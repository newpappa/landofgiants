--[[
Name: NPCMover
Type: ModuleScript
Location: ServerScriptService.NPC.Movement
Description: Pure movement executor for NPCs - handles only the actual movement execution
Interacts With:
  - NPCMovementController: Receives movement instructions
  - AnimationController: Coordinates with animations
  - NPCRegistry: Uses registry for NPC lookup
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Dependencies
local Promise = require(ReplicatedStorage.Shared.Core.Promise)
local NPCRegistry = require(ReplicatedStorage.Shared.NPC.NPCRegistry)

-- Constants
local MOVEMENT_SPEEDS = {
    WANDERING = 8,      -- Slower speed while wandering
    ORB_SEEKING = 16,
    PLAYER_HUNTING = 20,
    PLAYER_ATTACK = 24,
    FLEEING = 28
}

local NPCMover = {
    _initialized = false,
    _activeMovements = {}, -- {npcId = {targetPos = Vector3, speed = number, isFleeing = boolean}}
    _updateFrequency = 0.1, -- How often to update movements (in seconds)
    _lastUpdate = 0
}

-- Movement Status Events
local MovementStatus = {
    STARTED = "MovementStarted",
    COMPLETED = "MovementCompleted",
    FAILED = "MovementFailed",
    PROGRESS = "MovementProgress"
}

-- Private helper functions
local function reportMovementStatus(npc, status, details)
    local npcId = npc:GetAttribute("NPCId")
    if not npcId then return end
    
    local statusData = {
        npcId = npcId,
        status = status,
        timestamp = os.time(),
        details = details or {}
    }
    
    -- Log the status update
    print(string.format("NPCMover: NPC_%s movement %s - %s",
        npcId,
        status,
        details and details.message or ""
    ))
    
    -- Here we could fire a signal/event for other systems to listen to movement status
    -- This would be implemented by the system integrating this module
end

local function executeMovement(npc, targetPosition, speed, isFleeing)
    if not npc then return end
    
    local humanoid = npc:FindFirstChild("Humanoid")
    if not humanoid then
        reportMovementStatus(npc, MovementStatus.FAILED, {
            message = "No Humanoid found",
            targetPosition = targetPosition
        })
        return
    end
    
    local currentPos = npc:GetPivot().Position
    
    if isFleeing then
        -- Simply move away from target position
        local direction = (currentPos - targetPosition).Unit
        targetPosition = currentPos + (direction * 50)
    end
    
    -- Set movement speed
    humanoid.WalkSpeed = speed
    
    -- Execute the movement
    humanoid:MoveTo(targetPosition)
    
    -- Report movement started
    reportMovementStatus(npc, MovementStatus.STARTED, {
        message = string.format("Moving to position (%.1f, %.1f, %.1f)", targetPosition.X, targetPosition.Y, targetPosition.Z),
        targetPosition = targetPosition,
        speed = speed,
        isFleeing = isFleeing
    })
end

-- Public API

function NPCMover.MoveTo(npc, targetPosition, movementType)
    if not npc then 
        warn("NPCMover: Received MoveTo with nil NPC")
        return 
    end
    
    local npcId = npc:GetAttribute("NPCId")
    if not npcId then 
        warn("NPCMover: NPC has no NPCId attribute")
        return 
    end
    
    -- Verify NPC is in registry
    if not NPCRegistry.GetNPCById(npcId) then
        warn("NPCMover: NPC", npcId, "not found in registry")
        return
    end
    
    -- Store movement data
    NPCMover._activeMovements[npcId] = {
        targetPos = targetPosition,
        speed = MOVEMENT_SPEEDS[movementType] or MOVEMENT_SPEEDS.WANDERING,
        isFleeing = movementType == "FLEEING"
    }
    
    -- Execute the movement
    executeMovement(npc, targetPosition, NPCMover._activeMovements[npcId].speed, NPCMover._activeMovements[npcId].isFleeing)
end

function NPCMover.StopMovement(npc)
    if not npc then return end
    
    local npcId = npc:GetAttribute("NPCId")
    if not npcId then return end
    
    local humanoid = npc:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:MoveTo(npc:GetPivot().Position)
        humanoid.WalkSpeed = 0
    end
    
    NPCMover._activeMovements[npcId] = nil
    
    reportMovementStatus(npc, MovementStatus.COMPLETED, {
        message = "Movement stopped"
    })
end

function NPCMover.UpdateMovements()
    for npcId, movementData in pairs(NPCMover._activeMovements) do
        local npc = NPCRegistry.GetNPCById(npcId)
        if not npc then
            NPCMover._activeMovements[npcId] = nil
            continue
        end

        local humanoid = npc:FindFirstChild("Humanoid")
        if not humanoid then
            reportMovementStatus(npc, MovementStatus.FAILED, {
                message = "No Humanoid found during update"
            })
            NPCMover._activeMovements[npcId] = nil
            continue
        end

        -- Get current position and check progress
        local currentPos = npc:GetPivot().Position
        local targetPos = movementData.targetPos
        local distance = (currentPos - targetPos).Magnitude
        
        -- Report progress
        reportMovementStatus(npc, MovementStatus.PROGRESS, {
            message = string.format("Distance to target: %.1f studs", distance),
            currentPosition = currentPos,
            targetPosition = targetPos,
            distance = distance
        })
        
        -- Check if we've reached the target (within 1 stud horizontally)
        local horizontalDistance = Vector3.new(currentPos.X - targetPos.X, 0, currentPos.Z - targetPos.Z).Magnitude
        if horizontalDistance < 1 then
            reportMovementStatus(npc, MovementStatus.COMPLETED, {
                message = string.format("Reached target position (%.1f, %.1f, %.1f)", targetPos.X, targetPos.Y, targetPos.Z),
                finalPosition = currentPos,
                targetPosition = targetPos,
                finalDistance = horizontalDistance
            })
            NPCMover._activeMovements[npcId] = nil
        end
    end
end

function NPCMover.Init()
    if NPCMover._initialized then
        return Promise.resolve()
    end

    return Promise.new(function(resolve, reject)
        local success, err = pcall(function()
            print("NPCMover: Initializing...")
            
            -- Set up RunService connection for movement updates
            RunService.Heartbeat:Connect(function()
                local now = tick()
                if now - NPCMover._lastUpdate >= NPCMover._updateFrequency then
                    NPCMover._lastUpdate = now
                    NPCMover.UpdateMovements()
                end
            end)
            
            NPCMover._initialized = true
        end)

        if success then
            print("NPCMover: Initialization complete")
            resolve()
        else
            warn("NPCMover: Failed to initialize -", err)
            reject(err)
        end
    end)
end

return NPCMover