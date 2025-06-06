--[[
Name: RandomOrbPositions
Type: ModuleScript
Location: ReplicatedStorage.Shared.Orbs
Description: Manages random position sampling for orb spawning
Interacts With:
  - PositionSampler: Uses for base position sampling
  - OrbSpawnManager: Provides positions for orb spawning
--]]

local Promise = require(game:GetService("ReplicatedStorage").Shared.Core.Promise)
local PositionSampler = require(game:GetService("ServerScriptService").Server.Core.PositionSampler)

local RandomOrbPositions = {
    _initialized = false
}

-- Grid configuration
local GRID_SPACING = 25
local HEIGHT_OFFSET = 1
local MARGIN = 50
local VARIATION_AMOUNT = 20

-- Storage
local gridPositions = {}
local lastGenerationTime = 0
local REGENERATE_INTERVAL = 300

-- Generate grid positions
local function generateGridPositions()
    print("RandomOrbPositions: Generating grid positions...")
    -- Use PositionSampler to generate positions
    local positions, validCount = PositionSampler.GenerateGridPositions(GRID_SPACING, HEIGHT_OFFSET, MARGIN)
    gridPositions = positions
    lastGenerationTime = tick()
    print("RandomOrbPositions: Generated", validCount, "valid positions")
    return positions, validCount
end

function RandomOrbPositions.Init()
    if RandomOrbPositions._initialized then
        print("RandomOrbPositions: Already initialized")
        return Promise.resolve()
    end
    
    return Promise.new(function(resolve, reject)
        local success, err = pcall(function()
            print("RandomOrbPositions: Starting initialization...")
            
            -- Initialize PositionSampler first
            print("RandomOrbPositions: Initializing PositionSampler...")
            PositionSampler.Init():andThen(function()
                print("RandomOrbPositions: PositionSampler initialized")
                
                -- Generate initial grid positions
                generateGridPositions()
                
                RandomOrbPositions._initialized = true
                print("RandomOrbPositions: Initialization complete")
                resolve()
            end):catch(function(err)
                print("RandomOrbPositions: PositionSampler initialization failed:", err)
                reject(err)
            end)
        end)
        
        if not success then
            print("RandomOrbPositions: Initialization failed:", err)
            reject(err)
        end
    end)
end

function RandomOrbPositions:GetRandomPosition()
    if not RandomOrbPositions._initialized then
        error("RandomOrbPositions must be initialized before use")
    end
    
    if tick() - lastGenerationTime > REGENERATE_INTERVAL then
        print("RandomOrbPositions: Regenerating grid positions due to interval")
        gridPositions = generateGridPositions()
    end
    
    -- Use PositionSampler to get random position with variation
    local position = PositionSampler.GetRandomPosition(gridPositions, VARIATION_AMOUNT)
    if position then
        print("RandomOrbPositions: Generated random position:", position.X, position.Y, position.Z)
    else
        print("RandomOrbPositions: Failed to generate random position - no valid positions available")
    end
    return position
end

function RandomOrbPositions:GetPositionCount()
    if not RandomOrbPositions._initialized then
        error("RandomOrbPositions must be initialized before use")
    end

    return #gridPositions
end

function RandomOrbPositions:GetMapInfo()
    if not RandomOrbPositions._initialized then
        error("RandomOrbPositions must be initialized before use")
    end
    
    return {
        bounds = PositionSampler.GetPlayableBounds(),
    }
end

return RandomOrbPositions 