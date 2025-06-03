--[[
Name: PlayerSpawnHandler
Type: Script
Location: ServerScriptService
Description: Handles player spawning and initial size setup
Interacts With:
  - PlayerSizeCalculator: Gets spawn size calculations
  - SizeStateMachine: Updates player sizes
  - OrbFTUCluster: Spawns initial orbs for new players
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerSizeCalculator = require(ReplicatedStorage:WaitForChild("PlayerSizeCalculator"))
local SizeStateMachine = require(ReplicatedStorage:WaitForChild("SizeStateMachine"))
local OrbFTUCluster = require(ReplicatedStorage:WaitForChild("OrbFTUCluster"))

print("PlayerSpawnHandler: Starting up...")

-- Handle character spawning and scaling
local function handleCharacterSpawn(player, character)
    -- Get random spawn size
    local sizeData = PlayerSizeCalculator.getRandomSpawnSize()
    
    print("PlayerSpawnHandler: Spawning", player.Name, "at size", sizeData.scale)
    
    -- Update size state first
    SizeStateMachine:UpdatePlayerSize(player, sizeData)
    
    -- Then apply physical scaling
    character:ScaleTo(sizeData.scale)
    
    -- Log initial walk speed
    local humanoid = character:WaitForChild("Humanoid")
    if humanoid then
        print("PlayerSpawnHandler: Initial walk speed for", player.Name, "is", humanoid.WalkSpeed)
    end
    
    -- Spawn FTU orb cluster in front of the player
    task.delay(1, function() -- Small delay to ensure character is fully loaded
        OrbFTUCluster:SpawnCluster(character)
        print("PlayerSpawnHandler: Spawned FTU orb cluster for", player.Name)
    end)
end

-- Set up player handlers
local function onPlayerAdded(player)
    print("PlayerSpawnHandler: New player joined:", player.Name)
    
    -- Handle initial spawn and respawning
    player.CharacterAdded:Connect(function(character)
        print("PlayerSpawnHandler: Character added for", player.Name) -- Debug log
        handleCharacterSpawn(player, character)
    end)
    
    -- Handle case where character already exists
    if player.Character then
        print("PlayerSpawnHandler: Player already has character:", player.Name) -- Debug log
        handleCharacterSpawn(player, player.Character)
    end
end

-- Initialize
print("PlayerSpawnHandler: Setting up player handlers...") -- Debug log
Players.PlayerAdded:Connect(onPlayerAdded)

-- Handle existing players
local existingPlayers = Players:GetPlayers()
print("PlayerSpawnHandler: Found", #existingPlayers, "existing players") -- Debug log
for _, player in ipairs(existingPlayers) do
    onPlayerAdded(player) -- Use same handler for consistency
end

print("PlayerSpawnHandler initialized!") 