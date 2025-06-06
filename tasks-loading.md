# 📦 TASKS: Implement Folder-Based Modular Loading System (Rojo-Compatible)

## 🧠 Background

In Roblox, module initialization order can easily become brittle, especially across multiple scripts or phases (data loading, game systems, UI, etc.). Tag-based loading via `CollectionService` works in Studio, but breaks down in code-first workflows with Rojo and Git — where all source of truth should live in files, not Studio tags.

We're solving this with a **folder-based modular loading system**:
- All game logic is broken into modules organized by folder (e.g. `GameModules`, `DataModules`)
- Each module implements a standard `Init()` function that returns a `Promise`
- A shared `ModuleLoader` will iterate folders and automatically run `Init()` in sequence
- A `Bootstrapper` script coordinates the phase loading using this system

This ensures consistency, modularity, and full version control — no Studio tagging needed.

---

## 🎯 Goal

- Enable modular, phased initialization of game logic and UI
- Use folders instead of Studio tags to determine load groups
- Centralize loading logic for maintainability
- Prevent race conditions and make startup logic testable and declarative

---

## 🗂 Directory Layout (Rojo-Compatible)

Here's the target structure (assumes Rojo is syncing with these paths):

```
src/
├── Client/
│   ├── UILoaders/
│   │   ├── HUDLoader.lua
│   │   └── CutsceneLoader.lua
│   └── Bootstrapper.lua
├── Server/
│   ├── DataModules/
│   │   └── PlayerDataHandler.lua
│   ├── GameModules/
│   │   ├── CombatService.lua
│   │   └── EnemySpawner.lua
│   └── Bootstrapper.lua
├── Shared/
│   ├── Promise.lua
│   └── ModuleLoader.lua
```

Rojo `default.project.json` should map these to:
- `ServerScriptService`: `src/Server`
- `StarterPlayer.StarterPlayerScripts`: `src/Client`
- `ReplicatedStorage`: `src/Shared`

---

## ✅ Tasks

### 1. 🔧 `ModuleLoader.lua` (Shared Utility)
**Path:** `src/Shared/ModuleLoader.lua`

- [ ] Create a module that exports: `LoadFromFolder(folder: Instance): Promise<void>`
- [ ] Inside `LoadFromFolder`:
  - [ ] Iterate through all `ModuleScript` children
  - [ ] `pcall(require)` each one
  - [ ] If module returns an `Init()` function, call it and collect the promises
  - [ ] Return `Promise.all(initPromises)`
  - [ ] Warn if any module is missing `Init()`

### 2. 🚀 `Bootstrapper.lua` (Server)
**Path:** `src/Server/Bootstrapper.lua`

- [ ] Require `ModuleLoader`
- [ ] Wait for `DataModules` folder and call `LoadFromFolder()`
- [ ] Then wait for `GameModules` folder and call `LoadFromFolder()`
- [ ] Log "All systems loaded" on success
- [ ] Catch and warn on any promise failure

### 3. 🧠 Create Sample Server Modules

- [ ] `src/Server/DataModules/PlayerDataHandler.lua`
- [ ] `src/Server/GameModules/CombatService.lua`
- [ ] `src/Server/GameModules/EnemySpawner.lua`

Each module should look like:

```lua
local Module = {}

function Module.Init()
  return Promise.new(function(resolve)
    -- setup logic
    resolve()
  end)
end

return Module
```

### 4. 🎮 (Optional) `Bootstrapper.lua` (Client)

**Path:** `src/Client/Bootstrapper.lua`

* [ ] Same flow as server, but points to `UILoaders/`
* [ ] Can preload HUDs, bind input, etc.

### 5. 🖼️ Create Sample Client Modules

* [ ] `src/Client/UILoaders/HUDLoader.lua`
* [ ] `src/Client/UILoaders/CutsceneLoader.lua`

---

## 🧪 Validation Checklist

* [ ] Game runs without requiring any manual script execution order
* [ ] All modules log a confirmation when `Init()` is called
* [ ] Breaking a module (e.g. `Init` missing) causes a clear error in console
* [ ] Removing a module file causes no other modules to break
* [ ] Rojo syncs everything into Studio correctly
* [ ] Studio shows no manual tags needed (everything runs via folder logic)

---

## 🔚 Summary

This system sets up a predictable, scalable, code-first initialization pipeline for Roblox games. It replaces tag-based loading with folder-based loading, works fully in source control, and ensures clean separation of responsibility across game phases.

All modules follow a standard interface and are loaded dynamically by phase, improving maintainability, testability, and dev velocity. 