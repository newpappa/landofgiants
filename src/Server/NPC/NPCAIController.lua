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
local NPCRegistry = require(ReplicatedStorage.Shared.NPC.NPCRegistry)
local NPCStateMachine = require(ServerScriptService.Server.NPC.NPCStateMachine)
local ProximityManager = require(ServerScriptService.Server.NPC.ProximityManager)
local NPCMover = require(script.Parent.NPCMover)
local AnimationController = require(script.Parent.AnimationController)

-- Constants
local HUNT_TIMEOUT = 10 -- seconds to continue hunting before considering orbs

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
    local nearbyOrbs = ProximityManager.GetOrbsNearPosition(npcPosition, 300) -- Increased search radius to 300 studs
    
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
    
    -- Debug logging
    if #nearbyOrbs > 0 then
        print("NPCAIController: Found", #nearbyOrbs, "orbs near NPC", npc:GetAttribute("NPCId"))
        if nearestOrb then
            local orbId = nearestOrb:GetAttribute("OrbId")
            local orbPos = nearestOrb:GetPivot().Position
            print(string.format("NPCAIController: NPC_%s found target Orb_%s at position (X:%.1f, Y:%.1f, Z:%.1f)",
                npc:GetAttribute("NPCId"),
                orbId,
                orbPos.X, orbPos.Y, orbPos.Z
            ))
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

local function updateNPCTarget(npc, target)
    if target then
        -- Use the orb's unique ID if it's an orb
        if target:GetAttribute("OrbId") then
            npc:SetAttribute("CurrentTarget", target:GetAttribute("OrbId"))
        else
            npc:SetAttribute("CurrentTarget", target.Name)
        end
    else
        npc:SetAttribute("CurrentTarget", nil)
    end
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
            NPCStateMachine.Init()
            NPCMover.Init()
            AnimationController.Init()
            
            NPCAIController._initialized = true
        end)

        if success then
            print("NPCAIController initialized!")
            resolve()
        else
            warn("NPCAIController: Failed to initialize -", err)
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
    if not npcId then return end

    NPCAIController._activeNPCs[npcId] = {
        target = nil,
        huntStartTime = nil,
        lastAttackTime = nil
    }
    
    -- Set initial state
    NPCStateMachine.ChangeState(npcId, "ORB_SEEKING", nil)
    print("NPCAIController: Registered NPC", npcId)
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
    NPCMover.StopMovement(npc)
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
        
        -- If no targets are available, go to WANDERING state
        if not nearestOrb and not nearestPlayer then
            if currentState ~= "WANDERING" then
                print("NPCAIController: NPC", npcId, "no targets available, starting to wander")
                NPCStateMachine.ChangeState(npcId, "WANDERING", nil)
            end
            continue
        end
        
        -- Handle fleeing behavior for smaller NPCs
        if nearestPlayer and shouldFleeFromPlayer(npc, nearestPlayer) then
            if playerDistance <= DISTANCES.FLEE_START then
                if currentState ~= "FLEEING" then
                    print("NPCAIController: NPC", npcId, "fleeing from larger player")
                    NPCStateMachine.ChangeState(npcId, "FLEEING", nearestPlayer)
                end
                continue
            end
        end
        
        -- Handle hunting behavior for larger NPCs
        if nearestPlayer and not shouldFleeFromPlayer(npc, nearestPlayer) then
            if playerDistance <= DISTANCES.ATTACK_RANGE then
                if currentState ~= "PLAYER_ATTACK" then
                    print("NPCAIController: NPC", npcId, "attacking player")
                    NPCStateMachine.ChangeState(npcId, "PLAYER_ATTACK", nearestPlayer)
                end
                continue
            elseif playerDistance <= DISTANCES.HUNT_START then
                if currentState ~= "PLAYER_HUNTING" then
                    print("NPCAIController: NPC", npcId, "hunting player")
                    NPCStateMachine.ChangeState(npcId, "PLAYER_HUNTING", nearestPlayer)
                end
                continue
            end
        end
        
        -- Handle orb seeking
        if nearestOrb then
            if currentState ~= "ORB_SEEKING" then
                print("NPCAIController: NPC", npcId, "seeking orb")
                NPCStateMachine.ChangeState(npcId, "ORB_SEEKING", nearestOrb)
            else
                -- Update target orb even if already in ORB_SEEKING state
                local currentTarget = npc:GetAttribute("CurrentTarget")
                local orbId = nearestOrb:GetAttribute("OrbId")
                if currentTarget ~= orbId then
                    print("NPCAIController: NPC", npcId, "updating target orb")
                    NPCStateMachine.ChangeState(npcId, "ORB_SEEKING", nearestOrb)
                end
            end
        end
    end
end

-- Set up RunService connection for AI updates
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - (NPCAIController._lastUpdate or 0) >= NPCAIController._updateFrequency then
        NPCAIController._lastUpdate = now
        NPCAIController.UpdateAllNPCs()
    end
end)

return NPCAIController 