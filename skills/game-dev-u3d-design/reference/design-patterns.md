# Unity Design Patterns Reference

## 核心原则：依赖接口，不依赖实现

所有设计模式的应用都应遵循：
- 业务逻辑依赖抽象接口
- 具体实现可随时替换
- 便于单元测试

---

## 1. 依赖注入 (Dependency Injection)

**最重要的模式** - 所有核心系统都应使用

```csharp
// ✓ 正确：依赖接口，通过构造函数注入
public class PlantGrowthSystem
{
    private readonly IEventBus _events;
    private readonly IConfigProvider _config;
    private readonly IResourceLoader _resource;

    public PlantGrowthSystem(
        IEventBus events,
        IConfigProvider config,
        IResourceLoader resource)
    {
        _events = events ?? throw new ArgumentNullException(nameof(events));
        _config = config ?? throw new ArgumentNullException(nameof(config));
        _resource = resource ?? throw new ArgumentNullException(nameof(resource));
    }
}

// ✗ 错误：直接依赖具体实现
public class PlantGrowthSystem
{
    private EventBus _events = new EventBus();  // 硬编码
    private void Start()
    {
        var config = Resources.Load<GrowthConfig>("Config");  // 硬编码路径
    }
}
```

**优点**：
- 可测试：测试时注入 Mock
- 可替换：换实现只改 Bootstrap
- 清晰依赖：构造函数显示所有依赖

---

## 2. 事件驱动 (Event-Driven)

系统间通过事件通信，避免直接引用

### 事件定义

```csharp
// 使用 readonly struct 避免 GC
public readonly struct NutrientChanged
{
    public readonly int OldValue;
    public readonly int NewValue;
    public readonly InputType Source;

    public NutrientChanged(int oldValue, int newValue, InputType source)
    {
        OldValue = oldValue;
        NewValue = newValue;
        Source = source;
    }
}
```

### 发布/订阅

```csharp
// Publisher - 不知道谁在监听
public class NutrientManager
{
    private readonly IEventBus _events;

    public void AddNutrient(int amount, InputType source)
    {
        var oldValue = _nutrients;
        _nutrients += amount;
        _events.Publish(in new NutrientChanged(oldValue, _nutrients, source));
    }
}

// Subscriber - 不知道谁发布的
public class PlantGrowthSystem
{
    private IDisposable _subscription;

    public void Initialize()
    {
        _subscription = _events.Subscribe<NutrientChanged>(OnNutrientChanged);
    }

    public void Shutdown()
    {
        _subscription?.Dispose();
    }

    private void OnNutrientChanged(in NutrientChanged evt)
    {
        CheckGrowthCondition(evt.NewValue);
    }
}
```

---

## 3. 配置驱动 (Configuration-Driven)

所有可能变化的数值都应该来自配置

```csharp
// ✓ 正确：配置驱动
public class PlantGrowthSystem
{
    private readonly IConfigProvider _config;
    private List<StageConfig> _stages;

    public void Initialize()
    {
        _stages = _config.GetConfig<GrowthConfig>().Stages;
    }

    private void CheckGrowth(int nutrients)
    {
        foreach (var stage in _stages)
        {
            if (nutrients >= stage.RequiredNutrients)
            {
                TransitionTo(stage);
                break;
            }
        }
    }
}

// ✗ 错误：硬编码
private void CheckGrowth(int nutrients)
{
    if (nutrients >= 100) TransitionTo(1);
    else if (nutrients >= 500) TransitionTo(2);
    else if (nutrients >= 2000) TransitionTo(3);
}
```

---

## 4. 状态机 (State Machine)

适用于有明确状态和转换的对象

```csharp
public class PlantStateMachine
{
    private readonly IEventBus _events;
    private IPlantState _currentState;

    private readonly Dictionary<PlantStateType, IPlantState> _states;

    public PlantStateMachine(IEventBus events)
    {
        _events = events;
        _states = new Dictionary<PlantStateType, IPlantState>
        {
            { PlantStateType.Seed, new SeedState(this) },
            { PlantStateType.Sprout, new SproutState(this) },
            { PlantStateType.Mature, new MatureState(this) },
        };
    }

    public void TransitionTo(PlantStateType newState)
    {
        _currentState?.Exit();
        _currentState = _states[newState];
        _currentState.Enter();
        _events.Publish(in new PlantStateChanged(newState));
    }
}

public interface IPlantState
{
    void Enter();
    void Exit();
    void Update();
}
```

---

## 5. 对象池 (Object Pool)

频繁创建/销毁的对象使用池化

```csharp
public interface IPoolingService
{
    void Register(string key, GameObject prefab, int prewarmCount = 0);
    GameObject Rent(string key);
    void Return(string key, GameObject obj);
}

// 使用
public class ParticleSpawner
{
    private readonly IPoolingService _pool;

    public void SpawnNutrientParticle(Vector3 position)
    {
        var particle = _pool.Rent("nutrient_particle");
        particle.transform.position = position;
        // 粒子系统结束后自动归还
    }
}
```

---

## 6. 工厂模式 (Factory)

创建复杂对象时使用

```csharp
public interface IFruitFactory
{
    Fruit CreateFruit(FruitConfig config, Vector3 position);
}

public class FruitFactory : IFruitFactory
{
    private readonly IPoolingService _pool;
    private readonly IResourceLoader _resource;

    public FruitFactory(IPoolingService pool, IResourceLoader resource)
    {
        _pool = pool;
        _resource = resource;
    }

    public Fruit CreateFruit(FruitConfig config, Vector3 position)
    {
        var go = _pool.Rent(config.PrefabKey);
        var fruit = go.GetComponent<Fruit>();
        fruit.Initialize(config);
        fruit.transform.position = position;
        return fruit;
    }
}
```

---

## 7. 策略模式 (Strategy)

同一行为有多种实现时使用

```csharp
// 输入策略接口
public interface IInputStrategy
{
    void Initialize();
    void Shutdown();
    event Action<InputEvent> OnInput;
}

// Windows 钩子实现
public class WindowsHookInputStrategy : IInputStrategy
{
    public event Action<InputEvent> OnInput;
    // Windows API 实现...
}

// Unity 输入实现
public class UnityInputStrategy : IInputStrategy
{
    public event Action<InputEvent> OnInput;
    // Unity Input System 实现...
}

// 使用时根据平台选择
IInputStrategy input = Application.platform == RuntimePlatform.WindowsPlayer
    ? new WindowsHookInputStrategy()
    : new UnityInputStrategy();
```

---

## 模式选择指南

| 场景 | 推荐模式 | 理由 |
|------|----------|------|
| 核心系统 | 依赖注入 | 可测试、可替换 |
| 系统间通信 | 事件驱动 | 解耦、灵活 |
| 策划调参 | 配置驱动 | 无需改代码 |
| 有限状态 | 状态机 | 清晰的状态管理 |
| 频繁创建 | 对象池 | 避免 GC |
| 复杂创建 | 工厂模式 | 封装创建逻辑 |
| 多种实现 | 策略模式 | 运行时切换 |

---

## 反模式警示

### ✗ 直接引用具体类

```csharp
// 错误
private void Start()
{
    GameManager.Instance.AddScore(10);  // 强耦合
}

// 正确
private readonly IEventBus _events;
_events.Publish(in new ScoreGained(10));  // 解耦
```

### ✗ 硬编码路径/数值

```csharp
// 错误
Resources.Load<Sprite>("Sprites/Plant/stage_1");
if (nutrients >= 100) { }

// 正确
_resourceLoader.Load<Sprite>(config.SpriteKey);
if (nutrients >= config.RequiredNutrients) { }
```

### ✗ 静态状态

```csharp
// 错误 - 难以测试
public static class GameState
{
    public static int Nutrients;
}

// 正确 - 注入实例
public class GameState
{
    public int Nutrients { get; set; }
}
```
