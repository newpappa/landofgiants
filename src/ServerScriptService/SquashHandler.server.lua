print("=== SQUASH HANDLER STARTING ===")

-- Verify we're in the correct service
if not script:IsDescendantOf(game:GetService("ServerScriptService")) then
    error("SquashHandler must be in ServerScriptService!")
end

print("Server script location verified")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for ReplicatedStorage to be available
if not ReplicatedStorage then
    ReplicatedStorage = game:WaitForChild("ReplicatedStorage", 10)
    if not ReplicatedStorage then
        error("Failed to find ReplicatedStorage!")
    end
end

print("ReplicatedStorage found")

local PlayerSizeModule = require(ReplicatedStorage:WaitForChild("PlayerSizeModule"))

print("Services and modules loaded")

-- Create the RemoteEvent for squash communication if it doesn't exist
local SquashEvent = ReplicatedStorage:FindFirstChild("SquashEvent")
if not SquashEvent then
    SquashEvent = Instance.new("RemoteEvent")
    SquashEvent.Name = "SquashEvent"
    SquashEvent.Parent = ReplicatedStorage
    print("Created new SquashEvent")
else
    print("Found existing SquashEvent")
end

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
    
    print("SQUASH! " .. topPlayer.Name .. " squashed " .. bottomPlayer.Name)
    
    -- Get the bottom player's humanoid
    local bottomChar = bottomPlayer.Character
    if not bottomChar then return end
    
    local humanoid = bottomChar:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Fire the squash event before killing the player
    SquashEvent:FireAllClients(bottomPlayer, topPlayer)
    
    -- Kill the squashed player
    humanoid.Health = 0
end

-- Set up collision detection for a player's character
local function setupCharacterCollision(character)
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

-- Handle new players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(setupCharacterCollision)
end)

-- Handle existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player.Character then
        setupCharacterCollision(player.Character)
    end
end

print("SquashHandler initialized!") 