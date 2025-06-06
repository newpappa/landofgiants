--[[
Name: OrbPickupEffects
Type: LocalScript
Location: StarterPlayerScripts.Client.Orbs
Description: Handles visual and audio effects for orb pickups
Interacts With:
  - OrbVisuals: Uses visual configurations for effects
  - OrbPickupManager: Receives pickup events
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local EventManager = require(ReplicatedStorage.Shared.Core.EventManager)

local OrbVisuals = require(ReplicatedStorage.Shared.Orbs.OrbVisuals)

-- Get the OrbPickupEvent
local OrbPickupEvent = EventManager:GetEvent("OrbPickupEvent")

-- Function to create pickup effect
local function createPickupEffect(position, orbType)
    -- Create effect part
    local effect = Instance.new("Part")
    effect.Name = "OrbPickupEffect"
    effect.Anchored = true
    effect.CanCollide = false
    effect.Transparency = 1
    effect.Position = position
    effect.Parent = workspace
    
    -- Add particles
    local particles = Instance.new("ParticleEmitter")
    particles.Color = ColorSequence.new(OrbVisuals.ORB_TYPES[orbType].glowColor)
    particles.Size = OrbVisuals.PICKUP_PARTICLES.size
    particles.Lifetime = OrbVisuals.PICKUP_PARTICLES.lifetime
    particles.Speed = OrbVisuals.PICKUP_PARTICLES.speed
    particles.SpreadAngle = Vector2.new(0, 180)
    particles.Rate = 0 -- We'll emit in bursts
    particles.Parent = effect
    
    -- Create collection animation
    local tweenInfo = TweenInfo.new(
        OrbVisuals.COLLECTION_ANIMATION.duration,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(effect, tweenInfo, {
        Size = Vector3.new(2, 2, 2),
        Transparency = 1
    })
    
    -- Emit particles and play animation
    particles:Emit(OrbVisuals.PICKUP_PARTICLES.count)
    tween:Play()
    
    -- Clean up after animation
    tween.Completed:Connect(function()
        effect:Destroy()
    end)
end

-- Listen for pickup events
OrbPickupEvent.OnClientEvent:Connect(function(player, position, orbType)
    if player == game.Players.LocalPlayer then
        createPickupEffect(position, orbType)
    end
end) 