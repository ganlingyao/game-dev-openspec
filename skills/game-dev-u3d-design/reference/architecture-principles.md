# 架构原则：变化点与抽象边界

## 核心理念

> **好的架构 = 当需求变化时，只需修改最少的代码**

### 依赖倒置原则

```
❌ 错误：高层模块依赖低层细节
PlantGrowthSystem → File.ReadAllText("config.json")
PlantGrowthSystem → Resources.Load<Sprite>("plant_stage_1")
PlantGrowthSystem → PlayerPrefs.SetInt("nutrients", value)

✓ 正确：高层模块依赖抽象接口
PlantGrowthSystem → IConfigProvider.GetConfig<PlantConfig>()
PlantGrowthSystem → IResourceLoader.LoadAsync<Sprite>(key)
PlantGrowthSystem → ISaveStorage.Save(key, value)
```

---

## 六大抽象边界

### 1. 输入边界 (IInputProvider)

**问自己**：输入来源未来会变吗？

| 今天 | 明天可能 |
|------|----------|
| 键盘/鼠标 | 手柄、触屏 |
| Unity Input | New Input System |
| Windows 钩子 | 跨平台输入 |

**接口设计**：
```csharp
public interface IInputProvider
{
    event Action<InputEvent> OnInput;
    void Initialize();
    void Shutdown();
}

// 实现可以是：
// - WindowsHookInputProvider (Windows API 钩子)
// - UnityInputProvider (Unity Input System)
// - MockInputProvider (测试用)
```

### 2. 资源边界 (IResourceLoader)

**问自己**：资源加载方式会变吗？

| 今天 | 明天可能 |
|------|----------|
| Resources.Load | Addressables |
| 本地资源 | 远程下载 |
| 同步加载 | 异步加载 |

**接口设计**：
```csharp
public interface IResourceLoader
{
    T Load<T>(string key) where T : Object;
    Task<T> LoadAsync<T>(string key) where T : Object;
    void Release(string key);
}
```

### 3. 配置边界 (IConfigProvider)

**问自己**：配置来源会变吗？策划需要热更新吗？

| 今天 | 明天可能 |
|------|----------|
| ScriptableObject | JSON 文件 |
| 本地配置 | 服务器下发 |
| 编译时固定 | 运行时热更 |

**接口设计**：
```csharp
public interface IConfigProvider
{
    T GetConfig<T>(string key) where T : class;
    void ReloadConfig(string key);
    event Action<string> OnConfigChanged;
}
```

### 4. 存储边界 (ISaveStorage)

**问自己**：存档位置会变吗？

| 今天 | 明天可能 |
|------|----------|
| PlayerPrefs | JSON 文件 |
| 本地存储 | 云存档 |
| 明文 | 加密 |

**接口设计**：
```csharp
public interface ISaveStorage
{
    void Save<T>(string key, T data);
    T Load<T>(string key, T defaultValue = default);
    void Delete(string key);
    bool Exists(string key);
}
```

### 5. 时间边界 (ITimeProvider)

**问自己**：需要控制时间吗？（离线计算、测试、暂停）

| 场景 | 需求 |
|------|------|
| 离线进度 | 计算两个时间点之间的差值 |
| 测试 | Mock 时间快进 |
| 暂停 | 游戏时间 vs 真实时间 |

**接口设计**：
```csharp
public interface ITimeProvider
{
    DateTime Now { get; }           // 当前时间
    float DeltaTime { get; }        // 帧间隔
    float GameTime { get; }         // 游戏运行时间
    void SetTimeScale(float scale); // 时间缩放
}
```

### 6. 事件边界 (IEventBus)

**问自己**：系统间需要解耦吗？

```
❌ 错误：直接引用
NutrientSystem.OnNutrientChanged += PlantGrowthSystem.CheckGrowth;
// NutrientSystem 必须知道 PlantGrowthSystem 的存在

✓ 正确：通过事件总线
eventBus.Publish(new NutrientChangedEvent(amount));
// NutrientSystem 不需要知道谁在监听
```

**接口设计**：
```csharp
public interface IEventBus
{
    void Publish<T>(in T evt) where T : struct;
    IDisposable Subscribe<T>(Action<T> handler) where T : struct;
}
```

---

## 变化点分析模板

在设计开始前，填写此表格：

| 领域 | 当前方案 | 可能的变化 | 是否需要接口？ | 接口名 |
|------|----------|------------|---------------|--------|
| 输入 | _____ | _____ | ✓/✗ | _____ |
| 资源 | _____ | _____ | ✓/✗ | _____ |
| 配置 | _____ | _____ | ✓/✗ | _____ |
| 存储 | _____ | _____ | ✓/✗ | _____ |
| 时间 | _____ | _____ | ✓/✗ | _____ |
| 通信 | _____ | _____ | ✓/✗ | _____ |

**决策规则**：
- 项目生命周期 > 6 个月 → 所有边界默认需要接口
- 项目规模 > 中型 → 所有边界默认需要接口
- 不确定是否会变 → 默认会变，创建接口

---

## 检验清单

设计完成后，对每个核心系统问：

- [ ] 它依赖的是接口还是具体实现？
- [ ] 如果依赖的实现换了，这个系统需要改吗？
- [ ] 能否为这个系统编写单元测试（mock 依赖）？
- [ ] 新增一种输入/资源/配置来源，需要改几个文件？

**目标**：每个问题的答案都是"1 个文件"或"不需要改"。
