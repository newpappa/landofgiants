--[[
Name: OverheadSizeDisplay
Type: LocalScript
Location: StarterPlayer.StarterPlayerScripts
Description: Displays player sizes above their heads in 3D space
Interacts With:
  - PlayerSizeCalculator: Gets size formatting utilities
  - SizeStateMachine: Gets real-time size data for players
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerSizeCalculator = require(ReplicatedStorage:WaitForChild("PlayerSizeCalculator"))
local SizeStateMachine = require(ReplicatedStorage:WaitForChild("SizeStateMachine"))

local DISPLAY_DISTANCE = 100 -- Increased viewing distance
local MIN_SCALE = 0.5 -- Minimum scale when far away
local MAX_SCALE = 1.2 -- Maximum scale when close

local player = Players.LocalPlayer
local overheadDisplays = {} -- Store BillboardGuis for each player

-- Add debug print for initialization
print("OverheadSizeDisplay: Starting initialization...")

local function createOverheadDisplay(character)
    print("OverheadSizeDisplay: Creating display for character:", character.Name)
    
    -- Wait for head to exist first
    local head = character:WaitForChild("Head", 8)
    if not head then 
        warn("OverheadSizeDisplay: Failed to find Head for character:", character.Name)
        return nil
    end
    print("OverheadSizeDisplay: Found Head part for", character.Name)
    
    -- Create BillboardGui
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "OverheadSizeDisplay"
    billboardGui.Size = UDim2.new(4, 0, 0.8, 0) -- Made bigger for better visibility
    billboardGui.StudsOffset = Vector3.new(0, 2, 0) -- Lowered slightly
    billboardGui.AlwaysOnTop = true
    billboardGui.MaxDistance = DISPLAY_DISTANCE
    billboardGui.SizeOffset = Vector2.new(0, 1)
    billboardGui.ExtentsOffset = Vector3.new(0, 1, 0)
    billboardGui.Adornee = head
    
    -- Create background frame for better visibility
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = billboardGui
    
    -- Add corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 0)
    corner.Parent = frame
    
    -- Create the text label
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 18 -- Increased text size
    textLabel.TextScaled = true
    textLabel.Parent = billboardGui
    
    print("OverheadSizeDisplay: Created BillboardGui for", character.Name)
    
    -- Parent to head
    billboardGui.Parent = head
    print("OverheadSizeDisplay: Parented BillboardGui to Head for", character.Name)
    
    return billboardGui
end

local function updateDisplay(otherPlayer, display)
    if not display then 
        warn("OverheadSizeDisplay: No display found for", otherPlayer.Name)
        return 
    end
    
    local visualHeight = SizeStateMachine:GetPlayerVisualHeight(otherPlayer)
    if visualHeight then
        local textLabel = display:FindFirstChild("TextLabel")
        if textLabel then
            -- Convert to feet and inches
            local feet = math.floor(visualHeight)
            local inches = math.floor((visualHeight % 1) * 12)
            local sizeText = string.format("%d' %d\"", feet, inches)
            textLabel.Text = sizeText
            print("OverheadSizeDisplay: Updated display for", otherPlayer.Name, "to", sizeText)
        else
            warn("OverheadSizeDisplay: No TextLabel found in display for", otherPlayer.Name)
        end
    else
        warn("OverheadSizeDisplay: No visual height found for", otherPlayer.Name)
    end
end

local function onPlayerAdded(otherPlayer)
    print("OverheadSizeDisplay: New player joined:", otherPlayer.Name)
    
    local function handleCharacter(character)
        if not character then 
            warn("OverheadSizeDisplay: No character found for", otherPlayer.Name)
            return 
        end
        
        print("OverheadSizeDisplay: Character loaded for", otherPlayer.Name)
        -- We'll create the display when size data arrives instead of here
    end
    
    if otherPlayer.Character then
        handleCharacter(otherPlayer.Character)
    end
    otherPlayer.CharacterAdded:Connect(handleCharacter)
end

-- Handle size changes
SizeStateMachine.OnSizeChanged.Event:Connect(function(changedPlayer, newScale, newVisualHeight)
    print("OverheadSizeDisplay: Size changed for", changedPlayer.Name, "to scale:", newScale)
    
    -- If no display exists yet, create it
    if not overheadDisplays[changedPlayer] and changedPlayer.Character then
        print("OverheadSizeDisplay: Creating new display due to size update for", changedPlayer.Name)
        local display = createOverheadDisplay(changedPlayer.Character)
        if display then
            overheadDisplays[changedPlayer] = display
            updateDisplay(changedPlayer, display)
        end
    else
        -- Update existing display
        local display = overheadDisplays[changedPlayer]
        if display then
            updateDisplay(changedPlayer, display)
        end
    end
end)

-- Handle existing players (including local player)
for _, otherPlayer in ipairs(Players:GetPlayers()) do
    onPlayerAdded(otherPlayer)
end

-- Handle new players
Players.PlayerAdded:Connect(onPlayerAdded)

-- Handle players leaving
Players.PlayerRemoving:Connect(function(otherPlayer)
    print("OverheadSizeDisplay: Player leaving:", otherPlayer.Name)
    if overheadDisplays[otherPlayer] then
        overheadDisplays[otherPlayer]:Destroy()
        overheadDisplays[otherPlayer] = nil
    end
end)

print("OverheadSizeDisplay: Initialization complete!") 