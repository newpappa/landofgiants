--[[
Name: SoundRegistry
Type: ModuleScript
Location: ReplicatedStorage
Description: Manages and plays sound effects for squash events and purchase success
Interacts With:
  - SquashEffectHandler: Provides sound playback for squash events
  - BuySuccessNotifications: Plays success sound for purchases
--]]

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

-- Success sound for purchases
SoundRegistry.SuccessSound = "rbxassetid://128868300852541"

print("SoundRegistry: Loaded", #SoundRegistry.SquashSounds, "squash sounds and success sound")

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
    
    -- Add additional debugging properties
    sound.Name = "SquashSound"
    sound.RollOffMode = Enum.RollOffMode.InverseTapered
    sound.RollOffMaxDistance = 100
    sound.RollOffMinDistance = 5
    sound.EmitterSize = 10
    
    sound.Parent = parent
    
    print("SoundRegistry: Created sound instance")
    print("SoundRegistry: Using sound ID", sound.SoundId, "(index", selectedSoundIndex, ")")
    print("SoundRegistry: Sound parent is", sound.Parent:GetFullName())
    
    -- Connect to all relevant events for debugging
    sound.Loaded:Connect(function()
        print("SoundRegistry: Sound loaded successfully")
        print("SoundRegistry: Sound length is", sound.TimeLength, "seconds")
        print("SoundRegistry: Playing sound...")
        sound:Play()
    end)
    
    sound.Played:Connect(function()
        print("SoundRegistry: Sound started playing")
    end)
    
    sound.Ended:Connect(function()
        print("SoundRegistry: Sound finished playing")
        sound:Destroy()
    end)
end

function SoundRegistry.playSuccessSound(parent)
    print("SoundRegistry.playSuccessSound called with parent:", parent:GetFullName())
    
    if not parent then 
        warn("SoundRegistry: No parent provided for success sound")
        return 
    end
    
    -- Create and configure the sound
    local sound = Instance.new("Sound")
    sound.SoundId = SoundRegistry.SuccessSound
    sound.Volume = 0.8  -- Slightly quieter than squash sounds
    sound.PlayOnRemove = false
    
    -- Add additional properties
    sound.Name = "SuccessSound"
    sound.RollOffMode = Enum.RollOffMode.InverseTapered
    sound.RollOffMaxDistance = 50  -- More localized than squash sounds
    sound.RollOffMinDistance = 5
    sound.EmitterSize = 5
    
    sound.Parent = parent
    
    print("SoundRegistry: Created success sound instance")
    print("SoundRegistry: Using success sound ID", sound.SoundId)
    
    -- Connect to all relevant events for debugging
    sound.Loaded:Connect(function()
        print("SoundRegistry: Success sound loaded successfully")
        print("SoundRegistry: Sound length is", sound.TimeLength, "seconds")
        print("SoundRegistry: Playing sound...")
        sound:Play()
    end)
    
    sound.Played:Connect(function()
        print("SoundRegistry: Success sound started playing")
    end)
    
    sound.Ended:Connect(function()
        print("SoundRegistry: Success sound finished playing")
        sound:Destroy()
    end)
end

print("SoundRegistry: Module initialized")

return SoundRegistry 