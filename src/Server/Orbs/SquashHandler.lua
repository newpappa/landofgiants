--[[
Name: SquashHandler
Type: ModuleScript
Location: ServerScriptService.Server.Orbs
Description: Handles player squash mechanics and collision detection
Interacts With:
  - PlayerSizeCalculator: Uses player size data for squash calculations
  - SquashEvent: Fires client events for squash effects
  - GrowthHandler: Notifies for growth calculations
  - SquashTracker: Notifies for squash counting
--]]

local SquashHandler = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local Promise = require(ReplicatedStorage.Shared.Core.Promise)

print("SquashHandler: Module script loaded")

-- Create the RemoteEvent for squash communication
local SquashEvent = Instance.new("RemoteEvent")
SquashEvent.Name = "SquashEvent"
SquashEvent.Parent = ReplicatedStorage
print("SquashHandler: Created SquashEvent")

-- Create BindableEvent for server-side communication
local ServerSquashEvent = Instance.new("BindableEvent")
ServerSquashEvent.Name = "ServerSquashEvent"
print("SquashHandler: Created ServerSquashEvent")

-- Add cooldown tracking
local recentlySquashed = {} -- Table to track recently squashed players
local SQUASH_COOLDOWN = 3.5 -- Match the character removal delay

-- Get the player that owns this part's character
local function getPlayerFromPart(part)
    local character = part:FindFirstAncestorOfClass("Model")
    if character then
        return Players:GetPlayerFromCharacter(character)
    end
    return nil
end

-- Handle a potential foot-to-head squash
local function handleFootToHeadCollision(footPart, headPart)
    -- Get the players involved
    local topPlayer = getPlayerFromPart(footPart)
    local bottomPlayer = getPlayerFromPart(headPart)
    
    -- Basic validation
    if not (topPlayer and bottomPlayer) or topPlayer == bottomPlayer then
        return
    end
    
    -- Get the bottom player's character and check spawn time
    local bottomChar = bottomPlayer.Character
    if not bottomChar then return end
    
    -- Check if player was recently squashed
    if recentlySquashed[bottomPlayer.UserId] then
        return -- Skip if player was recently squashed
    end
    
    -- Check if the character has a SpawnTime value
    local spawnTime = bottomChar:GetAttribute("SpawnTime")
    if spawnTime and (os.time() - spawnTime) < 2 then -- 2 second protection
        return -- Player is still protected
    end
    
    print("SQUASH! " .. topPlayer.Name .. " squashed " .. bottomPlayer.Name)
    
    local humanoid = bottomChar:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Mark player as recently squashed
    recentlySquashed[bottomPlayer.UserId] = true
    
    -- First notify all clients about the squash for effects
    SquashEvent:FireAllClients(bottomPlayer, topPlayer)
    
    -- Then notify server-side handlers about the squash
    ServerSquashEvent:Fire(bottomPlayer, topPlayer)
    
    -- Kill the player and force character removal to ensure clean respawn
    task.spawn(function()
        humanoid.Health = 0
        -- Increased delay to ensure longest sound (3.23s) plays fully plus buffer
        task.wait(3.5) -- Changed from 2.0 to 3.5 seconds
        if bottomChar and bottomChar.Parent then
            bottomChar:Destroy()
        end
        -- Clear the recently squashed status after the cooldown
        recentlySquashed[bottomPlayer.UserId] = nil
    end)
end

-- Set up collision detection for a player's character
local function setupCharacterCollision(character)
    -- Set spawn time attribute
    character:SetAttribute("SpawnTime", os.time())
    
    -- Get the foot and set up its collision
    local rightFoot = character:WaitForChild("RightFoot", 2)
    local leftFoot = character:WaitForChild("LeftFoot", 2)
    
    if rightFoot then
        rightFoot.Touched:Connect(function(otherPart)
            if otherPart.Name == "Head" then
                handleFootToHeadCollision(rightFoot, otherPart)
            end
        end)
    end
    
    if leftFoot then
        leftFoot.Touched:Connect(function(otherPart)
            if otherPart.Name == "Head" then
                handleFootToHeadCollision(leftFoot, otherPart)
            end
        end)
    end
end

-- Initialize the module
function SquashHandler.Init()
    print("SquashHandler: Starting Init()")
    
    -- Handle new players
    Players.PlayerAdded:Connect(function(player)
        print("SquashHandler: Player added:", player.Name)
        player.CharacterAdded:Connect(function(character)
            print("SquashHandler: Character added for", player.Name)
            -- Clear any existing cooldown when character spawns
            recentlySquashed[player.UserId] = nil
            setupCharacterCollision(character)
        end)
    end)
    
    -- Handle existing players
    for _, player in ipairs(Players:GetPlayers()) do
        print("SquashHandler: Setting up existing player:", player.Name)
        if player.Character then
            setupCharacterCollision(player.Character)
        end
    end
    
    print("SquashHandler: Init() complete!")
    return Promise.new(function(resolve)
        print("SquashHandler: Resolving Init() promise")
        resolve()
    end)
end

-- Return the module interface
SquashHandler.ServerSquashEvent = ServerSquashEvent
print("SquashHandler: Module interface ready")
return SquashHandler 