--[[
Name: OrbPickupEffects
Type: LocalScript
Location: StarterPlayerScripts.Client.Orbs
Description: Handles visual and audio effects for orb pickups
Interacts With:
  - OrbVisuals: Uses visual configurations for effects
  - OrbPickupManager: Receives pickup events
  - EventManager: Gets orb pickup events
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

print("OrbPickupEffects: Starting up...")

local EventManager = require(ReplicatedStorage.Shared.Core.EventManager)
local OrbVisuals = require(ReplicatedStorage.Shared.Orbs.OrbVisuals)

print("OrbPickupEffects: OrbVisuals module loaded")
print("OrbPickupEffects: Available orb types:")
for orbType, _ in pairs(OrbVisuals.ORB_TYPES) do
    print("  - " .. orbType)
end
print("OrbPickupEffects: Pickup particles config:", OrbVisuals.PICKUP_PARTICLES)

-- Get the OrbPickupEvent from EventManager
local OrbPickupEvent = EventManager:GetEvent("OrbPickupEvent")
print("OrbPickupEffects: Found OrbPickupEvent:", OrbPickupEvent and "Yes" or "No")

-- Function to create pickup effect
local function createPickupEffect(position, orbType)
    print("OrbPickupEffects: Creating pickup effect for orb type:", orbType)
    print("OrbPickupEffects: Position:", position)
    print("OrbPickupEffects: Orb type data:", OrbVisuals.ORB_TYPES[orbType])
    
    -- Create effect part
    local effect = Instance.new("Part")
    effect.Name = "OrbPickupEffect"
    effect.Anchored = true
    effect.CanCollide = false
    effect.Transparency = 1
    effect.Position = position
    effect.Parent = workspace
    print("OrbPickupEffects: Created effect part")
    
    -- Add particles
    local particles = Instance.new("ParticleEmitter")
    particles.Color = ColorSequence.new(OrbVisuals.ORB_TYPES[orbType].glowColor)
    particles.Size = OrbVisuals.PICKUP_PARTICLES.size
    particles.Lifetime = OrbVisuals.PICKUP_PARTICLES.lifetime
    particles.Speed = OrbVisuals.PICKUP_PARTICLES.speed
    particles.SpreadAngle = Vector2.new(0, 180)
    particles.Rate = 0 -- We'll emit in bursts
    particles.Parent = effect
    print("OrbPickupEffects: Created particle emitter")
    
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
    print("OrbPickupEffects: Created tween")
    
    -- Emit particles and play animation
    particles:Emit(OrbVisuals.PICKUP_PARTICLES.count)
    print("OrbPickupEffects: Emitted particles")
    tween:Play()
    print("OrbPickupEffects: Started tween")
    
    -- Clean up after animation
    tween.Completed:Connect(function()
        print("OrbPickupEffects: Tween completed, cleaning up effect")
        effect:Destroy()
    end)
end

-- Listen for pickup events
print("OrbPickupEffects: Setting up event listener...")
if not OrbPickupEvent then
    warn("OrbPickupEffects: Failed to get OrbPickupEvent!")
    return
end

print("OrbPickupEffects: Connecting to OrbPickupEvent...")
OrbPickupEvent.OnClientEvent:Connect(function(player, position, orbType, feetGrowth)
    print("OrbPickupEffects: Received pickup event")
    print("OrbPickupEffects: Player:", player.Name)
    print("OrbPickupEffects: Position:", position)
    print("OrbPickupEffects: Orb type:", orbType)
    print("OrbPickupEffects: Feet growth:", feetGrowth)
    
    if player == game.Players.LocalPlayer then
        print("OrbPickupEffects: This is the local player, creating effect")
        createPickupEffect(position, orbType)
    else
        print("OrbPickupEffects: Not local player, ignoring")
    end
end)
print("OrbPickupEffects: Event listener set up")

print("OrbPickupEffects: Initialization complete") 