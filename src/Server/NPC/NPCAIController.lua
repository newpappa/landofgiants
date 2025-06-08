--[[
Name: NPCAIController
Type: ModuleScript
Location: ServerScriptService.Server.NPC
Description: Controls NPC behavior and decision making
Interacts With:
  - NPCRegistry: Gets NPC data
  - NPCStateMachine: Sends state change requests
  - PlayerProximityManager: Gets proximity data
  - OrbSpawner: Finds nearby orbs
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

-- Dependencies
local Promise = require(ReplicatedStorage.Shared.Core.Promise)
local NPCRegistry = require(ServerScriptService.Server.NPC.NPCRegistry)
local NPCStateMachine = require(ServerScriptService.Server.NPC.NPCStateMachine)
local ProximityManager = require(ServerScriptService.Server.NPC.ProximityManager)

-- Constants
local HUNT_TIMEOUT = 10 -- seconds to continue hunting before considering orbs
local MOVEMENT_SPEEDS = {
    ORB_SEEKING = 16,
    PLAYER_HUNTING = 20,
    PLAYER_ATTACK = 24,
    FLEEING = 28
}

-- Distance thresholds
local DISTANCES = {
    HUNT_START = 30,    -- Start hunting when player is this close
    ATTACK_RANGE = 10,  -- Start attack when this close
    FLEE_START = 20,    -- Start fleeing when player is this close
    SAFE_DISTANCE = 40  -- Consider safe when this far from player
}

local NPCAIController = {
    _initialized = false,
    _activeNPCs = {}, -- {npcId = {target = target, huntStartTime = time, lastAttackTime = time}}
    _updateFrequency = 1.0 -- How often to update AI decisions
}

-- Private helper functions
local function getNearestOrb(npc)
    local npcPosition = npc:GetPivot().Position
    local nearestOrb = nil
    local nearestDistance = math.huge
    
    -- Get nearby orbs using ProximityManager
    local nearbyOrbs = ProximityManager.GetOrbsNearPosition(npcPosition, 100) -- Search within 100 studs
    
    -- Find the nearest orb
    for _, orb in ipairs(nearbyOrbs) do
        if orb and orb:IsDescendantOf(workspace) then
            local distance = (orb.Position - npcPosition).Magnitude
            if distance < nearestDistance then
                nearestOrb = orb
                nearestDistance = distance
            end
        end
    end
    
    return nearestOrb, nearestDistance
end

local function getNearestPlayer(npc)
    local npcPosition = npc:GetPivot().Position
    local npcSize = npc:GetAttribute("Size") or 1
    local nearestPlayer = nil
    local nearestDistance = math.huge
    
    for _, player in ipairs(game.Players:GetPlayers()) do
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local playerPosition = character:GetPivot().Position
            local distance = (playerPosition - npcPosition).Magnitude
            
            if distance < nearestDistance then
                nearestPlayer = character
                nearestDistance = distance
            end
        end
    end
    
    return nearestPlayer, nearestDistance
end

local function shouldFleeFromPlayer(npc, player)
    local npcSize = npc:GetAttribute("Size") or 1
    local playerSize = player:GetAttribute("Size") or 1
    return playerSize > npcSize -- Flee if player is larger
end

local function moveTowardsTarget(npc, target, isFleeing)
    if not npc or not target then return end
    
    local humanoid = npc:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local targetPosition = target:GetPivot().Position
    local currentState = NPCStateMachine.GetState(npc:GetAttribute("NPCId"))
    local speed = MOVEMENT_SPEEDS[currentState] or MOVEMENT_SPEEDS.ORB_SEEKING
    
    if isFleeing then
        -- Move away from target
        local npcPosition = npc:GetPivot().Position
        local direction = (npcPosition - targetPosition).Unit
        targetPosition = npcPosition + (direction * 50) -- Move 50 studs away
    end
    
    humanoid:MoveTo(targetPosition)
    humanoid.WalkSpeed = speed
end

-- Public API

function NPCAIController.Init()
    if NPCAIController._initialized then
        return Promise.resolve()
    end

    return Promise.new(function(resolve, reject)
        local success, err = pcall(function()
            print("NPCAIController: Initializing...")
            
            -- Initialize dependencies
            NPCRegistry.Init():andThen(function()
                -- Set up NPCRegistry callbacks
                NPCRegistry.OnNPCRegistered = function(npc)
                    print("NPCAIController: Received NPC registration from NPCRegistry:", npc:GetAttribute("NPCId"))
                    NPCAIController.RegisterNPC(npc)
                end
                
                NPCRegistry.OnNPCUnregistered = function(npc)
                    print("NPCAIController: Received NPC unregistration from NPCRegistry:", npc:GetAttribute("NPCId"))
                    NPCAIController.UnregisterNPC(npc)
                end
                
                return NPCStateMachine.Init()
            end):andThen(function()
                return ProximityManager.Init()
            end):andThen(function()
                -- Set up RunService connection for updates
                RunService.Heartbeat:Connect(function()
                    local now = tick()
                    if now - (NPCAIController._lastUpdate or 0) >= NPCAIController._updateFrequency then
                        NPCAIController._lastUpdate = now
                        NPCAIController.UpdateAllNPCs()
                    end
                end)
                
                NPCAIController._initialized = true
                print("NPCAIController: Initialized successfully")
                resolve()
            end):catch(function(err)
                warn("NPCAIController: Initialization failed:", err)
                reject(err)
            end)
        end)

        if not success then
            warn("NPCAIController: Failed to initialize:", err)
            reject(err)
        end
    end)
end

function NPCAIController.RegisterNPC(npc)
    if not NPCAIController._initialized then
        warn("NPCAIController: Attempted to register NPC before initialization")
        return
    end

    local npcId = npc:GetAttribute("NPCId")
    if not npcId then
        warn("NPCAIController: Attempted to register NPC without ID")
        return
    end

    NPCAIController._activeNPCs[npcId] = {
        target = nil,
        huntStartTime = nil,
        lastAttackTime = nil
    }
    
    -- Set initial state to OrbSeeking
    NPCStateMachine.ChangeState(npcId, "ORB_SEEKING")
    print("NPCAIController: Registered NPC", npcId, "with initial state ORB_SEEKING")
end

function NPCAIController.UnregisterNPC(npc)
    if not NPCAIController._initialized then
        warn("NPCAIController: Attempted to unregister NPC before initialization")
        return
    end

    local npcId = npc:GetAttribute("NPCId")
    if not npcId then return end

    NPCAIController._activeNPCs[npcId] = nil
    NPCStateMachine.CleanupNPC(npcId)
    print("NPCAIController: Unregistered NPC", npcId)
end

function NPCAIController.UpdateAllNPCs()
    if not NPCAIController._initialized then return end

    for npcId, data in pairs(NPCAIController._activeNPCs) do
        local npc = NPCRegistry.GetNPCById(npcId)
        if not npc then
            print("NPCAIController: NPC", npcId, "not found in registry, cleaning up")
            NPCAIController._activeNPCs[npcId] = nil
            continue
        end

        local currentState = NPCStateMachine.GetState(npcId)
        local nearestPlayer, playerDistance = getNearestPlayer(npc)
        local nearestOrb, orbDistance = getNearestOrb(npc)
        
        -- Handle fleeing behavior for smaller NPCs
        if nearestPlayer and shouldFleeFromPlayer(npc, nearestPlayer) then
            if playerDistance < DISTANCES.FLEE_START then
                if currentState ~= "FLEEING" then
                    print("NPCAIController: NPC", npcId, "fleeing from larger player at distance", playerDistance)
                    NPCStateMachine.ChangeState(npcId, "FLEEING")
                end
                moveTowardsTarget(npc, nearestPlayer, true) -- Move away from player
                continue
            elseif currentState == "FLEEING" and playerDistance > DISTANCES.SAFE_DISTANCE then
                print("NPCAIController: NPC", npcId, "safe from player, returning to orb seeking")
                NPCStateMachine.ChangeState(npcId, "ORB_SEEKING")
            end
        end
        
        -- Handle hunting/attack behavior for larger NPCs
        if nearestPlayer and not shouldFleeFromPlayer(npc, nearestPlayer) then
            if playerDistance < DISTANCES.ATTACK_RANGE then
                if currentState ~= "PLAYER_ATTACK" then
                    print("NPCAIController: NPC", npcId, "attacking player at distance", playerDistance)
                    NPCStateMachine.ChangeState(npcId, "PLAYER_ATTACK")
                    data.lastAttackTime = os.time()
                end
                moveTowardsTarget(npc, nearestPlayer)
                continue
            elseif playerDistance < DISTANCES.HUNT_START then
                if currentState ~= "PLAYER_HUNTING" then
                    print("NPCAIController: NPC", npcId, "hunting player at distance", playerDistance)
                    NPCStateMachine.ChangeState(npcId, "PLAYER_HUNTING")
                    data.huntStartTime = os.time()
                end
                moveTowardsTarget(npc, nearestPlayer)
                continue
            end
        end
        
        -- Check for hunt timeout or attack cooldown
        if currentState == "PLAYER_HUNTING" and data.huntStartTime then
            if os.time() - data.huntStartTime > HUNT_TIMEOUT then
                print("NPCAIController: NPC", npcId, "hunt timeout, returning to orb seeking")
                NPCStateMachine.ChangeState(npcId, "ORB_SEEKING")
                data.huntStartTime = nil
            end
        elseif currentState == "PLAYER_ATTACK" and data.lastAttackTime then
            if os.time() - data.lastAttackTime > 2 then -- 2 second attack cooldown
                print("NPCAIController: NPC", npcId, "attack complete, returning to orb seeking")
                NPCStateMachine.ChangeState(npcId, "ORB_SEEKING")
                data.lastAttackTime = nil
            end
        end
        
        -- Default to orb seeking
        if currentState == "ORB_SEEKING" then
            if nearestOrb then
                print("NPCAIController: NPC", npcId, "seeking orb at distance", orbDistance)
                data.target = nearestOrb
                moveTowardsTarget(npc, nearestOrb)
            else
                print("NPCAIController: NPC", npcId, "no targets found")
            end
        end
    end
end

return NPCAIController 