--[[
Name: SquashTracker
Type: ModuleScript
Location: ServerScriptService.Server.Orbs
Description: Tracks and manages player squash counts
Interacts With:
    - SquashHandler: Receives squash events via ServerSquashEvent
    - LeaderstatsUpdater: Notifies of squash count updates
    - BottomBarManager: Updates client squash display
--]]

local SquashTracker = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Promise = require(ReplicatedStorage.Shared.Core.Promise)

print("SquashTracker: Module script loaded")

-- Create RemoteEvent for client communication
local SquashCountRemote = Instance.new("RemoteEvent")
SquashCountRemote.Name = "SquashCountRemote"
SquashCountRemote.Parent = ReplicatedStorage
print("SquashTracker: Created SquashCountRemote")

-- Create BindableEvent for communicating with LeaderstatsUpdater
local SquashCountChanged = Instance.new("BindableEvent")
SquashCountChanged.Name = "SquashCountChanged"
SquashCountChanged.Parent = script
print("SquashTracker: Created SquashCountChanged event")

-- Track active squash processing
local processingSquash = {}

-- Handle player spawns to reset squash count
local function handlePlayerAdded(player)
    print("SquashTracker: Setting up player:", player.Name)
    player.CharacterAdded:Connect(function()
        print("SquashTracker: Resetting squash count for", player.Name)
        -- Reset squash count on spawn and notify LeaderstatsUpdater
        SquashCountChanged:Fire(player, 0)
    end)
end

-- Initialize the module
function SquashTracker.Init()
    print("SquashTracker: Starting Init()")
    
    -- Set up for new players
    Players.PlayerAdded:Connect(handlePlayerAdded)
    
    -- Handle existing players
    for _, player in ipairs(Players:GetPlayers()) do
        handlePlayerAdded(player)
    end
    
    -- Get SquashHandler module and its event
    print("SquashTracker: Requiring SquashHandler")
    local SquashHandler = require(script.Parent.SquashHandler)
    local ServerSquashEvent = SquashHandler.ServerSquashEvent
    print("SquashTracker: Got ServerSquashEvent from SquashHandler")
    
    -- Listen for squash events
    ServerSquashEvent.Event:Connect(function(squashedPlayer, squashingPlayer)
        print("SquashTracker: Received squash event -", squashingPlayer.Name, "squashed", squashedPlayer.Name)
        
        -- Validate players
        if not squashedPlayer or not squashingPlayer then return end
        
        -- Create a unique key for this squash event
        local squashKey = squashedPlayer.UserId .. "_" .. os.time()
        
        -- Check if we're already processing this squash
        if processingSquash[squashKey] then 
            print("SquashTracker: Already processing this squash")
            return 
        end
        
        -- Mark this squash as being processed
        processingSquash[squashKey] = true
        
        -- Increment squash count for the squashing player
        print("SquashTracker: Incrementing squash count for", squashingPlayer.Name)
        SquashCountChanged:Fire(squashingPlayer, 1) -- 1 indicates increment
        
        -- Clear the processing flag after a short delay
        task.delay(3.5, function()
            processingSquash[squashKey] = nil
        end)
    end)
    
    SquashCountChanged.Event:Connect(function(player, action)
        -- Get current count for client update
        local currentCount = action == 0 and 0 or 
            player:FindFirstChild("leaderstats") and 
            player:FindFirstChild("leaderstats"):FindFirstChild("Squashes") and 
            player:FindFirstChild("leaderstats").Squashes.Value or 0
        
        print("SquashTracker: Updating client count for", player.Name, "to", currentCount)
        SquashCountRemote:FireClient(player, currentCount)
    end)
    
    print("SquashTracker: Init() complete!")
    return Promise.new(function(resolve)
        print("SquashTracker: Resolving Init() promise")
        resolve()
    end)
end

-- Return the module interface
SquashTracker.SquashCountChanged = SquashCountChanged
print("SquashTracker: Module interface ready")
return SquashTracker 