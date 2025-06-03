--[[
Name: OrbPickupManager
Type: Script
Location: ServerScriptService
Description: Handles orb collection and triggers growth
Interacts With:
  - OrbVisuals: Uses visual configurations for pickup effects
  - GrowthHandler: Triggers player growth
  - OrbSpawner: Notifies when orbs are collected
  - XPManager: Awards XP for orb collection
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local OrbVisuals = require(ReplicatedStorage:WaitForChild("OrbVisuals"))
local PlayerSizeCalculator = require(ReplicatedStorage:WaitForChild("PlayerSizeCalculator"))
local SizeStateMachine = require(ReplicatedStorage:WaitForChild("SizeStateMachine"))
local XPManager = require(ServerScriptService:WaitForChild("XPManager"))

-- Create RemoteEvent for pickup effects
local OrbPickupEvent = Instance.new("RemoteEvent")
OrbPickupEvent.Name = "OrbPickupEvent"
OrbPickupEvent.Parent = ReplicatedStorage

-- Create RemoteEvent for speed boost effects
local SpeedBoostEvent = Instance.new("RemoteEvent")
SpeedBoostEvent.Name = "SpeedBoostEvent"
SpeedBoostEvent.Parent = ReplicatedStorage

-- Table to track active speed boosts
local activeSpeedBoosts = {}

-- Function to apply speed boost
local function applySpeedBoost(player)
    if not player.Character then return end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Store original walk speed
    local originalSpeed = humanoid.WalkSpeed
    activeSpeedBoosts[player.UserId] = originalSpeed
    
    -- Apply speed boost
    humanoid.WalkSpeed = originalSpeed * OrbVisuals.SPEED_BOOST.multiplier
    
    -- Fire client event for visual effects
    SpeedBoostEvent:FireClient(player, true)
    
    -- Remove speed boost after duration
    task.delay(OrbVisuals.SPEED_BOOST.duration, function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            humanoid.WalkSpeed = originalSpeed
            activeSpeedBoosts[player.UserId] = nil
            SpeedBoostEvent:FireClient(player, false)
        end
    end)
end

-- Function to handle orb pickup
local function handleOrbPickup(player, orb)
    if not orb or not orb:IsDescendantOf(Workspace) then
        return
    end
    
    -- Check if orb is already being processed (debounce)
    if orb:GetAttribute("BeingPickedUp") then
        return
    end
    orb:SetAttribute("BeingPickedUp", true)
    
    -- Get orb data
    local growthAmount = orb:GetAttribute("GrowthAmount")
    local orbType = orb:GetAttribute("OrbType")
    
    if not orbType then
        warn("OrbPickupManager: Invalid orb data for", orb.Name)
        orb:SetAttribute("BeingPickedUp", false)
        return
    end
    
    -- Get current size data
    local currentSize = SizeStateMachine:GetPlayerScale(player)
    if not currentSize then
        warn("OrbPickupManager: No current size found for", player.Name)
        orb:SetAttribute("BeingPickedUp", false)
        return
    end
    
    -- Calculate new size by directly adding the scale increment
    local newScale = currentSize + growthAmount
    
    -- Cap at MAX_SIZE and round to 2 decimal places
    newScale = math.min(math.floor(newScale * 100) / 100, PlayerSizeCalculator.MAX_SIZE)
    
    -- Always update if we're not at max size and we actually grew
    if newScale <= PlayerSizeCalculator.MAX_SIZE and newScale > currentSize then
        local newSizeData = PlayerSizeCalculator.getSizeData(newScale)
        SizeStateMachine:UpdatePlayerSize(player, newSizeData)
        
        -- Scale the character if it exists
        if player.Character then
            player.Character:ScaleTo(newScale)
        end
        
        -- Calculate and show growth in feet for user feedback
        local oldVisualHeight = PlayerSizeCalculator.getVisualHeight(currentSize)
        local newVisualHeight = PlayerSizeCalculator.getVisualHeight(newScale)
        local feetGrowth = newVisualHeight - oldVisualHeight
        
        -- Fire pickup event for effects with growth information
        OrbPickupEvent:FireAllClients(player, orb.Position, orbType, feetGrowth)
    end
    
    -- Check if this is a speed boost orb
    local orbData = OrbVisuals.ORB_TYPES[orbType]
    if orbData and orbData.isSpeedBoost then
        applySpeedBoost(player)
    end
    
    -- Award XP for any orb pickup
    XPManager:AwardXP(player, "orb")
    print("OrbPickupManager: Awarded XP for orb collection to", player.Name)
    
    -- Remove the orb
    orb:Destroy()
end

-- Set up touch detection for orbs
local function setupOrbTouch(orb)
    orb.Touched:Connect(function(hit)
        -- Get the character from the hit part
        local character = hit.Parent
        local player = game.Players:GetPlayerFromCharacter(character)
        
        -- If not found at immediate parent level, check if hit part itself is a character
        if not player then
            character = hit.Parent.Parent
            player = game.Players:GetPlayerFromCharacter(character)
        end
        
        -- Still no player found, try one more level up
        if not player then
            character = hit.Parent.Parent.Parent
            player = game.Players:GetPlayerFromCharacter(character)
        end
        
        if not player then return end
        
        -- Verify this is actually a player character by checking for Humanoid
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        handleOrbPickup(player, orb)
    end)
end

-- Watch for new orbs
local orbFolder = Workspace:WaitForChild("GrowthOrbs")

orbFolder.ChildAdded:Connect(function(orb)
    if orb:IsA("BasePart") then
        setupOrbTouch(orb)
    end
end)

-- Set up existing orbs
for _, orb in ipairs(orbFolder:GetChildren()) do
    if orb:IsA("BasePart") then
        setupOrbTouch(orb)
    end
end 