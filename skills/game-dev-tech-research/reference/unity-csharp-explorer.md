# unity-csharp-explorer 使用指南

## 概述

`unity-csharp-explorer` 是一个**自定义 Claude 代理**（Custom Agent），用于探索 Unity C# 源代码。它可以：

- 查找 Unity API 的定义和签名
- 探索 Unity 引擎源代码 (UnityCsReference)
- 查找 Unity 包的源代码 (Library/PackageCache)
- 验证 API 在特定版本中的可用性

---

## 安装方法

### 检查是否已安装

```bash
ls .claude/agents/unity-csharp-explorer.md
```

### 安装步骤

```bash
# 1. 获取最新版本号
LATEST_TAG=$(git ls-remote --tags --sort=-v:refname https://github.com/zhing2006/unity-csharp-explorer.git | head -1 | sed 's/.*refs\/tags\///')

# 2. 创建目录并下载
mkdir -p .claude/agents
curl -fsSL "https://raw.githubusercontent.com/zhing2006/unity-csharp-explorer/${LATEST_TAG}/.claude/agents/unity-csharp-explorer.md" -o .claude/agents/unity-csharp-explorer.md

# 3. 验证安装
cat .claude/agents/unity-csharp-explorer.md | head -10
```

> **重要**: 安装后需要重启 Claude Code 才能激活代理。

---

## 工作原理

unity-csharp-explorer 是一个**自动激活的自定义代理**，不是内置的 subagent_type。

### 激活条件

代理在以下情况下自动激活：
- 遇到 Unity C# 错误需要排查时
- 需要查找 Unity API 定义时
- 需要验证 API 签名或可用性时
- 需要探索 Unity 包源码时

### 搜索策略

代理遵循三层搜索策略：

1. **确保源码可用**（首要步骤）
   - 检查本地是否存在 `UnityCsReference` 目录
   - 如果不存在，根据项目的 Unity 版本从 GitHub 克隆
   - 对于包，检查 `Library/PackageCache` 是否存在

2. **识别搜索目标**
   - 引擎 API → 搜索 `UnityCsReference`
   - 包 API → 搜索 `Library/PackageCache` 和 `Packages`
   - 未知 → 先搜索引擎，再搜索包

3. **执行全局搜索**
   - 使用 Grep/Glob 工具定位代码
   - 读取上下文文件
   - 验证准确性后返回结果

---

## 使用方式

安装后，只需描述你需要验证的内容，代理会自动激活并处理。

### 1. 验证 API 存在性

```
"查找 SpriteMask 类是否存在，以及它的命名空间"
```

### 2. 查找方法签名

```
"查找 MonoBehaviour.StartCoroutine 方法的所有重载签名"
```

### 3. 查找属性定义

```
"查找 SpriteRenderer.maskInteraction 属性的类型和可用值"
```

### 4. 探索类的完整定义

```
"查找 WaitForSeconds 类的完整定义，包括构造函数和属性"
```

### 5. 查找枚举值

```
"查找 SpriteMaskInteraction 枚举的所有可用值"
```

### 6. 验证版本兼容性

```
"查找 Vector2Int 类，确认它在 Unity 2022.3 中是否可用"
```

### 7. 查找 Unity 包源码

```
"在 TextMeshPro 包中查找 TMP_Text 类的 text 属性定义"
```

---

## 查询技巧

### 精确查询

```
"查找 UnityEngine.Input.GetKeyDown(KeyCode) 方法的定义"
```

### 模糊查询

```
"查找 Unity 中用于场景加载的 API，包括 SceneManager 相关方法"
```

### 对比查询

```
"比较 PlayerPrefs.SetInt 和 PlayerPrefs.SetFloat 的用法差异"
```

---

## 输出内容

unity-csharp-explorer 会返回：

1. **API 定义** - 类/方法/属性的完整定义
2. **命名空间** - 所需的 using 语句
3. **签名** - 方法参数和返回值
4. **示例** - 使用示例（如果找到）
5. **版本信息** - API 的版本兼容性说明
6. **文件路径** - 源码所在位置

---

## 常用查询模板

### 验证 MonoBehaviour 生命周期方法

```
"查找 MonoBehaviour 的 Awake, Start, Update, OnEnable, OnDisable 方法的定义和调用顺序"
```

### 验证协程相关 API

```
"查找 StartCoroutine, StopCoroutine, WaitForSeconds, WaitForEndOfFrame 的定义和用法"
```

### 验证 2D 物理 API

```
"查找 Collider2D, Rigidbody2D, OnCollisionEnter2D, OnTriggerEnter2D 的定义"
```

### 验证 UI API

```
"查找 Canvas, Button, Image, TextMeshProUGUI 的常用属性和方法"
```

### 验证音频 API

```
"查找 AudioSource.Play, AudioSource.clip, AudioSource.volume 的定义"
```

---

## 目录结构知识

代理了解以下目录结构：

**UnityCsReference** (Unity 引擎源码):
- `Runtime/` - 运行时 API
- `Editor/` - 编辑器 API
- `Modules/` - 模块化功能
- `External/` - 外部依赖

**PackageCache** (Unity 包):
- `com.unity.*/Runtime/` - 包运行时代码
- `Editor/` - 包编辑器代码
- `Shaders/` - 着色器
- `Documentation~/` - 文档

---

## 注意事项

1. **必须先安装** - 这是自定义代理，需要手动安装到 `.claude/agents/` 目录
2. **自动激活** - 安装后无需手动调用，描述需求即可自动激活
3. **记录验证结果** - 在 tech-research.md 中记录每个 API 的验证来源
4. **检查命名空间** - 确保记录正确的 using 语句
5. **关注废弃警告** - 如果 API 被标记为废弃，寻找替代方案
6. **版本敏感** - 某些 API 可能在特定版本才可用

---

## 故障排除

### 代理未激活

1. 检查 `.claude/agents/unity-csharp-explorer.md` 是否存在
2. 确认已重启 Claude Code
3. 确认文件内容完整（不是空文件）

### UnityCsReference 克隆失败

1. 检查网络连接
2. 确认 `ProjectSettings/ProjectVersion.txt` 存在且版本号正确
3. 手动克隆对应版本的 UnityCsReference

### 找不到包源码

1. 确认包已安装（存在于 `Library/PackageCache`）
2. 检查包名拼写是否正确

---

## 批量验证示例

当需要验证多个 API 时，可以分组查询：

```
# 第一组：核心类
"查找 MonoBehaviour, ScriptableObject, GameObject 的基本定义和常用方法"

# 第二组：渲染相关
"查找 SpriteRenderer, SpriteMask, SortingLayer 的定义和用法"

# 第三组：输入相关
"查找 Input.GetKeyDown, Input.GetKey, KeyCode 的定义"
```
