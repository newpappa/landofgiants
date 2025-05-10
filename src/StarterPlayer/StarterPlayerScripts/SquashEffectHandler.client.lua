local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

print("SquashEffectHandler: Starting up...")

local SquashEffect = require(ReplicatedStorage:WaitForChild("SquashEffect"))
local SoundRegistry = require(ReplicatedStorage:WaitForChild("SoundRegistry"))

-- Get the squash event
local SquashEvent = ReplicatedStorage:WaitForChild("SquashEvent")
print("SquashEffectHandler: Found SquashEvent")

-- Function to create and play particle effect
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

-- Function to play squash animation
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

-- Handle squash event
print("Setting up SquashEvent handler...")
SquashEvent.OnClientEvent:Connect(function(squashedPlayer, biggerPlayer)
    print("SquashEvent received for player:", squashedPlayer.Name)
    
    local character = squashedPlayer.Character
    if not character then 
        print("No character found for squashed player")
        return 
    end
    
    -- Play visual effects
    task.spawn(function()
        playSquashAnimation(character)
        createSquashParticles(character)
    end)
    
    -- Play sound effect
    task.spawn(function()
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            print("Playing squash sound...")
            SoundRegistry.playSquashSound(rootPart)
        else
            print("No RootPart found for sound")
        end
    end)
end)

print("SquashEffectHandler: Initialization complete") 