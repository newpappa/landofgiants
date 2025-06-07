--[[
Name: SizeStateMachine
Type: ModuleScript
Location: ReplicatedStorage.Shared.Core
Description: Manages and tracks player sizes, providing a central source of truth for size states
Interacts With:
  - PlayerSizeCalculator: Uses size utilities and constraints
  - PlayerSpawnHandler: Receives size updates for spawning
  - SquashHandler: Updates sizes for squash mechanics
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PlayerSizeCalculator = require(ReplicatedStorage.Shared.Progression.PlayerSizeCalculator)

-- Create or get RemoteEvent for size replication
local SizeReplicationEvent = ReplicatedStorage:FindFirstChild("SizeReplicationEvent")
if not SizeReplicationEvent then
    SizeReplicationEvent = Instance.new("RemoteEvent")
    SizeReplicationEvent.Name = "SizeReplicationEvent"
    SizeReplicationEvent.Parent = ReplicatedStorage
end

local SizeStateMachine = {
    _playerData = {}, -- Store player size data {scale = number, visualHeight = number, bonusHeight = number}
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
    if not data then return nil end
    
    local baseHeight = data.visualHeight or 0
    local bonusHeight = data.bonusHeight or 0
    local totalHeight = baseHeight + bonusHeight
    
    print("SizeStateMachine: GetPlayerVisualHeight called for", player.Name, 
          "base:", baseHeight, "bonus:", bonusHeight, "total:", totalHeight)
    return totalHeight
end

-- Update size for a player
function SizeStateMachine:UpdatePlayerSize(player, sizeData)
    print("SizeStateMachine: Attempting to update size for", player.Name, "to scale:", sizeData.scale, "visual height:", sizeData.visualHeight)
    
    if PlayerSizeCalculator.isValidSize(sizeData.scale) then
        local currentData = self._playerData[player.UserId] or {}
        local currentVisualHeight = currentData.visualHeight or 0
        local currentBonusHeight = currentData.bonusHeight or 0
        
        -- If we're at or above 1000 feet, cap the scale but allow visual height to increase
        if currentVisualHeight >= 1000 then
            -- Keep scale at whatever gave us 1000 feet
            local newBonusHeight = currentBonusHeight + (sizeData.visualHeight - currentVisualHeight)
            
            self._playerData[player.UserId] = {
                scale = currentData.scale, -- Keep existing scale
                visualHeight = currentVisualHeight, -- Keep base visual height
                bonusHeight = newBonusHeight -- Add to bonus height
            }
        else
            -- Normal update below 1000 feet
            self._playerData[player.UserId] = {
                scale = sizeData.scale,
                visualHeight = sizeData.visualHeight,
                bonusHeight = currentBonusHeight
            }
        end
        
        local data = self._playerData[player.UserId]
        local totalHeight = data.visualHeight + data.bonusHeight
        
        -- Fire event with total height
        self.OnSizeChanged:Fire(player, data.scale, totalHeight)
        
        -- If we're on the server, replicate to clients
        if RunService:IsServer() then
            SizeReplicationEvent:FireAllClients(player.UserId, {
                scale = data.scale,
                visualHeight = data.visualHeight,
                bonusHeight = data.bonusHeight
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
                  "scale:", sizeData.scale, "visual height:", sizeData.visualHeight,
                  "bonus height:", sizeData.bonusHeight)
            -- Store the complete data structure
            SizeStateMachine._playerData[userId] = sizeData
            -- Fire the change event with total height
            local totalHeight = sizeData.visualHeight + (sizeData.bonusHeight or 0)
            SizeStateMachine.OnSizeChanged:Fire(player, sizeData.scale, totalHeight)
        end
    end)
end

print("SizeStateMachine initialized!")

function SizeStateMachine.Init()
    return true
end

return SizeStateMachine 