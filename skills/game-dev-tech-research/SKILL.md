---
name: game-dev-tech-research
description: |
  Unity API 技术调研能力。验证 design.md 中的设计在 Unity 中的可行性，将伪代码映射到真实 Unity API。

  **必须使用 unity-csharp-explorer agent 验证每个 API，禁止依赖 AI 内部知识。**

  在以下情况触发此 skill：
  - openspec 工作流的 tech-research 阶段
  - 用户要求验证 Unity API 可行性
  - 用户要求将设计伪代码映射到 Unity 实现
  - 用户提到"技术调研"、"API 验证"、"Unity 可行性"
---

# Tech Research Unity Skill

产出 `tech-research.md` 文档，验证 design.md 中的设计在 Unity 中的可行性。

---

## Step 0: 前置检查 (必须首先执行)

### 0.1 检查 unity-csharp-explorer agent

使用 Agent 工具尝试调用 unity-csharp-explorer：

```
Agent(subagent_type="unity-csharp-explorer", prompt="ping")
```

#### 情况 A: Agent 可用

继续执行 Step 1。

#### 情况 B: Agent 不存在

检查 agent 文件是否已安装：

```
Glob: ".claude/agents/unity-csharp-explorer.md"
```

**如果文件不存在**，执行安装：

```bash
mkdir -p .claude/agents
LATEST_TAG=$(git ls-remote --tags --sort=-v:refname https://github.com/zhing2006/unity-csharp-explorer.git | head -1 | sed 's/.*refs\/tags\///')
curl -fsSL "https://raw.githubusercontent.com/zhing2006/unity-csharp-explorer/${LATEST_TAG}/.claude/agents/unity-csharp-explorer.md" -o .claude/agents/unity-csharp-explorer.md
```

安装完成后，**必须**使用 AskUserQuestion 工具提示用户：

```
AskUserQuestion:
  question: "unity-csharp-explorer agent 已安装，但需要重启 Claude Code 才能激活。请重启后再次执行此 skill。"
  options:
    - label: "我已了解，稍后重启"
      description: "关闭此对话，重启 Claude Code，然后重新执行 tech-research"
```

**然后立即停止执行此 skill。不进行任何后续步骤。**

**如果文件已存在但 agent 调用失败**（返回 "Agent type not found"），说明 agent 已安装但未激活。使用 AskUserQuestion 提示用户：

```
AskUserQuestion:
  question: "unity-csharp-explorer agent 已安装但未激活。必须重启 Claude Code 才能使用。请重启后再次执行此 skill。"
  options:
    - label: "我已了解，稍后重启"
      description: "关闭此对话，重启 Claude Code，然后重新执行 tech-research"
```

**然后立即停止执行此 skill。不进行任何后续步骤。**

> **重要**: 此 skill 要求使用 unity-csharp-explorer 进行源码级 API 验证。没有可用的 agent 时，**禁止**使用 WebSearch 或 AI 内部知识作为替代方案。必须等待用户重启 Claude Code。

### 0.2 检查 Unity 项目版本

使用 Glob 查找 Unity 项目版本文件：

```
Glob: "**/ProjectSettings/ProjectVersion.txt"
```

#### 情况 A: 项目存在

读取版本文件：

```
Read: "ProjectSettings/ProjectVersion.txt"
```

提取版本号（如 `2022.3.62f1`）。后续所有 API 验证基于此版本。

#### 情况 B: 项目不存在

使用 WebSearch 比较当前 LTS 版本，推荐合适版本。

---

## Step 1: 提取 Unity APIs

从 `design.md` 中提取所有涉及的 Unity API：

- 类名（MonoBehaviour, ScriptableObject, SpriteMask 等）
- 方法名（StartCoroutine, DontDestroyOnLoad 等）
- 属性名（Time.deltaTime, Input.GetKeyDown 等）
- 组件（SpriteRenderer, AudioSource 等）
- 数据类型（Vector2Int, WaitForSeconds 等）

---

## Step 2: 使用 unity-csharp-explorer 验证 API (强制)

**此步骤为强制步骤，不可跳过。**

对每个提取的 API，调用 unity-csharp-explorer agent 验证：

```
Agent(subagent_type="unity-csharp-explorer", prompt="Find the definition of [API Name], including its namespace, methods, and properties")
```

unity-csharp-explorer 会：
1. 确保 UnityCsReference 源码可用（按需克隆）
2. 搜索 Unity C# 源码
3. 返回实际定义、签名和命名空间

**验证清单**：
- API 是否存在
- 方法/属性签名是否正确
- 所需的 using 语句/命名空间
- 目标 Unity 版本中是否可用
- 是否有 [Obsolete] 标记

---

## Step 3: 伪代码到 Unity API 映射

将 design.md 中的伪代码转换为实际 Unity C# 代码：

```markdown
### [系统名称] - [功能名称]

**设计伪代码:**
```
[来自 design.md 的伪代码]
```

**Unity 实现:**
```csharp
[基于 unity-csharp-explorer 验证结果的实际代码]
```

**验证来源**: unity-csharp-explorer
**注意事项:**
- 使用 [API 名称] 因为 [原因]
- 注意: [注意事项]
```

---

## Step 4: 第三方包评估

评估项目所需的 Unity 包：
- 必须的内置包（如 TextMeshPro）
- 推荐的第三方包
- 应排除的包

---

## 输出格式

```markdown
# Tech Research: [游戏名称]

## 1. Unity 版本

**项目检测**: ✓ 已存在 / ✗ 新项目
**版本**: Unity X.X.X
**版本文件**: ProjectSettings/ProjectVersion.txt

## 2. API 验证清单

| API | 来源 | 验证工具 | 结果 | 命名空间 |
|-----|------|----------|------|----------|
| MonoBehaviour | design.md:XX | unity-csharp-explorer | ✓ | UnityEngine |
| ... | ... | ... | ... | ... |

## 3. 设计验证

### [系统名称]
- **设计**: [设计模式]
- **Unity 验证**: ✓ 可直接实现 / ⚠ 需要调整
- **验证工具**: unity-csharp-explorer
- **注意**: [Unity 特定注意事项]
- **调整建议**: [如需要]

## 4. 伪代码 → Unity API 映射

### [系统] - [功能]

**设计伪代码:**
```
...
```

**Unity 实现:**
```csharp
...
```

**验证来源**: unity-csharp-explorer

## 5. 所需 Unity API 汇总

| 系统 | Unity APIs | 命名空间 | 说明 |
|------|-----------|----------|------|
| ... | ... | ... | ... |

## 6. 第三方包建议

| 包名 | 用途 | 建议 |
|------|------|------|
| TextMeshPro | 文本渲染 | ✓ 必须 (内置) |
| ... | ... | ... |

## 7. API 快速参考

```csharp
// 常用 API 快速参考
...
```

## 8. 潜在问题与调整

| 问题 | 影响 | 解决方案 |
|------|------|----------|
| ... | ... | ... |
```

---

## 重要规则

1. **必须使用 unity-csharp-explorer** - 禁止使用 WebSearch 或 AI 知识替代源码验证
2. **Agent 不可用时停止执行** - 提示用户重启，不继续后续步骤
3. **记录验证来源** - 输出中每个 API 标注 "unity-csharp-explorer"
4. **版本兼容性** - 确认 API 在目标 Unity 版本中可用
5. **标记废弃 API** - 如发现废弃 API，提供替代方案
