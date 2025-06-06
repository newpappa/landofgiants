--[[
Name: NPCSpawnManager
Type: ModuleScript
Location: ServerScriptService.Server.NPC
Description: Manages NPC population and respawning
Interacts With:
  - NPCFactory: Creates new NPCs
  - NPCAIController: Assigns AI to new NPCs
  - RandomNPCPositions: Uses position management system
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Load dependencies
local NPCFactory = require(ServerScriptService.Server.NPC.NPCFactory)
local RandomNPCPositions = require(ServerScriptService.Server.NPC.RandomNPCPositions)
local Promise = require(ReplicatedStorage.Shared.Core.Promise)

local NPCSpawnManager = {
    _initialized = false
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
        NPCSpawnManager._activeNPCs[npc] = {
            spawnTime = os.time(),
            lastPosition = spawnPosition
        }
        print("NPCSpawnManager: Spawned new NPC")
    end
    
    return npc
end

-- Function to remove an NPC
function NPCSpawnManager.RemoveNPC(npc)
    if not NPCSpawnManager._initialized then
        warn("NPCSpawnManager: Attempted to remove NPC before initialization")
        return
    end

    if not NPCSpawnManager._activeNPCs[npc] then
        warn("NPCSpawnManager: Attempted to remove non-existent NPC")
        return
    end

    -- Add to spawn cooldown
    NPCSpawnManager._spawnCooldowns[npc] = os.time()
    
    -- Remove from active NPCs
    NPCSpawnManager._activeNPCs[npc] = nil
    
    -- Remove the NPC
    NPCFactory.RemoveNPC(npc)
    print("NPCSpawnManager: Removed NPC")
end

-- Function to get current NPC count
function NPCSpawnManager.GetNPCCount()
    if not NPCSpawnManager._initialized then
        warn("NPCSpawnManager: Attempted to get NPC count before initialization")
        return 0
    end
    return #NPCSpawnManager._activeNPCs
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
        print("NPCSpawnManager: Spawning", toSpawn, "NPCs to maintain minimum population")
        
        for i = 1, toSpawn do
            NPCSpawnManager.SpawnNPC()
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
        return Promise.resolve()
    end

    return Promise.new(function(resolve, reject)
        local success, err = pcall(function()
            -- Initialize RandomNPCPositions first
            print("NPCSpawnManager: Initializing RandomNPCPositions...")
            RandomNPCPositions.Init():andThen(function()
                -- Initialize all state
                NPCSpawnManager._activeNPCs = {}
                NPCSpawnManager._spawnCooldowns = {}
                NPCSpawnManager._minNPCs = 10
                NPCSpawnManager._maxNPCs = 15
                NPCSpawnManager._spawnCooldown = 30 -- Seconds between respawns
                NPCSpawnManager._initialized = true
                
                -- Start population maintenance
                task.spawn(function()
                    while true do
                        NPCSpawnManager.UpdatePopulation()
                        task.wait(5) -- Check every 5 seconds
                    end
                end)
                
                print("NPCSpawnManager: Initialized successfully")
                resolve()
            end):catch(function(err)
                warn("NPCSpawnManager: RandomNPCPositions initialization failed:", err)
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