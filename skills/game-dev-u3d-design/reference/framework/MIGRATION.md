# Migration Guide

如何将 XDUF 参考实现适配到现有项目。

---

## 适配评估

| 问题 | 如果"是" | 如果"否" |
|------|----------|----------|
| 是新项目？ | 直接参考 XDUF 创建实现 | 继续评估 |
| 已有事件系统？ | 评估是否需要替换 | 参考 XDUF Events 创建 |
| 已有对象池？ | 评估性能，考虑是否迁移 | 参考 XDUF Pooling 创建 |
| 代码量 < 1 万行？ | 可一次性适配 | 建议增量适配 |
| 有完善的测试？ | 适配更安全 | 先写测试再适配 |

---

## 适配策略

### 策略 1: 一次性适配（小型项目）

一次性创建所有基础设施实现。

**适用条件**：
- 项目 < 10,000 行代码
- 有良好的测试覆盖
- 团队有集中时间

**时间线**：1-2 周

---

### 策略 2: 增量适配（大型项目）

逐步用 XDUF 参考实现替换旧系统。

**适用条件**：
- 大型代码库
- 生产环境系统
- 有限的重构时间

**阶段**：

1. **并存阶段** - XDUF 参考实现与遗留代码共存
2. **适配器阶段** - 创建桥接层连接新旧系统
3. **逐步迁移** - 一个功能一个功能地迁移
4. **清理阶段** - 删除遗留代码

**时间线**：4-12 周

---

### 策略 3: 按模块适配（推荐）

根据价值优先级逐个适配 XDUF 模块。

**推荐顺序**：

1. **Events** - 零 GC，影响最大
2. **Pooling** - 性能提升明显
3. **Resource** - 异步加载收益
4. **GameFramework** - 状态管理

---

## 常见适配任务

### 适配事件系统

#### 从 C# Events 迁移
```csharp
// 旧代码
public static event Action<Enemy> OnEnemyKilled;
void Kill() => OnEnemyKilled?.Invoke(this);

// 新代码（参考 XDUF 适配）
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

### 适配对象池

```csharp
// 旧代码：自定义池
public class BulletPool
{
    private Stack<GameObject> _pool = new Stack<GameObject>();
    public GameObject Get() { ... }
    public void Return(GameObject obj) { ... }
}

// 新代码（参考 XDUF 适配）
_poolingService.RegisterPrefab("Bullet", bulletPrefab);
var bullet = _poolingService.Rent("Bullet");
_poolingService.Return("Bullet", bullet);

// 额外收益：指标统计
var metrics = _poolingService.GetMetrics("Bullet");
Debug.Log($"Active: {metrics.ActiveCount}, Available: {metrics.AvailableCount}");
```

### 适配单例模式

```csharp
// 旧代码：基础单例
public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }
    void Awake()
    {
        Instance = this;
        DontDestroyOnLoad(gameObject);
    }
}

// 新代码：依赖注入（参考 XDUF 模式）
public class GameInitializer : MonoBehaviour
{
    private IGameManager _gameManager;

    void Awake()
    {
        var events = new EventBus();  // 基于 XDUF 适配
        var sceneLoader = new SceneLoader(events, this);
        _gameManager = new GameManager(events, sceneLoader, MapScene);
        _gameManager.Initialize();
    }
}
```

---

## 适配期间的测试

### 功能开关

```csharp
public static class MigrationFlags
{
    public static bool UseNewEvents = true;
    public static bool UseNewPooling = false;  // 尚未适配
}

// 使用
if (MigrationFlags.UseNewEvents)
    _newEvents.Publish(new EnemyKilled(id, score));
else
    LegacyEvents.Send("EnemyKilled", id, score);
```

### 回滚方案

```bash
# 如果适配出问题
git revert <migration-commit>
```

---

## 成功指标

| 指标 | 目标 |
|------|------|
| 帧耗时 | -10% |
| GC 分配/帧 | -50% |
| 内存占用 | -20% |
| 加载时间 | -30% |
| 测试覆盖 | +20% |

使用 Unity Profiler 和 XDUF 指标测量改进效果。
