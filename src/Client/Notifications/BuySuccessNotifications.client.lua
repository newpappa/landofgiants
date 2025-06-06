--[[
Name: BuySuccessNotifications
Type: LocalScript
Location: StarterPlayer.StarterPlayerScripts
Description: Shows success notifications when players complete purchases
Interacts With:
  - NotificationManager: Shows notifications
  - GiantBuyModal: Listens for giant purchase modal close
  - SpeedBuyModal: Listens for speed purchase modal close
  - SoundRegistry: Plays success sounds
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NotificationManager = require(script.Parent.NotificationManager)
local SoundRegistry = require(ReplicatedStorage.Shared.Audio.SoundRegistry)

print("BuySuccessNotifications: Starting up...")

-- Get success events from modals
print("BuySuccessNotifications: Waiting for modal success events...")
local EconomyFolder = script.Parent.Parent.Economy
local GiantPurchaseSuccess = EconomyFolder.GiantBuyModal:WaitForChild("GiantPurchaseSuccess")
local SpeedPurchaseSuccess = EconomyFolder.SpeedBuyModal:WaitForChild("SpeedPurchaseSuccess")
print("BuySuccessNotifications: Found modal success events")

-- Function to show notification and play sound
local function showSuccessNotification(message, style)
    print("BuySuccessNotifications: Showing notification:", message, "style:", style)
    NotificationManager.showNotification(message, style)
    SoundRegistry.playSuccessSound(game.Players.LocalPlayer.Character)
end

-- Listen for giant purchase success (after modal closes)
print("BuySuccessNotifications: Setting up giant purchase success listener")
GiantPurchaseSuccess.Event:Connect(function()
    print("BuySuccessNotifications: Received giant purchase success event")
    showSuccessNotification("You are so big. Let's go!", "giant")
end)

-- Listen for speed purchase success (after modal closes)
print("BuySuccessNotifications: Setting up speed purchase success listener")
SpeedPurchaseSuccess.Event:Connect(function()
    print("BuySuccessNotifications: Received speed purchase success event")
    showSuccessNotification("You are so fast. Let's go!", "speed")
end)

print("BuySuccessNotifications: Initialization complete") 