--[[
Name: LeaderstatsUpdater
Type: Script
Location: ServerScriptService
Description: Creates and updates leaderstats for player size and squash tracking
Interacts With:
    - SizeStateMachine: Gets player visual height values
    - PlayerSpawnHandler: Waits for initial size to be set
    - SquashTracker: Updates squash counts
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
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

    -- Create the Squashes value
    local squashesValue = Instance.new("IntValue")
    squashesValue.Name = "Squashes"
    squashesValue.Value = 0
    squashesValue.Parent = leaderstats
    
    print("LeaderstatsUpdater: Created Size and Squashes values for", player.Name)
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
end)

-- Listen for size changes from SizeStateMachine
SizeStateMachine.OnSizeChanged.Event:Connect(function(player, newScale, newVisualHeight)
    print("LeaderstatsUpdater: Received size change event for", player.Name, "new visual height:", newVisualHeight, "feet")
    updateSizeValue(player)
end)

-- Listen for squash updates from SquashTracker
local SquashTracker = ServerScriptService:WaitForChild("SquashTracker")
local SquashCountChanged = SquashTracker:WaitForChild("SquashCountChanged")

SquashCountChanged.Event:Connect(function(player, action)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return end
    
    local squashesValue = leaderstats:FindFirstChild("Squashes")
    if squashesValue then
        if action == 0 then
            -- Reset squashes
            squashesValue.Value = 0
            print("LeaderstatsUpdater: Reset Squashes for", player.Name)
        else
            -- Increment squashes
            squashesValue.Value = squashesValue.Value + 1
            print("LeaderstatsUpdater: Updated Squashes for", player.Name, "to", squashesValue.Value)
        end
    end
end) 