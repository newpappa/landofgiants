--[[
Name: BuyModalsInit
Type: LocalScript
Location: StarterPlayer.StarterPlayerScripts
Description: Initializes and manages all purchase modal UIs
Interacts With:
  - GiantBuyModal: Giant transformation purchase modal
  - SpeedBuyModal: Speed boost purchase modal
  - TopBarManager: Connects purchase buttons to modals
--]]

local Players = game:GetService("Players")

-- Import modal modules
local GiantBuyModal = require(script.Parent.GiantBuyModal)
local SpeedBuyModal = require(script.Parent.SpeedBuyModal)

-- Initialize modals
local giantModal = GiantBuyModal.new()
local speedModal = SpeedBuyModal.new()

-- Export modal instances to _G for access from other scripts
_G.PurchaseModals = {
    giant = giantModal,
    speed = speedModal
    -- Add other modals here as they're created:
    -- experience = experienceModal,
} 