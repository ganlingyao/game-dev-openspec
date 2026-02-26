---
name: design-unity
description: Unity game architecture design capability. Used for project structure design, Manager module templates, pseudocode writing, and design pattern application. Automatically triggered during the design phase.
---

# Design Unity Skill - Unity Architecture Design Capability

This Skill provides Unity game architecture design capabilities, including project structure, design patterns, pseudocode writing, etc.

---

## XDUF Framework (Recommended Base Framework)

**Repository:** `git@git-huge.xindong.com:ganlingyao/xduf.git`

XDUF (XD Unity Framework) is a production-ready, modular framework with:
- **174 unit tests** with 100% pass rate
- **Zero-GC event system** for high-performance messaging
- **Lock-free object pooling** with leak detection
- **Async resource loading** with reference counting
- **Game state machine** with scene management

### Framework Modules

| Module | Namespace | Purpose |
|--------|-----------|---------|
| Core | `XDUF` | Base interfaces (`IManager`) |
| Events | `XDUF.Events` | Type-safe pub/sub event bus |
| Config | `XDUF.Config` | JSON/ScriptableObject configuration |
| Resource | `XDUF.Resource` | Async resource loading with caching |
| Pooling | `XDUF.Pooling` | Object pooling with diagnostics |
| GameFramework | `XDUF.GameFramework` | Game state machine, scene loading |
| Input | `XDUF.Input` | Input abstraction layer |
| Diagnostics | `XDUF.Diagnostics` | Logging system |

### Integration Strategies

| Level | Strategy | When to Use |
|-------|----------|-------------|
| **L1** | Direct Integration | New projects - clone as base |
| **L2** | Selective Adoption | Existing projects - integrate specific modules |
| **L3** | Reference Implementation | Special requirements - study patterns only |

### Quick Start

```bash
# Clone XDUF as project base
git clone git@git-huge.xindong.com:ganlingyao/xduf.git MyProject

# Or add as submodule
git submodule add git@git-huge.xindong.com:ganlingyao/xduf.git Assets/XDUF
```

See detailed guides:
- [XDUF_INTEGRATION.md](./framework/XDUF_INTEGRATION.md) - Complete integration guide
- [PATTERNS.md](./framework/PATTERNS.md) - Design patterns reference
- [MIGRATION.md](./framework/MIGRATION.md) - Migration strategies

---

## Part 1: Project Architecture Template

### Unity Project Structure (Feature-Based)

```
Assets/
│
├── Scripts/                     # All script code
│   │
│   ├── Core/                    # Core systems (reusable across projects)
│   │   ├── Base/                # Base classes (Singleton, StateMachine)
│   │   ├── Events/              # Event system (GameEvents, EventBus)
│   │   ├── Managers/            # Managers (GameManager, AudioManager, UIManager)
│   │   └── Utils/               # Utilities (ObjectPool, Timer, Extensions)
│   │
│   ├── Gameplay/                # Gameplay logic (project specific)
│   │   ├── Player/              # Player system (PlayerController, PlayerInput)
│   │   ├── Enemies/             # Enemy system (EnemyAI, EnemySpawner)
│   │   ├── Items/               # Item system (ItemPickup, Inventory)
│   │   ├── Combat/              # Combat system (DamageSystem, Projectile)
│   │   ├── Level/               # Level system (LevelManager, Checkpoint)
│   │   └── {Feature}/           # Other feature modules added as needed
│   │
│   ├── UI/                      # UI scripts
│   │   ├── Views/               # View controllers (MainMenuView, GameHUDView)
│   │   ├── Components/          # Reusable components (HealthBar, ProgressBar)
│   │   ├── Popups/              # Popups (SettingsPopup, ConfirmDialog)
│   │   └── Widgets/             # Widgets (Button, Toggle)
│   │
│   ├── Data/                    # Data definitions
│   │   ├── ScriptableObjects/   # SO class definitions (GameConfig, EnemyData)
│   │   ├── Constants/           # Constants (GameConstants, Tags, Layers)
│   │   └── Enums/               # Enum definitions (GameState, ItemType)
│   │
│   ├── Editor/                  # Editor extension scripts
│   │   ├── Tools/               # Custom tools
│   │   ├── Inspectors/          # Custom Inspectors
│   │   └── Windows/             # Custom Windows
│   │
│   └── Tests/                   # Test code
│       ├── EditMode/            # EditMode tests
│       └── PlayMode/            # PlayMode tests
│
├── Art/                         # Art assets
│   ├── Sprites/                 # Sprites
│   │   ├── Characters/          # Character sprites
│   │   ├── Environment/         # Environment sprites
│   │   ├── UI/                  # UI sprites
│   │   └── Effects/             # Effect sprites
│   │
│   ├── Animations/              # Animation assets
│   │   ├── Characters/          # Character animations
│   │   └── UI/                  # UI animations
│   │
│   ├── Materials/               # Materials
│   ├── Shaders/                 # Shaders
│   └── Textures/                # Textures
│
├── Prefabs/                     # Prefabs
│   ├── Characters/              # Character prefabs
│   │   ├── Player/
│   │   └── Enemies/
│   ├── Environment/             # Environment prefabs
│   ├── Items/                   # Item prefabs
│   ├── Effects/                 # Effect prefabs
│   └── UI/                      # UI prefabs
│       ├── Views/               # View prefabs
│       ├── Components/          # Component prefabs
│       └── Popups/              # Popup prefabs
│
├── Scenes/                      # Scene files
│   ├── Main/                    # Main scenes
│   ├── Levels/                  # Level scenes
│   └── Test/                    # Test scenes
│
├── ScriptableObjects/           # SO asset instances
│   ├── Config/                  # Config data (GameConfig.asset)
│   ├── GameData/                # Game data (EnemyData.asset)
│   └── Events/                  # Event assets (OnPlayerDied.asset)
│
├── Audio/                       # Audio assets
│   ├── Music/                   # Background music
│   ├── SFX/                     # SFX
│   └── Mixers/                  # Audio Mixer
│
├── Fonts/                       # Font files
│
├── ThirdParty/                  # Third-party assets (manually imported)
│
├── Resources/                   # Runtime dynamically loaded assets (use with caution)
│
└── StreamingAssets/             # Streaming assets
```

### Structure Design Principles

1. **Feature Module Separation**
   - `Scripts/` - All code centralized, separated by feature: Core/Gameplay/UI/Data
   - `Art/` - All art assets centralized, separated by type: Sprites/Animations/Materials
   - `Prefabs/` - All prefabs centralized, classified by feature

2. **Clear Hierarchy**
   - `Core/` - Reusable infrastructure across projects, no game logic dependencies
   - `Gameplay/` - Project-specific game logic
   - `Data/` - Pure data definitions, no behavioral logic

3. **Test Friendly**
   - `Scripts/Tests/` - Test code at the same level as source code
   - `EditMode/` and `PlayMode/` separated

4. **Asset Management**
   - `Resources/` - Only place assets that must be loaded dynamically at runtime
   - `ThirdParty/` - Isolate third-party assets for easy upgrade management
   - Use Addressables instead of Resources (Recommended)

5. **Naming Conventions**
   - Use PascalCase for folders
   - Correspond to code namespaces (e.g., `Scripts/Gameplay/Player/` → `namespace Game.Gameplay.Player`)

---

## Part 2: Design Pattern Templates

### 1. Singleton Pattern (Managers)

```csharp
public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);
    }

    private void OnDestroy()
    {
        if (Instance == this)
        {
            Instance = null;
        }
    }
}
```

### 2. Event System

```csharp
// Method A: C# Events
public class Player : MonoBehaviour
{
    public static event Action<int> OnScoreChanged;
    public static event Action OnDied;

    public void AddScore(int points)
    {
        _score += points;
        OnScoreChanged?.Invoke(_score);
    }
}

// Subscriber
private void OnEnable() => Player.OnScoreChanged += HandleScoreChanged;
private void OnDisable() => Player.OnScoreChanged -= HandleScoreChanged;
```

```csharp
// Method B: ScriptableObject Events
[CreateAssetMenu(menuName = "Events/Game Event")]
public class GameEvent : ScriptableObject
{
    private List<IGameEventListener> _listeners = new();

    public void Raise()
    {
        for (int i = _listeners.Count - 1; i >= 0; i--)
            _listeners[i].OnEventRaised();
    }

    public void RegisterListener(IGameEventListener listener) => _listeners.Add(listener);
    public void UnregisterListener(IGameEventListener listener) => _listeners.Remove(listener);
}
```

### 3. State Machine

```csharp
public enum GameState { Menu, Playing, Paused, GameOver }

public class GameManager : MonoBehaviour
{
    private GameState _currentState;
    public static event Action<GameState> OnStateChanged;

    public void ChangeState(GameState newState)
    {
        if (_currentState == newState) return;

        ExitState(_currentState);
        _currentState = newState;
        EnterState(_currentState);
        OnStateChanged?.Invoke(_currentState);
    }

    private void EnterState(GameState state)
    {
        switch (state)
        {
            case GameState.Playing: Time.timeScale = 1f; break;
            case GameState.Paused: Time.timeScale = 0f; break;
        }
    }
}
```

### 4. Object Pool

```csharp
public class ObjectPool : MonoBehaviour
{
    [SerializeField] private GameObject _prefab;
    [SerializeField] private int _initialSize = 10;
    private Queue<GameObject> _pool = new();

    private void Awake()
    {
        for (int i = 0; i < _initialSize; i++)
            CreateObject();
    }

    public GameObject Get()
    {
        if (_pool.Count == 0) CreateObject();
        var obj = _pool.Dequeue();
        obj.SetActive(true);
        return obj;
    }

    public void Return(GameObject obj)
    {
        obj.SetActive(false);
        _pool.Enqueue(obj);
    }

    private void CreateObject()
    {
        var obj = Instantiate(_prefab, transform);
        obj.SetActive(false);
        _pool.Enqueue(obj);
    }
}
```

### 5. ScriptableObject Configuration

```csharp
[CreateAssetMenu(fileName = "PlayerConfig", menuName = "Config/Player Config")]
public class PlayerConfig : ScriptableObject
{
    [Header("Movement")]
    public float MoveSpeed = 5f;
    public float JumpForce = 10f;

    [Header("Combat")]
    public int MaxHealth = 100;
    public int AttackDamage = 10;
}
```

---

## Part 3: Pseudocode Format Standards

### Basic Format

```
class ClassName:
    # Properties
    - propertyName: Type
    - anotherProperty: Type = defaultValue

    # Methods
    method MethodName(param1: Type, param2: Type) -> ReturnType:
        ...
```

### Complete Example

```
class GameManager:
    # State
    - state: GameState (Menu, Playing, Paused, GameOver)
    - score: int = 0
    - lives: int = 3
    - eventBus: EventBus

    # Singleton
    - static instance: GameManager

    method Initialize():
        instance = this
        state = Menu
        eventBus = new EventBus()

    method StartGame():
        state = Playing
        score = 0
        lives = 3
        eventBus.Emit("GameStarted")
        SpawnPlayer()

    method Update():
        if state != Playing: return
        UpdateGameLogic()
        CheckWinCondition()
        CheckLoseCondition()

    method AddScore(points: int):
        score += points
        eventBus.Emit("ScoreChanged", score)

    method GameOver():
        state = GameOver
        eventBus.Emit("GameOver", score)
```

### Control Flow

```
# Condition
if condition:
    DoSomething()
elif otherCondition:
    DoOther()
else:
    DoDefault()

# Loop
for item in collection:
    Process(item)

for i = 0 to count - 1:
    Process(i)

while condition:
    DoSomething()

# Early Return
method Attack(target: Enemy):
    if target == null: return
    if not CanAttack(): return

    damage = CalculateDamage()
    target.TakeDamage(damage)
```

### Events

```
class Player:
    - event OnDamaged(damage: int, health: int)
    - event OnDied()

    method TakeDamage(amount: int):
        health -= amount
        Emit OnDamaged(amount, health)
        if health <= 0:
            Emit OnDied()
```

---

## Part 4: Design Document Output Format

```markdown
# Design: [Game Name]

## 1. Project Architecture

[Use the above project structure template, adjust as needed]

## 2. Core System Design

### [System Name]
- **Responsibility**: What this system does
- **Pattern**: Design patterns used
- **Dependencies**: What it depends on, what depends on it

**Pseudocode:**
```
class SystemName:
    ...
```

## 3. Component Relationships

```
InputHandler → PlayerController → Movement
                               → Combat
             → UIController → PauseMenu

GameManager ←→ EventBus ←→ All Systems
```

## 4. Technical Decisions

### Decision 1: [Decision Name]
- **Decision**: What was chosen
- **Alternatives**: What options were available
- **Reason**: Why it was chosen
- **Trade-offs**: Known limitations

## 5. Data Management

- Config Data: ScriptableObjects
- Runtime State: [Solution]
- Save/Load: [Solution]

## 6. Performance Considerations

- Object Pooling: [Candidates]
- Update Optimization: [Strategy]

## 7. Risk Mitigation

| Risk | Mitigation |
|------|----------|
| [Risk] | [Mitigation] |
```

---

## Trigger Conditions

This Skill is automatically triggered in the following situations:
- When executing the design phase
- When designing Unity project architecture
- When writing pseudocode
- When applying design patterns
