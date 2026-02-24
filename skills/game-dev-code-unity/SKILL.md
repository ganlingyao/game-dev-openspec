---
name: code-unity
description: Unity game coding capability. Includes code standards, unit testing, and code quality review. Automatically triggered during the apply phase.
---

# Code Unity Skill - Unity Coding Capability

This Skill provides Unity game development coding capabilities to ensure code quality, standardization, and testability.

---

## Standards Reference

When writing code, you must follow the above specification documents, mainly including:

- **Naming Conventions**: PascalCase/camelCase/_camelCase rules
- **Code Format**: Allman style braces, 4 spaces indentation
- **Comment Standards**: File header comments, XML documentation comments, implementation comments
- **Unity Best Practices**: Inspector documentation, [SerializeField] usage

Note: If the user has explicit specification requirements, please follow the user's coding specification requirements.
---

## Part 1: Code Standards Cheat Sheet

### Naming Conventions

| Type | Style | Example |
|------|------|------|
| Class/Struct/Enum | PascalCase | `PlayerController`, `GameData` |
| Interface | IPascalCase | `IDamageable`, `IInteractable` |
| Public Member | PascalCase | `public int MaxHealth;`, `public void Fire()` |
| Private/Protected Field | _camelCase | `private float _movementSpeed;` |
| Local Variable/Parameter | camelCase | `int tempScore;`, `void SetHealth(int newHealth)` |
| Boolean | is/has/can + PascalCase | `public bool IsAlive;`, `private bool _canJump;` |
| Constant | ALL_CAPS_SNAKE_CASE | `public const int MAX_AMMO = 100;` |
| Coroutine Method | PascalCaseCoroutine | `private IEnumerator FadeOutCoroutine()` |

### Class Structure Order

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

### File Header Comments (Required)

```csharp
/*
 * File:      PlayerHealth.cs
 * Author:    XDTS
 * Date:      2025-08-06
 * Version:   1.0
 *
 * Description:
 *   Manages the player's health, damage intake, and death event.
 *
 *   Classes:
 *     - PlayerHealth: Handles player's health state and damage processing.
 *         - TakeDamage(): Applies damage to the player and checks for death.
 *         - Heal(): Restores a specified amount of health.
 *
 * History:
 *   1.0 (2025-08-06) - Initial creation.
 */
```

### Unity Specific Standards

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

### Prohibitions

| Prohibited | Reason | Alternative |
|------|------|----------|
| `GameObject.Find()` in Update | Poor performance | Cache reference or events |
| String concatenation in frequent calls | GC pressure | StringBuilder |
| `new` in Update/FixedUpdate | GC pressure | Object pooling or pre-allocation |
| Magic numbers | Hard to maintain | Constants or configuration |
| Deep nesting (>3 levels) | Poor readability | Extract method or early return |
| public fields | Poor encapsulation | [SerializeField] private |

### XML Documentation Comments (Required for all members)

```csharp
/// <summary>
/// Calculates the final damage value after applying armor and buffs.
/// </summary>
/// <param name="baseDamage">The initial, unmodified damage amount.</param>
/// <param name="armor">The target's armor rating.</param>
/// <returns>The calculated damage to be applied.</returns>
private float CalculateFinalDamage(float baseDamage, float armor)
{
    // Use squared magnitude for performance, avoids costly square root.
    // ...
}
```

---

## Part 2: Unit Testing

### Unity Test Framework

Use Unity's built-in Test Framework for testing.

#### Test File Location

```
Assets/
└── _Project/
    └── Tests/
        ├── EditMode/           # Editor Mode Tests
        │   └── GameManagerTests.cs
        └── PlayMode/           # Play Mode Tests
            └── PlayerMovementTests.cs
```

#### EditMode Test Example

```csharp
using NUnit.Framework;

[TestFixture]
public class GameManagerTests
{
    private GameManager _gameManager;

    [SetUp]
    public void Setup()
    {
        _gameManager = new GameObject().AddComponent<GameManager>();
    }

    [TearDown]
    public void TearDown()
    {
        Object.DestroyImmediate(_gameManager.gameObject);
    }

    [Test]
    public void StartGame_SetsStateToPlaying()
    {
        _gameManager.StartGame();
        Assert.AreEqual(GameState.Playing, _gameManager.CurrentState);
    }

    [Test]
    public void AddScore_IncreasesScore()
    {
        _gameManager.StartGame();
        _gameManager.AddScore(100);
        Assert.AreEqual(100, _gameManager.Score);
    }

    [Test]
    public void GameOver_SetsStateToGameOver()
    {
        _gameManager.StartGame();
        _gameManager.GameOver();
        Assert.AreEqual(GameState.GameOver, _gameManager.CurrentState);
    }
}
```

#### PlayMode Test Example

```csharp
using System.Collections;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;

public class PlayerMovementTests
{
    private GameObject _player;
    private PlayerController _controller;

    [SetUp]
    public void Setup()
    {
        _player = new GameObject("Player");
        _player.AddComponent<Rigidbody2D>();
        _controller = _player.AddComponent<PlayerController>();
    }

    [TearDown]
    public void TearDown()
    {
        Object.DestroyImmediate(_player);
    }

    [UnityTest]
    public IEnumerator Move_ChangesPosition()
    {
        Vector3 startPos = _player.transform.position;
        _controller.Move(Vector2.right);

        yield return new WaitForSeconds(0.1f);

        Assert.AreNotEqual(startPos, _player.transform.position);
    }
}
```

### Test Principles

1. **Test public behavior, not private implementation**
2. **Each test verifies only one thing**
3. **Test name describes expected behavior**: `MethodName_Condition_ExpectedResult`
4. **Use Arrange-Act-Assert pattern**

### Content to Test

| Priority | Content | Example |
|--------|------|------|
| High | Core Game Logic | Score calculation, state transition |
| High | Data Processing | Save/Load, Config parsing |
| Medium | Utility Classes | Math calculation, String processing |
| Low | UI Logic | Button state |
| No Test | Unity Built-in Features | Physics, Rendering |

---

## Part 3: Code Review

### Self-Check List

Check against this list after completing each feature:

#### Standards Check
- [ ] Naming follows conventions (_camelCase for private)
- [ ] Use [SerializeField] instead of public
- [ ] Class members arranged in prescribed order
- [ ] No magic numbers

#### Unity Check
- [ ] Component references cached in Awake
- [ ] No Find/GetComponent used in Update
- [ ] Events unsubscribed in OnDisable
- [ ] Use object pooling for frequently created objects

#### Performance Check
- [ ] No memory allocation in Update
- [ ] No unnecessary GetComponent calls
- [ ] Expensive operations use interval checks or coroutines

#### Maintainability Check
- [ ] Public APIs have documentation comments
- [ ] Complex logic has explanatory comments
- [ ] Methods do not exceed 30 lines
- [ ] Classes do not exceed 300 lines

### Common Issues

#### Issue 1: Memory Leak

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

#### Issue 2: Null Reference

```csharp
// Error: Directly using potentially null reference
_target.TakeDamage(10);

// Correct: Check for null
if (_target != null)
    _target.TakeDamage(10);

// Or use null-conditional operator
_target?.TakeDamage(10);
```

#### Issue 3: Update Performance

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

### Code Quality Metrics

| Metric | Target |
|------|------|
| Method Lines | < 30 lines |
| Class Lines | < 300 lines |
| Nesting Depth | < 3 levels |
| Parameter Count | < 5 |
| Cyclomatic Complexity | < 10 |

---

## Coding Workflow

1. **Read task and related design**
2. **Write code** (follow standards)
3. **Self-check** (check against list)
4. **Write tests** (if needed)
5. **Run tests**
6. **Mark task as complete**

---

## Trigger Conditions

This Skill is automatically triggered in the following situations:
- When executing the apply phase
- When writing Unity C# code
- When code review is needed
- When unit tests need to be written
