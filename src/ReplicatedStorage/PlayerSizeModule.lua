local PlayerSizeModule = {}

-- Constants
PlayerSizeModule.MIN_SIZE = 0.2    -- 1 foot tall (0.2x normal size)
PlayerSizeModule.MAX_SIZE = 20     -- 100 feet tall (20x normal size)
PlayerSizeModule.BASE_HEIGHT_FEET = 5 -- Standard character height in feet

-- Get a random size within the configured range
function PlayerSizeModule.getRandomSize()
    return PlayerSizeModule.MIN_SIZE + math.random() * (PlayerSizeModule.MAX_SIZE - PlayerSizeModule.MIN_SIZE)
end

-- Convert scale multiplier to actual height in feet
function PlayerSizeModule.getHeightInFeet(scale)
    return PlayerSizeModule.BASE_HEIGHT_FEET * scale
end

-- Format size for display
function PlayerSizeModule.formatSizeText(size)
    local heightInFeet = PlayerSizeModule.getHeightInFeet(size)
    local feet = math.floor(heightInFeet)
    local inches = math.floor((heightInFeet - feet) * 12)
    return string.format("SIZE: %d' %d\"", feet, inches)
end

-- Validate if a size is within acceptable range
function PlayerSizeModule.isValidSize(size)
    return size >= PlayerSizeModule.MIN_SIZE and size <= PlayerSizeModule.MAX_SIZE
end

return PlayerSizeModule 