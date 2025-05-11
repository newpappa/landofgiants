return [[
# RooftopHop Scripts Documentation

## ServerScriptService

### SquashHandler
#### SquashHandler
- **Name:** SquashHandler
- **Type:** Script
- **Location:** ServerScriptService
- **Description:** Handles player squash mechanics and collision detection

### PlayerSpawnHandler
#### PlayerSpawnHandler
- **Name:** PlayerSpawnHandler
- **Type:** Script
- **Location:** ServerScriptService
- **Description:** Handles player spawning and initial size setup

### PurchaseProcessor
#### PurchaseProcessor
- **Name:** PurchaseProcessor
- **Type:** Script
- **Location:** ServerScriptService
- **Description:** Central handler for processing all marketplace purchases

### LeaderstatsUpdater
#### LeaderstatsUpdater
- **Name:** LeaderstatsUpdater
- **Type:** Script
- **Location:** ServerScriptService
- **Description:** Creates and updates leaderstats for player size tracking

### GrowthHandler
#### GrowthHandler
- **Name:** GrowthHandler
- **Type:** Script
- **Location:** ServerScriptService
- **Description:** Handles player growth when they squash other players

### SpeedTransformationHandler
#### SpeedTransformationHandler
- **Name:** SpeedTransformationHandler
- **Type:** Script
- **Location:** ServerScriptService
- **Description:** Handles 2x speed purchases and character speed modification

### GiantTransformationHandler
#### GiantTransformationHandler
- **Name:** GiantTransformationHandler
- **Type:** Script
- **Location:** ServerScriptService
- **Description:** Handles giant transformation purchases and character scaling

## ReplicatedStorage

### PlayerSizeCalculator
#### PlayerSizeCalculator
- **Name:** PlayerSizeCalculator
- **Type:** ModuleScript
- **Location:** ReplicatedStorage
- **Description:** Handles size calculations and conversions between raw scale and visual height

### SizeStateMachine
#### SizeStateMachine
- **Name:** SizeStateMachine
- **Type:** ModuleScript
- **Location:** ReplicatedStorage
- **Description:** Manages and tracks player sizes, providing a central source of truth for size states

### SquashEffect
#### SquashEffect
- **Name:** SquashEffect
- **Type:** ModuleScript
- **Location:** ReplicatedStorage
- **Description:** Defines visual and animation configurations for squash effects

### ButtonStyler
#### ButtonStyler
- **Name:** ButtonStyler
- **Type:** ModuleScript
- **Location:** ReplicatedStorage
- **Description:** Provides utility functions for styling buttons and text labels with consistent formatting

### SoundRegistry
#### SoundRegistry
- **Name:** SoundRegistry
- **Type:** ModuleScript
- **Location:** ReplicatedStorage
- **Description:** Manages and plays sound effects for squash events

## StarterGui

### SizeDisplay
#### SizeDisplay
- **Name:** SizeDisplay
- **Type:** ModuleScript
- **Location:** StarterGui
- **Description:** Component that manages size display functionality

### TopBarManager
#### TopBarManager
- **Name:** TopBarManager
- **Type:** LocalScript
- **Location:** StarterGui
- **Description:** Manages the top bar UI layout including size display and purchase buttons


]]