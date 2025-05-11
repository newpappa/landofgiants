--[[
Name: LoadingScreen
Type: ModuleScript
Location: ReplicatedFirst
Description: Creates an absurd, dramatic loading screen with letter-by-letter reveal
Interacts With:
  - TweenService: For letter animations
--]]

local LoadingScreen = {}

local TweenService = game:GetService("TweenService")

-- Combine all our brand colors
local COLORS = {
    Color3.fromRGB(255, 105, 180), -- Pink (Giant)
    Color3.fromRGB(255, 255, 0),   -- Yellow (Size)
    Color3.fromRGB(50, 205, 50),   -- Green (Speed)
    Color3.fromRGB(255, 0, 0),     -- Red (Squashes)
    Color3.fromRGB(255, 255, 255), -- White
    Color3.fromRGB(0, 0, 0),       -- Black
}

-- Letter configuration
local LETTERS = {
    { letter = "L", color = COLORS[1] },
    { letter = "A", color = COLORS[2] },
    { letter = "N", color = COLORS[3] },
    { letter = "D", color = COLORS[4] },
    { letter = " ", color = COLORS[5] },
    { letter = "O", color = COLORS[1] },
    { letter = "F", color = COLORS[2] },
    { letter = " ", color = COLORS[5] },
    { letter = "G", color = COLORS[3] },
    { letter = "I", color = COLORS[4] },
    { letter = "A", color = COLORS[1] },
    { letter = "N", color = COLORS[2] },
    { letter = "T", color = COLORS[3] },
    { letter = "S", color = COLORS[4] }
}

-- Animation configurations
local LETTER_APPEAR_DURATION = 0.2
local LETTER_DELAY = 0.15
local FINAL_SCALE_DURATION = 0.5
local FINAL_SCALE_MULTIPLIER = 1.5
local HOLD_DURATION = 2.5  -- Time to hold after all letters appear

function LoadingScreen.show()
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create the main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LoadingScreen"
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 999999
    screenGui.ResetOnSpawn = false
    
    -- Create black background
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = COLORS[6] -- Black
    background.BorderSizePixel = 0
    background.Parent = screenGui
    
    -- Container for letters
    local letterContainer = Instance.new("Frame")
    letterContainer.Name = "LetterContainer"
    letterContainer.Size = UDim2.new(0.9, 0, 0.2, 0)
    letterContainer.Position = UDim2.new(0.5, 0, 0.4, 0)
    letterContainer.AnchorPoint = Vector2.new(0.5, 0)
    letterContainer.BackgroundTransparency = 1
    letterContainer.Parent = background
    
    -- Calculate total width needed for all letters
    local totalLetters = #LETTERS
    local letterWidth = 0.05  -- 5% of container width per letter
    local spacing = 0.02      -- 2% of container width between letters
    local totalWidth = (letterWidth * totalLetters) + (spacing * (totalLetters - 1))
    local startX = (1 - totalWidth) / 2  -- Center the entire text
    
    -- Function to create a letter
    local function createLetter(letterInfo, index)
        local letterLabel = Instance.new("TextLabel")
        letterLabel.Name = "Letter_" .. letterInfo.letter
        letterLabel.Size = UDim2.new(letterWidth, 0, 1, 0)
        -- Calculate X position for this letter
        local xPos = startX + ((letterWidth + spacing) * (index - 1))
        letterLabel.Position = UDim2.new(xPos, 0, 0, 0)
        letterLabel.Text = letterInfo.letter
        letterLabel.TextColor3 = letterInfo.color
        letterLabel.TextScaled = true
        letterLabel.Font = Enum.Font.GothamBold
        letterLabel.BackgroundTransparency = 1
        letterLabel.TextTransparency = 1
        letterLabel.TextStrokeTransparency = 0
        letterLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        letterLabel.Parent = letterContainer
        
        return letterLabel
    end
    
    -- Show the loading screen
    screenGui.Parent = playerGui
    
    -- Create and animate each letter
    local letterLabels = {}
    
    -- Function to animate letter at index
    local function animateLetter(index)
        if index > #LETTERS then return end
        
        local label = letterLabels[index]
        local appearTween = TweenService:Create(label, 
            TweenInfo.new(LETTER_APPEAR_DURATION, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { TextTransparency = 0 }
        )
        appearTween.Completed:Connect(function()
            animateLetter(index + 1)
        end)
        appearTween:Play()
    end
    
    -- Create all letters first
    for i, letterInfo in ipairs(LETTERS) do
        local label = createLetter(letterInfo, i)
        table.insert(letterLabels, label)
    end
    
    -- Start the sequence
    animateLetter(1)
    
    -- Final animation after all letters appear and hold
    task.delay(#LETTERS * LETTER_DELAY + LETTER_APPEAR_DURATION + HOLD_DURATION, function()
        -- Scale up
        local scaleUpTween = TweenService:Create(letterContainer,
            TweenInfo.new(FINAL_SCALE_DURATION, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Size = UDim2.new(0.9 * FINAL_SCALE_MULTIPLIER, 0, 0.2 * FINAL_SCALE_MULTIPLIER, 0) }
        )
        
        -- Scale down and fade out
        local scaleDownTween = TweenService:Create(letterContainer,
            TweenInfo.new(FINAL_SCALE_DURATION/2, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            { Size = UDim2.new(0, 0, 0, 0) }
        )
        
        local fadeOutTween = TweenService:Create(background,
            TweenInfo.new(FINAL_SCALE_DURATION/2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { BackgroundTransparency = 1 }
        )
        
        -- Play the sequence
        scaleUpTween:Play()
        -- Start fade out halfway through scale up
        task.delay(FINAL_SCALE_DURATION/2, function()
            scaleDownTween:Play()
            fadeOutTween:Play()
            fadeOutTween.Completed:Connect(function()
                screenGui:Destroy()
            end)
        end)
    end)
end

return LoadingScreen 