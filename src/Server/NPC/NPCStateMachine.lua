--[[
Name: NPCStateMachine
Type: ModuleScript
Location: ServerScriptService.Server.NPC
Description: Tracks and reports NPC states. Does not make decisions about state changes.
             Enforces cooldown between state changes to create lumbering, deliberate behavior.
Interacts With:
  - NPCAIController: Receives state change requests
  - AnimationController: Notifies of state changes for animation triggers
  - NPCRegistry: Updates NPC metadata with current state
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Dependencies
local Promise = require(ReplicatedStorage.Shared.Core.Promise)
local NPCRegistry = require(ReplicatedStorage.Shared.NPC.NPCRegistry)
local EventManager = require(ReplicatedStorage.Shared.Core.EventManager)
local NPCMover = require(script.Parent.NPCMover)
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
    _stateHistory = {}, -- {npcId = {state = state, timestamp = timestamp}}
    _lastStateChange = {}, -- {npcId = timestamp}
    _invalidStateWarnings = {}
}

function NPCStateMachine.Init()
    if NPCStateMachine._initialized then
        return Promise.resolve()
    end

    return Promise.new(function(resolve, reject)
        local success, err = pcall(function()
            print("NPCStateMachine: Initializing...")
            
            -- Initialize dependencies
            NPCMover.Init()
            AnimationController.Init()
            
            NPCStateMachine._initialized = true
        end)

        if success then
            print("NPCStateMachine initialized!")
            resolve()
        else
            warn("NPCStateMachine: Failed to initialize -", err)
            reject(err)
        end
    end)
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

    local currentState = NPCStateMachine.GetState(npcId)
    if currentState == newState then return end

    if not STATES[newState] then
        if not NPCStateMachine._invalidStateWarnings[newState] then
            warn("NPCStateMachine: Invalid state", newState)
            NPCStateMachine._invalidStateWarnings[newState] = true
        end
        return
    end

    -- Update state history
    NPCStateMachine._stateHistory[npcId] = {
        state = newState,
        timestamp = os.time()
    }
    
    -- Update last state change timestamp
    NPCStateMachine._lastStateChange[npcId] = os.time()
    
    -- Update state in registry
    NPCRegistry.UpdateNPCState(npcId, newState)
    
    -- Update movement and animation
    NPCMover.HandleStateChange(npc, newState, target)
    AnimationController.HandleNPCStateChange(npc, newState)
    
    -- Fire state change event with target
    if NPCStateChanged then
        NPCStateChanged:FireAllClients(npc, newState, target)
    else
        warn("NPCStateMachine: NPCStateChanged event not found")
    end
    
    print("NPCStateMachine: Changed state for NPC", npcId, "to", newState)
end

-- Gets current state of NPC
function NPCStateMachine.GetState(npcId)
    local history = NPCStateMachine._stateHistory[npcId]
    return history and history.state or nil
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