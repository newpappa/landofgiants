--[[
Name: AnimationController
Type: LocalScript
Location: StarterPlayer.StarterPlayerScripts.Client.Animation
Description: Manages animation playback for all characters (players and NPCs)
Interacts With:
  - AnimationRegistry: Gets animation data
  - NPCStateMachine: Receives state changes for NPCs
  - PlayerStateMachine: Receives state changes for players
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Dependencies
local AnimationRegistry = require(ReplicatedStorage.Shared.Core.AnimationRegistry)
local Promise = require(ReplicatedStorage.Shared.Core.Promise)
local EventManager = require(ReplicatedStorage.Shared.Core.EventManager)

local AnimationController = {
    _activeAnimations = {} -- Track active animations for each character
}

-- Map NPC states to animations
local NPC_STATE_ANIMATIONS = {
    ["OrbSeeking"] = "anim_walk",
    ["PlayerHunting"] = "anim_run",
    ["PlayerAttack"] = "anim_run",
    ["Dead"] = "anim_standing"
}

-- Function to play an animation on a character
function AnimationController.PlayAnimation(character, animationId, metadata)
    if not character or not animationId then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local animator = humanoid:FindFirstChild("Animator")
    if not animator then return end
    
    -- Get animation data
    local animData = AnimationRegistry.GetAnimationData(animationId)
    if not animData then return end
    
    -- Create or get existing animation track
    local track = animator:LoadAnimation(Instance.new("Animation"))
    track.AnimationId = animData.published
    
    -- Apply metadata
    if metadata then
        track.Priority = metadata.priority
        track.Looped = metadata.looped
        track.FadeTime = metadata.fadeTime
    end
    
    -- Stop any existing animation for this character
    AnimationController.StopAnimation(character)
    
    -- Play the animation
    track:Play()
    
    -- Store the track
    AnimationController._activeAnimations[character] = track
    
    return track
end

-- Function to stop animation on a character
function AnimationController.StopAnimation(character)
    if not character then return end
    
    local track = AnimationController._activeAnimations[character]
    if track then
        track:Stop()
        AnimationController._activeAnimations[character] = nil
    end
end

-- Function to play movement animation
function AnimationController.PlayMovementAnimation(character, isRunning)
    if not character then return end
    
    local animId, metadata = AnimationRegistry.GetMovementAnimation(isRunning)
    if animId then
        return AnimationController.PlayAnimation(character, animId, metadata)
    end
end

-- Function to play standing animation
function AnimationController.PlayStandingAnimation(character)
    if not character then return end
    
    local animData = AnimationRegistry.GetAnimationData("anim_standing")
    if animData then
        return AnimationController.PlayAnimation(character, "anim_standing", animData.metadata)
    end
end

-- Function to handle NPC state changes
function AnimationController.HandleNPCStateChange(npc, newState)
    local animId, metadata = AnimationRegistry.GetAnimationForNPCState(newState)
    if not animId then
        return
    end
    
    AnimationController.PlayAnimation(npc, animId, metadata)
end

-- Set up NPC state change listener
local NPCStateChanged = EventManager:GetEvent("NPCStateChanged")
NPCStateChanged.OnClientEvent:Connect(AnimationController.HandleNPCStateChange)

print("AnimationController: Script loaded") 