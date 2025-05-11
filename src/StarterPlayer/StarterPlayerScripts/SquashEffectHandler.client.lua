--[[
Name: SquashEffectHandler
Type: LocalScript
Location: StarterPlayer.StarterPlayerScripts
Description: Handles visual and audio effects when a player gets squashed
Interacts With:
  - SquashEffect: Uses effect configurations
  - SoundRegistry: Plays squash sound effects
  - SquashEvent: Listens for squash events from server
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

print("SquashEffectHandler: Starting up...")

local SquashEffect = require(ReplicatedStorage:WaitForChild("SquashEffect"))
local SoundRegistry = require(ReplicatedStorage:WaitForChild("SoundRegistry"))

-- Get the squash event
local SquashEvent = ReplicatedStorage:WaitForChild("SquashEvent")
print("SquashEffectHandler: Found SquashEvent")

-- Constants for sound distances
local PARTICIPANT_SOUND_DISTANCE = 10000 -- Much larger range for participants
local NEARBY_SOUND_DISTANCE = 100 -- Original range for spectators

-- Function to determine if player is a participant
local function isParticipant(localPlayer, squashedPlayer, squashingPlayer)
    return localPlayer == squashedPlayer or localPlayer == squashingPlayer
end

-- Temporarily disabled particle effect
--[[
local function createSquashParticles(character)
    print("Creating particles for character:", character.Name)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then 
        print("No RootPart found for particles")
        return 
    end
    
    -- Create particle emitter
    local emitter = Instance.new("ParticleEmitter")
    emitter.Color = ColorSequence.new(SquashEffect.PARTICLE_COLOR)
    emitter.Size = SquashEffect.PARTICLE_SIZE
    emitter.Lifetime = SquashEffect.PARTICLE_LIFETIME
    emitter.Speed = SquashEffect.PARTICLE_SPEED
    emitter.Spread = SquashEffect.PARTICLE_SPREAD
    emitter.Rate = 0 -- We'll emit all particles at once
    emitter.Parent = rootPart
    
    -- Emit particles
    emitter:Emit(SquashEffect.PARTICLE_COUNT)
    print("Particles emitted")
    
    -- Clean up emitter after particles are done
    task.delay(SquashEffect.PARTICLE_LIFETIME.Max, function()
        emitter:Destroy()
        print("Particle emitter cleaned up")
    end)
end
]]

-- Temporarily disabled custom animation
--[[
local function playSquashAnimation(character)
    print("Playing animation for character:", character.Name)
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then 
        print("No Humanoid found for animation")
        return 
    end
    
    -- Create and load the animation
    local animation = Instance.new("Animation")
    animation.AnimationId = SquashEffect.SQUASH_ANIMATION_ID
    
    -- Load and play the animation
    local animTrack = humanoid:LoadAnimation(animation)
    if not animTrack then
        print("Failed to load animation track")
        return
    end
    
    animTrack.Priority = Enum.AnimationPriority.Action
    
    -- Play the animation and handle errors
    local success, err = pcall(function()
        animTrack:Play()
        print("Animation started playing")
    end)
    
    if not success then
        warn("Failed to play animation:", err)
    end
end
]]

-- Handle squash event
print("Setting up SquashEvent handler...")
SquashEvent.OnClientEvent:Connect(function(squashedPlayer, squashingPlayer)
    print("SquashEvent received for player:", squashedPlayer.Name)
    
    local character = squashedPlayer.Character
    if not character then 
        print("No character found for squashed player")
        return 
    end
    
    -- Play sound effect with additional debugging
    task.spawn(function()
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            print("About to play squash sound...")
            print("RootPart position:", rootPart.Position)
            
            -- Add a visible indicator that we're trying to play sound
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.Parent = rootPart
            
            -- Play sound for all nearby players
            local localPlayer = Players.LocalPlayer
            if localPlayer and localPlayer.Character then
                local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if localRoot then
                    local distance = (localRoot.Position - rootPart.Position).Magnitude
                    local maxDistance = isParticipant(localPlayer, squashedPlayer, squashingPlayer) 
                        and PARTICIPANT_SOUND_DISTANCE 
                        or NEARBY_SOUND_DISTANCE
                    
                    if distance <= maxDistance then
                        print(string.format("Playing sound for %s (distance: %.1f, max allowed: %d)", 
                            isParticipant(localPlayer, squashedPlayer, squashingPlayer) and "participant" or "spectator",
                            distance,
                            maxDistance))
                        SoundRegistry.playSquashSound(localRoot)
                    else
                        print(string.format("Too far to hear sound (distance: %.1f, max allowed: %d)", 
                            distance,
                            maxDistance))
                    end
                end
            end
            
            -- Remove highlight after 1 second
            task.delay(1, function()
                highlight:Destroy()
            end)
        else
            print("No RootPart found for sound")
        end
    end)
end)

print("SquashEffectHandler: Initialization complete") 