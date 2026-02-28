# XDUF Integration Guide

XDUF 是 Unity 项目的**基础设施框架**，提供经过验证的核心模块。在设计阶段，必须先了解 XDUF 提供什么，再决定项目需要什么。

---

## 强制阅读：XDUF 模块概览

**在设计任何基础设施之前，必须阅读此章节。**

### 模块全景图

```
┌─────────────────────────────────────────────────────────────────┐
│                        XDUF Framework                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐            │
│  │    Core     │   │ Diagnostics │   │   Events    │            │
│  │  IManager   │   │LoggerManager│   │IEventManager│            │
│  │ 生命周期管理 │   │  日志系统   │   │ 零GC事件总线│            │
│  └─────────────┘   └─────────────┘   └──────┬──────┘            │
│                                             │                    │
│         ┌───────────────────────────────────┼────────────┐       │
│         │                                   │            │       │
│         ▼                                   ▼            ▼       │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐            │
│  │   Config    │   │    Input    │   │GameFramework│            │
│  │IConfigManager│  │IInputService│   │IGameManager │            │
│  │ 配置加载/缓存│  │ 统一输入抽象│   │ 状态机/场景 │            │
│  └─────────────┘   └─────────────┘   └─────────────┘            │
│                                                                  │
│  ┌─────────────┐   ┌─────────────┐                              │
│  │   Pooling   │   │  Resource   │   ← 独立模块，无依赖         │
│  │IPoolingServ │   │IResourceMgr │                              │
│  │ 对象池+泄漏 │   │ 异步+引用计数│                              │
│  └─────────────┘   └─────────────┘                              │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 模块详解

### 1. Core (XDUF.Core)

**接口**: `IManager`

**功能**: 定义所有服务的生命周期契约

```csharp
public interface IManager
{
    void Initialize();
    void Shutdown();
}
```

**使用场景**: 所有自定义 Manager 都应实现此接口

**集成建议**: L1 复制，或直接使用

---

### 2. Events (XDUF.Events)

**接口**: `IEventManager`

**功能**:
- 零 GC 事件发布（使用 `readonly struct`）
- 异常隔离（订阅者异常不影响其他订阅者）
- 线程安全订阅/取消
- `IDisposable` 订阅句柄

**API 示例**:
```csharp
// 接口定义
public interface IEventManager : IManager
{
    void Publish<T>(in T evt) where T : struct;
    IDisposable Subscribe<T>(Action<T> handler) where T : struct;
}

// 定义事件 (必须是 readonly struct)
public readonly struct NutrientChanged
{
    public readonly int OldValue;
    public readonly int NewValue;
    public readonly int Delta;

    public NutrientChanged(int oldValue, int newValue)
    {
        OldValue = oldValue;
        NewValue = newValue;
        Delta = newValue - oldValue;
    }
}

// 发布
eventManager.Publish(new NutrientChanged(old, current));

// 订阅 (返回 IDisposable，用于取消订阅)
var sub = eventManager.Subscribe<NutrientChanged>(evt => {
    Debug.Log($"Nutrients: {evt.OldValue} -> {evt.NewValue}");
});

// 取消订阅
sub.Dispose();
```

**集成建议**: L1 复制适配，改命名空间即可

---

### 3. Config (XDUF.Config)

**接口**: `IConfigManager`

**功能**:
- 强类型配置加载
- 多源支持：JSON 文件 (`JsonConfigLoader`) 和 ScriptableObject (`ScriptableObjectConfigLoader`)
- 内存缓存 + 按键失效
- 运行时刷新（白名单控制）
- 结构化键："domain.section.name"

**API 示例**:
```csharp
// 接口定义
public interface IConfigManager : IManager
{
    T Get<T>(string key) where T : class;
    void Invalidate(string key);
    void Refresh(string key);  // 运行时重新加载
}

// 配置类
[Serializable]
public class GrowthConfig
{
    public List<StageConfig> Stages;
}

[Serializable]
public class StageConfig
{
    public int Id;
    public string Name;
    public int RequiredNutrients;
    public int MaxFruitSlots;
}

// 使用
var config = configManager.Get<GrowthConfig>("gameplay.growth");
foreach (var stage in config.Stages)
{
    Debug.Log($"Stage {stage.Id}: requires {stage.RequiredNutrients}");
}
```

**加载器配置**:
```csharp
// ScriptableObject 加载器
var soLoader = new ScriptableObjectConfigLoader("Configs/");

// JSON 加载器
var jsonLoader = new JsonConfigLoader("StreamingAssets/Configs/");

// 注册加载器
configManager.RegisterLoader("gameplay.*", soLoader);
configManager.RegisterLoader("remote.*", jsonLoader);
```

**集成建议**: L1 复制，根据项目需要选择加载器

---

### 4. Pooling (XDUF.Pooling)

**接口**: `IPoolingService`, `IObjectPool`, `IPoolable`, `IResettable`

**功能**:
- 无锁并发栈 (`ConcurrentObjectStack`)
- 可配置耗尽策略：`Instantiate` / `Wait` / `Throw`
- 异步预热（分帧，避免卡顿）
- 开发模式泄漏检测
- 实时指标监控

**API 示例**:
```csharp
// 接口定义
public interface IPoolingService : IManager
{
    void Register(string key, GameObject prefab, PoolConfiguration config = null);
    GameObject Rent(string key);
    void Return(string key, GameObject obj);
    PoolMetrics GetMetrics(string key);
}

// 配置
var config = new PoolConfiguration
{
    InitialCapacity = 10,
    PrewarmCount = 5,
    MaxCapacity = 100,
    ExhaustionStrategy = PoolExhaustionStrategy.Instantiate,
    EnableLeakDetection = true  // 仅开发模式
};

// 注册
poolingService.Register("bullet", bulletPrefab, config);

// 租借
var bullet = poolingService.Rent("bullet");

// 归还
poolingService.Return("bullet", bullet);

// 查看指标
var metrics = poolingService.GetMetrics("bullet");
Debug.Log($"Active: {metrics.ActiveCount}, Available: {metrics.AvailableCount}");
```

**池化对象生命周期**:
```csharp
// 实现 IPoolable 接口获取回调
public class Bullet : MonoBehaviour, IPoolable
{
    public void OnRent()
    {
        // 从池中租借时调用
        gameObject.SetActive(true);
    }

    public void OnReturn()
    {
        // 归还到池时调用
        gameObject.SetActive(false);
        ResetState();
    }
}
```

**集成建议**: L1 复制，可简化泄漏检测（MVP 不需要）

---

### 5. Diagnostics (XDUF.Diagnostics)

**类**: `LoggerManager`

**功能**:
- 通道化日志 (`LogChannel` 枚举)
- 全局开关 + 每通道开关
- 统一输出到 Unity Console

**API 示例**:
```csharp
// 通道枚举
public enum LogChannel
{
    System,
    Events,
    Config,
    Pooling,
    Resource,
    Gameplay
}

// 配置
LoggerManager.SetGlobalEnabled(true);
LoggerManager.SetChannelEnabled(LogChannel.Events, false);  // 关闭事件日志

// 使用
LoggerManager.Log(LogChannel.Gameplay, "Plant grew to stage 3");
LoggerManager.LogWarning(LogChannel.Config, "Config not found, using default");
LoggerManager.LogError(LogChannel.System, "Critical error!");
```

**集成建议**: L2 包装或 L3 参考设计

---

### 6. Input (XDUF.Input)

**接口**: `IInputService`

**功能**:
- 事件驱动输入 (`OnMove`, `OnJump`, `OnInteract`, `OnMenu`)
- 动作映射（Gameplay / UI 等方案切换）
- 设备类型检测 (`DeviceKind`)
- 运行时重绑定 + 持久化
- 与 GameFramework 状态集成

**API 示例**:
```csharp
// 接口定义
public interface IInputService : IManager
{
    event Action<Vector2> OnMove;
    event Action OnJump;
    event Action OnInteract;
    event Action OnMenu;

    DeviceKind ActiveDevice { get; }
    event Action<DeviceKind> OnDeviceChanged;

    void EnableActionMap(string mapName);
    void DisableActionMap(string mapName);

    void Rebind(string action, string binding);
    string ExportBindings();
    void ImportBindings(string json);
}

// 订阅输入
inputService.OnMove += dir => character.Move(dir);
inputService.OnJump += () => character.Jump();

// 切换动作映射
inputService.EnableActionMap("UI");
inputService.DisableActionMap("Gameplay");

// 检测设备
if (inputService.ActiveDevice == DeviceKind.Gamepad)
{
    ShowGamepadPrompts();
}
```

**注意**: 当前基于 Unity 旧输入系统，未来可能迁移到新输入系统

**集成建议**:
- 如果项目需要 UI/Gameplay 切换 → L1 复制
- 如果项目有特殊输入需求（如全局钩子）→ L3 参考设计

---

### 7. Resource (XDUF.Resource)

**接口**: `IResourceManager`, `IResourceLoader`

**功能**:
- 异步加载（`Task` + `CancellationToken`）
- 引用计数（归零时卸载）
- 资源缓存（并发去重）
- 可插拔加载器
- 预加载支持
- 超时与取消

**API 示例**:
```csharp
// 接口定义
public interface IResourceManager : IManager
{
    Task<T> LoadAsync<T>(string key, CancellationToken ct = default) where T : Object;
    void Release(string key);
    void Preload(params string[] keys);
    int GetReferenceCount(string key);
}

// 异步加载
var sprite = await resourceManager.LoadAsync<Sprite>("sprites/plant_stage_3");
plantRenderer.sprite = sprite;

// 释放（引用计数 -1）
resourceManager.Release("sprites/plant_stage_3");

// 预加载
resourceManager.Preload(
    "sprites/plant_stage_0",
    "sprites/plant_stage_1",
    "sprites/plant_stage_2"
);

// 带取消的加载
var cts = new CancellationTokenSource();
cts.CancelAfter(TimeSpan.FromSeconds(5));  // 5秒超时
try
{
    var asset = await resourceManager.LoadAsync<GameObject>("prefabs/enemy", cts.Token);
}
catch (OperationCanceledException)
{
    Debug.Log("Load cancelled or timed out");
}
```

**集成建议**: L1 复制，MVP 可简化引用计数

---

### 8. GameFramework (XDUF.GameFramework)

**接口**: `IGameManager`, `ISceneLoader`

**功能**:
- 游戏状态机 (`GameState` 枚举 + 转换规则)
- 状态转换事件 (`StateChanged`)
- 异步场景加载（进度、取消、超时）
- 加载失败自动回滚
- 服务协调初始化

**API 示例**:
```csharp
// 状态定义
public enum GameState
{
    None,
    Initializing,
    MainMenu,
    Loading,
    Playing,
    Paused,
    GameOver
}

// 接口定义
public interface IGameManager : IManager
{
    GameState CurrentState { get; }
    void TransitionTo(GameState newState);
    Task LoadSceneAsync(string sceneName, IProgress<float> progress = null);
}

// 状态转换
gameManager.TransitionTo(GameState.Playing);

// 订阅状态变化
eventManager.Subscribe<StateChanged>(evt => {
    Debug.Log($"State: {evt.OldState} -> {evt.NewState}");

    if (evt.NewState == GameState.Playing)
    {
        inputService.EnableActionMap("Gameplay");
    }
});

// 异步场景加载
var progress = new Progress<float>(p => loadingBar.value = p);
await gameManager.LoadSceneAsync("GameScene", progress);
```

**集成建议**:
- 简单项目 → L3 参考设计，自己实现简化版
- 复杂项目 → L1 复制完整状态机

---

## 模块依赖关系

```
独立模块（无依赖）:
├── Core
├── Diagnostics
├── Pooling
└── Resource

依赖 Events:
├── Config      → Events (日志)
├── Input       → Events (StateChanged 订阅)
└── GameFramework → Events (状态变化发布)

依赖 GameFramework:
└── Input (状态切换时自动切换动作映射)
```

---

## 设计阶段决策流程

### Step 1: 列出项目需要的基础设施能力

对照项目需求，勾选需要的能力：

| 能力 | 需要？ | XDUF 模块 |
|------|--------|-----------|
| 事件总线 | [ ] | Events |
| 配置管理 | [ ] | Config |
| 对象池 | [ ] | Pooling |
| 资源加载 | [ ] | Resource |
| 输入抽象 | [ ] | Input |
| 状态机 | [ ] | GameFramework |
| 日志系统 | [ ] | Diagnostics |
| 存档系统 | [ ] | 无，需自己实现 |
| 时间控制 | [ ] | 无，需自己实现 |

### Step 2: 确定每个模块的集成级别

| 级别 | 说明 | 适用场景 |
|------|------|----------|
| L1 | 复制适配 | 功能完全匹配，改命名空间即可 |
| L2 | 包装集成 | 需要定制接口，内部使用 XDUF 模式 |
| L3 | 参考设计 | 有特殊需求，仅学习设计思路 |
| 自研 | 不使用 XDUF | XDUF 无此功能，或需求差异太大 |

### Step 3: 在 design.md 中记录决策

```markdown
## XDUF 集成决策

| 项目需求 | XDUF 模块 | 集成级别 | 理由 |
|----------|-----------|----------|------|
| 系统间解耦 | Events | L1 | 零 GC 设计，直接复用 |
| 配置加载 | Config | L1 | SO/JSON 双支持 |
| 粒子/果实池化 | Pooling | L1 | 泄漏检测有用 |
| 全局输入监听 | Input | L3 | 需要 Windows Hook，XDUF 不支持 |
| 资源加载 | Resource | L2 | 简化引用计数 |
| 游戏状态 | GameFramework | 不使用 | 本项目无复杂状态 |
| 存档系统 | 无 | 自研 | XDUF 不提供 |
```

---

## 集成级别详解

### L1: 复制适配

```
XDUF 源文件                    项目目标位置
──────────────                ──────────────
Framework/Events/             Scripts/Core/Events/
├── IEventManager.cs    →     ├── IEventManager.cs
├── EventManager.cs     →     ├── EventManager.cs 
└── Internals/          →     └── Internals/

修改内容:
1. 命名空间: XDUF.Events → YOURPROJECT.Core.Events,适配项目
2. 类名: EventManager → EventManager (可选)
3. 移除: 不需要的功能
4. 补充：完善需要的功能
```

### L2: 包装集成

```csharp
// 项目定义自己的接口
public interface IProjectEventBus
{
    void Send<T>(T evt) where T : struct;
    Action Listen<T>(Action<T> handler) where T : struct;
}

// 内部使用 XDUF 模式实现
public class ProjectEventBus : IProjectEventBus
{
    // 参考 XDUF EventManager 的实现模式
    // 但使用项目的接口和命名
}
```

### L3: 参考设计

```
学习 XDUF 的:
- 设计模式 
- 接口设计
- 错误处理

然后从零实现满足项目需求的版本
```

---

## Checklist

在 design.md 完成前，确认：

- [ ] 阅读了所有 8 个 XDUF 模块的说明
- [ ] 对照项目需求确定了需要哪些能力
- [ ] 为每个能力选择了 XDUF 模块或自研
- [ ] 确定了每个 XDUF 模块的集成级别
- [ ] 在 design.md 中记录了 XDUF 集成决策表
