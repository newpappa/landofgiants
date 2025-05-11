--[[
Name: ButtonStyleHandler
Type: LocalScript
Location: StarterGui
Description: Styles all buttons in the PlayerGui with consistent formatting
Interacts With:
  - ButtonStyler: Uses styling utilities to format buttons
--]]

local ButtonStyler = require(game:GetService("ReplicatedStorage"):WaitForChild("ButtonStyler"))
local Players = game:GetService("Players")

-- Function to style all buttons in PlayerGui
local function styleAllPlayerGuiButtons()
    local player = Players.LocalPlayer
    if not player then return end
    
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Style existing GUIs
    ButtonStyler.styleAllButtons(playerGui)
    
    -- Watch for new GUIs and style them
    playerGui.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("TextButton") or descendant:IsA("TextLabel") then
            ButtonStyler.styleButton(descendant)
        end
    end)
end

-- Run the styling
styleAllPlayerGuiButtons() 