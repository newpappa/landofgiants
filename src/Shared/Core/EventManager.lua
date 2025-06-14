--[[
Name: EventManager
Type: ModuleScript
Location: ReplicatedStorage
Description: Centralizes and manages all RemoteEvents for client-server communication
Interacts With:
  - XPManager: XP update events
  - SquashTracker: Squash count events
  - OrbPickupManager: Orb pickup events
  - SpeedTransformationHandler: Speed boost events
  - ProximityManager: Orb tracking events
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Create events container
local EventManager = {
    Events = {},
    _initialized = false
}

-- Initialize all remote events
function EventManager:Initialize()
    if self._initialized then return end
    
    print("EventManager: Starting initialization...")
    
    -- Check if we're on the server
    local isServer = RunService:IsServer()
    
    -- Create remote events only on the server
    if isServer then
        -- Create XPUpdate event
        self.Events.XPUpdate = Instance.new("RemoteEvent")
        self.Events.XPUpdate.Name = "XPUpdate"
        self.Events.XPUpdate.Parent = ReplicatedStorage
        print("EventManager: Created XPUpdate event:", self.Events.XPUpdate.Name, "Parent:", self.Events.XPUpdate.Parent.Name)
        
        -- Create OrbPickupEvent
        self.Events.OrbPickupEvent = Instance.new("RemoteEvent")
        self.Events.OrbPickupEvent.Name = "OrbPickupEvent"
        self.Events.OrbPickupEvent.Parent = ReplicatedStorage
        print("EventManager: Created OrbPickupEvent")

        -- Create SpeedBoostEvent
        self.Events.SpeedBoostEvent = Instance.new("RemoteEvent")
        self.Events.SpeedBoostEvent.Name = "SpeedBoostEvent"
        self.Events.SpeedBoostEvent.Parent = ReplicatedStorage
        print("EventManager: Created SpeedBoostEvent")

        -- Create SquashCount event
        self.Events.SquashCount = Instance.new("RemoteEvent")
        self.Events.SquashCount.Name = "SquashCountRemote"
        self.Events.SquashCount.Parent = ReplicatedStorage
        print("EventManager: Created SquashCount event")

        -- Create NPCStateChanged event
        self.Events.NPCStateChanged = Instance.new("RemoteEvent")
        self.Events.NPCStateChanged.Name = "NPCStateChanged"
        self.Events.NPCStateChanged.Parent = ReplicatedStorage
        print("EventManager: Created NPCStateChanged event")

        -- Create OrbAdded event
        self.Events.OnOrbAdded = Instance.new("BindableEvent")
        self.Events.OnOrbAdded.Name = "OnOrbAdded"
        print("EventManager: Created OnOrbAdded event")

        -- Create OrbRemoved event
        self.Events.OnOrbRemoved = Instance.new("BindableEvent")
        self.Events.OnOrbRemoved.Name = "OnOrbRemoved"
        print("EventManager: Created OnOrbRemoved event")
    end
    
    -- Move existing SquashCount remote here
    local existingSquashRemote = ReplicatedStorage:FindFirstChild("SquashCountRemote")
    if existingSquashRemote then
        self.Events.SquashCount = existingSquashRemote
        print("EventManager: Found existing SquashCount event")
    end
    
    self._initialized = true
    print("EventManager: Initialization complete")
end

-- Get a specific remote event
function EventManager:GetEvent(eventName)
    if not self._initialized then
        print("EventManager: Auto-initializing for event request:", eventName)
        self:Initialize()
    end
    
    local event = self.Events[eventName]
    if not event then
        -- Try to find the event in ReplicatedStorage
        event = ReplicatedStorage:FindFirstChild(eventName)
        if event then
            print("EventManager: Found event in ReplicatedStorage:", eventName)
            self.Events[eventName] = event
        else
            warn("EventManager: Event not found:", eventName)
        end
    end
    
    if event then
        print("EventManager: Returning event:", eventName, "Name:", event.Name, "Parent:", event.Parent.Name)
    end
    
    return event
end

function EventManager.Init()
    return EventManager:Initialize()
end

return EventManager 