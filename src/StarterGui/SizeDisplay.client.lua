local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local PlayerSizeModule = require(game:GetService("ReplicatedStorage"):WaitForChild("PlayerSizeModule"))
local RunService = game:GetService("RunService")

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

-- Function to update the size display
local function updateSizeDisplay(character)
    if not character then return end
    
    local size = character:GetScale()
    if size then
        sizeLabel.Text = PlayerSizeModule.formatSizeText(size)
    end
end

-- Get the local player
local player = Players.LocalPlayer

-- Update for current character if it exists
if player.Character then
    updateSizeDisplay(player.Character)
end

-- Handle character spawning
player.CharacterAdded:Connect(function(character)
    updateSizeDisplay(character)
    
    -- Update continuously
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if character.Parent then -- Check if character still exists
            updateSizeDisplay(character)
        else
            connection:Disconnect() -- Clean up if character is removed
        end
    end)
end)

-- Parent the ScreenGui
screenGui.Parent = player:WaitForChild("PlayerGui") 