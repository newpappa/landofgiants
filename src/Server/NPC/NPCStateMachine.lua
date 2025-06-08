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
local NPCRegistry = require(ServerScriptService.Server.NPC.NPCRegistry)
local EventManager = require(ReplicatedStorage.Shared.Core.EventManager)

-- Constants
local STATE_COOLDOWN = 5 -- seconds between state changes
local STATES = {
    ORB_SEEKING = "OrbSeeking",
    PLAYER_HUNTING = "PlayerHunting",
    PLAYER_ATTACK = "PlayerAttack",
    FLEEING = "Fleeing"
}

local NPCStateMachine = {
    _initialized = false,
    _stateHistory = {}, -- {npcId = {state = state, timestamp = timestamp}}
    _lastStateChange = {} -- {npcId = timestamp}
}

-- Track invalid states we've already warned about
local _invalidStateWarnings = {}

function NPCStateMachine.Init()
    if NPCStateMachine._initialized then
        return Promise.resolve()
    end

    return Promise.new(function(resolve, reject)
        local success, err = pcall(function()
            print("NPCStateMachine: Initializing...")
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
function NPCStateMachine.ChangeState(npcId, newState)
    if not NPCStateMachine._canChangeState(npcId) then
        return false
    end

    if not STATES[newState] then
        -- Only warn about each invalid state once
        if not _invalidStateWarnings[newState] then
            print("NPCStateMachine: Invalid state", newState, "attempted")
            _invalidStateWarnings[newState] = true
        end
        return false
    end

    -- Get the NPC instance
    local npc = NPCRegistry.GetNPCById(npcId)
    if not npc then
        warn("NPCStateMachine: NPC not found for ID", npcId)
        return false
    end

    -- Update state history
    NPCStateMachine._stateHistory[npcId] = {
        state = newState,
        timestamp = os.time()
    }
    
    -- Update last state change timestamp
    NPCStateMachine._lastStateChange[npcId] = os.time()
    
    -- Update NPC metadata in registry
    NPCRegistry.UpdateNPCState(npcId, newState)
    
    -- Notify AnimationController of state change via EventManager
    local event = EventManager:GetEvent("NPCStateChanged")
    if event then
        event:FireAllClients(npc, newState)
    end
    
    print("NPCStateMachine: Changed state for NPC", npcId, "to", newState)
    return true
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