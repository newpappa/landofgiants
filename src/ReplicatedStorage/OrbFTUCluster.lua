--[[
Name: OrbFTUCluster
Type: ModuleScript
Location: ReplicatedStorage
Description: Spawns a cluster of orbs in front of new players for first-time user experience
Interacts With:
  - OrbSpawner: Creates orbs
  - OrbVisuals: Uses visual configurations
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OrbSpawner = require(ReplicatedStorage:WaitForChild("OrbSpawner"))
local OrbVisuals = require(ReplicatedStorage:WaitForChild("OrbVisuals"))

local OrbFTUCluster = {}

-- Configuration for FTU orb cluster
local CONFIG = {
    ORBS_PER_CLUSTER = 3,       -- Number of orbs to spawn in the cluster
    DISTANCE_FROM_PLAYER = 12,   -- Base distance from player
    HEIGHT_OFFSET = 1,          -- Height above ground to spawn orbs
    -- Offsets for each orb relative to base position (forward, left)
    ORB_OFFSETS = {
        {10, 8},    -- First orb: slightly forward and left
        {8, 10},    -- Second orb: more to the left, slightly less forward
        {12, 9},    -- Third orb: most forward, between the other two laterally
    }
}

-- Function to get a position for an orb in the cluster
local function getOrbPosition(character, index)
    local forward = character.PrimaryPart.CFrame.LookVector
    local right = character.PrimaryPart.CFrame.RightVector
    
    -- Get the offset for this orb
    local forwardOffset = CONFIG.ORB_OFFSETS[index + 1][1]
    local leftOffset = CONFIG.ORB_OFFSETS[index + 1][2]
    
    -- Calculate position using offsets
    local offset = (forward * forwardOffset) + (right * -leftOffset) -- Negative right = left
    local basePosition = character.PrimaryPart.Position + offset
    
    -- Raycast to find ground position
    local rayOrigin = basePosition + Vector3.new(0, 10, 0)
    local rayDirection = Vector3.new(0, -20, 0)
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection)
    
    if raycastResult then
        return raycastResult.Position + Vector3.new(0, CONFIG.HEIGHT_OFFSET, 0)
    end
    
    -- Fallback if raycast fails
    return basePosition + Vector3.new(0, CONFIG.HEIGHT_OFFSET, 0)
end

-- Function to spawn a cluster of orbs in front of a player
function OrbFTUCluster:SpawnCluster(character)
    if not character or not character.PrimaryPart then
        warn("OrbFTUCluster: Invalid character or missing PrimaryPart")
        return
    end
    
    -- Spawn orbs in the cluster
    for i = 0, CONFIG.ORBS_PER_CLUSTER - 1 do
        local position = getOrbPosition(character, i)
        
        -- Create the orb with a specific pattern:
        -- First few are small, middle is medium, last is speed boost
        local orbType = "SMALL"
        if i == CONFIG.ORBS_PER_CLUSTER - 2 then
            orbType = "MEDIUM" -- Second to last orb is medium sized
        elseif i == CONFIG.ORBS_PER_CLUSTER - 1 then
            orbType = "RAINBOW_SPEED" -- Last orb is speed boost
        end
        
        -- Force the orb type by creating a custom position table
        local customPosition = {
            position = position,
            forcedType = orbType
        }
        
        OrbSpawner.CreateOrb(customPosition)
    end
end

return OrbFTUCluster 