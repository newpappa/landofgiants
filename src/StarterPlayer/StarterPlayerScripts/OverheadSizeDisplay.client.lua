--[[
Name: OverheadSizeDisplay
Type: LocalScript
Location: StarterPlayer.StarterPlayerScripts
Description: Displays player sizes above their heads in 3D space
Interacts With:
  - PlayerSizeModule: Gets size formatting utilities
  - SizeStateMachine: Gets real-time size data for players
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerSizeModule = require(ReplicatedStorage:WaitForChild("PlayerSizeModule"))
local SizeStateMachine = require(ReplicatedStorage:WaitForChild("SizeStateMachine"))

local DISPLAY_DISTANCE = 100 -- Increased viewing distance
local MIN_SCALE = 0.5 -- Minimum scale when far away
local MAX_SCALE = 1.2 -- Maximum scale when close

local player = Players.LocalPlayer
local overheadDisplays = {} -- Store BillboardGuis for each player

-- Add debug print for initialization
print("OverheadSizeDisplay: Starting initialization...")

local function createOverheadDisplay(character)
    -- Create BillboardGui
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "OverheadSizeDisplay"
    billboardGui.Size = UDim2.new(2, 0, 0.4, 0) -- Size relative to head size
    billboardGui.StudsOffset = Vector3.new(0, 3.5, 0) -- Positioned above default name tag
    billboardGui.AlwaysOnTop = true
    billboardGui.MaxDistance = DISPLAY_DISTANCE
    billboardGui.SizeOffset = Vector2.new(0, 1) -- Helps with distance scaling
    billboardGui.ExtentsOffset = Vector3.new(0, 1, 0) -- Better positioning relative to head
    billboardGui.Adornee = character:WaitForChild("Head")
    
    -- Create the text label
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 14
    textLabel.TextScaled = true
    textLabel.Parent = billboardGui
    
    return billboardGui
end

local function updateDisplay(otherPlayer, display)
    if not display then return end
    
    local size = SizeStateMachine:GetPlayerSize(otherPlayer)
    if size then
        local textLabel = display:FindFirstChild("TextLabel")
        if textLabel then
            -- Show only size value
            local sizeText = PlayerSizeModule.formatSizeText(size):gsub("SIZE: ", "")
            textLabel.Text = sizeText
        end
    end
end

local function onPlayerAdded(otherPlayer)
    print("OverheadSizeDisplay: New player joined:", otherPlayer.Name)
    
    local function handleCharacter(character)
        if not character then return end
        
        print("OverheadSizeDisplay: Creating display for", otherPlayer.Name)
        
        -- Wait for head to exist
        local head = character:WaitForChild("Head", 5)
        if not head then 
            warn("OverheadSizeDisplay: Failed to find Head for", otherPlayer.Name)
            return 
        end
        
        -- Create new display
        local display = createOverheadDisplay(character)
        overheadDisplays[otherPlayer] = display
        display.Parent = head
        
        -- Initial update
        task.delay(0.1, function() -- Small delay to ensure size is set
            updateDisplay(otherPlayer, display)
        end)
    end
    
    if otherPlayer.Character then
        handleCharacter(otherPlayer.Character)
    end
    otherPlayer.CharacterAdded:Connect(handleCharacter)
end

-- Handle size changes
SizeStateMachine.OnSizeChanged.Event:Connect(function(changedPlayer, newSize)
    local display = overheadDisplays[changedPlayer]
    if display then
        updateDisplay(changedPlayer, display)
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