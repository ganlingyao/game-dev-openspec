---
name: debug-unity
description: |
  Unity problem diagnosis and repair capability. Automatically triggered when the user reports any situation where "expected behavior differs from actual behavior".

  **Core Trigger Scenarios (Triggered if any match):**
  - Functionality Failure: "Click not working", "Function failed", "No response", "Not working"
  - Request for Fix: "Please fix", "Help me fix", "fix this", "Please solve"
  - Issue Discovery: "Found an issue", "There is a problem", "Has bug", "Error occurred"
  - Abnormal Behavior: "Wrong", "Incorrect", "Different from design", "Not executed as..."
  - Investigation: "Check reason", "Why", "What happened", "What's going on"
  - Improvement/Correction: "Please improve", "Please correct", "Please adjust", "Does not match spec"

  **典型触发句式：**
  - "UI存在问题，点击无效，请进行修复"
  - "返回主页功能失效，检查原因并修复"
  - "设计未按照策划案执行，请进行完善"
  - "蛇不动了，帮我看看什么问题"
  - "分数没有更新，请修复"
invocation: auto
---

# Debug Unity Skill

Unity problem diagnosis and repair expert. Responsible for locating root causes, verifying Unity runtime state, analyzing screenshots, and fixing code or configurations.

**Core Capabilities:**
1. **Problem Diagnosis** - Analyze user-reported issues and use decision trees to locate root causes.
2. **Runtime Debugging** - Enter Play Mode, analyze screenshots, check logs and component states.
3. **Scene Verification** - Build test scenes to verify if features work as designed.
4. **Issue Repair** - Fix code logic, component configurations, reference bindings, etc.

---

## Trigger Conditions (Auto-trigger)

**Core Principle: Must use this Skill when there is a discrepancy between the "expected behavior" described by the user and the "actual behavior".**

### Mandatory Trigger Scenarios

#### Category A: User Reports Issue + Requests Fix

**Typical Phrases:**
- "XX has issues, please fix" / "XX has issues, please fix"
- "XX is not working, help me check" / "XX is not working, help me check"
- "XX function failed, check reason and fix"
- "Clicking XX has no response, please solve"

**Keyword Combinations:**
- `{Problem Object}` + `{Problem Description}` + `{Fix Request}`
- Problem Object: UI, Button, Function, XX Function, Return, Jump, Move, Collision...
- Problem Description: Has issues, Problematic, Failed, Invalid, Not working, No response, Broken...
- Fix Request: Please fix, Help me fix, fix, Solve, Handle, Check...

#### Category B: Implementation Does Not Match Design/Spec

**Typical Phrases:**
- "Design not executed according to plan, please improve"
- "Different from design document, please correct"
- "Not implemented according to XX, please adjust"
- "Effect does not match expectation"

**Keywords:**
- Not according to, Did not follow, Different from..., Mismatch...
- Plan, Design document, design, spec, requirement
- Please improve, Please correct, Please adjust, Please fix

#### Category C: Functionality/Interaction Issues

- Button click invalid, no response
- Input unresponsive (Keyboard, Mouse, Touch)
- Event not triggered, callback not executed
- Function malfunction, feature not working
- No feedback after operation

#### Category D: Display/Rendering Issues

- UI not showing, invisible, disappeared
- GameObject invisible, not rendered
- Wrong position, wrong size, wrong color
- Animation not playing, playing abnormally
- Image/Texture missing, display error
- Layer occlusion, sorting issues

#### Category E: GameObject Issues

- Object not spawned, not created
- Object not destroyed, persists
- Object behavior abnormal, state error
- Component missing, reference lost

#### Category F: Movement/Physics Issues

- Movement abnormal: Stuck, Frozen, Not moving
- Penetration: Passing through walls, Overlap
- Collision issues: Not detected, False trigger
- Physics effects: Drifting, Abnormal bouncing
- Speed/Direction: Too fast, Too slow, Wrong direction

#### Category G: Game Logic Issues

- Values not updating: Score, Health, Timer
- State errors: Game state, Character state
- Flow issues: Flow interrupted, Stuck at step
- Condition check: Check error, Logic error

#### Category H: Scene Issues

- Scene switch failed, unable to load
- Scene content missing
- Scene state incorrect

#### Category I: Scene Setup and Function Verification

- Setup scene, Create scene, Configure scene
- Verify function, Test function, Check function
- Is it complete, Is it normal, Does it work

### Trigger Keyword Recognition

**问题描述（中文）：**
- 不工作、失效、无效、没用、坏了、出问题、有问题
- 不显示、看不到、消失、不见了、没有、缺失
- 卡住、卡死、冻结、不动、停止、无法移动
- 错误、问题、bug、异常、出错、报错
- 不对、不正确、不一样、不符、没按照

**修复请求（中文）：**
- 请修复、帮我修、修一下、解决、处理
- 请完善、请修正、请调整、请改正、请检查
- 看看、帮我看、检查一下、排查

**Problem Description (English):**
- not working, doesn't work, broken, failed
- not showing, invisible, disappeared, missing
- stuck, frozen, can't move, stopped
- error, bug, issue, problem, wrong
- incorrect, doesn't match, not as expected

**Fix Request (English):**
- please fix, fix this, help me fix
- please check, take a look, debug, troubleshoot
- please adjust, please correct, investigate

### Non-trigger Scenarios

Use other Skills in these cases:
- User asks how to implement a feature (use design-unity)
- User asks to write new code (use code-unity)
- User asks about Unity API usage (use tech-research-unity)
- Pure code review request
- Project architecture consultation

---

## Core Principles

### 1. User Interaction Strategy

**Use AskUserQuestion tool for interaction confirmation, NOT polling.**

```
When user needs to perform actions in Unity:
1. Clearly explain the steps
2. Use AskUserQuestion to provide confirmation options
3. Continue processing based on user response
```

**Example:**
```
[Tool: AskUserQuestion]
  questions:
    - question: "Please click the START button in Unity Game view, then select an option below"
      header: "Action Confirmation"
      options:
        - label: "Done"
          description: "Button clicked, waiting for result check"
        - label: "Problem encountered"
          description: "Button cannot be clicked or other issues"
        - label: "Skip"
          description: "Skip this step"
      multiSelect: false
```

### 2. Batch Operations Principle

- **Simple consecutive operations** → One explanation, one confirmation
- **Operations requiring step-by-step verification** → Batch by batch, one confirmation per batch
- **Complex debugging flow** → Divide by phases, confirm each phase

### 3. Auto-detection First

For auto-detectable results (scene switch, log output, etc.), prefer using tools for detection without user confirmation.

---

## Scene Setup Validation Workflow (NEW)

When user requests "set up scene to verify features", use this workflow:

```
┌─────────────────────────────────────────────────────────┐
│  1. Analyze feature modules to verify                    │
│     ↓                                                   │
│  2. Check/create necessary scenes and GameObjects        │
│     ↓                                                   │
│  3. Configure component references and parameters        │
│     ↓                                                   │
│  4. Save scene                                          │
│     ↓                                                   │
│  5. Enter play mode                                     │
│     ↓                                                   │
│  6. Verify features (screenshot + log check)            │
│     ↓                                                   │
│  7. Found issues → Diagnose & fix → Re-verify           │
│     ↓ No issues                                         │
│  8. Output verification report                          │
└─────────────────────────────────────────────────────────┘
```

### Scene Setup Checklist

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

### Quick Scene Setup Commands

```
# Create basic scene structure
[Tool: batch_execute]
  commands:
    - manage_gameobject: create "Main Camera" + Camera
    - manage_gameobject: create "=== MANAGERS ===" (parent object)
    - manage_gameobject: create each Manager and set parent

# Check scene completeness
[Tool: manage_scene]
  action: "get_hierarchy"

# Verify component configuration
[Tool: ReadMcpResourceTool]
  uri: "mcpforunity://scene/gameobject/{id}/components"
```

---

## Debugging Workflow

```
┌─────────────────────────────────────────────────────────┐
│  1. Enter play mode                                     │
│     ↓                                                   │
│  2. Screenshot to view current state                    │
│     ↓                                                   │
│  3. Identify issue ──→ Has issue ──→ 4. Diagnose        │
│     ↓ No issue                          ↓               │
│  5. Request user action               Analyze cause     │
│     ↓                                   ↓               │
│  6. Check action result              Stop, fix code     │
│     ↓                                   ↓               │
│  7. Continue or end                  Re-enter play mode │
└─────────────────────────────────────────────────────────┘
```

---

## Step Details

### Step 1: Enter Play Mode

```
[Tool: manage_editor]
  action: "play"
  wait_for_completion: true
```

**Pre-checks:**
- Confirm current scene is the correct start scene
- Confirm no compilation errors (use read_console)

### Step 2: Screenshot Current State

```
[Tool: manage_scene]
  action: "screenshot"
  screenshot_file_name: "debug_screenshot"

[Tool: Read]
  file_path: "Assets/Screenshots/debug_screenshot.png"
```

### Step 3: Identify Issues

**Common Issue Types:**

| Issue Type | Identification | Typical Symptoms |
|------------|----------------|------------------|
| UI not showing | Screenshot analysis | Blank screen, missing UI elements |
| Render abnormal | Screenshot analysis | Wrong lines, colors, positions |
| Click not working | Log check | No click event logs |
| Component not bound | Component check | Field is null |
| Scene not switched | Scene check | Active scene unchanged |

### Step 4: Diagnose Issues

**4.1 Check Console Logs**
```
[Tool: read_console]
  count: 30
  types: ["all"]  # or ["error", "warning"]
```

**4.2 Check GameObject State**
```
[Tool: find_gameobjects]
  search_term: "target object name"
  search_method: "by_name"  # or by_tag, by_component
```

**4.3 Check Component Configuration**
```
[Tool: ReadMcpResourceTool]
  server: "UnityMCP"
  uri: "mcpforunity://scene/gameobject/{instanceID}/components"
```

**4.4 Check Current Scene**
```
[Tool: manage_scene]
  action: "get_active"
```

### Step 5: Request User Action

**Use AskUserQuestion instead of polling:**

```
[Tool: AskUserQuestion]
  questions:
    - question: "Please complete the following:\n1. Click START button in Game view\n2. Observe if scene switches\n\nSelect result after completion"
      header: "User Action"
      options:
        - label: "Success"
          description: "Button responded, scene switched"
        - label: "No response"
          description: "Clicking button had no effect"
        - label: "Error occurred"
          description: "Error or abnormal behavior"
        - label: "Need help"
          description: "Not sure how to proceed"
      multiSelect: false
```

### Step 6: Check Action Result

**Auto-detection (preferred):**
```
[Tool: read_console]
  count: 20
  types: ["all"]

[Tool: manage_scene]
  action: "get_active"
```

**Screenshot verification (when needed):**
```
Take new screenshot and analyze
```

### Step 7: Fix Issues

**MUST stop play mode before fixing:**
```
[Tool: manage_editor]
  action: "stop"
```

**Common Fix Operations:**

| Issue | Fix Tool | Operation |
|-------|----------|-----------|
| Component property not set | manage_components | set_property |
| GameObject config error | manage_gameobject | modify |
| Code logic issue | Edit | Modify script |
| Sprite not set | manage_components | Set sprite property |
| Reference not bound | manage_components | Set instanceID reference |

**Post-fix Flow:**
```
1. Save scene
   [Tool: manage_scene] action: "save"

2. Refresh Unity (if code was modified)
   [Tool: refresh_unity] compile: "request", wait_for_ready: true

3. Check compilation errors
   [Tool: read_console] types: ["error"]

4. Re-enter play mode to test
   [Tool: manage_editor] action: "play"
```

---

## Tool Classification

| Source | Icon | Tools |
|--------|------|-------|
| **UnityMCP** | 🔷 | `manage_editor`, `find_gameobjects`, `read_console`, `manage_scene`, `manage_components`, `refresh_unity`, `manage_gameobject`, `manage_prefabs` |
| **MCP Resource** | 🔶 | `ReadMcpResourceTool` (server="UnityMCP") |
| **File Operations** | 📁 | `Read`, `Edit`, `Write`, `Glob` |
| **Bash Commands** | 💻 | `Bash` (win-shot.exe, etc.) |
| **User Interaction** | 👤 | `AskUserQuestion` |

---

## Problem Diagnosis Decision Trees

### -1. Scene Setup Validation Flow (NEW)

When user requests "set up scene to verify features", follow this flow:

```
Scene Setup Validation Flow
│
├─ Phase 1: Scene Preparation
│  ├─ Step 1: Confirm target scene
│  │  └─ 🔷 manage_scene(action="get_active") or load target scene
│  ├─ Step 2: Read task list/design docs to understand features to verify
│  │  └─ 📁 Read(file_path="tasks.md" or "design.md")
│  └─ Step 3: List required components
│     └─ Determine needed Managers, objects, configs based on feature modules
│
├─ Phase 2: Scene Setup
│  ├─ Step 1: Create basic structure
│  │  └─ 🔷 batch_execute → Create Camera, Light, parent objects
│  ├─ Step 2: Create Manager objects
│  │  └─ 🔷 batch_execute → GridManager, PoolManager, various Spawners
│  ├─ Step 3: Create game objects
│  │  └─ 🔷 manage_gameobject → Player/Snake, etc.
│  ├─ Step 4: Organize hierarchy
│  │  └─ 🔷 batch_execute → Set parent relationships
│  └─ Step 5: Save scene
│     └─ 🔷 manage_scene(action="save")
│
├─ Phase 3: Configuration Check
│  ├─ Step 1: Check if components auto-load references
│  │  └─ 🔷 refresh_unity → 📁 Read(code) check AutoFindReferences
│  ├─ Step 2: If manual config needed, set component properties
│  │  └─ 🔷 manage_components(action="set_property")
│  └─ Step 3: Verify config completeness
│     └─ 🔶 ReadMcpResourceTool → Check critical references not null
│
├─ Phase 4: Runtime Verification
│  ├─ Step 1: Clear console
│  │  └─ 🔷 read_console(action="clear")
│  ├─ Step 2: Enter play mode
│  │  └─ 🔷 manage_editor(action="play")
│  ├─ Step 3: Wait for initialization
│  │  └─ 💻 Bash: sleep 2
│  ├─ Step 4: Check console logs
│  │  └─ 🔷 read_console(types=["log", "error", "warning"])
│  ├─ Step 5: Screenshot verification
│  │  └─ 🔷 manage_scene(action="screenshot") + 📁 Read(screenshot)
│  └─ Step 6: Check key object states
│     └─ 🔷 find_gameobjects + 🔶 ReadMcpResourceTool
│
├─ Phase 5: Issue Fixing (if issues found)
│  ├─ Step 1: Stop play mode
│  │  └─ 🔷 manage_editor(action="stop")
│  ├─ Step 2: Diagnose issue cause
│  │  └─ Refer to "Common Diagnosis Steps" below
│  ├─ Step 3: Fix code or config
│  │  └─ 📁 Edit or 🔷 manage_components
│  ├─ Step 4: Refresh and re-test
│  │  └─ 🔷 refresh_unity → Return to Phase 4
│  └─ Repeat until all features verified
│
└─ Phase 6: Output Verification Report
   └─ List verified features, issues found, fixes applied
```

### 0. Common Diagnosis Steps (Execute first for all issues)

```
Common Diagnosis Steps
│
├─ Step 1: Confirm play mode
│  └─ 🔷 manage_editor(action="play") or confirm already in play mode
│
├─ Step 2: Screenshot current state
│  ├─ 🔷 manage_scene(action="screenshot")
│  └─ 📁 Read(file_path="screenshot.png")
│
├─ Step 3: Check console logs
│  └─ 🔷 read_console(types=["all"], count=30)
│
├─ Step 4: Confirm game state
│  ├─ 🔷 find_gameobjects(search_term="GameManager", search_method="by_name")
│  ├─ 🔶 ReadMcpResourceTool(server="UnityMCP", uri="mcpforunity://scene/gameobject/{id}/components")
│  └─ Check: CurrentState is expected value
│
└─ Step 5: Locate issue-related objects
   └─ 🔷 find_gameobjects(search_term="issue-related object name")
```

### 1. State Flag Issues

```
State Flag Issues
│
├─ Common State Flags and Meanings
│  ├─ IsAlive / _isDead      → Object alive/dead state
│  ├─ _isInitialized         → Initialization complete flag
│  ├─ IsSpawning             → Spawner running state
│  ├─ _isActive / IsActive   → Activation state
│  ├─ CurrentState           → Game/scene state enum
│  ├─ _collisionEnabled      → Collision detection switch
│  └─ IsVisible / _startHidden → UI visibility state
│
├─ Diagnosis Steps
│  ├─ Step 1: Find target object
│  │  └─ 🔷 find_gameobjects(search_term="object name", search_method="by_name")
│  ├─ Step 2: Read component properties
│  │  └─ 🔶 ReadMcpResourceTool(server="UnityMCP", uri="mcpforunity://scene/gameobject/{id}/components")
│  └─ Step 3: Check all Is/Has/Can/_is prefixed properties
│
└─ Common Issues
   ├─ IsAlive=false but object expected alive → Check death trigger conditions
   ├─ _isInitialized=false → Check if Initialize method was called
   ├─ IsSpawning=false → Check StartSpawning trigger conditions
   └─ CurrentState incorrect → Check scene loading method
```

### 2. Functionality/Interaction Issues

```
Functionality/Interaction Issues
│
├─ Button/UI Interaction Not Responding
│  ├─ Step 1: Check EventSystem
│  │  └─ 🔷 find_gameobjects(search_term="EventSystem", search_method="by_name")
│  ├─ Step 2: Check Button component
│  │  └─ 🔶 ReadMcpResourceTool → View onClick bindings
│  ├─ Step 3: Check script Button references
│  │  └─ 🔶 ReadMcpResourceTool → Check if _xxxButton is null
│  ├─ Step 4: Check GraphicRaycaster
│  │  └─ 🔷 find_gameobjects(search_term="Canvas") → 🔶 Read components
│  └─ Step 5: Check code logic
│     └─ 📁 Read(file_path="script path")
│
├─ Keyboard/Input Not Responding
│  ├─ Step 1: Confirm Input System type
│  │  └─ 📁 Glob(pattern="**/InputSystem*.cs") or check Project Settings
│  ├─ Step 2: Check input handling code
│  │  └─ 📁 Read(file_path="input script")
│  └─ Step 3: Check Time.timeScale
│     └─ 🔷 read_console to check if paused
│
└─ Event Not Firing
   ├─ Step 1: Check Manager singleton
   │  └─ 🔶 ReadMcpResourceTool → Confirm Instance != null
   ├─ Step 2: Check event subscription code
   │  └─ 📁 Read → Check += subscriptions in OnEnable
   └─ Step 3: Add debug logs to confirm
      └─ 📁 Edit → Add Debug.Log
```

### 3. UI/Display Issues

```
UI/Display Issues
│
├─ UI Not Showing At All
│  ├─ Step 1: Check Canvas
│  │  ├─ 🔷 find_gameobjects(search_term="Canvas", search_method="by_name")
│  │  └─ 🔶 ReadMcpResourceTool → Check enabled, renderMode
│  ├─ Step 2: Check UI object state
│  │  └─ 🔶 ReadMcpResourceTool → Check _startHidden, IsVisible
│  ├─ Step 3: Check GameObject.activeSelf
│  │  └─ 🔶 ReadMcpResourceTool → gameObject state in Transform data
│  ├─ Step 4: Check CanvasGroup
│  │  └─ 🔶 ReadMcpResourceTool → Check if alpha is 0
│  └─ Step 5: Fix
│     ├─ 🔷 manage_components(action="set_property", property="_startHidden", value=false)
│     └─ 🔷 manage_scene(action="save")
│
├─ UI Content Not Updating
│  ├─ Step 1: Check Text/TMP references
│  │  └─ 🔶 ReadMcpResourceTool → Check if _scoreText etc. is null
│  ├─ Step 2: Check update methods
│  │  └─ 📁 Read → Check UpdateScore etc. methods
│  └─ Step 3: Check event subscriptions
│     └─ 📁 Read → Check OnScoreChanged subscriptions
│
└─ UI Position/Size Wrong
   ├─ Step 1: Check RectTransform
   │  └─ 🔶 ReadMcpResourceTool → Check anchor, pivot
   └─ Step 2: Check Canvas Scaler
   └─ 🔶 ReadMcpResourceTool → Check scaleMode
onfirm object truly doesn't exist
│  │  └─ 🔷 find_gameobjects(search_term="object name", search_method="by_tag")
│  ├─ Step 2: Check Spawner exists
│  │  └─ 🔷 find_gameobjects(search_term="XXXSpawner")
│  ├─ Step 3: Check Spawner state
│  │  ├─ 🔶 ReadMcpResourceTool
│  │  └─ Key properties: IsSpawning, ActiveCount, _prefab reference
│  ├─ Step 4: Check GameManager state
│  │  ├─ 🔷 find_gameobjects(search_term="GameManager")
│  │  ├─ 🔶 ReadMcpResourceTool
│  │  └─ Check: CurrentState should be Playing
│  └─ Step 5: Check scene loading method
│     └─ 👤 AskUserQuestion → Confirm if started from MainMenu
│
├─ Object Spawning at Wrong Position
│  ├─ Step 1: Check Spawner configuration
│  │  └─ 🔶 ReadMcpResourceTool → Check _gridMin, _gridMax
│  └─ Step 2: Check coordinate system
│     └─ 📁 Read → Check if using centered coordinates
│
└─ Object Not Being Destroyed
   ├─ Step 1: Check recycling logic
   │  └─ 📁 Read → Check HandleXXXConsumed methods
   └─ Step 2: Check ObjectPool
      └─ 🔶 ReadMcpResourceTool → Check _pool reference
```

### 5. Movement/Physics Issues

```
Movement/Physics Issues
│
├─ Object Not Moving/Stuck
│  ├─ Step 1: Check console logs
│  │  └─ 🔷 read_console → Check for collision or error messages
│  ├─ Step 2: Check controller script state
│  │  ├─ 🔷 find_gameobjects(search_term="controlled object")
│  │  ├─ 🔶 ReadMcpResourceTool
│  │  └─ Key properties: IsAlive, _isInitialized, _isDead
│  ├─ Step 3: Check Rigidbody
│  │  └─ 🔶 ReadMcpResourceTool → bodyType, isKinematic
│  ├─ Step 4: Check collider blocking
│  │  └─ 🔶 ReadMcpResourceTool → isTrigger setting
│  └─ Step 5: Fix state flags
│     └─ 📁 Edit → Modify related code
│
├─ Collision Triggering Too Early/Late
│  ├─ Step 1: Check collider configuration
│  │  ├─ 🔷 find_gameobjects(search_term="object name")
│  │  └─ 🔶 ReadMcpResourceTool → radius/size, offset
│  ├─ Step 2: Check Transform.localScale
│  │  └─ 🔶 ReadMcpResourceTool → localScale value
│  ├─ Step 3: Calculate actual collision range
│  │  └─ Formula: actual range = collider.size × localScale
│  ├─ Step 4: Fix scene objects
│  │  ├─ 🔷 manage_components(action="set_property", property="radius", value=new_value)
│  │  └─ 🔷 manage_scene(action="save")
│  └─ Step 5: Fix Prefab
│     └─ 📁 Edit(file_path="xxx.prefab", old_string="m_Radius: old", new_string="m_Radius: new")
│
├─ Collision Not Being Detected
│  ├─ Step 1: Check both Colliders
│  │  └─ 🔶 ReadMcpResourceTool → Collider2D component exists
│  ├─ Step 2: Check Rigidbody exists
│  │  └─ 🔶 ReadMcpResourceTool → At least one has Rigidbody
│  ├─ Step 3: Check isTrigger setting
│  │  └─ 🔶 ReadMcpResourceTool → Matches callback method
│  └─ Step 4: Check Tag setting
│     └─ 🔶 ReadMcpResourceTool → tag field
│
└─ Self-Collision False Positive
   ├─ Step 1: Check collision ignore configuration
   │  └─ 🔶 ReadMcpResourceTool → _minCollisionSegmentIndex
   ├─ Step 2: Check segment index
   │  └─ 🔶 ReadMcpResourceTool → segment.Index
   └─ Step 3: Fix
      ├─ 📁 Edit → Modify default value in code
      ├─ 🔷 manage_components → Modify scene value
      └─ 🔷 manage_scene(action="save")
```

### 6. Scene Issues

```
Scene Issues
│
├─ Scene Switch Failed
│  ├─ Step 1: Check Build Settings
│  │  └─ 🔷 manage_scene(action="get_build_settings")
│  ├─ Step 2: Check scene name/index
│  │  └─ 📁 Read → Check LoadScene call
│  └─ Step 3: Check loading code
│     └─ 📁 Read → Check SceneManager calls
│
├─ Scene State Incorrect After Loading
│  ├─ Cause: Loading game scene directly, skipping normal flow
│  ├─ Diagnosis: 🔶 ReadMcpResourceTool → GameManager.CurrentState
│  └─ Solution: Start testing from start scene (MainMenu)
│     ├─ 🔷 manage_editor(action="stop")
│     ├─ 🔷 manage_scene(action="load", build_index=0)
│     ├─ 🔷 manage_editor(action="play")
│     └─ 👤 AskUserQuestion → Request user to click START
│
└─ Scene Content Missing
   ├─ Step 1: Check DontDestroyOnLoad
   │  └─ 📁 Read → Check Awake settings
   └─ Step 2: Check singleton preservation
      └─ 📁 Read → Check Singleton implementation
```

---

## User Interaction Patterns

### Pattern 1: Single Step Confirmation

For scenarios requiring user to perform a single action.

```
[AskUserQuestion]
  "Please click the START button"
  Options: Done | Problem encountered
```

### Pattern 2: Batch Operation Confirmation

For scenarios requiring user to perform a series of actions.

```
[AskUserQuestion]
  "Please complete the following:
   1. Click START button to enter game
   2. Move snake using arrow keys
   3. Try to eat a food item

   Select result after completion"
  Options: All succeeded | Partial failure | Need help
```

### Pattern 3: Observation Confirmation

For scenarios requiring user to observe and report results.

```
[AskUserQuestion]
  "Please observe the Game view and answer:
   - Is the border fully visible?
   - Is the snake head visible?
   - Are there any abnormal lines or graphics?"
  Options: Display normal | Has issues (please describe) | Not sure
```

---

## Tool Quick Reference

| Source | Tool | Purpose | Key Parameters |
|--------|------|---------|----------------|
| 🔷 UnityMCP | `manage_editor` | Play/stop | `action="play"` or `action="stop"` |
| 🔷 UnityMCP | `find_gameobjects` | Find objects | `search_term="xxx", search_method="by_name/by_tag/by_component"` |
| 🔷 UnityMCP | `read_console` | View logs | `types=["all"], count=30` |
| 🔷 UnityMCP | `manage_scene` | Scene operations | `action="load/save/get_active/get_build_settings/screenshot"` |
| 🔷 UnityMCP | `manage_components` | Modify components | `action="set_property", target=id, property="xxx", value=xxx` |
| 🔷 UnityMCP | `manage_gameobject` | Modify objects | `action="modify", target=id, ...` |
| 🔷 UnityMCP | `manage_prefabs` | Modify prefabs | `action="modify_contents", prefab_path="..."` |
| 🔷 UnityMCP | `refresh_unity` | Refresh assets | `compile="request", wait_for_ready=true` |
| 🔶 MCP Resource | `ReadMcpResourceTool` | Read components | `server="UnityMCP", uri="mcpforunity://scene/gameobject/{id}/components"` |
| 📁 File | `Read` | Read file | `file_path="D:/xxx/xxx.cs"` |
| 📁 File | `Edit` | Edit file | `file_path="...", old_string="...", new_string="..."` |
| 📁 File | `Glob` | Find files | `pattern="**/*.cs"` |
| 💻 Bash | `Bash` | Execute commands | `command="win-shot.exe ..."` |
| 👤 Interaction | `AskUserQuestion` | User confirmation | `questions=[{question, options, ...}]` |

---

## Debug Session Example

```
1. [manage_editor] play → Enter play mode
2. [manage_scene] screenshot → Take screenshot
3. [Read] screenshot.png → Analyze screenshot
4. Found issue: UI not showing
5. [read_console] → No compilation errors
6. [find_gameobjects] MainMenuView → Found component
7. [ReadMcpResourceTool] → Check _startHidden = true
8. [manage_editor] stop → Stop play mode
9. [manage_components] set_property _startHidden = false
10. [manage_scene] save → Save scene
11. [manage_editor] play → Re-enter play mode
12. [manage_scene] screenshot → Screenshot for verification
13. [AskUserQuestion] "Please click START button" → Wait for user action
14. User selects "Done"
15. [manage_scene] get_active → Confirm scene switch
16. [manage_scene] screenshot → Final screenshot verification
```
