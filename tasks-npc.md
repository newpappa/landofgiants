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

## 4. Animation Registry ✓
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
- [x] Create central registry for NPC animations
- [x] Define animation configurations:
  - [x] Walking/running animations
  - [x] Orb collection animations
  - [x] Squashing animations
  - [x] Death animations
  - [x] Idle animations
  - [x] Reaction animations
- [x] Add animation metadata:
  - [x] Priority levels
  - [x] Transition rules
  - [x] Size-based variations
  - [x] Duration and timing
- [x] Implement animation loading system:
  - [x] Lazy loading
  - [x] Preloading common animations
  - [x] Error handling
- [x] Add animation validation and testing

## 5. Animation Controller ✓
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
- [x] Create unified animation controller system:
  - [x] Animation loading and caching
  - [x] Transition management
  - [x] Priority handling
  - [x] Size-based adjustments
- [x] Implement animation playback:
  - [x] Play/stop/pause controls
  - [x] Speed adjustments
  - [x] Looping management
  - [x] Blend time control
- [x] Add state-based animation triggers:
  - [x] State enter/exit animations
  - [x] State-specific animations
  - [x] Transition animations
- [x] Support both NPC and player animations:
  - [x] Character type detection
  - [x] Type-specific animations
  - [x] Shared animation handling
- [x] Implement performance optimizations:
  - [x] Animation pooling
  - [x] Distance-based quality
  - [x] Update throttling

## 6. NPC State Machine
```lua
--[[
Name: NPCStateMachine
Type: ModuleScript
Location: ServerScriptService.Server.NPC.AI
Description: Tracks and reports NPC states. Does not make decisions about state changes.
             Enforces cooldown between state changes to create lumbering, deliberate behavior.
Interacts With:
  - NPCAIController: Receives state change requests
  - NPCAnimationController: Reports state changes for animation triggers
  - NPCRegistry: Updates NPC metadata with current state
--]]
```

### Tasks:
- [x] Define simplified NPC states:
  - [x] OrbSeeking
  - [x] PlayerHunting
  - [x] PlayerAttack
  - [x] Dead
- [x] Implement state tracking:
  - [x] Current state storage
  - [x] State change history
  - [x] State reporting methods
- [x] Add state change cooldown:
  - [x] Simple timestamp-based cooldown (5-10 seconds)
  - [x] Cooldown enforcement
  - [x] Cooldown reporting
- [x] Implement state persistence:
  - [x] State saving
  - [x] State restoration
  - [x] State debugging

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
- [x] Create central registry for active NPCs
- [x] Implement efficient NPC lookup by:
  - [x] ID
  - [x] Position
  - [x] Size (exact size value)
  - [x] State
- [x] Add NPC metadata tracking:
  - [x] Current state
  - [x] Target information
  - [x] Last known position
  - [x] Size history
- [x] Implement NPC filtering methods:
  - [x] Get NPCs in radius
  - [x] Get NPCs by size
  - [x] Get NPCs by state
- [x] Add cleanup methods for removed NPCs

## 8. Proximity Manager
```lua
--[[
Name: ProximityManager
Type: ModuleScript
Location: ServerScriptService.Server.NPC.Proximity
Description: Manages proximity detection between NPCs, players, and orbs.
             Provides spatial awareness for AI decision making and state transitions.
             Optimizes performance through spatial partitioning and update batching.

Key Responsibilities:
    - Spatial partitioning for efficient proximity checks
    - Proximity event broadcasting
    - Performance optimization through update batching

Dependencies:
    - NPCRegistry: Required for NPC tracking and metadata
    - Players Service: Required for player tracking
    - OrbManager: Required for active orb tracking

Consumers:
    - NPCAIController: Uses proximity data for AI decisions
    - NPCStateMachine: Uses proximity events for state transitions
--]]
```

### Tasks:
- [x] Implement spatial partitioning for efficient proximity checks
- [x] Create proximity detection system:
  - [x] Player to NPC proximity
  - [x] NPC to NPC proximity
  - [x] NPC to Orb proximity (using OrbManager's active orbs)
- [x] Implement orb tracking:
  - [x] Add OrbAdded/OrbRemoved events to EventManager
  - [x] Fire events from OrbManager using EventManager
  - [x] Subscribe to events in ProximityManager via EventManager
  - [x] Update spatial partitioning on orb changes
- [x] Add performance optimizations:
  - [x] Update throttling
  - [x] Distance-based update frequency
  - [x] Culling for far objects
  - [x] Batch proximity updates

## 9. NPC AI System
```lua
--[[
Name: NPCAIController
Type: ModuleScript
Location: ServerScriptService.Server.NPC.AI
Description: Controls NPC behavior and decision making based on size comparison with players
             and proximity thresholds. Implements a state machine for predictable behavior
             transitions with cooldowns to create deliberate, lumbering movement.

Key Behaviors:
    - Smaller NPCs flee from larger players
    - Larger NPCs hunt and attack smaller players
    - All NPCs seek orbs when not engaged with players
    - State changes have cooldowns to prevent erratic behavior

Distance Thresholds:
    - HUNT_START: 30 studs - Start chasing when player gets this close
    - ATTACK_RANGE: 10 studs - Start attack when this close
    - FLEE_START: 20 studs - Start fleeing when player gets this close
    - SAFE_DISTANCE: 40 studs - Consider safe when this far from player

State Flow:
    - ORB_SEEKING → PLAYER_HUNTING (when player gets within 30 studs)
    - PLAYER_HUNTING → PLAYER_ATTACK (when within 10 studs)
    - PLAYER_ATTACK → ORB_SEEKING (after 2-second attack cooldown)
    - ORB_SEEKING → FLEEING (for smaller NPCs when player within 20 studs)
    - FLEEING → ORB_SEEKING (when 40 studs from player)

Interacts With:
  - NPCRegistry: Gets NPC data
  - NPCStateMachine: Sends state change requests
  - PlayerProximityManager: Gets proximity data
  - OrbSpawner: Finds nearby orbs
--]]
```

### Phase 1: Basic Movement & States ✓
- [x] Implement simple direct movement:
  - [x] Move towards current target (orb or player)
  - [x] Basic collision avoidance
  - [x] Movement speed based on state
- [x] Basic state transitions:
  - [x] OrbSeeking → PlayerHunting (when player closer)
  - [x] PlayerHunting → PlayerAttack (when very close)
  - [x] PlayerAttack → OrbSeeking (after attack cooldown)
  - [x] OrbSeeking → Fleeing (for smaller NPCs)
  - [x] Fleeing → OrbSeeking (when safe)
- [x] Target selection:
  - [x] Find nearest orb
  - [x] Find nearest player
  - [x] Compare distances for state decisions
  - [x] Check player size for flee decisions

### Phase 2: Improved Movement
- [ ] Add waypoint-based navigation:
  - [ ] Define waypoint system
  - [ ] Path following logic
  - [ ] Waypoint selection
- [ ] Enhanced obstacle avoidance:
  - [ ] Dynamic obstacle detection
  - [ ] Path recalculation
  - [ ] Stuck detection and recovery
- [ ] Improved target selection:
  - [ ] Better distance calculations
  - [ ] Target priority system
  - [ ] Target switching logic

### Future Phases (Not Implemented Yet)
- [ ] Group coordination
- [ ] Advanced threat assessment
- [ ] Learning and adaptation
- [ ] Performance optimizations

## 10. Integration with Existing Systems

### Tasks:
- [ ] Modify `OrbPickupManager` to handle NPC orb collection
- [ ] Update `SquashHandler` to work with NPCs
- [ ] Add NPC size display using `OverheadSizeDisplay`
- [ ] Implement NPC growth using `GrowthHandler`

## 11. Performance Considerations

### Tasks:
- [x] Use spatial partitioning for NPC updates
- [x] Implement NPC culling when far from players
- [x] Batch NPC updates to reduce server load
- [ ] Use efficient pathfinding with waypoints

## 12. NPC Behavior Details

### Tasks:
- [x] Implement size-based behavior:
  - [x] Small NPCs: Flee from larger players
  - [x] Large NPCs: Hunt and attack smaller players
  - [x] All NPCs: Seek orbs when not engaged
- [x] Add proximity-based reactions:
  - [x] Flee from larger players (within 20 studs)
  - [x] Hunt smaller players (within 30 studs)
  - [x] Attack when very close (within 10 studs)
  - [x] Return to orb seeking when safe
- [x] Implement orb collection behavior:
  - [x] Prioritize closest orbs
  - [x] Avoid dangerous areas
  - [x] Share orb locations with nearby NPCs

## 13. Visual and Audio

### Tasks:
- [x] Add NPC-specific animations:
  - [x] Walking/running
  - [x] Orb collection
  - [x] Squashing
  - [x] Death
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
- [x] Test NPC behavior in various scenarios
- [x] Balance NPC population and spawn rates
- [x] Tune AI parameters for engaging gameplay
- [ ] Monitor server performance

## Implementation Order:
1. Folder Structure Setup ✓
2. Shared Types and Configs ✓
3. Position Management Integration
4. Animation Registry (Shared)
5. Animation Controller (Unified)
6. NPC State Machine
7. NPCRegistry
8. Proximity Manager
9. Basic AI System
10. Integration with Existing Systems
11. Advanced AI Behaviors
12. Visual and Audio Effects
13. Performance Optimizations
14. Testing and Balancing 