# Unity Design Patterns Reference

## 1. Singleton Pattern (Managers)

**When to Use**: Global managers that need single instance access

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

---

## 2. Event System

### Method A: C# Events (Simple)

```csharp
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

### Method B: XDUF Events (Zero-GC, Recommended)

```csharp
// Event definition (readonly struct)
public readonly struct ScoreChanged
{
    public readonly int NewScore;
    public ScoreChanged(int newScore) => NewScore = newScore;
}

// Publisher
_eventManager.Publish(in new ScoreChanged(100));

// Subscriber
_subscription = _eventManager.Subscribe<ScoreChanged>(OnScoreChanged);
// Cleanup
_subscription?.Dispose();
```

### Method C: ScriptableObject Events (Designer-Friendly)

```csharp
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

---

## 3. State Machine

**When to Use**: Objects with distinct states and transitions

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

---

## 4. Object Pool

### Basic Implementation

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

### XDUF Pooling (Recommended)

```csharp
// Register
_poolingService.RegisterPrefab("bullet", bulletPrefab);
_poolingService.PrewarmAsync("bullet", 10);

// Rent
var bullet = _poolingService.Rent("bullet");

// Return
_poolingService.Return("bullet", bullet);
```

---

## 5. ScriptableObject Configuration

**When to Use**: Designer-editable data, shared configuration

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

## 6. Constructor Injection (XDUF Pattern)

**When to Use**: Testable services with explicit dependencies

```csharp
public class PlayerController : IManager
{
    private readonly IEventManager _events;
    private readonly IInputService _input;

    public PlayerController(IEventManager events, IInputService input)
    {
        _events = events ?? throw new ArgumentNullException(nameof(events));
        _input = input ?? throw new ArgumentNullException(nameof(input));
    }

    public void Initialize()
    {
        _subscription = _events.Subscribe<InputReceived>(OnInput);
    }

    public void Shutdown()
    {
        _subscription?.Dispose();
    }
}
```

---

## Pattern Selection Guide

| Scenario | Recommended Pattern |
|----------|---------------------|
| Global managers | Singleton or Constructor Injection |
| System communication | XDUF Events (zero-GC) |
| Designer-editable events | ScriptableObject Events |
| Objects with states | State Machine |
| Frequent spawn/despawn | XDUF Pooling |
| Configuration data | ScriptableObject |
| Testable services | Constructor Injection |
