# Land of Giants - Squashing Implementation Plan (MVP)

## 🎮 Core Implementation

### Phase 1: Basic Mechanics
#### ServerScriptService/SquashHandler.server.lua
- [ ] Implement basic collision detection:
  - Listen for Touched events on character HumanoidRootPart
  - Get both players involved in collision
- [ ] Add core squash logic:
  - Compare player sizes using PlayerSizeModule
  - Check if larger player is above smaller player
  - Fire SquashEvent when conditions are met
- [ ] Handle player defeat:
  - Kill the squashed player's character
  - This will trigger natural respawn with new size

#### ReplicatedStorage/Events/SquashEvent
- [ ] Create single RemoteEvent for squash communication

### Phase 2: Visual Effects
#### ReplicatedStorage/SquashEffect.lua
- [ ] Define basic squash parameters:
  - Final squash scale for death animation
  - Quick animation duration
  - Particle effect timing

#### StarterPlayerScripts/SquashEffectHandler.client.lua
- [ ] Implement squash death effect:
  - Quick flatten animation
  - Trigger particle burst
  - Play sound effect
  - Let natural respawn system take over

### Phase 3: Sound
#### ReplicatedStorage/SoundRegistry.lua
- [ ] Create simple sound registry:
  - Table of sound IDs
  - Basic sound loading function
- [ ] Add core sounds:
  - Squash impact sound

## 🎨 Required Assets
- [ ] Sound effect:
  - One good squash/impact sound
- [ ] Simple particle effect for impact