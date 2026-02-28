---
name: game-dev-u3d-design
description: |
  Designs Unity game architecture with focus on long-term maintainability.
  Identifies change points, defines abstraction boundaries, and creates
  pseudocode for core systems. Use during architecture planning phase,
  OpenSpec design artifact creation, or when user asks about Unity project
  structure, system design, or technical architecture.
allowed-tools: Read, Glob, Grep, Write, Bash
---

# Unity Architecture Design

设计可长期维护的 Unity 游戏架构。

**核心原则**：当需求变化时，修改范围最小化。

---

## 执行流程

### Step 1: 评估项目规模

阅读 proposal.md（或用户需求），回答：

| 问题 | 选项 | 影响 |
|------|------|------|
| 项目定位 | Prototype / MVP / Production | 决定架构深度 |
| 预期生命周期 | <1月 / 1-6月 / >6月 | 决定扩展性投入 |
| 最终规模预期 | 小型 / 中型 / 大型 | 决定模块化程度 |

**决策规则**：
- 包含 "Production" / ">6月" / "中型以上" → 所有边界默认需要抽象
- 仅 "Prototype" + "<1月" + "小型" → 可简化部分抽象

将评估结果写入 design.md 的 `## 0. 项目评估` 部分。

---

### Step 2: 了解 XDUF 框架 (强制)

**⚠️ 这是强制步骤，不可跳过。**

**MUST READ**: [reference/framework/XDUF_INTEGRATION.md](reference/framework/XDUF_INTEGRATION.md)

在定义任何接口之前，必须先了解 XDUF 提供什么。

#### 2.1 确保 XDUF 可用

检查 XDUF 仓库：
```bash
ls <项目父目录>/XDUF/README.md
```

如不存在，请执行自动拉取项目：
```bash
cd <项目父目录>
git clone git@git-huge.xindong.com:ganlingyao/xduf.git XDUF
```

#### 2.2 阅读 XDUF README

**MUST READ**: `../XDUF/README.md`

记录 XDUF 提供的模块：

| XDUF 模块 | 功能 | 核心接口 |
|-----------|------|----------|
| Core | 生命周期管理 | IManager |
| Events | 零 GC 事件总线 | IEventManager |
| Config | 配置加载/缓存 | IConfigManager |
| Pooling | 对象池 | IPoolingService |
| Resource | 异步资源加载 | IResourceManager |
| Input | 输入抽象 | IInputService |
| GameFramework | 状态机/场景 | IGameManager |
| Diagnostics | 日志系统 | LoggerManager |

#### 2.3 确定项目需要的能力

对照 proposal.md 的功能需求，填写能力来源表：

| 项目需要的能力 | XDUF 提供？ | 集成方式 | 备注 |
|---------------|------------|----------|------|
| 事件通信 | ✓ Events | L1/L2/L3 | |
| 配置管理 | ✓ Config | L1/L2/L3 | |
| 对象池 | ✓ Pooling | L1/L2/L3 | |
| 资源加载 | ✓ Resource | L1/L2/L3 | |
| 输入系统 | ✓/✗ Input | | 判断 XDUF Input 是否满足需求 |
| 状态管理 | ✓/✗ GameFramework | | |
| 存档系统 | ✗ | 自研 | XDUF 不提供 |
| ... | .. | .. | ... |
| [项目特有] | ✗ | 自研 | |

将 XDUF 集成决策写入 design.md 的 `## XDUF 集成决策` 部分。

---

### Step 3: 识别变化点与定义边界

**MUST READ**: [reference/architecture-principles.md](reference/architecture-principles.md)

#### 3.1 分析变化点

对每个领域判断是否可能变化：

| 领域 | 问自己 | 可能变化？ |
|------|--------|-----------|
| 事件通信 | 需要换实现吗？ | 通常不变，用 XDUF |
| 配置来源 | 会从 SO 换成 JSON/远程？ | 可能，用 XDUF |
| 资源加载 | 会换成 Addressables？ | 可能，用 XDUF |
| 输入来源 | 会支持新设备/平台？ | 视项目需求 |
| 存档位置 | 会换成云存档？ | 可能，需要自研接口 |
| ... | .. | ... |

#### 3.2 定义接口

**关键原则**：优先使用 XDUF 提供的接口，只有 XDUF 不提供或不满足需求时才自定义。

**XDUF 已有的接口**（直接使用或 L1 适配）：
- IEventManager / IEventBus
- IConfigManager
- IPoolingService
- IResourceManager
- IInputService
- IGameManager

**需要自研的接口**（XDUF 不提供）：
- ISaveStorage（存档）
- [项目特有接口]

将变化点分析和接口定义写入 design.md 的 `## 1. 变化点与抽象边界` 部分。

---

### Step 4: 设计项目架构

**MUST READ**: [reference/architecture-template.md](reference/architecture-template.md)

#### 4.1 分析项目现状

探索 `Assets/Scripts/` 目录，记录：
- 已存在哪些模块/系统？
- 采用什么架构模式？
- 哪些接口已有实现？

#### 4.2 设计目录结构

基于 Step 2 和 Step 3 的决策设计结构：

```
Assets/Scripts/
├── Core/                       # 基础设施
│   ├── [XDUF L1 集成的模块]    # 从 XDUF 复制适配
│   └── [自研模块]              # XDUF 不提供的
├── Gameplay/                   # 游戏逻辑（来自 proposal）
│   └── [功能模块]
├── UI/
└── Data/
    ├── Events/                 # 事件定义（readonly struct）
    ├── Configs/                # 配置类定义
    └── SaveData/               # 存档数据定义
```

**Core 目录应该反映 XDUF 集成决策**：
- L1 集成的模块 → 从 XDUF 复制，改命名空间
- 自研模块 → 自己实现

将架构设计写入 design.md 的 `## 2. 项目架构` 部分。

---

### Step 5: 设计核心系统

**MUST READ**:
- [reference/design-patterns.md](reference/design-patterns.md)
- [reference/pseudocode-format.md](reference/pseudocode-format.md)

#### 5.1 基础设施系统

对于 XDUF 集成的模块，伪代码应标注来源：

```
class EventBus implements IEventManager:
    # 来源: XDUF.Events.EventManager
    # 集成级别: L1 (复制适配)
    # 修改:
    #   - 命名空间: XDUF.Events → {Project}.Core.Events
    #   - 移除: [不需要的功能]

    method Publish<T>(in evt: T) where T : struct:
        # [参考 XDUF 实现]
```

对于自研模块，正常编写伪代码。

#### 5.2 游戏业务系统

为每个核心系统定义：

1. **职责**：单一职责，只做一件事
2. **依赖**：依赖 XDUF 接口或自研接口
3. **事件**：发布什么事件？订阅什么事件？
4. **变化应对**：如果 X 变了，需要改这个系统吗？

将系统设计写入 design.md 的 `## 3. 核心系统设计` 部分。

---

### Step 6: 验证设计

对每个设计决策检验：

| 检查项 | 目标 | 通过？ |
|--------|------|--------|
| 需求变化时改几个文件？ | 1-2 个 | [ ] |
| 加新内容是改代码还是加配置？ | 加配置 | [ ] |
| 能 mock 外部依赖进行测试吗？ | 能 | [ ] |
| 新人能理解数据流向吗？ | 能 | [ ] |
| XDUF 模块是否正确使用？ | 是 | [ ] |

如果有检查项未通过，回到相应步骤调整。

---

### Step 7: 输出 design.md

**MUST READ**: [reference/output-format.md](reference/output-format.md)

确保 design.md 包含以下部分：

- [ ] `## 0. 项目评估` - Step 1 结果
- [ ] `## XDUF 集成决策` - Step 2 结果（能力来源表、集成级别）
- [ ] `## 1. 变化点与抽象边界` - Step 3 结果
- [ ] `## 2. 项目架构` - Step 4 结果
- [ ] `## 3. 核心系统设计` - Step 5 结果（含伪代码，标注 XDUF 来源）
- [ ] `## 4. 技术决策` - 其他技术选择
- [ ] `## 5. 组件关系` - 系统间依赖图
- [ ] `## 6. 数据管理` - 配置、运行时、存档
- [ ] `## 7. 性能考量` - 对象池、Update 优化
- [ ] `## 8. 风险缓解` - research.md 中风险的应对

---

## 触发条件

此 Skill 在以下情况自动触发：
- OpenSpec workflow 的 design 阶段
- 用户询问 Unity 项目架构设计
- 用户询问系统设计或技术决策
- 用户需要编写技术设计文档

---

## 引用文件索引

| 文件 | 用途 | 何时读取 |
|------|------|----------|
| `reference/framework/XDUF_INTEGRATION.md` | XDUF 模块概览和集成指南 | **Step 2 (强制)** |
| `../XDUF/README.md` | XDUF 官方文档 | **Step 2 (强制)** |
| `reference/architecture-principles.md` | 架构原则：变化点、抽象边界 | Step 3 (必须) |
| `reference/architecture-template.md` | 项目结构设计指南 | Step 4 (必须) |
| `reference/design-patterns.md` | 设计模式参考 | Step 5 (必须) |
| `reference/pseudocode-format.md` | 伪代码格式 | Step 5 (必须) |
| `reference/output-format.md` | 输出格式模板 | Step 7 (必须) |
