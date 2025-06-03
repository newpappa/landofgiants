--[[
Name: XPManager
Type: ModuleScript
Location: ServerScriptService
Description: Manages XP awards and updates for all players
Interacts With:
  - XPCalculator: Uses for XP calculations
  - EventManager: Sends XP updates to clients
  - LeaderstatsUpdater: Updates XP stats
  - OrbPickupManager: Receives orb collection events
  - SquashTracker: Receives stomp events
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- Load dependencies
local EventManager = require(ReplicatedStorage:WaitForChild("EventManager"))
local XPCalculator = require(ReplicatedStorage:WaitForChild("XPCalculator"))

-- Create XPManager
local XPManager = {}

-- Initialize EventManager and get remote
EventManager:Initialize()
local XPUpdateRemote = EventManager:GetEvent("XPUpdate")
print("XPManager: Got XP update event:", XPUpdateRemote and XPUpdateRemote.Name or "nil")

-- Function to award XP to a player
function XPManager:AwardXP(player, action)
    local xpAmount = XPCalculator:GetXPReward(action)
    if xpAmount <= 0 then return end
    
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return end
    
    local xpValue = leaderstats:FindFirstChild("XP")
    if not xpValue then return end
    
    -- Update XP
    xpValue.Value = xpValue.Value + xpAmount
    
    -- Calculate new level
    local newLevel = XPCalculator:CalculateLevel(xpValue.Value)
    local xpForNext = XPCalculator:XPForNextLevel(xpValue.Value)
    
    -- Notify client
    if XPUpdateRemote then
        print("XPManager: Firing XP update to client - XP:", xpValue.Value, "Level:", newLevel, "Next:", xpForNext)
        print("XPManager: Using event:", XPUpdateRemote.Name, "Parent:", XPUpdateRemote.Parent.Name)
        XPUpdateRemote:FireClient(player, xpValue.Value, newLevel, xpForNext)
    else
        warn("XPManager: XPUpdateRemote not found!")
    end
    
    print("XPManager: Awarded", xpAmount, "XP to", player.Name, "for", action)
end

-- Initialize XPManager
function XPManager:Initialize()
    -- Connect to squash events
    local SquashTracker = ServerScriptService:WaitForChild("SquashTracker")
    local SquashCountChanged = SquashTracker:WaitForChild("SquashCountChanged")
    
    SquashCountChanged.Event:Connect(function(player, action)
        if action ~= 0 then  -- Ignore reset events (action = 0)
            self:AwardXP(player, "stomp")
        end
    end)
    
    print("XPManager: Initialized and connected to events")
end

-- Start initialization
XPManager:Initialize()

return XPManager 