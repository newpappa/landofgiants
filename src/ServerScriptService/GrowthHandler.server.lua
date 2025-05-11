--[[
Name: GrowthHandler
Type: Script
Location: ServerScriptService
Description: Handles player growth when they squash other players
Interacts With:
  - PlayerSizeModule: Gets growth calculations
  - SizeStateMachine: Updates size state
  - SquashEvent: Listens for squash events
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerSizeModule = require(ReplicatedStorage:WaitForChild("PlayerSizeModule"))
local SizeStateMachine = require(ReplicatedStorage:WaitForChild("SizeStateMachine"))
local SquashEvent = ReplicatedStorage:WaitForChild("SquashEvent")

print("GrowthHandler: Starting up...")

-- Handle growth after a successful squash
local function handleSquashGrowth(squashedPlayer, biggerPlayer)
    -- Get current size of the bigger player
    local currentSize = SizeStateMachine:GetPlayerSize(biggerPlayer)
    if not currentSize then
        warn("GrowthHandler: No current size found for", biggerPlayer.Name)
        return
    end
    
    -- Calculate new size
    local newSize = PlayerSizeModule.calculateSquashGrowth(currentSize)
    print("GrowthHandler:", biggerPlayer.Name, "growing from", currentSize, "to", newSize, 
          "(Visual:", PlayerSizeModule.formatSizeText(currentSize), "->", 
          PlayerSizeModule.formatSizeText(newSize), ")")
    
    -- Update the size state (which will trigger visual updates)
    if newSize > currentSize then
        -- Only update if we actually grew (might not if at MAX_SIZE)
        SizeStateMachine:UpdatePlayerSize(biggerPlayer, newSize)
        
        -- Scale the character if it exists
        if biggerPlayer.Character then
            biggerPlayer.Character:ScaleTo(newSize)
        end
    end
end

-- Listen for squash events
SquashEvent.OnServerEvent:Connect(handleSquashGrowth)

print("GrowthHandler initialized!") 