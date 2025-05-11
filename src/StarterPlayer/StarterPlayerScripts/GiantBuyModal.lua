--[[
Name: GiantBuyModal
Type: ModuleScript
Location: StarterPlayer.StarterPlayerScripts
Description: Modal UI module for giant transformation purchases
Interacts With:
  - GiantTransformationHandler: Server-side purchase and transformation processing
  - BuyModalsInit: Client-side initialization of all purchase modals
  - BuySuccessNotifications: Triggers success notification after modal closes
--]]

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NotificationManager = require(script.Parent.NotificationManager)

local GiantBuyModal = {}

-- Configuration
local GIANT_PRODUCT_ID = 3283964724

-- Get the GiantPurchaseEvent
local GiantPurchaseEvent = ReplicatedStorage:WaitForChild("GiantPurchaseEvent")

-- Create a BindableEvent for purchase success
local PurchaseSuccessEvent = Instance.new("BindableEvent")
PurchaseSuccessEvent.Name = "GiantPurchaseSuccess"
PurchaseSuccessEvent.Parent = script

function GiantBuyModal.new()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local purchaseSuccessful = false
    
    print("GiantBuyModal: Creating new modal instance")
    
    -- Create UI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GiantBuyModal"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    local modal = Instance.new("Frame")
    modal.Name = "Modal"
    modal.Size = UDim2.new(0, 400, 0, 300)
    modal.Position = UDim2.new(0.5, -200, 0.5, -150)
    modal.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    modal.BorderSizePixel = 0
    modal.Visible = false
    modal.Parent = screenGui

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = modal

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Become a Giant!"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 24
    title.Font = Enum.Font.GothamBold
    title.Parent = modal

    local description = Instance.new("TextLabel")
    description.Name = "Description"
    description.Size = UDim2.new(0.9, 0, 0, 60)
    description.Position = UDim2.new(0.05, 0, 0.2, 0)
    description.BackgroundTransparency = 1
    description.Text = "Tower over other players with 15x normal size!\nOne-time purchase of 49 Robux."
    description.TextColor3 = Color3.fromRGB(200, 200, 200)
    description.TextSize = 16
    description.Font = Enum.Font.Gotham
    description.TextWrapped = true
    description.Parent = modal

    local purchaseButton = Instance.new("TextButton")
    purchaseButton.Name = "PurchaseButton"
    purchaseButton.Size = UDim2.new(0.8, 0, 0, 50)
    purchaseButton.Position = UDim2.new(0.1, 0, 0.6, 0)
    purchaseButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    purchaseButton.Text = "Purchase for 49 R$"
    purchaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    purchaseButton.TextSize = 18
    purchaseButton.Font = Enum.Font.GothamBold
    purchaseButton.Parent = modal

    local purchaseCorner = Instance.new("UICorner")
    purchaseCorner.CornerRadius = UDim.new(0, 8)
    purchaseCorner.Parent = purchaseButton

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 10)
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeButton.TextSize = 24
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = modal

    -- Animation settings
    local fadeInInfo = TweenInfo.new(
        0.3,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )

    -- Methods
    local function showModal()
        print("GiantBuyModal: Showing modal for", player.Name)
        purchaseSuccessful = false  -- Reset flag when showing modal
        modal.Visible = true
        modal.BackgroundTransparency = 1
        modal.Position = UDim2.new(0.5, -200, 0.6, -150)
        
        local fadeIn = TweenService:Create(modal, fadeInInfo, {
            BackgroundTransparency = 0,
            Position = UDim2.new(0.5, -200, 0.5, -150)
        })
        fadeIn:Play()
    end

    local function hideModal()
        print("GiantBuyModal: Hiding modal")
        local fadeOut = TweenService:Create(modal, fadeInInfo, {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.5, -200, 0.4, -150)
        })
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            modal.Visible = false
            if purchaseSuccessful then
                print("GiantBuyModal: Purchase was successful, firing success event")
                PurchaseSuccessEvent:Fire()
                purchaseSuccessful = false
            end
        end)
    end

    -- Set up purchase handling
    local function onPurchaseSuccess()
        print("GiantBuyModal: Purchase successful for", player.Name)
        print("GiantBuyModal: Firing GiantPurchaseEvent")
        GiantPurchaseEvent:FireServer()
        purchaseSuccessful = true
        print("GiantBuyModal: Set purchaseSuccessful to true")
        hideModal()
    end

    -- Connect button events
    purchaseButton.MouseButton1Click:Connect(function()
        print("GiantBuyModal: Purchase button clicked by", player.Name)
        hideModal()  -- Hide our modal first
        MarketplaceService:PromptProductPurchase(player, GIANT_PRODUCT_ID)
    end)

    closeButton.MouseButton1Click:Connect(hideModal)

    -- Connect to MarketplaceService purchase event
    MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, productId, isPurchased)
        print("GiantBuyModal: Purchase finished - userId:", userId, "productId:", productId, "isPurchased:", isPurchased)
        if userId == player.UserId and productId == GIANT_PRODUCT_ID and isPurchased then
            onPurchaseSuccess()
        end
    end)

    -- Return the public interface
    return {
        show = showModal,
        hide = hideModal
    }
end

return GiantBuyModal 