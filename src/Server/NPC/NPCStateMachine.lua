--[[
Name: NPCStateMachine
Type: ModuleScript
Location: ServerScriptService.Server.NPC
Description: Manages NPC state transitions and enforces state change rules.
             Coordinates state changes between AI, Movement, and Animation systems.
             Does not make decisions about state changes or handle movement.
Interacts With:
  - NPCAIController: Receives state change requests
  - NPCMovementController: Notifies of state changes for movement updates
  - AnimationController: Notifies of state changes for animation triggers
  - NPCRegistry: Updates NPC metadata with current state
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Dependencies
local Promise = require(ReplicatedStorage.Shared.Core.Promise)
local NPCRegistry = require(ReplicatedStorage.Shared.NPC.NPCRegistry)
local EventManager = require(ReplicatedStorage.Shared.Core.EventManager)
local NPCMovementController = require(script.Parent.NPCMovementController)
local AnimationController = require(script.Parent.AnimationController)

-- Get the state change event
local NPCStateChanged = EventManager:GetEvent("NPCStateChanged")

-- Constants
local STATE_COOLDOWN = 5 -- seconds between state changes
local STATES = {
    IDLE = "IDLE",
    WANDERING = "WANDERING",
    ORB_SEEKING = "ORB_SEEKING",
    PLAYER_HUNTING = "PLAYER_HUNTING",
    PLAYER_ATTACK = "PLAYER_ATTACK",
    FLEEING = "FLEEING"
}

local NPCStateMachine = {
    _initialized = false,
    _initPromise = nil,
    _stateHistory = {}, -- {npcId = {state = state, timestamp = timestamp, target = target}}
    _lastStateChange = {}, -- {npcId = timestamp}
    _invalidStateWarnings = {}
}

function NPCStateMachine.Init()
    if NPCStateMachine._initialized then
        return Promise.resolve()
    end
    
    if NPCStateMachine._initPromise then
        return NPCStateMachine._initPromise
    end

    NPCStateMachine._initPromise = Promise.new(function(resolve, reject)
        local success, err = pcall(function()
            print("NPCStateMachine: Initializing...")
            
            -- Initialize dependencies in sequence
            NPCMovementController.Init():andThen(function()
                return AnimationController.Init()
            end):andThen(function()
                NPCStateMachine._initialized = true
                print("NPCStateMachine: Initialization complete")
                resolve()
            end):catch(function(initErr)
                warn("NPCStateMachine: Failed to initialize dependencies -", initErr)
                reject(initErr)
            end)
        end)

        if not success then
            warn("NPCStateMachine: Failed to initialize -", err)
            reject(err)
        end
    end)
    
    return NPCStateMachine._initPromise
end

-- Returns true if NPC can change state (cooldown elapsed)
function NPCStateMachine._canChangeState(npcId)
    local lastChange = NPCStateMachine._lastStateChange[npcId]
    if not lastChange then return true end
    
    return (os.time() - lastChange) >= STATE_COOLDOWN
end

-- Changes NPC state if cooldown has elapsed
function NPCStateMachine.ChangeState(npcId, newState, target)
    if not NPCStateMachine._initialized then
        warn("NPCStateMachine: Attempted to change state before initialization")
        return
    end

    local npc = NPCRegistry.GetNPCById(npcId)
    if not npc then
        warn("NPCStateMachine: NPC", npcId, "not found")
        return
    end

    -- Validate state change
    local currentState = NPCStateMachine.GetState(npcId)
    if currentState == newState and target == NPCStateMachine.GetStateTarget(npcId) then return end

    if not STATES[newState] then
        if not NPCStateMachine._invalidStateWarnings[newState] then
            warn("NPCStateMachine: Invalid state", newState)
            NPCStateMachine._invalidStateWarnings[newState] = true
        end
        return
    end

    -- Check cooldown
    if not NPCStateMachine._canChangeState(npcId) then
        print(string.format("NPCStateMachine: State change for NPC %s blocked by cooldown. Time remaining: %.1f seconds",
            npcId,
            NPCStateMachine.GetTimeUntilNextChange(npcId)
        ))
        return
    end

    -- Update state history with target
    NPCStateMachine._stateHistory[npcId] = {
        state = newState,
        timestamp = os.time(),
        target = target
    }
    
    -- Update last state change timestamp
    NPCStateMachine._lastStateChange[npcId] = os.time()
    
    -- Update state in registry
    NPCRegistry.UpdateNPCState(npcId, newState)
    
    -- Notify dependent systems
    NPCMovementController.HandleStateChange(npc, newState, target)
    AnimationController.HandleNPCStateChange(npc, newState)
    
    -- Fire state change event
    if NPCStateChanged then
        NPCStateChanged:FireAllClients(npc, newState, target)
    else
        warn("NPCStateMachine: NPCStateChanged event not found")
    end
    
    print(string.format("NPCStateMachine: NPC_%s changed state from %s to %s with target %s",
        npcId,
        currentState or "NONE",
        newState,
        target and (target:GetAttribute("OrbId") or target.Name) or "none"
    ))
end

-- Gets current state and target of NPC
function NPCStateMachine.GetState(npcId)
    local history = NPCStateMachine._stateHistory[npcId]
    return history and history.state or nil
end

function NPCStateMachine.GetStateTarget(npcId)
    local history = NPCStateMachine._stateHistory[npcId]
    return history and history.target or nil
end

-- Gets time until next possible state change
function NPCStateMachine.GetTimeUntilNextChange(npcId)
    local lastChange = NPCStateMachine._lastStateChange[npcId]
    if not lastChange then return 0 end
    
    local elapsed = os.time() - lastChange
    return math.max(0, STATE_COOLDOWN - elapsed)
end

-- Cleans up state data for removed NPC
function NPCStateMachine.CleanupNPC(npcId)
    NPCStateMachine._stateHistory[npcId] = nil
    NPCStateMachine._lastStateChange[npcId] = nil
    print("NPCStateMachine: Cleaned up state data for NPC", npcId)
end

return NPCStateMachine 