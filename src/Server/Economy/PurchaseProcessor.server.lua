--[[
Name: PurchaseProcessor
Type: Script
Location: ServerScriptService
Description: Central handler for processing all marketplace purchases
Interacts With:
  - GiantTransformationHandler: Delegates giant transformation purchases
  - SpeedTransformationHandler: Delegates speed boost purchases
--]]

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Product IDs
local PRODUCT_IDS = {
    GIANT_TRANSFORM = 3283964724,
    SPEED_BOOST = 3283965166
}

-- Create RemoteEvents for purchase handling
local GiantPurchaseEvent = Instance.new("RemoteEvent")
GiantPurchaseEvent.Name = "GiantPurchaseEvent"
GiantPurchaseEvent.Parent = ReplicatedStorage

local SpeedPurchaseEvent = Instance.new("RemoteEvent")
SpeedPurchaseEvent.Name = "SpeedPurchaseEvent"
SpeedPurchaseEvent.Parent = ReplicatedStorage

-- Create BindableEvents for server-side communication
local GiantPurchaseBindable = Instance.new("BindableEvent")
GiantPurchaseBindable.Name = "GiantPurchaseBindable"
GiantPurchaseBindable.Parent = script

local SpeedPurchaseBindable = Instance.new("BindableEvent")
SpeedPurchaseBindable.Name = "SpeedPurchaseBindable"
SpeedPurchaseBindable.Parent = script

-- Connect the BindableEvents to the handlers
GiantPurchaseBindable.Event:Connect(function(player)
    print("PurchaseProcessor: Handling giant transformation for", player.Name)
    GiantPurchaseEvent:FireClient(player)
end)

SpeedPurchaseBindable.Event:Connect(function(player)
    print("PurchaseProcessor: Handling speed boost for", player.Name)
    SpeedPurchaseEvent:FireClient(player)
end)

-- Handle purchase success
local function onProcessReceipt(receiptInfo)
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then
        print("PurchaseProcessor: Player not found for userId:", receiptInfo.PlayerId)
        return false
    end

    print("PurchaseProcessor: Processing receipt for", player.Name)
    print("PurchaseProcessor: ProductId:", receiptInfo.ProductId)
    
    if receiptInfo.ProductId == PRODUCT_IDS.GIANT_TRANSFORM then
        print("PurchaseProcessor: Firing giant transformation event for", player.Name)
        GiantPurchaseBindable:Fire(player)
        return true
    elseif receiptInfo.ProductId == PRODUCT_IDS.SPEED_BOOST then
        print("PurchaseProcessor: Firing speed boost event for", player.Name)
        SpeedPurchaseBindable:Fire(player)
        return true
    end
    
    print("PurchaseProcessor: Unknown product ID:", receiptInfo.ProductId)
    return false
end

-- Set up MarketplaceService handler
MarketplaceService.ProcessReceipt = onProcessReceipt

print("PurchaseProcessor initialized!")

-- Also handle purchase completion events as a backup
MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, wasPurchased)
    print("PurchaseProcessor: Purchase finished - userId:", userId, "productId:", productId, "wasPurchased:", wasPurchased)
    
    if not wasPurchased then
        print("PurchaseProcessor: Purchase was not completed")
        return
    end
    
    local player = Players:GetPlayerByUserId(userId)
    if not player then
        print("PurchaseProcessor: Player not found for userId:", userId)
        return
    end
    
    if productId == PRODUCT_IDS.GIANT_TRANSFORM then
        print("PurchaseProcessor: Firing giant transformation event for", player.Name)
        GiantPurchaseBindable:Fire(player)
    elseif productId == PRODUCT_IDS.SPEED_BOOST then
        print("PurchaseProcessor: Firing speed boost event for", player.Name)
        SpeedPurchaseBindable:Fire(player)
    else
        print("PurchaseProcessor: Unknown product ID:", productId)
    end
end) 