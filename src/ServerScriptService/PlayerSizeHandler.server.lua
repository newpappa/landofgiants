local Players = game:GetService("Players")

-- Configuration
local MIN_SIZE = 0.2    -- 1 foot tall (0.2x normal size)
local MAX_SIZE = 20     -- 100 feet tall (20x normal size)

local function getRandomSize()
	return MIN_SIZE + math.random() * (MAX_SIZE - MIN_SIZE)
end

local function setPlayerSize(player)
	local randomSize = getRandomSize()
	
	-- Wait for character to load
	local character = player.Character or player.CharacterAdded:Wait()
	print("Setting size for", player.Name, "to", randomSize)
	
	-- Scale the character
	character:ScaleTo(randomSize)
end

-- Handle new players joining
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		setPlayerSize(player)
	end)
end)

-- Handle existing players
for _, player in ipairs(Players:GetPlayers()) do
	setPlayerSize(player)
end

print("PlayerSizeHandler initialized!") 