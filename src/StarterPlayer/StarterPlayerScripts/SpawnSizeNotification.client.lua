--[[
Name: SpawnSizeNotification
Type: LocalScript
Location: StarterPlayer.StarterPlayerScripts
Description: Shows notification when players first spawn with their initial size
Interacts With:
  - NotificationManager: Shows notifications
  - SizeStateMachine: Listens for size changes to detect initial spawn
  - LoadingScreen: Waits for loading screen to finish before showing notification
  - OnboardingMessageNotification: Signals when spawn notification is complete
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local NotificationManager = require(script.Parent.NotificationManager)
local SizeStateMachine = require(ReplicatedStorage:WaitForChild("SizeStateMachine"))

print("SpawnSizeNotification: Starting up...")

-- Create event for other scripts to know when we're done
local SpawnNotificationComplete = Instance.new("BindableEvent")
SpawnNotificationComplete.Name = "SpawnNotificationComplete"
SpawnNotificationComplete.Parent = ReplicatedStorage

-- Track if we've shown the initial spawn notification
local hasShownSpawnNotification = false
local isLoadingScreenFinished = false

-- Animation timing
local LOADING_SCREEN_DURATION = 4 -- Time for loading screen animation
local LANDING_BUFFER = 1.25 -- Extra time to let player land and get oriented

-- Function to show the spawn size notification
local function showSpawnSizeNotification(visualHeight)
    if hasShownSpawnNotification then return end
    if not visualHeight then return end
    if not isLoadingScreenFinished then
        print("SpawnSizeNotification: Waiting for loading screen to finish...")
        return
    end
    
    -- Format height as feet and inches
    local feet = math.floor(visualHeight)
    local inches = math.floor((visualHeight % 1) * 12)
    local message = string.format("You are %d' %d\" big!", feet, inches)
    
    print("SpawnSizeNotification: Showing notification:", message)
    NotificationManager.showNotification(message)
    hasShownSpawnNotification = true
    
    -- Signal completion after notification duration
    task.delay(2.5, function() -- Wait for notification duration + fade
        SpawnNotificationComplete:Fire()
    end)
end

-- Store the initial size until loading screen finishes
local pendingVisualHeight = nil

-- Check initial size
local function checkInitialSize()
    local player = Players.LocalPlayer
    if not player then return end
    
    print("SpawnSizeNotification: Checking initial size")
    local visualHeight = SizeStateMachine:GetPlayerVisualHeight(player)
    if visualHeight then
        print("SpawnSizeNotification: Found initial height:", visualHeight)
        if isLoadingScreenFinished then
            showSpawnSizeNotification(visualHeight)
        else
            print("SpawnSizeNotification: Storing height until loading screen finishes")
            pendingVisualHeight = visualHeight
        end
    else
        print("SpawnSizeNotification: No initial height found, waiting for size change")
    end
end

-- Listen for size changes
print("SpawnSizeNotification: Setting up size change listener")
SizeStateMachine.OnSizeChanged.Event:Connect(function(changedPlayer, scale, visualHeight)
    if changedPlayer == Players.LocalPlayer then
        print("SpawnSizeNotification: Received size change for local player, height:", visualHeight)
        if isLoadingScreenFinished then
            showSpawnSizeNotification(visualHeight)
        else
            print("SpawnSizeNotification: Storing height until loading screen finishes")
            pendingVisualHeight = visualHeight
        end
    end
end)

-- Wait for loading screen to finish
task.spawn(function()
    print("SpawnSizeNotification: Waiting for ReplicatedFirst to finish...")
    ReplicatedFirst:RemoveDefaultLoadingScreen()
    print("SpawnSizeNotification: Waiting for loading screen animation + landing buffer:", LOADING_SCREEN_DURATION + LANDING_BUFFER, "seconds")
    task.wait(LOADING_SCREEN_DURATION + LANDING_BUFFER) -- Wait for loading screen + landing buffer
    print("SpawnSizeNotification: Loading screen and landing buffer complete")
    isLoadingScreenFinished = true
    
    -- Show any pending notification
    if pendingVisualHeight then
        print("SpawnSizeNotification: Showing pending notification after loading screen")
        showSpawnSizeNotification(pendingVisualHeight)
    end
end)

-- Check initial size after a short delay to ensure everything is loaded
task.delay(1, checkInitialSize)

print("SpawnSizeNotification: Initialization complete") 