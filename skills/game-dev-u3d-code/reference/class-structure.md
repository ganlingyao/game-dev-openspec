# Unity C# Class Structure

## Member Order

```csharp
public class ExampleClass : MonoBehaviour
{
    // 1. Constants
    private const int MAX_COUNT = 10;

    // 2. Static Fields
    private static int _instanceCount;

    // 3. Serialized Fields (Inspector Visible)
    [Header("Configuration")]
    [SerializeField] private float _speed = 5f;
    [SerializeField] private GameObject _prefab;

    // 4. Private Fields
    private int _currentCount;
    private bool _isInitialized;

    // 5. Properties
    public int CurrentCount => _currentCount;
    public bool IsReady { get; private set; }

    // 6. Unity Lifecycle Methods (Order of Execution)
    private void Awake() { }
    private void OnEnable() { }
    private void Start() { }
    private void Update() { }
    private void FixedUpdate() { }
    private void LateUpdate() { }
    private void OnDisable() { }
    private void OnDestroy() { }

    // 7. Public Methods
    public void Initialize() { }

    // 8. Private Methods
    private void HelperMethod() { }

    // 9. Event Handlers
    private void OnEventTriggered() { }

    // 10. Coroutines
    private IEnumerator DoSomethingCoroutine() { yield return null; }
}
```

---

## Code Format

- **Brace Style**: Allman (braces on new line)
- **Indentation**: 4 spaces
- **Max Method Lines**: < 30 lines
- **Max Class Lines**: < 300 lines
- **Max Nesting Depth**: < 3 levels
- **Max Parameters**: < 5
