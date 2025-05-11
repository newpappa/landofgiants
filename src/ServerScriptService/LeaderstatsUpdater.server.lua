--[[
Name: LeaderstatsUpdater
Type: Script
Location: ServerScriptService
Description: Creates and updates leaderstats for player size tracking
Interacts With:
    - SizeStateMachine: Gets player visual height values
    - PlayerSpawnHandler: Waits for initial size to be set
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SizeStateMachine = require(ReplicatedStorage:WaitForChild("SizeStateMachine"))

-- Function to setup leaderstats for a player
local function setupLeaderstats(player)
    print("LeaderstatsUpdater: Setting up leaderstats for", player.Name)
    -- Create the leaderstats folder
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
    
    -- Create the Size value (will store visual height in feet)
    local sizeValue = Instance.new("NumberValue")
    sizeValue.Name = "Size"
    sizeValue.Value = 5 -- Start at minimum height (5 feet)
    sizeValue.Parent = leaderstats
    print("LeaderstatsUpdater: Created Size value for", player.Name, "starting at 5 feet")
end

-- Function to update size value
local function updateSizeValue(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then 
        print("LeaderstatsUpdater: No leaderstats found for", player.Name)
        return 
    end
    
    local sizeValue = leaderstats:FindFirstChild("Size")
    if not sizeValue then 
        print("LeaderstatsUpdater: No Size value found for", player.Name)
        return 
    end
    
    -- Get visual height directly from SizeStateMachine
    local visualHeight = SizeStateMachine:GetPlayerVisualHeight(player)
    if visualHeight then
        print("LeaderstatsUpdater: Updating size for", player.Name, "to", visualHeight, "feet")
        sizeValue.Value = math.round(visualHeight * 10) / 10 -- Round to 1 decimal place
    else
        print("LeaderstatsUpdater: No size data found in SizeStateMachine for", player.Name)
    end
end

-- When a player joins
Players.PlayerAdded:Connect(function(player)
    print("LeaderstatsUpdater: New player joined:", player.Name)
    setupLeaderstats(player)
    -- We no longer try to get the initial size here
    -- It will be set when PlayerSpawnHandler sets the first size
end)

-- Listen for size changes from SizeStateMachine
SizeStateMachine.OnSizeChanged.Event:Connect(function(player, newScale, newVisualHeight)
    print("LeaderstatsUpdater: Received size change event for", player.Name, "new visual height:", newVisualHeight, "feet")
    updateSizeValue(player)
end) 