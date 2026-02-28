# Unity Project Architecture Guide

## 核心原则

> **不要复制模板，要理解需求后设计结构。**

本文档是**思考指南**，不是**复制模板**。每个项目的结构应该根据实际需求设计。

---

## Step 1: 确定基础设施来源

在设计项目结构之前，先确定基础设施的来源：

### 1.1 阅读 XDUF 模块概览

**强制要求**：先阅读 [XDUF_INTEGRATION.md](framework/XDUF_INTEGRATION.md) 了解 XDUF 提供什么。

### 1.2 填写能力来源表

| 项目需要的能力 | XDUF 提供？ | 集成方式 | 项目中的位置 |
|---------------|------------|----------|-------------|
| 事件总线 | ✓ Events | L1/L2/L3 | Core/Events/ |
| 配置管理 | ✓ Config | L1/L2/L3 | Core/Config/ |
| 对象池 | ✓ Pooling | L1/L2/L3 | Core/Pooling/ |
| 资源加载 | ✓ Resource | L1/L2/L3 | Core/Resource/ |
| 输入系统 | ✓ Input | L1/L2/L3 | Core/Input/ |
| 状态机 | ✓ GameFramework | L1/L2/L3 | Core/GameFramework/ |
| 日志系统 | ✓ Diagnostics | L1/L2/L3 | Core/Diagnostics/ |
| 存档系统 | ✗ | 自研 | Core/Save/ |
| ... | | | |

**关键问题**：
- XDUF 已经提供的接口，项目应该**复用**还是**重新定义**？
- 如果 L1 集成，是否需要修改接口签名？
- 如果 L2/L3 集成，项目接口与 XDUF 接口的映射关系是什么？

---

## Step 2: 设计项目结构

基于 Step 1 的决策，设计项目结构。

### 2.1 核心结构（必需）
```
Assets/
│
├── Scripts/                     # All script code
│   │
│   ├── Core/                    # Core systems (reusable across projects)
│   │   ├── Base/                # Base classes (Singleton, StateMachine)
│   │   ├── Events/              # Event system (GameEvents, EventBus)
│   │   ├── Managers/            # Managers (GameManager, AudioManager, UIManager)
│   │   └── Utils/               # Utilities (ObjectPool, Timer, Extensions)
│   │
│   ├── Gameplay/                # Gameplay logic (project specific)
│   │   ├── Player/              # Player system (PlayerController, PlayerInput)
│   │   ├── Enemies/             # Enemy system (EnemyAI, EnemySpawner)
│   │   ├── Items/               # Item system (ItemPickup, Inventory)
│   │   ├── Combat/              # Combat system (DamageSystem, Projectile)
│   │   ├── Level/               # Level system (LevelManager, Checkpoint)
│   │   └── {Feature}/           # Other feature modules added as needed
│   │
│   ├── UI/                      # UI scripts
│   │   ├── Views/               # View controllers (MainMenuView, GameHUDView)
│   │   ├── Components/          # Reusable components (HealthBar, ProgressBar)
│   │   ├── Popups/              # Popups (SettingsPopup, ConfirmDialog)
│   │   └── Widgets/             # Widgets (Button, Toggle)
│   │
│   ├── Data/                    # Data definitions
│   │   ├── ScriptableObjects/   # SO class definitions (GameConfig, EnemyData)
│   │   ├── Constants/           # Constants (GameConstants, Tags, Layers)
│   │   └── Enums/               # Enum definitions (GameState, ItemType)
│   │
│   ├── Editor/                  # Editor extension scripts
│   │   ├── Tools/               # Custom tools
│   │   ├── Inspectors/          # Custom Inspectors
│   │   └── Windows/             # Custom Windows
│   │
│   └── Tests/                   # Test code
│       ├── EditMode/            # EditMode tests
│       └── PlayMode/            # PlayMode tests
│
├── Art/                         # Art assets
│   ├── Sprites/                 # Sprites
│   │   ├── Characters/          # Character sprites
│   │   ├── Environment/         # Environment sprites
│   │   ├── UI/                  # UI sprites
│   │   └── Effects/             # Effect sprites
│   │
│   ├── Animations/              # Animation assets
│   │   ├── Characters/          # Character animations
│   │   └── UI/                  # UI animations
│   │
│   ├── Materials/               # Materials
│   ├── Shaders/                 # Shaders
│   └── Textures/                # Textures
│
├── Prefabs/                     # Prefabs
│   ├── Characters/              # Character prefabs
│   │   ├── Player/
│   │   └── Enemies/
│   ├── Environment/             # Environment prefabs
│   ├── Items/                   # Item prefabs
│   ├── Effects/                 # Effect prefabs
│   └── UI/                      # UI prefabs
│       ├── Views/               # View prefabs
│       ├── Components/          # Component prefabs
│       └── Popups/              # Popup prefabs
│
├── Scenes/                      # Scene files
│   ├── Main/                    # Main scenes
│   ├── Levels/                  # Level scenes
│   └── Test/                    # Test scenes
│
├── ScriptableObjects/           # SO asset instances
│   ├── Config/                  # Config data (GameConfig.asset)
│   ├── GameData/                # Game data (EnemyData.asset)
│   └── Events/                  # Event assets (OnPlayerDied.asset)
│
├── Audio/                       # Audio assets
│   ├── Music/                   # Background music
│   ├── SFX/                     # SFX
│   └── Mixers/                  # Audio Mixer
│
├── Fonts/                       # Font files
│
├── ThirdParty/                  # Third-party assets (manually imported)
│
├── Resources/                   # Runtime dynamically loaded assets (use with caution)
│
└── StreamingAssets/             # Streaming assets
```

### Structure Design Principles

1. **Feature Module Separation**
   - `Scripts/` - All code centralized, separated by feature: Core/Gameplay/UI/Data
   - `Art/` - All art assets centralized, separated by type: Sprites/Animations/Materials
   - `Prefabs/` - All prefabs centralized, classified by feature

2. **Clear Hierarchy**
   - `Core/` - Reusable infrastructure across projects, no game logic dependencies
   - `Gameplay/` - Project-specific game logic
   - `Data/` - Pure data definitions, no behavioral logic

3. **Test Friendly**
   - `Scripts/Tests/` - Test code at the same level as source code
   - `EditMode/` and `PlayMode/` separated

4. **Asset Management**
   - `Resources/` - Only place assets that must be loaded dynamically at runtime
   - `ThirdParty/` - Isolate third-party assets for easy upgrade management
   - Use Addressables instead of Resources (Recommended)

5. **Naming Conventions**
   - Use PascalCase for folders
   - Correspond to code namespaces (e.g., `Scripts/Gameplay/Player/` → `namespace Game.Gameplay.Player`)

---

```
Assets/Scripts/
├── Core/                       # 基础设施
│   ├── [从 XDUF 集成的模块]
│   └── [自研的模块]
│
├── Gameplay/                   # 游戏逻辑
│   └── [功能模块]
│
├── UI/                         # UI 脚本
│   └── [视图和组件]
│
└── Data/                       # 数据定义
    ├── Events/                 # 事件结构
    ├── Configs/                # 配置结构
    └── SaveData/               # 存档结构
```

### 2.2 Core 目录设计

Core 目录的结构取决于 XDUF 集成决策：

**方案 A: L1 集成多个模块**
```
Core/
├── Events/                     # 从 XDUF.Events 复制适配
│   ├── IEventManager.cs
│   ├── EventManager.cs
│   └── Internals/
├── Config/                     # 从 XDUF.Config 复制适配
│   ├── IConfigManager.cs
│   └── ...
├── Pooling/                    # 从 XDUF.Pooling 复制适配
│   └── ...
└── Save/                       # 自研
    ├── ISaveStorage.cs
    └── JsonSaveStorage.cs
```

**方案 B: 自定义接口 + XDUF 实现参考**
```
Core/
├── Interfaces/                 # 项目定义的接口
│   ├── IEventBus.cs           # 基于 XDUF IEventManager 设计
│   ├── IConfigProvider.cs     # 基于 XDUF IConfigManager 设计
│   └── ...
└── Implementations/            # 接口实现
    ├── Events/
    │   └── EventBus.cs        # 参考 XDUF EventManager 实现
    └── ...
```

**选择依据**：
- 如果项目接口与 XDUF 完全一致 → 方案 A
- 如果项目需要定制接口 → 方案 B

### 2.3 Gameplay 目录设计

根据 proposal.md 的功能列表设计：

```
Gameplay/
├── [功能1]/                    # 来自 proposal.md
├── [功能2]/
└── ...
```

**示例**（桌面植物项目）：
```
Gameplay/
├── Nutrient/                   # 养分系统
│   └── NutrientManager.cs
├── Plant/                      # 植物系统
│   ├── PlantGrowthSystem.cs
│   └── PlantVisualController.cs
├── Fruit/                      # 果实系统
│   ├── FruitSpawner.cs
│   └── FruitHarvester.cs
└── Feedback/                   # 反馈系统
    └── ClickFeedbackSystem.cs
```

---

## Step 3: 定义依赖规则

### 3.1 依赖方向图

```
                    ┌─────────────┐
                    │    Data     │
                    │ (Events,    │
                    │  Configs)   │
                    └─────────────┘
                          ▲
                          │ 引用数据结构
         ┌────────────────┼────────────────┐
         │                │                │
         ▼                ▼                ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  Gameplay   │    │     UI      │    │    Core     │
│ (业务逻辑)  │    │ (视图/交互) │    │ (基础设施) │
└─────────────┘    └─────────────┘    └─────────────┘
         │                │                │
         │                │                │
         └────────────────┼────────────────┘
                          │ 依赖接口
                          ▼
                 ┌─────────────────┐
                 │ Core.Interfaces │
                 │ 或 XDUF 接口    │
                 └─────────────────┘
```

### 3.2 依赖规则

| 模块 | 可以依赖 | 禁止依赖 |
|------|----------|----------|
| Data | 无 | 任何其他模块 |
| Core | Data, XDUF 接口 | Gameplay, UI |
| Gameplay | Core 接口, Data | UI, Core 实现 |
| UI | Core 接口, Data | Gameplay 内部类 |

### 3.3 示例

```csharp
// ✓ 正确: Gameplay 依赖 Core 接口
public class NutrientManager
{
    private readonly IEventManager _events;  // XDUF 接口
    private readonly IConfigManager _config; // XDUF 接口

    public NutrientManager(IEventManager events, IConfigManager config)
    {
        _events = events;
        _config = config;
    }
}

// ✗ 错误: Gameplay 依赖 Core 实现
public class NutrientManager
{
    private readonly EventManager _events;  // 具体实现！
}
```

---

## Step 4: 设计命名空间

命名空间应该反映项目结构和 XDUF 集成决策。

### 4.1 集成 XDUF (L1) 的命名空间

如果直接复制 XDUF 代码：
```
XDUF.Events      → {Project}.Core.Events
XDUF.Config      → {Project}.Core.Config
XDUF.Pooling     → {Project}.Core.Pooling
```

### 4.2 自定义接口的命名空间

如果项目定义自己的接口：
```
{Project}.Core.Interfaces     # 项目接口
{Project}.Core.Events         # 事件实现
{Project}.Core.Config         # 配置实现
```

### 4.3 完整映射表（示例）

| 目录 | 命名空间 |
|------|----------|
| Scripts/Core/Events/ | Plants.Core.Events |
| Scripts/Core/Config/ | Plants.Core.Config |
| Scripts/Core/Pooling/ | Plants.Core.Pooling |
| Scripts/Core/Save/ | Plants.Core.Save |
| Scripts/Gameplay/Nutrient/ | Plants.Gameplay.Nutrient |
| Scripts/Gameplay/Plant/ | Plants.Gameplay.Plant |
| Scripts/UI/Views/ | Plants.UI.Views |
| Scripts/Data/Events/ | Plants.Data.Events |

---

## Step 5: Bootstrap 设计

### 5.1 服务初始化顺序

基于 XDUF 模块依赖关系设计初始化顺序：

```
1. 独立模块（无依赖）
   - LoggerManager (Diagnostics)
   - PoolingService (Pooling)
   - ResourceManager (Resource)

2. 核心事件系统
   - EventManager (Events)

3. 依赖事件的模块
   - ConfigManager (Config) ← 依赖 Events
   - InputService (Input) ← 依赖 Events
   - GameManager (GameFramework) ← 依赖 Events

4. 游戏业务系统
   - NutrientManager
   - PlantGrowthSystem
   - ...
```

### 5.2 Bootstrap 代码结构

```csharp
public class GameBootstrap : MonoBehaviour
{
    void Awake()
    {
        // 1. 创建基础设施（按依赖顺序）
        var events = new EventManager();
        var config = new ConfigManager(events);
        var pool = new PoolingService();
        var resource = new ResourceManager();

        // 2. 初始化基础设施
        events.Initialize();
        config.Initialize();
        pool.Initialize();
        resource.Initialize();

        // 3. 创建游戏系统（注入依赖）
        var nutrient = new NutrientManager(events, config);
        var plant = new PlantGrowthSystem(events, config);
        // ...

        // 4. 初始化游戏系统
        nutrient.Initialize();
        plant.Initialize();
        // ...
    }
}
```

---

## Checklist

设计项目结构前：
- [ ] 阅读了 XDUF_INTEGRATION.md
- [ ] 填写了能力来源表
- [ ] 确定了每个 XDUF 模块的集成级别

设计项目结构时：
- [ ] Core 目录结构反映了 XDUF 集成决策
- [ ] Gameplay 目录结构来自 proposal.md 功能列表
- [ ] 依赖规则清晰，无循环依赖
- [ ] 命名空间与目录结构一致

设计 Bootstrap 时：
- [ ] 初始化顺序遵循 XDUF 模块依赖关系
- [ ] 所有依赖通过构造函数注入
