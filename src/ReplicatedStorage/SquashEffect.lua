--[[
Name: SquashEffect
Type: ModuleScript
Location: ReplicatedStorage
Description: Defines visual and animation configurations for squash effects
Interacts With:
  - SquashEffectHandler: Uses these configurations for visual effects
--]]

local SquashEffect = {
    -- Animation parameters
    SQUASH_ANIMATION_ID = "rbxassetid://393916540", -- Death animation
    
    -- Particle effect configuration
    PARTICLE_COLOR = Color3.fromRGB(150, 150, 150), -- Gray dust color
    PARTICLE_SIZE = NumberSequence.new(0.5, 0), -- Fade out size
    PARTICLE_LIFETIME = NumberRange.new(0.3, 0.5),
    PARTICLE_SPEED = NumberRange.new(3, 5),
    PARTICLE_SPREAD = NumberRange.new(0, 360), -- Full circular spread
    PARTICLE_COUNT = 30
}

return SquashEffect 