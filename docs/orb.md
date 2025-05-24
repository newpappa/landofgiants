# Growth Orb System Documentation

## Overview
The Growth Orb System is a gameplay mechanic that allows players to grow by collecting glowing orbs scattered throughout the game world. The system consists of three main components: Orb Spawning, Orb Collection, and Visual Effects.

## Components

### 1. Orb Types
Three types of orbs exist, each with different properties:

| Type   | Growth Amount | Spawn Rate | Color  | Scale |
|--------|---------------|------------|--------|-------|
| Small  | 0.05 scale   | 70%        | Yellow | 2x    |
| Medium | 0.1 scale    | 25%        | Green  | 3x    |
| Large  | 0.2 scale    | 5%         | Red    | 4x    |

### 2. Orb Spawning System
The `OrbSpawner` manages orb creation and placement:

- **Spawn Configuration**:
  - Minimum Orbs: 20
  - Maximum Orbs: 50
  - Spawn Check Interval: 1 second
  - Initial Spawn Batch: 5 orbs per batch
  - Initial Spawn Delay: 0.1 seconds between orbs
  - Minimum Distance Between Orbs: 10 units
  - Player Safe Distance: 20 units
  - Spawn Height: 1 unit above ground
  - Spawn Radius: 100 units from center

- **Spawn Logic**:
  1. Randomly selects orb type based on rarity
  2. Finds valid spawn position (not too close to other orbs or players)
  3. Creates orb with appropriate visual properties
  4. Maintains minimum orb count through periodic checks

### 3. Orb Collection System
The `OrbPickupManager` handles orb collection and growth:

- **Collection Process**:
  1. Detects player contact with orb
  2. Retrieves growth amount from orb attributes
  3. Calculates new player size based on current size and growth amount
  4. Updates player size through SizeStateMachine
  5. Triggers visual effects
  6. Removes collected orb

- **Growth Calculation**:
  - Converts visual height growth to scale
  - Maintains size caps and progression
  - Ensures smooth size transitions

### 4. Visual Effects System
The `OrbPickupEffects` handles client-side visuals:

- **Orb Properties**:
  - Glowing effect with PointLight
  - Particle effects
  - Semi-transparent neon material
  - Color-coded by type

- **Collection Effects**:
  - Burst of particles matching orb color
  - Scale animation
  - Fade-out effect
  - Automatic cleanup

## Technical Implementation

### File Structure
```
src/
├── ReplicatedStorage/
│   └── OrbVisuals.lua           # Visual configurations
├── ServerScriptService/
│   ├── OrbSpawner.server.lua    # Orb spawning logic
│   └── OrbPickupManager.server.lua  # Collection handling
└── StarterPlayer/
    └── StarterPlayerScripts/
        └── OrbPickupEffects.client.lua  # Visual effects
```

### Key Features
1. **Efficient Orb Management**:
   - Maintains optimal number of orbs
   - Prevents orb clustering
   - Automatic respawning

2. **Smooth Growth Integration**:
   - Works with existing size system
   - Maintains size progression
   - Handles size caps

3. **Visual Polish**:
   - Dynamic particle effects
   - Smooth animations
   - Color-coded feedback

4. **Performance Considerations**:
   - Efficient orb pooling
   - Optimized particle effects
   - Proper cleanup

## Usage

### For Players
1. Move near orbs to collect them
2. Different colored orbs provide different growth amounts
3. Visual feedback indicates successful collection
4. Growth is proportional to orb type

### For Developers
1. Orb types and properties can be modified in `OrbVisuals.lua`
2. Spawn configuration can be adjusted in `OrbSpawner.server.lua`
3. Visual effects can be customized in `OrbPickupEffects.client.lua`

## Dependencies
- PlayerSizeCalculator
- SizeStateMachine
- GrowthHandler

## Future Improvements
1. Add sound effects for collection
2. Implement orb movement patterns
3. Add special effect orbs
4. Create orb collection achievements
5. Add orb collection leaderboard 