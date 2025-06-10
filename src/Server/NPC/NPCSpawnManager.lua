--[[
Name: NPCSpawnManager
Type: ModuleScript
Location: ServerScriptService.Server.NPC
Description: Manages NPC population and respawning
Interacts With:
  - NPCFactory: Creates new NPCs
  - NPCAIController: Assigns AI to new NPCs
  - NPCRegistry: Tracks active NPCs
  - RandomNPCPositions: Uses position management system
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Load dependencies
local NPCFactory = require(ServerScriptService.Server.NPC.NPCFactory)
local RandomNPCPositions = require(ServerScriptService.Server.NPC.RandomNPCPositions)
local NPCRegistry = require(ReplicatedStorage.Shared.NPC.NPCRegistry)
local NPCAIController = require(ServerScriptService.Server.NPC.NPCAIController)
local Promise = require(ReplicatedStorage.Shared.Core.Promise)

local NPCSpawnManager = {
    _initialized = false,
    _spawnCooldowns = {}, -- Track respawn cooldowns
    _minNPCs = 10,
    _maxNPCs = 15,
    _spawnCooldown = 30 -- Seconds between respawns
}

-- Function to get a random spawn position
function NPCSpawnManager.GetRandomSpawnPosition()
    if not NPCSpawnManager._initialized then
        warn("NPCSpawnManager: Attempted to get spawn position before initialization")
        return nil
    end

    local position = RandomNPCPositions:GetRandomPosition()
    if not position then
        warn("NPCSpawnManager: Failed to get random spawn position")
        return nil
    end

    return position
end

-- Function to spawn a new NPC
function NPCSpawnManager.SpawnNPC()
    if not NPCSpawnManager._initialized then
        warn("NPCSpawnManager: Attempted to spawn NPC before initialization")
        return nil
    end

    local spawnPosition = NPCSpawnManager.GetRandomSpawnPosition()
    local npc = NPCFactory.CreateNPC(spawnPosition)
    
    if npc then
        -- Set up death handling
        local humanoid = npc:WaitForChild("Humanoid")
        humanoid.Died:Connect(function()
            -- Wait for death animation/ragdoll
            task.delay(5, function()
                if npc and npc:IsDescendantOf(workspace) then
                    NPCSpawnManager.RemoveNPC(npc)
                end
            end)
        end)
        
        -- Register with NPCRegistry and NPCAIController
        NPCRegistry.RegisterNPC(npc)
        NPCAIController.RegisterNPC(npc)
        local npcId = npc:GetAttribute("NPCId")
        print("NPCSpawnManager: Spawned new NPC", npcId, "(Total NPCs:", NPCSpawnManager.GetNPCCount(), ")")
    end
    
    return npc
end

-- Function to remove an NPC
function NPCSpawnManager.RemoveNPC(npc)
    if not NPCSpawnManager._initialized then
        warn("NPCSpawnManager: Attempted to remove NPC before initialization")
        return
    end

    local npcId = npc:GetAttribute("NPCId")
    if not npcId then return end

    -- Add to spawn cooldown
    NPCSpawnManager._spawnCooldowns[npcId] = os.time()
    
    -- Unregister from NPCRegistry and NPCAIController
    NPCRegistry.UnregisterNPC(npc)
    NPCAIController.UnregisterNPC(npc)
    
    -- Remove the NPC
    NPCFactory.RemoveNPC(npc)
    print("NPCSpawnManager: Removed NPC", npcId, "(Total NPCs:", NPCSpawnManager.GetNPCCount(), ")")
end

-- Function to get current NPC count
function NPCSpawnManager.GetNPCCount()
    if not NPCSpawnManager._initialized then
        warn("NPCSpawnManager: Attempted to get NPC count before initialization")
        return 0
    end
    
    local count = 0
    for _ in pairs(NPCRegistry.GetAllNPCs()) do
        count = count + 1
    end
    return count
end

-- Function to check and maintain NPC population
function NPCSpawnManager.UpdatePopulation()
    if not NPCSpawnManager._initialized then
        warn("NPCSpawnManager: Attempted to update population before initialization")
        return
    end

    local currentCount = NPCSpawnManager.GetNPCCount()
    
    -- Check if we need to spawn more NPCs
    if currentCount < NPCSpawnManager._minNPCs then
        local toSpawn = NPCSpawnManager._minNPCs - currentCount
        print("NPCSpawnManager: Spawning", toSpawn, "NPCs to maintain minimum population (Current:", currentCount, ")")
        
        for i = 1, toSpawn do
            NPCSpawnManager.SpawnNPC()
        end
    end
    
    -- Check if we need to remove excess NPCs
    if currentCount > NPCSpawnManager._maxNPCs then
        local toRemove = currentCount - NPCSpawnManager._maxNPCs
        print("NPCSpawnManager: Removing", toRemove, "excess NPCs to maintain maximum population (Current:", currentCount, ")")
        
        -- Get all NPCs and sort by spawn time (oldest first)
        local allNPCs = NPCRegistry.GetAllNPCs()
        local npcsToRemove = {}
        for _, npc in pairs(allNPCs) do
            table.insert(npcsToRemove, {
                npc = npc,
                spawnTime = npc:GetAttribute("SpawnTime") or 0
            })
        end
        table.sort(npcsToRemove, function(a, b) return a.spawnTime < b.spawnTime end)
        
        -- Remove oldest NPCs first
        for i = 1, toRemove do
            if npcsToRemove[i] then
                NPCSpawnManager.RemoveNPC(npcsToRemove[i].npc)
            end
        end
    end
    
    -- Check spawn cooldowns
    local currentTime = os.time()
    for npc, cooldownTime in pairs(NPCSpawnManager._spawnCooldowns) do
        if currentTime - cooldownTime >= NPCSpawnManager._spawnCooldown then
            NPCSpawnManager._spawnCooldowns[npc] = nil
        end
    end
end

-- Initialize the NPCSpawnManager
function NPCSpawnManager.Init()
    if NPCSpawnManager._initialized then
        return Promise.new(function(resolve)
            resolve()
        end)
    end

    return Promise.new(function(resolve, reject)
        local success, err = pcall(function()
            -- Initialize RandomNPCPositions first
            print("NPCSpawnManager: Initializing RandomNPCPositions...")
            RandomNPCPositions.Init():andThen(function()
                -- Initialize NPCFactory
                print("NPCSpawnManager: Initializing NPCFactory...")
                return NPCFactory.Init()
            end):andThen(function()
                -- Initialize NPCRegistry
                print("NPCSpawnManager: Initializing NPCRegistry...")
                return NPCRegistry.Init()
            end):andThen(function()
                -- Initialize all state
                NPCSpawnManager._spawnCooldowns = {}
                NPCSpawnManager._initialized = true
                
                -- Start population maintenance after a short delay to ensure everything is ready
                task.delay(1, function()
                    while NPCSpawnManager._initialized do
                        NPCSpawnManager.UpdatePopulation()
                        task.wait(1)
                    end
                end)
                
                print("NPCSpawnManager: Initialized successfully")
                resolve()
            end):catch(function(err)
                warn("NPCSpawnManager: Initialization failed:", err)
                reject(err)
            end)
        end)

        if not success then
            warn("NPCSpawnManager: Failed to initialize:", err)
            reject(err)
        end
    end)
end

return NPCSpawnManager 