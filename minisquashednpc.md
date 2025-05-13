# Mini Squashed NPC Feature
## Overview
When a player is squashed, they will spawn 3-5 miniature NPCs at 1/10th their size. These mini NPCs wander around the map randomly and can be squashed by other players, adding an extra layer of fun to the squash mechanics. The mini NPCs have a limited lifetime and will eventually disappear to prevent overcrowding.

## How It Works
1. When a player is squashed, their final size is captured
2. 3-5 mini NPCs spawn at the death location before the character is removed
3. Each mini NPC inherits the squashed player's appearance but at 1/10th scale
4. Mini NPCs walk randomly and can be squashed by players
5. After 30-60 seconds, mini NPCs fade away and despawn
6. The game maintains a maximum of 20 mini NPCs at once

## Technical Integration
- Uses existing squash detection system
- Reuses current squash effects and sounds
- Leverages same character structure for compatibility
- Implements basic AI for movement
- Includes automatic cleanup system

## Implementation Plan

### Phase 1: Core Module Setup
1. Create new `MiniSquashedNPC` module in ReplicatedStorage
2. Define core configuration values:
   - Size ratio (1/10)
   - Number of NPCs per squash (3-5)
   - Maximum lifetime (30-60 seconds)
   - Movement speed
   - Global NPC limit (20)

### Phase 2: NPC Creation
1. Add NPC spawning logic to SquashHandler
2. Implement size inheritance from squashed player
3. Setup basic character structure compatible with squash system
4. Add spawn effects/animation

### Phase 3: NPC Behavior
1. Implement random walk pattern
   - Direction changes every 3-5 seconds
   - Basic obstacle avoidance
2. Add lifetime management
   - Countdown timer
   - Fade out effect
   - Cleanup process

### Phase 4: Integration
1. Hook into existing squash detection system
2. Reuse squash mechanics for mini NPCs
3. Add global NPC count management
4. Implement cleanup for server shutdown

### Phase 5: Testing & Optimization
1. Test with multiple simultaneous squashes
2. Verify cleanup systems
3. Check performance impact
4. Validate size inheritance
5. Test interaction with existing squash mechanics

## Performance Considerations
- Maximum of 5 minis per squash
- 30-60 second lifetime per mini
- Global cap of 20 minis
- Automatic cleanup systems
- Basic AI to minimize server impact

## Future Enhancements (Optional)
- Unique squash effects for minis
- Points system for squashing minis
- Different behaviors based on original player size
- Custom animations for mini NPCs 