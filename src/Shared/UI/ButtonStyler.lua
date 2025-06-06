--[[
Name: ButtonStyler
Type: ModuleScript
Location: ReplicatedStorage
Description: Provides utility functions for styling buttons and text labels with consistent formatting
Interacts With:
  - ButtonStyleHandler: Provides styling functions for GUI elements
  - TopBarManager: Provides styling for top bar components
--]]

local ButtonStyler = {}

-- Default style configuration
ButtonStyler.DefaultStyle = {
    textColor = Color3.new(1, 1, 1),
    backgroundColor = Color3.new(0.5, 0.5, 0.5),
    strokeColor = Color3.new(0, 0, 0),
    strokeTransparency = 0,
    strokeThickness = 4,
    fontSize = 24,
    cornerRadius = UDim.new(0.2, 0),
    padding = UDim.new(0.1, 0),
    textStrokeColor = Color3.new(0, 0, 0),
    textStrokeTransparency = 1
}

-- Function to style a button with custom properties
function ButtonStyler.styleButton(button, customStyle)
    if not button:IsA("TextButton") and not button:IsA("TextLabel") then
        return
    end
    
    -- Merge custom style with defaults
    local style = table.clone(ButtonStyler.DefaultStyle)
    if customStyle then
        for key, value in pairs(customStyle) do
            style[key] = value
        end
    end
    
    -- Apply text styling
    button.TextColor3 = style.textColor
    button.TextStrokeColor3 = style.textStrokeColor
    button.TextStrokeTransparency = style.textStrokeTransparency
    button.Font = Enum.Font.GothamBlack
    button.TextSize = style.fontSize
    button.TextScaled = true
    
    -- Apply background styling
    button.BackgroundColor3 = style.backgroundColor
    button.BorderSizePixel = 0
    button.BorderMode = Enum.BorderMode.Outline
    
    -- Remove existing UI elements
    for _, className in ipairs({"UIStroke", "UICorner", "UIPadding"}) do
        local existing = button:FindFirstChild(className)
        if existing then existing:Destroy() end
    end
    
    -- Add custom border
    local stroke = Instance.new("UIStroke")
    stroke.Color = style.strokeColor
    stroke.Thickness = style.strokeThickness
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = button
    
    -- Add corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = style.cornerRadius
    corner.Parent = button
    
    -- Add padding
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = style.padding
    padding.PaddingRight = style.padding
    padding.PaddingTop = style.padding
    padding.PaddingBottom = style.padding
    padding.Parent = button
end

-- Function to apply styling to all buttons in a parent
function ButtonStyler.styleAllButtons(parent, customStyle)
    local buttons = parent:GetDescendants()
    for _, button in ipairs(buttons) do
        if button:IsA("TextButton") or button:IsA("TextLabel") then
            ButtonStyler.styleButton(button, customStyle)
        end
    end
end

return ButtonStyler 