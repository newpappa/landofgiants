# Module Initialization System

## Overview
Our game uses a structured module loading system that ensures modules are loaded in the correct sequence and properly initialized. The system is built around the `ModuleLoader` utility and uses Promises for asynchronous initialization.

## Core Components

### 1. ModuleLoader
- Located in `ReplicatedStorage.Shared.Core.ModuleLoader`
- Handles loading and initialization of modules from specified folders
- Supports both synchronous and asynchronous initialization
- Uses Promises for handling initialization sequence

### 2. Bootstrapper
- Located in `ServerScriptService.Server.Bootstrapper`
- Coordinates the loading sequence of all server-side modules
- Loads modules in a specific order:
  1. Core modules
  2. Orbs system
  3. Player system
  4. Economy system
  5. NPC system

### 3. EventManager
- Located in `ReplicatedStorage.Shared.Core.EventManager`
- Centralizes all RemoteEvents for client-server communication
- Handles initialization of remote events
- Provides a consistent interface for accessing events

## Script Types and Patterns

### 1. Server-Side Modules
- Located in `ServerScriptService.Server`
- Must implement the `Init()` function pattern
- Are loaded and initialized by the server bootstrapper
- Follow the module structure below

### 2. Client-Side Scripts
- Located in `StarterPlayer.StarterPlayerScripts.Client`
- Are `LocalScript`s that run directly
- Do NOT use the `Init()` pattern
- Follow a simpler pattern:
  ```lua
  --[[
  Name: ExampleClientScript
  Type: LocalScript
  Location: StarterPlayerScripts.Client.Example
  Description: Example client script
  --]]

  print("ExampleClientScript: Starting up...")
  
  -- Setup code here
  -- Event connections here
  
  print("ExampleClientScript: Initialization complete")
  ```

## Module Requirements

### 1. Module Structure
All server-side modules should follow this basic structure:
```lua
local ModuleName = {}

-- Optional: Dependencies
local Dependency1 = require(path.to.dependency1)
local Dependency2 = require(path.to.dependency2)

-- Required: Init function
function ModuleName.Init()
    -- Initialization code here
    -- Can return a Promise or direct value
end

return ModuleName
```

### 2. Initialization Function
- Every server module must implement an `Init()` function
- The `Init()` function can be synchronous or asynchronous
- If asynchronous, return a Promise
- If synchronous, return any value (will be wrapped in a Promise)

Example:
```lua
-- Synchronous initialization
function ModuleName.Init()
    -- Setup code
    return true
end

-- Asynchronous initialization
function ModuleName.Init()
    return Promise.new(function(resolve, reject)
        -- Async setup code
        resolve()
    end)
end
```

### 3. Error Handling
- Use `pcall` for critical operations
- Log errors appropriately
- Return meaningful error messages
- Handle initialization failures gracefully

### 4. Dependencies
- Declare dependencies at the top of the module
- Use `require()` for dependencies
- Handle missing dependencies gracefully
- Document dependencies in module header

## Best Practices

1. **Module Headers**
   - Include a header comment block with:
     - Name
     - Type (ModuleScript or LocalScript)
     - Location
     - Description
     - Interacts With (list of dependencies)

2. **Error Handling**
   - Use `pcall` for critical operations
   - Log errors with `warn()` or `error()`
   - Return meaningful error messages

3. **State Management**
   - Initialize state in `Init()` for server modules
   - Clean up resources when needed
   - Use attributes for persistent data

4. **Event Management**
   - Use EventManager for remote events
   - Document event usage
   - Handle event cleanup

5. **Performance**
   - Initialize heavy resources asynchronously
   - Use spatial partitioning where appropriate
   - Implement proper cleanup

## Example Module

```lua
--[[
Name: ExampleModule
Type: ModuleScript
Location: ServerScriptService.Server.Example
Description: Example module demonstrating proper initialization
Interacts With:
  - EventManager: Uses events for communication
  - ModuleLoader: Implements Init() for loading
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Dependencies
local EventManager = require(ReplicatedStorage.Shared.Core.EventManager)
local Promise = require(ReplicatedStorage.Shared.Core.Promise)

local ExampleModule = {
    _initialized = false
}

function ExampleModule.Init()
    if ExampleModule._initialized then
        return Promise.resolve()
    end

    return Promise.new(function(resolve, reject)
        local success, err = pcall(function()
            -- Initialize module
            ExampleModule._initialized = true
        end)

        if success then
            resolve()
        else
            reject(err)
        end
    end)
end

return ExampleModule
```

## Testing
- Test initialization sequence
- Verify error handling
- Check resource cleanup
- Validate event handling
- Monitor performance impact 