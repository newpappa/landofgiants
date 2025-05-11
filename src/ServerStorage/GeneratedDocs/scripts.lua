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

### SquashTracker
#### SquashTracker
- **Name:** SquashTracker
- **Type:** Script
- **Location:** ServerScriptService
- **Description:** Tracks and manages player squash counts

### SpeedTransformationHandler
#### SpeedTransformationHandler
- **Name:** SpeedTransformationHandler
- **Type:** Script
- **Location:** ServerScriptService
- **Description:** Handles 2x speed purchases and character speed modification. Speed boost is temporary and resets on death.

### LeaderstatsUpdater
#### LeaderstatsUpdater
- **Name:** LeaderstatsUpdater
- **Type:** Script
- **Location:** ServerScriptService
- **Description:** Creates and updates leaderstats for player size and squash tracking

### GrowthHandler
#### GrowthHandler
- **Name:** GrowthHandler
- **Type:** Script
- **Location:** ServerScriptService
- **Description:** Handles player growth when they squash other players

### PurchaseProcessor
#### PurchaseProcessor
- **Name:** PurchaseProcessor
- **Type:** Script
- **Location:** ServerScriptService
- **Description:** Central handler for processing all marketplace purchases

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
- **Description:** Manages and plays sound effects for squash events and purchase success

## StarterGui

### BottomBarManager
#### BottomBarManager
- **Name:** BottomBarManager
- **Type:** LocalScript
- **Location:** StarterGui
- **Description:** Manages the bottom bar UI layout including squash count display

### TopBarManager
#### TopBarManager
- **Name:** TopBarManager
- **Type:** LocalScript
- **Location:** StarterGui
- **Description:** Manages the top bar UI layout including size display and purchase buttons

## ReplicatedFirst

### LoadingScreenInit
#### LoadingScreenInit
- **Name:** LoadingScreenInit
- **Type:** LocalScript
- **Location:** ReplicatedFirst
- **Description:** Initializes and shows the loading screen when the game starts, before other scripts load

### LoadingScreen
#### LoadingScreen
- **Name:** LoadingScreen
- **Type:** ModuleScript
- **Location:** ReplicatedFirst
- **Description:** Creates an absurd, dramatic loading screen with letter-by-letter reveal


]]