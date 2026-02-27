# Scene Setup Validation Workflow

When user requests "set up scene to verify features", use this workflow.

## Workflow Overview

```
Phase 1: Scene Preparation
    |
Phase 2: Scene Setup
    |
Phase 3: Configuration Check
    |
Phase 4: Runtime Verification
    |
Phase 5: Issue Fixing (if needed)
    |
Phase 6: Output Verification Report
```

---

## Phase 1: Scene Preparation

| Step | Action | Tool |
|------|--------|------|
| 1 | Confirm target scene | `manage_scene(action="get_active")` or load target scene |
| 2 | Read task list/design docs | `Read(file_path="tasks.md" or "design.md")` |
| 3 | List required components | Determine needed Managers, objects, configs |

---

## Phase 2: Scene Setup

| Step | Action | Tool |
|------|--------|------|
| 1 | Create basic structure | `batch_execute` -> Create Camera, Light, parent objects |
| 2 | Create Manager objects | `batch_execute` -> GridManager, PoolManager, Spawners |
| 3 | Create game objects | `manage_gameobject` -> Player/Snake, etc. |
| 4 | Organize hierarchy | `batch_execute` -> Set parent relationships |
| 5 | Save scene | `manage_scene(action="save")` |

---

## Phase 3: Configuration Check

| Step | Action | Tool |
|------|--------|------|
| 1 | Check if components auto-load | `refresh_unity` -> `Read(code)` check AutoFindReferences |
| 2 | If manual config needed | `manage_components(action="set_property")` |
| 3 | Verify config completeness | `ReadMcpResourceTool` -> Check critical references not null |

---

## Phase 4: Runtime Verification

| Step | Action | Tool |
|------|--------|------|
| 1 | Clear console | `read_console(action="clear")` |
| 2 | Enter play mode | `manage_editor(action="play")` |
| 3 | Wait for initialization | `Bash: sleep 2` |
| 4 | Check console logs | `read_console(types=["log", "error", "warning"])` |
| 5 | Screenshot verification | `manage_scene(action="screenshot")` + `Read(screenshot)` |
| 6 | Check key object states | `find_gameobjects` + `ReadMcpResourceTool` |

---

## Phase 5: Issue Fixing

| Step | Action | Tool |
|------|--------|------|
| 1 | Stop play mode | `manage_editor(action="stop")` |
| 2 | Diagnose issue cause | Refer to [decision-trees.md](decision-trees.md) |
| 3 | Fix code or config | `Edit` or `manage_components` |
| 4 | Refresh and re-test | `refresh_unity` -> Return to Phase 4 |

Repeat until all features verified.

---

## Phase 6: Output Verification Report

List:
- Verified features
- Issues found
- Fixes applied

---

## Scene Setup Checklist

When building verification scene, check these items in order:

| Check Item | Tool | Description |
|------------|------|-------------|
| **Basic Scene Elements** | | |
| Camera exists and configured | `find_gameobjects` + `ReadMcpResourceTool` | Check orthographic, size |
| Light exists | `find_gameobjects` | Optional for 2D games |
| **Manager Components** | | |
| All required Managers exist | `find_gameobjects(by_component)` | GridManager, PoolManager, etc. |
| Manager references configured | `ReadMcpResourceTool` | Check SerializeField not null |
| **Game Objects** | | |
| Player/main object exists | `find_gameobjects` | Snake, Player, etc. |
| Prefab references correct | `ReadMcpResourceTool` | segmentPrefab, foodPrefab, etc. |
| **Configuration Assets** | | |
| ScriptableObjects loaded | `ReadMcpResourceTool` | GameConfig, PowerUpConfig, etc. |
| **Visual Elements** | | |
| Border/grid visualization | `find_gameobjects` | GridBorderVisualizer, etc. |

---

## Quick Scene Setup Commands

### Create basic scene structure

```
[Tool: batch_execute]
  commands:
    - manage_gameobject: create "Main Camera" + Camera
    - manage_gameobject: create "=== MANAGERS ===" (parent object)
    - manage_gameobject: create each Manager and set parent
```

### Check scene completeness

```
[Tool: manage_scene]
  action: "get_hierarchy"
```

### Verify component configuration

```
[Tool: ReadMcpResourceTool]
  uri: "mcpforunity://scene/gameobject/{id}/components"
```
