# NPC Orb Collection

## Current Flow Documentation

### 1. Bootstrapper.server.lua
- Initializes CollisionSetup first
- Then loads all other modules in sequence
- ✅ Proper initialization order

### 2. CollisionSetup.server.lua
- Creates collision groups (NPCs, Orbs)
- Sets up collision rules
- ✅ Proper collision group setup

### 3. NPCAIController.lua
- Manages NPC behavior and decision making
- Checks for nearby orbs every update
- Handles orb collection when in range
- ❌ Missing: Size increase after collection
- ❌ Missing: Visual effects for collection
- ❌ Missing: Error handling for failed collections

### 4. NPCStateMachine.lua
- Manages state transitions
- Handles COLLECTING state
- Returns to ORB_SEEKING after collection
- ❌ Missing: GROWING state implementation
- ❌ Missing: Size transition animations
- ❌ Missing: State cleanup for destroyed NPCs

### 5. EventManager.lua
- Manages OrbCollected and NPCStateChanged events
- Handles both server and client events
- ✅ Proper event setup

### 6. OrbManager.server.lua
- Manages orb spawning and cleanup
- ❌ Missing: Integration with collection system
- ❌ Missing: Orb respawn after collection
- ❌ Missing: Collection statistics tracking

### 7. AnimationController.lua
- Manages NPC animations
- ❌ Missing: Collection animation
- ❌ Missing: Growth animation
- ❌ Missing: Animation transition handling

### 8. ProximityManager.lua
- Handles spatial awareness
- Provides nearby orb detection
- ✅ Proper proximity checking

## Issues Found
1. No size increase implementation after collection
2. Missing visual feedback for collection
3. No orb respawn system after collection
4. Missing collection animations
5. No error handling for failed collections
6. Missing state cleanup for destroyed NPCs
7. No collection statistics tracking
8. Missing growth animations
9. No integration between OrbManager and collection system

## To-Do List

### 1. Size System Implementation

#### 1.1 Orb Collection Detection
- [ ] 1.1.1 Add collision detection for NPC-Orb contact
- [ ] 1.1.2 Add proximity check for collection
- [ ] 1.1.3 Add collection validation
- [ ] 1.1.4 Add collection cooldown system

#### 1.2 Orb Collection Handling
- [ ] 1.2.1 Add orb collection event handling
- [ ] 1.2.2 Add orb removal after collection
- [ ] 1.2.3 Add collection success/failure handling
- [ ] 1.2.4 Add collection statistics tracking

#### 1.3 Size Increase Implementation
- [ ] 1.3.1 Add size increase logic to NPCAIController
- [ ] 1.3.2 Implement orb collection size increase
- [ ] 1.3.3 Use SizeCalculator for new size calculations
- [ ] 1.3.4 Add size validation

#### 1.4 State Management
- [ ] 1.4.1 Implement GROWING state in NPCStateMachine
- [ ] 1.4.2 Add state transition logic
- [ ] 1.4.3 Handle size increase timing
- [ ] 1.4.4 Add state validation

#### 1.5 Size Calculator Refactor
- [ ] 1.5.1 Refactor PlayerSizeCalculator to be generic SizeCalculator
- [ ] 1.5.2 Remove player-specific naming and constants
- [ ] 1.5.3 Keep core size calculation logic (MIN_SIZE, MAX_SIZE, etc.)
- [ ] 1.5.4 Maintain visual height calculations
- [ ] 1.5.5 Update all references in NPCFactory and other scripts

#### 1.6 Visual Feedback
- [ ] 1.6.1 Add size transition animations
- [ ] 1.6.2 Implement growth animation
- [ ] 1.6.3 Add transition smoothing
- [ ] 1.6.4 Add growth particles
- [ ] 1.6.5 Add size change effects

### 2. Collection Visuals
- [ ] Add collection animation to AnimationController
- [ ] Implement collection particle effects
- [ ] Add sound effects for collection
- [ ] Add visual feedback for successful collection

### 3. Orb Management
- [ ] Integrate OrbManager with collection system
- [ ] Implement orb respawn system
- [ ] Add collection statistics tracking
- [ ] Add orb type-specific behaviors

### 4. Error Handling
- [ ] Add error handling for failed collections
- [ ] Implement state cleanup for destroyed NPCs
- [ ] Add validation for collection attempts
- [ ] Add recovery mechanisms for failed states

### 5. Animation System
- [ ] Add collection animation
- [ ] Add growth animation
- [ ] Implement smooth animation transitions
- [ ] Add animation state validation

### 6. State Management
- [ ] Complete GROWING state implementation
- [ ] Add state transition validation
- [ ] Implement state cleanup
- [ ] Add state recovery mechanisms

### 7. Performance Optimization
- [ ] Optimize proximity checks
- [ ] Implement collection cooldown system
- [ ] Add spatial partitioning for orb detection
- [ ] Optimize state transitions

### 8. Testing and Validation
- [ ] Add unit tests for collection system
- [ ] Implement collection validation
- [ ] Add state transition tests
- [ ] Test error recovery
