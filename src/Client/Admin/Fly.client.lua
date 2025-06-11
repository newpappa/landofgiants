--[[
Name: FlyScript
Type: LocalScript
Location: StarterPlayerScripts.Client.Admin
Description: Enables flying for specified players using key controls and adjusts movement direction and speed.
--]]

print("FlyScript: Starting up...")

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local allowedPlayers = { "newpappax", "fFireFox675" }
local player = Players.LocalPlayer

print("FlyScript: Player name:", player.Name)
print("FlyScript: Is player allowed:", table.find(allowedPlayers, player.Name) ~= nil)

if not table.find(allowedPlayers, player.Name) then
	print("FlyScript: Player not allowed, exiting")
	return -- Exit script if player is not allowed
end

-- Configuration
local flySpeed = 50
local flying = false
local direction = Vector3.new(0, 0, 0)
local activeKeys = {} -- Track currently pressed keys

-- Create BodyVelocity and BodyGyro instances
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
bodyVelocity.Velocity = Vector3.new(0, 0, 0)

local bodyGyro = Instance.new("BodyGyro")
bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
bodyGyro.P = 1000
bodyGyro.D = 100

function startFlying(character)
	print("FlyScript: Attempting to start flying")
	if not character then 
		print("FlyScript: No character found")
		return 
	end
	
	local root = character:WaitForChild("HumanoidRootPart")
	if not root then 
		print("FlyScript: No HumanoidRootPart found")
		return 
	end
	
	bodyVelocity.Parent = root
	bodyGyro.Parent = root
	flying = true
	print("FlyScript: Flying enabled")
	
	-- Reset direction when starting to fly
	direction = Vector3.new(0, 0, 0)
	activeKeys = {}
end

function stopFlying()
	print("FlyScript: Stopping flying")
	bodyVelocity.Parent = nil
	bodyGyro.Parent = nil
	flying = false
	print("FlyScript: Flying disabled")
	
	-- Reset direction when stopping
	direction = Vector3.new(0, 0, 0)
	activeKeys = {}
end

-- Key mapping for movement directions
local keyDirections = {
	[Enum.KeyCode.W] = Vector3.new(0, 0, -1),
	[Enum.KeyCode.S] = Vector3.new(0, 0, 1),
	[Enum.KeyCode.A] = Vector3.new(-1, 0, 0),
	[Enum.KeyCode.D] = Vector3.new(1, 0, 0),
	[Enum.KeyCode.Space] = Vector3.new(0, 1, 0),
	[Enum.KeyCode.LeftShift] = Vector3.new(0, -1, 0)
}

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.F then
		print("FlyScript: F key pressed")
		local character = player.Character
		if not character then 
			print("FlyScript: No character found when F pressed")
			return 
		end
		
		if flying then
			stopFlying()
		else
			startFlying(character)
		end
	end
	
	-- Track movement keys
	if keyDirections[input.KeyCode] then
		activeKeys[input.KeyCode] = true
		direction = direction + keyDirections[input.KeyCode]
	end
end)

UIS.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	-- Update movement keys
	if keyDirections[input.KeyCode] then
		activeKeys[input.KeyCode] = nil
		direction = direction - keyDirections[input.KeyCode]
	end
end)

-- Handle character respawning
player.CharacterAdded:Connect(function(character)
	print("FlyScript: Character added")
	if flying then
		startFlying(character)
	end
end)

-- Update movement
RunService.RenderStepped:Connect(function()
	if not flying then return end
	
	local character = player.Character
	if not character then return end
	
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	-- Normalize direction if moving
	if direction.Magnitude > 0 then
		direction = direction.Unit
	end
	
	-- Update velocity and orientation
	bodyVelocity.Velocity = root.CFrame:VectorToWorldSpace(direction) * flySpeed
	bodyGyro.CFrame = workspace.CurrentCamera.CFrame
end)

print("FlyScript: Initialization complete") 