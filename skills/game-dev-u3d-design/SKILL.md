---
name: game-dev-u3d-design
description: Designs Unity game architecture including project structure, Manager modules, pseudocode, and design patterns. Use during architecture planning phase.
---

# Design Unity Skill

Unity 游戏架构设计能力。

---

## 执行流程

### Step 1: 检测项目状态

检查是否为新项目或已有项目：

```bash
# 检测 Unity 项目
Glob: "**/ProjectSettings/ProjectVersion.txt"
```

**记录答案**：
- [ ] 是否为新项目？
- [ ] Unity 版本是什么？

---

### Step 2: XDUF 框架决策 (MANDATORY)

**MUST READ**: `reference/framework/XDUF_INTEGRATION.md`

阅读后回答以下问题（答案只能从文档中获取）：

| 问题 | 你的答案 |
|------|----------|
| 当前项目适合 L1/L2/L3 哪种集成级别？ | _____ |
| 需要采用哪些 XDUF 模块？ | _____ |
| 有哪些模块明确不需要？ | _____ |
| 初始化入口采用什么模式？ | _____ |

**将答案写入 design.md 的 `## 0. Framework Decision: XDUF` 部分。**

> 如果跳过此步骤，design.md 将缺少 Framework Decision 部分，用户可以立即发现。

---

### Step 3: 设计项目架构

**MUST READ**: `reference/templates/architecture.md`

根据项目需求调整架构模板，回答：

| 问题 | 你的答案 |
|------|----------|
| 需要哪些 Gameplay 模块？ | _____ |
| 需要哪些 UI Views？ | _____ |
| 是否需要 Editor 扩展？ | _____ |

**将架构写入 design.md 的 `## 1. Project Architecture` 部分。**

---

### Step 4: 设计核心系统

**MUST READ**: `reference/templates/design-patterns.md`

为每个核心系统选择合适的设计模式：

| 系统 | 选择的模式 | 原因 |
|------|-----------|------|
| _____ | _____ | _____ |

**将系统设计写入 design.md 的 `## 2. Core System Design` 部分。**

使用 `reference/templates/pseudocode.md` 中的格式编写伪代码。

---

### Step 5: 输出设计文档

**MUST READ**: `reference/templates/output-format.md`

按照输出格式模板创建完整的 design.md，确保包含：

- [ ] `## 0. Framework Decision: XDUF` (Step 2 的答案)
- [ ] `## 1. Project Architecture`
- [ ] `## 2. Core System Design` (含伪代码)
- [ ] `## 3. Component Relationships`
- [ ] `## 4. Technical Decisions`
- [ ] `## 5. Data Management`
- [ ] `## 6. Performance Considerations`
- [ ] `## 7. Risk Mitigation`

---

## 验证清单

在完成 design.md 前，确认以下内容：

- [ ] 已读取 `reference/framework/XDUF_INTEGRATION.md` 并做出框架决策
- [ ] 已读取 `reference/templates/architecture.md` 并调整项目结构
- [ ] 已读取 `reference/templates/design-patterns.md` 并选择设计模式
- [ ] 已读取 `reference/templates/pseudocode.md` 并使用正确格式
- [ ] design.md 包含 Framework Decision 部分（L1/L2/L3 决策）

---

## 触发条件

- 执行 design 阶段时
- 设计 Unity 项目架构时
- 编写伪代码时
- 应用设计模式时

---

## 引用文件索引

| 文件 | 用途 | 何时读取 |
|------|------|----------|
| `reference/framework/XDUF_INTEGRATION.md` | XDUF 集成指南 | Step 2 (必须) |
| `reference/framework/PATTERNS.md` | XDUF 设计模式参考 | Step 2 (如需深入) |
| `reference/framework/MIGRATION.md` | 迁移策略 | Step 2 (如需迁移) |
| `reference/templates/architecture.md` | 项目架构模板 | Step 3 (必须) |
| `reference/templates/design-patterns.md` | 设计模式模板 | Step 4 (必须) |
| `reference/templates/pseudocode.md` | 伪代码格式 | Step 4 (必须) |
| `reference/templates/output-format.md` | 输出格式模板 | Step 5 (必须) |
