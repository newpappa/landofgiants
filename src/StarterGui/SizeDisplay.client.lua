--[[
Name: SizeDisplay
Type: ModuleScript
Location: StarterGui
Description: Component that manages size display functionality
Interacts With:
  - PlayerSizeCalculator: Gets size formatting utilities
  - SizeStateMachine: Gets real-time size data
  - TopBarManager: Provides display element
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerSizeCalculator = require(ReplicatedStorage:WaitForChild("PlayerSizeCalculator"))
local SizeStateMachine = require(ReplicatedStorage:WaitForChild("SizeStateMachine"))

local SizeDisplay = {}

-- Function to update the size display text
function SizeDisplay.updateDisplayText(displayLabel, player)
    local visualHeight = SizeStateMachine:GetPlayerVisualHeight(player)
    if visualHeight then
        -- Convert to feet and inches
        local feet = math.floor(visualHeight)
        local inches = math.floor((visualHeight % 1) * 12)
        displayLabel.Text = string.format("SIZE: %d' %d\"", feet, inches)
    else
        displayLabel.Text = "Size: Not Set"
    end
end

-- Initialize size display functionality for a display label
function SizeDisplay.init(displayLabel)
    local player = Players.LocalPlayer
    
    -- Update initial display
    SizeDisplay.updateDisplayText(displayLabel, player)
    
    -- Listen for size changes
    SizeStateMachine.OnSizeChanged.Event:Connect(function(changedPlayer, newSize)
        if changedPlayer == player then
            SizeDisplay.updateDisplayText(displayLabel, player)
        end
    end)
end

return SizeDisplay 