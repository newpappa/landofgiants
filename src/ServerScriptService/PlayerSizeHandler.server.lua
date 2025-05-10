local Players = game:GetService("Players")
local PlayerSizeModule = require(game:GetService("ReplicatedStorage"):WaitForChild("PlayerSizeModule"))

-- Configuration
local MIN_SIZE = 1    -- Normal size
local MAX_SIZE = 10   -- 1000% bigger

local function setPlayerSize(player)
	local randomSize = PlayerSizeModule.getRandomSize()
	
	-- Wait for character to load
	local character = player.Character or player.CharacterAdded:Wait()
	
	-- Set the size by scaling all body parts
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")
	
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