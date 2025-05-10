local SquashEffect = {
    -- Animation parameters
    SQUASH_SCALE = Vector3.new(2, 0.1, 2), -- Flatten on Y axis, spread on X and Z
    ANIMATION_DURATION = 0.15, -- Quick squash animation
    
    -- Particle effect configuration
    PARTICLE_COLOR = Color3.fromRGB(150, 150, 150), -- Gray dust color
    PARTICLE_SIZE = NumberSequence.new(0.5, 0), -- Fade out size
    PARTICLE_LIFETIME = NumberRange.new(0.3, 0.5),
    PARTICLE_SPEED = NumberRange.new(3, 5),
    PARTICLE_SPREAD = NumberRange.new(0, 360), -- Full circular spread
    PARTICLE_COUNT = 30
}

return SquashEffect 