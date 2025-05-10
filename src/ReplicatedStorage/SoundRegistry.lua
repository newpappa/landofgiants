local SoundRegistry = {}

print("SoundRegistry: Module loading...")

-- Sound IDs collection
SoundRegistry.SquashSounds = {
    "rbxassetid://17620645740",
    "rbxassetid://6832470734",
    "rbxassetid://18900008907",
    "rbxassetid://17517499979",
    "rbxassetid://9084006093",
    "rbxassetid://6345884580",
    "rbxassetid://5525281334"
}

print("SoundRegistry: Loaded", #SoundRegistry.SquashSounds, "squash sounds")

function SoundRegistry.playSquashSound(parent)
    print("SoundRegistry.playSquashSound called with parent:", parent:GetFullName())
    
    if not parent then 
        warn("SoundRegistry: No parent provided for squash sound")
        return 
    end
    
    -- Create and configure the sound
    local sound = Instance.new("Sound")
    local selectedSoundIndex = math.random(#SoundRegistry.SquashSounds)
    sound.SoundId = SoundRegistry.SquashSounds[selectedSoundIndex]
    sound.Volume = 1
    sound.PlayOnRemove = false
    sound.Parent = parent
    
    print("SoundRegistry: Created sound instance")
    print("SoundRegistry: Using sound ID", sound.SoundId, "(index", selectedSoundIndex, ")")
    print("SoundRegistry: Sound parent is", sound.Parent:GetFullName())
    
    -- Connect to loading events
    sound.Loaded:Connect(function()
        print("SoundRegistry: Sound loaded successfully")
        sound:Play()
    end)
    
    -- Clean up after playing
    sound.Ended:Connect(function()
        print("SoundRegistry: Sound finished playing")
        sound:Destroy()
    end)
end

print("SoundRegistry: Module initialized")

return SoundRegistry 