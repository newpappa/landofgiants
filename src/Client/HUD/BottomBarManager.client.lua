--[[
Name: BottomBarManager
Type: LocalScript
Location: StarterGui
Description: Manages the bottom bar UI layout including squash count display
Interacts With:
  - ButtonStyler: Uses styling utilities
  - SquashTracker: Gets real-time squash count updates
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ButtonStyler = require(ReplicatedStorage.Shared.UI.ButtonStyler)
local EventManager = require(ReplicatedStorage.Shared.Core.EventManager)

-- Constants
local BOTTOM_BAR_HEIGHT = 50
local DISPLAY_WIDTH = 200
local SPACING = 20

-- Display style configuration
local DISPLAY_STYLES = {
    squashes = {
        backgroundColor = Color3.fromRGB(45, 45, 45), -- Dark slate/charcoal
        textColor = Color3.fromRGB(255, 255, 255),
        strokeColor = Color3.fromRGB(80, 80, 80), -- Slightly lighter than background for subtle border
        strokeThickness = 2,
        cornerRadius = UDim.new(0.15, 0), -- More rectangular corners
        textStrokeColor = Color3.fromRGB(0, 0, 0),
        textStrokeTransparency = 0
    }
}

-- Create the main container
local function createBottomBar()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BottomBar"
    screenGui.ResetOnSpawn = false
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 0, BOTTOM_BAR_HEIGHT)
    container.Position = UDim2.new(0, 0, 1, -BOTTOM_BAR_HEIGHT - 10) -- 10px from bottom
    container.BackgroundTransparency = 1
    container.Parent = screenGui
    
    -- Create layout for automatic spacing
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left -- Left aligned
    layout.Padding = UDim.new(0, SPACING)
    layout.Parent = container
    
    -- Add left padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, SPACING)
    padding.Parent = container
    
    return screenGui, container
end

-- Function to update squash display
local function updateSquashDisplay(displayLabel, count)
    displayLabel.Text = string.format("Squashes: %d", count)
end

-- Initialize the bottom bar
local function init()
    local player = Players.LocalPlayer
    local screenGui, container = createBottomBar()
    
    -- Create squash display
    local squashDisplay = Instance.new("TextLabel")
    squashDisplay.Name = "SquashDisplay"
    squashDisplay.Size = UDim2.new(0, DISPLAY_WIDTH, 1, 0)
    squashDisplay.Text = "Squashes: 0"
    ButtonStyler.styleButton(squashDisplay, DISPLAY_STYLES.squashes)
    squashDisplay.Parent = container
    
    -- Initialize EventManager
    EventManager:Initialize()
    
    -- Listen for squash count updates
    local SquashCountRemote = EventManager:GetEvent("SquashCount")
    SquashCountRemote.OnClientEvent:Connect(function(newCount)
        updateSquashDisplay(squashDisplay, newCount)
    end)
    
    -- Parent the ScreenGui
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    return screenGui
end

-- Start the BottomBarManager
init() 