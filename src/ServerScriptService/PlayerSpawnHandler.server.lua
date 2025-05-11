--[[
Name: PlayerSpawnHandler
Type: Script
Location: ServerScriptService
Description: Handles player spawning and physical size scaling
Interacts With:
  - PlayerSizeModule: Gets spawn size calculations
  - SizeStateMachine: Updates size state
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerSizeModule = require(ReplicatedStorage:WaitForChild("PlayerSizeModule"))
local SizeStateMachine = require(ReplicatedStorage:WaitForChild("SizeStateMachine"))

print("PlayerSpawnHandler: Starting up...")

-- Handle character spawning and scaling
local function handleCharacterSpawn(player, character)
    -- Get random spawn size using non-linear distribution
    local spawnSize = PlayerSizeModule.getRandomSpawnSize()
    
    print("PlayerSpawnHandler: Spawning", player.Name, "at size", spawnSize)
    
    -- Update size state first
    SizeStateMachine:UpdatePlayerSize(player, spawnSize)
    
    -- Then apply physical scaling
    character:ScaleTo(spawnSize)
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