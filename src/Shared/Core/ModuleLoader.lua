--[[
Name: ModuleLoader
Type: ModuleScript
Location: ReplicatedStorage.Shared.Core
Description: Core utility for loading modules in a controlled sequence
Interacts With:
  - All modules that implement Init(): Handles their initialization
--]]

local Promise = require(game:GetService("ReplicatedStorage").Shared.Core.Promise)
local ModuleLoader = {}

-- Helper function to check if a value is a Promise
local function isPromise(value)
    return type(value) == "table" and type(value.andThen) == "function"
end

-- Loads all modules from a folder in sequence
function ModuleLoader.LoadFromFolder(folder)
    print("ModuleLoader: Loading from folder:", folder:GetFullName())
    local initPromises = {}
    
    -- Get all ModuleScripts in the folder
    for _, child in ipairs(folder:GetChildren()) do
        print("ModuleLoader: Found child:", child.Name, "Type:", child.ClassName)
        if child:IsA("ModuleScript") then
            print("ModuleLoader: Loading ModuleScript:", child.Name)
            local success, module = pcall(require, child)
            
            if not success then
                warn("ModuleLoader: Failed to require module:", child.Name, "\nError:", module)
                continue
            end
            
            print("ModuleLoader: Successfully required module:", child.Name)
            -- Check if module has Init function
            if type(module.Init) == "function" then
                print("ModuleLoader: Found Init() function in:", child.Name)
                local initResult = module.Init()
                
                -- Handle both Promise and non-Promise returns
                if isPromise(initResult) then
                    print("ModuleLoader: Module", child.Name, "returned a Promise")
                    table.insert(initPromises, initResult)
                else
                    print("ModuleLoader: Module", child.Name, "returned a non-Promise result")
                    -- Convert non-Promise result to Promise
                    local promise = Promise.new(function(resolve)
                        resolve(initResult)
                    end)
                    table.insert(initPromises, promise)
                end
            else
                warn("ModuleLoader: Module", child.Name, "does not implement Init() function")
            end
        end
    end
    
    print("ModuleLoader: Found", #initPromises, "modules to initialize in", folder.Name)
    
    -- If no promises to wait for, return resolved promise
    if #initPromises == 0 then
        return Promise.new(function(resolve)
            resolve()
        end)
    end
    
    -- Wait for all init promises to resolve
    return Promise.all(initPromises)
end

return ModuleLoader 