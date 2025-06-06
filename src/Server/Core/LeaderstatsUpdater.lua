--[[
Name: LeaderstatsUpdater
Type: ModuleScript
Location: ServerScriptService.Server.Core
Description: Creates and updates leaderstats for player size and squash tracking
Interacts With:
    - SizeStateMachine: Gets player visual height values
    - PlayerSpawnHandler: Waits for initial size to be set
    - EventManager: Gets squash count updates
--]]

local Promise = require(game:GetService("ReplicatedStorage").Shared.Core.Promise)
local LeaderstatsUpdater = {}

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SizeStateMachine = require(ReplicatedStorage.Shared.Core.SizeStateMachine)
local EventManager = require(ReplicatedStorage.Shared.Core.EventManager)

print("LeaderstatsUpdater: Module script loaded")
print("LeaderstatsUpdater: Required SizeStateMachine and EventManager")

-- Initialize EventManager
print("LeaderstatsUpdater: Initializing EventManager")
EventManager:Initialize()

-- Function to setup leaderstats for a player
local function setupLeaderstats(player)
    print("LeaderstatsUpdater: Setting up leaderstats for", player.Name)
    
    -- Create leaderstats folder if it doesn't exist
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        print("LeaderstatsUpdater: Creating new leaderstats folder for", player.Name)
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = player
        print("LeaderstatsUpdater: Created leaderstats folder for", player.Name)
    else
        print("LeaderstatsUpdater: Found existing leaderstats folder for", player.Name)
    end
    
    -- Create or get Size value
    local sizeValue = leaderstats:FindFirstChild("Size")
    if not sizeValue then
        print("LeaderstatsUpdater: Creating Size value for", player.Name)
        sizeValue = Instance.new("NumberValue")
        sizeValue.Name = "Size"
        sizeValue.Value = 0
        sizeValue.Parent = leaderstats
        print("LeaderstatsUpdater: Created Size value for", player.Name)
    else
        print("LeaderstatsUpdater: Found existing Size value for", player.Name)
    end
    
    -- Create or get Squashes value
    local squashesValue = leaderstats:FindFirstChild("Squashes")
    if not squashesValue then
        print("LeaderstatsUpdater: Creating Squashes value for", player.Name)
        squashesValue = Instance.new("NumberValue")
        squashesValue.Name = "Squashes"
        squashesValue.Value = 0
        squashesValue.Parent = leaderstats
        print("LeaderstatsUpdater: Created Squashes value for", player.Name)
    else
        print("LeaderstatsUpdater: Found existing Squashes value for", player.Name)
    end
    
    print("LeaderstatsUpdater: All leaderstats values set up for", player.Name)
    print("LeaderstatsUpdater: Current values for", player.Name, "- Size:", sizeValue.Value, "Squashes:", squashesValue.Value)
end

local function updateSizeValue(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then 
        print("LeaderstatsUpdater: No leaderstats found for", player.Name)
        return 
    end
    
    local sizeValue = leaderstats:FindFirstChild("Size")
    if not sizeValue then 
        print("LeaderstatsUpdater: No Size value found for", player.Name)
        return 
    end
    
    -- Get visual height directly from SizeStateMachine
    local visualHeight = SizeStateMachine:GetPlayerVisualHeight(player)
    if visualHeight then
        print("LeaderstatsUpdater: Updating size for", player.Name, "to", visualHeight, "feet")
        sizeValue.Value = math.round(visualHeight * 10) / 10 -- Round to 1 decimal place
    else
        print("LeaderstatsUpdater: No size data found in SizeStateMachine for", player.Name)
    end
end

-- Initialize the module
function LeaderstatsUpdater.Init()
    print("LeaderstatsUpdater: Starting Init()")
    
    -- When a player joins
    print("LeaderstatsUpdater: Setting up PlayerAdded connection")
    Players.PlayerAdded:Connect(function(player)
        print("LeaderstatsUpdater: New player joined:", player.Name)
        setupLeaderstats(player)
    end)
    
    -- Listen for size changes from SizeStateMachine
    print("LeaderstatsUpdater: Setting up size change listener")
    SizeStateMachine.OnSizeChanged.Event:Connect(function(player, newScale, newVisualHeight)
        print("LeaderstatsUpdater: Received size change event for", player.Name, "new visual height:", newVisualHeight, "feet")
        updateSizeValue(player)
    end)
    
    -- Listen for squash updates from EventManager
    print("LeaderstatsUpdater: Setting up squash count listener")
    local SquashCountEvent = EventManager:GetEvent("SquashCount")
    SquashCountEvent.OnServerEvent:Connect(function(player, newCount)
        local leaderstats = player:FindFirstChild("leaderstats")
        if not leaderstats then 
            print("LeaderstatsUpdater: No leaderstats found for", player.Name)
            return 
        end
        
        local squashesValue = leaderstats:FindFirstChild("Squashes")
        if squashesValue then
            squashesValue.Value = newCount
            print("LeaderstatsUpdater: Updated Squashes for", player.Name, "to", newCount)
        else
            print("LeaderstatsUpdater: No Squashes value found for", player.Name)
        end
    end)
    
    print("LeaderstatsUpdater: Init() complete!")
    return Promise.new(function(resolve)
        print("LeaderstatsUpdater: Resolving Init() promise")
        resolve()
    end)
end

return LeaderstatsUpdater 