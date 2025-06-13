# NPCs tasks

## Architecture

### Core Systems

1. **NPCAIController**
   - Makes high-level behavior decisions
   - Decides when NPCs should:
     - Seek orbs
     - Hunt players
     - Flee from players
     - Start wandering
   - Uses ProximityManager to find targets
   - Does NOT handle movement specifics

2. **NPCMovementController** (New)
   - Handles all movement-specific decisions
   - Calculates wander positions
   - Determines best paths to targets
   - Manages movement timeouts and retries
   - Works with ProximityManager for target positions
   - Provides movement instructions to NPCMover

3. **NPCStateMachine**
   - Manages state transitions
   - Enforces state change rules
   - Coordinates between systems
   - Does NOT make decisions
   - Does NOT calculate positions

4. **NPCMover**
   - Pure movement executor
   - Receives movement instructions from NPCMovementController
   - Executes movement via Humanoid
   - Reports movement completion to NPCMovementController
   - Does NOT make decisions
   - Does NOT calculate positions

### Data Flow

1. **Behavior Decision Flow**:
   ```
   NPCAIController
   ├─ Decides behavior (seek/wander/hunt/flee)
   ├─ Uses ProximityManager to find targets
   └─ Sends state change request to NPCStateMachine
   ```

2. **Movement Decision Flow**:
   ```
   NPCMovementController
   ├─ Receives state change from NPCStateMachine
   ├─ Calculates appropriate movement
   │  ├─ Wander positions for WANDERING
   │  ├─ Path to orb for ORB_SEEKING
   │  ├─ Path to player for PLAYER_HUNTING
   │  └─ Escape path for FLEEING
   └─ Sends movement instructions to NPCMover
   ```

3. **State Management Flow**:
   ```
   NPCStateMachine
   ├─ Receives state change request from NPCAIController
   ├─ Validates state change
   ├─ Updates state in registry
   ├─ Sends state change to NPCMovementController
   └─ Sends state change to AnimationController
   ```

4. **Movement Execution Flow**:
   ```
   NPCMover
   ├─ Receives movement instructions from NPCMovementController
   ├─ Executes movement via Humanoid
   ├─ Monitors progress
   └─ Sends completion/failure to NPCMovementController
   ```

### Implementation Tasks

1. **Create NPCMovementController**:
   - [x] Create new module
   - [x] Implement wander position calculation
   - [x] Implement path finding
   - [x] Add movement timeout handling
   - [x] Add movement retry logic
   - [x] Make compliant with @init loading pattern
   - [x] Add logging including NPC_ID such as NPC_5 so we can trace end to end flow
   - [x] Validate implementation aligns with architecture in @tasks-npc.md
   - [x] Validate implementation aligns with the data flow in @tasks-npc.md

2. **Refactor NPCAIController**:
   - [x] Remove movement-specific code
   - [x] Focus on behavior decisions
   - [x] Update state change requests
   - [x] Validate implementation aligns with architecture in @tasks-npc.md
   - [x] Validate implementation aligns with the data flow in @tasks-npc.md

3. **Refactor NPCMover**:
   - [x] Remove decision-making code
   - [x] Simplify to pure movement execution
   - [x] Add movement reporting
   - [x] Validate implementation aligns with architecture in @tasks-npc.md
   - [x] Validate implementation aligns with the data flow in @tasks-npc.md

4. **Update NPCStateMachine**:
   - [x] Add NPCMovementController integration
   - [x] Update state change notifications
   - [x] Remove position calculations
   - [x] Validate implementation aligns with architecture in @tasks-npc.md
   - [x] Validate implementation aligns with the data flow in @tasks-npc.md

### Improvement Tasks

1. **Orb Interaction System**:
   - [ ] Implement orb collection/consumption
   - [ ] Add orb interaction detection
   - [ ] Handle post-orb interaction state
   - [ ] Add orb interaction animations
   - [ ] Add orb collection effects

2. **State Management Improvements**:
   - [ ] Add post-orb interaction state handling
   - [ ] Implement return to WANDERING after orb interaction
   - [ ] Add orb targeting cooldown system
   - [ ] Prevent repeated targeting of same orb
   - [ ] Add state transition animations

3. **Movement System Optimization**:
   - [ ] Optimize movement timeout system
   - [ ] Reduce movement progress log frequency
   - [ ] Improve path recalculation efficiency
   - [ ] Add movement smoothing
   - [ ] Implement better stuck detection

4. **Performance Optimizations**:
   - [ ] Reduce log spam
   - [ ] Optimize proximity checks
   - [ ] Implement spatial partitioning
   - [ ] Add NPC culling for distant NPCs
   - [ ] Optimize animation transitions