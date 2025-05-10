local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SquashEffect = require(ReplicatedStorage:WaitForChild("SquashEffect"))
local SoundRegistry = require(ReplicatedStorage:WaitForChild("SoundRegistry"))

-- Get the squash event
local SquashEvent = ReplicatedStorage:WaitForChild("SquashEvent")

-- Function to create and play particle effect
local function createSquashParticles(character)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
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
    
    -- Clean up emitter after particles are done
    task.delay(SquashEffect.PARTICLE_LIFETIME.Max, function()
        emitter:Destroy()
    end)
end

-- Function to play squash animation
local function playSquashAnimation(character)
    if not character then return end
    
    -- Scale the character for squash effect
    character:ScaleTo(SquashEffect.SQUASH_SCALE, SquashEffect.ANIMATION_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
end

-- Handle squash event
SquashEvent.OnClientEvent:Connect(function(squashedPlayer, biggerPlayer)
    local character = squashedPlayer.Character
    if not character then return end
    
    -- Play visual effects
    playSquashAnimation(character)
    createSquashParticles(character)
    
    -- Play sound effect
    SoundRegistry.playSound(SoundRegistry.Sounds.SQUASH_IMPACT, character:FindFirstChild("HumanoidRootPart"))
end) 