--[[
Name: NPCOverheadSizeDisplay
Type: LocalScript
Location: StarterPlayer.StarterPlayerScripts.Client.HUD
Description: Displays persistent overhead labels showing NPC size and state
Interacts With:
  - EventManager: Listens for NPC state changes
  - NPCRegistry: Gets NPC data
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Dependencies
local EventManager = require(ReplicatedStorage.Shared.Core.EventManager)

-- Constants
local DISPLAY_DISTANCE = 100 -- Increased viewing distance
local LABEL_OFFSET = Vector3.new(0, 3, 0) -- Height above NPC
local LABEL_SIZE = UDim2.new(0, 100, 0, 50)

-- Add debug print for initialization
print("NPCOverheadSizeDisplay: Starting initialization...")

-- Storage
local npcLabels = {} -- {npc = {billboardGui = gui, textLabel = label}}

-- Debug function to print NPC attributes
local function printNPCAttributes(npc)
    print("NPC Attributes for", npc.Name)
    for _, attr in ipairs(npc:GetAttributes()) do
        print("  ", attr, "=", npc:GetAttribute(attr))
    end
end

-- Recursive function to find NPCs in model hierarchy
local function findNPCsInModel(model)
    local foundNPCs = {}
    
    -- Check if this model is an NPC
    if model:GetAttribute("IsNPC") then
        table.insert(foundNPCs, model)
    end
    
    -- Recursively check children
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("Model") then
            local childNPCs = findNPCsInModel(child)
            for _, npc in ipairs(childNPCs) do
                table.insert(foundNPCs, npc)
            end
        end
    end
    
    return foundNPCs
end

-- Create a new label for an NPC
local function createLabel(npc)
    if npcLabels[npc] then 
        print("NPCOverheadSizeDisplay: Label already exists for NPC:", npc:GetAttribute("NPCId"))
        return 
    end
    
    print("NPCOverheadSizeDisplay: Creating label for NPC:", npc:GetAttribute("NPCId"))
    printNPCAttributes(npc)
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = LABEL_SIZE
    billboardGui.StudsOffset = LABEL_OFFSET
    billboardGui.Adornee = npc:WaitForChild("HumanoidRootPart")
    billboardGui.AlwaysOnTop = true
    billboardGui.MaxDistance = DISPLAY_DISTANCE
    
    -- Create background frame for better visibility
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = billboardGui
    
    -- Add corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 18
    textLabel.TextScaled = true
    textLabel.Parent = billboardGui
    
    billboardGui.Parent = npc
    npcLabels[npc] = {
        billboardGui = billboardGui,
        textLabel = textLabel
    }
    
    print("NPCOverheadSizeDisplay: Created label for NPC:", npc:GetAttribute("NPCId"))
end

-- Update a label's text
local function updateLabel(npc)
    local label = npcLabels[npc]
    if not label then return end
    
    local size = npc:GetAttribute("Size") or 1
    local state = npc:GetAttribute("CurrentState") or "Unknown"
    local npcId = npc:GetAttribute("NPCId") or "Unknown"
    
    label.textLabel.Text = string.format("NPC %s\nSize: %.2f\nState: %s", 
        npcId, size, state)
end

-- Remove a label
local function removeLabel(npc)
    local label = npcLabels[npc]
    if label then
        print("NPCOverheadSizeDisplay: Removing label for NPC:", npc:GetAttribute("NPCId"))
        label.billboardGui:Destroy()
        npcLabels[npc] = nil
    end
end

-- Initialize
local function init()
    print("NPCOverheadSizeDisplay: Setting up event listeners...")
    
    -- Listen for NPC state changes
    local stateChangedEvent = EventManager:GetEvent("NPCStateChanged")
    if stateChangedEvent then
        stateChangedEvent.OnClientEvent:Connect(function(npc, newState)
            print("NPCOverheadSizeDisplay: Received state change for NPC:", npc:GetAttribute("NPCId"))
            if npcLabels[npc] then
                updateLabel(npc)
            end
        end)
    end
    
    -- Set up update loop
    game:GetService("RunService").Heartbeat:Connect(function()
        for npc, label in pairs(npcLabels) do
            if not npc:IsDescendantOf(workspace) then
                removeLabel(npc)
            else
                updateLabel(npc)
            end
        end
    end)
    
    -- Find existing NPCs
    print("NPCOverheadSizeDisplay: Finding existing NPCs...")
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") then
            print("Checking model:", model.Name)
            local foundNPCs = findNPCsInModel(model)
            for _, npc in ipairs(foundNPCs) do
                print("Found NPC:", npc.Name)
                createLabel(npc)
            end
        end
    end
    
    -- Listen for new models
    workspace.ChildAdded:Connect(function(child)
        if child:IsA("Model") then
            print("New model added:", child.Name)
            local foundNPCs = findNPCsInModel(child)
            for _, npc in ipairs(foundNPCs) do
                print("Found new NPC:", npc.Name)
                createLabel(npc)
            end
        end
    end)
    
    -- Listen for removed NPCs
    workspace.ChildRemoved:Connect(function(child)
        if npcLabels[child] then
            removeLabel(child)
        end
    end)
    
    print("NPCOverheadSizeDisplay: Initialization complete!")
end

-- Start the script
init() 