# NPCs

## Project Goal
Create a multiplayer game where players must survive in a world filled with AI-controlled giants. The giants will wander around collecting orbs to grow larger, and when they detect players, they'll switch to chase mode and attempt to stomp them. Players must avoid the giants while trying to survive as long as possible.

## Implementation Plan

### 1. NPC Spawner System
- **Tasks:**
  - Convert NPCGiantManager to NPCSpawner
    - Add random spawn point selection
    - Implement spawn rate controls
    - Add spawn limits and cooldowns

### 2. Proximity Detection System
- **Tasks:**
  - Create ProximityDetector to handle:
    - Player detection for chase behavior
    - Orb detection for collection behavior
    - Spatial partitioning for performance
    - Detection ranges and priorities

### 3. Movement & AI
- **Tasks:**
  - Create NPCPathfinding system
    - Implement path calculation
    - Add movement target management
  - Create NPCMovement system
    - Add collision avoidance
    - Implement movement states
  - Create OrbCollectionBehavior
    - Add orb targeting logic
    - Implement collection animations
  - Create NPCAnimationController
    - Add run animation for movement
    - Add jump animation for obstacles
    - Add stomp animation for attacks
    - Sync animations with movement states

### 4. Size Management System
- **Tasks:**
  - Adapt SizeStateMachine for NPCs
    - Create NPC size tracking
    - Handle size increases from:
      - Orb collection
      - Player squashing
    - Implement size-based collision updates
    - Handle size replication to clients

### 5. Orb System Integration
- **Tasks:**
  - Modify OrbPickupManager to handle NPC collection
    - Add NPC collection method
    - Update orb respawn logic for NPC collection
  - Integrate with existing systems
    - Use OrbVisuals for collection effects
    - Use SquashEffect for visual feedback

Next up
- [ ] Debug things on Roblox
- [ ] You are N'N" big when player spawns in
- [ ] Update description "Squish to grow. Hide in caves."
- [ ] Save Size button gives player way to subscribe to monthly pass where we save their size
- [ ] When player squishes another, squished explodes into many small NPCs
- [ ] Add random NPC giants that go around squishing smaller NPCs
- [ ] Leaderboards - top size live, all time, top squishers live, all time
- [ ] Premium users get 1.25x growth! Add to description and as a feature.

3D
- [ ] Bean stalks to hide in or trees