--[[
Name: LoadingScreenInit
Type: LocalScript
Location: ReplicatedFirst
Description: Initializes and shows the loading screen when the game starts, before other scripts load
Interacts With:
  - LoadingScreen: Shows the dramatic loading screen
--]]

local ReplicatedFirst = game:GetService("ReplicatedFirst")
local LoadingScreen = require(ReplicatedFirst:WaitForChild("LoadingScreen"))

-- Remove the default loading screen immediately
ReplicatedFirst:RemoveDefaultLoadingScreen()

-- Show our custom loading screen
LoadingScreen.show()

-- Let ReplicatedFirst finish loading before other scripts
game:WaitForChild("ReplicatedStorage")
game:WaitForChild("StarterGui")
game:WaitForChild("StarterPack")
game:WaitForChild("StarterPlayer") 