local SoundRegistry = {
    -- Sound IDs (replace these with actual Roblox sound IDs)
    Sounds = {
        SQUASH_IMPACT = "rbxasset://sounds/uuhhh.mp3" -- Placeholder sound, replace with actual squash sound ID
    }
}

function SoundRegistry.playSound(soundId, parent)
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Parent = parent
    sound:Play()
    
    -- Clean up sound after playing
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
    
    return sound
end

return SoundRegistry 