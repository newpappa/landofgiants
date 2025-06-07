--[[
Name: Bootstrapper
Type: Script
Location: ServerScriptService.Server.Core
Description: Coordinates the loading of all server-side modules
Interacts With:
  - ModuleLoader: Uses it to load modules in sequence
  - All server modules: Ensures they are loaded in the correct order
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Get the ModuleLoader
local Shared = ReplicatedStorage:WaitForChild("Shared")
local ModuleLoader = require(Shared:WaitForChild("Core").ModuleLoader)

-- Function to load modules from a specific folder
local function loadModuleFolder(folderName)
    local folder = ServerScriptService.Server:WaitForChild(folderName)
    print("Loading modules from:", folderName)
    return ModuleLoader.LoadFromFolder(folder)
end

-- Function to load shared core modules
local function loadSharedCoreModules()
    local coreFolder = ReplicatedStorage.Shared.Core
    print("Loading shared core modules...")
    return ModuleLoader.LoadFromFolder(coreFolder)
end

-- Main loading sequence
local function initialize()
    print("Starting server initialization...")
    
    -- Load shared core modules first
    loadSharedCoreModules()
        :andThen(function()
            print("Shared core modules loaded successfully")
            -- Load server modules in sequence
            return loadModuleFolder("Core")  -- Load core modules first (including LeaderstatsUpdater)
        end)
        :andThen(function()
            print("Core modules loaded successfully")
            return loadModuleFolder("Orbs")  -- Then load Orbs system
        end)
        :andThen(function()
            print("Orbs modules loaded successfully")
            return loadModuleFolder("Player")  -- Then load Player system
        end)
        :andThen(function()
            print("Player modules loaded successfully")
            return loadModuleFolder("Economy")  -- Then load Economy system
        end)
        :andThen(function()
            print("Economy modules loaded successfully")
            return loadModuleFolder("NPC")  -- Finally load NPC system
        end)
        :andThen(function()
            print("All server modules loaded successfully!")
        end)
        :catch(function(err)
            warn("Error loading modules:", err)
        end)
end

-- Start the initialization
initialize() 