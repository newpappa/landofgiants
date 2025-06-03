--[[
Name: OrbSpawner
Type: ModuleScript
Location: ReplicatedStorage
Description: Handles the creation and visual setup of orbs
Interacts With:
  - OrbVisuals: Uses visual configurations for orb creation
  - OrbManager: Receives spawn requests
  - OrbCounter: Records spawn statistics
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local OrbVisuals = require(ReplicatedStorage:WaitForChild("OrbVisuals"))
local OrbCounter = require(ReplicatedStorage:WaitForChild("OrbCounter"))

-- Create a folder for orbs
local orbFolder = Instance.new("Folder")
orbFolder.Name = "GrowthOrbs"
orbFolder.Parent = Workspace

local OrbSpawner = {}

-- Function to create a new orb
function OrbSpawner.CreateOrb(positionData)
    -- Handle both Vector3 and custom position table
    local position
    local forcedType
    
    if typeof(positionData) == "Vector3" then
        position = positionData
    elseif typeof(positionData) == "table" then
        position = positionData.position
        forcedType = positionData.forcedType
    else
        warn("OrbSpawner: Invalid position data type")
        return nil
    end
    
    -- Select orb type based on rarity or forced type
    local selectedType = forcedType
    if not selectedType then
        local rand = math.random()
        local cumulativeRarity = 0
        
        for typeName, typeData in pairs(OrbVisuals.ORB_TYPES) do
            cumulativeRarity = cumulativeRarity + typeData.rarity
            if rand <= cumulativeRarity then
                selectedType = typeName
                break
            end
        end
    end
    
    local typeData = OrbVisuals.ORB_TYPES[selectedType]
    if not typeData then
        warn("OrbSpawner: Invalid orb type:", selectedType)
        return nil
    end
    
    -- Create the orb part
    local orb = Instance.new("Part")
    orb.Name = "GrowthOrb_" .. selectedType
    orb.Anchored = true
    orb.CanCollide = false
    orb.Size = Vector3.new(1, 1, 1) * typeData.scale
    orb.Color = typeData.color
    orb.Material = Enum.Material.Neon
    orb.Shape = Enum.PartType.Ball
    orb.Transparency = 0.2
    orb.Position = position
    orb.Parent = orbFolder
    
    -- Add glow effect with reduced initial intensity
    local glow = Instance.new("PointLight")
    glow.Color = typeData.glowColor
    glow.Brightness = 0
    glow.Range = 8
    glow.Parent = orb
    
    -- Add particle effect with reduced initial rate
    local particles = Instance.new("ParticleEmitter")
    particles.Color = ColorSequence.new(typeData.glowColor)
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, OrbVisuals.GLOW_EFFECT.size),
        NumberSequenceKeypoint.new(1, 0)
    })
    particles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 1)
    })
    particles.Lifetime = NumberRange.new(1, 2)
    particles.Rate = 0
    particles.Speed = NumberRange.new(1, 2)
    particles.SpreadAngle = Vector2.new(0, 180)
    particles.Parent = orb
    
    -- Store orb data
    orb:SetAttribute("GrowthAmount", typeData.growthAmount)
    orb:SetAttribute("OrbType", selectedType)
    
    -- Gradually increase visual effects
    task.delay(0.5, function()
        if orb and orb.Parent then
            glow.Brightness = OrbVisuals.GLOW_EFFECT.brightness
            particles.Rate = 15
            particles.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.3),
                NumberSequenceKeypoint.new(1, 1)
            })
        end
    end)
    
    -- Log successful spawn
    OrbCounter.LogSuccess(selectedType)
    
    return orb
end

-- Function to remove an orb
function OrbSpawner.RemoveOrb(orb)
    if orb and orb.Parent then
        orb:Destroy()
    end
end

-- Function to record failed spawn
function OrbSpawner.RecordFailedSpawn()
    OrbCounter.LogFail()
end

return OrbSpawner 