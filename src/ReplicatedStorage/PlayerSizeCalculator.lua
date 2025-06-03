--[[
Name: PlayerSizeCalculator
Type: ModuleScript
Location: ReplicatedStorage
Description: Handles size calculations and conversions between raw scale and visual height
Interacts With:
  - PlayerSpawnHandler: Provides size calculation functions
  - SquashHandler: Uses size data for squash mechanics
--]]

local PlayerSizeCalculator = {}

-- Size configuration for actual game scaling
PlayerSizeCalculator.MIN_SIZE = 0.2     -- Minimum scale (0.2x normal size)
PlayerSizeCalculator.MAX_SIZE = 20      -- Maximum scale (20x normal size)
PlayerSizeCalculator.SPAWN_MAX_SIZE = 15 -- Maximum size players can spawn at
PlayerSizeCalculator.BASE_HEIGHT_FEET = 5  -- Standard character height in feet

-- Visual height configuration (adjusted for better progression)
PlayerSizeCalculator.VISUAL_MIN_HEIGHT = 5     -- Start at normal human height
PlayerSizeCalculator.VISUAL_MAX_HEIGHT = 1000  -- Allow for more impressive displayed heights
PlayerSizeCalculator.VISUAL_MID_HEIGHT = 100   -- Height at scale 10 (halfway point)

-- Growth configuration
PlayerSizeCalculator.SQUASH_GROWTH_FEET = 10 -- Add 10 feet per squash (more noticeable growth)

-- Get both scale and visual height together
function PlayerSizeCalculator.getSizeData(scale)
    if not PlayerSizeCalculator.isValidSize(scale) then
        return nil
    end
    return {
        scale = scale,
        visualHeight = PlayerSizeCalculator.getVisualHeight(scale)
    }
end

-- Get a random spawn size with non-linear distribution favoring smaller sizes
function PlayerSizeCalculator.getRandomSpawnSize()
    -- Always return minimum size
    print("PlayerSizeCalculator: Spawning at minimum size:", PlayerSizeCalculator.MIN_SIZE)
    return PlayerSizeCalculator.getSizeData(PlayerSizeCalculator.MIN_SIZE)
end

-- Calculate growth after squashing someone
function PlayerSizeCalculator.calculateSquashGrowth(currentSize)
    print("\nGrowth Calculation Start - Current Size:", currentSize)
    
    -- First get current visual height
    local currentVisualHeight = PlayerSizeCalculator.getVisualHeight(currentSize)
    print("Current Visual Height:", currentVisualHeight, "feet")
    
    local targetVisualHeight = currentVisualHeight + PlayerSizeCalculator.SQUASH_GROWTH_FEET
    print("Target Visual Height:", targetVisualHeight, "feet")
    
    -- Now we need to reverse-calculate what scale would give us this visual height
    local normalizedHeight = (targetVisualHeight - PlayerSizeCalculator.VISUAL_MIN_HEIGHT) / 
        (PlayerSizeCalculator.VISUAL_MAX_HEIGHT - PlayerSizeCalculator.VISUAL_MIN_HEIGHT)
    print("Normalized Height:", normalizedHeight)
    
    -- Reverse the inverse exponential curve
    -- Original: y = 1 - 4^(-x)
    -- Reverse: x = -log4(1 - y)
    local normalizedScale = -math.log(1 - normalizedHeight, 4)
    print("Reversed Scale:", normalizedScale)
    
    -- Map back to actual scale
    local newSize = PlayerSizeCalculator.MIN_SIZE + 
        normalizedScale * (PlayerSizeCalculator.MAX_SIZE - PlayerSizeCalculator.MIN_SIZE)
    print("New Size Before Cap:", newSize)
    
    -- Cap at MAX_SIZE and round to 2 decimal places
    local finalSize = math.min(math.floor(newSize * 100) / 100, PlayerSizeCalculator.MAX_SIZE)
    print("Final Size After Cap:", finalSize)
    return finalSize
end

-- Convert actual scale to visual height using non-linear mapping
function PlayerSizeCalculator.getVisualHeight(scale)
    print("\nVisual Height Calculation - Input Scale:", scale)
    
    -- Normalize scale to 0-1 range
    local normalizedScale = (scale - PlayerSizeCalculator.MIN_SIZE) / 
        (PlayerSizeCalculator.MAX_SIZE - PlayerSizeCalculator.MIN_SIZE)
    print("Normalized Scale:", normalizedScale)
    
    -- Use inverse exponential curve for better progression
    -- Fast growth at small sizes, slowing down at larger sizes
    -- Formula: y = 1 - 4^(-x)
    local curvedScale = 1 - math.pow(4, -normalizedScale)
    print("Inverse Exponential Curved Scale:", curvedScale)
    
    -- Map to our visual height range
    local visualHeight = PlayerSizeCalculator.VISUAL_MIN_HEIGHT + 
        curvedScale * (PlayerSizeCalculator.VISUAL_MAX_HEIGHT - PlayerSizeCalculator.VISUAL_MIN_HEIGHT)
    print("Final Visual Height:", visualHeight, "feet")
    
    return visualHeight
end

-- Format size for display (e.g., "SIZE: 6' 2"")
function PlayerSizeCalculator.formatSizeText(scale)
    local heightInFeet = PlayerSizeCalculator.getVisualHeight(scale)
    local feet = math.floor(heightInFeet)
    local inches = math.floor((heightInFeet - feet) * 12)
    return string.format("SIZE: %d' %d\"", feet, inches)
end

-- Validate if a size is within acceptable range
function PlayerSizeCalculator.isValidSize(size)
    return size >= PlayerSizeCalculator.MIN_SIZE and size <= PlayerSizeCalculator.MAX_SIZE
end

return PlayerSizeCalculator 