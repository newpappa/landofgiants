--[[
Name: XPCalculator
Type: ModuleScript
Location: ReplicatedStorage
Description: Handles XP calculations and stores XP-related constants
Interacts With:
  - XPManager: Provides XP calculation functions
--]]

local XPCalculator = {}

-- XP Constants
XPCalculator.Constants = {
    ORB_XP = 50,        -- XP gained from collecting an orb
    STOMP_XP = 100,     -- XP gained from stomping a player
    LEVELS = {          -- XP required for each level (can be expanded)
        [1] = 0,
        [2] = 1000,
        [3] = 2500,
        [4] = 5000,
        [5] = 10000
    }
}

-- Calculate level based on XP
function XPCalculator:CalculateLevel(xp)
    local level = 1
    for l, requiredXP in pairs(self.Constants.LEVELS) do
        if xp >= requiredXP then
            level = l
        else
            break
        end
    end
    return level
end

-- Calculate XP needed for next level
function XPCalculator:XPForNextLevel(currentXP)
    local currentLevel = self:CalculateLevel(currentXP)
    local nextLevel = currentLevel + 1
    
    if self.Constants.LEVELS[nextLevel] then
        return self.Constants.LEVELS[nextLevel] - currentXP
    end
    return 0 -- Max level reached
end

-- Get XP reward for an action
function XPCalculator:GetXPReward(action)
    if action == "orb" then
        return self.Constants.ORB_XP
    elseif action == "stomp" then
        return self.Constants.STOMP_XP
    end
    return 0
end

return XPCalculator 