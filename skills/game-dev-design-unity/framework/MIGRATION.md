# Migration Guide

Strategies for migrating existing Unity projects to XDUF framework.

---

## Migration Assessment

| Question | If Yes | If No |
|----------|--------|-------|
| Is this a new project? | Use L1 Direct Integration | Continue assessment |
| Do you have existing event system? | Consider keeping or migrating | Adopt XDUF.Events |
| Do you have object pooling? | Compare performance, migrate if better | Adopt XDUF.Pooling |
| Is your codebase < 10k LOC? | Full migration feasible | Incremental migration |
| Do you have comprehensive tests? | Safer to migrate | Write tests first |

---

## Migration Strategies

### Strategy 1: Big Bang (Small Projects)

Replace entire framework at once.

**When to use:**
- Project < 10,000 lines of code
- Good test coverage
- Team available for focused effort

**Timeline:** 1-2 weeks

---

### Strategy 2: Strangler Fig (Large Projects)

Gradually replace old systems with XDUF equivalents.

**When to use:**
- Large codebase
- Production system
- Limited refactoring time

**Phases:**

1. **Add XDUF Alongside** - Keep legacy code working
2. **Create Adapters** - Bridge legacy to XDUF interfaces
3. **Migrate Feature by Feature** - One system at a time
4. **Remove Legacy** - Delete old code when migrated

**Timeline:** 4-12 weeks

---

### Strategy 3: Module-by-Module (Recommended)

Adopt XDUF modules one at a time based on value.

**Recommended Order:**

1. **Events** - Zero-GC, highest impact
2. **Pooling** - Performance improvement
3. **Resource** - Async loading benefits
4. **GameFramework** - State management

---

## Common Migration Tasks

### Migrating Event Systems

#### From C# Events
```csharp
// Before
public static event Action<Enemy> OnEnemyKilled;
void Kill() => OnEnemyKilled?.Invoke(this);

// After
public readonly struct EnemyKilled
{
    public readonly int EnemyId;
    public readonly int ScoreValue;
    public EnemyKilled(int id, int score)
    {
        EnemyId = id;
        ScoreValue = score;
    }
}

void Kill() => _events.Publish(new EnemyKilled(Id, ScoreValue));
```

### Migrating Object Pools

```csharp
// Before: Custom pool
public class BulletPool
{
    private Stack<GameObject> _pool = new Stack<GameObject>();
    public GameObject Get() { ... }
    public void Return(GameObject obj) { ... }
}

// After: XDUF pooling
_poolingService.RegisterPrefab("Bullet", bulletPrefab);
var bullet = _poolingService.Rent("Bullet");
_poolingService.Return("Bullet", bullet);

// Bonus: metrics
var metrics = _poolingService.GetMetrics("Bullet");
Debug.Log($"Active: {metrics.ActiveCount}, Available: {metrics.AvailableCount}");
```

### Migrating Singletons

```csharp
// Before: Basic singleton
public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }
    void Awake()
    {
        Instance = this;
        DontDestroyOnLoad(gameObject);
    }
}

// After: XDUF with DI
public class GameInitializer : MonoBehaviour
{
    private IGameManager _gameManager;

    void Awake()
    {
        var events = new EventManager();
        var sceneLoader = new SceneLoader(events, this);
        _gameManager = new GameManager(events, sceneLoader, MapScene);
        _gameManager.Initialize();
    }
}
```

---

## Testing During Migration

### Feature Flags

```csharp
public static class MigrationFlags
{
    public static bool UseXDUFEvents = true;
    public static bool UseXDUFPooling = false;  // Not yet migrated
}

// Usage
if (MigrationFlags.UseXDUFEvents)
    _xdufEvents.Publish(new EnemyKilled(id, score));
else
    LegacyEvents.Send("EnemyKilled", id, score);
```

### Rollback Plan

```bash
# If migration causes issues
git revert <migration-commit>
```

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Frame time | -10% |
| GC allocations/frame | -50% |
| Memory usage | -20% |
| Load time | -30% |
| Test coverage | +20% |

Use Unity Profiler and XDUF metrics to measure improvements.
