--[[
Name: TopBarManager
Type: LocalScript
Location: StarterGui
Description: Manages the top bar UI layout including size display and purchase buttons
Interacts With:
  - ButtonStyler: Uses styling utilities
  - SizeDisplay: Manages size display component
  - PlayerSizeCalculator: Gets size formatting utilities
  - SizeStateMachine: Gets real-time size data
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ButtonStyler = require(ReplicatedStorage:WaitForChild("ButtonStyler"))
local SizeStateMachine = require(ReplicatedStorage:WaitForChild("SizeStateMachine"))

-- Constants
local TOP_BAR_HEIGHT = 50
local BUTTON_WIDTH = 200
local SPACING = 20

-- Button style configurations
local BUTTON_STYLES = {
    giant = {
        backgroundColor = Color3.fromRGB(255, 105, 180), -- Pink
        textColor = Color3.fromRGB(255, 255, 255),
        strokeColor = Color3.fromRGB(255, 255, 255),
        strokeThickness = 4,
        cornerRadius = UDim.new(0.3, 0),
        textStrokeColor = Color3.fromRGB(0, 0, 0),
        textStrokeTransparency = 0
    },
    size = {
        backgroundColor = Color3.fromRGB(255, 255, 0), -- Yellow
        textColor = Color3.fromRGB(255, 255, 255),
        strokeColor = Color3.fromRGB(255, 255, 255),
        strokeThickness = 4,
        cornerRadius = UDim.new(0.3, 0),
        textStrokeColor = Color3.fromRGB(0, 0, 0),
        textStrokeTransparency = 0
    },
    speed = {
        backgroundColor = Color3.fromRGB(50, 205, 50), -- Green
        textColor = Color3.fromRGB(255, 255, 255),
        strokeColor = Color3.fromRGB(255, 255, 255),
        strokeThickness = 4,
        cornerRadius = UDim.new(0.3, 0),
        textStrokeColor = Color3.fromRGB(0, 0, 0),
        textStrokeTransparency = 0
    }
}

-- Create the main container
local function createTopBar()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TopBar"
    screenGui.ResetOnSpawn = false
    
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 0, TOP_BAR_HEIGHT)
    container.Position = UDim2.new(0, 0, 0, 10)
    container.BackgroundTransparency = 1
    container.Parent = screenGui
    
    -- Create layout for automatic spacing
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Padding = UDim.new(0, SPACING)
    layout.Parent = container
    
    return screenGui, container
end

-- Create a button with custom styling
local function createStyledButton(name, text, style)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, BUTTON_WIDTH, 1, 0)
    button.Text = text
    button.AutoButtonColor = true
    
    -- Apply custom styling
    ButtonStyler.styleButton(button, style)
    
    return button
end

-- Function to update size display
local function updateSizeDisplay(displayLabel, player)
    local scale = SizeStateMachine:GetPlayerScale(player)
    if scale then
        local visualHeight = SizeStateMachine:GetPlayerVisualHeight(player)
        if visualHeight then
            displayLabel.Text = string.format("%d' %d\"", math.floor(visualHeight), math.floor((visualHeight % 1) * 12))
        else
            displayLabel.Text = "Size: Not Set"
        end
    else
        displayLabel.Text = "Size: Not Set"
    end
end

-- Initialize the top bar
local function init()
    local player = Players.LocalPlayer
    local screenGui, container = createTopBar()
    
    -- Create BE GIANT button (Pink)
    local giantButton = createStyledButton(
        "BeGiantButton",
        "BE GIANT",
        BUTTON_STYLES.giant
    )
    giantButton.Parent = container
    
    -- Create size display (Yellow)
    local sizeDisplay = Instance.new("TextLabel")
    sizeDisplay.Name = "SizeDisplay"
    sizeDisplay.Size = UDim2.new(0, BUTTON_WIDTH, 1, 0)
    sizeDisplay.Text = "Size: Loading..."
    ButtonStyler.styleButton(sizeDisplay, BUTTON_STYLES.size)
    sizeDisplay.Parent = container
    
    -- Initialize size display updates
    updateSizeDisplay(sizeDisplay, player)
    SizeStateMachine.OnSizeChanged.Event:Connect(function(changedPlayer)
        if changedPlayer == player then
            updateSizeDisplay(sizeDisplay, player)
        end
    end)
    
    -- Create 2X SPEED button (Green)
    local speedButton = createStyledButton(
        "SpeedButton",
        "2X SPEED",
        BUTTON_STYLES.speed
    )
    speedButton.Parent = container
    
    -- Set up button click handlers (placeholder for now)
    giantButton.MouseButton1Click:Connect(function()
        if _G.PurchaseModals and _G.PurchaseModals.giant then
            _G.PurchaseModals.giant.show()
        end
    end)
    
    speedButton.MouseButton1Click:Connect(function()
        if _G.PurchaseModals and _G.PurchaseModals.speed then
            _G.PurchaseModals.speed.show()
        end
    end)
    
    -- Parent the ScreenGui
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    return screenGui
end

-- Start the TopBarManager
init() 