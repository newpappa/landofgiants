--[[
Name: GrowthHandler
Type: Script
Location: ServerScriptService
Description: Handles player growth when they squash other players
Interacts With:
  - PlayerSizeCalculator: Gets growth calculations
  - SizeStateMachine: Updates size state
  - SquashEvent: Listens for squash events
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerSizeCalculator = require(ReplicatedStorage:WaitForChild("PlayerSizeCalculator"))
local SizeStateMachine = require(ReplicatedStorage:WaitForChild("SizeStateMachine"))
local SquashEvent = ReplicatedStorage:WaitForChild("SquashEvent")

print("GrowthHandler: Starting up...")

-- Handle growth after a successful squash
local function handleSquashGrowth(squashedPlayer, biggerPlayer)
    -- Get current size of the bigger player
    local currentSize = SizeStateMachine:GetPlayerScale(biggerPlayer)
    if not currentSize then
        warn("GrowthHandler: No current size found for", biggerPlayer.Name)
        return
    end
    
    -- Calculate new size
    local newScale = PlayerSizeCalculator.calculateSquashGrowth(currentSize)
    local newSizeData = PlayerSizeCalculator.getSizeData(newScale)
    print("GrowthHandler:", biggerPlayer.Name, "growing from", currentSize, "to", newScale, 
          "(Visual:", PlayerSizeCalculator.formatSizeText(currentSize), "->", 
          PlayerSizeCalculator.formatSizeText(newScale), ")")
    
    -- Update the size state (which will trigger visual updates)
    if newScale > currentSize then
        -- Only update if we actually grew (might not if at MAX_SIZE)
        SizeStateMachine:UpdatePlayerSize(biggerPlayer, newSizeData)
        
        -- Scale the character if it exists
        if biggerPlayer.Character then
            biggerPlayer.Character:ScaleTo(newScale)
        end
    end
end

-- Listen for squash events
SquashEvent.OnServerEvent:Connect(handleSquashGrowth)

print("GrowthHandler initialized!") 