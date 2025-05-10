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

local function getPlayerFromPart(part)
    print("Checking part:", part:GetFullName())
    local character = part:FindFirstAncestorOfClass("Model")
    if character then
        local player = Players:GetPlayerFromCharacter(character)
        if player then
            print("Found player:", player.Name, "from part:", part.Name)
        else
            print("No player found for character:", character.Name)
        end
        return player
    end
    print("No character found for part:", part.Name)
    return nil
end

local function isPlayerAbove(player1, player2)
    local char1, char2 = player1.Character, player2.Character
    if not (char1 and char2) then 
        print("isPlayerAbove: Missing character(s)", char1, char2)
        return false 
    end
    
    local root1 = char1:FindFirstChild("HumanoidRootPart")
    local root2 = char2:FindFirstChild("HumanoidRootPart")
    if not (root1 and root2) then 
        print("isPlayerAbove: Missing root part(s)", root1, root2)
        return false 
    end
    
    local isAbove = root1.Position.Y > root2.Position.Y
    print("Height check:", player1.Name, "Y:", root1.Position.Y, player2.Name, "Y:", root2.Position.Y, "IsAbove:", isAbove)
    return isAbove
end

local function setupCollisionForPart(part, player)
    print("Setting up collision for part:", part.Name, "of player:", player.Name)
    part.Touched:Connect(function(otherPart)
        handleCollision(part, otherPart)
    end)
end

local function handleCollision(part1, part2)
    print("Collision detected between parts:", part1:GetFullName(), "and", part2:GetFullName())
    
    -- Get players involved in collision
    local player1 = getPlayerFromPart(part1)
    local player2 = getPlayerFromPart(part2)
    
    if not (player1 and player2) then 
        print("handleCollision: Not both players", player1, player2)
        return 
    end
    
    if player1 == player2 then
        print("Same player collision, ignoring")
        return
    end
    
    print("Players involved:", player1.Name, "and", player2.Name)
    
    -- Get character sizes
    local char1, char2 = player1.Character, player2.Character
    if not (char1 and char2) then 
        print("handleCollision: Missing character(s)", char1, char2)
        return 
    end
    
    local size1 = char1:GetScale()
    local size2 = char2:GetScale()
    print("Player sizes:", player1.Name, "=", size1, player2.Name, "=", size2)
    
    -- Determine which player is bigger and if they're above
    local biggerPlayer, smallerPlayer
    if size1 > size2 then
        biggerPlayer = player1
        smallerPlayer = player2
        print("Player", player1.Name, "is bigger than", player2.Name)
    elseif size2 > size1 then
        biggerPlayer = player2
        smallerPlayer = player1
        print("Player", player2.Name, "is bigger than", player1.Name)
    else
        print("Players are same size, no squash")
        return -- Same size, no squash
    end
    
    -- Check if bigger player is above
    if not isPlayerAbove(biggerPlayer, smallerPlayer) then
        print("Bigger player", biggerPlayer.Name, "is not above smaller player", smallerPlayer.Name)
        return
    end
    
    print("SQUASH CONDITIONS MET! Bigger player", biggerPlayer.Name, "is above smaller player", smallerPlayer.Name)
    
    -- Get the smaller player's humanoid to handle death
    local smallerCharacter = smallerPlayer.Character
    if not smallerCharacter then 
        print("handleCollision: Missing smaller player character")
        return 
    end
    
    local humanoid = smallerCharacter:FindFirstChild("Humanoid")
    if not humanoid then 
        print("handleCollision: Missing humanoid")
        return 
    end
    
    -- Fire the squash event before killing the player
    print("Firing SquashEvent for", smallerPlayer.Name)
    SquashEvent:FireAllClients(smallerPlayer, biggerPlayer)
    
    -- Kill the smaller player (this will trigger respawn)
    print("Killing player", smallerPlayer.Name)
    humanoid.Health = 0
end

-- Connect collision detection to all players
Players.PlayerAdded:Connect(function(player)
    print("New player joined:", player.Name)
    player.CharacterAdded:Connect(function(character)
        print("Character added for player:", player.Name)
        
        -- Set up collision detection for multiple parts
        local partsToWatch = {"HumanoidRootPart", "Head", "UpperTorso", "LowerTorso"}
        for _, partName in ipairs(partsToWatch) do
            local part = character:WaitForChild(partName, 2)
            if part then
                setupCollisionForPart(part, player)
            else
                print("Could not find part:", partName, "for player:", player.Name)
            end
        end
    end)
end)

-- Handle existing players
for _, player in ipairs(Players:GetPlayers()) do
    print("Setting up existing player:", player.Name)
    if player.Character then
        local partsToWatch = {"HumanoidRootPart", "Head", "UpperTorso", "LowerTorso"}
        for _, partName in ipairs(partsToWatch) do
            local part = player.Character:FindFirstChild(partName)
            if part then
                setupCollisionForPart(part, player)
            else
                print("Could not find part:", partName, "for existing player:", player.Name)
            end
        end
    else
        print("No Character found for existing player:", player.Name)
    end
end

print("SquashHandler initialized!") 