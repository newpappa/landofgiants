--[[
Name: SizeStateMachine
Type: ModuleScript
Location: ReplicatedStorage
Description: Manages and tracks player sizes, providing a central source of truth for size states
Interacts With:
  - PlayerSizeCalculator: Uses size utilities and constraints
  - PlayerSpawnHandler: Receives size updates for spawning
  - SquashHandler: Updates sizes for squash mechanics
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PlayerSizeCalculator = require(ReplicatedStorage:WaitForChild("PlayerSizeCalculator"))

-- Create or get RemoteEvent for size replication
local SizeReplicationEvent = ReplicatedStorage:FindFirstChild("SizeReplicationEvent")
if not SizeReplicationEvent then
    SizeReplicationEvent = Instance.new("RemoteEvent")
    SizeReplicationEvent.Name = "SizeReplicationEvent"
    SizeReplicationEvent.Parent = ReplicatedStorage
end

local SizeStateMachine = {
    _playerData = {}, -- Store player size data {scale = number, visualHeight = number}
    OnSizeChanged = Instance.new("BindableEvent")
}

-- Get current raw scale for a player
function SizeStateMachine:GetPlayerScale(player)
    local data = self._playerData[player.UserId]
    local scale = data and data.scale or nil
    print("SizeStateMachine: GetPlayerScale called for", player.Name, "returning:", scale)
    return scale
end

-- Get current visual height for a player
function SizeStateMachine:GetPlayerVisualHeight(player)
    local data = self._playerData[player.UserId]
    local height = data and data.visualHeight or nil
    print("SizeStateMachine: GetPlayerVisualHeight called for", player.Name, "returning:", height)
    return height
end

-- Update size for a player
function SizeStateMachine:UpdatePlayerSize(player, sizeData)
    print("SizeStateMachine: Attempting to update size for", player.Name, "to scale:", sizeData.scale, "visual height:", sizeData.visualHeight)
    
    if PlayerSizeCalculator.isValidSize(sizeData.scale) then
        -- Store both values directly
        self._playerData[player.UserId] = {
            scale = sizeData.scale,
            visualHeight = sizeData.visualHeight
        }
        
        -- Fire event with both values
        self.OnSizeChanged:Fire(player, sizeData.scale, sizeData.visualHeight)
        
        -- If we're on the server, replicate to clients
        if RunService:IsServer() then
            -- Send both scale and visual height
            SizeReplicationEvent:FireAllClients(player.UserId, {
                scale = sizeData.scale,
                visualHeight = sizeData.visualHeight
            })
        end
        
        return true
    end
    print("SizeStateMachine: Scale", sizeData.scale, "is not valid for player", player.Name)
    return false
end

-- Clean up when player leaves
function SizeStateMachine:RemovePlayer(player)
    print("SizeStateMachine: Removing size data for", player.Name)
    self._playerData[player.UserId] = nil
end

-- Handle player cleanup
local function onPlayerRemoving(player)
    SizeStateMachine:RemovePlayer(player)
end

-- Set up player cleanup
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- If we're on the client, listen for size updates from server
if RunService:IsClient() then
    SizeReplicationEvent.OnClientEvent:Connect(function(userId, sizeData)
        local player = Players:GetPlayerByUserId(userId)
        if player then
            print("SizeStateMachine: Received size update from server for", player.Name, 
                  "scale:", sizeData.scale, "visual height:", sizeData.visualHeight)
            -- Store the received data directly
            SizeStateMachine._playerData[userId] = {
                scale = sizeData.scale,
                visualHeight = sizeData.visualHeight
            }
            -- Fire the change event
            SizeStateMachine.OnSizeChanged:Fire(player, sizeData.scale, sizeData.visualHeight)
        end
    end)
end

print("SizeStateMachine initialized!")

return SizeStateMachine 