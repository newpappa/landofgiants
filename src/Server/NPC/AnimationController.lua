--[[
Name: AnimationController
Type: ModuleScript
Location: ServerScriptService.NPC.Animation
Description: Manages animation playback for all NPCs
Interacts With:
  - AnimationRegistry: Gets animation data
  - NPCStateMachine: Receives state changes for NPCs
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Dependencies
local Promise = require(ReplicatedStorage.Shared.Core.Promise)
local AnimationRegistry = require(ReplicatedStorage.Shared.Core.AnimationRegistry)
local EventManager = require(ReplicatedStorage.Shared.Core.EventManager)

local AnimationController = {
    _initialized = false,
    _activeAnimations = {} -- Track active animations for each character
}

-- Map NPC states to animations
local NPC_STATE_ANIMATIONS = {
    ["WANDERING"] = "anim_walk",
    ["ORB_SEEKING"] = "anim_walk",
    ["PLAYER_HUNTING"] = "anim_run",
    ["PLAYER_ATTACK"] = "anim_run",
    ["FLEEING"] = "anim_run"
}

-- Function to play an animation on a character
function AnimationController.PlayAnimation(character, animationId, metadata)
    if not character or not animationId then 
        warn("[AnimationController] Invalid parameters for PlayAnimation:", character and character:GetAttribute("NPCId") or "nil", animationId)
        return 
    end
    
    print("[AnimationController] Attempting to play animation:", animationId, "on character:", character:GetAttribute("NPCId"))
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then 
        warn("[AnimationController] No Humanoid found on character:", character:GetAttribute("NPCId"))
        return 
    end
    
    print("[AnimationController] Found Humanoid for character:", character:GetAttribute("NPCId"))
    
    local animator = humanoid:FindFirstChild("Animator")
    if not animator then 
        print("[AnimationController] Creating new Animator for character:", character:GetAttribute("NPCId"))
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    
    print("[AnimationController] Using Animator for character:", character:GetAttribute("NPCId"))
    
    -- Get animation data
    local animData = AnimationRegistry.GetAnimationData(animationId)
    if not animData then 
        warn("[AnimationController] No animation data found for:", animationId)
        return 
    end
    
    print("[AnimationController] Creating animation instance for:", animationId)
    
    -- Create animation instance
    local animation = Instance.new("Animation")
    animation.AnimationId = animData.published
    
    print("[AnimationController] Loading animation track for:", animationId)
    
    -- Create or get existing animation track
    local track = animator:LoadAnimation(animation)
    
    print("[AnimationController] Animation track loaded for:", animationId)
    
    -- Apply metadata
    if metadata then
        print("[AnimationController] Applying metadata to track:", animationId)
        track.Priority = metadata.priority
        track.Looped = metadata.looped
    end
    
    -- Stop any existing animation for this character
    AnimationController.StopAnimation(character)
    
    print("[AnimationController] Playing animation track for:", animationId)
    
    -- Play the animation
    track:Play()
    
    -- Store the track
    AnimationController._activeAnimations[character] = track
    
    print("[AnimationController] Animation track stored for character:", character:GetAttribute("NPCId"))
    
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
    
    local animId = isRunning and "anim_run" or "anim_walk"
    local animData = AnimationRegistry.GetAnimationData(animId)
    if animData then
        return AnimationController.PlayAnimation(character, animId, animData.metadata)
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
    if not npc then 
        warn("[AnimationController] Received nil NPC in HandleNPCStateChange")
        return 
    end
    
    print("[AnimationController] Handling state change for NPC:", npc:GetAttribute("NPCId"), "New state:", newState)
    
    local animId = NPC_STATE_ANIMATIONS[newState]
    if not animId then
        warn("[AnimationController] No animation mapped for state:", newState)
        return
    end
    
    print("[AnimationController] Found animation ID:", animId, "for state:", newState)
    
    local animData = AnimationRegistry.GetAnimationData(animId)
    if not animData then
        warn("[AnimationController] No animation data found for ID:", animId)
        return
    end
    
    print("[AnimationController] Playing animation:", animId, "on NPC:", npc:GetAttribute("NPCId"))
    AnimationController.PlayAnimation(npc, animId, animData.metadata)
end

function AnimationController.Init()
    if AnimationController._initialized then
        return Promise.resolve()
    end

    return Promise.new(function(resolve, reject)
        local success, err = pcall(function()
            print("AnimationController: Initializing...")
            
            -- Set up NPC state change listener
            local NPCStateChanged = EventManager:GetEvent("NPCStateChanged")
            NPCStateChanged.OnServerEvent:Connect(AnimationController.HandleNPCStateChange)
            
            AnimationController._initialized = true
        end)

        if success then
            print("AnimationController: Initialization complete")
            resolve()
        else
            warn("AnimationController: Failed to initialize -", err)
            reject(err)
        end
    end)
end

return AnimationController 