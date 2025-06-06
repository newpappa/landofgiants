--[[
Name: PositionSampler
Type: ModuleScript
Location: ReplicatedStorage.Shared.Core
Description: Core position sampling system for grid-based positioning
Interacts With:
  - RandomOrbPositions: Provides base position sampling
  - RandomNPCPositions: Will provide base position sampling
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Shared.Core.Promise)

local PositionSampler = {
    _initialized = false
}

-- Playable world corner points - use these to define the actual spawn area
local PLAYABLE_CORNERS = {
    NORTHWEST = Vector3.new(-1200, 2570.875, 0),
    SOUTHWEST = Vector3.new(-1200, 2570.875, 3800),
    SOUTHEAST = Vector3.new(2400, 2570.875, 3800),
    NORTHEAST = Vector3.new(2400, 2570.875, 0)
}

-- Calculate the bounding box from the playable corners
local PLAYABLE_BOUNDS = {
    MIN_X = math.min(PLAYABLE_CORNERS.NORTHWEST.X, PLAYABLE_CORNERS.SOUTHWEST.X, PLAYABLE_CORNERS.SOUTHEAST.X, PLAYABLE_CORNERS.NORTHEAST.X),
    MAX_X = math.max(PLAYABLE_CORNERS.NORTHWEST.X, PLAYABLE_CORNERS.SOUTHWEST.X, PLAYABLE_CORNERS.SOUTHEAST.X, PLAYABLE_CORNERS.NORTHEAST.X),
    MIN_Z = math.min(PLAYABLE_CORNERS.NORTHWEST.Z, PLAYABLE_CORNERS.SOUTHWEST.Z, PLAYABLE_CORNERS.SOUTHEAST.Z, PLAYABLE_CORNERS.NORTHEAST.Z),
    MAX_Z = math.max(PLAYABLE_CORNERS.NORTHWEST.Z, PLAYABLE_CORNERS.SOUTHWEST.Z, PLAYABLE_CORNERS.SOUTHEAST.Z, PLAYABLE_CORNERS.NORTHEAST.Z),
    Y = PLAYABLE_CORNERS.NORTHWEST.Y
}

-- Services
local Workspace = game:GetService("Workspace")

-- Initialize the module
function PositionSampler.Init()
    if PositionSampler._initialized then
        print("PositionSampler: Already initialized")
        return Promise.resolve()
    end

    return Promise.new(function(resolve, reject)
        local success, err = pcall(function()
            print("PositionSampler: Starting initialization...")
            -- Validate playable bounds
            if not PLAYABLE_BOUNDS.MIN_X or not PLAYABLE_BOUNDS.MAX_X or 
               not PLAYABLE_BOUNDS.MIN_Z or not PLAYABLE_BOUNDS.MAX_Z or 
               not PLAYABLE_BOUNDS.Y then
                error("Invalid playable bounds configuration")
            end

            print("PositionSampler: Playable bounds validated")
            print("PositionSampler: Bounds:", PLAYABLE_BOUNDS.MIN_X, PLAYABLE_BOUNDS.MAX_X, PLAYABLE_BOUNDS.MIN_Z, PLAYABLE_BOUNDS.MAX_Z, PLAYABLE_BOUNDS.Y)

            -- Initialize any additional resources here
            PositionSampler._initialized = true
            print("PositionSampler: Initialization complete")
        end)

        if success then
            resolve()
        else
            print("PositionSampler: Initialization failed:", err)
            reject(err)
        end
    end)
end

-- Generate grid positions
function PositionSampler.GenerateGridPositions(gridSpacing, heightOffset, margin)
    if not PositionSampler._initialized then
        error("PositionSampler must be initialized before use")
    end

    print("PositionSampler: Generating grid positions with spacing:", gridSpacing, "height:", heightOffset, "margin:", margin)
    local gridPositions = {}
    local validCount = 0
    
    local PLAYABLE_WIDTH = PLAYABLE_BOUNDS.MAX_X - PLAYABLE_BOUNDS.MIN_X
    local PLAYABLE_DEPTH = PLAYABLE_BOUNDS.MAX_Z - PLAYABLE_BOUNDS.MIN_Z
    local GRID_SIZE_X = math.ceil(PLAYABLE_WIDTH / gridSpacing)
    local GRID_SIZE_Z = math.ceil(PLAYABLE_DEPTH / gridSpacing)
    
    print("PositionSampler: Grid size:", GRID_SIZE_X, "x", GRID_SIZE_Z)
    
    for i = 0, GRID_SIZE_X - 1 do
        for j = 0, GRID_SIZE_Z - 1 do
            local x = PLAYABLE_BOUNDS.MIN_X + (i * gridSpacing)
            local z = PLAYABLE_BOUNDS.MIN_Z + (j * gridSpacing)
            
            -- Skip positions outside playable bounds
            if x < PLAYABLE_BOUNDS.MIN_X - margin or x > PLAYABLE_BOUNDS.MAX_X + margin or
               z < PLAYABLE_BOUNDS.MIN_Z - margin or z > PLAYABLE_BOUNDS.MAX_Z + margin then
                continue
            end
            
            -- Raycast to find ground
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.FilterDescendantsInstances = {workspace.CurrentCamera}
            
            local rayOrigin = Vector3.new(x, PLAYABLE_BOUNDS.Y + 100, z)
            local rayDirection = Vector3.new(0, -200, 0)
            
            local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
            
            if raycastResult then
                local hitPosition = raycastResult.Position
                local hitNormal = raycastResult.Normal
                
                if hitNormal.Y > 0.3 and math.abs(hitPosition.Y - PLAYABLE_BOUNDS.Y) <= 10 then
                    local spawnPosition = hitPosition + Vector3.new(0, heightOffset, 0)
                    table.insert(gridPositions, spawnPosition)
                    validCount += 1
                end
            end
        end
    end
    
    print("PositionSampler: Generated", validCount, "valid positions")
    return gridPositions, validCount
end

-- Get random position with variation
function PositionSampler.GetRandomPosition(gridPositions, variationAmount)
    if not PositionSampler._initialized then
        error("PositionSampler must be initialized before use")
    end

    if #gridPositions == 0 then
        return nil
    end
    
    local randomIndex = math.random(1, #gridPositions)
    local position = gridPositions[randomIndex]
    
    -- Add some random variation to avoid exact grid placement
    local variation = Vector3.new(
        (math.random() - 0.5) * variationAmount,
        0,
        (math.random() - 0.5) * variationAmount
    )
    
    return position + variation
end

-- Get playable bounds
function PositionSampler.GetPlayableBounds()
    if not PositionSampler._initialized then
        error("PositionSampler must be initialized before use")
    end

    return PLAYABLE_BOUNDS
end

return PositionSampler 