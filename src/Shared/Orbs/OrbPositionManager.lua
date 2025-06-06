--[[
Name: OrbPositionManager
Type: ModuleScript
Location: ReplicatedStorage
Description: Manages the sampling and distribution of valid orb positions
Interacts With:
  - OrbSpawner: Provides position data for orb spawning
--]]

local OrbPositionManager = {}

-- Configuration
local CONFIG = {
    SAMPLE_GRID_SIZE = 2,        -- How far apart to sample points
    MIN_ORB_DISTANCE = 3,        -- Minimum distance between orbs
    MIN_SURFACE_ANGLE = 0.7,     -- Maximum angle for valid surface (in radians)
    SPAWN_RADIUS = 200,          -- Maximum distance from center
    SPAWN_CENTER = Vector3.new(125.79, 2570.875, 1845.954),  -- Center point for orb spawning
    MAX_SAMPLE_HEIGHT = 50,      -- Maximum height to sample from
    MIN_SAMPLE_HEIGHT = 0,       -- Minimum height to sample from
}

-- Private variables
local validPositions = {}
local availablePositions = {}
local positionCooldowns = {}

-- Private function to check if a position is valid
local function isValidPosition(position)
    -- Check if within spawn radius
    local distanceFromCenter = (position - CONFIG.SPAWN_CENTER).Magnitude
    if distanceFromCenter > CONFIG.SPAWN_RADIUS then
        return false
    end

    -- Check if position is too close to other valid positions
    for _, existingPos in ipairs(validPositions) do
        if (position - existingPos).Magnitude < CONFIG.MIN_ORB_DISTANCE then
            return false
        end
    end

    return true
end

-- Private function to sample the map
local function sampleMap()
    local gridSize = CONFIG.SAMPLE_GRID_SIZE
    local center = CONFIG.SPAWN_CENTER
    local radius = CONFIG.SPAWN_RADIUS
    
    -- Calculate grid bounds
    local minX = center.X - radius
    local maxX = center.X + radius
    local minZ = center.Z - radius
    local maxZ = center.Z + radius
    
    -- Sample the grid
    for x = minX, maxX, gridSize do
        for z = minZ, maxZ, gridSize do
            -- Raycast from above
            local rayOrigin = Vector3.new(x, CONFIG.MAX_SAMPLE_HEIGHT, z)
            local rayDirection = Vector3.new(0, -1, 0)
            local raycastResult = workspace:Raycast(rayOrigin, rayDirection * (CONFIG.MAX_SAMPLE_HEIGHT - CONFIG.MIN_SAMPLE_HEIGHT))
            
            if raycastResult then
                local position = raycastResult.Position
                local normal = raycastResult.Normal
                
                -- Check if surface is valid (not too steep)
                if normal.Y > CONFIG.MIN_SURFACE_ANGLE then
                    if isValidPosition(position) then
                        table.insert(validPositions, position)
                    end
                end
            end
        end
    end
    
    -- Initialize available positions
    availablePositions = table.clone(validPositions)
end

-- Public function to initialize the position manager
function OrbPositionManager.Initialize()
    print("OrbPositionManager: Starting position sampling...")
    sampleMap()
    print("OrbPositionManager: Sampled", #validPositions, "valid positions")
end

-- Public function to get a random position
function OrbPositionManager.GetRandomPosition()
    if #availablePositions == 0 then
        -- If no positions available, reset the pool
        availablePositions = table.clone(validPositions)
    end
    
    -- Get random position from available pool
    local index = math.random(1, #availablePositions)
    local position = availablePositions[index]
    
    -- Remove from available pool
    table.remove(availablePositions, index)
    
    -- Add to cooldown
    positionCooldowns[position] = os.time()
    
    return position
end

-- Public function to return a position to the pool
function OrbPositionManager.ReturnPosition(position)
    if positionCooldowns[position] then
        positionCooldowns[position] = nil
        table.insert(availablePositions, position)
    end
end

return OrbPositionManager 