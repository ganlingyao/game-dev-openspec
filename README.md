# Game Dev OpenSpec

Unity 游戏开发工作流 Skills，基于 OpenSpec 构建。

## 前置要求

1. **Claude Code** - 已安装并配置
2. **OpenSpec** - 在项目中已初始化

```bash
# 安装 OpenSpec CLI (如未安装)
npm install -g @fission-ai/openspec

# 在项目中初始化 OpenSpec
cd your-project
openspec init
```

## 安装

```powershell
# 进入项目目录后执行
irm https://raw.githubusercontent.com/ganlingyao/game-dev-openspec/main/run.ps1 | iex
```

## 更新

```powershell
# 进入项目目录后执行
iex "& { $(irm https://raw.githubusercontent.com/ganlingyao/game-dev-openspec/main/run.ps1) } -Action update"
```

## 包含的 Skills

| Skill | 用途 | 触发方式 |
|-------|------|----------|
| `game-dev-debug-unity` | Unity 问题诊断与修复 | 问题描述 + 修复请求 |
| `game-dev-code-unity` | Unity 编码规范与实现 | 实现、编码、开发 |
| `game-dev-design-unity` | Unity 架构设计 | 设计、架构 |
| `game-dev-research-game` | 游戏市场调研 | 调研、分析 |
| `tech-research-unity` | Unity API 技术调研 | API 研究、可行性 |
| `test-unity` | Unity 测试执行 | 运行测试、执行测试 |
| `win-screenshot` | Windows 窗口截图 | 截图请求 |

## 使用示例

```
# 调试问题
用户: "UI按钮点击无效，请修复"
→ 自动触发 game-dev-debug-unity

# 实现功能
用户: "实现一个血条系统"
→ 自动触发 game-dev-code-unity

# 设计架构
用户: "设计战斗系统模块"
→ 自动触发 game-dev-design-unity
```

## 目录结构

```
game-dev-openspec/
├── README.md
├── install.ps1          # 安装脚本
├── update.ps1           # 更新脚本
├── run.ps1              # 远程安装脚本
├── CLAUDE.md.template   # Claude Code 项目指令模板
├── skills/              # Claude Code Skills
│   ├── game-dev-debug-unity/
│   ├── game-dev-code-unity/
│   ├── game-dev-design-unity/
│   ├── game-dev-research-game/
│   ├── tech-research-unity/
│   ├── test-unity/
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
| tech-research | tech-research.md | 技术可行性验证 |
| spec | spec.md | 详细规格 |
| tasks | tasks.md | 实现任务列表 |

## 许可证

内部使用
