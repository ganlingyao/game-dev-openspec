# Problem Diagnosis Decision Trees

## 0. Common Diagnosis Steps (Execute first for all issues)

```
Common Diagnosis Steps
|
|- Step 1: Confirm play mode
|  -> manage_editor(action="play") or confirm already in play mode
|
|- Step 2: Screenshot current state
|  |- manage_scene(action="screenshot")
|  -> Read(file_path="screenshot.png")
|
|- Step 3: Check console logs
|  -> read_console(types=["all"], count=30)
|
|- Step 4: Confirm game state
|  |- find_gameobjects(search_term="GameManager", search_method="by_name")
|  |- ReadMcpResourceTool(server="UnityMCP", uri="mcpforunity://scene/gameobject/{id}/components")
|  -> Check: CurrentState is expected value
|
-> Step 5: Locate issue-related objects
   -> find_gameobjects(search_term="issue-related object name")
```

---

## 1. State Flag Issues

```
State Flag Issues
|
|- Common State Flags and Meanings
|  |- IsAlive / _isDead      -> Object alive/dead state
|  |- _isInitialized         -> Initialization complete flag
|  |- IsSpawning             -> Spawner running state
|  |- _isActive / IsActive   -> Activation state
|  |- CurrentState           -> Game/scene state enum
|  |- _collisionEnabled      -> Collision detection switch
|  -> IsVisible / _startHidden -> UI visibility state
|
|- Diagnosis Steps
|  |- Step 1: Find target object
|  |  -> find_gameobjects(search_term="object name", search_method="by_name")
|  |- Step 2: Read component properties
|  |  -> ReadMcpResourceTool(server="UnityMCP", uri="mcpforunity://scene/gameobject/{id}/components")
|  -> Step 3: Check all Is/Has/Can/_is prefixed properties
|
-> Common Issues
   |- IsAlive=false but object expected alive -> Check death trigger conditions
   |- _isInitialized=false -> Check if Initialize method was called
   |- IsSpawning=false -> Check StartSpawning trigger conditions
   -> CurrentState incorrect -> Check scene loading method
```

---

## 2. Functionality/Interaction Issues

```
Functionality/Interaction Issues
|
|- Button/UI Interaction Not Responding
|  |- Step 1: Check EventSystem
|  |  -> find_gameobjects(search_term="EventSystem", search_method="by_name")
|  |- Step 2: Check Button component
|  |  -> ReadMcpResourceTool -> View onClick bindings
|  |- Step 3: Check script Button references
|  |  -> ReadMcpResourceTool -> Check if _xxxButton is null
|  |- Step 4: Check GraphicRaycaster
|  |  -> find_gameobjects(search_term="Canvas") -> Read components
|  -> Step 5: Check code logic
|     -> Read(file_path="script path")
|
|- Keyboard/Input Not Responding
|  |- Step 1: Confirm Input System type
|  |  -> Glob(pattern="**/InputSystem*.cs") or check Project Settings
|  |- Step 2: Check input handling code
|  |  -> Read(file_path="input script")
|  -> Step 3: Check Time.timeScale
|     -> read_console to check if paused
|
-> Event Not Firing
   |- Step 1: Check Manager singleton
   |  -> ReadMcpResourceTool -> Confirm Instance != null
   |- Step 2: Check event subscription code
   |  -> Read -> Check += subscriptions in OnEnable
   -> Step 3: Add debug logs to confirm
      -> Edit -> Add Debug.Log
```

---

## 3. UI/Display Issues

```
UI/Display Issues
|
|- UI Not Showing At All
|  |- Step 1: Check Canvas
|  |  |- find_gameobjects(search_term="Canvas", search_method="by_name")
|  |  -> ReadMcpResourceTool -> Check enabled, renderMode
|  |- Step 2: Check UI object state
|  |  -> ReadMcpResourceTool -> Check _startHidden, IsVisible
|  |- Step 3: Check GameObject.activeSelf
|  |  -> ReadMcpResourceTool -> gameObject state in Transform data
|  |- Step 4: Check CanvasGroup
|  |  -> ReadMcpResourceTool -> Check if alpha is 0
|  -> Step 5: Fix
|     |- manage_components(action="set_property", property="_startHidden", value=false)
|     -> manage_scene(action="save")
|
|- UI Content Not Updating
|  |- Step 1: Check Text/TMP references
|  |  -> ReadMcpResourceTool -> Check if _scoreText etc. is null
|  |- Step 2: Check update methods
|  |  -> Read -> Check UpdateScore etc. methods
|  -> Step 3: Check event subscriptions
|     -> Read -> Check OnScoreChanged subscriptions
|
-> UI Position/Size Wrong
   |- Step 1: Check RectTransform
   |  -> ReadMcpResourceTool -> Check anchor, pivot
   -> Step 2: Check Canvas Scaler
      -> ReadMcpResourceTool -> Check scaleMode
```

---

## 4. GameObject/Spawner Issues

```
GameObject/Spawner Issues
|
|- Object Not Spawning
|  |- Step 1: Confirm object truly doesn't exist
|  |  -> find_gameobjects(search_term="object name", search_method="by_tag")
|  |- Step 2: Check Spawner exists
|  |  -> find_gameobjects(search_term="XXXSpawner")
|  |- Step 3: Check Spawner state
|  |  |- ReadMcpResourceTool
|  |  -> Key properties: IsSpawning, ActiveCount, _prefab reference
|  |- Step 4: Check GameManager state
|  |  |- find_gameobjects(search_term="GameManager")
|  |  |- ReadMcpResourceTool
|  |  -> Check: CurrentState should be Playing
|  -> Step 5: Check scene loading method
|     -> AskUserQuestion -> Confirm if started from MainMenu
|
|- Object Spawning at Wrong Position
|  |- Step 1: Check Spawner configuration
|  |  -> ReadMcpResourceTool -> Check _gridMin, _gridMax
|  -> Step 2: Check coordinate system
|     -> Read -> Check if using centered coordinates
|
-> Object Not Being Destroyed
   |- Step 1: Check recycling logic
   |  -> Read -> Check HandleXXXConsumed methods
   -> Step 2: Check ObjectPool
      -> ReadMcpResourceTool -> Check _pool reference
```

---

## 5. Movement/Physics Issues

```
Movement/Physics Issues
|
|- Object Not Moving/Stuck
|  |- Step 1: Check console logs
|  |  -> read_console -> Check for collision or error messages
|  |- Step 2: Check controller script state
|  |  |- find_gameobjects(search_term="controlled object")
|  |  |- ReadMcpResourceTool
|  |  -> Key properties: IsAlive, _isInitialized, _isDead
|  |- Step 3: Check Rigidbody
|  |  -> ReadMcpResourceTool -> bodyType, isKinematic
|  |- Step 4: Check collider blocking
|  |  -> ReadMcpResourceTool -> isTrigger setting
|  -> Step 5: Fix state flags
|     -> Edit -> Modify related code
|
|- Collision Triggering Too Early/Late
|  |- Step 1: Check collider configuration
|  |  |- find_gameobjects(search_term="object name")
|  |  -> ReadMcpResourceTool -> radius/size, offset
|  |- Step 2: Check Transform.localScale
|  |  -> ReadMcpResourceTool -> localScale value
|  |- Step 3: Calculate actual collision range
|  |  -> Formula: actual range = collider.size x localScale
|  |- Step 4: Fix scene objects
|  |  |- manage_components(action="set_property", property="radius", value=new_value)
|  |  -> manage_scene(action="save")
|  -> Step 5: Fix Prefab
|     -> Edit(file_path="xxx.prefab", old_string="m_Radius: old", new_string="m_Radius: new")
|
|- Collision Not Being Detected
|  |- Step 1: Check both Colliders
|  |  -> ReadMcpResourceTool -> Collider2D component exists
|  |- Step 2: Check Rigidbody exists
|  |  -> ReadMcpResourceTool -> At least one has Rigidbody
|  |- Step 3: Check isTrigger setting
|  |  -> ReadMcpResourceTool -> Matches callback method
|  -> Step 4: Check Tag setting
|     -> ReadMcpResourceTool -> tag field
|
-> Self-Collision False Positive
   |- Step 1: Check collision ignore configuration
   |  -> ReadMcpResourceTool -> _minCollisionSegmentIndex
   |- Step 2: Check segment index
   |  -> ReadMcpResourceTool -> segment.Index
   -> Step 3: Fix
      |- Edit -> Modify default value in code
      |- manage_components -> Modify scene value
      -> manage_scene(action="save")
```

---

## 6. Scene Issues

```
Scene Issues
|
|- Scene Switch Failed
|  |- Step 1: Check Build Settings
|  |  -> manage_scene(action="get_build_settings")
|  |- Step 2: Check scene name/index
|  |  -> Read -> Check LoadScene call
|  -> Step 3: Check loading code
|     -> Read -> Check SceneManager calls
|
|- Scene State Incorrect After Loading
|  |- Cause: Loading game scene directly, skipping normal flow
|  |- Diagnosis: ReadMcpResourceTool -> GameManager.CurrentState
|  -> Solution: Start testing from start scene (MainMenu)
|     |- manage_editor(action="stop")
|     |- manage_scene(action="load", build_index=0)
|     |- manage_editor(action="play")
|     -> AskUserQuestion -> Request user to click START
|
-> Scene Content Missing
   |- Step 1: Check DontDestroyOnLoad
   |  -> Read -> Check Awake settings
   -> Step 2: Check singleton preservation
      -> Read -> Check Singleton implementation
```
