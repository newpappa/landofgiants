--[[
Name: OnboardingMessageNotification
Type: LocalScript
Location: StarterPlayer.StarterPlayerScripts
Description: Shows onboarding message shortly after spawn
Interacts With:
  - NotificationManager: Shows notifications
  - LoadingScreen: Coordinates timing with loading screen
--]]

--[[
local NotificationManager = require(script.Parent.NotificationManager)

-- Wait for loading screen (5.3s) + spawn size notification (2.5s) + small buffer
task.wait(8)

-- Show the onboarding message with the onboarding style
NotificationManager.showNotification(
    "Collect orbs to grow.\nStomp smaller players to grow faster!",
    "onboarding"
)
--]] 