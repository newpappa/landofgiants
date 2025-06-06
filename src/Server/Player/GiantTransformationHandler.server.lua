--[[
Name: GiantTransformationHandler
Type: Script
Location: ServerScriptService
Description: Handles giant transformation purchases and character scaling
Interacts With:
  - GiantBuyModal: Client-side UI handling for giant transformation purchases
  - PurchaseProcessor: Receives purchase events for giant transformations
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import required modules
local PlayerSizeCalculator = require(ReplicatedStorage.Shared.Progression.PlayerSizeCalculator)
local SizeStateMachine = require(ReplicatedStorage.Shared.Core.SizeStateMachine)

-- Configuration
local GIANT_SCALE = 15

-- Function to transform player into giant
local function transformPlayerToGiant(player)
    print("GiantTransformationHandler: Starting transformation for", player.Name)
    
    -- Calculate size data for giant transformation
    local sizeData = PlayerSizeCalculator.getSizeData(GIANT_SCALE)
    print("GiantTransformationHandler: Calculated size data for", player.Name, "scale:", GIANT_SCALE)
    
    -- Update the size state through SizeStateMachine
    local success = SizeStateMachine:UpdatePlayerSize(player, sizeData)
    if success then
        print("GiantTransformationHandler: Successfully transformed", player.Name, "to giant size", GIANT_SCALE)
        
        -- Scale the character if it exists
        if player.Character then
            print("GiantTransformationHandler: Scaling character for", player.Name)
            player.Character:ScaleTo(GIANT_SCALE)
        else
            warn("GiantTransformationHandler: No character found to scale for", player.Name)
        end
    else
        warn("GiantTransformationHandler: Failed to transform", player.Name)
    end
end

-- Wait for and connect to purchase event
local GiantPurchaseEvent = ReplicatedStorage:WaitForChild("GiantPurchaseEvent")
print("GiantTransformationHandler: Found GiantPurchaseEvent")

GiantPurchaseEvent.OnServerEvent:Connect(function(player)
    print("GiantTransformationHandler: Received purchase event from", player.Name)
    transformPlayerToGiant(player)
end)

print("GiantTransformationHandler initialized!") 