--[[
Name: SizeDisplay
Type: LocalScript
Location: StarterGui
Description: Manages the HUD display of player size information
Interacts With:
  - PlayerSizeModule: Gets size formatting utilities
  - SizeStateMachine: Gets real-time size data
  - ButtonStyler: Uses styling for HUD elements
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerSizeModule = require(ReplicatedStorage:WaitForChild("PlayerSizeModule"))
local SizeStateMachine = require(ReplicatedStorage:WaitForChild("SizeStateMachine"))

-- Create the GUI elements
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SizeDisplay"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 50)
frame.Position = UDim2.new(0.5, -100, 0, 10) -- Centered at top
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 0) -- Bright yellow
frame.BorderSizePixel = 4 -- Thicker border
frame.BorderColor3 = Color3.new(0, 0, 0) -- Black border
frame.Parent = screenGui

-- Round the corners
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0.2, 0) -- More rounded corners
uiCorner.Parent = frame

-- Add shadow effect
local uiStroke = Instance.new("UIStroke")
uiStroke.Color = Color3.new(0, 0, 0)
uiStroke.Thickness = 4
uiStroke.Parent = frame

local sizeLabel = Instance.new("TextLabel")
sizeLabel.Size = UDim2.new(1, 0, 1, 0)
sizeLabel.BackgroundTransparency = 1
sizeLabel.Font = Enum.Font.GothamBlack -- Bolder font
sizeLabel.TextColor3 = Color3.new(0, 0, 0)
sizeLabel.TextSize = 24 -- Bigger text
sizeLabel.TextStrokeTransparency = 0 -- Text outline
sizeLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
sizeLabel.Text = "Size: Loading..." -- Initial text
sizeLabel.Parent = frame

-- Get the local player
local player = Players.LocalPlayer

-- Function to update the size display
local function updateSizeDisplay()
    local size = SizeStateMachine:GetPlayerSize(player)
    print("SizeDisplay: Got size for player", player.Name, ":", size) -- Debug log
    if size then
        local formattedText = PlayerSizeModule.formatSizeText(size)
        print("SizeDisplay: Formatted text:", formattedText) -- Debug log
        sizeLabel.Text = formattedText
    else
        print("SizeDisplay: No size found for player", player.Name) -- Debug log
        sizeLabel.Text = "Size: Not Set"
    end
end

-- Update initial display
print("SizeDisplay: Running initial update") -- Debug log
updateSizeDisplay()

-- Listen for size changes
SizeStateMachine.OnSizeChanged.Event:Connect(function(changedPlayer, newSize)
    print("SizeDisplay: Size changed event received for", changedPlayer.Name, "size:", newSize) -- Debug log
    if changedPlayer == player then
        print("SizeDisplay: Updating display for local player") -- Debug log
        updateSizeDisplay()
    end
end)

-- Parent the ScreenGui
screenGui.Parent = player:WaitForChild("PlayerGui") 