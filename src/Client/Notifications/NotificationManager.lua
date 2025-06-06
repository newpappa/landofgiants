--[[
Name: NotificationManager
Type: ModuleScript
Location: StarterPlayer.StarterPlayerScripts
Description: Manages temporary centered notifications with animations
Interacts With:
  - GiantBuyModal: Shows giant purchase success notification
  - SpeedBuyModal: Shows speed purchase success notification
--]]

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local NotificationManager = {}

-- Animation configurations
local SLIDE_DURATION = 0.3
local DISPLAY_DURATION = 2
local FADE_DURATION = 0.2

-- Notification styles
local STYLES = {
    default = {
        width = 300,
        height = 60,
        backgroundColor = Color3.fromRGB(255, 255, 0),
        textColor = Color3.fromRGB(255, 255, 255),
        textSize = 24,
        cornerRadius = UDim.new(0, 12),
        padding = 16,
        textStrokeTransparency = 0,
        textStrokeColor = Color3.fromRGB(0, 0, 0),
        displayDuration = 2
    },
    onboarding = {
        width = 600, -- Twice as wide
        height = 200, -- Tall enough for two lines
        backgroundColor = Color3.fromRGB(0, 0, 0),
        textColor = Color3.fromRGB(255, 255, 255),
        textSize = 32, -- Larger text
        cornerRadius = UDim.new(0, 20),
        padding = 24,
        textStrokeTransparency = 0,
        textStrokeColor = Color3.fromRGB(100, 100, 100), -- Softer stroke
        displayDuration = 4 -- Show longer
    }
}

-- Constants for positioning (matching TopBarManager)
local TOP_BAR_OFFSET = 10 -- TopBarManager's initial offset
local TOP_BAR_HEIGHT = 50 -- Matching TopBarManager's height
local NOTIFICATION_SPACING = 20 -- Space between top bar and notification

function NotificationManager.showNotification(message, style)
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Get style configuration
    local styleConfig = STYLES[style or "default"]
    
    -- Create notification UI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ToastNotification"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main notification frame
    local frame = Instance.new("Frame")
    frame.Name = "ToastFrame"
    frame.Size = UDim2.new(0, styleConfig.width, 0, styleConfig.height)
    frame.Position = UDim2.new(0.5, -styleConfig.width/2, 0, -styleConfig.height) -- Start above screen
    frame.BackgroundColor3 = styleConfig.backgroundColor
    frame.BackgroundTransparency = 0
    frame.ZIndex = 11
    frame.Parent = screenGui
    
    -- Add corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = styleConfig.cornerRadius
    corner.Parent = frame
    
    -- Add text
    local text = Instance.new("TextLabel")
    text.Name = "Message"
    text.Size = UDim2.new(1, -styleConfig.padding * 2, 1, -styleConfig.padding * 2)
    text.Position = UDim2.new(0, styleConfig.padding, 0, styleConfig.padding)
    text.BackgroundTransparency = 1
    text.Text = message
    text.TextColor3 = styleConfig.textColor
    text.Font = Enum.Font.GothamBold
    text.TextSize = styleConfig.textSize
    text.TextStrokeColor3 = styleConfig.textStrokeColor
    text.TextStrokeTransparency = styleConfig.textStrokeTransparency
    text.TextWrapped = true
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.TextYAlignment = Enum.TextYAlignment.Center
    text.ZIndex = 12
    text.Parent = frame
    
    -- Show animation (slide down)
    local targetY = TOP_BAR_OFFSET + TOP_BAR_HEIGHT + NOTIFICATION_SPACING
    local slideInTween = TweenService:Create(frame, TweenInfo.new(SLIDE_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -styleConfig.width/2, 0, targetY)
    })
    
    -- Fade out animation
    local fadeOutTween = TweenService:Create(frame, TweenInfo.new(FADE_DURATION, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 1
    })
    
    local textFadeOutTween = TweenService:Create(text, TweenInfo.new(FADE_DURATION, Enum.EasingStyle.Quad), {
        TextTransparency = 1,
        TextStrokeTransparency = 1
    })
    
    -- Play animation sequence
    screenGui.Parent = playerGui
    
    slideInTween:Play()
    
    task.delay(styleConfig.displayDuration, function()
        fadeOutTween:Play()
        textFadeOutTween:Play()
        
        task.delay(FADE_DURATION, function()
            screenGui:Destroy()
        end)
    end)
end

return NotificationManager 