--[[
Name: OrbManager
Type: Script
Location: ServerScriptService
Description: Manages orb spawning and cleanup
Interacts With:
  - OrbSpawner: Creates and removes orbs
  - RandomOrbPositions: Gets spawn positions
  - OrbCounter: Records spawn statistics
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Load dependencies
local RandomOrbPositions = require(ReplicatedStorage:WaitForChild("RandomOrbPositions"))
local OrbSpawner = require(ReplicatedStorage:WaitForChild("OrbSpawner"))

-- Configuration
local CONFIG = {
    MIN_ORBS = 500,          -- Minimum number of orbs in the game
    MAX_ORBS = 500,          -- Maximum number of orbs in the game
    SPAWN_INTERVAL = 1,      -- How often to check for new orb spawns (seconds)
    DEATH_ORB_SPREAD = 5,    -- How far death orbs spread from death position
    DEATH_ORB_MIN_DISTANCE = 2  -- Minimum distance between death orbs
}

-- Create the OrbManager table
local OrbManager = {}

-- Track active orbs
local activeOrbs = {}

-- Initialize systems
local function initialize()
    print("OrbManager: Starting initialization...")
    RandomOrbPositions.Initialize()
    print("OrbManager: Initialization complete")
end

-- Function to get a valid position for death orbs
local function getDeathOrbPosition(centerPosition, existingPositions)
    local attempts = 0
    local maxAttempts = 10
    
    while attempts < maxAttempts do
        -- Generate random offset
        local angle = math.random() * math.pi * 2
        local radius = math.random() * CONFIG.DEATH_ORB_SPREAD
        local offset = Vector3.new(
            math.cos(angle) * radius,
            0,
            math.sin(angle) * radius
        )
        
        local position = centerPosition + offset
        
        -- Check if position is valid
        local isValid = true
        for _, existingPos in ipairs(existingPositions) do
            if (position - existingPos).Magnitude < CONFIG.DEATH_ORB_MIN_DISTANCE then
                isValid = false
                break
            end
        end
        
        if isValid then
            return position
        end
        
        attempts = attempts + 1
    end
    
    -- If no valid position found, return slightly offset from center
    return centerPosition + Vector3.new(
        math.random(-1, 1),
        0,
        math.random(-1, 1)
    )
end

-- Function to spawn orbs from a death
function OrbManager.SpawnDeathOrbs(position, amount)
    local positions = {}
    
    -- Generate positions for death orbs
    for i = 1, amount do
        local orbPosition = getDeathOrbPosition(position, positions)
        table.insert(positions, orbPosition)
    end
    
    -- Spawn orbs at positions
    for _, orbPosition in ipairs(positions) do
        local orb = OrbSpawner.CreateOrb(orbPosition)
        if orb then
            activeOrbs[orb] = true
        end
    end
end

-- Function to spawn a random orb
function OrbManager.SpawnRandomOrb()
    local position = RandomOrbPositions.GetRandomPosition()
    if not position then
        print("OrbManager: No valid positions available for random spawn")
        OrbSpawner.RecordFailedSpawn()
        return
    end
    
    local orb = OrbSpawner.CreateOrb(position)
    if orb then
        activeOrbs[orb] = true
    else
        print("OrbManager: Failed to create orb at position:", position.X, position.Y, position.Z)
        OrbSpawner.RecordFailedSpawn()
    end
end

-- Function to remove an orb
function OrbManager.RemoveOrb(orb)
    if activeOrbs[orb] then
        activeOrbs[orb] = nil
        OrbSpawner.RemoveOrb(orb)
    end
end

-- Function to get current orb count
function OrbManager.GetOrbCount()
    local count = 0
    for orb, _ in pairs(activeOrbs) do
        if orb and orb:IsDescendantOf(workspace) then
            count = count + 1
        else
            activeOrbs[orb] = nil
        end
    end
    return count
end

-- Initialize the system
initialize()

-- Fast initial spawning to reach minimum orb count quickly
task.spawn(function()
    print("OrbManager: Starting initial orb spawn...")
    
    local currentCount = OrbManager.GetOrbCount()
    local needed = CONFIG.MIN_ORBS - currentCount
    
    -- Spawn all needed orbs instantly
    for i = 1, needed do
        OrbManager.SpawnRandomOrb()
        -- Small wait to prevent overwhelming
        if i % 50 == 0 then
            task.wait()
        end
    end
    
    -- Wait a moment for all orbs to fully spawn
    task.wait(1)
    
    -- Print final spawn stats
    print("\n=== INITIAL SPAWN COMPLETE ===")
    print("Target Count:", CONFIG.MIN_ORBS)
    print("Actual Count:", OrbManager.GetOrbCount())
    print("=============================\n")
end)

-- Start periodic random spawn check for maintenance
task.spawn(function()
    -- Wait a bit for initial spawning to complete
    task.wait(2)
    
    while true do
        task.wait(CONFIG.SPAWN_INTERVAL)
        
        local count = OrbManager.GetOrbCount()
        if count < CONFIG.MIN_ORBS then
            OrbManager.SpawnRandomOrb()
        end
    end
end)

return OrbManager 