---
name: game-dev-u3d-test
description: Unity 测试执行能力。负责编译检查、测试执行、结果处理。
---

# Test Unity Skill

在完成功能开发后执行 Unity 测试验证。

---

## 核心流程

```
1. 刷新并编译 → 2. 检查编译错误 → 3. 运行测试 → 4. 处理结果
```

---

## 步骤 1：刷新 Unity 并等待编译

```
[Tool: refresh_unity]
  mode: "force"
  scope: "all"
  compile: "request"
  wait_for_ready: true
```

`wait_for_ready: true` 会自动等待编译完成。
若编译一直在等待，超过60s，可以选择使用AskUserQuestion 工具进行交互确认

---

## 步骤 2：检查编译错误（关键步骤）

**编译完成后必须检查控制台日志：**

```
[Tool: read_console]
  action: "get"
  types: ["error"]
  count: 20
```

**判断逻辑：**
- 有 `error CS` 开头的编译错误 → 修复代码，回到步骤 1
- 只有 `CommandBuffer`、`render texture` 等 Unity 内部警告 → 忽略，继续
- 无错误 → 继续步骤 3
- 每次修改报错后再次进入可以先进行清除旧日志信息，再获取最新报错日志。

---

## 步骤 3：运行测试

**EditMode 测试：**
```
[Tool: run_tests]
  mode: "EditMode"
  include_failed_tests: true
```

**PlayMode 测试：**
```
[Tool: run_tests]
  mode: "PlayMode"
  include_failed_tests: true
```

**获取结果：**
```
[Tool: get_test_job]
  job_id: "<返回的 job_id>"
  wait_timeout: 60      # PlayMode 用 120
  include_failed_tests: true
```

---

## 步骤 4：处理测试结果

### 全部通过

标记任务完成，继续下一个 task。

### 存在失败

> **⚠️ 测试失败后的第一步永远是检查控制台日志！**
>
> 测试失败可能是：
> - **编译错误**：代码无法编译，测试结果是陈旧的缓存
> - **运行时错误**：代码可以编译，测试逻辑失败
>
> 如果直接基于测试结果修改代码，可能忽略真正的编译问题（如 asmdef 引用缺失）。

**修复流程：**

1. **【强制】检查控制台日志**
   - 有 `error CS` 编译错误 → 修复编译错误，回到步骤 1
   - 无编译错误 → 分析测试失败原因

2. 修改代码

3. 刷新 Unity（步骤 1）→ 检查编译（步骤 2）→ 重新测试（步骤 3）

4. 最多重试 3 次，仍失败则报告用户

---

## 测试模式选择

| 类型 | 模式 |
|------|------|
| 纯逻辑（分数、状态、对象池） | EditMode |
| 物理/协程/碰撞/UI | PlayMode |

---

## 常见问题

### 编译错误导致测试失败

**症状**：测试报告显示失败，但错误信息看起来像运行时错误

**原因**：实际是编译问题（如 asmdef 引用缺失），测试运行器用的是缓存的旧结果

**解决**：检查控制台日志，查找：
- `error CS` 开头的编译错误
- `does not contain a definition` 错误
- `The type or namespace name 'X' does not exist` 错误

**常见编译问题：**

| 问题 | 解决方案 |
|------|----------|
| asmdef 引用缺失 | 在 `EditMode.asmdef` / `PlayMode.asmdef` 的 references 中添加 GUID |
| 命名空间找不到 | 添加 using 语句或修复 asmdef |

### 测试超时

增加 `wait_timeout`：
```
[Tool: get_test_job]
  job_id: "<job_id>"
  wait_timeout: 180
```

### Unity 无响应

提示用户检查 Unity Editor 状态，等待用户响应后继续。

---

## 工具参考

| 工具 | 用途 | 关键参数 |
|------|------|----------|
| `refresh_unity` | 刷新/编译 | `wait_for_ready: true` |
| `read_console` | 检查错误 | `action: "get"`, `types: ["error"]` |
| `run_tests` | 运行测试 | `mode`, `include_failed_tests` |
| `get_test_job` | 获取结果 | `job_id`, `wait_timeout` |
