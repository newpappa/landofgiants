--[[
Name: NPCMovementController
Type: ModuleScript
Location: ServerScriptService.Server.NPC
Description: Handles all movement-specific decisions for NPCs, including wander positions, path finding, and movement timeouts
Interacts With:
  - NPCStateMachine: Receives state changes for movement updates
  - NPCMover: Sends movement instructions
  - ProximityManager: Gets target positions
  - NPCRegistry: Uses registry for NPC lookup
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

-- Dependencies
local Promise = require(ReplicatedStorage.Shared.Core.Promise)
local NPCRegistry = require(ReplicatedStorage.Shared.NPC.NPCRegistry)
local NPCMover = require(script.Parent.NPCMover)
local ProximityManager = require(ServerScriptService.Server.NPC.ProximityManager)

-- Constants
local MOVEMENT_TIMEOUT = 10 -- seconds before movement is considered failed
local MOVEMENT_RETRY_DELAY = 2 -- seconds to wait before retrying failed movement
local WANDER_DISTANCE = 50 -- how far to wander from current position
local WANDER_TIMEOUT = 5 -- seconds before picking new wander position

local NPCMovementController = {
    _initialized = false,
    _activeMovements = {}, -- {npcId = {target = target, startTime = time, retryCount = count}}
    _wanderTargets = {}, -- {npcId = {position = Vector3, startTime = time}}
    _updateFrequency = 0.1 -- how often to update movements (in seconds)
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

local function calculatePathToTarget(npc, target)
    -- TODO: Implement path finding logic
    -- For now, return direct path
    return target:GetPivot().Position
end

local function calculateEscapePath(npc, threat)
    local npcPos = npc:GetPivot().Position
    local threatPos = threat:GetPivot().Position
    local direction = (npcPos - threatPos).Unit
    return npcPos + (direction * 50) -- Move 50 studs away from threat
end

-- Public API

function NPCMovementController.Init()
    if NPCMovementController._initialized then
        return Promise.resolve()
    end

    return Promise.new(function(resolve, reject)
        local success, err = pcall(function()
            print("NPCMovementController: Initializing...")
            
            -- Initialize dependencies
            NPCMover.Init()
            
            -- Set up RunService connection for movement updates
            RunService.Heartbeat:Connect(function()
                local now = tick()
                if now - (NPCMovementController._lastUpdate or 0) >= NPCMovementController._updateFrequency then
                    NPCMovementController._lastUpdate = now
                    NPCMovementController.UpdateMovements()
                end
            end)
            
            NPCMovementController._initialized = true
        end)

        if success then
            print("NPCMovementController: Initialization complete")
            resolve()
        else
            warn("NPCMovementController: Failed to initialize -", err)
            reject(err)
        end
    end)
end

function NPCMovementController.HandleStateChange(npc, newState, target)
    if not NPCMovementController._initialized then
        warn("NPCMovementController: Attempted to handle state change before initialization")
        return
    end

    local npcId = npc:GetAttribute("NPCId")
    if not npcId then return end

    print("NPCMovementController: Handling state change for NPC", npcId, "State:", newState)

    -- Clear any existing movement data
    NPCMovementController._wanderTargets[npcId] = nil
    NPCMovementController._activeMovements[npcId] = nil

    local targetPosition
    local movementType = newState

    -- Calculate appropriate movement based on state
    if newState == "WANDERING" then
        targetPosition = getRandomWanderPosition(npc)
        NPCMovementController._wanderTargets[npcId] = {
            position = targetPosition,
            startTime = os.time()
        }
    elseif newState == "ORB_SEEKING" and target then
        targetPosition = calculatePathToTarget(npc, target)
    elseif newState == "PLAYER_HUNTING" and target then
        targetPosition = calculatePathToTarget(npc, target)
    elseif newState == "FLEEING" and target then
        targetPosition = calculateEscapePath(npc, target)
    end

    if targetPosition then
        NPCMovementController._activeMovements[npcId] = {
            target = target,
            targetPosition = targetPosition,
            startTime = os.time(),
            retryCount = 0
        }

        -- Send movement instructions to NPCMover
        NPCMover.HandleStateChange(npc, newState, target)
        
        -- Log movement start
        if target and target:GetAttribute("OrbId") then
            print(string.format("NPCMovementController: NPC_%s moving to Orb_%s at position (X:%.1f, Y:%.1f, Z:%.1f)",
                npcId,
                target:GetAttribute("OrbId"),
                targetPosition.X, targetPosition.Y, targetPosition.Z
            ))
        end
    end
end

function NPCMovementController.UpdateMovements()
    for npcId, movementData in pairs(NPCMovementController._activeMovements) do
        local npc = NPCRegistry.GetNPCById(npcId)
        if not npc then
            NPCMovementController._activeMovements[npcId] = nil
            NPCMovementController._wanderTargets[npcId] = nil
            continue
        end

        local currentPos = npc:GetPivot().Position
        local targetPos = movementData.targetPosition

        -- Handle wandering
        if movementData.target == nil then
            local wanderData = NPCMovementController._wanderTargets[npcId]
            if wanderData then
                -- Check if we've reached the wander target
                if (currentPos - wanderData.position).Magnitude < 5 then
                    print("NPCMovementController: NPC", npcId, "reached wander target, picking new position")
                    local newWanderPos = getRandomWanderPosition(npc)
                    NPCMovementController._wanderTargets[npcId].position = newWanderPos
                    NPCMovementController._wanderTargets[npcId].startTime = os.time()
                    NPCMovementController._activeMovements[npcId].targetPosition = newWanderPos
                end
                
                -- Check if we've been wandering too long
                if os.time() - wanderData.startTime > WANDER_TIMEOUT then
                    print("NPCMovementController: NPC", npcId, "wander timeout, picking new position")
                    local newWanderPos = getRandomWanderPosition(npc)
                    NPCMovementController._wanderTargets[npcId].position = newWanderPos
                    NPCMovementController._wanderTargets[npcId].startTime = os.time()
                    NPCMovementController._activeMovements[npcId].targetPosition = newWanderPos
                end
            end
        end

        -- Check for movement timeout
        if os.time() - movementData.startTime > MOVEMENT_TIMEOUT then
            if movementData.retryCount < 3 then
                print("NPCMovementController: NPC", npcId, "movement timeout, retrying")
                movementData.retryCount = movementData.retryCount + 1
                movementData.startTime = os.time()
                
                -- Recalculate path
                if movementData.target then
                    movementData.targetPosition = calculatePathToTarget(npc, movementData.target)
                end
            else
                print("NPCMovementController: NPC", npcId, "movement failed after retries")
                NPCMovementController._activeMovements[npcId] = nil
            end
        end
    end
end

function NPCMovementController.StopMovement(npc)
    if not npc then return end
    
    local npcId = npc:GetAttribute("NPCId")
    if not npcId then return end
    
    NPCMovementController._activeMovements[npcId] = nil
    NPCMovementController._wanderTargets[npcId] = nil
    
    NPCMover.StopMovement(npc)
    print("NPCMovementController: Stopped movement for NPC", npcId)
end

return NPCMovementController 