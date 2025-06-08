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

-- Helper function to get module dependencies
local function getModuleDependencies(module, moduleName)
    local dependencies = {}
    
    -- Check if the module has any require statements in its environment
    for name, value in pairs(getfenv(module.Init)) do
        if type(value) == "table" and value.__type == "ModuleScript" then
            -- Only include dependencies that are in the same folder
            if value.Parent and value.Parent == module.Parent then
                local depName = value.Name
                if depName and depName ~= moduleName then
                    table.insert(dependencies, depName)
                end
            end
        end
    end
    
    return dependencies
end

-- Loads all modules from a folder in sequence
function ModuleLoader.LoadFromFolder(folder)
    print("ModuleLoader: Starting to load from folder:", folder:GetFullName())
    local modules = {}
    local initPromises = {}
    
    -- First pass: collect all modules
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
            if type(module.Init) == "function" then
                print("ModuleLoader: Found Init() function in:", child.Name)
                modules[child.Name] = {
                    module = module,
                    moduleScript = child,
                    dependencies = getModuleDependencies(module, child.Name),
                    initialized = false
                }
            else
                warn("ModuleLoader: Module", child.Name, "does not implement Init() function")
            end
        end
    end
    
    -- Second pass: initialize modules in dependency order
    local function initializeModule(moduleName)
        local moduleInfo = modules[moduleName]
        if not moduleInfo then
            print("ModuleLoader: Module", moduleName, "not found in module list")
            return Promise.resolve(true)
        end
        
        if moduleInfo.initialized then
            print("ModuleLoader: Module", moduleName, "already initialized, skipping")
            return Promise.resolve(true)
        end
        
        -- Initialize dependencies first
        local dependencyPromises = {}
        for _, dep in ipairs(moduleInfo.dependencies) do
            if modules[dep] and not modules[dep].initialized then
                table.insert(dependencyPromises, initializeModule(dep))
            end
        end
        
        -- Wait for all dependencies to complete
        return Promise.all(dependencyPromises):andThen(function()
            print("ModuleLoader: Initializing module:", moduleName)
            local initResult = moduleInfo.module.Init()
            
            if isPromise(initResult) then
                print("ModuleLoader: Module", moduleName, "returned a Promise")
                return initResult:andThen(function()
                    moduleInfo.initialized = true
                    print("ModuleLoader: Module", moduleName, "initialization complete")
                    return true
                end):catch(function(err)
                    warn("ModuleLoader: Error initializing module", moduleName, ":", err)
                    return false
                end)
            else
                print("ModuleLoader: Module", moduleName, "returned a non-Promise result")
                moduleInfo.initialized = true
                print("ModuleLoader: Module", moduleName, "initialization complete")
                return Promise.resolve(true)
            end
        end):catch(function(err)
            warn("ModuleLoader: Error in dependency chain for", moduleName, ":", err)
            return false
        end)
    end
    
    -- Initialize all modules
    local initPromises = {}
    for moduleName, moduleInfo in pairs(modules) do
        if not moduleInfo.initialized then
            table.insert(initPromises, initializeModule(moduleName))
        else
            print("ModuleLoader: Module", moduleName, "already initialized before ModuleLoader")
        end
    end
    
    print("ModuleLoader: Found", #initPromises, "modules to initialize in", folder.Name)
    
    -- If no promises to wait for, return resolved promise
    if #initPromises == 0 then
        print("ModuleLoader: No modules to initialize in", folder.Name)
        return Promise.resolve(true)
    end
    
    -- Wait for all init promises to resolve
    print("ModuleLoader: Waiting for", #initPromises, "modules to initialize in", folder.Name)
    return Promise.all(initPromises):andThen(function(results)
        local allSuccess = true
        for i, success in ipairs(results) do
            if not success then
                allSuccess = false
                break
            end
        end
        
        if allSuccess then
            print("ModuleLoader: All modules initialized successfully in", folder.Name)
        else
            warn("ModuleLoader: Some modules failed to initialize in", folder.Name)
        end
        return allSuccess
    end):catch(function(err)
        warn("ModuleLoader: Error initializing modules in", folder.Name, ":", err)
        return false
    end)
end

function ModuleLoader.Init()
    return true
end

return ModuleLoader 