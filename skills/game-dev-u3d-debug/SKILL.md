---
name: game-dev-u3d-debug
description: Diagnoses and fixes Unity issues when expected behavior differs from actual. Use for bugs, errors, broken features, or troubleshooting questions.
---

# Debug Unity Skill

Unity problem diagnosis and repair expert. Locates root causes, verifies Unity runtime state, analyzes screenshots, and fixes code or configurations.

**Core Capabilities:**
1. **Problem Diagnosis** - Analyze issues using decision trees to locate root causes
2. **Runtime Debugging** - Enter Play Mode, analyze screenshots, check logs and component states
3. **Scene Verification** - Build test scenes to verify features work as designed
4. **Issue Repair** - Fix code logic, component configurations, reference bindings

---

## Reference Files

For detailed guidance, see these files:

| File | Content |
|------|---------|
| [reference/decision-trees.md](reference/decision-trees.md) | Problem diagnosis decision trees for all issue types |
| [reference/scene-setup.md](reference/scene-setup.md) | Scene setup validation workflow |
| [reference/user-interaction.md](reference/user-interaction.md) | User interaction patterns with AskUserQuestion |

---

## Debugging Workflow

```
1. Enter play mode
       |
2. Screenshot current state
       |
3. Identify issue --> Has issue --> 4. Diagnose (see decision-trees.md)
       |                                    |
       | No issue                      Analyze cause
       v                                    |
5. Request user action              Stop, fix code
       |                                    |
6. Check action result              Re-enter play mode
       |
7. Continue or end
```

---

## Core Steps

### Step 1: Enter Play Mode

```
[Tool: manage_editor]
  action: "play"
  wait_for_completion: true
```

**Pre-checks:**
- Confirm current scene is correct start scene
- Confirm no compilation errors (`read_console`)

### Step 2: Screenshot Current State

```
[Tool: manage_scene]
  action: "screenshot"
  screenshot_file_name: "debug_screenshot"

[Tool: Read]
  file_path: "Assets/Screenshots/debug_screenshot.png"
```

### Step 3: Identify Issues

| Issue Type | Identification | Typical Symptoms |
|------------|----------------|------------------|
| UI not showing | Screenshot analysis | Blank screen, missing elements |
| Render abnormal | Screenshot analysis | Wrong lines, colors, positions |
| Click not working | Log check | No click event logs |
| Component not bound | Component check | Field is null |
| Scene not switched | Scene check | Active scene unchanged |

### Step 4: Diagnose Issues

See [reference/decision-trees.md](reference/decision-trees.md) for detailed diagnosis flows.

**Quick checks:**
```
# Check console logs
[Tool: read_console] count: 30, types: ["all"]

# Check GameObject state
[Tool: find_gameobjects] search_term: "target object", search_method: "by_name"

# Check component configuration
[Tool: ReadMcpResourceTool] uri: "mcpforunity://scene/gameobject/{id}/components"

# Check current scene
[Tool: manage_scene] action: "get_active"
```

### Step 5: Request User Action

See [reference/user-interaction.md](reference/user-interaction.md) for interaction patterns.

**Use AskUserQuestion instead of polling.**

### Step 6: Check Action Result

**Auto-detection (preferred):**
```
[Tool: read_console] count: 20, types: ["all"]
[Tool: manage_scene] action: "get_active"
```

### Step 7: Fix Issues

**MUST stop play mode before fixing:**
```
[Tool: manage_editor] action: "stop"
```

**Common fix operations:**

| Issue | Tool | Operation |
|-------|------|-----------|
| Component property not set | `manage_components` | `set_property` |
| GameObject config error | `manage_gameobject` | `modify` |
| Code logic issue | `Edit` | Modify script |
| Reference not bound | `manage_components` | Set instanceID reference |

**Post-fix flow:**
1. Save scene: `manage_scene(action="save")`
2. Refresh Unity: `refresh_unity(compile="request", wait_for_ready=true)`
3. Check errors: `read_console(types=["error"])`
4. Re-enter play mode: `manage_editor(action="play")`

---

## Tool Quick Reference

| Source | Tool | Purpose |
|--------|------|---------|
| UnityMCP | `manage_editor` | Play/stop |
| UnityMCP | `find_gameobjects` | Find objects |
| UnityMCP | `read_console` | View logs |
| UnityMCP | `manage_scene` | Scene operations |
| UnityMCP | `manage_components` | Modify components |
| UnityMCP | `refresh_unity` | Refresh assets |
| MCP Resource | `ReadMcpResourceTool` | Read components |
| File | `Read`, `Edit` | Read/edit files |
| Interaction | `AskUserQuestion` | User confirmation |

---

## Debug Session Example

```
1. [manage_editor] play
2. [manage_scene] screenshot
3. [Read] screenshot.png -> Found: UI not showing
4. [read_console] -> No errors
5. [find_gameobjects] MainMenuView -> Found
6. [ReadMcpResourceTool] -> _startHidden = true
7. [manage_editor] stop
8. [manage_components] set_property _startHidden = false
9. [manage_scene] save
10. [manage_editor] play
11. [manage_scene] screenshot -> UI visible
12. [AskUserQuestion] "Click START button"
13. User: "Done"
14. [manage_scene] get_active -> Scene switched
15. Done
```
