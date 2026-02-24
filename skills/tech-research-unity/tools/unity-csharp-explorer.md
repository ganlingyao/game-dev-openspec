# unity-csharp-explorer 工具使用指南

## 概述

`unity-csharp-explorer` 是一个专门用于探索 Unity C# 源代码的 Task Agent。它可以：

- 查找 Unity API 的定义和签名
- 探索 Unity 引擎源代码
- 查找 Unity 包的源代码
- 验证 API 在特定版本中的可用性

---

## 调用方式

使用 `Task` 工具调用：

```
Task 工具参数:
  subagent_type: unity-csharp-explorer
  prompt: <详细的查询描述>
  description: <简短描述 3-5 词>
```

---

## 使用场景

### 1. 验证 API 存在性

```
prompt: "查找 SpriteMask 类是否存在，以及它的命名空间"
description: "Verify SpriteMask exists"
```

### 2. 查找方法签名

```
prompt: "查找 MonoBehaviour.StartCoroutine 方法的所有重载签名"
description: "Find StartCoroutine signatures"
```

### 3. 查找属性定义

```
prompt: "查找 SpriteRenderer.maskInteraction 属性的类型和可用值"
description: "Find maskInteraction property"
```

### 4. 探索类的完整定义

```
prompt: "查找 WaitForSeconds 类的完整定义，包括构造函数和属性"
description: "Explore WaitForSeconds class"
```

### 5. 查找枚举值

```
prompt: "查找 SpriteMaskInteraction 枚举的所有可用值"
description: "Find SpriteMaskInteraction enum"
```

### 6. 验证版本兼容性

```
prompt: "查找 Vector2Int 类，确认它在 Unity 2022.3 中是否可用"
description: "Verify Vector2Int compatibility"
```

### 7. 查找 Unity 包源码

```
prompt: "在 TextMeshPro 包中查找 TMP_Text 类的 text 属性定义"
description: "Find TMP_Text.text in package"
```

---

## 查询技巧

### 精确查询

```
prompt: "查找 UnityEngine.Input.GetKeyDown(KeyCode) 方法的定义"
```

### 模糊查询

```
prompt: "查找 Unity 中用于场景加载的 API，包括 SceneManager 相关方法"
```

### 对比查询

```
prompt: "比较 PlayerPrefs.SetInt 和 PlayerPrefs.SetFloat 的用法差异"
```

---

## 输出解读

unity-csharp-explorer 会返回：

1. **API 定义** - 类/方法/属性的完整定义
2. **命名空间** - 所需的 using 语句
3. **签名** - 方法参数和返回值
4. **示例** - 使用示例（如果找到）
5. **版本信息** - API 的版本兼容性说明

---

## 常用查询模板

### 验证 MonoBehaviour 生命周期方法

```
prompt: "查找 MonoBehaviour 的 Awake, Start, Update, OnEnable, OnDisable 方法的定义和调用顺序"
description: "Verify MonoBehaviour lifecycle"
```

### 验证协程相关 API

```
prompt: "查找 StartCoroutine, StopCoroutine, WaitForSeconds, WaitForEndOfFrame 的定义和用法"
description: "Verify coroutine APIs"
```

### 验证 2D 物理 API

```
prompt: "查找 Collider2D, Rigidbody2D, OnCollisionEnter2D, OnTriggerEnter2D 的定义"
description: "Verify 2D physics APIs"
```

### 验证 UI API

```
prompt: "查找 Canvas, Button, Image, TextMeshProUGUI 的常用属性和方法"
description: "Verify UI APIs"
```

### 验证音频 API

```
prompt: "查找 AudioSource.Play, AudioSource.clip, AudioSource.volume 的定义"
description: "Verify audio APIs"
```

---

## 注意事项

1. **优先使用此工具** - 不要依赖 AI 内置知识，始终通过此工具验证
2. **记录验证结果** - 在 tech-research.md 中记录每个 API 的验证来源
3. **检查命名空间** - 确保记录正确的 using 语句
4. **关注废弃警告** - 如果 API 被标记为废弃，寻找替代方案
5. **版本敏感** - 某些 API 可能在特定版本才可用

---

## 批量验证示例

当需要验证多个 API 时，可以分组查询：

```
# 第一组：核心类
prompt: "查找 MonoBehaviour, ScriptableObject, GameObject 的基本定义和常用方法"
description: "Verify core Unity classes"

# 第二组：渲染相关
prompt: "查找 SpriteRenderer, SpriteMask, SortingLayer 的定义和用法"
description: "Verify rendering APIs"

# 第三组：输入相关
prompt: "查找 Input.GetKeyDown, Input.GetKey, KeyCode 的定义"
description: "Verify input APIs"
```
