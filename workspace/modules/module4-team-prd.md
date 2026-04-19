# CODE-YI Module 4: 团队 (Team) — 产品需求文档

> **版本:** v1.0  
> **日期:** 2026-04-20  
> **作者:** Zylos AI Agent (by Stephanie's direction)  
> **状态:** Draft  

---

## 目录

1. [问题陈述](#1-问题陈述)
2. [产品愿景](#2-产品愿景)
3. [竞品对标](#3-竞品对标)
4. [技术突破点分析](#4-技术突破点分析)
5. [用户故事](#5-用户故事)
6. [功能拆分](#6-功能拆分)
7. [HxA 协作模型](#7-hxa-协作模型)
8. [Agent 角色权限引擎](#8-agent-角色权限引擎)
9. [数据模型](#9-数据模型)
10. [技术方案](#10-技术方案)
11. [模块集成](#11-模块集成)
12. [测试用例](#12-测试用例)
13. [成功指标](#13-成功指标)
14. [风险与缓解](#14-风险与缓解)
15. [排期建议](#15-排期建议)

---

## 1. 问题陈述

### 1.1 现有团队管理工具的结构性缺陷

当前主流团队协作工具（Slack、Microsoft Teams、Jira、Linear、Asana、ClickUp）在"团队"这一基本组织单元上，均基于一个根深蒂固的假设：**团队成员全部是人类，AI 仅作为第三方集成或辅助工具存在**。当 AI Agent 成为团队中实际承担任务的"工作者"时，这些工具的团队模型立刻暴露出根本性不足：

**Slack 的致命限制：**
- **Bot 是二等公民**：Slack 的 Workspace Members 列表只显示人类用户。Bot/App 被隐藏在"Apps"侧边栏中，不出现在团队成员列表、@提及自动补全的"成员"分类中。用户无法一眼看到"我的团队里有哪些 Agent 在工作"
- **Bot 没有角色系统**：Slack 的 Workspace Roles（Owner / Admin / Member / Guest）只适用于人类用户。Bot 只有一个笼统的"App"身份，无法区分"执行 Agent"、"审核 Agent"、"协调 Agent"的角色差异
- **没有协作拓扑概念**：Slack 可以看到频道成员列表，但无法可视化"谁和谁在协作"、"Agent A 向 Agent B 交付产出"这样的关系图谱
- **Agent 状态不可见**：Slack 的在线/离线状态只适用于人类。Bot 始终显示为"App"图标，用户无法知道某个 Agent 当前是在线运行、离线维护还是异常中断
- **多团队组织能力弱**：Slack 的 Channels 可以模拟团队分组，但 Channel 的设计初衷是"话题"而非"团队"。一个 Workspace 内无法原生创建"产品开发团队"、"运营团队"这样的组织结构

**Microsoft Teams 的致命限制：**
- **Copilot 不是团队成员**：Microsoft 365 Copilot 虽然深度集成到 Teams 中，但它是一个全局助手，不是某个团队的"成员"。你无法把 Copilot 加入"产品开发团队"并给它分配"代码审查"的角色
- **Bot Framework 的成员模型**：Teams Bot Framework 允许创建 Bot，但 Bot 在团队中的身份是"App"而非"成员"。Bot 无法被赋予 Owner / Member / Guest 等团队角色
- **没有 Agent 角色分化**：Teams 的权限模型不支持为不同 Bot 设置不同权限——所有 Bot 共享同一个"App 权限"层级
- **缺乏 HxA 可视化**：Teams 可以查看"团队成员"列表，但无法可视化人与 Agent 之间的协作关系

**GitHub 的致命限制：**
- **Copilot 不是 Team Member**：GitHub Copilot（包括 Coding Agent）可以为 Issue 创建 PR，但它不是任何 GitHub Team 的"成员"。你无法在 GitHub Organization 的 Team 管理中看到 Copilot
- **GitHub Teams 只管人类**：GitHub Teams 的核心功能是管理人类开发者的代码仓库访问权限。Bot 通过 GitHub Apps 机制访问仓库，与 Team 权限体系完全独立
- **没有协作拓扑**：GitHub 的 Contribution Graph 展示个人代码贡献，但不展示团队成员之间的协作关系（如"谁 Review 了谁的 PR"、"Agent A 的产出由谁审核"）
- **Bot 角色固定**：GitHub App 的权限是安装时一次性配置的（read/write 仓库、管理 Issue 等），无法在团队层面动态调整 Bot 的角色

**Linear / Asana / ClickUp 的共同问题：**
- 团队成员列表只支持人类用户
- 没有 Agent 成员概念——AI 功能（Linear AI、Asana Intelligence、ClickUp Brain）是全局功能，不绑定到具体团队
- 没有 Agent 角色系统——无法区分不同 Agent 的职责和权限
- 没有协作关系可视化——只能看到"谁被 assigned 了什么任务"，无法看到协作拓扑
- 团队管理停留在"人员名单 + 权限"层级，缺乏"角色化分工 + 协作关系"的深度模型

**Jira 的致命限制：**
- **Project Roles 只针对人类**：Jira 的 Project Roles（Administrator / Developer / Viewer）只能分配给人类用户。Automation Rules 和 Bot 没有对应的"角色"概念
- **Atlassian Intelligence 是工具而非成员**：Atlassian Intelligence 提供 AI 辅助（自然语言搜索、Issue 摘要），但它不是 Jira 项目中的"团队成员"
- **团队管理与权限割裂**：Jira 的"Team"概念（Jira Work Management 中）和权限系统（Project Permissions Scheme）是两套独立机制，配置复杂且无法统一管理

### 1.2 核心洞察

所有现有工具的团队模型可以用一句话概括：**"团队 = 一群人类 + 一些可选的 AI 辅助工具"**。但 AI-Native 时代的团队模型应该是：**"团队 = 人类成员 + Agent 成员，每个成员（无论人类还是 Agent）都有明确的角色、职责和协作关系"**。

```
现状（人类中心模型）：
  团队管理工具（Slack/Teams/Jira）
  - 成员列表：只有人类
  - Bot/AI：隐藏在"集成"或"应用"中
  - 角色系统：Owner/Admin/Member/Guest（只适用于人类）
  - 协作关系：不可见
  
  ↓ 问题：Agent 在团队中没有"存在感"，管理者无法一眼掌握 HxA 协作全貌

CODE-YI 模型（HxA 对等模型）：
  团队 = 人类 + Agent（统一管理）
  - 成员列表：人类和 Agent 并列显示
  - 角色系统：人类角色（管理员/成员/审核者）+ Agent 角色（执行者/审核者/协调者/观察者）
  - 协作拓扑：可视化人与 Agent 之间的关系
  - 状态监控：实时显示所有成员（含 Agent）的在线/离线状态
```

### 1.3 市场机会

- 2025-2026 年，超过 60% 的软件开发团队正在引入至少一个 AI Agent 参与日常工作流（GitHub Copilot、Cursor Agent、Devin、Codex 等），但**没有一个团队管理工具**能让管理者一眼看到"我的团队中有哪些 Agent、它们分别承担什么角色、和人类成员之间如何协作"
- Gartner 2025 报告指出，"AI Agent Governance"将成为企业 IT 治理的新维度——谁部署了哪些 Agent、这些 Agent 有什么权限、它们在做什么。但现有工具没有提供 Agent 治理的团队级视图
- 多 Agent 协同的兴起（CrewAI、AutoGen、LangGraph）催生了"Agent 编排"需求，但这些框架停留在代码层面。**没有一个产品**在 UI 层面提供 Agent 团队管理和协作可视化
- 这是 CODE-YI 的差异化窗口：一个**把人类和 Agent 作为对等成员统一管理、以角色化分工和协作拓扑图为核心的团队管理模块**

---

## 2. 产品愿景

### 2.1 一句话定位

**CODE-YI 团队模块是全球首个将人类成员和 AI Agent 作为对等团队成员统一管理、以四种 Agent 角色（执行者/审核者/协调者/观察者）实现角色化分工、以 HxA 协作拓扑图可视化人与 Agent 协作关系的 AI-Native 团队管理系统。**

### 2.2 核心价值主张

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        CODE-YI 团队系统                                   │
├──────────────────┬──────────────────────┬────────────────────────────────┤
│ 统一成员管理       │ Agent 角色化分工       │ HxA 协作拓扑                    │
│                  │                      │                                │
│ 人类 + Agent 并列 │ 执行者：接任务、做交付  │ 可视化人↔Agent 协作关系          │
│ 成员卡片统一展示   │ 审核者：Review 产出    │ 委派、交接、上报路径一目了然       │
│ 邀请/添加/移除    │ 协调者：拆需求、分任务  │ 实时更新协作活跃度               │
│ 在线/离线状态     │ 观察者：监控、生成报告  │ 交互式拓扑图                    │
│ 多团队组织       │ 跨模块权限矩阵        │ 协作频次热力图                   │
└──────────────────┴──────────────────────┴────────────────────────────────┘
```

### 2.3 核心差异化

| 维度 | Slack Workspace | Microsoft Teams | GitHub Teams | Jira Project Roles | **CODE-YI Teams** |
|------|----------------|-----------------|--------------|--------------------|--------------------|
| Agent 作为团队成员 | 不支持（隐藏在 Apps） | 不支持（全局 Copilot） | 不支持 | 不支持 | **原生支持，与人类并列** |
| Agent 角色系统 | 无 | 无 | 无 | 无 | **4 种专用角色 + 权限矩阵** |
| 协作拓扑可视化 | 无 | 无 | Contribution Graph | 无 | **HxA 交互式拓扑图** |
| Agent 状态监控 | App 图标不变 | 不显示 | 不显示 | 不显示 | **实时在线/离线/异常** |
| 多团队管理 | Channel 模拟 | Teams/Channels | Teams | 项目级 | **原生多团队 + 一个 Workspace** |
| 成员卡片 | 简单头像+名字 | 简单头像+名字 | 头像+贡献 | 头像+角色 | **头像+角色+状态+协作统计** |

### 2.4 设计理念

**"Team as an Organism"** ——团队是一个有机体，人类和 Agent 是其中的器官，各有分工、相互协作。

Stephanie 的设计稿（Screen 4）完美体现了这一理念：页面上半部分是"人类成员"和"Agent 成员"的卡片网格——每张卡片不仅展示身份信息，还显示角色标签和状态指示器；页面下半部分是"HxA 协作关系"拓扑图——用节点和连线展示谁在和谁协作、协作频次如何。管理者打开一个团队页面，就能全局掌控团队的 HxA 组成和协作拓扑——不需要翻看多个工具、多个页面。

---

## 3. 竞品对标

### 3.1 团队级 AI 成员管理能力对比

| 功能 | Slack | Microsoft Teams | GitHub | Linear | Asana | ClickUp | Jira | **CODE-YI** |
|------|-------|-----------------|--------|--------|-------|---------|------|-------------|
| Agent 作为团队成员 | - | - | - | - | - | - | - | **原生支持** |
| Agent 角色系统 | - | - | - | - | - | - | - | **4 种角色** |
| 人类角色管理 | ★★★★ | ★★★★ | ★★★ | ★★★ | ★★★★ | ★★★ | ★★★★ | ★★★★ |
| 成员卡片展示 | ★★★ | ★★★ | ★★ | ★★ | ★★★ | ★★ | ★★ | ★★★★★ |
| 在线/离线状态 | ★★★★ | ★★★★ | - | - | - | - | - | ★★★★★（含 Agent） |
| 协作拓扑可视化 | - | - | ★ | - | - | - | - | ★★★★★ |
| 多团队管理 | ★★★ | ★★★★ | ★★★★ | ★★ | ★★★ | ★★★ | ★★★ | ★★★★ |
| 邀请机制 | ★★★★★ | ★★★★ | ★★★★ | ★★★ | ★★★★ | ★★★ | ★★★ | ★★★★ |

### 3.2 深度分析

**Slack：**
- 优势：Workspace 级成员管理成熟，邀请流程顺畅（邮件/链接），支持 Guest 账户（外部协作）
- 劣势：Bot 完全独立于成员体系。2025 年推出的 Agent Orchestration 仍是"Slackbot 中转路由"模式，Agent 不是 Workspace 的一等成员
- 核心缺失：无法回答"我的团队里有几个 Agent 在工作，它们各自负责什么"

**Microsoft Teams：**
- 优势：与 Azure AD 深度集成，支持组织层级的权限管理。Teams 和 Channels 的双层组织结构灵活
- 劣势：Copilot 是租户级别的全局助手，不属于任何具体 Team。Bot Framework 创建的 Bot 在 Team 成员列表中不可见
- 核心缺失：无法在"产品开发团队"这个粒度管理 Agent 的角色和权限

**GitHub：**
- 优势：Organization Teams 的代码仓库权限管理非常精细（admin/write/read/triage）。GitHub App 的权限控制粒度到仓库级别
- 劣势：Teams 只管理人类成员的仓库权限。Copilot Coding Agent 的"团队归属"概念不存在——它只是一个全局可用的功能
- 核心缺失：无法将"代码 Agent"和"测试 Agent"分配到不同团队并赋予不同角色

**Linear / Asana / ClickUp：**
- 共同劣势：团队成员管理仅覆盖人类用户。AI 功能（Linear AI、Asana Intelligence、ClickUp Brain）是平台级功能而非团队级成员
- 核心缺失：团队中完全看不到 AI 的存在。管理者只能通过查看任务的 Activity Log 间接了解 AI 做了什么

**Jira：**
- 优势：Project Roles + Permission Schemes 的组合提供了企业级权限粒度
- 劣势：这套权限体系只针对人类用户设计。Atlassian Intelligence 是 Cloud 平台级功能，不绑定到 Project 或 Team
- 核心缺失：没有"Agent 角色"概念。无法在一个 Jira Project 中定义"代码 Agent 是执行者，Review Agent 是审核者"

### 3.3 竞品演进方向判断

| 竞品 | 可能的演进方向 | CODE-YI 的时间窗口 |
|------|--------------|-------------------|
| Slack | Agent Orchestration 可能演进为"Agent 可被添加到 Channel 成员列表" | 12-18 个月——Slack 的产品决策周期长 |
| Microsoft Teams | Copilot 可能演进为可在特定 Team 内定制的角色化 Agent | 18-24 个月——依赖 Microsoft 的 AI 战略优先级 |
| GitHub | Copilot Coding Agent 可能演进为可分配到 Team 的成员 | 12-18 个月——GitHub 已在 Copilot Workspace 中探索 |
| Linear | 可能引入 "AI Team Member" 概念 | 6-12 个月——Linear 的产品迭代速度快 |

**结论：** CODE-YI 有 6-12 个月的差异化窗口。如果在这个窗口内建立"Agent 作为团队一等成员 + 角色化管理 + 协作拓扑"的产品认知，就能占据 AI-Native 团队管理的定义权。

---

## 4. 技术突破点分析

### 4.1 多态成员模型 (Polymorphic Member Model)

**传统模型：**
```
Team Members = [Human_1, Human_2, Human_3]
Bot Integration = [Bot_A, Bot_B]  // 独立管理，不在成员列表中
```

**CODE-YI 模型：**
```
Team Members = [
  { type: "human", id: "user_alice", role: "admin" },
  { type: "human", id: "user_bob", role: "member" },
  { type: "agent", id: "agent_codebot", role: "executor" },
  { type: "agent", id: "agent_reviewer", role: "reviewer" }
]
```

**核心突破：** 人类和 Agent 共享同一个成员接口（`TeamMember`），但通过 `member_type` 字段区分。前端的成员卡片组件通过同一个 `MemberCard` 组件渲染，但根据类型展示不同信息（人类显示部门/职位，Agent 显示模型/能力标签）。

**技术关键点：**
- 数据库层：`team_members` 表使用 `member_type` + `member_id` 的组合，`member_id` 可以指向 `users` 表或 `agents` 表（Module 5）
- API 层：成员列表 API 统一返回 `TeamMember[]`，每个元素包含 `type` 字段。客户端无需调用两个不同的 API
- 前端层：`MemberCard` 组件接受统一的 `TeamMember` 数据，根据 `type` 动态渲染不同的内容区域

### 4.2 Agent 四角色 RBAC (Role-Based Access Control)

**传统 RBAC：**
```
Roles: [Owner, Admin, Member, Guest]
Permissions: [read, write, admin, delete]
Subjects: [Human Users]
```

**CODE-YI Agent RBAC：**
```
Human Roles: [管理员, 成员, 审核者]
Agent Roles: [执行者, 审核者, 协调者, 观察者]

每个 Agent 角色 → 一组操作权限（跨 Module 1-6）
权限由角色自动决定，无需逐个配置
```

**核心突破：** 传统 RBAC 的"角色"只是权限分组的便利机制。CODE-YI 的 Agent 角色不仅是权限分组，更是**行为模式的声明**——告诉系统"这个 Agent 在团队中扮演什么角色"，从而驱动任务分配、消息路由、审批流程等自动化行为。

### 4.3 HxA 协作拓扑图

**核心突破：** 将团队中人类与 Agent 之间隐含的协作关系显式化为一个可视化的有向图。

```
图的构成：
  节点 = 团队成员（人类或 Agent）
  边   = 协作关系（委派、交接、审核、上报）
  边权 = 协作频次（过去 N 天的交互次数）
  
数据来源（自动生成，非手动维护）：
  - Module 2 任务分配记录：人 → Agent 分配任务 = "委派"边
  - Module 2 任务交接记录：Agent A 提交 → Agent B Review = "交接"边  
  - Module 1 对话 @提及记录：人 @Agent 或 Agent @人 = "沟通"边
  - Module 3 项目协作记录：同一个项目中协同的成员 = "协作"边
```

**技术关键点：**
- 拓扑数据实时从已有交互记录中聚合（不需要用户手动维护关系）
- 前端使用 D3.js force-directed graph 渲染，支持缩放、拖拽、高亮路径
- 边的粗细反映协作频次，节点大小反映活跃度

### 4.4 实时 Agent 状态监控

**传统在线状态：** 人类用户 → 在线/离线/忙碌/离开（基于客户端心跳）

**CODE-YI Agent 状态：**
```
Agent 状态机：
  online   → Agent 进程运行中，可接受任务
  busy     → Agent 正在执行任务
  offline  → Agent 进程未运行
  error    → Agent 进程异常（OOM、API 超时等）
  updating → Agent 正在更新模型/配置
```

**核心突破：** Agent 的"在线状态"不是简单的心跳检测，而是一个多维度的健康指标。`online` 不仅意味着进程在运行，还意味着 Agent 的 API 密钥有效、模型可用、内存充足。`error` 状态会附带错误类型和持续时间，帮助管理者快速诊断问题。

---

## 5. 用户故事

### 5.1 人类成员管理

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-TM-01 | 团队管理员 | 作为团队管理员，我想通过邮件邀请新成员加入团队，以便快速扩充人力 | 输入邮箱后发送邀请邮件，邮件内含一键加入链接，点击后直接加入团队 | P0 |
| US-TM-02 | 团队管理员 | 作为团队管理员，我想生成邀请链接分享到群聊，以便批量邀请同事 | 生成带有效期（7天/30天/永久）的邀请链接，链接可设置使用次数上限 | P0 |
| US-TM-03 | 团队管理员 | 作为团队管理员，我想设置成员角色（管理员/成员/审核者），以便明确分工 | 角色下拉选择，变更即时生效，权限实时更新 | P0 |
| US-TM-04 | 团队管理员 | 作为团队管理员，我想移除不再参与的成员，以便保持团队清洁 | 移除时提示该成员是否有未完成任务，可选择重新分配或保留 | P0 |
| US-TM-05 | 新成员 | 作为新成员，我想通过邀请链接一键加入团队，不需要复杂审批 | 点击链接 → 登录/注册 → 自动加入团队并跳转到团队页面 | P0 |

### 5.2 Agent 成员管理

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-TM-06 | 团队管理员 | 作为管理员，我想从 Agent 市场选择一个 Agent 添加到团队，以便扩充团队能力 | 浏览市场 → 选择 Agent → 设置角色 → 添加成功，Agent 出现在成员列表 | P0 |
| US-TM-07 | 团队管理员 | 作为管理员，我想为 Agent 设置角色（执行者/审核者/协调者/观察者），以便明确其职责 | 角色下拉选择 + 角色说明提示，变更即时生效 | P0 |
| US-TM-08 | 团队管理员 | 作为管理员，我想创建自定义 Agent 并添加到团队，以便使用私有模型 | 填写 Agent 配置（名称、模型、能力标签）→ 创建成功 → 添加到团队 | P1 |
| US-TM-09 | 团队管理员 | 作为管理员，我想移除团队中的 Agent，以便替换为更好的 Agent | 移除时提示该 Agent 是否有正在执行的任务，可选择等待完成或强制移除 | P0 |
| US-TM-10 | 团队成员 | 作为成员，我想查看 Agent 的能力描述和模型信息，以便了解如何协作 | Agent 卡片展示：名称、模型、能力标签、角色、状态、最近活跃时间 | P0 |

### 5.3 成员卡片展示

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-TM-11 | 团队成员 | 作为成员，我想在团队页面一眼看到所有人类和 Agent 成员的卡片，以便了解团队组成 | 成员卡片按类型分组显示（人类成员区域 + Agent 成员区域），每张卡片显示头像/名称/角色/状态 | P0 |
| US-TM-12 | 团队成员 | 作为成员，我想通过状态指示器区分谁在线谁离线，以便知道找谁能即时响应 | 在线绿色点、离线灰色点、Agent 额外有"busy/error"状态颜色 | P0 |
| US-TM-13 | 团队成员 | 作为成员，我想点击成员卡片查看详细信息，以便了解其角色、任务、协作历史 | 点击卡片展开详情面板：角色描述、分配的任务数、完成数、最近协作记录 | P1 |

### 5.4 HxA 协作拓扑图

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-TM-14 | 团队管理员 | 作为管理员，我想看到团队内人与 Agent 的协作拓扑图，以便掌握协作全貌 | 力导向图展示所有成员节点和协作边，边的粗细反映交互频次 | P1 |
| US-TM-15 | 团队管理员 | 作为管理员，我想通过拓扑图发现协作瓶颈，以便优化团队分工 | 高亮"孤立节点"（无协作关系的成员）和"过载节点"（协作边过多的成员） | P1 |
| US-TM-16 | 团队成员 | 作为成员，我想在拓扑图中点击一个节点高亮其协作路径，以便了解某人/Agent 的协作网络 | 点击节点 → 高亮所有相连的边和节点 → 展示协作统计（任务数、消息数） | P1 |
| US-TM-17 | 团队管理员 | 作为管理员，我想筛选拓扑图的时间范围（7天/30天/全部），以便分析不同时段的协作变化 | 时间范围选择器 → 拓扑图根据选定时段的数据重新渲染 | P1 |

### 5.5 多团队管理

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-TM-18 | Workspace 管理员 | 作为管理员，我想在一个 Workspace 中创建多个团队（如"产品开发"、"运营"），以便组织化管理 | 点击"新建团队" → 填写名称/描述 → 创建成功，出现在团队列表 | P2 |
| US-TM-19 | Workspace 管理员 | 作为管理员，我想让同一个人/Agent 加入多个团队，以便支持跨团队协作 | 添加成员时可选择已在 Workspace 中的成员，同一成员可在不同团队有不同角色 | P2 |
| US-TM-20 | 团队成员 | 作为成员，我想在团队列表中切换不同团队，以便查看各团队的成员和拓扑 | 左侧团队列表 → 点击切换 → 右侧展示对应团队的成员和拓扑 | P2 |
| US-TM-21 | Workspace 管理员 | 作为管理员，我想将团队与项目（Module 3）关联，以便项目成员自动同步 | 创建项目时选择关联团队 → 项目成员自动从团队成员同步 | P2 |

---

## 6. 功能拆分

### 6.1 P0 功能（MVP，必须实现）

#### 6.1.1 人类成员管理

**邀请加入：**
- 邮件邀请：输入邮箱 → 发送带邀请链接的邮件 → 收件人点击链接加入
- 链接邀请：生成邀请链接（可设有效期和使用次数） → 分享到群聊/其他渠道 → 点击链接加入
- 邀请列表：显示已发出但未接受的邀请，支持撤销和重新发送

**角色设置：**
- 支持三种人类角色：管理员 / 成员 / 审核者
- 管理员：完全管理权限（邀请/移除成员、设置角色、管理 Agent、删除团队）
- 成员：基础使用权限（查看成员、参与任务、@提及）
- 审核者：成员权限 + 审批权限（审核 Agent 产出、批准任务完成）

**移除成员：**
- 移除前检查是否有未完成任务
- 如有未完成任务，提示"该成员还有 N 个未完成任务"并提供重新分配选项
- 移除后该成员不再出现在团队成员列表，但历史协作记录保留

#### 6.1.2 Agent 成员管理

**添加 Agent：**
- 从 Agent 市场（Module 5）浏览和选择
- 搜索和筛选（按能力、模型、角色类型）
- 选择后设置 Agent 在团队中的角色
- 添加成功后 Agent 出现在成员列表

**Agent 角色设置：**
- 四种 Agent 角色：执行者 / 审核者 / 协调者 / 观察者
- 每种角色有预定义的权限矩阵（详见第 8 章）
- 角色可随时变更，变更后权限即时生效
- 角色说明提示（Tooltip）解释每种角色的职责

**移除 Agent：**
- 移除前检查是否有正在执行的任务
- 如有执行中任务：可选择"等待完成后移除"或"立即移除（任务标记为中断）"
- 移除后 Agent 不再出现在团队成员列表

#### 6.1.3 成员卡片展示

**卡片信息：**
```
┌─────────────────────────────────┐    ┌─────────────────────────────────┐
│  [Avatar]  陈明辉               │    │  [🤖]  代码助手                  │
│  ● 在线                         │    │  ● 在线                         │
│                                 │    │                                 │
│  技术负责人                      │    │  全栈开发 · Claude Sonnet        │
│  [管理员] [协调者]               │    │  [执行者]                       │
│                                 │    │                                 │
│  任务: 12 完成 / 15 分配         │    │  任务: 28 完成 / 30 分配         │
│  最近活动: 2 分钟前              │    │  成功率: 93.3%                   │
└─────────────────────────────────┘    └─────────────────────────────────┘
        人类成员卡片                            Agent 成员卡片
```

**卡片元素：**
- 头像：人类用 Logto 头像，Agent 用自定义图标（可上传或从预设选择）
- 名称：人类用显示名，Agent 用配置名称
- 状态指示器：
  - 人类：在线（绿色）/ 离线（灰色）
  - Agent：在线（绿色）/ 忙碌（黄色）/ 离线（灰色）/ 异常（红色）/ 更新中（蓝色）
- 角色标签：Badge 样式，颜色编码（管理员-紫色、成员-蓝色、审核者-橙色、执行者-绿色、协调者-紫色、观察者-灰色）
- 辅助信息：人类显示职位/部门，Agent 显示模型名称和能力标签
- 统计信息：人类显示任务完成/分配数，Agent 额外显示成功率

**分组展示：**
- 人类成员区域（上方）和 Agent 成员区域（下方）
- 每个区域内按角色排序：管理员 > 审核者 > 成员（人类）；协调者 > 审核者 > 执行者 > 观察者（Agent）
- 每个区域显示成员数量徽标

### 6.2 P1 功能

#### 6.2.1 HxA 协作拓扑图

**可视化展示：**
- 力导向图（Force-Directed Graph）
- 节点：圆形，人类成员蓝色底色，Agent 成员绿色底色
- 节点大小：反映活跃度（过去 N 天的协作次数）
- 边：有向箭头，表示协作方向（如"人→Agent 委派任务"、"Agent→人 提交结果"）
- 边粗细：反映协作频次
- 边颜色：委派（蓝色）、交接（绿色）、审核（橙色）、上报（红色）

**交互功能：**
- 缩放（鼠标滚轮/手势）
- 拖拽节点（重新布局）
- 点击节点高亮其协作路径
- Hover 节点/边显示详细统计
- 时间范围筛选（7天 / 30天 / 全部）
- 关系类型筛选（委派 / 交接 / 审核 / 全部）

**数据来源（自动聚合）：**
- 任务分配事件 → 委派边
- 任务提交/交接事件 → 交接边
- 任务审核事件 → 审核边
- 对话 @提及事件 → 沟通边
- Agent 上报/升级事件 → 上报边

#### 6.2.2 成员详情面板

**面板内容：**
- 基本信息（头像、名称、角色、加入时间）
- 协作统计（分配任务数、完成任务数、协作次数、Agent 额外显示成功率和平均执行时间）
- 最近协作记录（时间线形式）
- 快捷操作（分配任务、发消息、修改角色）

### 6.3 P2 功能

#### 6.3.1 多团队管理

- 一个 Workspace 下可创建多个团队
- 团队列表视图（左侧边栏或顶部 Tab）
- 创建团队表单（名称、描述、图标）
- 同一成员可加入多个团队，在不同团队有不同角色
- 团队级设置（默认角色、自动添加新 Agent 规则等）
- 团队归档/删除
- 团队与项目（Module 3）关联

#### 6.3.2 团队级权限模板

- 预定义权限模板（开发团队、运营团队、设计团队）
- 自定义权限模板
- 模板应用到新团队时自动配置角色和权限

---

## 7. HxA 协作模型

### 7.1 多态成员接口

CODE-YI 团队模块的核心设计原则是**多态成员接口 (Polymorphic Member Interface)**——人类和 Agent 共享同一个成员数据结构，通过 `member_type` 字段区分。

```typescript
// 统一的团队成员接口
interface TeamMember {
  id: string;                              // team_member 记录 ID
  team_id: string;                         // 所属团队
  member_id: string;                       // 关联的 user_id 或 agent_id
  member_type: 'human' | 'agent';          // 成员类型
  
  // 角色（人类和 Agent 使用不同的角色枚举）
  human_role?: 'admin' | 'member' | 'reviewer';
  agent_role?: 'executor' | 'reviewer' | 'coordinator' | 'observer';
  
  // 展示信息（由 join 查询填充）
  display_name: string;
  avatar_url: string;
  status: MemberStatus;
  
  // 统计
  assigned_task_count: number;
  completed_task_count: number;
  
  // Agent 额外信息
  agent_model?: string;                    // 如 "Claude Sonnet"
  agent_capability_tags?: string[];        // 如 ["全栈开发", "代码审查"]
  agent_success_rate?: number;             // 如 0.933
  
  // 时间
  joined_at: string;
  last_active_at: string;
}

// 成员状态
type MemberStatus = 
  | 'online'     // 在线
  | 'offline'    // 离线
  | 'busy'       // 忙碌（Agent 特有：正在执行任务）
  | 'error'      // 异常（Agent 特有：进程异常）
  | 'updating';  // 更新中（Agent 特有：模型/配置更新中）
```

### 7.2 角色层级体系

CODE-YI 的角色体系是双轨制——人类角色和 Agent 角色各自独立，但在权限矩阵中统一管理。

```
┌─────────────────────────────────────────────────────────────────┐
│                     CODE-YI 角色体系                              │
│                                                                  │
│  ┌─── 人类角色 ───┐          ┌─── Agent 角色 ───┐               │
│  │                │          │                   │               │
│  │  管理员 Admin   │          │  协调者 Coordinator│               │
│  │  ↑ 最高权限     │          │  ↑ 拆解需求、分配  │               │
│  │                │          │                   │               │
│  │  审核者 Reviewer│          │  审核者 Reviewer   │               │
│  │  ↑ 审批权限     │          │  ↑ Review 产出    │               │
│  │                │          │                   │               │
│  │  成员 Member    │          │  执行者 Executor  │               │
│  │  ↑ 基础使用     │          │  ↑ 执行任务、交付  │               │
│  │                │          │                   │               │
│  └────────────────┘          │  观察者 Observer   │               │
│                              │  ↑ 只读监控       │               │
│                              └───────────────────┘               │
└─────────────────────────────────────────────────────────────────┘
```

**设计决策：为什么人类和 Agent 使用不同的角色枚举？**

1. **语义差异**：人类的"管理员"意味着"管理团队"，Agent 的"协调者"意味着"编排任务"——虽然都是高权限角色，但职责完全不同
2. **权限粒度不同**：人类管理员可以删除团队、移除成员；Agent 协调者可以拆解需求和分配子任务——这不是同一套权限
3. **避免混淆**：如果人类和 Agent 共用"Admin/Member/Guest"角色，用户会困惑"Agent 的 Admin 能做什么？"。独立的角色命名让语义更清晰

### 7.3 协作模式

CODE-YI 支持四种核心协作模式，所有模式都会在拓扑图中可视化：

#### 7.3.1 Human → Agent 委派 (Delegation)

```
人类成员                    Agent（执行者/协调者）
  │                              │
  ├── 创建任务并指派给 Agent ──→  │
  │                              ├── 接收任务
  │                              ├── 自主执行
  │                              ├── 实时汇报进度
  │  ←── 提交结果 ───────────────┤
  │                              │
  ├── 审核结果                    │
  │  ├── 通过 → 任务完成          │
  │  └── 不通过 → 反馈修改意见 ──→│ 重新执行
```

**拓扑图表达：** 人类节点 → Agent 节点（蓝色委派边）

#### 7.3.2 Agent → Agent 交接 (Handoff)

```
Agent A（执行者）           Agent B（审核者）
  │                              │
  ├── 完成代码编写                │
  ├── 提交给 Agent B 审核 ────→  │
  │                              ├── 自动 Code Review
  │                              ├── 生成审查报告
  │  ←── 返回审查意见 ────────── │
  │                              │
  ├── 修改代码                   │
  ├── 再次提交 ──────────────→   │
```

**拓扑图表达：** Agent A 节点 → Agent B 节点（绿色交接边）

#### 7.3.3 Agent → Human 上报 (Escalation)

```
Agent（执行者/协调者）       人类成员
  │                              │
  ├── 遇到无法自主决策的情况       │
  │   （如：发现严重 bug、         │
  │    需要业务确认、              │
  │    超出权限范围）              │
  │                              │
  ├── 发送上报消息 ────────────→ │
  │   附带上下文和建议选项         ├── 人类审阅
  │                              ├── 做出决策
  │  ←── 收到决策指令 ──────────  │
  │                              │
  ├── 按照人类决策继续执行         │
```

**拓扑图表达：** Agent 节点 → 人类节点（红色上报边）

#### 7.3.4 Coordinator 编排 (Orchestration)

```
Agent（协调者）
  │
  ├── 接收高层需求
  ├── 拆解为子任务
  │
  ├── 分配子任务 A → Agent 执行者 1
  ├── 分配子任务 B → Agent 执行者 2
  ├── 分配子任务 C → 人类成员 1
  │
  ├── 跟踪所有子任务进度
  ├── 汇总结果
  └── 提交最终产出
```

**拓扑图表达：** 协调者节点 → 多个执行者节点（蓝色委派边扇出）

### 7.4 协作关系数据模型

```typescript
// 协作关系边
interface CollaborationEdge {
  id: string;
  team_id: string;
  
  // 源节点
  source_member_id: string;
  source_member_type: 'human' | 'agent';
  
  // 目标节点
  target_member_id: string;
  target_member_type: 'human' | 'agent';
  
  // 关系类型
  relation_type: 'delegation' | 'handoff' | 'review' | 'escalation' | 'communication';
  
  // 统计（时间窗口内）
  interaction_count: number;          // 交互次数
  last_interaction_at: string;        // 最近交互时间
  
  // 来源事件（聚合）
  task_assignments: number;           // 任务分配次数
  task_handoffs: number;              // 任务交接次数
  message_mentions: number;           // 消息 @提及次数
  review_requests: number;            // 审核请求次数
}
```

### 7.5 拓扑图渲染规则

```
节点样式：
  人类成员 → 圆形，蓝色边框，Logto 头像
  Agent 成员 → 圆形，绿色边框，机器人图标
  节点大小 → 基于活跃度（MIN 40px, MAX 80px）
  活跃度 = 过去 N 天的总协作次数归一化

边样式：
  委派 (delegation)  → 蓝色实线箭头
  交接 (handoff)     → 绿色实线箭头
  审核 (review)      → 橙色虚线箭头
  上报 (escalation)  → 红色虚线箭头
  沟通 (communication) → 灰色细线
  边粗细 → 基于交互频次（MIN 1px, MAX 6px）

布局算法：
  D3.js force simulation
  - 斥力 (charge): -300（防止节点重叠）
  - 引力 (center): 指向画布中心
  - 链接力 (link): 基于交互频次（交互多 → 距离近）
  - 碰撞检测 (collision): 节点半径 + 10px padding

交互：
  - 鼠标悬停节点 → 高亮所有相连边 + 显示统计卡片
  - 点击节点 → 固定高亮 + 展开详情面板
  - 拖拽节点 → 重新布局（释放后回弹或固定）
  - 鼠标悬停边 → 显示关系详情（类型、频次、最近时间）
  - 滚轮缩放 → 缩放拓扑图
  - 双击空白 → 重置视图
```

---

## 8. Agent 角色权限引擎

### 8.1 Agent 角色定义

#### 8.1.1 执行者 (Executor)

```
职责描述：
  接收人类或协调者分配的任务 → 自主执行 → 提交交付物

典型场景：
  - 代码助手写代码、修 bug
  - 设计 Agent 生成设计稿
  - 内容 Agent 撰写文档
  - 测试 Agent 执行自动化测试

行为特征：
  - 被动触发（不主动发起任务）
  - 专注执行单个任务
  - 遇到问题时上报而非自主决策
  - 执行完成后提交结果等待审核
```

#### 8.1.2 审核者 (Reviewer)

```
职责描述：
  Review 其他 Agent 或人类的产出 → 提出修改建议 → 决定是否通过

典型场景：
  - 测试 Agent 做 Code Review
  - QA Agent 验证测试覆盖率
  - 安全 Agent 审查代码安全性
  - 设计 Agent 审查 UI 一致性

行为特征：
  - 被动触发（收到审核请求时启动）
  - 只读访问被审核的产出物
  - 产出物是"审核报告"而非"执行结果"
  - 可以请求修改但不能直接修改产出
```

#### 8.1.3 协调者 (Coordinator)

```
职责描述：
  拆解高层需求 → 分配子任务给执行者 → 跟踪进度 → 汇总结果

典型场景：
  - 产品助手接收需求 → 拆解为多个开发任务
  - 项目经理 Agent 制定 Sprint 计划
  - 架构 Agent 做技术方案 → 分配给多个代码 Agent

行为特征：
  - 可主动发起任务（向执行者分配）
  - 全局视角（了解所有子任务的状态）
  - 不直接执行任务，只编排和监控
  - 遇到重大决策时上报给人类
```

#### 8.1.4 观察者 (Observer)

```
职责描述：
  只读监控团队活动 → 收集和分析数据 → 生成报告

典型场景：
  - 数据分析 Agent 监控项目进度
  - 周报 Agent 汇总一周工作
  - 告警 Agent 监控系统指标
  - 知识 Agent 总结和归档对话内容

行为特征：
  - 主动运行（持续监控或定期触发）
  - 只读权限（不能创建/修改任务、不能发起对话）
  - 产出物是"报告"和"分析"
  - 通过通知或定期报告机制传递结果
```

### 8.2 跨模块权限矩阵

Agent 角色的权限不仅限于团队模块，而是横跨 Module 1-6。以下是完整的权限矩阵：

#### 8.2.1 Module 1 (Chat 对话) 权限

| 操作 | 执行者 | 审核者 | 协调者 | 观察者 |
|------|--------|--------|--------|--------|
| 在团队频道发送消息 | 允许（任务相关） | 允许（审核反馈） | 允许（编排相关） | 禁止 |
| 在 DM 中对话 | 允许（与分配者） | 允许（与被审核者） | 允许（与所有成员） | 禁止 |
| 主动发起对话 | 禁止 | 禁止 | 允许 | 禁止 |
| @提及其他成员 | 允许（上报时） | 允许 | 允许 | 禁止 |
| 读取频道消息 | 允许（已加入的） | 允许（已加入的） | 允许（所有团队频道） | 允许（只读） |
| 发送通知 | 允许（任务状态变更） | 允许（审核结果） | 允许（进度更新） | 允许（报告推送） |

#### 8.2.2 Module 2 (Tasks 任务) 权限

| 操作 | 执行者 | 审核者 | 协调者 | 观察者 |
|------|--------|--------|--------|--------|
| 创建任务 | 禁止 | 禁止 | **允许** | 禁止 |
| 被分配任务 | **允许** | 禁止 | 禁止 | 禁止 |
| 执行任务 | **允许** | 禁止 | 禁止 | 禁止 |
| 更新任务状态 | 允许（自己的） | 禁止 | 允许（协调中的） | 禁止 |
| 更新任务进度 | 允许（自己的） | 禁止 | 允许（协调中的） | 禁止 |
| 审核任务 | 禁止 | **允许** | 禁止 | 禁止 |
| 分配任务给其他 Agent | 禁止 | 禁止 | **允许** | 禁止 |
| 查看任务详情 | 允许（相关的） | 允许（待审核的） | 允许（所有的） | 允许（只读） |
| 评论任务 | 允许（自己的） | 允许（审核意见） | 允许 | 禁止 |

#### 8.2.3 Module 3 (Projects 项目) 权限

| 操作 | 执行者 | 审核者 | 协调者 | 观察者 |
|------|--------|--------|--------|--------|
| 查看项目 | 允许（已加入的） | 允许（已加入的） | 允许（已加入的） | 允许（只读） |
| 查看项目进度 | 允许 | 允许 | 允许 | 允许 |
| 提交代码/PR | **允许** | 禁止 | 禁止 | 禁止 |
| Review PR | 禁止 | **允许** | 禁止 | 禁止 |
| 创建 Sprint | 禁止 | 禁止 | **允许** | 禁止 |
| 管理 Sprint 任务 | 禁止 | 禁止 | **允许** | 禁止 |
| 生成项目报告 | 禁止 | 禁止 | 允许 | **允许** |

#### 8.2.4 Module 4 (Team 团队) 权限

| 操作 | 执行者 | 审核者 | 协调者 | 观察者 |
|------|--------|--------|--------|--------|
| 查看团队成员 | 允许 | 允许 | 允许 | 允许 |
| 查看协作拓扑 | 允许 | 允许 | 允许 | 允许 |
| 邀请/添加成员 | 禁止 | 禁止 | 禁止 | 禁止 |
| 移除成员 | 禁止 | 禁止 | 禁止 | 禁止 |
| 修改自己的 Agent 配置 | 允许（限定范围） | 允许（限定范围） | 允许 | 禁止 |

> **注意：** Agent 成员管理操作（邀请、添加、移除、角色变更）只允许人类管理员执行。任何 Agent 角色都不能修改团队成员组成。

#### 8.2.5 Module 5 (Agent 管理) 权限

| 操作 | 执行者 | 审核者 | 协调者 | 观察者 |
|------|--------|--------|--------|--------|
| 查看自己的状态 | 允许 | 允许 | 允许 | 允许 |
| 上报自己的健康状态 | 允许 | 允许 | 允许 | 允许 |
| 查看其他 Agent 状态 | 禁止 | 禁止 | **允许** | **允许** |
| 重启其他 Agent | 禁止 | 禁止 | 禁止 | 禁止 |

### 8.3 权限检查流程

```
API 请求到达
  │
  ├── 1. 身份认证（JWT Token → user_id / agent_id + agent_type）
  │
  ├── 2. 确定成员类型
  │     ├── user_id → 人类成员 → 查询 human_role
  │     └── agent_id → Agent 成员 → 查询 agent_role
  │
  ├── 3. 查询权限矩阵
  │     ├── 操作: "task.create"
  │     ├── 角色: "coordinator"
  │     └── 结果: ALLOW
  │
  ├── 4. 附加条件检查（可选）
  │     ├── 范围检查：该 Agent 是否属于此团队？
  │     ├── 资源检查：该任务是否在 Agent 的可见范围？
  │     └── 频率检查：是否超过操作频率限制？
  │
  └── 5. 返回结果
        ├── ALLOW → 继续处理
        ├── DENY → 返回 403 + 权限不足说明
        └── ESCALATE → 触发人类审批流程
```

### 8.4 角色变更工作流

```
管理员发起角色变更
  │
  ├── 检查：是否有进行中的操作会被打断？
  │     ├── 执行者 → 审核者：检查是否有执行中任务
  │     │   └── 如有：提示"该 Agent 正在执行 N 个任务，变更后将中断执行"
  │     ├── 协调者 → 执行者：检查是否有正在编排的子任务
  │     │   └── 如有：提示"该 Agent 正在协调 N 个子任务，变更后将停止编排"
  │     └── 任意角色 → 观察者：检查是否有写操作权限将被撤销
  │
  ├── 管理员确认变更
  │
  ├── 执行变更
  │     ├── 更新 team_members.agent_role
  │     ├── 清除旧角色的缓存权限
  │     ├── 加载新角色的权限
  │     └── 通知 Agent 角色已变更
  │
  ├── 记录变更日志（team_activities 表）
  │
  └── WebSocket 通知团队成员
```

### 8.5 权限继承与覆盖

```
权限优先级（从高到低）：
  1. Workspace 级封禁（最高优先级）
     → Workspace 管理员可以全局禁用某个 Agent
  2. 团队级角色权限
     → 由 agent_role 决定
  3. 项目级覆盖（P2 功能）
     → 特定项目可覆盖团队角色权限（如：代码助手在项目 A 是执行者，在项目 B 是观察者）
  4. 全局默认（最低优先级）
     → 未明确配置的操作默认 DENY
```

---

## 9. 数据模型

### 9.1 团队主表

```sql
-- 团队表
CREATE TABLE teams (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  name VARCHAR(100) NOT NULL,
  description TEXT,                          -- Markdown 格式
  icon_url VARCHAR(500),                     -- 团队图标
  
  -- 统计（缓存字段，异步更新）
  human_count INTEGER DEFAULT 0,             -- 人类成员数
  agent_count INTEGER DEFAULT 0,             -- Agent 成员数
  total_member_count INTEGER DEFAULT 0,      -- 总成员数
  
  -- 配置
  default_human_role VARCHAR(20) DEFAULT 'member'
    CHECK (default_human_role IN ('admin', 'member', 'reviewer')),
  default_agent_role VARCHAR(20) DEFAULT 'executor'
    CHECK (default_agent_role IN ('executor', 'reviewer', 'coordinator', 'observer')),
  
  -- 状态
  status VARCHAR(20) NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'archived')),
  
  -- 审计
  created_by UUID NOT NULL,                  -- 创建者 user_id
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  archived_at TIMESTAMPTZ,
  
  UNIQUE(workspace_id, name)
);

-- 索引
CREATE INDEX idx_teams_workspace ON teams(workspace_id, status);
CREATE INDEX idx_teams_status ON teams(status, updated_at DESC);
CREATE INDEX idx_teams_created_by ON teams(created_by);
```

### 9.2 团队成员表（多态）

```sql
-- 团队成员表（核心表——多态设计）
CREATE TABLE team_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  
  -- 多态成员：member_id 可指向 users 表或 agents 表
  member_id UUID NOT NULL,
  member_type VARCHAR(10) NOT NULL
    CHECK (member_type IN ('human', 'agent')),
  
  -- 人类角色（仅 member_type = 'human' 时有效）
  human_role VARCHAR(20)
    CHECK (human_role IN ('admin', 'member', 'reviewer')),
  
  -- Agent 角色（仅 member_type = 'agent' 时有效）
  agent_role VARCHAR(20)
    CHECK (agent_role IN ('executor', 'reviewer', 'coordinator', 'observer')),
  
  -- 约束：人类必须有 human_role，Agent 必须有 agent_role
  CONSTRAINT role_type_check CHECK (
    (member_type = 'human' AND human_role IS NOT NULL AND agent_role IS NULL) OR
    (member_type = 'agent' AND agent_role IS NOT NULL AND human_role IS NULL)
  ),
  
  -- 显示信息（冗余缓存，减少 join 查询）
  display_name VARCHAR(100),
  avatar_url VARCHAR(500),
  
  -- 统计（缓存）
  assigned_task_count INTEGER DEFAULT 0,
  completed_task_count INTEGER DEFAULT 0,
  
  -- 状态
  is_active BOOLEAN DEFAULT TRUE,
  
  -- 时间
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_active_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- 唯一约束：同一人/Agent 在同一团队中只能有一个成员记录
  UNIQUE(team_id, member_id, member_type)
);

-- 索引
CREATE INDEX idx_team_members_team ON team_members(team_id) WHERE is_active = TRUE;
CREATE INDEX idx_team_members_member ON team_members(member_id, member_type);
CREATE INDEX idx_team_members_human_role ON team_members(team_id, human_role) 
  WHERE member_type = 'human' AND is_active = TRUE;
CREATE INDEX idx_team_members_agent_role ON team_members(team_id, agent_role) 
  WHERE member_type = 'agent' AND is_active = TRUE;
```

### 9.3 成员角色权限表

```sql
-- Agent 角色权限矩阵（系统级配置，非用户数据）
CREATE TABLE agent_role_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- 角色
  agent_role VARCHAR(20) NOT NULL
    CHECK (agent_role IN ('executor', 'reviewer', 'coordinator', 'observer')),
  
  -- 模块
  module VARCHAR(20) NOT NULL
    CHECK (module IN ('chat', 'tasks', 'projects', 'team', 'agents')),
  
  -- 操作
  action VARCHAR(50) NOT NULL,               -- 如 'task.create', 'message.send', 'project.view'
  
  -- 权限
  permission VARCHAR(10) NOT NULL DEFAULT 'deny'
    CHECK (permission IN ('allow', 'deny', 'conditional')),
  
  -- 条件说明（当 permission = 'conditional' 时）
  condition_description TEXT,                -- 人类可读的条件说明
  condition_rule JSONB,                      -- 机器可读的条件规则
  
  UNIQUE(agent_role, module, action)
);

-- 索引
CREATE INDEX idx_role_permissions_role ON agent_role_permissions(agent_role);
CREATE INDEX idx_role_permissions_module ON agent_role_permissions(module, action);
```

### 9.4 协作边表（拓扑图数据）

```sql
-- HxA 协作关系边（拓扑图的数据源）
CREATE TABLE collaboration_edges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  
  -- 源节点
  source_member_id UUID NOT NULL,
  source_member_type VARCHAR(10) NOT NULL
    CHECK (source_member_type IN ('human', 'agent')),
  
  -- 目标节点
  target_member_id UUID NOT NULL,
  target_member_type VARCHAR(10) NOT NULL
    CHECK (target_member_type IN ('human', 'agent')),
  
  -- 关系类型
  relation_type VARCHAR(20) NOT NULL
    CHECK (relation_type IN ('delegation', 'handoff', 'review', 'escalation', 'communication')),
  
  -- 统计（滚动窗口，由后台 Worker 定期聚合）
  interaction_count_7d INTEGER DEFAULT 0,    -- 过去 7 天交互次数
  interaction_count_30d INTEGER DEFAULT 0,   -- 过去 30 天交互次数
  interaction_count_total INTEGER DEFAULT 0, -- 总交互次数
  
  -- 细分统计
  task_assignments INTEGER DEFAULT 0,        -- 任务分配次数
  task_handoffs INTEGER DEFAULT 0,           -- 任务交接次数
  message_mentions INTEGER DEFAULT 0,        -- 消息 @提及次数
  review_requests INTEGER DEFAULT 0,         -- 审核请求次数
  
  -- 时间
  first_interaction_at TIMESTAMPTZ,
  last_interaction_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- 唯一约束：同一对成员之间的同一种关系只有一条边
  UNIQUE(team_id, source_member_id, source_member_type, 
         target_member_id, target_member_type, relation_type)
);

-- 索引
CREATE INDEX idx_collab_edges_team ON collaboration_edges(team_id);
CREATE INDEX idx_collab_edges_source ON collaboration_edges(source_member_id, source_member_type);
CREATE INDEX idx_collab_edges_target ON collaboration_edges(target_member_id, target_member_type);
CREATE INDEX idx_collab_edges_recent ON collaboration_edges(team_id, last_interaction_at DESC);
```

### 9.5 协作事件日志表

```sql
-- 协作事件日志（拓扑图聚合的原始数据）
CREATE TABLE collaboration_events (
  id BIGSERIAL PRIMARY KEY,
  team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  
  -- 源
  source_member_id UUID NOT NULL,
  source_member_type VARCHAR(10) NOT NULL
    CHECK (source_member_type IN ('human', 'agent')),
  
  -- 目标
  target_member_id UUID NOT NULL,
  target_member_type VARCHAR(10) NOT NULL
    CHECK (target_member_type IN ('human', 'agent')),
  
  -- 事件类型
  event_type VARCHAR(30) NOT NULL,
  -- 可能的值：
  -- 'task_assigned'       : 任务分配
  -- 'task_handed_off'     : 任务交接
  -- 'task_reviewed'       : 任务审核
  -- 'task_escalated'      : 任务上报
  -- 'message_mentioned'   : 消息 @提及
  -- 'pr_review_requested' : PR Review 请求
  -- 'pr_reviewed'         : PR 已 Review
  
  -- 关联实体
  related_entity_type VARCHAR(20),           -- 'task' | 'message' | 'pr'
  related_entity_id VARCHAR(100),            -- 实体 ID
  
  -- 事件详情
  details JSONB,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_collab_events_team ON collaboration_events(team_id, created_at DESC);
CREATE INDEX idx_collab_events_source ON collaboration_events(source_member_id, created_at DESC);
CREATE INDEX idx_collab_events_target ON collaboration_events(target_member_id, created_at DESC);
-- 用于定期聚合的时间范围查询
CREATE INDEX idx_collab_events_time ON collaboration_events(team_id, created_at) 
  WHERE created_at > NOW() - INTERVAL '30 days';
```

### 9.6 团队邀请表

```sql
-- 团队邀请
CREATE TABLE team_invitations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  
  -- 邀请方式
  invite_type VARCHAR(10) NOT NULL
    CHECK (invite_type IN ('email', 'link')),
  
  -- 邮件邀请
  invitee_email VARCHAR(255),                -- invite_type='email' 时必填
  
  -- 链接邀请
  invite_code VARCHAR(32),                   -- invite_type='link' 时的唯一代码
  max_uses INTEGER,                          -- 最大使用次数（NULL=无限）
  use_count INTEGER DEFAULT 0,               -- 已使用次数
  
  -- 角色
  assigned_role VARCHAR(20) DEFAULT 'member'
    CHECK (assigned_role IN ('admin', 'member', 'reviewer')),
  
  -- 状态
  status VARCHAR(20) NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'accepted', 'expired', 'revoked')),
  
  -- 时间
  expires_at TIMESTAMPTZ NOT NULL,
  accepted_at TIMESTAMPTZ,
  accepted_by UUID,                          -- 接受邀请的 user_id
  
  -- 审计
  invited_by UUID NOT NULL,                  -- 邀请人 user_id
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- 邮件邀请的唯一约束
  CONSTRAINT unique_pending_email_invite 
    UNIQUE NULLS NOT DISTINCT (team_id, invitee_email, status)
);

-- 索引
CREATE INDEX idx_invitations_team ON team_invitations(team_id, status);
CREATE INDEX idx_invitations_email ON team_invitations(invitee_email, status) 
  WHERE invite_type = 'email';
CREATE INDEX idx_invitations_code ON team_invitations(invite_code) 
  WHERE invite_type = 'link' AND status = 'pending';
CREATE INDEX idx_invitations_expiry ON team_invitations(expires_at) 
  WHERE status = 'pending';
```

### 9.7 团队活动表

```sql
-- 团队级活动流
CREATE TABLE team_activities (
  id BIGSERIAL PRIMARY KEY,
  team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  
  -- 操作者
  actor_id UUID NOT NULL,
  actor_type VARCHAR(10) NOT NULL
    CHECK (actor_type IN ('human', 'agent', 'system')),
  
  -- 操作
  action VARCHAR(30) NOT NULL,
  -- 可能的 action 值:
  -- 'team_created', 'team_updated', 'team_archived',
  -- 'member_invited', 'member_joined', 'member_removed',
  -- 'member_role_changed',
  -- 'agent_added', 'agent_removed', 'agent_role_changed',
  -- 'agent_status_changed'
  
  -- 目标
  target_type VARCHAR(20),                   -- 'member' | 'agent' | 'team' | 'invitation'
  target_id VARCHAR(100),
  
  -- 详情
  details JSONB,                             -- 活动详情（如角色变更前后值）
  summary VARCHAR(300),                      -- 人类可读摘要
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_team_activities_team ON team_activities(team_id, created_at DESC);
CREATE INDEX idx_team_activities_recent ON team_activities(created_at DESC);
```

### 9.8 Agent 状态表

```sql
-- Agent 实时状态（与 Module 5 共享，此处定义 Team 视角的状态视图）
-- 注意：Agent 的核心数据（名称、模型、能力等）在 Module 5 的 agents 表中
-- team_members 表通过 member_id 关联到 agents 表
-- 此表仅记录 Agent 在团队上下文中的实时状态

CREATE TABLE agent_team_status (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  team_member_id UUID NOT NULL REFERENCES team_members(id) ON DELETE CASCADE,
  
  -- 状态
  status VARCHAR(20) NOT NULL DEFAULT 'offline'
    CHECK (status IN ('online', 'offline', 'busy', 'error', 'updating')),
  
  -- 状态详情（error 时有错误信息）
  status_details JSONB,
  
  -- 当前执行的任务（busy 时）
  current_task_id UUID,
  current_task_title VARCHAR(200),
  
  -- 健康指标
  uptime_seconds BIGINT DEFAULT 0,          -- 连续运行时间
  last_heartbeat_at TIMESTAMPTZ,            -- 最后心跳时间
  error_count_24h INTEGER DEFAULT 0,        -- 过去 24 小时错误次数
  
  -- 统计
  tasks_completed_today INTEGER DEFAULT 0,
  avg_task_duration_seconds INTEGER,         -- 平均任务执行时间
  
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  UNIQUE(team_member_id)
);

-- 索引
CREATE INDEX idx_agent_status_status ON agent_team_status(status);
CREATE INDEX idx_agent_status_heartbeat ON agent_team_status(last_heartbeat_at) 
  WHERE status IN ('online', 'busy');
```

### 9.9 ER 关系图

```
workspaces
  │
  └── teams
        │
        ├── team_members ─── (users 表 | agents 表 via member_id + member_type)
        │     │
        │     └── agent_team_status (Agent 成员的实时状态)
        │
        ├── team_invitations (邮件/链接邀请)
        │
        ├── collaboration_edges (HxA 协作关系 — 聚合数据)
        │     └── collaboration_events (协作事件日志 — 原始数据)
        │
        ├── team_activities (团队活动流)
        │
        └── agent_role_permissions (系统级 — Agent 角色权限矩阵)
        
外部关联：
  team_members.member_id → users.id (当 member_type = 'human')
  team_members.member_id → agents.id (当 member_type = 'agent', Module 5)
  collaboration_events.related_entity_id → tasks.id (Module 2)
  collaboration_events.related_entity_id → messages.id (Module 1)
```

### 9.10 与现有模块的数据关系

**与 Module 2 (Tasks) 的关系：**
- `tasks.assignee_id` + `tasks.assignee_type` 关联到 `team_members.member_id` + `team_members.member_type`
- 任务分配事件触发 `collaboration_events` 记录
- Agent 角色权限决定 Agent 能否被分配/执行/审核任务

**与 Module 3 (Projects) 的关系：**
- `project_members` 表与 `team_members` 表结构类似但独立——一个 Agent 可以是"产品开发团队"的执行者，同时是"项目 A"的成员
- P2 功能中，项目可关联团队，项目成员自动从团队成员同步
- 项目级可覆盖 Agent 的团队角色（如：团队中是执行者，但在特定项目中是审核者）

**与 Module 5 (Agent 管理) 的关系：**
- `agents` 表（Module 5）存储 Agent 的核心数据（名称、模型、能力、API Key 等）
- `team_members` 表通过 `member_id` 关联到 `agents` 表
- `agent_team_status` 表是 Module 5 `agent_status` 的团队视角投影

---

## 10. 技术方案

### 10.1 整体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                          客户端层                                    │
│  Web (Next.js + TailwindCSS)                                        │
│  ├── Team Members Page (成员卡片网格)                                │
│  │   ├── Human Members Section (人类成员区域)                        │
│  │   └── Agent Members Section (Agent 成员区域)                     │
│  ├── HxA Topology Graph (D3.js 力导向图)                            │
│  ├── Member Detail Panel (成员详情面板)                              │
│  ├── Invite Flow (邀请流程 UI)                                      │
│  └── Team Settings Page                                             │
└───────────────────────┬─────────────────────────────────────────────┘
                        │ REST API + WebSocket
┌───────────────────────┴─────────────────────────────────────────────┐
│                        API Gateway                                   │
│  JWT Auth │ RBAC Middleware │ Rate Limiting │ WS Upgrade             │
└───────────────────────┬─────────────────────────────────────────────┘
                        │
┌───────────────────────┴─────────────────────────────────────────────┐
│                        服务层                                        │
│                                                                      │
│  Team Service ──── Permission Engine ──── Topology Aggregator       │
│       │                    │                       │                  │
│       │              Redis Cache                   │                  │
│       │           (permissions,                Collaboration         │
│       │            member status)              Event Collector       │
│       │                    │                       │                  │
│  ┌────┴────────────────────┴───────────────────────┴──────┐         │
│  │              Event Bus (Redis Streams)                   │         │
│  └────┬────────────────────┬───────────────────────┬──────┘         │
│       │                    │                       │                  │
│  Invitation           Notification           Activity Logger          │
│  Service              Service                                         │
└───────────────────────┬─────────────────────────────────────────────┘
                        │
┌───────────────────────┴─────────────────────────────────────────────┐
│                        数据层                                        │
│  PostgreSQL 16 (Cloud SQL)  │  Redis 7 (Memorystore)                │
│  (teams, team_members,      │  (permission cache, member status,    │
│   collaboration_edges,       │   topology cache, invitation codes,   │
│   team_invitations)          │   event bus, websocket pub/sub)       │
└─────────────────────────────────────────────────────────────────────┘
```

### 10.2 API 设计

#### RESTful API

```
# 团队 CRUD
GET    /api/v1/workspaces/:wid/teams              # 获取团队列表
POST   /api/v1/workspaces/:wid/teams              # 创建团队
GET    /api/v1/teams/:tid                          # 获取团队详情
PATCH  /api/v1/teams/:tid                          # 更新团队
DELETE /api/v1/teams/:tid                          # 删除团队
POST   /api/v1/teams/:tid/archive                  # 归档团队
POST   /api/v1/teams/:tid/unarchive                # 取消归档

# 团队成员
GET    /api/v1/teams/:tid/members                  # 获取成员列表（含人类和 Agent）
POST   /api/v1/teams/:tid/members                  # 添加成员（人类或 Agent）
GET    /api/v1/teams/:tid/members/:mid             # 获取成员详情
PATCH  /api/v1/teams/:tid/members/:mid             # 修改成员角色
DELETE /api/v1/teams/:tid/members/:mid             # 移除成员

# 邀请管理
POST   /api/v1/teams/:tid/invitations              # 创建邀请（邮件或链接）
GET    /api/v1/teams/:tid/invitations              # 获取邀请列表
DELETE /api/v1/teams/:tid/invitations/:iid         # 撤销邀请
POST   /api/v1/invitations/:code/accept            # 接受邀请（通过邀请码）

# Agent 成员管理
GET    /api/v1/teams/:tid/agents                   # 获取 Agent 成员列表
POST   /api/v1/teams/:tid/agents                   # 从市场添加 Agent
PATCH  /api/v1/teams/:tid/agents/:aid              # 修改 Agent 角色/配置
DELETE /api/v1/teams/:tid/agents/:aid              # 移除 Agent
GET    /api/v1/teams/:tid/agents/:aid/status       # 获取 Agent 实时状态

# HxA 协作拓扑
GET    /api/v1/teams/:tid/topology                 # 获取拓扑图数据（节点+边）
GET    /api/v1/teams/:tid/topology/edges           # 获取协作边列表（支持时间范围筛选）
GET    /api/v1/teams/:tid/topology/stats           # 获取协作统计数据

# 权限查询
GET    /api/v1/permissions/agent-roles             # 获取 Agent 角色权限矩阵
GET    /api/v1/permissions/check                   # 检查特定操作的权限
       ?agent_id=xxx&action=task.create

# 团队活动
GET    /api/v1/teams/:tid/activities               # 获取团队活动流
```

#### 请求/响应示例

**创建团队：**

```typescript
// POST /api/v1/workspaces/:wid/teams
// Request
{
  "name": "产品开发团队",
  "description": "CODE-YI 产品核心开发团队",
  "icon_url": "https://cdn.codeyi.com/team-icons/dev.png",
  "members": [
    { "member_id": "user_chenmh", "member_type": "human", "human_role": "admin" },
    { "member_id": "user_lisq", "member_type": "human", "human_role": "member" },
    { "member_id": "agent_codebot", "member_type": "agent", "agent_role": "executor" },
    { "member_id": "agent_reviewer", "member_type": "agent", "agent_role": "reviewer" }
  ]
}

// Response 201
{
  "id": "team_abc123",
  "name": "产品开发团队",
  "description": "CODE-YI 产品核心开发团队",
  "icon_url": "https://cdn.codeyi.com/team-icons/dev.png",
  "status": "active",
  "human_count": 2,
  "agent_count": 2,
  "total_member_count": 4,
  "created_by": "user_chenmh",
  "created_at": "2026-04-20T10:00:00Z"
}
```

**获取成员列表：**

```typescript
// GET /api/v1/teams/:tid/members?include_status=true
// Response 200
{
  "members": {
    "humans": [
      {
        "id": "tm_001",
        "member_id": "user_chenmh",
        "member_type": "human",
        "display_name": "陈明辉",
        "avatar_url": "https://cdn.codeyi.com/avatars/chenmh.jpg",
        "human_role": "admin",
        "status": "online",
        "title": "技术负责人",
        "assigned_task_count": 15,
        "completed_task_count": 12,
        "joined_at": "2026-01-10T08:00:00Z",
        "last_active_at": "2026-04-20T09:55:00Z"
      },
      {
        "id": "tm_002",
        "member_id": "user_lisq",
        "member_type": "human",
        "display_name": "李思琪",
        "avatar_url": "https://cdn.codeyi.com/avatars/lisq.jpg",
        "human_role": "member",
        "status": "online",
        "title": "UI/UX 设计师",
        "assigned_task_count": 8,
        "completed_task_count": 6,
        "joined_at": "2026-01-12T08:00:00Z",
        "last_active_at": "2026-04-20T09:30:00Z"
      }
    ],
    "agents": [
      {
        "id": "tm_005",
        "member_id": "agent_codebot",
        "member_type": "agent",
        "display_name": "代码助手",
        "avatar_url": "https://cdn.codeyi.com/agent-icons/codebot.png",
        "agent_role": "executor",
        "status": "online",
        "agent_model": "Claude Sonnet",
        "agent_capability_tags": ["全栈开发", "代码审查", "Bug 修复"],
        "agent_success_rate": 0.933,
        "assigned_task_count": 30,
        "completed_task_count": 28,
        "joined_at": "2026-01-15T10:00:00Z",
        "last_active_at": "2026-04-20T09:58:00Z",
        "current_status_details": {
          "current_task": "实现用户认证模块",
          "uptime": "48h 23m",
          "tasks_today": 3
        }
      },
      {
        "id": "tm_006",
        "member_id": "agent_testbot",
        "member_type": "agent",
        "display_name": "测试 Agent",
        "avatar_url": "https://cdn.codeyi.com/agent-icons/testbot.png",
        "agent_role": "reviewer",
        "status": "offline",
        "agent_model": "GPT-4",
        "agent_capability_tags": ["自动化测试", "Code Review"],
        "agent_success_rate": 0.95,
        "assigned_task_count": 20,
        "completed_task_count": 19,
        "joined_at": "2026-02-01T10:00:00Z",
        "last_active_at": "2026-04-19T18:30:00Z"
      }
    ]
  },
  "total_humans": 4,
  "total_agents": 4,
  "total": 8
}
```

**获取拓扑图数据：**

```typescript
// GET /api/v1/teams/:tid/topology?period=30d
// Response 200
{
  "nodes": [
    {
      "id": "user_chenmh",
      "type": "human",
      "display_name": "陈明辉",
      "avatar_url": "...",
      "role": "admin",
      "status": "online",
      "activity_score": 0.85        // 归一化活跃度 [0, 1]
    },
    {
      "id": "agent_codebot",
      "type": "agent",
      "display_name": "代码助手",
      "avatar_url": "...",
      "role": "executor",
      "status": "online",
      "activity_score": 0.92
    }
    // ... more nodes
  ],
  "edges": [
    {
      "source": "user_chenmh",
      "target": "agent_codebot",
      "relation_type": "delegation",
      "interaction_count": 45,
      "last_interaction_at": "2026-04-20T09:30:00Z",
      "breakdown": {
        "task_assignments": 30,
        "message_mentions": 15
      }
    },
    {
      "source": "agent_codebot",
      "target": "agent_testbot",
      "relation_type": "handoff",
      "interaction_count": 22,
      "last_interaction_at": "2026-04-19T17:00:00Z",
      "breakdown": {
        "task_handoffs": 18,
        "pr_review_requests": 4
      }
    },
    {
      "source": "agent_codebot",
      "target": "user_chenmh",
      "relation_type": "escalation",
      "interaction_count": 5,
      "last_interaction_at": "2026-04-18T14:00:00Z",
      "breakdown": {
        "task_escalated": 5
      }
    }
    // ... more edges
  ],
  "period": "30d",
  "generated_at": "2026-04-20T10:00:00Z"
}
```

**创建邀请：**

```typescript
// POST /api/v1/teams/:tid/invitations
// 邮件邀请
{
  "invite_type": "email",
  "invitee_email": "zhangwei@example.com",
  "assigned_role": "member",
  "expires_in_days": 7
}

// Response 201
{
  "id": "inv_001",
  "invite_type": "email",
  "invitee_email": "zhangwei@example.com",
  "assigned_role": "member",
  "status": "pending",
  "expires_at": "2026-04-27T10:00:00Z",
  "invited_by": "user_chenmh"
}

// 链接邀请
{
  "invite_type": "link",
  "assigned_role": "member",
  "max_uses": 10,
  "expires_in_days": 30
}

// Response 201
{
  "id": "inv_002",
  "invite_type": "link",
  "invite_code": "abc123def456",
  "invite_url": "https://app.codeyi.com/invite/abc123def456",
  "assigned_role": "member",
  "max_uses": 10,
  "use_count": 0,
  "status": "pending",
  "expires_at": "2026-05-20T10:00:00Z"
}
```

### 10.3 WebSocket 事件

```typescript
// 客户端 → 服务端
interface WsClientEvents {
  'team:subscribe': { team_id: string };                // 订阅团队更新
  'team:unsubscribe': { team_id: string };
  'teams:subscribe': { workspace_id: string };           // 订阅 Workspace 的团队列表更新
  'teams:unsubscribe': { workspace_id: string };
}

// 服务端 → 客户端
interface WsServerEvents {
  // 团队列表更新
  'team:created': { team: TeamSummary };
  'team:updated': { team_id: string; changes: Partial<Team> };
  'team:archived': { team_id: string };
  
  // 成员变更
  'team:member_joined': { team_id: string; member: TeamMember };
  'team:member_left': { team_id: string; member_id: string; member_type: string };
  'team:member_role_changed': { 
    team_id: string; 
    member_id: string; 
    old_role: string; 
    new_role: string 
  };
  
  // Agent 状态变更
  'team:agent_status_changed': { 
    team_id: string;
    agent_id: string;
    old_status: MemberStatus;
    new_status: MemberStatus;
    details?: object;
  };
  
  // Agent 任务进度（实时更新忙碌状态）
  'team:agent_task_progress': {
    team_id: string;
    agent_id: string;
    task_id: string;
    task_title: string;
    progress: number;
  };
  
  // 协作事件（实时更新拓扑图）
  'team:collaboration_event': {
    team_id: string;
    event: CollaborationEvent;
  };
  
  // 拓扑图变更（当协作边数据有显著变化时推送）
  'team:topology_updated': {
    team_id: string;
    updated_edges: CollaborationEdge[];
  };
  
  // 邀请状态
  'team:invitation_accepted': {
    team_id: string;
    invitation_id: string;
    new_member: TeamMember;
  };
  
  // 团队活动
  'team:activity': { team_id: string; activity: TeamActivity };
}
```

### 10.4 前端架构

```
pages/
  teams/
    index.tsx              # 团队列表页（多团队视图）
    [teamId]/
      index.tsx            # 团队详情页（默认展示成员卡片）
      members.tsx          # 成员管理页
      topology.tsx         # HxA 协作拓扑页
      settings.tsx         # 团队设置页

components/
  teams/
    TeamCard.tsx                # 团队卡片（团队列表中）
    TeamList.tsx                # 团队列表
    TeamCreateForm.tsx          # 创建团队表单（Modal）
    
    members/
      MemberCard.tsx            # 成员卡片（统一组件，根据 type 渲染）
      HumanMemberCard.tsx       # 人类成员卡片内容
      AgentMemberCard.tsx       # Agent 成员卡片内容
      MemberCardGrid.tsx        # 成员卡片网格（分 Human/Agent 两区域）
      MemberDetailPanel.tsx     # 成员详情面板（Drawer）
      StatusIndicator.tsx       # 状态指示器（在线/离线/忙碌/异常）
      RoleBadge.tsx             # 角色标签组件
      
    invite/
      InviteModal.tsx           # 邀请弹窗
      EmailInviteForm.tsx       # 邮件邀请表单
      LinkInviteForm.tsx        # 链接邀请表单
      InvitationList.tsx        # 邀请列表（待处理）
      InviteAcceptPage.tsx      # 接受邀请页面
      
    agents/
      AgentMarketBrowser.tsx    # Agent 市场浏览器（嵌入式）
      AgentRoleSelector.tsx     # Agent 角色选择器（带说明）
      AgentStatusCard.tsx       # Agent 状态详情卡片
      
    topology/
      TopologyGraph.tsx         # D3.js 拓扑图主组件
      TopologyNode.tsx          # 拓扑图节点
      TopologyEdge.tsx          # 拓扑图边
      TopologyControls.tsx      # 控制面板（时间范围、关系类型筛选）
      TopologyTooltip.tsx       # 节点/边的 Tooltip
      TopologyLegend.tsx        # 图例
```

**关键组件设计：**

**MemberCard（统一成员卡片）：**

```tsx
// components/teams/members/MemberCard.tsx
interface MemberCardProps {
  member: TeamMember;
  onClickDetail: (member: TeamMember) => void;
  onRoleChange?: (memberId: string, newRole: string) => void;  // 管理员才有
}

export function MemberCard({ member, onClickDetail, onRoleChange }: MemberCardProps) {
  return (
    <div className="rounded-lg border p-4 hover:shadow-md transition-shadow cursor-pointer"
         onClick={() => onClickDetail(member)}>
      <div className="flex items-center gap-3">
        {/* 头像 + 状态指示器 */}
        <div className="relative">
          <Avatar src={member.avatar_url} size={48} />
          <StatusIndicator status={member.status} className="absolute -bottom-1 -right-1" />
        </div>
        
        {/* 名称 + 辅助信息 */}
        <div className="flex-1 min-w-0">
          <h3 className="font-medium truncate">{member.display_name}</h3>
          {member.member_type === 'human' ? (
            <p className="text-sm text-gray-500">{member.title}</p>
          ) : (
            <p className="text-sm text-gray-500">
              {member.agent_capability_tags?.[0]} · {member.agent_model}
            </p>
          )}
        </div>
      </div>
      
      {/* 角色标签 */}
      <div className="mt-3 flex gap-2">
        <RoleBadge role={member.human_role || member.agent_role} type={member.member_type} />
      </div>
      
      {/* 统计信息 */}
      <div className="mt-3 text-sm text-gray-500">
        {member.member_type === 'agent' ? (
          <span>成功率: {(member.agent_success_rate! * 100).toFixed(1)}%</span>
        ) : (
          <span>任务: {member.completed_task_count} 完成 / {member.assigned_task_count} 分配</span>
        )}
      </div>
    </div>
  );
}
```

**TopologyGraph（D3.js 拓扑图）：**

```tsx
// components/teams/topology/TopologyGraph.tsx
interface TopologyGraphProps {
  nodes: TopologyNode[];
  edges: TopologyEdge[];
  onNodeClick: (node: TopologyNode) => void;
  onEdgeHover: (edge: TopologyEdge | null) => void;
  timeRange: '7d' | '30d' | 'all';
  relationFilter: 'all' | 'delegation' | 'handoff' | 'review' | 'escalation';
}

// D3 force simulation 配置
const FORCE_CONFIG = {
  charge: -300,             // 节点间斥力
  centerStrength: 0.05,     // 向心力
  linkDistance: (edge: TopologyEdge) => {
    // 交互越多 → 距离越近
    const maxInteraction = 100;
    const normalized = Math.min(edge.interaction_count / maxInteraction, 1);
    return 200 - normalized * 120;  // 范围: 80-200
  },
  collisionRadius: 50,      // 碰撞半径
};

// 边样式配置
const EDGE_STYLES: Record<string, { color: string; dash: string }> = {
  delegation:    { color: '#3B82F6', dash: 'none' },     // 蓝色实线
  handoff:       { color: '#10B981', dash: 'none' },     // 绿色实线
  review:        { color: '#F59E0B', dash: '5,5' },      // 橙色虚线
  escalation:    { color: '#EF4444', dash: '5,5' },      // 红色虚线
  communication: { color: '#9CA3AF', dash: 'none' },     // 灰色细线
};
```

### 10.5 Permission Engine 架构

```
┌──────────────────────────────────────────────────────┐
│                 Permission Engine                      │
│                                                      │
│  1. Permission Check (同步路径，< 5ms)                │
│     ├── 检查 Redis 缓存: perm:{agent_id}:{action}    │
│     │   └── 命中 → 直接返回 ALLOW/DENY              │
│     │                                                │
│     ├── 缓存未命中 → 查询 agent_role_permissions 表   │
│     │   └── 写入 Redis 缓存 (TTL: 5 分钟)           │
│     │                                                │
│     └── 附加条件检查（if permission = 'conditional'）│
│         ├── 范围检查：Agent 是否属于该团队？           │
│         ├── 资源检查：目标资源是否在 Agent 可见范围？   │
│         └── 频率检查：操作频率是否超限？              │
│                                                      │
│  2. Permission Cache Invalidation                    │
│     ├── 角色变更事件 → 清除该 Agent 的所有权限缓存    │
│     ├── 权限矩阵更新 → 清除该角色的所有缓存          │
│     └── 团队成员移除 → 清除该成员的所有权限缓存       │
│                                                      │
│  3. Audit Log                                        │
│     └── 所有权限检查结果写入 audit_log（异步）        │
└──────────────────────────────────────────────────────┘
```

### 10.6 Topology Aggregator 架构

```
┌──────────────────────────────────────────────────────┐
│              Topology Aggregator                      │
│                                                      │
│  Event Collector (Redis Streams 消费者)               │
│    ├── task.assigned        → 记录 collaboration_event│
│    ├── task.handed_off      → 记录 collaboration_event│
│    ├── task.reviewed        → 记录 collaboration_event│
│    ├── task.escalated       → 记录 collaboration_event│
│    ├── message.mentioned    → 记录 collaboration_event│
│    └── pr.review_requested  → 记录 collaboration_event│
│                                                      │
│  Edge Aggregator (定时任务，每 5 分钟)                 │
│    ├── 读取 collaboration_events (过去 30 天)          │
│    ├── 按 (source, target, relation_type) 分组聚合    │
│    ├── 计算 interaction_count_7d / 30d / total        │
│    ├── 更新 collaboration_edges 表                    │
│    └── 如有显著变化 → 推送 WebSocket 事件              │
│                                                      │
│  Cache Layer                                         │
│    ├── Redis: topology:{team_id}:{period}             │
│    │   → 缓存完整拓扑数据 (TTL: 5 分钟)              │
│    └── 增量更新：新事件到达时只更新相关边的缓存         │
│                                                      │
│  输出                                                 │
│    ├── GET /topology → 从缓存返回完整拓扑图数据        │
│    ├── WebSocket → team:topology_updated 推送增量变更  │
│    └── WebSocket → team:collaboration_event 推送实时事件│
└──────────────────────────────────────────────────────┘
```

### 10.7 Agent 状态监控架构

```
┌──────────────────────┐       heartbeat (30s)       ┌──────────────────────┐
│  Agent Runtime       │ ─────────────────────────── │  Status Monitor      │
│  (Module 5)          │                             │  (Backend Worker)    │
│                      │       status report         │                      │
│  - 发送心跳          │ ─────────────────────────── │  1. 接收心跳         │
│  - 上报状态变更      │                             │  2. 更新 Redis status│
│  - 上报错误          │                             │  3. 更新 PostgreSQL  │
│                      │                             │  4. 推送 WebSocket   │
└──────────────────────┘                             └──────────┬───────────┘
                                                               │
                                                     ┌─────────┴──────────┐
                                                     │  Timeout Detector  │
                                                     │  (定时任务, 60s)   │
                                                     │                    │
                                                     │  检查所有 online    │
                                                     │  Agent 的最后心跳  │
                                                     │  > 90s → 标记      │
                                                     │    offline/error   │
                                                     └────────────────────┘

Redis 状态缓存:
  Key: agent_status:{agent_id}
  Value: {
    status: "online",
    current_task_id: "task_xyz",
    last_heartbeat: "2026-04-20T09:59:30Z",
    uptime: 174180
  }
  TTL: 无（由 Timeout Detector 管理）
```

### 10.8 性能目标

| 指标 | 目标 |
|------|------|
| 团队成员列表加载（20 成员） | < 200ms |
| 成员卡片渲染（含状态） | < 100ms |
| Agent 状态变更推送延迟 | < 500ms |
| 权限检查（缓存命中） | < 5ms |
| 权限检查（缓存未命中） | < 50ms |
| 拓扑图数据查询（30 天窗口） | < 300ms |
| 拓扑图前端渲染（20 节点） | < 500ms |
| 拓扑图前端渲染（50 节点） | < 1s |
| 邀请链接响应时间 | < 200ms |
| WebSocket 连接数（团队频道） | > 2,000 |
| 协作事件写入吞吐 | > 500 events/s |

---

## 11. 模块集成

### 11.1 与 Module 1 (Chat 对话) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| 团队频道自动创建 | Team → Chat | 创建团队时自动创建对应的 Chat 频道，成员自动加入 |
| 成员同步 | Team → Chat | 团队成员变更时自动更新 Chat 频道成员列表 |
| Agent 消息权限 | Team → Chat | Chat 模块检查 Agent 的团队角色决定其发消息权限（观察者不能发消息） |
| @提及协作记录 | Chat → Team | Chat 中的 @提及事件写入 collaboration_events 表，供拓扑图聚合 |
| 团队通知推送 | Team → Chat | 成员加入/离开、Agent 状态异常等通知推送到团队 Chat 频道 |

```yaml
# Team → Chat 事件示例
event: team.member_joined
payload:
  team_id: "team_abc123"
  team_name: "产品开发团队"
  member: { display_name: "代码助手", type: "agent", role: "executor" }
  channel_id: "ch_team_abc123"
  message: "代码助手（Agent 执行者）加入了产品开发团队"
```

### 11.2 与 Module 2 (Tasks 任务) 集成

| 集成点 | 说明 |
|--------|------|
| 任务分配权限 | 任务分配时检查 Agent 角色——只有执行者角色的 Agent 可被分配任务，观察者不可 |
| 任务审核权限 | 任务审核时检查角色——只有审核者角色的 Agent 可审核任务 |
| 任务创建权限 | 只有协调者角色的 Agent 可以自主创建任务 |
| 协作事件采集 | 任务分配、交接、审核事件自动写入 collaboration_events 表 |
| 指派人范围 | 创建任务选择指派人时，基于团队成员列表筛选可用的执行者 |

**数据流：**

```
Module 2 (Task) 事件                         Module 4 (Team) 处理
────────────────────                        ────────────────────────
task.assigned (agent, executor)    ────→    权限检查（executor 可被分配 ✓）
                                            写入 collaboration_event
                                            更新 collaboration_edges

task.assigned (agent, observer)    ────→    权限检查（observer 不可被分配 ✗）
                                            返回 403

task.reviewed (agent, reviewer)    ────→    权限检查（reviewer 可审核 ✓）
                                            写入 collaboration_event

task.created (agent, coordinator)  ────→    权限检查（coordinator 可创建 ✓）
                                            写入 collaboration_event

task.created (agent, executor)     ────→    权限检查（executor 不可创建 ✗）
                                            返回 403
```

### 11.3 与 Module 3 (Projects 项目) 集成

| 集成点 | 说明 |
|--------|------|
| 项目团队关联 | 创建项目时可选择关联团队，项目成员自动从团队成员同步（P2） |
| Agent 项目角色 | 项目级可覆盖 Agent 的团队角色（P2：如团队中是执行者，项目中是审核者） |
| Sprint 权限 | 只有协调者角色的 Agent 可创建 Sprint 和管理 Sprint 任务 |
| 项目协作数据 | 项目内的协作活动也纳入团队拓扑图的数据源 |

### 11.4 与 Module 5 (Agent 管理) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| Agent 市场 | Agent → Team | 从 Agent 市场浏览和选择 Agent 添加到团队 |
| Agent 核心数据 | Agent → Team | 团队成员展示中，Agent 的名称、模型、能力标签等数据从 Module 5 的 agents 表获取 |
| Agent 状态同步 | Agent → Team | Module 5 的 Agent 运行时状态同步到 agent_team_status 表 |
| Agent 生命周期 | Agent → Team | Agent 被全局停用/删除时，自动从所有团队中移除 |
| Agent 健康监控 | Agent → Team | Agent 健康指标（心跳、错误率）实时同步到团队视图 |

```yaml
# Module 5 → Module 4 状态同步事件
event: agent.status_changed
payload:
  agent_id: "agent_codebot"
  old_status: "online"
  new_status: "busy"
  details:
    task_id: "task_xyz"
    task_title: "实现用户认证模块"

→ Module 4 处理：
  1. 更新 agent_team_status 表
  2. 更新 Redis agent_status:{agent_codebot}
  3. 推送 WebSocket: team:agent_status_changed
  4. 前端成员卡片状态指示器实时变色（绿→黄）
```

### 11.5 集成数据流全景

```
Chat (M1)              Tasks (M2)           Team (M4)              Agent (M5)
  │                      │                     │                      │
  │ @提及事件             │                     │                      │
  ├────────────────────────────────────────→   │ collaboration_event   │
  │                      │                     │ 拓扑图更新            │
  │                      │                     │                      │
  │                      │ 任务分配给 Agent     │                      │
  │                      ├──────────────────→  │ 权限检查              │
  │                      │                     │ collaboration_event   │
  │                      │                     │                      │
  │                      │ Agent 完成任务      │                      │
  │                      ├──────────────────→  │ collaboration_event   │
  │                      │                     │ 更新统计              │
  │                      │                     │                      │
  │ 团队频道通知          │                     │                      │
  │ ←──────────────────────────────────────── │ 成员加入/离开          │
  │                      │                     │                      │
  │                      │                     │ Agent 状态查询        │
  │                      │                     ├──────────────────→   │
  │                      │                     │ ←────────────────── │ 心跳/状态
  │                      │                     │                      │
  │                      │                     │ Agent 从市场添加      │
  │                      │                     ├──────────────────→   │
  │                      │                     │ ←────────────────── │ Agent 数据
```

---

## 12. 测试用例

### 12.1 团队 CRUD

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-TM-01 | 创建团队（最小） | 仅填写名称，点击创建 | 团队创建成功，default_human_role=member, default_agent_role=executor |
| TC-TM-02 | 创建团队（完整） | 填写名称+描述+图标+初始成员 | 团队创建成功，成员正确关联，自动创建 Chat 频道 |
| TC-TM-03 | 编辑团队名称 | 修改团队名称 | 实时保存，所有引用处同步更新 |
| TC-TM-04 | 归档团队 | 管理员点击归档 | 显示确认框，确认后团队标记为 archived，成员保留但不可操作 |
| TC-TM-05 | 删除团队 | 管理员删除团队 | 二次确认，删除后所有成员记录级联删除，Chat 频道归档 |
| TC-TM-06 | 非管理员操作 | 普通成员尝试归档/删除 | 操作被拒绝，返回 403 |
| TC-TM-07 | 团队名称重复 | 在同一 Workspace 创建同名团队 | 提示"团队名称已存在" |

### 12.2 人类成员管理

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-HM-01 | 邮件邀请 | 输入邮箱发送邀请 | 邮件发出，邀请列表显示 pending 状态 |
| TC-HM-02 | 链接邀请 | 生成邀请链接 | 链接生成，可复制分享 |
| TC-HM-03 | 接受邀请（邮件） | 点击邮件中的链接 | 加入团队，状态变为 accepted |
| TC-HM-04 | 接受邀请（链接） | 打开邀请链接 | 加入团队，use_count 增加 |
| TC-HM-05 | 链接使用次数耗尽 | 达到 max_uses 后再次使用 | 提示"邀请链接已失效" |
| TC-HM-06 | 邀请过期 | 超过有效期后使用 | 提示"邀请已过期" |
| TC-HM-07 | 撤销邀请 | 管理员撤销未接受的邀请 | 状态变为 revoked，链接/邮件链接失效 |
| TC-HM-08 | 设置成员角色 | 管理员修改成员角色为审核者 | 角色即时生效，权限更新 |
| TC-HM-09 | 移除成员（无任务） | 移除无未完成任务的成员 | 直接移除成功 |
| TC-HM-10 | 移除成员（有任务） | 移除有未完成任务的成员 | 提示任务数量，可选择重新分配 |
| TC-HM-11 | 最后一个管理员 | 尝试移除唯一管理员 | 拒绝操作，提示"团队必须至少有一个管理员" |

### 12.3 Agent 成员管理

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-AM-01 | 从市场添加 Agent | 浏览市场 → 选择 → 设置角色 → 添加 | Agent 出现在成员列表，角色正确 |
| TC-AM-02 | 设置 Agent 为执行者 | 选择执行者角色 | 角色标签显示"执行者"，权限矩阵生效 |
| TC-AM-03 | 设置 Agent 为审核者 | 选择审核者角色 | 角色标签显示"审核者"，只能审核不能执行 |
| TC-AM-04 | 设置 Agent 为协调者 | 选择协调者角色 | 角色标签显示"协调者"，可创建任务和分配 |
| TC-AM-05 | 设置 Agent 为观察者 | 选择观察者角色 | 角色标签显示"观察者"，只读权限 |
| TC-AM-06 | 变更 Agent 角色 | 从执行者变为审核者 | 检查进行中任务 → 确认 → 角色变更 → 权限更新 |
| TC-AM-07 | 移除 Agent（无执行中任务） | 移除空闲 Agent | 直接移除成功 |
| TC-AM-08 | 移除 Agent（有执行中任务） | 移除正在执行任务的 Agent | 提示"Agent 正在执行 N 个任务"，可选择等待或强制移除 |
| TC-AM-09 | 添加同一 Agent 两次 | 尝试重复添加 | 提示"该 Agent 已在团队中" |
| TC-AM-10 | Agent 全局停用 | Module 5 停用 Agent | 自动从所有团队移除，成员列表更新 |

### 12.4 成员卡片展示

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-MC-01 | 人类卡片展示 | 打开团队页面 | 人类卡片正确显示：头像、名称、职位、角色、在线状态 |
| TC-MC-02 | Agent 卡片展示 | 打开团队页面 | Agent 卡片正确显示：图标、名称、模型、能力标签、角色、状态 |
| TC-MC-03 | 状态实时更新 | Agent 状态变更（online→busy） | 状态指示器颜色在 <1s 内变化（绿→黄） |
| TC-MC-04 | 分组显示 | 查看成员列表 | 人类成员区域在上，Agent 成员区域在下，各区域内按角色排序 |
| TC-MC-05 | 角色标签颜色 | 查看角色标签 | 管理员紫色、成员蓝色、审核者橙色、执行者绿色、协调者紫色、观察者灰色 |
| TC-MC-06 | Agent 成功率显示 | 查看 Agent 卡片 | 显示任务成功率百分比 |
| TC-MC-07 | 空状态 | 新建团队无成员 | 显示空状态引导："添加团队成员或 Agent" |
| TC-MC-08 | 响应式布局 | 缩小浏览器窗口 | 卡片从 4 列变为 2 列再变为 1 列 |

### 12.5 HxA 协作拓扑图

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-TP-01 | 拓扑图渲染 | 打开团队拓扑页 | 力导向图正确渲染，节点和边位置合理 |
| TC-TP-02 | 节点样式 | 查看拓扑图 | 人类节点蓝色边框，Agent 节点绿色边框，大小反映活跃度 |
| TC-TP-03 | 边样式 | 查看拓扑图 | 委派蓝色实线、交接绿色实线、审核橙色虚线、上报红色虚线 |
| TC-TP-04 | 节点点击 | 点击一个节点 | 高亮该节点的所有相连边和邻居节点，展示详情面板 |
| TC-TP-05 | 边悬停 | 鼠标悬停边 | 显示 Tooltip：关系类型、交互次数、最近交互时间 |
| TC-TP-06 | 缩放 | 鼠标滚轮缩放 | 拓扑图平滑缩放 |
| TC-TP-07 | 拖拽节点 | 拖拽一个节点 | 节点跟随鼠标，其他节点通过力模拟重新布局 |
| TC-TP-08 | 时间范围切换 | 从"30 天"切换到"7 天" | 拓扑图重新渲染，边的粗细和节点大小根据新时间范围调整 |
| TC-TP-09 | 关系类型筛选 | 选择"仅委派" | 只显示委派类型的边，其他边隐藏 |
| TC-TP-10 | 实时更新 | 新的协作事件产生 | 拓扑图边的粗细在下次聚合后更新 |
| TC-TP-11 | 空拓扑 | 新团队无协作数据 | 显示所有节点但无边，提示"开始协作后拓扑图将自动生成" |
| TC-TP-12 | 大团队渲染 | 50 个节点的团队 | 拓扑图在 <1s 内完成渲染，交互流畅 |

### 12.6 Agent 角色权限

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-RP-01 | 执行者接收任务 | 给执行者角色的 Agent 分配任务 | 权限检查通过，任务分配成功 |
| TC-RP-02 | 观察者拒绝分配 | 给观察者角色的 Agent 分配任务 | 权限检查拒绝，返回 403 |
| TC-RP-03 | 审核者 Review | 审核者角色 Agent 审核任务 | 权限检查通过，审核记录生成 |
| TC-RP-04 | 执行者不可 Review | 执行者角色 Agent 尝试审核任务 | 权限检查拒绝，返回 403 |
| TC-RP-05 | 协调者创建任务 | 协调者角色 Agent 创建任务 | 权限检查通过，任务创建成功 |
| TC-RP-06 | 执行者不可创建 | 执行者角色 Agent 尝试创建任务 | 权限检查拒绝，返回 403 |
| TC-RP-07 | 观察者只读 | 观察者查看任务/项目 | 权限检查通过（只读） |
| TC-RP-08 | 观察者不可发消息 | 观察者尝试在频道发消息 | 权限检查拒绝 |
| TC-RP-09 | 权限缓存命中 | 同一 Agent 连续权限检查 | 第二次 < 5ms（缓存命中） |
| TC-RP-10 | 角色变更后权限更新 | 变更 Agent 角色后立即操作 | 新角色权限立即生效，旧角色权限失效 |

### 12.7 邀请流程

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-IV-01 | 邮件邀请发送 | 输入邮箱 → 发送 | 邮件到达收件箱，含团队名称和加入链接 |
| TC-IV-02 | 邮件邀请接受 | 收件人点击链接 | 登录/注册后直接加入团队 |
| TC-IV-03 | 链接邀请创建 | 生成链接（7天有效/10次） | 链接可用，显示在邀请列表 |
| TC-IV-04 | 链接邀请使用 | 第三方用户打开链接 | 登录/注册后加入团队 |
| TC-IV-05 | 邀请过期处理 | 超时邀请被点击 | 显示过期提示页面 |
| TC-IV-06 | 已注册用户邀请 | 邀请已注册但未加入 Workspace 的用户 | 自动加入 Workspace + 加入团队 |

### 12.8 性能测试

| 指标 | 测试方法 | 目标 |
|------|---------|------|
| 成员列表加载 | API 响应时间 + Lighthouse | < 200ms (API) + FCP < 800ms |
| 拓扑图渲染 | Performance timing | 20 节点 < 500ms, 50 节点 < 1s |
| Agent 状态更新延迟 | 端到端计时 | 状态变更 → 前端更新 < 500ms |
| 权限检查性能 | k6 负载测试 | P99 < 10ms (缓存命中) |
| 协作事件写入 | k6 负载测试 | > 500 events/s |
| WebSocket 广播延迟 | 端到端计时 | < 200ms（团队内 50 成员） |
| 邀请链接响应 | API 响应时间 | < 200ms |
| 并发成员操作 | 多用户同时操作 | 无数据不一致 |

---

## 13. 成功指标

### 13.1 核心指标

| 指标 | MVP (2 月后) | 成熟期 (10 月后) | 说明 |
|------|-------------|-----------------|------|
| 活跃团队数 | 10 | 200 | status=active 的团队数 |
| 日均团队页面访问数 | 30 | 800 | 打开团队详情页的次数 |
| 平均团队成员数 | 4 | 10 | 含人类和 Agent |
| 团队中 Agent 成员占比 | > 20% | > 40% | Agent 成员 / 总成员 |
| Agent 角色分布均衡度 | 4 种角色均有使用 | 每种角色 > 10% 占比 | 避免全部是执行者 |

### 13.2 HxA 协作指标

| 指标 | MVP | 成熟期 | 说明 |
|------|-----|--------|------|
| 协作边覆盖率 | > 50% | > 80% | 有协作关系的成员对 / 所有成员对 |
| 拓扑图查看频率 | 2 次/周 | 5+ 次/周 | 每周拓扑图页面访问次数 |
| 平均每成员协作边数 | 2 | 5 | 每个成员平均有多少协作关系 |
| Human→Agent 委派次数 | 20/周 | 200/周 | 每周任务委派次数 |
| Agent→Agent 交接次数 | 5/周 | 100/周 | 每周任务交接次数 |
| Agent→Human 上报次数 | 3/周 | 30/周 | 每周上报次数 |

### 13.3 Agent 治理指标

| 指标 | MVP | 成熟期 | 说明 |
|------|-----|--------|------|
| Agent 角色设置率 | > 80% | > 95% | 设置了非默认角色的 Agent / 总 Agent |
| Agent 权限违规次数 | < 5/天 | < 1/天 | Agent 操作被权限拒绝的次数 |
| Agent 状态异常平均恢复时间 | < 30 分钟 | < 5 分钟 | 从 error 状态到 online 的时间 |
| Agent 在线率 | > 90% | > 99% | Agent online 时间 / 总时间 |

### 13.4 体验指标

| 指标 | 目标 | 说明 |
|------|------|------|
| 成员列表加载时间 P99 | < 400ms | 含卡片渲染 |
| Agent 状态更新延迟 P99 | < 1s | 状态变更到前端更新 |
| 拓扑图渲染时间 P95 | < 1s | 20 节点 |
| 邀请到加入时间 | < 30 秒 | 从点击链接到加入团队 |
| 权限检查 P99 | < 10ms | 缓存命中 |
| 用户在团队页面停留时间 | > 2 分钟 | 说明用户在使用成员卡片/拓扑图 |

---

## 14. 风险与缓解

### 14.1 技术风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **权限升级漏洞** — Agent 通过某种方式绕过角色权限检查，执行超出角色范围的操作 | 低 | 高 | Permission Engine 实现为独立中间件，所有 API 请求必须经过权限检查。默认拒绝策略（未明确允许的操作一律拒绝）。所有权限检查结果写入审计日志。定期安全审计 |
| **拓扑图性能** — 大团队（50+ 成员）的 D3.js 力导向图渲染性能下降，交互卡顿 | 中 | 中 | 渲染优化：Canvas 渲染替代 SVG（节点数 > 30 时自动切换）。数据优化：只加载交互频次 Top N 的边。分层渲染：先渲染节点，再逐步渲染边。Web Worker：力模拟计算放到 Worker 中 |
| **Agent 状态同步延迟** — Agent 心跳丢失或延迟导致状态显示不准确 | 中 | 低 | 心跳间隔 30 秒，超时判定 90 秒（3 个心跳周期）。乐观更新：Agent 上报状态变更时立即推送，不等心跳。离线后重新上线时全量同步状态。状态页面显示"最后心跳时间"让用户判断数据新鲜度 |
| **协作事件丢失** — 高并发下 Redis Stream 消费者来不及处理所有协作事件 | 低 | 低 | 消费者组 (Consumer Group) 确保每个事件至少被处理一次。积压监控告警。协作边使用增量聚合，丢失少量事件只影响统计精度不影响功能正确性 |
| **多态成员查询性能** — 成员列表需要 join users 和 agents 两张表，查询复杂度高 | 中 | 低 | team_members 表冗余存储 display_name 和 avatar_url（缓存字段），列表查询无需 join。详情查询（点击卡片）才去 join 获取完整数据。Member 变更时异步更新冗余字段 |
| **权限缓存不一致** — Redis 权限缓存与数据库不同步 | 低 | 中 | 角色变更时同步清除缓存。缓存 TTL 5 分钟兜底。权限拒绝时主动刷新缓存并重试一次（避免因缓存陈旧误拒） |

### 14.2 产品风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **Agent 角色混淆** — 用户不理解四种 Agent 角色的区别，随意设置或全部设为执行者 | 高 | 中 | 角色选择器带详细说明（Tooltip + 示例场景）。添加 Agent 时推荐角色（基于 Agent 的能力标签自动推荐）。入门引导（Onboarding Tour）解释每种角色的价值 |
| **拓扑图认知负担** — 协作拓扑图对非技术用户来说太抽象，看不懂 | 中 | 低 | 提供简化视图（仅显示直接协作关系，隐藏二级关系）。图例常驻显示。Hover 交互提供文字解释。P2 考虑替代可视化（如矩阵热力图，对非技术用户更直观） |
| **多团队使用率低** — 小公司只需要一个团队，多团队功能利用率低 | 高 | 低 | 多团队是 P2 功能，MVP 不投入。每个 Workspace 自动创建"默认团队"，小团队不需要创建额外团队。大团队场景做深用户调研后再迭代 |
| **Agent 治理过度** — 权限矩阵过于严格，Agent 频繁被权限拒绝，影响自动化效率 | 中 | 中 | 权限拒绝时显示清晰的错误消息和建议操作（"该 Agent 是观察者角色，无法创建任务。需要将角色变更为协调者"）。管理员可在团队设置中调整权限严格程度（P2：自定义权限覆盖） |

### 14.3 安全风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **Agent 冒充人类成员** — Agent 伪造 JWT Token 中的 member_type 声称自己是人类 | 低 | 高 | JWT Token 中的 member_type 由认证服务签发，不可篡改。API Gateway 的 RBAC 中间件强制从 Token 中提取类型，不接受请求体中的自声明。Agent 和人类使用不同的 Token 签发流程 |
| **邀请链接泄露** — 邀请链接被分享到公开渠道，非目标用户加入团队 | 中 | 中 | 邀请链接设有效期和使用次数上限。邀请列表实时监控使用情况。管理员可随时撤销邀请。新成员加入时通知管理员 |
| **Agent 权限越权** — Agent 利用 API 漏洞绕过权限检查 | 低 | 高 | 所有 API 端点必须经过 Permission Engine 中间件。Agent API Key 和人类 JWT 使用不同的认证路径。定期渗透测试。Agent 操作频率限制（Rate Limiting by Agent Role） |

---

## 15. 排期建议

### 15.1 为什么是 3 周？

Module 4（Team）P0 范围的工期估算为 ~3 周（1 前端 + 1 后端），原因如下：

1. **团队 CRUD 逻辑简单**：团队 CRUD 只有 4 个核心字段（名称、描述、图标、状态），远比 Module 2 的任务或 Module 3 的项目简单
2. **成员管理是标准 CRUD**：添加/移除/修改角色是典型的 CRUD 操作，没有复杂的业务逻辑
3. **成员卡片是纯展示**：卡片组件的核心是数据展示 + 状态指示器，不涉及复杂交互（拖拽、排序等）
4. **P0 不含拓扑图**：HxA 协作拓扑图是 P1 功能，MVP 只需要成员列表和邀请流程
5. **复用已有基础设施**：WebSocket、Event Bus、Auth 中间件全部复用 Module 1-3 已搭建的基础设施

### 15.2 Sprint 规划（P0 范围约 3 周）

#### Sprint 1: 团队 CRUD 与成员管理（第 1 周）

**做什么：** 搭建团队模块的骨架——数据库表、团队和成员的 CRUD API、前端成员卡片网格。

**后端（1 人周）：**
- 数据库 Schema 创建（teams, team_members, agent_role_permissions, team_activities）
- Team CRUD API（创建/读取/更新/归档/删除）
- Team Members API（添加/移除/修改角色——含人类和 Agent）
- Agent 角色权限矩阵初始化（agent_role_permissions 表种子数据）
- Permission Engine 核心（中间件 + Redis 缓存）

**前端（1 人周）：**
- 团队详情页面框架
- 成员卡片组件（MemberCard，多态渲染）
- 成员卡片网格（MemberCardGrid，分 Human/Agent 两区域）
- 状态指示器组件（StatusIndicator）
- 角色标签组件（RoleBadge）
- 角色选择器组件（AgentRoleSelector，带角色说明 Tooltip）

**难点：** 多态成员模型的数据库设计和 API 设计，确保人类和 Agent 共用同一套成员接口。Permission Engine 中间件的实现要覆盖所有 Agent 操作场景。

#### Sprint 2: 邀请流程与 Agent 状态（第 2 周）

**做什么：** 实现邀请成员加入团队的完整流程，以及 Agent 实时状态监控。

**后端（1 人周）：**
- 邀请系统 API（邮件邀请、链接邀请、接受邀请、撤销邀请）
- 邮件发送服务集成（邀请邮件模板 + 发送）
- Agent 状态监控（agent_team_status 表 + 心跳接收 + 超时检测）
- WebSocket 团队频道（team:subscribe / team:member_joined / team:agent_status_changed）
- 团队活动记录（team_activities 表写入）

**前端（1 人周）：**
- 邀请弹窗（InviteModal：邮件邀请 Tab + 链接邀请 Tab）
- 邀请列表展示（待接受/已接受/已过期）
- 接受邀请页面（InviteAcceptPage）
- Agent 状态实时更新（WebSocket 消费 + 卡片状态指示器刷新）
- 团队设置页面（基础设置）
- 成员详情面板（MemberDetailPanel，Drawer 形式）

**难点：** 邀请邮件的发送和模板设计。Agent 状态的实时同步（WebSocket + Redis pub/sub）。

#### Sprint 3: 权限集成与联调（第 3 周）

**做什么：** 将 Permission Engine 集成到 Module 1-3 的 API 中，实现 Agent 角色权限的跨模块生效。全流程联调。

**后端（1 人周）：**
- Permission Engine 集成到 Module 2 API（任务分配、创建、审核的权限检查）
- Permission Engine 集成到 Module 1 API（消息发送权限按角色控制）
- Permission Engine 集成到 Module 3 API（Sprint 管理权限按角色控制）
- 协作事件采集（collaboration_events 写入——监听 Module 1/2/3 事件）
- 团队统计缓存更新（human_count, agent_count, 成员的 task 统计）

**前端（1 人周）：**
- 前端权限感知（根据当前用户/Agent 角色动态显示/隐藏操作按钮）
- Agent 市场浏览器集成（嵌入 Module 5 的 Agent 列表）
- 团队与 Chat 频道联动（创建团队自动创建频道）
- 全流程联调 + Bug 修复
- 空状态和错误状态设计

**难点：** 跨模块权限集成需要和 Module 1/2/3 团队协调 API 变更。协作事件采集的事件监听覆盖面需要全面测试。

### 15.3 P1 功能排期（约 2 周，P0 完成后）

#### Sprint 4-5: HxA 协作拓扑图（第 4-5 周）

**后端（1 人周）：**
- collaboration_edges 表聚合 Worker（定时任务）
- Topology API（GET /topology，支持时间范围和关系类型筛选）
- 协作统计 API
- 拓扑数据 Redis 缓存
- WebSocket 拓扑增量更新推送

**前端（1 人周）：**
- D3.js 力导向图组件（TopologyGraph）
- 节点和边的交互（点击高亮、Hover Tooltip、拖拽、缩放）
- 控制面板（时间范围筛选、关系类型筛选）
- 图例组件
- 成员详情面板中的协作历史时间线

### 15.4 P2 功能排期（约 2 周，P1 完成后）

#### Sprint 6-7: 多团队管理 + 权限模板（第 6-7 周）

- 多团队列表视图
- 团队创建/编辑/归档
- 同一成员多团队支持
- 团队与项目（Module 3）关联
- 权限模板系统
- 团队级 Agent 权限覆盖

### 15.5 里程碑

| 里程碑 | 时间 | 关键能力 | 对应 Sprint |
|--------|------|---------|------------|
| **M1: Team Members** | Week 1 | 团队 CRUD + 成员管理 + 卡片展示 + 权限引擎 | Sprint 1 |
| **M2: Invite & Status** | Week 2 | 邀请流程 + Agent 实时状态 + WebSocket | Sprint 2 |
| **M3: Permission Integration** | Week 3 | 跨模块权限生效 + 协作事件采集 + 联调 | Sprint 3 |
| **M4: HxA Topology** | Week 5 | 协作拓扑图 + 交互 + 协作统计 | Sprint 4-5 |
| **M5: Multi-Team** | Week 7 | 多团队管理 + 权限模板 + 项目关联 | Sprint 6-7 |

### 15.6 团队配置

| 角色 | 人数 | 职责 |
|------|------|------|
| 前端工程师 | 1 | 成员卡片 UI + 状态指示器 + 邀请流程 + 拓扑图（D3.js）+ 权限感知 UI |
| 后端工程师 | 1 | Team Service + Permission Engine + Agent Status Monitor + Topology Aggregator + 跨模块集成 |

**注意：** 后端工作量比 Module 3 多（Module 3 后端 0.5 人），因为 Permission Engine 是一个全新的横切关注点，需要集成到 Module 1-3 的所有 API 中。这是 Module 4 的核心技术投入。

### 15.7 依赖关系

```
Module 1 (Chat)    ──→  Module 4 依赖 M1 的 Chat 频道创建 API
Module 2 (Tasks)   ──→  Module 4 依赖 M2 的任务分配/审核事件
Module 3 (Projects) ──→  Module 4 依赖 M3 的项目成员模型参考
Module 5 (Agents)  ──→  Module 4 强依赖 M5 的 Agent 数据和状态 API

Module 4 输出：
  ├── Permission Engine → M1/M2/M3 集成（Agent 操作权限检查）
  ├── Team Members API → M2/M3 使用（指派人范围限定）
  └── collaboration_events → 拓扑图数据源
```

**关键依赖：**
- Module 5（Agent 管理）的 agents 表和状态 API 是前置条件。如果 Module 5 未就绪，Module 4 的 Agent 相关功能需要使用 Mock 数据开发
- Permission Engine 是 Module 4 的核心输出，需要 Module 1/2/3 团队配合集成。建议在 Sprint 1 完成 Permission Engine 核心后立即开始协调集成工作

---

> **文档结束。** 本 PRD 由 Zylos AI Agent 在 Stephanie 的产品指导下撰写。如有调整需求，请直接反馈。
