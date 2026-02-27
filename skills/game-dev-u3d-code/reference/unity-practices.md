# Unity Best Practices

## SerializeField Usage

```csharp
// Use [SerializeField] + Attribute Grouping
[Header("Movement Stats")]
[SerializeField][Range(1f, 20f)][Tooltip("The maximum movement speed.")]
private float _speed = 10f;

// Use RequireComponent to declare dependencies
[RequireComponent(typeof(Rigidbody2D))]
public class PlayerMovement : MonoBehaviour
{
    private Rigidbody2D _rb;

    private void Awake()
    {
        _rb = GetComponent<Rigidbody2D>();  // Cache in Awake
    }
}
```

---

## Prohibitions

| Prohibited | Reason | Alternative |
|------------|--------|-------------|
| `GameObject.Find()` in Update | Poor performance | Cache reference or events |
| String concatenation in frequent calls | GC pressure | StringBuilder |
| `new` in Update/FixedUpdate | GC pressure | Object pooling or pre-allocation |
| Magic numbers | Hard to maintain | Constants or configuration |
| Deep nesting (>3 levels) | Poor readability | Extract method or early return |
| public fields | Poor encapsulation | [SerializeField] private |

---

## Common Issues and Fixes

### Memory Leak

```csharp
// Error: Event not unsubscribed
private void OnEnable()
{
    Player.OnDied += HandlePlayerDied;
}
// Missing OnDisable

// Correct:
private void OnEnable() => Player.OnDied += HandlePlayerDied;
private void OnDisable() => Player.OnDied -= HandlePlayerDied;
```

### Null Reference

```csharp
// Error: Directly using potentially null reference
_target.TakeDamage(10);

// Correct: Check for null
if (_target != null)
    _target.TakeDamage(10);

// Or use null-conditional operator
_target?.TakeDamage(10);
```

### Update Performance

```csharp
// Error: Execute expensive operation every frame
void Update()
{
    var enemies = FindObjectsOfType<Enemy>();
}

// Correct: Use interval check
private float _checkInterval = 0.5f;
private float _nextCheck;

void Update()
{
    if (Time.time >= _nextCheck)
    {
        _nextCheck = Time.time + _checkInterval;
        CheckEnemies();
    }
}
```
