--[[
Name: OrbVisuals
Type: ModuleScript
Location: ReplicatedStorage
Description: Defines visual configurations and effects for growth orbs
Interacts With:
  - OrbSpawner: Uses these configurations for orb creation
  - OrbPickupManager: Uses these configurations for pickup effects
--]]

local OrbVisuals = {
    -- Orb types and their properties
    ORB_TYPES = {
        SMALL = {
            scale = 2,
            growthAmount = 0.05, -- raw scale increment
            color = Color3.fromRGB(255, 255, 0), -- Yellow
            glowColor = Color3.fromRGB(255, 255, 100),
            rarity = 0.7 -- 70% chance to spawn
        },
        MEDIUM = {
            scale = 3,
            growthAmount = 0.1, -- raw scale increment
            color = Color3.fromRGB(0, 255, 0), -- Green
            glowColor = Color3.fromRGB(100, 255, 100),
            rarity = 0.25 -- 25% chance to spawn
        },
        LARGE = {
            scale = 4,
            growthAmount = 0.2, -- raw scale increment
            color = Color3.fromRGB(255, 0, 0), -- Red
            glowColor = Color3.fromRGB(255, 100, 100),
            rarity = 0.05 -- 5% chance to spawn
        }
    },

    -- Particle effect configuration for pickup
    PICKUP_PARTICLES = {
        color = Color3.fromRGB(255, 255, 255),
        size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 10),
            NumberSequenceKeypoint.new(1, 0)
        }),
        lifetime = NumberRange.new(0.5, 1),
        speed = NumberRange.new(5, 10),
        spread = NumberRange.new(0, 360),
        count = 30
    },

    -- Glow effect configuration
    GLOW_EFFECT = {
        brightness = 5,
        size = 5,
        transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(1, 1)
        })
    },

    -- Collection animation configuration
    COLLECTION_ANIMATION = {
        scale = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 2),
            NumberSequenceKeypoint.new(1, 0)
        }),
        duration = 0.3
    }
}

return OrbVisuals 