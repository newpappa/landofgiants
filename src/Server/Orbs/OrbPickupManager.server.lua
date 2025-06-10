--[[
Name: OrbPickupManager
Type: ModuleScript
Location: ServerScriptService.Server.Orbs
Description: Handles orb collection and triggers growth
Interacts With:
  - OrbVisuals: Uses visual configurations for pickup effects
  - GrowthHandler: Triggers player growth
  - OrbSpawner: Notifies when orbs are collected
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local OrbVisuals = require(ReplicatedStorage.Shared.Orbs.OrbVisuals)
local PlayerSizeCalculator = require(ReplicatedStorage.Shared.Progression.PlayerSizeCalculator)
local SizeStateMachine = require(ReplicatedStorage.Shared.Core.SizeStateMachine)
local EventManager = require(ReplicatedStorage.Shared.Core.EventManager)

print("OrbPickupManager: Starting up...")

-- Initialize EventManager
print("OrbPickupManager: Initializing EventManager...")
EventManager:Initialize()
print("OrbPickupManager: EventManager initialized")

-- Get RemoteEvents from EventManager
local OrbPickupEvent = EventManager:GetEvent("OrbPickupEvent")
local SpeedBoostEvent = EventManager:GetEvent("SpeedBoostEvent")
print("OrbPickupManager: Found OrbPickupEvent:", OrbPickupEvent and "Yes" or "No")
print("OrbPickupManager: Found SpeedBoostEvent:", SpeedBoostEvent and "Yes" or "No")

-- Table to track active speed boosts
local activeSpeedBoosts = {}

-- Table to track orbs being processed
local processingOrbs = {}

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
    print("OrbPickupManager: Firing speed boost event for player:", player.Name)
    SpeedBoostEvent:FireClient(player, true)
    
    -- Remove speed boost after duration
    task.delay(OrbVisuals.SPEED_BOOST.duration, function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            humanoid.WalkSpeed = originalSpeed
            activeSpeedBoosts[player.UserId] = nil
            print("OrbPickupManager: Firing speed boost end event for player:", player.Name)
            SpeedBoostEvent:FireClient(player, false)
        end
    end)
end

-- Function to handle orb pickup
local function handleOrbPickup(player, orb)
    -- Check if orb is already being processed
    if processingOrbs[orb] then
        return
    end
    
    -- Mark orb as being processed
    processingOrbs[orb] = true
    
    -- Clean up processing flag when orb is destroyed
    orb.AncestryChanged:Connect(function(_, newParent)
        if not newParent then
            processingOrbs[orb] = nil
        end
    end)
    
    print("OrbPickupManager: Handling orb pickup for player:", player.Name)
    
    if not orb or not orb:IsDescendantOf(Workspace) then
        print("OrbPickupManager: Invalid orb or not in workspace")
        processingOrbs[orb] = nil
        return
    end
    
    -- Get orb data
    local growthAmount = orb:GetAttribute("GrowthAmount")
    local orbType = orb:GetAttribute("OrbType")
    
    if not orbType then
        warn("OrbPickupManager: Invalid orb data for", orb.Name)
        processingOrbs[orb] = nil
        return
    end
    
    print("OrbPickupManager: Orb type:", orbType)
    print("OrbPickupManager: Growth amount:", growthAmount)
    
    -- Get current size data
    local currentSize = SizeStateMachine:GetPlayerScale(player)
    if not currentSize then
        warn("OrbPickupManager: No current size found for", player.Name)
        processingOrbs[orb] = nil
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
        print("OrbPickupManager: Firing pickup event for player:", player.Name)
        print("OrbPickupManager: Position:", orb.Position)
        print("OrbPickupManager: Orb type:", orbType)
        print("OrbPickupManager: Feet growth:", feetGrowth)
        OrbPickupEvent:FireClient(player, player, orb.Position, orbType, feetGrowth)
    end
    
    -- Check if this is a speed boost orb
    local orbData = OrbVisuals.ORB_TYPES[orbType]
    if orbData and orbData.isSpeedBoost then
        print("OrbPickupManager: Applying speed boost for player:", player.Name)
        applySpeedBoost(player)
    end
    
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
        
        -- Check if this is an NPC
        local isNPC = false
        if not player then
            -- Check if the character has an NPCId attribute
            if character and character:GetAttribute("NPCId") then
                isNPC = true
            end
        end
        
        -- If neither player nor NPC, ignore
        if not player and not isNPC then return end
        
        -- Verify this is actually a character by checking for Humanoid
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid then return end
        
        -- Get orb data for logging
        local orbId = orb:GetAttribute("OrbId")
        local orbType = orb:GetAttribute("OrbType")
        local growthAmount = orb:GetAttribute("GrowthAmount")
        
        -- Handle pickup for both players and NPCs
        if player then
            print(string.format("OrbPickupManager: Player %s (ID: %d) collecting orb %s (Type: %s, Growth: %.2f)",
                player.Name, player.UserId, orbId, orbType, growthAmount))
            handleOrbPickup(player, orb)
        elseif isNPC then
            -- For NPCs, just destroy the orb and trigger growth
            local npcId = character:GetAttribute("NPCId")
            local currentSize = character:GetAttribute("Size") or 1
            local growthAmount = orb:GetAttribute("GrowthAmount") or 0.1
            
            -- Calculate new size
            local newSize = math.min(currentSize + growthAmount, PlayerSizeCalculator.MAX_SIZE)
            
            -- Update NPC size
            character:SetAttribute("Size", newSize)
            character:ScaleTo(newSize)
            
            -- Fire pickup event for visual effects
            OrbPickupEvent:FireAllClients(nil, orb.Position, orb:GetAttribute("OrbType"), 0)
            
            -- Remove the orb
            orb:Destroy()
            
            print(string.format("OrbPickupManager: NPC %s collecting orb %s (Type: %s, Growth: %.2f) - Size: %.2f -> %.2f",
                npcId, orbId, orbType, growthAmount, currentSize, newSize))
        end
    end)
end

-- Watch for new orbs
print("OrbPickupManager: Setting up orb folder watcher...")
local orbFolder = Workspace:WaitForChild("GrowthOrbs")
print("OrbPickupManager: Found orb folder")

orbFolder.ChildAdded:Connect(function(orb)
    if orb:IsA("BasePart") then
        print("OrbPickupManager: New orb added, setting up touch detection")
        setupOrbTouch(orb)
    end
end)

-- Set up existing orbs
print("OrbPickupManager: Setting up existing orbs...")
for _, orb in ipairs(orbFolder:GetChildren()) do
    if orb:IsA("BasePart") then
        print("OrbPickupManager: Setting up touch detection for existing orb")
        setupOrbTouch(orb)
    end
end

print("OrbPickupManager: Initialization complete")

-- Return module interface
return {
    handleOrbPickup = handleOrbPickup,
    applySpeedBoost = applySpeedBoost,
    OrbPickupEvent = OrbPickupEvent,
    SpeedBoostEvent = SpeedBoostEvent
} 