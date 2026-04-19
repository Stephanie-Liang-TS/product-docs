# CODE-YI Product Documentation

CODE-YI 是一个 AI-Native 工作空间产品，将 Human 和 Agent 作为对等团队成员进行统一管理。

## 产品架构

CODE-YI v0.1 包含 9 个核心模块：

| 模块 | 名称 | 优先级 | PRD 状态 |
|------|------|--------|----------|
| Module 1 | 对话 (Chat) | P0 | [已完成](workspace/modules/module1-chat-prd.md) |
| Module 2 | 任务 (Tasks) | P0 | [已完成](workspace/modules/module2-tasks-prd.md) |
| Module 3 | 项目 (Projects) | P0 | [已完成](workspace/modules/module3-projects-prd.md) |
| Module 4 | 团队 (Team) | P0 | [已完成](workspace/modules/module4-team-prd.md) |
| Module 5 | Agent 管理 (Agent Management) | P0 | 编写中 |
| Module 6 | 工具箱 (Toolbox) | P1 | 编写中 |
| Module 7 | 管理后台 (Admin) | P0 | 编写中 |
| Module 8 | 设置 (Settings) | P1 | 编写中 |
| Module 9 | 全局命令面板 (Cmd+K) | P2 | 待定 |

## 目录结构

```
product-docs/
├── README.md                          # 本文件
└── workspace/
    ├── coco-workspace-prd.md          # 总产品 PRD（概览）
    ├── coco-workspace-spec.md         # 总产品 Spec v1
    ├── coco-workspace-spec-v2.md      # 总产品 Spec v2
    ├── coco-workspace-summary.md      # 产品概要
    ├── workbuddy-research.md          # WorkBuddy 竞品调研
    └── modules/
        ├── module1-chat-prd.md        # Module 1: 对话 (2111 行)
        ├── module2-tasks-prd.md       # Module 2: 任务 (2540 行)
        ├── module3-projects-prd.md    # Module 3: 项目 (2212 行)
        └── module4-team-prd.md        # Module 4: 团队 (2403 行)
```

## SSOT 工作流

- **Single Source of Truth** = 本仓库中的 Markdown 文件
- **HTML 展示层** = [zylos150.coco.site](https://zylos150.coco.site) 自动部署
- **流程**: 编辑 Markdown → 提 PR → Review/Merge → HTML 自动更新

## 核心理念

- **HxA 对等模型**: Human 和 Agent 作为同等级别的团队成员
- **统一消息总线 (UMB)**: Human↔Human、Human↔Bot、Bot↔Bot 三种对话模式均为一等公民
- **Agent-Native**: 不是在传统工具上加 AI，而是从架构层面为 AI Agent 设计
- **多模型支持**: Claude / GPT-4 / Gemini / 开源模型，按需切换

## 作者

- **产品设计**: Stephanie Liang
- **PRD 撰写**: Zylos AI Agent (by Stephanie's direction)
