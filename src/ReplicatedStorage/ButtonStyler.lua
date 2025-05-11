--[[
Name: ButtonStyler
Type: ModuleScript
Location: ReplicatedStorage
Description: Provides utility functions for styling buttons and text labels with consistent formatting
Interacts With:
  - ButtonStyleHandler: Provides styling functions for GUI elements
--]]

local ButtonStyler = {}

-- Function to style a button with white text and black borders
function ButtonStyler.styleButton(button)
    -- Make sure we're working with a button or text label
    if not button:IsA("TextButton") and not button:IsA("TextLabel") then
        return
    end
    
    -- Set text color to white
    button.TextColor3 = Color3.new(1, 1, 1)
    
    -- Add black stroke/border to text
    button.TextStrokeColor3 = Color3.new(0, 0, 0)
    button.TextStrokeTransparency = 0.5  -- Make the stroke 50% transparent for a thinner appearance
    
    -- Set font to bold
    button.Font = Enum.Font.GothamBlack
    
    -- Ensure text is visible and properly sized
    button.TextSize = 24
    button.TextScaled = true
    
    -- Remove default border
    button.BorderSizePixel = 0
    button.BorderMode = Enum.BorderMode.Outline
    
    -- Remove any existing UIStroke
    local existingStroke = button:FindFirstChild("UIStroke")
    if existingStroke then
        existingStroke:Destroy()
    end
    
    -- Add custom border using UIStroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(0, 0, 0)  -- Black border
    stroke.Thickness = 1  -- Border thickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = button
    
    -- Add padding around the text
    local padding = button:FindFirstChild("UIPadding")
    if not padding then
        padding = Instance.new("UIPadding")
        padding.Parent = button
    end
    
    -- Set padding on all sides (10% of the button size)
    padding.PaddingLeft = UDim.new(0.1, 0)
    padding.PaddingRight = UDim.new(0.1, 0)
    padding.PaddingTop = UDim.new(0.1, 0)
    padding.PaddingBottom = UDim.new(0.1, 0)
end

-- Function to apply styling to all buttons in a parent
function ButtonStyler.styleAllButtons(parent)
    local buttons = parent:GetDescendants()
    for _, button in ipairs(buttons) do
        if button:IsA("TextButton") or button:IsA("TextLabel") then
            ButtonStyler.styleButton(button)
        end
    end
end

return ButtonStyler 