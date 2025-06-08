--[[
Name: NPCRegistry
Type: ModuleScript
Location: ServerScriptService.Server.NPC
Description: Central registry for all active NPCs, providing efficient lookup and management
Interacts With:
  - NPCFactory: Registers new NPCs
  - NPCAIController: Provides NPC lookup and filtering
  - ProximityManager: Provides NPC data for proximity checks
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Dependencies
local Promise = require(ReplicatedStorage.Shared.Core.Promise)

print("[NPCRegistry] Module script loaded")

-- Create the module
local NPCRegistry = {
    _initialized = false,
    _initPromise = nil,
    _npcs = {}, -- Main registry table
    _npcsBySize = {}, -- Indexed by size for quick lookups
    _npcsByState = {}, -- Indexed by state for quick lookups
    OnNPCRegistered = nil, -- Callback for NPC registration
    OnNPCUnregistered = nil, -- Callback for NPC unregistration
}

-- Private helper functions
local function getTableKeys(t)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end

-- Public API

-- Register a new NPC
function NPCRegistry.RegisterNPC(npc)
    if not npc then return end
    
    local id = npc:GetAttribute("NPCId")
    if not id then
        warn("[NPCRegistry] Attempted to register NPC without ID")
        return
    end
    
    -- Store in main registry
    NPCRegistry._npcs[id] = npc
    
    -- Index by size
    local size = npc:GetAttribute("Size") or 1
    if not NPCRegistry._npcsBySize[size] then
        NPCRegistry._npcsBySize[size] = {}
    end
    table.insert(NPCRegistry._npcsBySize[size], npc)
    
    -- Index by state
    local state = npc:GetAttribute("State") or "Idle"
    if not NPCRegistry._npcsByState[state] then
        NPCRegistry._npcsByState[state] = {}
    end
    table.insert(NPCRegistry._npcsByState[state], npc)
    
    -- Set up cleanup on removal
    npc.AncestryChanged:Connect(function(_, parent)
        if not parent then
            NPCRegistry.UnregisterNPC(npc)
        end
    end)

    -- Notify listeners
    if NPCRegistry.OnNPCRegistered then
        NPCRegistry.OnNPCRegistered(npc)
    end
end

-- Unregister an NPC
function NPCRegistry.UnregisterNPC(npc)
    if not npc then return end
    
    local id = npc:GetAttribute("NPCId")
    if not id then return end
    
    -- Remove from main registry
    NPCRegistry._npcs[id] = nil
    
    -- Remove from size index
    local size = npc:GetAttribute("Size") or 1
    if NPCRegistry._npcsBySize[size] then
        for i, storedNPC in ipairs(NPCRegistry._npcsBySize[size]) do
            if storedNPC == npc then
                table.remove(NPCRegistry._npcsBySize[size], i)
                break
            end
        end
    end
    
    -- Remove from state index
    local state = npc:GetAttribute("State") or "Idle"
    if NPCRegistry._npcsByState[state] then
        for i, storedNPC in ipairs(NPCRegistry._npcsByState[state]) do
            if storedNPC == npc then
                table.remove(NPCRegistry._npcsByState[state], i)
                break
            end
        end
    end

    -- Notify listeners
    if NPCRegistry.OnNPCUnregistered then
        NPCRegistry.OnNPCUnregistered(npc)
    end
end

-- Get NPC by ID
function NPCRegistry.GetNPCById(id)
    return NPCRegistry._npcs[id]
end

-- Get NPCs by size
function NPCRegistry.GetNPCsBySize(size)
    return NPCRegistry._npcsBySize[size] or {}
end

-- Get NPCs by state
function NPCRegistry.GetNPCsByState(state)
    return NPCRegistry._npcsByState[state] or {}
end

-- Get all NPCs
function NPCRegistry.GetAllNPCs()
    return NPCRegistry._npcs
end

-- Get NPCs in radius
function NPCRegistry.GetNPCsInRadius(position, radius)
    local npcsInRadius = {}
    for _, npc in pairs(NPCRegistry._npcs) do
        local npcPosition = npc:GetPivot().Position
        if (npcPosition - position).Magnitude <= radius then
            table.insert(npcsInRadius, npc)
        end
    end
    return npcsInRadius
end

-- Update NPC state
function NPCRegistry.UpdateNPCState(npcId, newState)
    local npc = NPCRegistry.GetNPCById(npcId)
    if not npc or not newState then 
        warn("[NPCRegistry] Failed to update state - Invalid NPC ID or state:", npcId, newState)
        return 
    end
    
    local oldState = npc:GetAttribute("State") or "Idle"
    
    -- Remove from old state index
    if NPCRegistry._npcsByState[oldState] then
        for i, storedNPC in ipairs(NPCRegistry._npcsByState[oldState]) do
            if storedNPC == npc then
                table.remove(NPCRegistry._npcsByState[oldState], i)
                break
            end
        end
    end
    
    -- Add to new state index
    if not NPCRegistry._npcsByState[newState] then
        NPCRegistry._npcsByState[newState] = {}
    end
    table.insert(NPCRegistry._npcsByState[newState], npc)
    
    -- Update attribute
    npc:SetAttribute("State", newState)
    print("[NPCRegistry] Updated state for NPC", npcId, "from", oldState, "to", newState)
end

-- Update NPC size
function NPCRegistry.UpdateNPCSize(npc, newSize)
    if not npc or not newSize then return end
    
    local oldSize = npc:GetAttribute("Size") or 1
    
    -- Remove from old size index
    if NPCRegistry._npcsBySize[oldSize] then
        for i, storedNPC in ipairs(NPCRegistry._npcsBySize[oldSize]) do
            if storedNPC == npc then
                table.remove(NPCRegistry._npcsBySize[oldSize], i)
                break
            end
        end
    end
    
    -- Add to new size index
    if not NPCRegistry._npcsBySize[newSize] then
        NPCRegistry._npcsBySize[newSize] = {}
    end
    table.insert(NPCRegistry._npcsBySize[newSize], npc)
    
    -- Update attribute
    npc:SetAttribute("Size", newSize)
end

-- Initialize the module
function NPCRegistry.Init()
    print("[NPCRegistry] Init() called")
    
    if NPCRegistry._initialized then
        print("[NPCRegistry] Already initialized, skipping")
        return Promise.new(function(resolve)
            resolve()
        end)
    end

    if NPCRegistry._initPromise then
        print("[NPCRegistry] Initialization already in progress")
        return NPCRegistry._initPromise
    end

    NPCRegistry._initPromise = Promise.new(function(resolve, reject)
        local success, err = pcall(function()
            print("[NPCRegistry] Starting initialization...")
            
            -- Initialize registry tables
            NPCRegistry._npcs = {}
            NPCRegistry._npcsBySize = {}
            NPCRegistry._npcsByState = {}
            
            -- Set up event handlers
            NPCRegistry.OnNPCRegistered = function(npc)
                print("[NPCRegistry] NPC registered:", npc:GetAttribute("NPCId"))
            end
            
            NPCRegistry.OnNPCUnregistered = function(npc)
                print("[NPCRegistry] NPC unregistered:", npc:GetAttribute("NPCId"))
            end
            
            NPCRegistry._initialized = true
            print("[NPCRegistry] ✓ Initialization complete")
        end)

        if success then
            resolve()
        else
            warn("[NPCRegistry] ❌ Initialization failed:", err)
            reject(err)
        end
    end)

    return NPCRegistry._initPromise
end

print("[NPCRegistry] Module script complete")

return NPCRegistry 