# XDUF Integration Guide

Complete guide for integrating XDUF framework into Unity projects.

---

## Prerequisites

- Unity 2021.3 LTS or higher
- .NET Standard 2.1 / .NET Framework 4.x
- Newtonsoft.Json (included in Unity 2020+)

---

## Installation Methods

### Method 1: Git Clone (Recommended for New Projects)

```bash
# Clone directly
git clone git@git-huge.xindong.com:ganlingyao/xduf.git MyProject

# Or clone into existing project
cd MyProject/Assets
git clone git@git-huge.xindong.com:ganlingyao/xduf.git Framework
```

### Method 2: Git Submodule (Recommended for Version Control)

```bash
cd MyProject
git submodule add git@git-huge.xindong.com:ganlingyao/xduf.git Assets/XDUF
git submodule update --init --recursive
```

**Update submodule:**
```bash
git submodule update --remote Assets/XDUF
```

### Method 3: Manual Copy

1. Download/clone XDUF repository
2. Copy `Assets/Framework` folder to your project's `Assets/` directory
3. Ensure assembly definitions are properly referenced

---

## Module Dependencies

```
XDUF Module Dependency Graph:

┌─────────────────────────────────────────────────────┐
│                     GameFramework                    │
│              (IGameManager, ISceneLoader)            │
└──────────────────────┬──────────────────────────────┘
                       │ depends on
                       ▼
┌─────────────────────────────────────────────────────┐
│                       Events                         │
│                   (IEventManager)                    │
└─────────────────────────────────────────────────────┘
                       ▲
                       │ depends on
┌──────────────────────┴──────────────────────────────┐
│                       Config                         │
│                  (IConfigManager)                    │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│                      Pooling                         │
│                  (IPoolingService)                   │
│                   [STANDALONE]                       │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│                      Resource                        │
│                 (IResourceManager)                   │
│                   [STANDALONE]                       │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│                       Input                          │
│                   (IInputService)                    │
└──────────────────────┬──────────────────────────────┘
                       │ depends on
                       ▼
                    Events (for StateChanged)
```

---

## Quick Start: Framework Initializer

```csharp
using UnityEngine;
using XDUF;
using XDUF.Events;
using XDUF.Resource;
using XDUF.Pooling;
using XDUF.GameFramework;

public class FrameworkInitializer : MonoBehaviour
{
    [SerializeField] private PoolConfiguration _poolConfig;
    [SerializeField] private ResourceSettings _resourceSettings;

    private IEventManager _eventManager;
    private IPoolingService _poolingService;
    private IResourceManager _resourceManager;
    private ISceneLoader _sceneLoader;
    private IGameManager _gameManager;

    private void Awake()
    {
        // 1. Event Manager (no dependencies)
        _eventManager = new EventManager();
        _eventManager.Initialize();

        // 2. Pooling Service
        _poolingService = new PoolingService(_poolConfig);
        _poolingService.Initialize();

        // 3. Resource Manager (explicit configuration)
        ResourceManager.Configure(null, _resourceSettings);
        _resourceManager = ResourceManager.Instance;
        _resourceManager.Initialize();

        // 4. Scene Loader
        _sceneLoader = new SceneLoader(_eventManager, this);
        _sceneLoader.Initialize();

        // 5. Game Manager
        _gameManager = new GameManager(_eventManager, _sceneLoader, MapStateToScene);
        _gameManager.Initialize();
    }

    private string MapStateToScene(GameState state) => state switch
    {
        GameState.MainMenu => "MainMenuScene",
        GameState.InGame => "GameScene",
        _ => ""
    };

    private void OnDestroy()
    {
        _gameManager?.Shutdown();
        _sceneLoader?.Shutdown();
        _resourceManager?.Shutdown();
        _poolingService?.Shutdown();
        _eventManager?.Shutdown();
    }
}
```

---

## Selective Module Integration

### Events Only

Copy these folders:
```
Assets/Framework/
├── Core/
│   └── IManager.cs
├── Events/
│   ├── EventManager.cs
│   ├── IEventManager.cs
│   ├── EventLogger.cs
│   ├── EventErrorCodes.cs
│   └── Internals/
└── XDUF.asmdef (modify references)
```

### Pooling Only

Copy these folders:
```
Assets/Framework/
├── Core/
│   └── IManager.cs
├── Pooling/
│   ├── Core/
│   ├── Contracts/
│   └── Diagnostics/
└── XDUF.asmdef (modify references)
```

---

## Configuration Examples

### PoolConfiguration

```csharp
var config = new PoolConfiguration
{
    DefaultCapacity = 100,
    DefaultPrewarmCount = 10,
    DefaultExhaustionStrategy = PoolExhaustionStrategy.Instantiate,
    EnableLeakDetection = true,
    LeakDetectionThresholdSeconds = 30f,
    LogLevel = PoolLogLevel.Warning,

    // Pool-specific definitions
    PoolDefinitions = new List<PoolDefinition>
    {
        new PoolDefinition
        {
            TypeName = "Bullet",
            Capacity = 200,
            PrewarmCount = 50,
            ExhaustionStrategy = PoolExhaustionStrategy.Instantiate
        }
    }
};
```

### ResourceSettings

```csharp
var settings = new ResourceSettings
{
    IsVerboseLoggingEnabled = false,
    DefaultLoadTimeoutMs = 10000
};

ResourceManager.Configure(null, settings);
```

---

## Using Framework Services

```csharp
// Events - Publish and Subscribe
_eventManager.Publish(new PlayerDied { PlayerId = 1 });
var sub = _eventManager.Subscribe<PlayerDied>(OnPlayerDied);

// Pooling - Rent and Return
_poolingService.RegisterPrefab("Bullet", bulletPrefab);
var bullet = _poolingService.Rent("Bullet");
_poolingService.Return("Bullet", bullet);

// Resource - Async Load
var prefab = await _resourceManager.LoadAsync<GameObject>("Prefabs/Enemy");
_resourceManager.Release(prefab);

// Game State - Transition
_gameManager.ChangeState(GameState.InGame);
```

---

## Troubleshooting

### Assembly Definition Errors
- Verify XDUF.asmdef exists
- Check your assembly references XDUF
- Reimport the XDUF folder

### Pool Exhaustion with Wait Strategy
```csharp
// Use coroutine for Wait strategy
StartCoroutine(_pooling.RentWithWaitCoroutine("Pool", obj => {
    // Use obj here
}));
```

### Async Deadlock in Edit Mode Tests
XDUF handles this internally. For custom async code:
```csharp
await SomeAsyncOperation().ConfigureAwait(false);
```
