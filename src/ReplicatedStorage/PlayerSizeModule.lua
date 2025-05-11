--[[
Name: PlayerSizeModule
Type: ModuleScript
Location: ReplicatedStorage
Description: Manages player size calculations and transformations
Interacts With:
  - PlayerSpawnHandler: Provides size calculation functions
  - SquashHandler: Uses size data for squash mechanics
--]]

local PlayerSizeModule = {}

-- Size configuration for actual game scaling
PlayerSizeModule.MIN_SIZE = 0.2     -- Minimum scale (0.2x normal size)
PlayerSizeModule.MAX_SIZE = 20      -- Maximum scale (20x normal size)
PlayerSizeModule.SPAWN_MAX_SIZE = 15 -- Maximum size players can spawn at
PlayerSizeModule.BASE_HEIGHT_FEET = 5  -- Standard character height in feet

-- Visual height configuration (adjusted for better progression)
PlayerSizeModule.VISUAL_MIN_HEIGHT = 5     -- Start at normal human height
PlayerSizeModule.VISUAL_MAX_HEIGHT = 1000  -- Allow for more impressive displayed heights
PlayerSizeModule.VISUAL_MID_HEIGHT = 100   -- Height at scale 10 (halfway point)

-- Growth configuration
PlayerSizeModule.SQUASH_GROWTH_FEET = 10 -- Add 10 feet per squash (more noticeable growth)

-- Get a random spawn size with non-linear distribution favoring smaller sizes
function PlayerSizeModule.getRandomSpawnSize()
    -- Use exponential distribution to favor smaller sizes
    local randomValue = math.random()
    local power = 3 -- Higher power = more bias towards smaller sizes
    local normalizedSize = math.pow(randomValue, power)
    
    -- Map to our desired range (MIN_SIZE to SPAWN_MAX_SIZE)
    local size = PlayerSizeModule.MIN_SIZE + 
        normalizedSize * (PlayerSizeModule.SPAWN_MAX_SIZE - PlayerSizeModule.MIN_SIZE)
    
    return math.floor(size * 100) / 100  -- Round to 2 decimal places
end

-- Calculate growth after squashing someone
function PlayerSizeModule.calculateSquashGrowth(currentSize)
    -- First get current visual height
    local currentVisualHeight = PlayerSizeModule.getVisualHeight(currentSize)
    local targetVisualHeight = currentVisualHeight + PlayerSizeModule.SQUASH_GROWTH_FEET
    
    -- Now we need to reverse-calculate what scale would give us this visual height
    local normalizedHeight = (targetVisualHeight - PlayerSizeModule.VISUAL_MIN_HEIGHT) / 
        (PlayerSizeModule.VISUAL_MAX_HEIGHT - PlayerSizeModule.VISUAL_MIN_HEIGHT)
    
    -- Reverse our two-phase curve
    local normalizedScale
    if normalizedHeight <= 0.5 then
        -- Reverse early growth phase
        normalizedScale = math.pow(normalizedHeight / 8, 1/3)
    else
        -- Reverse late growth phase
        local t = math.sqrt((normalizedHeight - 0.5) * 2)
        normalizedScale = 0.5 + t * 0.5
    end
    
    -- Map back to actual scale
    local newSize = PlayerSizeModule.MIN_SIZE + 
        normalizedScale * (PlayerSizeModule.MAX_SIZE - PlayerSizeModule.MIN_SIZE)
    
    -- Cap at MAX_SIZE and round to 2 decimal places
    return math.min(math.floor(newSize * 100) / 100, PlayerSizeModule.MAX_SIZE)
end

-- Convert actual scale to visual height using non-linear mapping
function PlayerSizeModule.getVisualHeight(scale)
    -- Normalize scale to 0-1 range
    local normalizedScale = (scale - PlayerSizeModule.MIN_SIZE) / 
        (PlayerSizeModule.MAX_SIZE - PlayerSizeModule.MIN_SIZE)
    
    -- Use a two-phase curve to make growth feel natural:
    -- Phase 1 (0-0.5): Cubic curve for quick early growth
    -- Phase 2 (0.5-1): Exponential curve for dramatic late growth
    local curvedScale
    if normalizedScale <= 0.5 then
        -- Early growth phase - cubic curve
        curvedScale = 8 * math.pow(normalizedScale, 3)
    else
        -- Late growth phase - exponential curve
        local t = (normalizedScale - 0.5) * 2 -- Normalize 0.5-1 to 0-1
        curvedScale = 0.5 + 0.5 * math.pow(t, 2)
    end
    
    -- Map to our visual height range
    local visualHeight = PlayerSizeModule.VISUAL_MIN_HEIGHT + 
        curvedScale * (PlayerSizeModule.VISUAL_MAX_HEIGHT - PlayerSizeModule.VISUAL_MIN_HEIGHT)
    
    return visualHeight
end

-- Format size for display (e.g., "SIZE: 6' 2"")
function PlayerSizeModule.formatSizeText(scale)
    local heightInFeet = PlayerSizeModule.getVisualHeight(scale)
    local feet = math.floor(heightInFeet)
    local inches = math.floor((heightInFeet - feet) * 12)
    return string.format("SIZE: %d' %d\"", feet, inches)
end

-- Validate if a size is within acceptable range
function PlayerSizeModule.isValidSize(size)
    return size >= PlayerSizeModule.MIN_SIZE and size <= PlayerSizeModule.MAX_SIZE
end

return PlayerSizeModule 