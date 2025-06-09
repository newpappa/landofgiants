--[[
Name: NPCMover
Type: LocalScript
Location: StarterPlayer.StarterPlayerScripts.Client.NPC
Description: Handles NPC movement execution based on state changes
Interacts With:
  - NPCStateMachine: Receives state changes for movement updates
  - AnimationController: Coordinates with animations
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Dependencies
local EventManager = require(ReplicatedStorage.Shared.Core.EventManager)

-- Constants
local MOVEMENT_SPEEDS = {
    ORB_SEEKING = 16,
    PLAYER_HUNTING = 20,
    PLAYER_ATTACK = 24,
    FLEEING = 28
}

local NPCMover = {
    _activeMovements = {}, -- {npcId = {target = target, movementType = type, startTime = time}}
    _updateFrequency = 0.1 -- How often to update movements (in seconds)
}

-- Private helper functions
local function getMovementSpeed(movementType)
    return MOVEMENT_SPEEDS[movementType] or MOVEMENT_SPEEDS.ORB_SEEKING
end

local function moveTowardsTarget(npc, target, isFleeing)
    if not npc or not target then return end
    
    local humanoid = npc:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local targetPosition = target:GetPivot().Position
    local speed = getMovementSpeed(npc:GetAttribute("CurrentState"))
    
    if isFleeing then
        -- Move away from target
        local npcPosition = npc:GetPivot().Position
        local direction = (npcPosition - targetPosition).Unit
        targetPosition = npcPosition + (direction * 50) -- Move 50 studs away
    end
    
    humanoid:MoveTo(targetPosition)
    humanoid.WalkSpeed = speed
end

-- Public API

function NPCMover.HandleStateChange(npc, newState)
    if not npc then return end
    
    local npcId = npc:GetAttribute("NPCId")
    if not npcId then return end
    
    -- Get target from NPC attributes
    local targetId = npc:GetAttribute("CurrentTarget")
    local target = targetId and workspace:FindFirstChild(targetId)
    
    if target then
        NPCMover._activeMovements[npcId] = {
            target = target,
            movementType = newState,
            startTime = os.time()
        }
        print("NPCMover: Started movement for NPC", npcId, "to target", target.Name, "in state", newState)
    else
        NPCMover.StopMovement(npc)
    end
end

function NPCMover.StopMovement(npc)
    if not npc then return end
    
    local npcId = npc:GetAttribute("NPCId")
    if not npcId then return end
    
    NPCMover._activeMovements[npcId] = nil
    
    local humanoid = npc:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:MoveTo(npc:GetPivot().Position)
    end
    
    print("NPCMover: Stopped movement for NPC", npcId)
end

function NPCMover.UpdateMovements()
    for npcId, movementData in pairs(NPCMover._activeMovements) do
        local npc = workspace:FindFirstChild(npcId)
        if not npc then
            print("NPCMover: NPC", npcId, "not found, cleaning up movement")
            NPCMover._activeMovements[npcId] = nil
            continue
        end

        local target = movementData.target
        if not target or not target:IsDescendantOf(workspace) then
            print("NPCMover: Target for NPC", npcId, "not found, stopping movement")
            NPCMover.StopMovement(npc)
            continue
        end

        -- Execute movement
        local isFleeing = movementData.movementType == "FLEEING"
        moveTowardsTarget(npc, target, isFleeing)
    end
end

-- Set up state change listener
local NPCStateChanged = EventManager:GetEvent("NPCStateChanged")
NPCStateChanged.OnClientEvent:Connect(NPCMover.HandleStateChange)

-- Set up RunService connection for movement updates
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - (NPCMover._lastUpdate or 0) >= NPCMover._updateFrequency then
        NPCMover._lastUpdate = now
        NPCMover.UpdateMovements()
    end
end)

print("NPCMover: Script loaded") 