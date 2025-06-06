# 📁 Codebase Reorganization Plan

## 🎯 Goal
Reorganize the codebase into a more intuitive, system-based structure that makes it easier to find and maintain related functionality.

## 📂 New Directory Structure

```
src/
├── Server/
│   ├── Economy/
│   │   └── PurchaseProcessor.server.lua
│   ├── NPC/
│   │   └── NPCGiantManager.server.lua
│   ├── Progression/
│   │   ├── LeaderstatsUpdater.server.lua
│   │   └── XPManager.lua
│   ├── Player/
│   │   ├── PlayerSpawnHandler.server.lua
│   │   ├── GrowthHandler.server.lua
│   │   ├── GiantTransformationHandler.server.lua
│   │   └── SpeedTransformationHandler.server.lua
│   └── Orbs/
│       ├── OrbManager.server.lua
│       ├── OrbPickupManager.server.lua
│       ├── SquashHandler.server.lua
│       └── SquashTracker.server.lua
│
├── Client/
│   ├── Economy/
│   │   ├── GiantBuyModal.lua
│   │   ├── SpeedBuyModal.lua
│   │   └── BuyModalsInit.client.lua
│   ├── Notifications/
│   │   ├── NotificationManager.lua
│   │   ├── BuySuccessNotifications.client.lua
│   │   ├── SpawnSizeNotification.client.lua
│   │   └── OnboardingMessageNotification.client.lua
│   ├── HUD/
│   │   ├── BottomBarManager.client.lua
│   │   └── OverheadSizeDisplay.client.lua
│   └── Orbs/
│       ├── SpeedBoostEffects.client.lua
│       ├── OrbPickupEffects.client.lua
│       └── SquashEffectHandler.client.lua
│
└── Shared/
    ├── Core/
    │   ├── EventManager.lua
    │   └── SizeStateMachine.lua
    ├── Progression/
    │   └── PlayerSizeCalculator.lua
    ├── UI/
    │   └── ButtonStyler.lua
    ├── Orbs/
    │   ├── OrbSpawner.lua
    │   ├── OrbVisuals.lua
    │   ├── OrbCounter.lua
    │   ├── OrbFTUCluster.lua
    │   ├── OrbPositionManager.lua
    │   └── RandomOrbPositions.lua
    └── Audio/
        └── SoundRegistry.lua
```

## ✅ Tasks

### 1. Create New Directory Structure
- [ ] Create all new directories in `src/`
- [ ] Verify directory permissions
- [ ] Update `.gitignore` if needed

### 2. Move Server Files
- [ ] Economy/
  - [ ] Move `PurchaseProcessor.server.lua`
- [ ] NPC/
  - [ ] Move `NPCGiantManager.server.lua`
- [ ] Progression/
  - [ ] Move `LeaderstatsUpdater.server.lua`
  - [ ] Move `XPManager.lua`
- [ ] Player/
  - [ ] Move `PlayerSpawnHandler.server.lua`
  - [ ] Move `GrowthHandler.server.lua`
  - [ ] Move `GiantTransformationHandler.server.lua`
  - [ ] Move `SpeedTransformationHandler.server.lua`
- [ ] Orbs/
  - [ ] Move `OrbManager.server.lua`
  - [ ] Move `OrbPickupManager.server.lua`
  - [ ] Move `SquashHandler.server.lua`
  - [ ] Move `SquashTracker.server.lua`

### 3. Move Client Files
- [ ] Economy/
  - [ ] Move `GiantBuyModal.lua`
  - [ ] Move `SpeedBuyModal.lua`
  - [ ] Move `BuyModalsInit.client.lua`
- [ ] Notifications/
  - [ ] Move `NotificationManager.lua`
  - [ ] Move `BuySuccessNotifications.client.lua`
  - [ ] Move `SpawnSizeNotification.client.lua`
  - [ ] Move `OnboardingMessageNotification.client.lua`
- [ ] HUD/
  - [ ] Move `BottomBarManager.client.lua`
  - [ ] Move `OverheadSizeDisplay.client.lua`
- [ ] Orbs/
  - [ ] Move `SpeedBoostEffects.client.lua`
  - [ ] Move `OrbPickupEffects.client.lua`
  - [ ] Move `SquashEffectHandler.client.lua`

### 4. Move Shared Files
- [ ] Core/
  - [ ] Move `EventManager.lua`
  - [ ] Move `SizeStateMachine.lua`
- [ ] Progression/
  - [ ] Move `PlayerSizeCalculator.lua`
- [ ] UI/
  - [ ] Move `ButtonStyler.lua`
- [ ] Orbs/
  - [ ] Move `OrbSpawner.lua`
  - [ ] Move `OrbVisuals.lua`
  - [ ] Move `OrbCounter.lua`
  - [ ] Move `OrbFTUCluster.lua`
  - [ ] Move `OrbPositionManager.lua`
  - [ ] Move `RandomOrbPositions.lua`
- [ ] Audio/
  - [ ] Move `SoundRegistry.lua`

### 5. Update Rojo Project
- [ ] Update `default.project.json` to reflect new structure
- [ ] Test Rojo sync
- [ ] Verify all files are syncing correctly

### 6. Update Require Paths
- [ ] Update all require paths in moved files
- [ ] Test each system after moving
- [ ] Fix any broken dependencies

### 7. Testing
- [ ] Test each system after moving
- [ ] Verify all functionality works
- [ ] Check for any console errors
- [ ] Test in Studio

## 🧪 Validation Checklist

- [ ] All files are in their new locations
- [ ] No files are left in old locations
- [ ] All require paths are updated
- [ ] Rojo syncs everything correctly
- [ ] Game runs without errors
- [ ] All systems function as before
- [ ] No console warnings about missing modules

## 🔚 Summary

This reorganization will make the codebase more maintainable and easier to navigate by grouping related functionality together. Each system (Economy, Orbs, Player, etc.) will have its own dedicated folder, making it clear where to find and add new features. 