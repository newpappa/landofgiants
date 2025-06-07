--[[
Name: SpeedBoostEffects
Type: LocalScript
Location: StarterPlayerScripts.Client.Orbs
Description: Handles visual and audio effects for speed boost orbs
Interacts With:
  - OrbVisuals: Uses visual configurations
  - OrbPickupManager: Receives speed boost events
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

print("SpeedBoostEffects: Starting up...")

local OrbVisuals = require(ReplicatedStorage.Shared.Orbs.OrbVisuals)
local EventManager = require(ReplicatedStorage.Shared.Core.EventManager)

print("SpeedBoostEffects: Modules loaded")
print("SpeedBoostEffects: Speed boost config:", OrbVisuals.SPEED_BOOST)

-- Get the SpeedBoostEvent from EventManager
local SpeedBoostEvent = EventManager:GetEvent("SpeedBoostEvent")
print("SpeedBoostEffects: Found SpeedBoostEvent:", SpeedBoostEvent and "Yes" or "No")

-- Configuration
local TRAIL_LENGTH = 75 -- Increased trail length from 50 to 75 studs
local TRAIL_WIDTH = 3 -- New width multiplier for the trail

-- Variables
local activeTrail = nil -- Store the active trail instance

-- Function to create speed trail
local function createSpeedTrail(character)
    print("SpeedBoostEffects: Creating speed trail for character")
    local trail = Instance.new("Trail")
    trail.Name = "SpeedTrail"
    trail.Color = ColorSequence.new(OrbVisuals.ORB_TYPES.RAINBOW_SPEED.color)
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(1, 1)
    })
    trail.Lifetime = 0.5
    trail.MinLength = 0.3 -- Increased from 0.1
    trail.MaxLength = TRAIL_LENGTH
    trail.WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0, TRAIL_WIDTH),
        NumberSequenceKeypoint.new(1, TRAIL_WIDTH * 0.5)
    })
    
    -- Attach trail to character
    local attachment1 = Instance.new("Attachment")
    local attachment2 = Instance.new("Attachment")
    attachment1.Position = Vector3.new(0, 0, 1) -- Increased spread from 0.5
    attachment2.Position = Vector3.new(0, 0, -1) -- Increased spread from -0.5
    
    attachment1.Parent = character.HumanoidRootPart
    attachment2.Parent = character.HumanoidRootPart
    trail.Attachment0 = attachment1
    trail.Attachment1 = attachment2
    trail.Parent = character.HumanoidRootPart
    
    print("SpeedBoostEffects: Speed trail created and attached")
    return trail
end

-- Watch for new rainbow orbs
local function setupSpeedOrb(orb)
    if orb:GetAttribute("OrbType") == "RAINBOW_SPEED" then
        print("SpeedBoostEffects: Found rainbow speed orb")
    end
end

workspace.ChildAdded:Connect(function(child)
    if child.Name:match("^GrowthOrb") then
        setupSpeedOrb(child)
    end
end)

-- Handle speed boost effects
print("SpeedBoostEffects: Setting up event listener...")
if not SpeedBoostEvent then
    warn("SpeedBoostEffects: Failed to get SpeedBoostEvent!")
    return
end

print("SpeedBoostEffects: Connecting to SpeedBoostEvent...")
SpeedBoostEvent.OnClientEvent:Connect(function(isActive)
    print("SpeedBoostEffects: Received speed boost event, isActive:", isActive)
    local player = game.Players.LocalPlayer
    if not player.Character then 
        print("SpeedBoostEffects: No character found, returning")
        return 
    end
    
    if isActive then
        print("SpeedBoostEffects: Activating speed boost effects")
        -- Clean up existing trail if any
        if activeTrail and activeTrail.Parent then
            print("SpeedBoostEffects: Cleaning up existing trail")
            activeTrail:Destroy()
        end
        
        -- Create speed trail
        activeTrail = createSpeedTrail(player.Character)
        
        -- Fade in trail
        local tweenInfo = TweenInfo.new(OrbVisuals.SPEED_BOOST.fadeTime, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(activeTrail, tweenInfo, {
            MaxLength = TRAIL_LENGTH
        })
        tween:Play()
        print("SpeedBoostEffects: Started fade in tween")
    else
        print("SpeedBoostEffects: Deactivating speed boost effects")
        -- Find and remove trail
        if activeTrail and activeTrail.Parent then
            -- Fade out trail
            local tweenInfo = TweenInfo.new(OrbVisuals.SPEED_BOOST.fadeTime, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(activeTrail, tweenInfo, {
                MaxLength = 0
            })
            tween:Play()
            print("SpeedBoostEffects: Started fade out tween")
            
            -- Remove trail after fade
            task.delay(OrbVisuals.SPEED_BOOST.fadeTime, function()
                if activeTrail and activeTrail.Parent then
                    activeTrail:Destroy()
                end
                activeTrail = nil
                print("SpeedBoostEffects: Trail cleanup complete")
            end)
        end
    end
end)
print("SpeedBoostEffects: Event listener set up")

-- Set up existing orbs
for _, orb in ipairs(workspace:GetChildren()) do
    if orb.Name:match("^GrowthOrb") then
        setupSpeedOrb(orb)
    end
end

print("SpeedBoostEffects: Initialization complete") 