# Unity Testing Guide

## Test File Location

```
Assets/
└── _Project/
    └── Tests/
        ├── EditMode/           # Editor Mode Tests
        │   └── GameManagerTests.cs
        └── PlayMode/           # Play Mode Tests
            └── PlayerMovementTests.cs
```

---

## EditMode Test Example

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
}
```

---

## PlayMode Test Example

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

---

## Test Principles

1. **Test public behavior, not private implementation**
2. **Each test verifies only one thing**
3. **Test name describes expected behavior**: `MethodName_Condition_ExpectedResult`
4. **Use Arrange-Act-Assert pattern**

---

## Content to Test

| Priority | Content | Example |
|----------|---------|---------|
| High | Core Game Logic | Score calculation, state transition |
| High | Data Processing | Save/Load, Config parsing |
| Medium | Utility Classes | Math calculation, String processing |
| Low | UI Logic | Button state |
| No Test | Unity Built-in Features | Physics, Rendering |
