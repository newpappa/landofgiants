--[[
Name: NPCGiantManager
Type: Script
Location: ServerScriptService
Description: Spawns a static giant NPC in front of the player at the same size
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Load dependencies
local ModelsFolder = ReplicatedStorage:WaitForChild("Models")
local NPCModel = ModelsFolder:WaitForChild("R15 Dummy")
local PlayerSizeCalculator = require(ReplicatedStorage:WaitForChild("PlayerSizeCalculator"))

-- Function to create an NPC in front of a player
local function createNPC(player)
    local character = player.Character
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Get player's current size
    local playerScale = character:GetScale()
    print("NPCGiantManager: Creating giant at player's size:", playerScale)
    
    -- Clone the model
    local npc = NPCModel:Clone()
    npc.Parent = workspace
    
    -- Position 30 studs in front of player
    local forward = rootPart.CFrame.LookVector
    local spawnPos = rootPart.Position + (forward * 30)
    local npcRootPart = npc:WaitForChild("HumanoidRootPart")
    npcRootPart.CFrame = CFrame.new(spawnPos, rootPart.Position) -- Make giant face the player
    
    -- Scale the NPC to match player size
    npc:ScaleTo(playerScale)
    print("NPCGiantManager: Scaled giant to match player size")
    
    print("NPCGiantManager: Created giant in front of", player.Name)
end

-- Create giant when a player joins
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1) -- Wait for character to load
        createNPC(player)
    end)
end)

print("NPCGiantManager: Initialized") 