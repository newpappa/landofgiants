# NPC Implementation Plan for Land of Giants


## 1. NPC Factory System ✓
```lua
--[[
Name: NPCFactory
Type: ModuleScript
Location: ServerScriptService.Server.NPC
Description: Creates and manages NPC characters with proper scaling and behaviors
Interacts With:
  - PlayerSizeCalculator: Uses same size calculation logic as players
  - SizeStateMachine: Manages NPC size state
  - OrbPickupManager: Handles NPC orb collection
  - SquashHandler: Manages NPC squash mechanics
--]]
```

### Tasks:
- [x] Create NPC characters using R15 rigs
- [x] Implement size scaling using `PlayerSizeCalculator`
- [x] Add NPC-specific attributes (AI state, target, etc.)
- [x] Handle NPC death and cleanup
- [x] Manage NPC animations and visual effects

## 2. NPC Spawn Manager ✓
```lua
--[[
Name: NPCSpawnManager
Type: ModuleScript
Location: ServerScriptService.Server.NPC.Factory
Description: Manages NPC population and respawning
Interacts With:
  - NPCFactory: Creates new NPCs
  - NPCAIController: Assigns AI to new NPCs
  - RandomOrbPositions: Uses position management system
  - OrbPositionManager: Manages spawn position distribution
--]]
```

### Tasks:
- [x] Maintain optimal NPC population (e.g., 10-15 NPCs)
- [x] Spawn new NPCs when:
  - [x] Population drops below threshold
  - [x] Players join the game
  - [x] Map areas are empty
- [x] Handle NPC respawning with cooldown
- [x] Distribute NPCs across the map

## 3. Position Management Integration
```lua
--[[
Name: PositionManagement
Type: ModuleScript
Location: ServerScriptService.Server.NPC
Description: Extends existing position management for NPC spawning
Interacts With:
  - RandomOrbPositions: Extends for NPC position sampling
  - OrbPositionManager: Adapts for NPC position distribution
  - NPCSpawnManager: Uses unified position system
--]]
```

### Tasks:
- [x] Extend RandomOrbPositions:
  - [x] Add NPC-specific grid spacing
  - [x] Implement NPC position validation
  - [x] Add size-based position requirements
  - [x] Handle NPC movement space requirements
- [x] Adapt OrbPositionManager:
  - [x] Add NPC position type handling
  - [x] Implement NPC-specific cooldowns
  - [x] Add NPC position reservation system
  - [x] Handle NPC position recycling
- [x] Update NPCSpawnManager:
  - [x] Integrate with position management system
  - [x] Add position validation hooks
  - [x] Implement position-based spawn logic
  - [x] Add spawn area management

## 4. Animation Registry
```lua
--[[
Name: AnimationRegistry
Type: ModuleScript
Location: ServerScriptService.Server
Description: Central registry for all character animations and their configurations
Interacts With:
  - AnimationController: Provides animation data
  - NPCFactory: Registers new animations
  - PlayerFactory: Registers player animations
--]]
```

### Tasks:
- [ ] Create central registry for NPC animations
- [ ] Define animation configurations:
  - [ ] Walking/running animations
  - [ ] Orb collection animations
  - [ ] Squashing animations
  - [ ] Death animations
  - [ ] Idle animations
  - [ ] Reaction animations
- [ ] Add animation metadata:
  - [ ] Priority levels
  - [ ] Transition rules
  - [ ] Size-based variations
  - [ ] Duration and timing
- [ ] Implement animation loading system:
  - [ ] Lazy loading
  - [ ] Preloading common animations
  - [ ] Error handling
- [ ] Add animation validation and testing

## 5. Animation Controller
```lua
--[[
Name: AnimationController
Type: ModuleScript
Location: ServerScriptService.Client.Animation
Description: Manages animation playback for all characters (players and NPCs)
Interacts With:
  - AnimationRegistry: Gets animation data
  - NPCStateMachine: Receives state changes for NPCs
  - PlayerStateMachine: Receives state changes for players
--]]
```

### Tasks:
- [ ] Create unified animation controller system:
  - [ ] Animation loading and caching
  - [ ] Transition management
  - [ ] Priority handling
  - [ ] Size-based adjustments
- [ ] Implement animation playback:
  - [ ] Play/stop/pause controls
  - [ ] Speed adjustments
  - [ ] Looping management
  - [ ] Blend time control
- [ ] Add state-based animation triggers:
  - [ ] State enter/exit animations
  - [ ] State-specific animations
  - [ ] Transition animations
- [ ] Support both NPC and player animations:
  - [ ] Character type detection
  - [ ] Type-specific animations
  - [ ] Shared animation handling
- [ ] Implement performance optimizations:
  - [ ] Animation pooling
  - [ ] Distance-based quality
  - [ ] Update throttling

## 6. NPC State Machine
```lua
--[[
Name: NPCStateMachine
Type: ModuleScript
Location: ServerScriptService.Server.NPC.AI
Description: Manages NPC states and transitions
Interacts With:
  - NPCAIController: Receives AI decisions
  - NPCAnimationController: Triggers animations
  - PlayerProximityManager: Gets proximity data
--]]
```

### Tasks:
- [ ] Define core NPC states:
  - [ ] Idle
  - [ ] Wandering
  - [ ] OrbSeeking
  - [ ] PlayerHunting
  - [ ] Fleeing
  - [ ] Stunned
  - [ ] Dead
- [ ] Implement state transitions:
  - [ ] Transition conditions
  - [ ] Transition validation
  - [ ] State history
  - [ ] Cooldown management
- [ ] Add state behaviors:
  - [ ] State entry/exit actions
  - [ ] State update logic
  - [ ] State-specific parameters
- [ ] Implement state persistence:
  - [ ] State saving
  - [ ] State restoration
  - [ ] State debugging

## 7. NPC Registry
```lua
--[[
Name: NPCRegistry
Type: ModuleScript
Location: ServerScriptService.Server.NPC.Registry
Description: Central registry for all active NPCs, providing efficient lookup and management
Interacts With:
  - NPCFactory: Registers new NPCs
  - NPCAIController: Provides NPC lookup and filtering
  - PlayerProximityManager: Provides NPC data for proximity checks
--]]
```

### Tasks:
- [ ] Create central registry for active NPCs
- [ ] Implement efficient NPC lookup by:
  - [ ] ID
  - [ ] Position
  - [ ] Size range
  - [ ] State
- [ ] Add NPC metadata tracking:
  - [ ] Current state
  - [ ] Target information
  - [ ] Last known position
  - [ ] Size history
- [ ] Implement NPC filtering methods:
  - [ ] Get NPCs in radius
  - [ ] Get NPCs by size range
  - [ ] Get NPCs by state
- [ ] Add cleanup methods for removed NPCs

## 8. Player Proximity Manager
```lua
--[[
Name: PlayerProximityManager
Type: ModuleScript
Location: ServerScriptService.Server.NPC.Proximity
Description: Manages proximity detection between players and NPCs
Interacts With:
  - NPCRegistry: Gets NPC data for proximity checks
  - NPCAIController: Provides proximity data for AI decisions
--]]
```

### Tasks:
- [ ] Implement spatial partitioning for efficient proximity checks
- [ ] Create proximity detection system:
  - [ ] Player to NPC proximity
  - [ ] NPC to NPC proximity
  - [ ] Size-based threat detection
- [ ] Add proximity event system:
  - [ ] Player entered NPC range
  - [ ] Player left NPC range
  - [ ] NPC entered player range
  - [ ] NPC left player range
- [ ] Implement threat level calculation:
  - [ ] Size difference analysis
  - [ ] Distance weighting
  - [ ] Group threat assessment
- [ ] Add performance optimizations:
  - [ ] Update throttling
  - [ ] Distance-based update frequency
  - [ ] Culling for far objects

## 9. NPC AI System
```lua
--[[
Name: NPCAIController
Type: ModuleScript
Location: ServerScriptService.Server.NPC.AI
Description: Controls NPC behavior and decision making
Interacts With:
  - NPCRegistry: Gets NPC data
  - NPCStateMachine: Sends state change requests
  - PlayerProximityManager: Gets proximity data
  - OrbSpawner: Finds nearby orbs
--]]
```

### Tasks:
- [ ] Implement decision making system:
  - [ ] Target selection
  - [ ] Path planning
  - [ ] Threat assessment
  - [ ] Group coordination
- [ ] Add behavior strategies:
  - [ ] Size-based behavior selection
  - [ ] Group behavior coordination
  - [ ] Resource management
  - [ ] Risk assessment
- [ ] Implement learning and adaptation:
  - [ ] Success rate tracking
  - [ ] Strategy adjustment
  - [ ] Group behavior learning
- [ ] Add performance optimizations:
  - [ ] Decision caching
  - [ ] Update frequency control
  - [ ] Priority-based updates

## 10. Integration with Existing Systems

### Tasks:
- [ ] Modify `OrbPickupManager` to handle NPC orb collection
- [ ] Update `SquashHandler` to work with NPCs
- [ ] Add NPC size display using `OverheadSizeDisplay`
- [ ] Implement NPC growth using `GrowthHandler`

## 11. Performance Considerations

### Tasks:
- [ ] Use spatial partitioning for NPC updates
- [ ] Implement NPC culling when far from players
- [ ] Batch NPC updates to reduce server load
- [ ] Use efficient pathfinding with waypoints

## 12. NPC Behavior Details

### Tasks:
- [ ] Implement size-based behavior:
  - [ ] Small NPCs (< 5x): Focus on orb collection
  - [ ] Medium NPCs (5-10x): Balance orb collection and player hunting
  - [ ] Large NPCs (> 10x): Focus on player hunting
- [ ] Add proximity-based reactions:
  - [ ] Flee from players 2x larger
  - [ ] Hunt players 2x smaller
  - [ ] Ignore players of similar size
- [ ] Implement orb collection behavior:
  - [ ] Prioritize closest orbs
  - [ ] Avoid dangerous areas
  - [ ] Share orb locations with nearby NPCs

## 13. Visual and Audio

### Tasks:
- [ ] Add NPC-specific animations:
  - [ ] Walking/running
  - [ ] Orb collection
  - [ ] Squashing
  - [ ] Death
- [ ] Implement visual effects:
  - [ ] Growth particles
  - [ ] Squash effects
  - [ ] Death effects
- [ ] Add NPC-specific sounds:
  - [ ] Movement
  - [ ] Growth
  - [ ] Squashing
  - [ ] Death

## 14. Testing and Balancing

### Tasks:
- [ ] Test NPC behavior in various scenarios
- [ ] Balance NPC population and spawn rates
- [ ] Tune AI parameters for engaging gameplay
- [ ] Monitor server performance

## Implementation Order:
1. Folder Structure Setup ✓
2. Shared Types and Configs ✓
3. Position Management Integration
4. Animation Registry (Shared)
5. Animation Controller (Unified)
6. NPC State Machine
7. NPCRegistry
8. PlayerProximityManager
9. Basic AI System
10. Integration with Existing Systems
11. Advanced AI Behaviors
12. Visual and Audio Effects
13. Performance Optimizations
14. Testing and Balancing 