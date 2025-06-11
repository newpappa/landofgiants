--[[
Name: NPCMover
Type: ModuleScript
Location: ServerScriptService.NPC.Movement
Description: Handles NPC movement execution based on state changes
Interacts With:
  - NPCStateMachine: Receives state changes for movement updates
  - AnimationController: Coordinates with animations
  - NPCRegistry: Uses registry for NPC lookup
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Dependencies
local Promise = require(ReplicatedStorage.Shared.Core.Promise)
local NPCRegistry = require(ReplicatedStorage.Shared.NPC.NPCRegistry)

print("NPCMover: Starting up...")

-- Constants
local MOVEMENT_SPEEDS = {
    WANDERING = 8,      -- Slower speed while wandering
    ORB_SEEKING = 16,
    PLAYER_HUNTING = 20,
    PLAYER_ATTACK = 24,
    FLEEING = 28
}

local WANDER_DISTANCE = 50  -- How far to wander from current position
local WANDER_TIMEOUT = 5    -- How long to wander before picking new direction

local NPCMover = {
    _initialized = false,
    _activeMovements = {}, -- {npcId = {target = target, movementType = type, startTime = time}}
    _wanderTargets = {},   -- {npcId = {position = Vector3, startTime = time}}
    _updateFrequency = 0.1, -- How often to update movements (in seconds)
    _pendingStateChanges = {}, -- Store state changes that arrive before ready
    _isReady = false, -- Track if NPCMover is ready to handle state changes
    _lastUpdate = 0
}

-- Private helper functions
local function getRandomWanderPosition(npc)
    local currentPos = npc:GetPivot().Position
    local randomAngle = math.random() * math.pi * 2
    local randomDistance = math.random(WANDER_DISTANCE * 0.5, WANDER_DISTANCE)
    
    return currentPos + Vector3.new(
        math.cos(randomAngle) * randomDistance,
        0,
        math.sin(randomAngle) * randomDistance
    )
end

local function moveTowardsTarget(npc, target, isFleeing)
    if not npc then return end
    
    local humanoid = npc:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local targetPosition
    local speed
    
    if typeof(target) == "Vector3" then
        -- Wandering target
        targetPosition = target
        speed = MOVEMENT_SPEEDS.WANDERING
    else
        -- Normal target (orb or player)
        targetPosition = target:GetPivot().Position
        speed = MOVEMENT_SPEEDS[npc:GetAttribute("CurrentState")] or MOVEMENT_SPEEDS.WANDERING
        
        if isFleeing then
            -- Move away from target
            local npcPosition = npc:GetPivot().Position
            local direction = (npcPosition - targetPosition).Unit
            targetPosition = npcPosition + (direction * 50) -- Move 50 studs away
        end
    end
    
    humanoid:MoveTo(targetPosition)
    humanoid.WalkSpeed = speed
end

-- Public API

function NPCMover.HandleStateChange(npc, newState, target)
    if not npc then 
        print("NPCMover: Received state change with nil NPC")
        return 
    end
    
    local npcId = npc:GetAttribute("NPCId")
    if not npcId then 
        print("NPCMover: NPC has no NPCId attribute")
        return 
    end
    
    -- Verify NPC is in registry
    if not NPCRegistry.GetNPCById(npcId) then
        print("NPCMover: NPC", npcId, "not found in registry")
        return
    end
    
    print("NPCMover: Handling state change for NPC", npcId, "State:", newState, "Target:", target and target.Name or "none")
    
    -- Ensure we have a Humanoid
    local humanoid = npc:FindFirstChild("Humanoid")
    if not humanoid then
        print("NPCMover: Waiting for Humanoid on NPC", npcId)
        task.delay(1, function()
            if NPCRegistry.GetNPCById(npcId) and npc:FindFirstChild("Humanoid") then
                print("NPCMover: Humanoid found for NPC", npcId, "retrying state change")
                NPCMover.HandleStateChange(npc, newState, target)
            else
                print("NPCMover: Still no Humanoid for NPC", npcId, "after delay")
            end
        end)
        return
    end
    
    -- Clear any existing movement data
    NPCMover._wanderTargets[npcId] = nil
    
    if not target then
        -- Start wandering
        local wanderPos = getRandomWanderPosition(npc)
        NPCMover._wanderTargets[npcId] = {
            position = wanderPos,
            startTime = os.time()
        }
        NPCMover._activeMovements[npcId] = {
            target = wanderPos,
            movementType = "WANDERING",
            startTime = os.time()
        }
        print("NPCMover: NPC", npcId, "started wandering to", wanderPos)
        return
    end
    
    -- Store the actual target instance for orb seeking
    NPCMover._activeMovements[npcId] = {
        target = target,
        movementType = newState,
        startTime = os.time()
    }
    
    -- Enhanced logging for target receipt
    if target and target:GetAttribute("OrbId") then
        local targetPos = target:GetPivot().Position
        print(string.format("NPCMover: NPC_%s received target Orb_%s at position (X:%.1f, Y:%.1f, Z:%.1f)",
            npcId,
            target:GetAttribute("OrbId"),
            targetPos.X, targetPos.Y, targetPos.Z
        ))
    end
    
    print("NPCMover: Started movement for NPC", npcId, "to target", target.Name, "in state", newState)
end

function NPCMover.StopMovement(npc)
    if not npc then return end
    
    local npcId = npc:GetAttribute("NPCId")
    if not npcId then return end
    
    NPCMover._activeMovements[npcId] = nil
    NPCMover._wanderTargets[npcId] = nil
    
    local humanoid = npc:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:MoveTo(npc:GetPivot().Position)
    end
    
    print("NPCMover: Stopped movement for NPC", npcId)
end

function NPCMover.UpdateMovements()
    for npcId, movementData in pairs(NPCMover._activeMovements) do
        local npc = NPCRegistry.GetNPCById(npcId)
        if not npc then
            -- Don't immediately clean up, give NPC time to appear
            if not NPCMover._pendingCleanup then
                NPCMover._pendingCleanup = {}
            end
            NPCMover._pendingCleanup[npcId] = (NPCMover._pendingCleanup[npcId] or 0) + 1
            
            if NPCMover._pendingCleanup[npcId] > 20 then -- Wait about 2 seconds (20 * 0.1s)
                print("NPCMover: NPC", npcId, "not found in registry after delay, cleaning up movement")
                NPCMover._activeMovements[npcId] = nil
                NPCMover._wanderTargets[npcId] = nil
                NPCMover._pendingCleanup[npcId] = nil
            end
            continue
        end
        
        -- Reset pending cleanup if NPC is found
        if NPCMover._pendingCleanup then
            NPCMover._pendingCleanup[npcId] = nil
        end

        -- Ensure we have a Humanoid
        local humanoid = npc:FindFirstChild("Humanoid")
        if not humanoid then
            print("NPCMover: No Humanoid found for NPC", npcId, "in UpdateMovements")
            continue
        end

        -- Get current position
        local currentPos = npc:GetPivot().Position
        local targetPos

        -- Handle wandering
        if movementData.movementType == "WANDERING" then
            local wanderData = NPCMover._wanderTargets[npcId]
            if wanderData then
                targetPos = wanderData.position
                
                -- Check if we've reached the wander target
                if (currentPos - targetPos).Magnitude < 5 then
                    print("NPCMover: NPC", npcId, "reached wander target, picking new position")
                    local newWanderPos = getRandomWanderPosition(npc)
                    NPCMover._wanderTargets[npcId].position = newWanderPos
                    NPCMover._wanderTargets[npcId].startTime = os.time()
                    NPCMover._activeMovements[npcId].target = newWanderPos
                    print("NPCMover: NPC", npcId, "picked new wander position", newWanderPos)
                end
                
                -- Check if we've been wandering too long
                if os.time() - wanderData.startTime > WANDER_TIMEOUT then
                    print("NPCMover: NPC", npcId, "wander timeout, picking new position")
                    local newWanderPos = getRandomWanderPosition(npc)
                    NPCMover._wanderTargets[npcId].position = newWanderPos
                    NPCMover._wanderTargets[npcId].startTime = os.time()
                    NPCMover._activeMovements[npcId].target = newWanderPos
                    print("NPCMover: NPC", npcId, "picked new wander position", newWanderPos)
                end
            end
        else
            -- Normal target behavior
            if movementData.target then
                if typeof(movementData.target) == "Vector3" then
                    targetPos = movementData.target
                else
                    -- Get current position of target orb
                    targetPos = movementData.target:GetPivot().Position
                end
                
                -- Log movement progress
                local distance = (currentPos - targetPos).Magnitude
                if movementData.target:GetAttribute("OrbId") then
                    print(string.format("NPCMover: NPC_%s moving to Orb_%s, current position (X:%.1f, Y:%.1f, Z:%.1f), target position (X:%.1f, Y:%.1f, Z:%.1f), distance: %.1f studs",
                        npcId,
                        movementData.target:GetAttribute("OrbId"),
                        currentPos.X, currentPos.Y, currentPos.Z,
                        targetPos.X, targetPos.Y, targetPos.Z,
                        distance
                    ))
                end
                
                -- Check if we've reached the target
                if (currentPos - targetPos).Magnitude < 5 then
                    if movementData.target:GetAttribute("OrbId") then
                        print(string.format("NPCMover: NPC_%s reached Orb_%s - NPC position (X:%.1f, Y:%.1f, Z:%.1f), Orb position (X:%.1f, Y:%.1f, Z:%.1f), final distance: %.1f studs",
                            npcId,
                            movementData.target:GetAttribute("OrbId"),
                            currentPos.X, currentPos.Y, currentPos.Z,
                            targetPos.X, targetPos.Y, targetPos.Z,
                            distance
                        ))
                    end
                    -- Let the touch event handle the actual collection
                end
            end
        end
        
        -- Update movement if we have a target
        if targetPos then
            moveTowardsTarget(npc, targetPos, movementData.movementType == "FLEEING")
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
                if now - (NPCMover._lastUpdate or 0) >= NPCMover._updateFrequency then
                    NPCMover._lastUpdate = now
                    
                    -- Mark as ready after first heartbeat
                    if not NPCMover._isReady then
                        NPCMover._isReady = true
                        print("NPCMover: Now ready to handle state changes")
                        
                        -- Process any pending state changes
                        for npcId, changeData in pairs(NPCMover._pendingStateChanges) do
                            if NPCRegistry.GetNPCById(npcId) then
                                print("NPCMover: Processing stored state change for NPC", npcId)
                                NPCMover.HandleStateChange(changeData.npc, changeData.state, changeData.target)
                            end
                        end
                        NPCMover._pendingStateChanges = {}
                    end
                    
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