# Design Document Output Format

## 必需章节

```markdown
# Design: [项目名称]

## 0. 项目评估

### 规模评估

| 问题 | 答案 | 影响 |
|------|------|------|
| 项目定位 | Prototype / MVP / Production | ... |
| 预期生命周期 | <1月 / 1-6月 / >6月 | ... |
| 最终规模预期 | 小型 / 中型 / 大型 | ... |

### 评估结论

[根据评估结果，说明架构深度决策]

---

## 1. 变化点与抽象边界

### 变化点分析

| 领域 | 当前方案 | 可能的变化 | 需要接口？ | 接口名 |
|------|----------|------------|-----------|--------|
| 输入 | ... | ... | ✓/✗ | IInputProvider |
| 资源 | ... | ... | ✓/✗ | IResourceLoader |
| 配置 | ... | ... | ✓/✗ | IConfigProvider |
| 存储 | ... | ... | ✓/✗ | ISaveStorage |
| 时间 | ... | ... | ✓/✗ | ITimeProvider |
| 通信 | ... | ... | ✓/✗ | IEventBus |

### 接口定义

```csharp
// 列出所有需要的接口签名
public interface IInputProvider { ... }
public interface IResourceLoader { ... }
// ...
```

---

## 2. 项目架构

[调整后的项目结构，基于 architecture-template.md]

### 命名空间映射

| 目录 | 命名空间 |
|------|----------|
| Scripts/Core/Interfaces | {Project}.Core.Interfaces |
| Scripts/Gameplay/{Feature} | {Project}.Gameplay.{Feature} |
| ... | ... |

---

## 3. 核心系统设计

### [System Name]

- **职责**: 单一职责描述
- **依赖接口**: 依赖哪些抽象接口
- **发布事件**: 发布什么事件
- **订阅事件**: 订阅什么事件
- **变化应对**: 如果 X 变了，需要改这个系统吗？

**伪代码:**
```
class SystemName:
    # 依赖（构造注入）
    - readonly events: IEventBus
    - readonly config: IConfigProvider

    constructor(events, config):
        this.events = events
        this.config = config

    method Initialize():
        ...

    method Update():
        ...
```

**如果基于 XDUF 适配，添加参考标注:**
```
class EventBus:
    # 参考来源: ../XDUF/Assets/Framework/Events/EventManager.cs
    # 集成级别: L1 (复制适配)
    # 适配修改:
    #   - 命名空间: XDUF.Events → {Project}.Core.Events
    #   - 移除: [不需要的功能]
    #   - 简化: [简化的接口]

    method Publish<T>(in evt: T):
        ...
```

[为每个核心系统重复此结构]

---

## 4. 技术决策

### 决策 1: [接口实现选择]

| 接口 | 选择的实现 | 备选方案 | 选择理由 |
|------|-----------|----------|----------|
| IEventBus | 基于 XDUF 适配 | C# Events, SO Events | 零 GC，参考 ../XDUF/Events/ |
| IResourceLoader | ResourcesLoader | 异步封装 | 简单项目足够 |
| IPoolingService | 基于 XDUF 适配 | Unity ObjectPool | 泄漏检测，参考 ../XDUF/Pooling/ |
| ... | ... | ... | ... |

### 决策 2: [其他技术决策]

- **决策**: 选择了什么
- **备选方案**: 有哪些选项
- **选择理由**: 为什么这样选
- **权衡**: 已知的限制

[为每个重要技术决策重复此结构]

---

## 5. 组件关系

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   System A  │────▶│  IEventBus  │◀────│   System B  │
└─────────────┘     └─────────────┘     └─────────────┘
       │                   ▲                   │
       ▼                   │                   ▼
┌─────────────┐            │            ┌─────────────┐
│ IConfigProv │            │            │ IResourceLdr│
└─────────────┘            │            └─────────────┘
                    ┌──────┴──────┐
                    │   System C  │
                    └─────────────┘
```

### 数据流

1. 输入事件流: IInputProvider → EventBus → 订阅者
2. 状态更新流: System → EventBus → UI
3. 配置读取流: System → IConfigProvider → Config Data

---

## 6. 数据管理

### 配置数据

| 配置类型 | 存储方式 | 加载时机 | 热更新？ |
|----------|----------|----------|---------|
| 成长阶段 | ScriptableObject / JSON | 启动时 | ✓/✗ |
| 果实配置 | ScriptableObject / JSON | 启动时 | ✓/✗ |
| ... | ... | ... | ... |

### 运行时状态

| 状态 | 类型 | 管理者 |
|------|------|--------|
| 当前养分 | int | NutrientManager |
| 当前阶段 | int | PlantGrowthSystem |
| ... | ... | ... |

### 存档方案

- **存储格式**: JSON
- **存储位置**: Application.persistentDataPath
- **加密**: 是/否
- **数据结构**:
```csharp
public class SaveData
{
    public int Nutrients;
    public int PlantStage;
    public List<FruitData> Fruits;
    public DateTime LastPlayTime;
}
```

---

## 7. 性能考量

### 对象池

| 对象类型 | 预热数量 | 池化理由 |
|----------|----------|----------|
| 粒子特效 | 10 | 频繁生成/销毁 |
| 果实 | 8 | 最大同屏数量 |
| ... | ... | ... |

### Update 优化

| 优化策略 | 应用场景 |
|----------|----------|
| 降帧更新 | 后台运行时降低更新频率 |
| 事件驱动 | 用事件替代轮询检查 |
| ... | ... |

### 内存管理

| 策略 | 说明 |
|------|------|
| 资源异步加载 | 避免加载卡顿 |
| 按需加载 | 不预加载所有阶段资源 |
| ... | ... |

---

## 8. 风险缓解

| 风险（来自 research.md） | 缓解措施 |
|--------------------------|----------|
| 透明窗口兼容性 | 使用 TransparentWindowManager，固定 Unity 版本 |
| 数值平衡 | 配置表驱动，便于迭代调整 |
| 输入监听被拦截 | 提供管理员权限说明，杀毒白名单指南 |
| ... | ... |
```

---

## 验证清单

完成 design.md 前，确认：

- [ ] Section 0 包含项目规模评估
- [ ] Section 1 包含变化点分析和接口定义
- [ ] Section 2 包含项目结构和命名空间
- [ ] Section 3 包含所有核心系统设计（含伪代码）
- [ ] Section 4 包含技术决策和理由
- [ ] Section 5 包含组件关系图和数据流
- [ ] Section 6 包含数据管理策略
- [ ] Section 7 包含性能考量
- [ ] Section 8 包含风险缓解措施

### 架构质量检查

- [ ] 所有外部依赖都通过接口抽象
- [ ] Gameplay 模块不直接依赖 Core/Implementations
- [ ] 每个系统职责单一
- [ ] 所有可配置项都在配置表中
- [ ] 可以为核心系统编写单元测试
