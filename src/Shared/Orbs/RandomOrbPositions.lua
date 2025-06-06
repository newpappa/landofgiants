--[[
Name: RandomOrbPositions
Type: ModuleScript
Location: ReplicatedStorage
Description: Manages random position sampling for orb spawning using grid-based positioning
--]]

local RandomOrbPositions = {}

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

-- Grid configuration
local GRID_SPACING = 25
local PLAYABLE_WIDTH = PLAYABLE_BOUNDS.MAX_X - PLAYABLE_BOUNDS.MIN_X
local PLAYABLE_DEPTH = PLAYABLE_BOUNDS.MAX_Z - PLAYABLE_BOUNDS.MIN_Z
local GRID_SIZE_X = math.ceil(PLAYABLE_WIDTH / GRID_SPACING)
local GRID_SIZE_Z = math.ceil(PLAYABLE_DEPTH / GRID_SPACING)
local HEIGHT_OFFSET = 1

-- Storage
local gridPositions = {}
local lastGenerationTime = 0
local REGENERATE_INTERVAL = 300

-- Services
local Workspace = game:GetService("Workspace")

-- Generate grid positions
local function generateGridPositions()
    local gridPositions = {}
    local validCount = 0
    
    for i = 0, GRID_SIZE_X - 1 do
        for j = 0, GRID_SIZE_Z - 1 do
            local x = PLAYABLE_BOUNDS.MIN_X + (i * GRID_SPACING)
            local z = PLAYABLE_BOUNDS.MIN_Z + (j * GRID_SPACING)
            
            -- Skip positions outside playable bounds
            local margin = 50
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
                    local spawnPosition = hitPosition + Vector3.new(0, HEIGHT_OFFSET, 0)
                    table.insert(gridPositions, spawnPosition)
                    validCount += 1
                end
            end
        end
    end
    
    lastGenerationTime = tick()
    return gridPositions
end

function RandomOrbPositions:Initialize()
    gridPositions = generateGridPositions()
end

function RandomOrbPositions:GetRandomPosition()
    if tick() - lastGenerationTime > REGENERATE_INTERVAL then
        gridPositions = generateGridPositions()
    end
    
    if #gridPositions == 0 then
        return nil
    end
    
    local randomIndex = math.random(1, #gridPositions)
    local position = gridPositions[randomIndex]
    
    -- Add some random variation to avoid exact grid placement
    local variation = Vector3.new(
        (math.random() - 0.5) * 20,
        0,
        (math.random() - 0.5) * 20
    )
    
    return position + variation
end

function RandomOrbPositions:GetPositionCount()
    return #gridPositions
end

function RandomOrbPositions:GetMapInfo()
    return {
        bounds = PLAYABLE_BOUNDS,
    }
end

return RandomOrbPositions 