--[[
Name: AnimationRegistry
Type: ModuleScript
Location: ReplicatedStorage.Shared.Core
Description: Centralized registry for all animations used in the game.
             Maintains a single source of truth for animation IDs and provides
             standardized access patterns for retrieving animations.

Key Responsibilities:
    - Provides owner-agnostic animation access
    - Uses ID-based lookups
    - Validates animation IDs
    - Manages animation metadata
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Dependencies
local Promise = require(ReplicatedStorage.Shared.Core.Promise)

-- Create the service
local AnimationRegistry = {}

-- Private state
local _initialized = false
local _initPromise = nil

-- Helper function to get table keys
local function getTableKeys(t)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end

-- Hardcoded admin list (keep in sync with AdminTools.client.lua)
local ADMINS = {
    ["newpappax"] = true,
    ["fFireFox675"] = true
}

local animationDefinitions = {
    ["anim_standing"] = {
        published = "rbxassetid://507766666",
        newpappax = "rbxassetid://507766666",
        fFireFox675 = "rbxassetid://507766666",
        metadata = {
            priority = Enum.AnimationPriority.Movement,
            looped = true,
            fadeTime = 0.2,
            npcStates = {
                "OrbSeeking",
                "PlayerHunting"
            }
        }
    },
    
    ["anim_walk"] = {
        published = "rbxassetid://180426354",
        newpappax = "rbxassetid://180426354",
        fFireFox675 = "rbxassetid://180426354",
        metadata = {
            priority = Enum.AnimationPriority.Movement,
            looped = true,
            fadeTime = 0.2,
            npcStates = {
                "OrbSeeking",
                "PlayerHunting"
            }
        }
    },
    
    ["anim_run"] = {
        published = "rbxassetid://180426354",
        newpappax = "rbxassetid://180426354",
        fFireFox675 = "rbxassetid://180426354",
        metadata = {
            priority = Enum.AnimationPriority.Movement,
            looped = true,
            fadeTime = 0.2,
            npcStates = {
                "PlayerHunting"
            }
        }
    },
    
    ["anim_slide"] = {
        published = "rbxassetid://507770677",
        newpappax = "rbxassetid://507770677",
        fFireFox675 = "rbxassetid://507770677",
        metadata = {
            priority = Enum.AnimationPriority.Movement,
            looped = false,
            fadeTime = 0.1,
            npcStates = {
                "PlayerAttack"
            }
        }
    }
}

-- Helper function to get current user's name
local function getCurrentUserName()
    if RunService:IsStudio() then
        -- In Studio, use the first player's name
        local players = Players:GetPlayers()
        if #players > 0 then
            return players[1].Name
        end
        return nil
    else
        local player = Players.LocalPlayer
        return player and player.Name or nil
    end
end

-- Helper function to get appropriate animation ID
local function getAnimationId(animationConfig)
    if not animationConfig then return nil end
    
    -- Always use published animation for now
    return animationConfig.published
end

-- Function to get animation data by ID
function AnimationRegistry.GetAnimationData(animationId)
    local config = animationDefinitions[animationId]
    if not config then
        warn("[AnimationRegistry] Animation not found:", animationId)
        return nil
    end
    return config
end

-- Function to get basic movement animation
function AnimationRegistry.GetMovementAnimation(isRunning)
    local animData = isRunning and animationDefinitions["anim_run"] or animationDefinitions["anim_walk"]
    return getAnimationId(animData), animData.metadata
end

-- Function to validate animation IDs
function AnimationRegistry.ValidateAnimationId(animationId)
    if not animationId or type(animationId) ~= "string" then
        return false
    end
    
    local config = animationDefinitions[animationId]
    if not config then
        return false
    end
    
    return true
end

function AnimationRegistry.Init()
    if _initialized then
        print("[AnimationRegistry] Already initialized, skipping")
        return Promise.resolve()
    end

    if _initPromise then
        print("[AnimationRegistry] Initialization already in progress")
        return _initPromise
    end

    _initPromise = Promise.new(function(resolve, reject)
        local success, err = pcall(function()
            print("[AnimationRegistry] Starting initialization...")
            print("[AnimationRegistry] Validating animation definitions...")
            
            -- Validate animation definitions
            for animId, animData in pairs(animationDefinitions) do
                print("[AnimationRegistry] Checking animation:", animId)
                -- Check required fields
                if not animData.published then
                    error("Missing published animation ID for: " .. animId)
                end
                
                -- Validate metadata
                if not animData.metadata then
                    error("Missing metadata for animation: " .. animId)
                end
                
                -- Validate priority
                if not animData.metadata.priority then
                    error("Missing priority for animation: " .. animId)
                end
                print("[AnimationRegistry] ✓ Animation valid:", animId)
            end
            
            _initialized = true
            print("[AnimationRegistry] ✓ Initialization complete")
            print("[AnimationRegistry] Loaded animations:", table.concat(getTableKeys(animationDefinitions), ", "))
        end)

        if success then
            resolve()
        else
            warn("[AnimationRegistry] ❌ Initialization failed:", err)
            reject(err)
        end
    end)

    return _initPromise
end

-- Function to get animation for NPC state
function AnimationRegistry.GetAnimationForNPCState(state)
    for animId, animData in pairs(animationDefinitions) do
        if animData.metadata.npcStates and table.find(animData.metadata.npcStates, state) then
            return getAnimationId(animData), animData.metadata
        end
    end
    return nil, nil
end

return AnimationRegistry 