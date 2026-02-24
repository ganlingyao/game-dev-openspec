---
name: tech-research-unity
description: Unity API 技术调研能力。验证 design.md 中的设计在 Unity 中的可行性，将伪代码映射到真实 Unity API。必须使用 unity-csharp-explorer 工具验证每个 API。自动在 tech-research 阶段触发。
---

# Tech Research Unity Skill - Unity API Technical Research

Used for the **tech-research phase** of the openspec workflow, producing `tech-research.md`.

---

## Core Principles

> **Must use unity-csharp-explorer to verify every Unity API. Do NOT rely on AI internal knowledge.**

---

## Mandatory Tools

| Tool | Purpose | Mandatory |
|------|---------|-----------|
| **unity-csharp-explorer** | Verify Unity API existence, signature, and usage | **Yes** |
| WebSearch | Search for Unity version comparisons, best practices | Optional |

### unity-csharp-explorer Usage

See [tools/unity-csharp-explorer.md](tools/unity-csharp-explorer.md)

```
Task Tool Parameters:
- subagent_type: unity-csharp-explorer
- prompt: "Find the definition, signature, and usage of [API Name]"
- description: "Verify [API Name]"
```

---

## Research Steps

### Step 0: Detect Existing Unity Project (Must Execute First)

**Before conducting any research, you must check if a Unity project already exists in the current directory.**

#### Detection Method

Use the Glob tool to find the Unity project version file:

```
Glob: "**/ProjectSettings/ProjectVersion.txt"
```

#### Case A: Project Exists

If `ProjectVersion.txt` is found, read the file to get the Unity version:

```
Read: "ProjectSettings/ProjectVersion.txt"
```

Example File Format:
```
m_EditorVersion: 6000.0.50f1
m_EditorVersionWithRevision: 6000.0.50f1 (f1ef1dca8bff)
```

**Extract the version number** (e.g., `6000.0.50f1`). All subsequent API research must be based on this version.

Explicitly state in the output:
```markdown
## 1. Unity Version

**Existing Project Detected**: ✓
**Project Version**: Unity 6000.0.50f1 (Unity 6)
**Version File**: ProjectSettings/ProjectVersion.txt

> All API research in this document is based on the actual Unity version used in the project.
```

#### Case B: Project Does Not Exist

If the version file is not found, proceed with version recommendation:

Use WebSearch to compare current LTS versions:

```
WebSearch: "Unity LTS versions comparison 2024 2025"
```

Recommend a version based on project requirements, considering:
- Stability vs. New Features
- Target Platform Support
- Third-party Package Compatibility

State in the output:
```markdown
## 1. Unity Version Recommendation

**Existing Project Detected**: ✗
**Recommended Version**: Unity 2022.3 LTS
**Reason**: ...
```

---

### Step 1: Extract Unity APIs from design.md

Read `design.md` and extract all involved Unity APIs:

**Content to Extract**:
- Class Names (e.g., `MonoBehaviour`, `ScriptableObject`, `SpriteMask`)
- Method Names (e.g., `StartCoroutine`, `DontDestroyOnLoad`)
- Property Names (e.g., `Time.deltaTime`, `Input.GetKeyDown`)
- Components (e.g., `SpriteRenderer`, `AudioSource`)
- Data Types (e.g., `Vector2Int`, `WaitForSeconds`)

### Step 2: Verify Each API using unity-csharp-explorer (Mandatory)

**This step is mandatory and cannot be skipped.**

For each extracted API, call unity-csharp-explorer to verify:

```
Task:
  subagent_type: unity-csharp-explorer
  prompt: "Find the definition of SpriteMask class, including sprite property and common methods"
  description: "Verify SpriteMask API"
```

**Verification Checklist**:
- [ ] API exists
- [ ] Correct signature for methods/properties
- [ ] Required using statements/namespaces
- [ ] Available in the target Unity version
- [ ] Check for deprecation warnings

### Step 3: Pseudocode to Unity API Mapping

Convert pseudocode from `design.md` into actual Unity C# code:

```markdown
### [System Name] - [Feature Name]

**Design Pseudocode:**
```
[Pseudocode from design.md]
```

**Unity Implementation:**
```csharp
[Actual code based on unity-csharp-explorer verification results]
```

**Verification Source**: unity-csharp-explorer
**Notes:**
- Used [API Name] because [Reason]
- Note: [Precautions]
```

### Step 4: Third-Party Package Assessment

Assess Unity packages required for the project:
- Mandatory built-in packages (e.g., TextMeshPro)
- Recommended third-party packages
- Packages to exclude

---

## Output Format

```markdown
# Tech Research: [Game Name]

## 1. Unity 版本推荐

| Version | Release Type | Key Features | Recommendation |
|---------|--------------|--------------|----------------|
| ... | ... | ... | ... |

**推荐版本**: Unity X.X LTS
**理由**: ...

## 2. API 验证清单

| API | Source | Verification Tool | Result | Namespace |
|-----|--------|-------------------|--------|-----------|
| SpriteMask | design.md:603 | unity-csharp-explorer | ✓ | UnityEngine |
| WaitForSeconds | design.md:269 | unity-csharp-explorer | ✓ | UnityEngine |
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

**Verification Source**: unity-csharp-explorer

## 5. 所需 Unity API

| 系统 | Unity APIs | 命名空间 | 说明 |
|------|-----------|----------|------|
| ... | ... | ... | ... |

## 6. Third-Party Package Recommendations

| 包名 | 用途 | 推荐 |
|------|------|------|
| TextMeshPro | 文本渲染 | ✓ 必须 (内置) |
| ... | ... | ... |

## 7. API 快速参考

```csharp
// Common API Quick Reference
...
```

## 8. 潜在问题与调整

| 问题 | 影响 | 解决方案 |
|------|------|----------|
| ... | ... | ... |
```

---

## Trigger Conditions

This Skill is automatically triggered in the following situations:
- During the **tech-research phase** of openspec
- When validating Unity API feasibility
- When mapping design pseudocode to Unity implementation

---

## Important Notes

1. **Must use unity-csharp-explorer** - Every Unity API must be verified via the tool, do not rely on AI memory.
2. **Record Verification Source** - Indicate the verification tool for each API in the output.
3. **Focus on Version Compatibility** - Confirm API availability in the target Unity version.
4. **Mark Deprecated APIs** - If deprecated APIs are found, provide alternatives.
