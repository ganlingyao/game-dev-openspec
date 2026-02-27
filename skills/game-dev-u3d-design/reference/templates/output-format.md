# Design Document Output Format

## Required Sections

```markdown
# Design: [Game Name]

## 0. Framework Decision: XDUF

### 评估结果

根据 XDUF Migration Guide 评估：

| 问题 | 答案 | 建议 |
|------|------|------|
| 是新项目吗？ | ✓/✗ | ... |
| 有现有事件系统吗？ | ✓/✗ | ... |
| 有对象池吗？ | ✓/✗ | ... |
| 代码量 < 10k LOC？ | ✓/✗ | ... |

### 决策：L1/L2/L3

**采用方式：** Git Submodule / Selective / Reference Only

**采用模块：**

| 模块 | 采用 | 用途 |
|------|------|------|
| XDUF.Events | ✓/✗ | ... |
| XDUF.Pooling | ✓/✗ | ... |
| XDUF.Config | ✓/✗ | ... |
| ... | ... | ... |

---

## 1. Project Architecture

[调整后的项目结构，基于 templates/architecture.md]

---

## 2. Core System Design

### [System Name]
- **Responsibility**: What this system does
- **Pattern**: Design patterns used
- **Dependencies**: What it depends on, what depends on it

**Pseudocode:**
```
class SystemName:
    ...
```

[为每个核心系统重复此结构]

---

## 3. Component Relationships

```
System A → System B → System C
         ↓
      System D

EventManager ←→ All Systems
```

[系统间依赖关系图]

---

## 4. Technical Decisions

### Decision 1: [Decision Name]
- **Decision**: What was chosen
- **Alternatives**: What options were available
- **Reason**: Why it was chosen
- **Trade-offs**: Known limitations

[为每个重要技术决策重复此结构]

---

## 5. Data Management

### Config Data
- 使用方案：ScriptableObjects / JSON / ...
- 配置类型列表

### Runtime State
- 需要追踪的运行时状态
- 状态管理方案

### Save/Load
- 存储格式：JSON / Binary / ...
- 存储位置：persistentDataPath / ...
- 数据结构

---

## 6. Performance Considerations

### Object Pooling
- 需要池化的对象列表
- 预热策略

### Update Optimization
- 降帧策略
- 批量处理策略

### Memory Management
- 资源加载策略
- GC 优化策略

---

## 7. Risk Mitigation

| 风险 | 缓解措施 |
|------|----------|
| [Risk 1] | [Mitigation] |
| [Risk 2] | [Mitigation] |
| ... | ... |
```

## Section Checklist

Before completing design.md, ensure:

- [ ] Section 0 contains XDUF decision with L1/L2/L3 choice
- [ ] Section 1 contains project structure
- [ ] Section 2 contains all core systems with pseudocode
- [ ] Section 3 contains component relationship diagram
- [ ] Section 4 contains key technical decisions
- [ ] Section 5 contains data management strategy
- [ ] Section 6 contains performance considerations
- [ ] Section 7 contains risk mitigation table
