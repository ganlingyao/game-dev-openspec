# XDUF Design Patterns

Reference guide for design patterns used in and recommended by XDUF framework.

---

## Core Patterns

### 1. Service Locator with Explicit Configuration

XDUF's ResourceManager demonstrates a hybrid pattern: singleton access with explicit configuration.

```csharp
public sealed class ResourceManager : IResourceManager
{
    private static ResourceManager _instance;
    private static bool _isConfigured;

    // Explicit configuration (recommended)
    public static ResourceManager Configure(IResourceLoader loader, ResourceSettings settings)
    {
        _instance = new ResourceManager(loader ?? new DefaultResourceLoader(), settings ?? new ResourceSettings());
        _isConfigured = true;
        return _instance;
    }

    // Global access (after configuration)
    public static ResourceManager Instance
    {
        get
        {
            if (!_isConfigured)
            {
                Debug.LogWarning("ResourceManager accessed before Configure()");
                _instance = new ResourceManager(null, null);
            }
            return _instance;
        }
    }
}

// Usage:
ResourceManager.Configure(customLoader, customSettings);
var resource = await ResourceManager.Instance.LoadAsync<Texture>("path");
```

**Benefits:**
- Explicit dependency injection during initialization
- Convenient global access after setup
- Testable via SetInstance() or Configure()

---

### 2. Interface Segregation

XDUF uses focused interfaces for each responsibility:

```csharp
// Core lifecycle interface
public interface IManager
{
    void Initialize();
    void Shutdown();
}

// Specific service interfaces extend IManager
public interface IPoolingService : IManager
{
    void RegisterPrefab(string key, GameObject prefab);
    GameObject Rent(string key);
    void Return(string key, GameObject obj);
    PoolMetrics GetMetrics(string key);
}

public interface IEventManager : IManager
{
    IDisposable Subscribe<T>(Action<T> handler) where T : struct;
    void Publish<T>(in T evt) where T : struct;
}
```

---

### 3. Strategy Pattern (Exhaustion Strategies)

```csharp
public enum PoolExhaustionStrategy
{
    Instantiate,  // Create new instance
    Wait,         // Wait for available object (coroutine)
    Throw         // Throw exception
}

// In ObjectPool
private T HandleExhaustion()
{
    switch (_config.DefaultExhaustionStrategy)
    {
        case PoolExhaustionStrategy.Instantiate:
            return InstantiateObject();
        case PoolExhaustionStrategy.Wait:
            throw new InvalidOperationException("Use RentWithWaitCoroutine()");
        case PoolExhaustionStrategy.Throw:
            throw new InvalidOperationException("Pool exhausted");
        default:
            return null;
    }
}
```

---

### 4. Observer Pattern (Event System)

Zero-allocation event system using copy-on-write:

```csharp
// Event definition (readonly struct = zero GC)
public readonly struct PlayerDamaged
{
    public readonly int PlayerId;
    public readonly float Damage;
    public readonly Vector3 HitPoint;

    public PlayerDamaged(int playerId, float damage, Vector3 hitPoint)
    {
        PlayerId = playerId;
        Damage = damage;
        HitPoint = hitPoint;
    }
}

// Subscribing
private IDisposable _subscription;

void OnEnable()
{
    _subscription = _eventManager.Subscribe<PlayerDamaged>(OnPlayerDamaged);
}

void OnDisable()
{
    _subscription?.Dispose();
}

// Publishing
_eventManager.Publish(new PlayerDamaged(playerId, damage, hitPoint));
```

**Key Design Decisions:**
- `readonly struct` prevents heap allocation
- `in` parameter avoids copying
- `IDisposable` return enables RAII cleanup

---

### 5. Object Pool Pattern

```csharp
// Implement IPoolable for custom lifecycle
public class Bullet : MonoBehaviour, IPoolable, IResettable
{
    private Rigidbody _rb;
    private TrailRenderer _trail;

    public void OnRent()
    {
        _trail.Clear();
    }

    public void OnReturn()
    {
        _rb.linearVelocity = Vector3.zero;
    }

    public void OnReset()
    {
        // Full state reset
    }
}

// Usage
_poolingService.RegisterPrefab("Bullet", bulletPrefab);
await _poolingService.PrewarmAsync("Bullet", 100);

var bullet = _poolingService.Rent("Bullet");
_poolingService.Return("Bullet", bullet);
```

---

### 6. State Machine Pattern

```csharp
public enum GameState
{
    Boot, MainMenu, InGame, Paused, Result
}

// Transition rules
_gameManager.AddAllowedTransition(GameState.Boot, GameState.MainMenu);
_gameManager.AddAllowedTransition(GameState.MainMenu, GameState.InGame);
_gameManager.AddAllowedTransition(GameState.InGame, GameState.Paused);
_gameManager.AddAllowedTransition(GameState.InGame, GameState.Result);

// Subscribe to state changes
_eventManager.Subscribe<StateChanged>(e => {
    if (e.NewState == GameState.Paused)
        Time.timeScale = 0f;
});

// Change state
_gameManager.ChangeState(GameState.InGame);
```

---

### 7. Constructor Injection

```csharp
public class GameService : IManager
{
    private readonly IEventManager _events;
    private readonly IConfigManager _config;

    // Dependencies are explicit and required
    public GameService(IEventManager events, IConfigManager config)
    {
        _events = events ?? throw new ArgumentNullException(nameof(events));
        _config = config ?? throw new ArgumentNullException(nameof(config));
    }
}
```

---

## Anti-Patterns to Avoid

### 1. Service Locator Abuse

```csharp
// Bad: Hidden dependencies
public class Player
{
    public void TakeDamage(float damage)
    {
        ServiceLocator.Get<IEventManager>().Publish(new PlayerDamaged(...));
    }
}

// Good: Explicit dependencies
public class Player
{
    private readonly IEventManager _events;

    public Player(IEventManager events)
    {
        _events = events;
    }

    public void TakeDamage(float damage)
    {
        _events.Publish(new PlayerDamaged(...));
    }
}
```

### 2. Event Payload Mutation

```csharp
// Bad: Mutable event
public struct PlayerMoved
{
    public Vector3 Position; // Can be modified!
}

// Good: Immutable event
public readonly struct PlayerMoved
{
    public readonly Vector3 Position;
    public PlayerMoved(Vector3 position) => Position = position;
}
```

### 3. Forgetting to Release Resources

```csharp
// Bad: Memory leak
async void LoadEnemy()
{
    var prefab = await _resources.LoadAsync<GameObject>("Enemy");
    Instantiate(prefab);
    // Never released!
}

// Good: Proper lifecycle
private GameObject _enemyPrefab;

async Task LoadEnemy()
{
    _enemyPrefab = await _resources.LoadAsync<GameObject>("Enemy");
}

void OnDestroy()
{
    if (_enemyPrefab != null)
        _resources.Release(_enemyPrefab);
}
```
