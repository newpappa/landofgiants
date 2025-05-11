--[[
Name: SquashTracker
Type: Script
Location: ServerScriptService
Description: Tracks and manages player squash counts
Interacts With:
    - SquashHandler: Receives squash events
    - LeaderstatsUpdater: Notifies of squash count updates
    - BottomBarManager: Updates client squash display
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create RemoteEvent for client communication
local SquashCountRemote = Instance.new("RemoteEvent")
SquashCountRemote.Name = "SquashCountRemote"
SquashCountRemote.Parent = ReplicatedStorage

-- Create BindableEvent for communicating with LeaderstatsUpdater
local SquashCountChanged = Instance.new("BindableEvent")
SquashCountChanged.Name = "SquashCountChanged"
SquashCountChanged.Parent = script

-- Listen for squash events from SquashHandler
local SquashEvent = ReplicatedStorage:WaitForChild("SquashEvent")

-- Handle player spawns to reset squash count
local function handlePlayerAdded(player)
    player.CharacterAdded:Connect(function()
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

SquashEvent.OnServerEvent:Connect(function(_, squashedPlayer, squashingPlayer)
    -- We only care about the squashing player for offensive squashes
    if squashingPlayer then
        -- Notify LeaderstatsUpdater about the new squash count
        SquashCountChanged:Fire(squashingPlayer, 1) -- 1 indicates increment
    end
end)

SquashCountChanged.Event:Connect(function(player, action)
    -- Also notify clients of the update
    SquashCountRemote:FireClient(player, action == 0 and 0 or player:FindFirstChild("leaderstats") and player:FindFirstChild("leaderstats"):FindFirstChild("Squashes") and player:FindFirstChild("leaderstats").Squashes.Value or 0)
end) 