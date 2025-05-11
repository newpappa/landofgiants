--[[
Name: SpeedTransformationHandler
Type: Script
Location: ServerScriptService
Description: Handles 2x speed purchases and character speed modification. Speed boost is temporary and resets on death.
Interacts With:
  - SpeedBuyModal: Client-side UI handling for speed purchases
  - PurchaseProcessor: Receives purchase events for speed boosts
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local SPEED_MULTIPLIER = 2

-- Function to apply speed boost to player
local function applySpeedBoost(player)
    print("SpeedTransformationHandler: Starting speed boost process for", player.Name)
    
    if not player.Character then
        warn("SpeedTransformationHandler: No Character found for", player.Name)
        return
    end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid then
        warn("SpeedTransformationHandler: No Humanoid found for", player.Name)
        return
    end
    
    -- Log current speed before changes
    print("SpeedTransformationHandler: Current walk speed for", player.Name, "is", humanoid.WalkSpeed)
    
    -- Apply speed multiplier (one-time boost)
    local newSpeed = humanoid.WalkSpeed * SPEED_MULTIPLIER
    humanoid.WalkSpeed = newSpeed
    print("SpeedTransformationHandler: Applied", SPEED_MULTIPLIER, "x speed to", player.Name, 
          "- new speed:", newSpeed)
end

-- Wait for and connect to purchase event
local SpeedPurchaseEvent = ReplicatedStorage:WaitForChild("SpeedPurchaseEvent")
print("SpeedTransformationHandler: Found SpeedPurchaseEvent")

SpeedPurchaseEvent.OnServerEvent:Connect(function(player)
    print("SpeedTransformationHandler: Received purchase event from", player.Name)
    applySpeedBoost(player)
end)

print("SpeedTransformationHandler initialized!") 