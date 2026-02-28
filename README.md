# Game Dev OpenSpec

Unity 游戏开发工作流 Skills，基于 OpenSpec 构建。

## 前置要求

1. **Claude Code** - 已安装并配置
2. **OpenSpec** - 在项目中已初始化
3. **UnityMCP** - Unity Editor MCP 集成（测试/调试必需）

```bash
# 安装 OpenSpec CLI (如未安装)
npm install -g @anthropics/openspec

# 在项目中初始化 OpenSpec
cd your-project
openspec init
```

### UnityMCP 安装

UnityMCP 用于 Unity Editor 集成，支持脚本管理、编译检查、测试执行等功能。

**Unity Package Manager 安装：**
```
https://github.com/AcrylicShrimp/unity-mcp.git
```

在 Unity 中：Window > Package Manager > Add package from git URL > 粘贴上述地址

## 安装

```powershell
# 进入项目目录后执行
irm https://raw.githubusercontent.com/ganlingyao/game-dev-openspec/main/run.ps1 | iex
```

安装内容包括：
- **Skills** - Claude Code 技能文件
- **Agents** - unity-csharp-explorer（用于 Unity API 源码验证）
- **Schemas** - game-dev-workflow 工作流定义
- **CLAUDE.md** - 项目配置模板

> **注意**：安装完成后需要重启 Claude Code 以激活 agents。

## 更新

```powershell
# 进入项目目录后执行
iex "& { $(irm https://raw.githubusercontent.com/ganlingyao/game-dev-openspec/main/run.ps1) } -Action update"
```

## 包含的 Skills

| Skill | 用途 | 触发方式 |
|-------|------|----------|
| `game-dev-u3d-debug` | Unity 问题诊断与修复 | 问题描述 + 修复请求 |
| `game-dev-u3d-code` | Unity 编码规范与实现 | 实现、编码、开发 |
| `game-dev-u3d-design` | Unity 架构设计 | 设计、架构 |
| `game-dev-u3d-test` | Unity 测试执行 | 运行测试、执行测试 |
| `game-dev-research` | 游戏市场调研 | 调研、分析 |
| `game-dev-tech-research` | Unity API 技术调研 | API 研究、可行性验证 |
| `win-screenshot` | Windows 窗口截图 | 截图请求 |

## 包含的 Agents

| Agent | 用途 | 来源 |
|-------|------|------|
| `unity-csharp-explorer` | Unity C# 源码搜索与 API 验证 | [zhing2006/unity-csharp-explorer](https://github.com/zhing2006/unity-csharp-explorer) |

## 使用示例

```
# 调试问题
用户: "UI按钮点击无效，请修复"
→ 自动触发 game-dev-u3d-debug

# 实现功能
用户: "实现一个血条系统"
→ 自动触发 game-dev-u3d-code

# 设计架构
用户: "设计战斗系统模块"
→ 自动触发 game-dev-u3d-design

# 技术调研（使用 unity-csharp-explorer）
用户: "验证 SpriteMask API 是否支持..."
→ 自动触发 game-dev-tech-research
```

## 目录结构

```
game-dev-openspec/
├── README.md
├── install.ps1          # 安装脚本（含 agents 安装）
├── update.ps1           # 更新脚本（含 agents 更新）
├── run.ps1              # 远程安装脚本
├── CLAUDE.md.template   # Claude Code 项目指令模板
├── skills/              # Claude Code Skills
│   ├── game-dev-u3d-debug/
│   ├── game-dev-u3d-code/
│   ├── game-dev-u3d-design/
│   ├── game-dev-u3d-test/
│   ├── game-dev-research/
│   ├── game-dev-tech-research/
│   └── win-screenshot/
└── schemas/             # OpenSpec Workflow Schemas
    └── game-dev-workflow/
        ├── schema.yaml      # 工作流定义
        └── templates/       # Artifact 模板
            ├── proposal.md
            ├── research.md
            ├── design.md
            ├── tech-research.md
            ├── spec.md
            └── tasks.md
```

## Schemas 说明

`game-dev-workflow` schema 定义了游戏开发的工作流阶段：

| 阶段 | Artifact | 用途 |
|------|----------|------|
| research | research.md | 游戏市场调研 |
| proposal | proposal.md | 功能提案 |
| design | design.md | 架构设计 |
| tech-research | tech-research.md | 技术可行性验证（使用 unity-csharp-explorer） |
| spec | spec.md | 详细规格 |
| tasks | tasks.md | 实现任务列表 |

## unity-csharp-explorer Agent

`game-dev-tech-research` skill 依赖 `unity-csharp-explorer` agent 进行 Unity API 源码级验证。

**功能**：
- 搜索 Unity C# 源码（UnityCsReference）
- 验证 API 存在性、签名、命名空间
- 检查 [Obsolete] 标记
- 支持特定 Unity 版本验证

**安装方式**：
- 自动：运行 `install.ps1` 时自动下载
- 手动：skill 执行时检测缺失并提示安装

## 许可证

内部使用
