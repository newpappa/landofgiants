--[[
Name: RandomNPCPositions
Type: ModuleScript
Location: ServerScriptService.Server.NPC
Description: Manages random position sampling for NPC spawning
Interacts With:
  - PositionSampler: Uses for base position sampling
  - NPCSpawnManager: Provides positions for NPC spawning
--]]

local Promise = require(game:GetService("ReplicatedStorage").Shared.Core.Promise)
local PositionSampler = require(game:GetService("ServerScriptService").Server.Core.PositionSampler)

local RandomNPCPositions = {
    _initialized = false
}

-- Grid configuration
local GRID_SPACING = 50 -- Larger spacing than orbs to avoid overcrowding
local HEIGHT_OFFSET = 1
local MARGIN = 100 -- Larger margin to keep NPCs away from map edges
local VARIATION_AMOUNT = 30 -- More variation than orbs for natural movement

-- Storage
local gridPositions = {}
local lastGenerationTime = 0
local REGENERATE_INTERVAL = 600 -- Longer interval than orbs since NPCs move

-- Generate grid positions
local function generateGridPositions()
    print("RandomNPCPositions: Generating grid positions...")
    -- Use PositionSampler to generate positions
    local positions, validCount = PositionSampler.GenerateGridPositions(GRID_SPACING, HEIGHT_OFFSET, MARGIN)
    gridPositions = positions
    lastGenerationTime = tick()
    print("RandomNPCPositions: Generated", validCount, "valid positions")
    return positions, validCount
end

function RandomNPCPositions.Init()
    if RandomNPCPositions._initialized then
        print("RandomNPCPositions: Already initialized")
        return Promise.resolve()
    end
    
    return Promise.new(function(resolve, reject)
        local success, err = pcall(function()
            print("RandomNPCPositions: Starting initialization...")
            
            -- Initialize PositionSampler first
            print("RandomNPCPositions: Initializing PositionSampler...")
            PositionSampler.Init():andThen(function()
                print("RandomNPCPositions: PositionSampler initialized")
                
                -- Generate initial grid positions
                generateGridPositions()
                
                RandomNPCPositions._initialized = true
                print("RandomNPCPositions: Initialization complete")
                resolve()
            end):catch(function(err)
                print("RandomNPCPositions: PositionSampler initialization failed:", err)
                reject(err)
            end)
        end)
        
        if not success then
            print("RandomNPCPositions: Initialization failed:", err)
            reject(err)
        end
    end)
end

function RandomNPCPositions:GetRandomPosition()
    if not RandomNPCPositions._initialized then
        error("RandomNPCPositions must be initialized before use")
    end
    
    if tick() - lastGenerationTime > REGENERATE_INTERVAL then
        print("RandomNPCPositions: Regenerating grid positions due to interval")
        gridPositions = generateGridPositions()
    end
    
    -- Use PositionSampler to get random position with variation
    local position = PositionSampler.GetRandomPosition(gridPositions, VARIATION_AMOUNT)
    if position then
        print("RandomNPCPositions: Generated random position:", position.X, position.Y, position.Z)
    else
        print("RandomNPCPositions: Failed to generate random position - no valid positions available")
    end
    return position
end

function RandomNPCPositions:GetPositionCount()
    if not RandomNPCPositions._initialized then
        error("RandomNPCPositions must be initialized before use")
    end

    return #gridPositions
end

function RandomNPCPositions:GetMapInfo()
    if not RandomNPCPositions._initialized then
        error("RandomNPCPositions must be initialized before use")
    end
    
    return {
        bounds = PositionSampler.GetPlayableBounds(),
    }
end

return RandomNPCPositions 