--[[
Name: ProximityManager
Type: ModuleScript
Location: ServerScriptService.Server.NPC
Description: Manages proximity detection between NPCs, players, and orbs.
             Provides spatial awareness for AI decision making and state transitions.
             Optimizes performance through spatial partitioning and update batching.

Key Responsibilities:
    - Spatial partitioning for efficient proximity checks
    - Proximity event broadcasting
    - Threat level calculation
    - Performance optimization through update batching

Dependencies:
    - NPCRegistry: Required for NPC tracking and metadata
    - Players Service: Required for player tracking
    - OrbManager: Required for active orb tracking
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Dependencies
local NPCRegistry = require(ReplicatedStorage.Shared.NPC.NPCRegistry)
local Promise = require(ReplicatedStorage.Shared.Core.Promise)

print("[ProximityManager] Module script loaded")

-- Create the module
local ProximityManager = {
    _initialized = false,
    _initPromise = nil,
    _npcs = {}, -- Active NPCs being tracked
    _players = {}, -- Active players being tracked
    _orbs = {}, -- Active orbs being tracked
    _spatialGrid = {}, -- Spatial partitioning grid
    _updateFrequency = 1.0, -- How often to update proximity checks (in seconds)
    _lastUpdate = 0,
}

-- Configuration
local CONFIG = {
    GRID_CELL_SIZE = 20, -- Size of each grid cell
    UPDATE_FREQUENCY = 1.0, -- How often to update proximity checks
    MAX_UPDATE_DISTANCE = 100, -- Maximum distance to check for proximity
    DEBUG_LOGGING = false -- Control debug logging
}

-- Private helper functions
local function getGridCell(position)
    local cellX = math.floor(position.X / CONFIG.GRID_CELL_SIZE)
    local cellZ = math.floor(position.Z / CONFIG.GRID_CELL_SIZE)
    return cellX, cellZ
end

local function getGridKey(cellX, cellZ)
    return string.format("%d,%d", cellX, cellZ)
end

local function debugLog(...)
    if CONFIG.DEBUG_LOGGING then
        print("[ProximityManager]", ...)
    end
end

local function updateSpatialGrid()
    debugLog("Updating spatial grid...")
    -- Clear existing grid
    ProximityManager._spatialGrid = {}
    
    -- Add NPCs to grid
    for npc, _ in pairs(ProximityManager._npcs) do
        if npc and npc:IsDescendantOf(workspace) then
            local position = npc:GetPivot().Position
            local cellX, cellZ = getGridCell(position)
            local key = getGridKey(cellX, cellZ)
            
            if not ProximityManager._spatialGrid[key] then
                ProximityManager._spatialGrid[key] = {
                    npcs = {},
                    players = {},
                    orbs = {}
                }
            end
            
            table.insert(ProximityManager._spatialGrid[key].npcs, npc)
        end
    end
    
    -- Add players to grid
    for player, _ in pairs(ProximityManager._players) do
        local character = player.Character
        if character and character:IsDescendantOf(workspace) then
            local position = character:GetPivot().Position
            local cellX, cellZ = getGridCell(position)
            local key = getGridKey(cellX, cellZ)
            
            if not ProximityManager._spatialGrid[key] then
                ProximityManager._spatialGrid[key] = {
                    npcs = {},
                    players = {},
                    orbs = {}
                }
            end
            
            table.insert(ProximityManager._spatialGrid[key].players, player)
        end
    end
    
    -- Add orbs to grid
    for orb, _ in pairs(ProximityManager._orbs) do
        if orb and orb:IsDescendantOf(workspace) then
            local position = orb.Position
            local cellX, cellZ = getGridCell(position)
            local key = getGridKey(cellX, cellZ)
            
            if not ProximityManager._spatialGrid[key] then
                ProximityManager._spatialGrid[key] = {
                    npcs = {},
                    players = {},
                    orbs = {}
                }
            end
            
            table.insert(ProximityManager._spatialGrid[key].orbs, orb)
        end
    end
    
    -- Count active entities
    local npcCount = 0
    local playerCount = 0
    local orbCount = 0
    
    for _ in pairs(ProximityManager._npcs) do
        npcCount = npcCount + 1
    end
    
    for _ in pairs(ProximityManager._players) do
        playerCount = playerCount + 1
    end
    
    for _ in pairs(ProximityManager._orbs) do
        orbCount = orbCount + 1
    end
    
    debugLog("Spatial grid updated with:")
    debugLog("  - NPCs:", npcCount)
    debugLog("  - Players:", playerCount)
    debugLog("  - Orbs:", orbCount)
end

-- Public API

-- Track a new orb
function ProximityManager.TrackOrb(orb)
    if orb and orb:IsDescendantOf(workspace) then
        print("[ProximityManager] Tracking new orb:", orb.Name)
        ProximityManager._orbs[orb] = true
        updateSpatialGrid()
    end
end

-- Untrack an orb
function ProximityManager.UntrackOrb(orb)
    if ProximityManager._orbs[orb] then
        print("[ProximityManager] Untracking orb:", orb.Name)
        ProximityManager._orbs[orb] = nil
        updateSpatialGrid()
    end
end

-- Register an NPC for proximity tracking
function ProximityManager.RegisterNPC(npc)
    if not npc then return end
    print("[ProximityManager] Registering NPC:", npc.Name)
    ProximityManager._npcs[npc] = true
    updateSpatialGrid()
end

-- Unregister an NPC from proximity tracking
function ProximityManager.UnregisterNPC(npc)
    if not npc then return end
    print("[ProximityManager] Unregistering NPC:", npc.Name)
    ProximityManager._npcs[npc] = nil
    updateSpatialGrid()
end

-- Get NPCs near a position
function ProximityManager.GetNPCsNearPosition(position, radius)
    local nearbyNPCs = {}
    local cellX, cellZ = getGridCell(position)
    
    -- Check current cell and adjacent cells
    for x = cellX - 1, cellX + 1 do
        for z = cellZ - 1, cellZ + 1 do
            local key = getGridKey(x, z)
            local cell = ProximityManager._spatialGrid[key]
            
            if cell and cell.npcs then
                for _, npc in ipairs(cell.npcs) do
                    if npc and npc:IsDescendantOf(workspace) then
                        local npcPosition = npc:GetPivot().Position
                        local distance = (npcPosition - position).Magnitude
                        if distance <= radius then
                            print("[ProximityManager] Found NPC", npc.Name, "at distance", distance)
                            table.insert(nearbyNPCs, npc)
                        end
                    end
                end
            end
        end
    end
    
    return nearbyNPCs
end

-- Get players near a position
function ProximityManager.GetPlayersNearPosition(position, radius)
    local nearbyPlayers = {}
    local cellX, cellZ = getGridCell(position)
    
    -- Check current cell and adjacent cells
    for x = cellX - 1, cellX + 1 do
        for z = cellZ - 1, cellZ + 1 do
            local key = getGridKey(x, z)
            local cell = ProximityManager._spatialGrid[key]
            
            if cell and cell.players then
                for _, player in ipairs(cell.players) do
                    local character = player.Character
                    if character and character:IsDescendantOf(workspace) then
                        local playerPosition = character:GetPivot().Position
                        local distance = (playerPosition - position).Magnitude
                        if distance <= radius then
                            print("[ProximityManager] Found player", player.Name, "at distance", distance)
                            table.insert(nearbyPlayers, player)
                        end
                    end
                end
            end
        end
    end
    
    return nearbyPlayers
end

-- Get orbs near a position
function ProximityManager.GetOrbsNearPosition(position, radius)
    local nearbyOrbs = {}
    local cellX, cellZ = getGridCell(position)
    
    -- Check current cell and adjacent cells
    for x = cellX - 1, cellX + 1 do
        for z = cellZ - 1, cellZ + 1 do
            local key = getGridKey(x, z)
            local cell = ProximityManager._spatialGrid[key]
            
            if cell and cell.orbs then
                for _, orb in ipairs(cell.orbs) do
                    if orb and orb:IsDescendantOf(workspace) then
                        local distance = (orb.Position - position).Magnitude
                        if distance <= radius then
                            print("[ProximityManager] Found orb", orb.Name, "at distance", distance)
                            table.insert(nearbyOrbs, orb)
                        end
                    end
                end
            end
        end
    end
    
    return nearbyOrbs
end

-- Initialize the module
function ProximityManager.Init()
    if ProximityManager._initialized then
        debugLog("Already initialized, skipping")
        return Promise.resolve()
    end

    if ProximityManager._initPromise then
        debugLog("Initialization already in progress")
        return ProximityManager._initPromise
    end

    ProximityManager._initPromise = Promise.new(function(resolve, reject)
        debugLog("Starting initialization...")
        
        -- Initialize NPCRegistry first
        debugLog("Initializing NPCRegistry...")
        NPCRegistry.Init():andThen(function()
            -- Set up RunService connection for updates
            RunService.Heartbeat:Connect(function()
                local now = tick()
                if now - ProximityManager._lastUpdate >= CONFIG.UPDATE_FREQUENCY then
                    updateSpatialGrid()
                    ProximityManager._lastUpdate = now
                end
            end)
            
            ProximityManager._initialized = true
            debugLog("✓ Initialization complete")
            resolve()
        end):catch(function(err)
            warn("[ProximityManager] ❌ Initialization failed:", err)
            reject(err)
        end)
    end)

    return ProximityManager._initPromise
end

print("[ProximityManager] Module script complete")

return ProximityManager 