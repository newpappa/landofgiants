--[[
Name: NPCFactory
Type: ModuleScript
Location: ServerScriptService.Server.NPC
Description: Creates and manages NPC characters with proper scaling and behaviors
Interacts With:
  - PlayerSizeCalculator: Uses same size calculation logic as players
  - SizeStateMachine: Manages NPC size state
  - OrbPickupManager: Handles NPC orb collection
  - SquashHandler: Manages NPC squash mechanics
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Load dependencies
local PlayerSizeCalculator = require(ReplicatedStorage.Shared.Progression.PlayerSizeCalculator)
local SizeStateMachine = require(ReplicatedStorage.Shared.Core.SizeStateMachine)
local Promise = require(ReplicatedStorage.Shared.Core.Promise)

-- Get the NPC model
local NPCModel = ReplicatedStorage.Models:WaitForChild("R15 Dummy")

local NPCFactory = {
    _initialized = false,
    _activeNPCs = {},
    _nextNPCId = 1
}

-- Function to create a new NPC
function NPCFactory.CreateNPC(spawnPosition)
    if not NPCFactory._initialized then
        warn("NPCFactory: Attempted to create NPC before initialization")
        return nil
    end

    -- Get random spawn size
    local sizeData = PlayerSizeCalculator.getRandomSpawnSize()
    if not sizeData then
        warn("NPCFactory: Failed to get random spawn size")
        return nil
    end
    
    -- Clone the model
    local npc = NPCModel:Clone()
    npc.Parent = workspace
    
    -- Set up the NPC
    local rootPart = npc:WaitForChild("HumanoidRootPart")
    rootPart.CFrame = CFrame.new(spawnPosition)
    
    -- Scale the NPC
    npc:ScaleTo(sizeData.scale)
    
    -- Generate unique NPC ID
    local npcId = "NPC_" .. NPCFactory._nextNPCId
    NPCFactory._nextNPCId = NPCFactory._nextNPCId + 1
    
    -- Add NPC-specific attributes
    npc:SetAttribute("IsNPC", true)
    npc:SetAttribute("NPCId", npcId)
    npc:SetAttribute("SpawnTime", os.time())
    npc:SetAttribute("CurrentState", "ORB_SEEKING")
    npc:SetAttribute("Size", sizeData.scale)
    npc:SetAttribute("VisualHeight", sizeData.visualHeight)
    
    -- Set up the humanoid
    local humanoid = npc:WaitForChild("Humanoid")
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    
    -- Add to active NPCs
    NPCFactory._activeNPCs[npc] = {
        sizeData = sizeData,
        lastPosition = spawnPosition,
        state = "OrbSeeking"
    }
    
    print("NPCFactory: Created NPC", npcId, "at size", sizeData.scale)
    return npc
end

-- Function to remove an NPC
function NPCFactory.RemoveNPC(npc)
    if not NPCFactory._initialized then
        warn("NPCFactory: Attempted to remove NPC before initialization")
        return
    end

    if not NPCFactory._activeNPCs[npc] then
        warn("NPCFactory: Attempted to remove non-existent NPC")
        return
    end
    
    -- Clean up
    NPCFactory._activeNPCs[npc] = nil
    npc:Destroy()
    print("NPCFactory: Removed NPC")
end

-- Function to get all active NPCs
function NPCFactory.GetActiveNPCs()
    if not NPCFactory._initialized then
        warn("NPCFactory: Attempted to get active NPCs before initialization")
        return {}
    end
    return NPCFactory._activeNPCs
end

-- Function to get NPC data
function NPCFactory.GetNPCData(npc)
    if not NPCFactory._initialized then
        warn("NPCFactory: Attempted to get NPC data before initialization")
        return nil
    end
    return NPCFactory._activeNPCs[npc]
end

-- Function to update NPC state
function NPCFactory.UpdateNPCState(npc, newState)
    if not NPCFactory._initialized then
        warn("NPCFactory: Attempted to update NPC state before initialization")
        return
    end

    if not NPCFactory._activeNPCs[npc] then
        warn("NPCFactory: Attempted to update state for non-existent NPC")
        return
    end
    
    NPCFactory._activeNPCs[npc].state = newState
    npc:SetAttribute("CurrentState", newState)
    print("NPCFactory: Updated NPC state to", newState)
end

-- Function to update NPC size
function NPCFactory.UpdateNPCSize(npc, newSizeData)
    if not NPCFactory._initialized then
        warn("NPCFactory: Attempted to update NPC size before initialization")
        return
    end

    if not NPCFactory._activeNPCs[npc] then
        warn("NPCFactory: Attempted to update size for non-existent NPC")
        return
    end
    
    -- Update size
    npc:ScaleTo(newSizeData.scale)
    
    -- Update attributes
    npc:SetAttribute("Size", newSizeData.scale)
    npc:SetAttribute("VisualHeight", newSizeData.visualHeight)
    
    -- Update tracking data
    NPCFactory._activeNPCs[npc].sizeData = newSizeData
    
    print("NPCFactory: Updated NPC size to", newSizeData.scale)
end

-- Initialize the NPCFactory
function NPCFactory.Init()
    if NPCFactory._initialized then
        return Promise.resolve()
    end

    return Promise.new(function(resolve, reject)
        local success, err = pcall(function()
            print("NPCFactory: Initializing...")
            NPCFactory._initialized = true
        end)

        if success then
            print("NPCFactory initialized!")
            resolve()
        else
            warn("NPCFactory: Failed to initialize -", err)
            reject(err)
        end
    end)
end

return NPCFactory 