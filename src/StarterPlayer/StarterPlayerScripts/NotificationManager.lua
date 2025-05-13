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

-- Style configurations matching TopBarManager
local NOTIFICATION_STYLES = {
    giant = {
        backgroundColor = Color3.fromRGB(255, 105, 180), -- Pink
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
    },
    size = {
        backgroundColor = Color3.fromRGB(255, 255, 0), -- Yellow
        textColor = Color3.fromRGB(255, 255, 255),
        strokeColor = Color3.fromRGB(255, 255, 255),
        strokeThickness = 4,
        cornerRadius = UDim.new(0.3, 0),
        textStrokeColor = Color3.fromRGB(0, 0, 0),
        textStrokeTransparency = 0
    }
}

-- Animation configurations
local SHOW_DURATION = 0.3
local DISPLAY_DURATION = 2
local HIDE_DURATION = 0.3

function NotificationManager.showNotification(message, style)
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create notification UI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "NotificationGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local frame = Instance.new("Frame")
    frame.Name = "NotificationFrame"
    frame.Size = UDim2.new(0, 300, 0, 80)
    frame.Position = UDim2.new(0.5, -150, 0.5, -40)
    frame.BackgroundColor3 = NOTIFICATION_STYLES[style].backgroundColor
    frame.BackgroundTransparency = 0
    frame.ZIndex = 10
    frame.Parent = screenGui
    
    -- Add corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = NOTIFICATION_STYLES[style].cornerRadius
    corner.Parent = frame
    
    -- Add stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = NOTIFICATION_STYLES[style].strokeColor
    stroke.Thickness = NOTIFICATION_STYLES[style].strokeThickness
    stroke.Parent = frame
    
    -- Add text
    local text = Instance.new("TextLabel")
    text.Name = "Message"
    text.Size = UDim2.new(1, -20, 1, -20)
    text.Position = UDim2.new(0, 10, 0, 10)
    text.BackgroundTransparency = 1
    text.Text = message
    text.TextColor3 = NOTIFICATION_STYLES[style].textColor
    text.TextStrokeColor3 = NOTIFICATION_STYLES[style].textStrokeColor
    text.TextStrokeTransparency = NOTIFICATION_STYLES[style].textStrokeTransparency
    text.Font = Enum.Font.GothamBold
    text.TextSize = 24
    text.TextWrapped = true
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.TextYAlignment = Enum.TextYAlignment.Center
    text.ZIndex = 11
    text.Parent = frame
    
    -- Initial state
    frame.Size = UDim2.new(0, 300 * 0.8, 0, 80 * 0.8)
    frame.Position = UDim2.new(0.5, -150 * 0.8, 0.5, -40 * 0.8)
    frame.BackgroundTransparency = 0
    text.TextTransparency = 0
    
    -- Show animation
    local showTween = TweenService:Create(frame, TweenInfo.new(SHOW_DURATION, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 300 * 1.1, 0, 80 * 1.1),
        Position = UDim2.new(0.5, -150 * 1.1, 0.5, -40 * 1.1)
    })
    
    local normalTween = TweenService:Create(frame, TweenInfo.new(SHOW_DURATION, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(0.5, -150, 0.5, -40)
    })
    
    -- Hide animation
    local popOutTween = TweenService:Create(frame, TweenInfo.new(HIDE_DURATION/2, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 300 * 1.1, 0, 80 * 1.1),
        Position = UDim2.new(0.5, -150 * 1.1, 0.5, -40 * 1.1)
    })
    
    local hideTween = TweenService:Create(frame, TweenInfo.new(HIDE_DURATION/2, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 300 * 0.8, 0, 80 * 0.8),
        Position = UDim2.new(0.5, -150 * 0.8, 0.5, -40 * 0.8),
        BackgroundTransparency = 1
    })
    
    local textHideTween = TweenService:Create(text, TweenInfo.new(HIDE_DURATION/2, Enum.EasingStyle.Back), {
        TextTransparency = 1
    })
    
    -- Play animations sequence
    screenGui.Parent = playerGui
    
    showTween:Play()
    showTween.Completed:Connect(function()
        normalTween:Play()
        task.wait(DISPLAY_DURATION)
        
        popOutTween:Play()
        popOutTween.Completed:Connect(function()
            hideTween:Play()
            textHideTween:Play()
            hideTween.Completed:Connect(function()
                screenGui:Destroy()
            end)
        end)
    end)
end

return NotificationManager 