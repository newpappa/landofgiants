--[[
Name: EventManager
Type: ModuleScript
Location: ReplicatedStorage
Description: Centralizes and manages all RemoteEvents for client-server communication
Interacts With:
  - XPManager: XP update events
  - SquashTracker: Squash count events
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create events container
local EventManager = {
    Events = {},
    _initialized = false
}

-- Initialize all remote events
function EventManager:Initialize()
    if self._initialized then return end
    
    print("EventManager: Starting initialization...")
    
    -- Create remote events
    self.Events.XPUpdate = Instance.new("RemoteEvent")
    self.Events.XPUpdate.Name = "XPUpdate"
    self.Events.XPUpdate.Parent = ReplicatedStorage
    print("EventManager: Created XPUpdate event:", self.Events.XPUpdate.Name, "Parent:", self.Events.XPUpdate.Parent.Name)
    
    -- Move existing SquashCount remote here
    local existingSquashRemote = ReplicatedStorage:FindFirstChild("SquashCountRemote")
    if not existingSquashRemote then
        self.Events.SquashCount = Instance.new("RemoteEvent")
        self.Events.SquashCount.Name = "SquashCountRemote"
        self.Events.SquashCount.Parent = ReplicatedStorage
    else
        self.Events.SquashCount = existingSquashRemote
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
    if event then
        print("EventManager: Returning event:", eventName, "Name:", event.Name, "Parent:", event.Parent.Name)
    else
        warn("EventManager: Event not found:", eventName)
    end
    return event
end

return EventManager 