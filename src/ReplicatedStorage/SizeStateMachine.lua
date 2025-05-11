--[[
Name: SizeStateMachine
Type: ModuleScript
Location: ReplicatedStorage
Description: Manages and tracks player sizes, providing a central source of truth for size states
Interacts With:
  - PlayerSizeModule: Uses size utilities and constraints
  - PlayerSpawnHandler: Receives size updates for spawning
  - SquashHandler: Updates sizes for squash mechanics
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PlayerSizeModule = require(ReplicatedStorage:WaitForChild("PlayerSizeModule"))

-- Create or get RemoteEvent for size replication
local SizeReplicationEvent = ReplicatedStorage:FindFirstChild("SizeReplicationEvent")
if not SizeReplicationEvent then
    SizeReplicationEvent = Instance.new("RemoteEvent")
    SizeReplicationEvent.Name = "SizeReplicationEvent"
    SizeReplicationEvent.Parent = ReplicatedStorage
end

local SizeStateMachine = {
    _sizes = {}, -- Store player sizes
    OnSizeChanged = Instance.new("BindableEvent")
}

-- Get current size for a player
function SizeStateMachine:GetPlayerSize(player)
    local size = self._sizes[player.UserId]
    print("SizeStateMachine: GetPlayerSize called for", player.Name, "returning:", size) -- Debug log
    return size
end

-- Update size for a player
function SizeStateMachine:UpdatePlayerSize(player, newSize)
    print("SizeStateMachine: Attempting to update size for", player.Name, "to", newSize) -- Debug log
    if PlayerSizeModule.isValidSize(newSize) then
        print("SizeStateMachine: Size is valid, updating...")
        self._sizes[player.UserId] = newSize
        self.OnSizeChanged:Fire(player, newSize)
        
        -- If we're on the server, replicate to clients
        if RunService:IsServer() then
            SizeReplicationEvent:FireAllClients(player.UserId, newSize)
        end
        
        return true
    end
    print("SizeStateMachine: Size", newSize, "is not valid for player", player.Name) -- Debug log
    return false
end

-- Clean up when player leaves
function SizeStateMachine:RemovePlayer(player)
    print("SizeStateMachine: Removing size data for", player.Name)
    self._sizes[player.UserId] = nil
end

-- Handle player cleanup
local function onPlayerRemoving(player)
    SizeStateMachine:RemovePlayer(player)
end

-- Set up player cleanup
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- If we're on the client, listen for size updates from server
if RunService:IsClient() then
    SizeReplicationEvent.OnClientEvent:Connect(function(userId, newSize)
        local player = Players:GetPlayerByUserId(userId)
        if player then
            print("SizeStateMachine: Received size update from server for", player.Name, ":", newSize)
            SizeStateMachine:UpdatePlayerSize(player, newSize)
        end
    end)
end

print("SizeStateMachine initialized!")

return SizeStateMachine 