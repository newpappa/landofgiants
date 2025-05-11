--[[
Name: SquashTracker
Type: Script
Location: ServerScriptService
Description: Tracks and manages player squash counts
Interacts With:
    - SquashHandler: Receives squash events via ServerSquashEvent
    - LeaderstatsUpdater: Notifies of squash count updates
    - BottomBarManager: Updates client squash display
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Create RemoteEvent for client communication
local SquashCountRemote = Instance.new("RemoteEvent")
SquashCountRemote.Name = "SquashCountRemote"
SquashCountRemote.Parent = ReplicatedStorage

-- Create BindableEvent for communicating with LeaderstatsUpdater
local SquashCountChanged = Instance.new("BindableEvent")
SquashCountChanged.Name = "SquashCountChanged"
SquashCountChanged.Parent = script

-- Handle player spawns to reset squash count
local function handlePlayerAdded(player)
    player.CharacterAdded:Connect(function()
        print("SquashTracker: Resetting squash count for", player.Name)
        -- Reset squash count on spawn and notify LeaderstatsUpdater
        SquashCountChanged:Fire(player, 0)
    end)
end

-- Set up for new players
Players.PlayerAdded:Connect(handlePlayerAdded)

-- Handle existing players
for _, player in ipairs(Players:GetPlayers()) do
    handlePlayerAdded(player)
end

-- Listen for squash events from SquashHandler
local SquashHandler = ServerScriptService:WaitForChild("SquashHandler")
local ServerSquashEvent = SquashHandler:WaitForChild("ServerSquashEvent")

ServerSquashEvent.Event:Connect(function(squashedPlayer, squashingPlayer)
    -- Increment squash count for the squashing player
    if squashingPlayer then
        print("SquashTracker: Incrementing squash count for", squashingPlayer.Name)
        SquashCountChanged:Fire(squashingPlayer, 1) -- 1 indicates increment
    end
end)

SquashCountChanged.Event:Connect(function(player, action)
    -- Get current count for client update
    local currentCount = action == 0 and 0 or 
        player:FindFirstChild("leaderstats") and 
        player:FindFirstChild("leaderstats"):FindFirstChild("Squashes") and 
        player:FindFirstChild("leaderstats").Squashes.Value or 0
    
    print("SquashTracker: Updating client count for", player.Name, "to", currentCount)
    SquashCountRemote:FireClient(player, currentCount)
end) 