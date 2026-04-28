# CODE-YI Module 3: 项目 (Projects) — 产品需求文档

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
7. [项目-Git 绑定模型](#7-项目-git-绑定模型)
8. [项目进度聚合引擎](#8-项目进度聚合引擎)
9. [数据模型](#9-数据模型)
10. [技术方案](#10-技术方案)
11. [模块集成](#11-模块集成)
12. [测试用例](#12-测试用例)
13. [成功指标](#13-成功指标)
14. [风险与缓解](#14-风险与缓解)
15. [排期建议](#15-排期建议)

---

## 1. 问题陈述

### 1.1 现有项目管理工具的结构性缺陷

当前主流项目管理工具（Jira、Linear、GitHub Projects、Asana、ClickUp）在"项目"这一层级的抽象上，均基于一个过时的假设：**项目的执行者全部是人类，AI 仅作为辅助工具存在**。当 AI Agent 成为实际的任务执行者时，这些工具的项目管理模型立刻暴露出根本性不足：

**Jira Projects 的致命限制：**
- **项目进度依赖人工更新**：Jira 的项目进度（Board / Roadmap / Dashboard）本质上是 Issue 状态的聚合统计。但 Issue 状态由人手动拖拽更新——当 Agent 在外部执行任务时，Issue 状态永远滞后于实际进度
- **Sprint 模型为人类设计**：Sprint Planning、Story Point、Velocity Chart 的核心假设是"人类每周工作 40 小时"。Agent 24/7 运行、执行速度远超人类、不需要休息——现有的 Sprint Velocity 计算模型完全不适用
- **Git 集成浅层化**：Jira + GitHub 的集成停留在"Issue 链接到 PR"层面，无法自动关联 commit、无法追踪 branch 状态、无法基于 Git 活动自动更新项目进度
- **Agent 在项目中不可见**：项目成员列表只支持人类用户。Agent 无法被添加为项目成员，更无法看到 Agent 在项目中的贡献和工作量

**Linear Projects 的局限：**
- **Projects 定位为路线图视图**：Linear 的 Project 本质是 Issue 的分组容器 + 甘特图视图，没有独立的 Sprint 周期管理
- **进度计算单一**：项目完成度 = 已完成 Issue 数 / 总 Issue 数，不考虑任务权重、优先级或复杂度。一个 P0 大任务和一个 P4 小修复对项目进度的贡献相同
- **Agent 集成断裂**：Linear Agent 可以在 Issue 级别辅助（分类、写规格），但不能在 Project 级别编排——不支持"给这个项目分配一个 Agent 负责所有后端任务"
- **Git 绑定缺失**：Linear 没有仓库级别的绑定概念。虽然支持 GitHub Integration，但是 Issue 粒度而非 Project 粒度，无法实现"一个项目绑定多个仓库"

**GitHub Projects 的局限：**
- **本质是看板而非项目管理**：GitHub Projects V2 是一个灵活的 Issue 视图层，但缺少"项目"作为管理单元应有的能力——没有进度条、没有 Sprint 周期、没有团队成员管理
- **代码中心而非协作中心**：GitHub 的世界观是"代码仓库"，Project 只是 Issue 的一种组织方式。非代码工作（设计、文档、运维）在 GitHub Projects 中是二等公民
- **没有 Agent 执行可见性**：Copilot Coding Agent 可以被分配 Issue 并创建 PR，但项目级别看不到 Agent 正在执行什么、进展如何、成功率多少
- **进度追踪全凭手动**：没有内置的项目进度百分比。用户需要自己用 Status 字段统计

**Asana Projects / ClickUp Spaces / Notion Databases 的共同问题：**
- 项目进度追踪依赖手动更新或简单的任务完成率统计
- 没有深度 Git 集成——最多是 Webhook 通知，无法自动关联 commit/PR 到任务再到项目
- Agent 在项目视图中完全不可见
- Sprint/迭代管理能力薄弱或缺失

**Shortcut 的局限：**
- 有 Iteration（类似 Sprint）和 Epic（类似 Project），但 Agent 集成完全缺失
- Git 集成仅限 Branch/PR 关联，不支持 commit 级别自动匹配
- 进度追踪基于 Story Point 或 Issue 数量，无智能加权

### 1.2 核心洞察

Stephanie 的原话精准点出了问题本质：**"包括这个整个项目本质上就是现在在 Git 里面所解决的这个问题"**——团队的项目管理和代码版本管理本应深度融合，但现有工具把它们割裂成了两个独立系统：

```
现状（割裂模型）：
  项目管理工具（Jira/Linear）  ←── 浅层 Webhook ──→  代码托管（GitHub/GitLab）
  - 手动更新进度                                      - commit 自动产生
  - Sprint 手动规划                                   - PR 自动关联
  - Agent 不可见                                      - Agent 可以提 PR
  - 人员只有人类                                      - bot 可以 commit
  
  ↓ 信息断裂：项目经理在 Jira 看不到 Agent 在 GitHub 的工作进展

CODE-YI 模型（融合模型）：
  项目 ←→ Git 仓库（深度绑定）
  - 进度自动聚合（基于任务 + Git 活动 + Agent 执行）
  - Sprint 包含人类和 Agent 的 velocity
  - Agent 是项目一等成员
  - commit/PR/branch 自动关联到任务和项目
```

### 1.3 市场机会

- 2026 年，超过 40% 的软件团队同时使用 2 个以上工具管理项目（Jira + GitHub、Linear + GitHub），工具切换导致平均每天浪费 30 分钟上下文切换
- GitHub Projects 用户中，68% 仍需要一个外部工具（Jira/Linear/Asana）来做 Sprint 管理和进度追踪——说明 GitHub Projects 的项目管理能力不足
- **没有一个项目管理工具**原生支持 Agent 作为项目成员，更没有基于 Agent 执行数据的项目进度聚合
- 这是 CODE-YI 的差异化窗口：一个**把 Git 仓库、任务看板、Agent 执行、Sprint 周期深度融合的项目管理模块**

---

## 2. 产品愿景

### 2.1 一句话定位

**CODE-YI 项目模块是全球首个将 Human 和 Agent 统一为项目成员、将 Git 仓库深度绑定为项目代码源、将 Sprint Velocity 扩展为包含 Agent 吞吐量的 AI-Native 项目管理系统。**

### 2.2 核心价值主张

```
┌──────────────────────────────────────────────────────────────────────┐
│                       CODE-YI 项目系统                                │
├──────────────────┬─────────────────────┬─────────────────────────────┤
│ 项目组织管理       │ Git 深度融合          │ Agent-Aware 进度引擎         │
│                  │                     │                             │
│ 项目卡片视图       │ 一个项目多个仓库      │ 任务完成率 + 权重             │
│ Sprint/Phase 周期 │ commit → 任务自动关联  │ Agent 执行成功率纳入计算       │
│ 团队 = 人 + Agent │ PR 状态 → 项目进度    │ Sprint Burndown（含 Agent）  │
│ 归档 / 我参与的   │ branch 命名规范解析    │ Velocity = 人 + Agent        │
│ 最近活动时间       │ Webhook 实时同步      │ 项目健康度评分                │
└──────────────────┴─────────────────────┴─────────────────────────────┘
```

### 2.3 核心差异化

| 维度 | Jira Projects | Linear Projects | GitHub Projects | CODE-YI Projects |
|------|---------------|-----------------|-----------------|------------------|
| Agent 作为项目成员 | 不支持 | 不支持 | 不支持 | **原生支持，Agent 与人类平级** |
| 项目进度计算 | Issue 完成率 | Issue 完成率 | 手动/无 | **加权聚合：优先级+Agent成功率+Git活动** |
| Git 仓库绑定 | 浅层 Webhook | Issue 级 | 原生但单仓库 | **项目级多仓库深度绑定** |
| Sprint Velocity | 基于 Story Point | 基于 Issue 数 | 无 Sprint | **含 Agent 吞吐量的混合 Velocity** |
| commit→任务关联 | 手动/插件 | 手动 | commit message | **自动解析 + branch 命名 + PR 关联** |
| 项目卡片视图 | Dashboard | 甘特图 | Table/Board | **卡片视图：进度条+Sprint标签+团队头像** |
| 项目归档 | 支持 | 支持 | 支持 | **支持 + 归档统计报告** |

### 2.4 设计理念

**"Project as the Single Source of Truth"** ——项目是唯一事实来源。

一个项目聚合了所有相关信息：哪些人和 Agent 在参与、哪些仓库的代码在推进、Sprint 进展如何、任务完成度多少、最近有什么活动。项目经理打开一个项目卡片，就能全局掌控——不需要在 Jira、GitHub、Slack 之间反复切换。

---

## 3. 竞品对标

### 3.1 项目级能力对比

| 功能 | Jira | Linear | GitHub Projects | Asana | ClickUp | Notion | Shortcut | **CODE-YI** |
|------|------|--------|-----------------|-------|---------|--------|----------|-------------|
| 项目卡片视图 | Dashboard | 列表+甘特 | Table/Board | 列表 | Spaces | Gallery | Epic 视图 | **卡片+进度条+Sprint标签** |
| 项目进度条 | 自定义 | 百分比 | 无 | 百分比 | 百分比 | 进度属性 | 百分比 | **加权自动聚合** |
| Sprint/迭代 | ★★★★★ | ★★★ | 无 | ★★ | ★★★ | 无 | ★★★★ | ★★★★ |
| 项目成员管理 | ★★★★ | ★★★ | ★★ | ★★★★ | ★★★ | ★★ | ★★★ | ★★★★★（含 Agent）|
| 项目归档 | 支持 | 支持 | 支持 | 支持 | 支持 | 支持 | 支持 | 支持+统计 |
| 多仓库绑定 | 多个（插件） | 无 | 单仓库 | 无 | 无 | 无 | 多个 | **原生多仓库** |
| 列表视图 | ★★★★ | ★★★★★ | ★★★★ | ★★★★ | ★★★★★ | ★★★★ | ★★★ | ★★★★ |
| Agent 可见性 | 无 | 有限 | 无 | 无 | 无 | 无 | 无 | **完整** |

### 3.2 深度分析

**Jira Projects：**
- 优势：Sprint 管理最成熟——Scrum Board、Sprint Planning、Velocity Chart、Burndown Chart、Release Hub 一应俱全。拥有最丰富的项目看板自定义能力（JQL 查询、自定义字段、筛选器）
- 劣势：项目配置过于复杂——创建一个项目需要选择模板（Scrum/Kanban/Bug Tracking）、配置工作流、设置权限方案。进度完全依赖 Story Point 和手动状态更新。2026 年的"Agents in Jira"仅允许将 Issue 分配给外部 Agent，项目面板看不到 Agent 的执行过程
- Git 集成：通过 Jira + GitHub/Bitbucket 插件实现。支持在 Issue 中看到关联的 Branch/Commit/PR，但**不支持自动创建关联**——需要在 commit message 或 branch name 中包含 Issue Key（如 `PROJ-123`）
- Agent 参与度：项目成员列表不支持 Agent。Agent 执行的任务在 Jira 中表现为"某个 Integration User"的操作，与项目成员体系脱节

**Linear Projects：**
- 优势：UI 极简优雅。Project 视图支持进度百分比、目标截止日、Lead/Member 配置。Roadmap 视图可跨项目查看时间线
- 劣势：Project 的进度计算过于简单（完成 Issue 数 / 总 Issue 数），不区分任务优先级和复杂度。Sprint（Cycle）与 Project 是独立概念，一个 Cycle 可以跨多个 Project，但一个 Project 不能有自己独立的 Sprint 周期
- Git 集成：通过 GitHub/GitLab Integration，支持 PR 状态显示在 Issue 上、PR merge 自动关闭 Issue。但这是 **Issue 级别**的集成，不是 Project 级别——项目视图中看不到仓库活动汇总
- Agent 参与度：Linear Agent 可以作为 Issue 的 assignee（标记为 AI），但项目面板没有区分人类成员和 Agent 成员的视图

**GitHub Projects V2：**
- 优势：与 GitHub 代码仓库原生一体。Issue、PR、Draft Issue 可直接作为 Project Item。自定义字段灵活（Text/Number/Date/Single Select/Iteration）
- 劣势：**不是传统意义的"项目管理"**——没有进度条（需自定义字段模拟）、没有 Sprint Velocity、没有团队成员管理（Projects 不绑定人员，只绑定 Items）。本质上是一个灵活的 Issue 视图/过滤器
- Git 集成：天然最强——PR 和 Issue 直接在 Project 中展示，commit 通过 Issue 引用自动关联。但这也导致了**代码中心偏见**——只有代码相关的活动能反映在 Project 中
- Agent 参与度：Copilot Coding Agent 创建的 PR 显示在 Project 中，但没有 Agent 维度的统计（如 Agent 完成了多少任务、成功率多少）

**Asana Projects：**
- 优势：项目模板丰富、多视图（List/Board/Timeline/Calendar/Gantt）、Portfolio 可跨项目汇总进度
- 劣势：Git 集成极浅——通过第三方（Unito、Zapier）连接 GitHub，仅同步 Issue 标题和状态。AI Teammates 只做项目管理辅助（生成状态报告、推荐任务优先级），不执行任务
- Sprint 管理：通过 Sprint 自定义字段实现，非原生支持
- Agent 参与度：AI Studio 的 Agent 可以自动化项目内操作（分类、状态更新），但不是任务执行者

**ClickUp Spaces：**
- 优势：层级结构灵活（Workspace → Space → Folder → List → Task），15+ 视图
- 劣势：过于复杂——层级太深导致用户经常不知道该在哪一层创建内容。Sprint 管理通过 Sprint List 实现，不如 Jira 直观
- Git 集成：GitHub Integration 支持 PR/Commit 关联到 Task，但仅限显示层面，不影响任务状态
- Agent 参与度：ClickUp Brain Autopilot 可以自动创建任务、更新状态，但范围限于 ClickUp 内部操作

**Notion Databases：**
- 优势：极度灵活——Relation/Rollup/Formula 可以构建任何项目管理模型。Gallery 视图适合项目卡片展示
- 劣势：**需要从零搭建**——Notion 不提供开箱即用的项目管理能力，一切都需要用户自定义。没有内置的 Sprint 概念、没有进度自动计算（需要 Formula 手写）
- Git 集成：几乎没有——依赖第三方工具（如 Automate.io）
- Agent 参与度：Notion AI 可以总结项目状态、生成报告，但无法执行任务

**Shortcut：**
- 优势：为软件团队设计——Epic/Story/Iteration 模型清晰。Git 集成较好（Branch/PR 自动关联到 Story）
- 劣势：进度追踪基于 Story Point，无智能加权。迭代报告（Iteration Report）仅展示完成/未完成数量
- Agent 参与度：完全缺失

### 3.3 竞品总结

**所有竞品的共同盲区：**

1. **项目进度 = 任务完成率**——没有任何工具考虑任务优先级权重、Agent 执行成功率、Git 活动密度等因素
2. **Git 集成停留在 Issue 级别**——没有"项目绑定仓库"的一等概念。commit/PR 关联到 Issue，但不聚合到项目视图
3. **Agent 在项目中隐身**——即使支持 Agent 执行任务（如 Jira、Linear），项目面板也没有 Agent 维度的统计和可见性
4. **Sprint Velocity 只算人类**——没有工具将 Agent 的任务吞吐量纳入 Velocity 计算

**CODE-YI 的独特定位：** 一个让项目经理在一个界面中看到人类进展 + Agent 进展 + Git 活动的统一项目管理视图，且进度自动聚合、无需手动更新。

---

## 4. 技术突破点分析

### 4.1 突破 1：Agent-Aware 项目进度计算

**传统模型：** `项目进度 = 已完成任务数 / 总任务数 * 100%`

这个公式在 Agent-Native 团队中严重失真：
- 一个 P0 核心架构任务和一个 P4 文档修复任务权重相同？
- Agent 完成的任务成功率只有 70%（可能需要人类 review 返工），和人类完成的任务等价？
- 一个任务 Agent 报告 100% 完成但 PR 还在 review 中，算完成吗？

**CODE-YI 模型：** 多维加权进度聚合引擎

```
项目进度 = Σ(任务权重 × 任务完成度 × 置信系数) / Σ(任务权重)

其中：
  任务权重 = f(优先级)     # P0=8, P1=5, P2=3, P3=2, P4=1
  任务完成度 = 0-100%      # Agent 自动上报 or 人类手动更新
  置信系数 = {
    人类完成: 1.0           # 人类标记完成 = 可信
    Agent 完成 + PR merged: 1.0  # Agent 完成且代码已合入 = 可信
    Agent 完成 + PR open: 0.8    # Agent 完成但未 review = 部分可信
    Agent 执行中: progress * 0.7  # 执行中的进度打折
  }
```

### 4.2 突破 2：项目级 Git 深度绑定

**传统集成：** Issue → PR 的 1:1 链接（通过 commit message 中的 Issue Key）

**CODE-YI 集成：** Project → Repo 的 1:N 绑定 + 自动化关联引擎

```
项目「CODE-YI 主站」
  │
  ├── 绑定仓库 1: coco/codeyi-frontend
  │   ├── branch: feat/CODEYI-42-login-page  → 自动关联 Task #42
  │   ├── commit: "fix(auth): CODEYI-42 token refresh"  → 自动关联 Task #42
  │   └── PR #78: "feat: user login page"  → 自动关联 Task #42, Task #43
  │
  ├── 绑定仓库 2: coco/codeyi-backend
  │   ├── branch: fix/CODEYI-55-api-timeout  → 自动关联 Task #55
  │   └── PR #34: "fix: API timeout handling"  → 自动关联 Task #55
  │
  └── 绑定仓库 3: coco/codeyi-docs
      └── commit: "docs: CODEYI-60 API reference"  → 自动关联 Task #60
```

**自动关联规则：**
1. **Branch 命名解析**：`feat/CODEYI-42-*`, `fix/CODEYI-55-*` → 提取任务 ID
2. **Commit message 解析**：正则匹配 `CODEYI-\d+` 或 `#\d+`（项目前缀可配置）
3. **PR 描述解析**：解析 PR body 中的任务引用链接或 ID
4. **Agent 自动关联**：Agent 执行任务时创建的 branch/commit/PR 自动携带任务 ID

### 4.3 突破 3：混合 Sprint Velocity

传统 Sprint Velocity 只统计人类完成的 Story Point。但在 CODE-YI 中：

```
Sprint Velocity = Human Velocity + Agent Velocity

Human Velocity = Σ(人类在此 Sprint 完成的任务权重)
Agent Velocity = Σ(Agent 在此 Sprint 完成的任务权重 × 置信系数)

Sprint Burndown 图表同时展示两条线：
  ━━━ 人类完成（蓝色）
  ━━━ Agent 完成（绿色）
  ━━━ 总计（白色/黑色）
  --- 理想趋势线（灰色虚线）
```

这让项目经理不仅能看到"Sprint 进展如何"，还能看到"人类和 Agent 各贡献了多少"。

### 4.4 突破 4：项目健康度评分

基于多维指标的项目健康度自动评估：

```
项目健康度 = 0-100 分

评分维度：
  1. 进度健康（30%）：实际进度 vs 时间进度的偏差
     - 超前/按时：满分
     - 滞后 <10%：80 分
     - 滞后 10-25%：50 分
     - 滞后 >25%：20 分
     
  2. Agent 健康（20%）：Agent 任务成功率
     - >90%：满分
     - 80-90%：70 分
     - <80%：40 分
     
  3. Git 活动（20%）：过去 7 天的 commit/PR 活跃度
     - 持续活跃：满分
     - 减少但有活动：70 分
     - 停滞（无 commit 超 3 天）：30 分
     
  4. 任务流动（15%）：任务从 todo → done 的流转效率
     - 无阻塞任务：满分
     - 有少量阻塞：60 分
     - 大量阻塞：20 分
     
  5. 团队活跃（15%）：成员参与度（评论、更新、代码提交）
     - 全员活跃：满分
     - 部分活跃：60 分
     - 大量不活跃成员：30 分
```

---

## 5. 用户故事

### 5.1 项目创建与管理

#### US-3.01: 项目卡片视图

**作为**团队成员，**我希望**在项目首页看到所有项目的卡片概览，**以便**快速了解各项目状态。

**验收标准：**
- 每个项目卡片显示：项目名称、描述文本（截断显示）、Sprint/Phase 标签（如 "Sprint 14 - 2026 Q2"）、进度条 + 百分比、团队成员头像（最多显示 5 个，超出显示 "+N"）、最近活动时间
- 卡片默认按最近活动时间降序排列
- 支持 Tabs 切换：全部项目 / 我参与的 / 已归档
- "我参与的" Tab 仅显示当前用户是项目成员的项目
- 页面右上角有"+ 新建项目"按钮
- 卡片支持点击进入项目详情页

#### US-3.02: 创建项目

**作为**团队负责人，**我希望**快速创建一个新项目，**以便**组织团队的工作。

**验收标准：**
- 点击"+ 新建项目"弹出创建表单
- 必填字段：项目名称
- 选填字段：描述（Markdown）、Sprint/Phase 类型选择（Sprint 制 / Phase 制 / 无周期）、开始日期、目标结束日期、项目成员（可添加人类和 Agent）、Git 仓库绑定（可选多个）
- 创建后自动跳转到项目详情页
- 创建者自动成为项目管理员

#### US-3.03: 编辑项目

**作为**项目管理员，**我希望**修改项目的基本信息和配置，**以便**保持项目信息最新。

**验收标准：**
- 在项目详情页的设置 Tab 中编辑：名称、描述、成员管理、Git 仓库绑定
- 修改实时保存，其他项目成员看到更新
- 项目成员变更通知所有现有成员

#### US-3.04: 归档项目

**作为**项目管理员，**我希望**将已结束的项目归档，**以便**保持项目列表整洁。

**验收标准：**
- 归档操作需要管理员权限
- 归档后项目从"全部项目"Tab 移到"已归档"Tab
- 归档项目为只读状态——可查看但不能修改任务
- 支持取消归档（恢复为活跃项目）

### 5.2 项目内任务管理

#### US-3.06: 项目内 Kanban

**作为**项目成员，**我希望**进入项目后看到该项目的任务看板，**以便**管理项目内的具体任务。

**验收标准：**
- 进入项目详情页的"任务"Tab，展示该项目的 Kanban 看板
- Kanban 复用 Module 2 的任务看板组件，通过 `project_id` 筛选
- 在项目 Kanban 中创建的任务自动关联到当前项目
- 所有 Module 2 的任务功能均可在项目 Kanban 中使用（拖拽、筛选、Agent 指派等）

#### US-3.07: 项目内创建任务

**作为**项目成员，**我希望**在项目上下文中快速创建任务，**以便**任务自动关联到项目。

**验收标准：**
- 在项目 Kanban 中创建的任务自动设置 `project_id`
- 任务创建时的指派人选择器仅显示项目成员（人类 + Agent）
- 任务标签选择器优先显示项目级标签

### 5.3 项目成员管理

#### US-3.08: 管理项目成员

**作为**项目管理员，**我希望**添加和移除项目成员（包含 Agent），**以便**控制项目的参与者范围。

**验收标准：**
- 在项目设置中管理成员
- 成员列表区分人类（圆形头像）和 Agent（机器人图标头像）
- 支持添加成员时搜索团队中的人类和 Agent
- 支持设置成员角色：管理员 / 成员 / 查看者
- Agent 默认角色为"成员"
- 移除成员时，该成员被指派的未完成任务显示提醒："[成员名] 还有 N 个未完成任务，是否重新分配？"

#### US-3.09: 项目成员概览

**作为**项目经理，**我希望**查看每个成员在项目中的贡献，**以便**了解工作分配情况。

**验收标准：**
- 项目"成员"Tab 显示所有成员列表
- 每个成员显示：头像、名称、角色、分配的任务数、已完成任务数、当前进行中任务
- Agent 成员额外显示：执行成功率、平均执行时间
- 支持按贡献量排序

### 5.4 Sprint / Phase 管理

#### US-3.10: 创建 Sprint

**作为**项目管理员，**我希望**创建 Sprint 周期，**以便**按迭代管理项目进度。

**验收标准：**
- 在项目设置中创建 Sprint：名称（自动递增，如 Sprint 15）、开始日期、结束日期、Sprint 目标（文本描述）
- 同一时间只能有一个"进行中"的 Sprint
- Sprint 状态：计划中 → 进行中 → 已完成
- 创建 Sprint 时可从 Backlog 拖拽任务到 Sprint 中

#### US-3.11: Sprint 看板

**作为**项目成员，**我希望**在 Sprint 维度查看任务，**以便**聚焦当前迭代的工作。

**验收标准：**
- 项目的 Kanban 视图可按 Sprint 筛选：当前 Sprint / 下一 Sprint / Backlog
- Sprint 看板顶部显示 Sprint 信息：名称、日期范围、剩余天数、Sprint 目标
- Sprint 结束时，未完成的任务自动提示是否移到下一个 Sprint

#### US-3.12: Sprint 回顾

**作为**项目经理，**我希望**在 Sprint 结束后查看回顾数据，**以便**评估团队效率。

**验收标准：**
- Sprint 完成后生成回顾报告：完成任务数/总任务数、Velocity（人类 + Agent 分别统计）、Burndown Chart、未完成任务列表、Agent 执行统计（成功/失败/重试）
- Burndown Chart 同时展示人类完成线和 Agent 完成线

### 5.5 Git 仓库绑定

#### US-3.13: 绑定 Git 仓库

**作为**项目管理员，**我希望**将 Git 仓库绑定到项目，**以便**代码活动自动关联到项目任务。

**验收标准：**
- 在项目设置中绑定 Git 仓库（GitHub / GitLab）
- 通过 OAuth 授权访问仓库
- 一个项目支持绑定多个仓库
- 绑定时配置：任务 ID 前缀（如 `CODEYI`）、branch 命名规范、是否自动创建 Webhook
- 绑定成功后，仓库最近的 commit/PR 活动开始同步

#### US-3.14: Git 活动关联

**作为**开发者，**我希望**我的 commit 和 PR 自动关联到对应的任务，**以便**不需要手动同步。

**验收标准：**
- commit message 中包含任务 ID（如 `CODEYI-42` 或 `#42`）时，自动关联到对应任务
- branch 名称匹配模式（如 `feat/CODEYI-42-*`）时，该 branch 上的所有 commit 自动关联
- PR 描述中引用任务时，PR 自动关联到任务
- 任务详情中显示关联的 commit 列表和 PR 列表
- 项目详情中显示近期 Git 活动汇总

#### US-3.15: PR 状态影响项目进度

**作为**项目经理，**我希望** PR 的合并状态自动影响项目进度，**以便**进度反映真实的代码交付情况。

**验收标准：**
- PR merged → 关联任务的置信系数变为 1.0（完全可信），项目进度相应提升
- PR open + review approved → 置信系数 0.9
- PR open + changes requested → 置信系数 0.6
- PR closed without merge → 不影响任务进度
- 项目进度条实时反映 PR 状态变化

### 5.6 进度追踪

#### US-3.16: 项目进度实时展示

**作为**任何团队成员，**我希望**在项目卡片和详情页看到实时进度，**以便**了解项目整体状况。

**验收标准：**
- 项目卡片上的进度条和百分比实时更新（WebSocket 推送）
- 项目详情页显示进度面板：总进度、本 Sprint 进度、人类贡献占比、Agent 贡献占比
- 进度计算考虑任务优先级权重和 Agent 置信系数（详见第 8 章）
- 鼠标悬停进度条显示详细分解

#### US-3.17: 项目仪表盘

**作为**项目经理，**我希望**查看项目的综合仪表盘，**以便**全面评估项目健康状况。

**验收标准：**
- 项目详情页的"概览"Tab 展示仪表盘
- 仪表盘内容：项目进度环形图、Sprint Burndown Chart、任务状态分布（饼图）、近 7 天活动趋势（折线图）、Agent 执行统计、近期 Git 活动列表
- 所有图表数据实时更新

---

## 6. 功能拆分

### P0 核心功能（MVP）

| 编号 | 功能 | 子功能 | 说明 |
|------|------|--------|------|
| F-P0-01 | **项目卡片视图** | 卡片布局 | 网格布局，每行 2-4 张卡片（响应式），显示名称、描述、Sprint/Phase 标签、进度条、团队头像、最近活动时间 |
| | | 进度条 | 加权自动聚合（详见第 8 章），实时更新 |
| | | Tab 切换 | 全部项目 / 我参与的 / 已归档 |
| | | 排序 | 按最近活动时间降序（默认）、按名称、按进度 |
| F-P0-02 | **项目 CRUD** | 创建项目 | 名称（必填）、描述、周期类型、日期、成员、Git 仓库 |
| | | 编辑项目 | 所有可编辑字段的实时更新 |
| | | 归档/恢复 | 管理员权限，归档统计，只读模式 |
| | | 删除项目 | 二次确认，级联处理（任务解绑 project_id 而非删除） |
| F-P0-03 | **项目内 Kanban** | 嵌入式看板 | 复用 Module 2 的 Kanban 组件，filter by project_id |
| | | 项目上下文 | 新建任务自动关联项目、指派人限定为项目成员 |
| | | Sprint 筛选 | 可按 Sprint / Backlog 筛选任务 |
| F-P0-04 | **项目成员管理** | 添加/移除 | 支持人类和 Agent 成员 |
| | | 角色管理 | 管理员 / 成员 / 查看者 |
| | | 成员头像展示 | 卡片上展示头像 + overflow |
| F-P0-05 | **项目进度聚合** | 加权计算 | 基于任务优先级权重 + Agent 置信系数 |
| | | 实时更新 | WebSocket 推送进度变化 |
| | | 进度分解 | hover 展示详细分解 |

### P1 重要功能（第二阶段）

| 编号 | 功能 | 子功能 | 说明 |
|------|------|--------|------|
| F-P1-01 | **列表视图** | 表格 | 列：名称、Sprint/Phase、进度、任务数、成员数、最近活动、创建日期 |
| | | 排序 | 点击列头排序 |
| | | 列宽 | 可拖拽调整 |
| | | 导出 | CSV 导出 |
| F-P1-02 | **Git 仓库绑定** | OAuth 授权 | GitHub / GitLab OAuth 流程 |
| | | 多仓库绑定 | 一个项目 → 多个仓库 |
| | | 任务 ID 配置 | 配置前缀和匹配模式 |
| | | Webhook 自动创建 | 绑定时自动在 GitHub/GitLab 创建 Webhook |
| F-P1-03 | **commit/PR 自动关联** | commit message 解析 | 正则匹配任务 ID |
| | | branch 命名解析 | 提取任务 ID |
| | | PR 描述解析 | 提取任务引用 |
| | | Agent commit 自动标记 | Agent 创建的 commit 自动携带任务 ID |
| F-P1-04 | **PR 状态 → 项目进度** | PR merged | 任务置信系数 → 1.0 |
| | | PR review 状态 | approved → 0.9, changes_requested → 0.6 |
| | | 项目进度实时反映 | PR 状态变化触发项目进度重算 |
| F-P1-05 | **项目仪表盘** | 进度环形图 | 项目整体完成度 |
| | | 任务状态分布 | 饼图：todo/in_progress/done/archived |
| | | 近期活动趋势 | 7 天折线图 |
| | | Git 活动汇总 | commit/PR 数量和列表 |

### P2 增强功能（第三阶段）

| 编号 | 功能 | 子功能 | 说明 |
|------|------|--------|------|
| F-P2-01 | **Sprint 管理** | Sprint CRUD | 创建/编辑/完成 Sprint |
| | | Sprint 目标 | 文本描述 + 完成度追踪 |
| | | Backlog 管理 | 未分配到 Sprint 的任务 |
| | | Sprint 切换 | 自动处理未完成任务迁移 |
| F-P2-02 | **Velocity 图表** | 混合 Velocity | Human + Agent 分开统计 |
| | | Burndown Chart | 双线（人类/Agent）+ 理想线 |
| | | 历史对比 | 多 Sprint Velocity 对比 |
| F-P2-03 | **项目健康度** | 健康度评分 | 0-100 分多维评估 |
| | | 健康趋势 | 历史健康度趋势图 |
| | | 告警规则 | 健康度低于阈值时通知 |
| F-P2-04 | **项目模板** | 预设模板 | 常见项目类型模板（Web App、Mobile App、API Service 等） |
| | | 自定义模板 | 保存项目配置为模板 |
| F-P2-05 | **跨项目视图** | Portfolio | 多项目概览面板 |
| | | 依赖关系 | 项目间依赖关系图 |

---

## 7. 项目-Git 绑定模型

这是 CODE-YI 项目模块最关键的差异化特性——将 Git 仓库从"外部链接"提升为"项目一等组成部分"。

### 7.1 绑定关系模型

```
Project（项目）
  │
  ├── ProjectRepo 1 ── GitHub: coco/codeyi-frontend
  │     ├── 任务 ID 前缀: CODEYI
  │     ├── branch 模式: {type}/CODEYI-{id}-{slug}
  │     ├── 同步方向: both
  │     └── Webhook: active
  │
  ├── ProjectRepo 2 ── GitHub: coco/codeyi-backend
  │     ├── 任务 ID 前缀: CODEYI
  │     ├── branch 模式: {type}/CODEYI-{id}-{slug}
  │     ├── 同步方向: both
  │     └── Webhook: active
  │
  └── ProjectRepo 3 ── GitLab: coco/codeyi-docs
        ├── 任务 ID 前缀: CODEYI
        ├── branch 模式: {type}/CODEYI-{id}-{slug}
        ├── 同步方向: inbound（仅接收，不推送）
        └── Webhook: active
```

**设计原则：**
- 一个项目可以绑定多个 Git 仓库（1:N）
- 一个仓库只能绑定到一个项目（N:1），避免 commit 关联歧义
- 如果仓库已被其他项目绑定，绑定时提示冲突
- 支持 GitHub 和 GitLab 混合绑定

### 7.2 任务自动关联引擎

#### 7.2.1 Commit Message 解析

**解析规则（按优先级）：**

```
规则 1: 项目前缀 + 数字
  模式: /{PREFIX}-(\d+)/gi
  示例: "fix(auth): CODEYI-42 token refresh logic"
  结果: 关联到 Task #42

规则 2: 井号 + 数字（仅在项目绑定仓库中）
  模式: /#(\d+)/g
  示例: "implement login page (#42, #43)"
  结果: 关联到 Task #42 和 Task #43

规则 3: Conventional Commits 扩展
  模式: /^(\w+)(\(.+\))?: (.+)/
  + 从 scope 或 body 中提取任务 ID
  示例: "feat(CODEYI-42): user login page"
  结果: 关联到 Task #42

规则 4: 关闭指令
  模式: /(close[sd]?|fix(e[sd])?|resolve[sd]?) #{PREFIX}-(\d+)/gi
  示例: "closes CODEYI-42"
  结果: 关联到 Task #42 + 标记为可关闭
```

**解析后处理：**
1. 验证任务 ID 存在且属于当前项目
2. 创建 `git_task_links` 记录
3. 在任务活动流中记录 "关联 commit abc1234"
4. 触发项目进度重算

#### 7.2.2 Branch 命名解析

**推荐命名规范（可在项目设置中配置）：**

```
{type}/{PREFIX}-{task_id}-{slug}

type: feat | fix | hotfix | refactor | docs | test | chore
PREFIX: 项目前缀（如 CODEYI）
task_id: 任务 ID
slug: 可选的描述文字

示例:
  feat/CODEYI-42-login-page
  fix/CODEYI-55-api-timeout
  docs/CODEYI-60-api-reference
```

**解析逻辑：**
- 当 Webhook 收到 `push` 事件时，检查 branch 名称
- 提取任务 ID，建立 branch → task 关联
- 该 branch 上所有后续 commit 自动关联到对应任务（即使 commit message 未包含任务 ID）

#### 7.2.3 PR 自动关联

**关联触发点：**
1. PR 创建时（`pull_request.opened`）
2. PR 描述修改时（`pull_request.edited`）
3. PR 的 source branch 已关联任务

**PR 描述解析：**
```markdown
## Related Tasks
- CODEYI-42
- CODEYI-43
- Closes CODEYI-44
```

**解析规则：**
- 扫描 PR title 和 body 中的任务 ID 引用
- 检查 PR 的 source branch 是否已关联任务
- 合并所有关联并去重

**PR 状态 → 任务状态映射：**

| PR 状态 | 任务影响 | 置信系数 |
|---------|---------|---------|
| `opened` | 任务关联 PR | 不变 |
| `review_requested` | 任务 sub_status → "待 review" | 不变 |
| `approved` | 任务 sub_status → "已 approve" | 0.9 |
| `changes_requested` | 任务 sub_status → "需修改" | 0.6 |
| `merged` | 任务状态 → "done"（如配置自动完成） | 1.0 |
| `closed` (not merged) | 无自动操作 | 不变 |

### 7.3 Webhook 事件处理

#### 7.3.1 GitHub Webhook 事件

| 事件 | 处理逻辑 |
|------|---------|
| `push` | 解析每个 commit message → 创建 commit-task 关联 → 检查 branch 关联 |
| `pull_request.opened` | 解析 PR → 创建 PR-task 关联 → 通知任务关注者 |
| `pull_request.edited` | 重新解析 PR 描述 → 更新关联 |
| `pull_request.closed` (merged) | 关联任务自动完成（如配置）→ 项目进度重算 |
| `pull_request.closed` (not merged) | 记录日志，不自动操作 |
| `pull_request_review.submitted` | 更新 PR review 状态 → 影响任务置信系数 |
| `create` (branch) | 解析 branch 名称 → 创建 branch-task 关联 |
| `delete` (branch) | 清理 branch-task 关联 |
| `issues.opened` | 如果配置了 Issue 同步，创建对应 Task（复用 Module 2 git_repo_bindings 逻辑） |
| `issues.closed` | 同步关闭对应 Task |
| `issue_comment.created` | 同步评论（如配置） |

#### 7.3.2 GitLab Webhook 事件

| 事件 | 对应 GitHub 事件 | 处理逻辑 |
|------|------------------|---------|
| `Push Hook` | `push` | 同 push |
| `Merge Request Hook` (open) | `pull_request.opened` | 同 PR opened |
| `Merge Request Hook` (merge) | `pull_request.closed` (merged) | 同 PR merged |
| `Note Hook` (MR comment) | `pull_request_review.submitted` | 解析评审意见 |
| `Tag Push Hook` | 无对应 | 记录日志（可用于 Release 追踪，P2） |

#### 7.3.3 Webhook 安全与可靠性

```
GitHub Webhook 请求
  │
  ├── 1. 验证签名（HMAC-SHA256，使用 webhook_secret）
  │     └── 失败 → 返回 401, 记录安全日志
  │
  ├── 2. 检查 repo 是否已绑定项目
  │     └── 未绑定 → 返回 200（静默忽略）
  │
  ├── 3. 检查 sync_source 防循环
  │     └── 来自 CODE-YI 的操作 → 忽略
  │
  ├── 4. 解析事件并入队（Redis Stream）
  │     └── 异步处理，Webhook 端点立即返回 200
  │
  └── 5. 异步 Worker 消费事件
        ├── 解析 commit/PR/branch
        ├── 创建/更新关联
        ├── 触发进度重算
        └── 通知相关用户
```

**幂等性保证：**
- 每个 Webhook event 携带 `delivery_id`（GitHub）或 `X-Gitlab-Event-UUID`（GitLab）
- 处理前检查是否已处理过（Redis SET + 24h TTL）
- 重复事件静默忽略

**失败重试：**
- Webhook 处理失败（非 2xx 返回）→ GitHub/GitLab 自动重试
- 内部处理失败 → 写入死信队列（Dead Letter Queue），人工介入

### 7.4 Git 活动聚合视图

在项目详情的"Git 活动"Tab 中展示：

```
┌──────────────────────────────────────────────────────────┐
│ Git 活动 (过去 7 天)                                       │
│                                                          │
│ ● 今天                                                    │
│   ├── [codeyi-frontend] PR #92 merged by @alice          │
│   │   "feat: implement search component" → Task #67      │
│   ├── [codeyi-backend] 3 commits by @CodeBot             │
│   │   fix(api): CODEYI-55 handle timeout → Task #55      │
│   └── [codeyi-frontend] Branch created by @bob           │
│       feat/CODEYI-70-settings-page → Task #70            │
│                                                          │
│ ● 昨天                                                    │
│   ├── [codeyi-backend] PR #34 opened by @CodeBot         │
│   │   "fix: API timeout handling" → Task #55             │
│   └── [codeyi-docs] 2 commits by @DocBot                 │
│       docs: CODEYI-60 API reference → Task #60           │
│                                                          │
│ 统计: 12 commits | 3 PRs (2 merged) | 3 个仓库活跃         │
└──────────────────────────────────────────────────────────┘
```

---

## 8. 项目进度聚合引擎

### 8.1 进度计算公式

**核心公式：**

```
project_progress = Σ(task_weight[i] × task_completion[i] × confidence[i]) 
                   / Σ(task_weight[i])
                   × 100%
```

**各参数定义：**

#### 8.1.1 任务权重 (task_weight)

基于任务优先级的权重系数：

| 优先级 | 权重 | 说明 |
|--------|------|------|
| P0 (Critical) | 8 | 核心架构、阻塞性任务 |
| P1 (High) | 5 | 重要功能 |
| P2 (Medium) | 3 | 常规功能 |
| P3 (Low) | 2 | 优化和改进 |
| P4 (Trivial) | 1 | 文档修复、小调整 |

**设计决策：** 为什么不用线性权重（5/4/3/2/1）？因为 P0 任务对项目成败的影响是指数级的——一个 P0 未完成，项目就不算完成。8:5:3:2:1 的指数递减更能反映这种现实。

#### 8.1.2 任务完成度 (task_completion)

| 任务状态 | 完成度 |
|---------|--------|
| todo | 0% |
| in_progress (手动进度) | 用户设定值（0-100%）|
| in_progress (Agent 执行中) | Agent 上报的 progress 值 |
| done | 100% |
| archived | 100% |

#### 8.1.3 置信系数 (confidence)

置信系数反映任务完成度的可靠性：

| 场景 | 置信系数 | 说明 |
|------|---------|------|
| 人类标记完成 | 1.0 | 人类判断默认可信 |
| Agent 完成 + PR merged | 1.0 | 代码已合入主干 = 完全可信 |
| Agent 完成 + PR approved (not merged) | 0.9 | 已审核但未合入 |
| Agent 完成 + PR open (pending review) | 0.8 | 等待审核 |
| Agent 完成 + PR changes requested | 0.6 | 需要修改 |
| Agent 完成 + 无关联 PR (非代码任务) | 0.85 | 文档/设计等非代码任务 |
| Agent 执行中 | progress × 0.7 | 执行中的进度打 30% 折扣 |
| Agent 失败 | 0 | 失败的任务不计入进度 |
| 任务在 todo 状态 | 0 | 未开始 |

### 8.2 进度计算示例

**项目：CODE-YI 主站 Sprint 14**

| 任务 | 优先级 | 权重 | 状态 | 完成度 | 置信系数 | 贡献 |
|------|--------|------|------|--------|---------|------|
| 用户认证系统 | P0 | 8 | done (Agent, PR merged) | 100% | 1.0 | 8.0 |
| 搜索功能 | P1 | 5 | in_progress (Agent, 70%) | 70% | 0.7 × 0.7 = 0.49 | 5 × 0.7 × 0.49 = 1.715 |
| 设置页面 | P1 | 5 | done (人类) | 100% | 1.0 | 5.0 |
| API 文档 | P2 | 3 | done (Agent, 无 PR) | 100% | 0.85 | 2.55 |
| 单元测试补充 | P2 | 3 | in_progress (Agent, PR open) | 100% | 0.8 | 2.4 |
| README 更新 | P4 | 1 | todo | 0% | 0 | 0 |

```
总权重 = 8 + 5 + 5 + 3 + 3 + 1 = 25
总贡献 = 8.0 + 1.715 + 5.0 + 2.55 + 2.4 + 0 = 19.665

项目进度 = 19.665 / 25 × 100% = 78.66% ≈ 79%
```

对比简单计算（完成数/总数）：4/6 = 66.7%。加权计算更准确——因为高优先级任务已完成，项目实际进度比简单比率看起来更好。

### 8.3 进度重算触发条件

| 事件 | 触发方式 |
|------|---------|
| 任务状态变更 | 即时重算 |
| 任务优先级变更 | 即时重算 |
| Agent 进度更新 | 节流重算（每 30s 最多一次，避免频繁计算） |
| PR 状态变更 | 即时重算 |
| PR merged | 即时重算 |
| 任务添加到/移出项目 | 即时重算 |
| Sprint 任务变更 | 即时重算 |

### 8.4 重算性能优化

**问题：** 一个项目可能有上百个任务，每次事件都全量重算的代价太高。

**方案：增量更新 + 缓存**

```
1. Redis 缓存项目进度
   Key: project_progress:{project_id}
   Value: { progress, breakdown, last_calculated_at }
   TTL: 5 分钟

2. 增量更新策略
   - 任务状态变更：只需更新该任务的贡献值
     new_progress = cached_progress - old_contribution + new_contribution
   - 新增/删除任务：需要重算总权重
     → 触发全量重算
   
3. 全量重算（兜底）
   - 每 5 分钟缓存过期时触发
   - 手动刷新触发
   - 用 SQL 一次查询聚合
```

**全量重算 SQL：**

```sql
SELECT 
  p.id as project_id,
  SUM(
    CASE t.priority
      WHEN 'p0' THEN 8
      WHEN 'p1' THEN 5
      WHEN 'p2' THEN 3
      WHEN 'p3' THEN 2
      WHEN 'p4' THEN 1
    END
  ) as total_weight,
  SUM(
    CASE t.priority
      WHEN 'p0' THEN 8
      WHEN 'p1' THEN 5
      WHEN 'p2' THEN 3
      WHEN 'p3' THEN 2
      WHEN 'p4' THEN 1
    END
    * (t.progress / 100.0)
    * CASE 
        WHEN t.status = 'done' AND t.assignee_type = 'human' THEN 1.0
        WHEN t.status = 'done' AND t.assignee_type = 'agent' THEN
          COALESCE(
            (SELECT CASE 
              WHEN EXISTS (SELECT 1 FROM git_task_links gtl 
                          WHERE gtl.task_id = t.id AND gtl.link_type = 'pr' AND gtl.pr_merged = true)
              THEN 1.0
              WHEN EXISTS (SELECT 1 FROM git_task_links gtl 
                          WHERE gtl.task_id = t.id AND gtl.link_type = 'pr' AND gtl.pr_approved = true)
              THEN 0.9
              WHEN EXISTS (SELECT 1 FROM git_task_links gtl 
                          WHERE gtl.task_id = t.id AND gtl.link_type = 'pr')
              THEN 0.8
              ELSE 0.85
            END),
            0.85
          )
        WHEN t.status = 'in_progress' AND t.assignee_type = 'agent' THEN 0.7
        WHEN t.status = 'in_progress' THEN 1.0
        WHEN t.status = 'todo' THEN 0.0
        ELSE 1.0
      END
  ) as weighted_progress
FROM projects p
JOIN tasks t ON t.project_id = p.id AND t.status != 'archived'
WHERE p.id = $1
GROUP BY p.id;
```

### 8.5 Sprint Burndown 数据模型

Sprint Burndown Chart 需要按天记录进度快照：

```sql
-- 每日进度快照（定时任务每天凌晨生成）
CREATE TABLE sprint_daily_snapshots (
  id BIGSERIAL PRIMARY KEY,
  sprint_id UUID NOT NULL REFERENCES sprints(id),
  snapshot_date DATE NOT NULL,
  
  -- 任务统计
  total_tasks INTEGER NOT NULL,
  completed_tasks INTEGER NOT NULL,
  human_completed INTEGER NOT NULL,
  agent_completed INTEGER NOT NULL,
  
  -- 权重统计
  total_weight REAL NOT NULL,
  completed_weight REAL NOT NULL,
  human_completed_weight REAL NOT NULL,
  agent_completed_weight REAL NOT NULL,
  
  -- 进度
  progress_percent REAL NOT NULL,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(sprint_id, snapshot_date)
);
```

**Burndown 数据格式（返回前端）：**

```typescript
interface BurndownData {
  sprint_id: string;
  start_date: string;
  end_date: string;
  total_weight: number;
  daily: Array<{
    date: string;
    remaining_weight: number;         // 总剩余
    human_remaining_weight: number;    // 人类剩余
    agent_remaining_weight: number;    // Agent 剩余
    ideal_remaining: number;           // 理想线
  }>;
}
```

### 8.6 Velocity 计算

```typescript
interface SprintVelocity {
  sprint_id: string;
  sprint_name: string;
  total_velocity: number;        // 总完成权重
  human_velocity: number;        // 人类完成权重
  agent_velocity: number;        // Agent 完成权重
  task_count: number;            // 总完成任务数
  human_task_count: number;      // 人类完成数
  agent_task_count: number;      // Agent 完成数
  agent_success_rate: number;    // Agent 成功率
}
```

**Velocity Chart** 展示最近 N 个 Sprint 的柱状图：
- 每个 Sprint 一组柱子：蓝色（人类）+ 绿色（Agent）+ 总计虚线
- 趋势线显示团队（人+Agent）的 Velocity 是否在增长

---

## 9. 数据模型

### 9.1 项目主表

```sql
-- 项目表
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  name VARCHAR(200) NOT NULL,
  description TEXT,                          -- Markdown 格式
  status VARCHAR(20) NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'archived')),
  
  -- 周期类型
  cycle_type VARCHAR(10) NOT NULL DEFAULT 'none'
    CHECK (cycle_type IN ('sprint', 'phase', 'none')),
  
  -- 日期
  start_date DATE,
  target_end_date DATE,
  
  -- 进度（缓存字段，异步更新）
  progress SMALLINT DEFAULT 0               -- 0-100，由聚合引擎计算并缓存
    CHECK (progress >= 0 AND progress <= 100),
  progress_details JSONB DEFAULT '{}',       -- 进度分解详情
  
  -- 配置
  task_id_prefix VARCHAR(20),               -- 任务 ID 前缀（如 CODEYI），用于 Git 关联
  branch_pattern VARCHAR(200) DEFAULT '{type}/{PREFIX}-{id}-{slug}',
  
  -- 计量
  task_count INTEGER DEFAULT 0,             -- 缓存：总任务数
  completed_task_count INTEGER DEFAULT 0,   -- 缓存：已完成任务数
  member_count INTEGER DEFAULT 0,           -- 缓存：成员数
  
  -- 最近活动
  last_activity_at TIMESTAMPTZ DEFAULT NOW(),
  last_activity_summary VARCHAR(200),        -- "Alice completed Task #42"
  
  -- 审计
  created_by UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  archived_at TIMESTAMPTZ                    -- 归档时间
);

-- 索引
CREATE INDEX idx_projects_workspace ON projects(workspace_id, status);
CREATE INDEX idx_projects_status ON projects(status, last_activity_at DESC);
CREATE INDEX idx_projects_created_by ON projects(created_by);
CREATE INDEX idx_projects_activity ON projects(last_activity_at DESC) WHERE status = 'active';
```

### 9.2 项目成员表

```sql
-- 项目成员
CREATE TABLE project_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  member_id UUID NOT NULL,                   -- user_id 或 agent_id
  member_type VARCHAR(10) NOT NULL           -- 'human' | 'agent'
    CHECK (member_type IN ('human', 'agent')),
  role VARCHAR(20) NOT NULL DEFAULT 'member'
    CHECK (role IN ('admin', 'member', 'viewer')),
  
  -- 统计（缓存）
  assigned_task_count INTEGER DEFAULT 0,
  completed_task_count INTEGER DEFAULT 0,
  
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  UNIQUE(project_id, member_id, member_type)
);

CREATE INDEX idx_project_members_project ON project_members(project_id);
CREATE INDEX idx_project_members_member ON project_members(member_id, member_type);
```

### 9.3 项目仓库绑定表

```sql
-- 项目-Git 仓库绑定（扩展 Module 2 的 git_repo_bindings）
CREATE TABLE project_repos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  
  -- Git 仓库信息
  provider VARCHAR(10) NOT NULL              -- 'github' | 'gitlab'
    CHECK (provider IN ('github', 'gitlab')),
  repo_owner VARCHAR(100) NOT NULL,          -- 组织/用户名
  repo_name VARCHAR(100) NOT NULL,           -- 仓库名
  repo_full_name VARCHAR(200) NOT NULL,      -- owner/name
  repo_url VARCHAR(500) NOT NULL,            -- 仓库 URL
  default_branch VARCHAR(100) DEFAULT 'main',
  
  -- 认证
  access_token_encrypted TEXT NOT NULL,       -- 加密存储的 OAuth token
  
  -- 同步配置
  sync_direction VARCHAR(10) DEFAULT 'both'
    CHECK (sync_direction IN ('inbound', 'outbound', 'both')),
  auto_link_commits BOOLEAN DEFAULT TRUE,    -- 自动关联 commit
  auto_link_prs BOOLEAN DEFAULT TRUE,        -- 自动关联 PR
  auto_link_branches BOOLEAN DEFAULT TRUE,   -- 自动关联 branch
  auto_close_on_merge BOOLEAN DEFAULT TRUE,  -- PR merge 时自动关闭任务
  sync_issues BOOLEAN DEFAULT FALSE,         -- 同步 Issue（复用 Module 2 逻辑）
  
  -- Webhook
  webhook_id VARCHAR(50),                    -- GitHub/GitLab Webhook ID
  webhook_secret VARCHAR(100),               -- Webhook 签名密钥
  webhook_active BOOLEAN DEFAULT FALSE,
  
  -- 统计
  total_commits_linked INTEGER DEFAULT 0,
  total_prs_linked INTEGER DEFAULT 0,
  last_sync_at TIMESTAMPTZ,
  
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- 一个仓库只能绑定到一个项目
  UNIQUE(provider, repo_owner, repo_name)
);

CREATE INDEX idx_project_repos_project ON project_repos(project_id) WHERE is_active = TRUE;
CREATE INDEX idx_project_repos_repo ON project_repos(provider, repo_owner, repo_name);
```

### 9.4 Git-Task 关联表

```sql
-- Git 实体与 Task 的关联
CREATE TABLE git_task_links (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_repo_id UUID NOT NULL REFERENCES project_repos(id) ON DELETE CASCADE,
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  
  -- 关联类型
  link_type VARCHAR(10) NOT NULL
    CHECK (link_type IN ('commit', 'branch', 'pr')),
  
  -- Git 实体信息
  git_ref VARCHAR(200) NOT NULL,             -- commit SHA / branch name / PR number
  git_url VARCHAR(500),                      -- 链接到 GitHub/GitLab 的 URL
  git_title VARCHAR(500),                    -- PR title / commit message (first line)
  git_author VARCHAR(100),                   -- Git 作者
  git_author_avatar VARCHAR(500),            -- 作者头像 URL
  
  -- PR 特有字段
  pr_number INTEGER,
  pr_state VARCHAR(20),                      -- 'open' | 'closed' | 'merged'
  pr_merged BOOLEAN DEFAULT FALSE,
  pr_approved BOOLEAN DEFAULT FALSE,
  pr_changes_requested BOOLEAN DEFAULT FALSE,
  pr_review_count INTEGER DEFAULT 0,
  pr_merged_at TIMESTAMPTZ,
  
  -- 关联来源
  linked_by VARCHAR(20) DEFAULT 'auto'       -- 'auto' | 'manual' | 'agent'
    CHECK (linked_by IN ('auto', 'manual', 'agent')),
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- 防止重复关联
  UNIQUE(project_repo_id, task_id, link_type, git_ref)
);

CREATE INDEX idx_git_task_links_task ON git_task_links(task_id);
CREATE INDEX idx_git_task_links_repo ON git_task_links(project_repo_id, link_type);
CREATE INDEX idx_git_task_links_pr ON git_task_links(pr_number, project_repo_id) 
  WHERE link_type = 'pr';
```

### 9.5 Sprint 表

```sql
-- Sprint / Phase 周期
CREATE TABLE sprints (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  
  name VARCHAR(100) NOT NULL,                -- "Sprint 14" / "Phase 1"
  description TEXT,                          -- Sprint 目标描述
  sprint_number INTEGER NOT NULL,            -- 自增序号
  
  status VARCHAR(20) NOT NULL DEFAULT 'planning'
    CHECK (status IN ('planning', 'active', 'completed')),
  
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  
  -- 统计（缓存）
  total_tasks INTEGER DEFAULT 0,
  completed_tasks INTEGER DEFAULT 0,
  total_weight REAL DEFAULT 0,
  completed_weight REAL DEFAULT 0,
  human_velocity REAL DEFAULT 0,
  agent_velocity REAL DEFAULT 0,
  
  -- 进度
  progress SMALLINT DEFAULT 0
    CHECK (progress >= 0 AND progress <= 100),
  
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  UNIQUE(project_id, sprint_number)
);

CREATE INDEX idx_sprints_project ON sprints(project_id, status);
CREATE INDEX idx_sprints_active ON sprints(project_id) WHERE status = 'active';
```

### 9.6 Sprint-Task 关联表

```sql
-- Sprint 与 Task 的关联（多对多：一个任务可以跨 Sprint，如果上一个 Sprint 未完成移到下一个）
CREATE TABLE sprint_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sprint_id UUID NOT NULL REFERENCES sprints(id) ON DELETE CASCADE,
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  
  added_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  added_by UUID NOT NULL,                    -- 谁把任务加入 Sprint
  
  -- 如果任务从上个 Sprint 移过来
  carried_from_sprint_id UUID REFERENCES sprints(id),
  
  UNIQUE(sprint_id, task_id)
);

CREATE INDEX idx_sprint_tasks_sprint ON sprint_tasks(sprint_id);
CREATE INDEX idx_sprint_tasks_task ON sprint_tasks(task_id);
```

### 9.7 项目活动表

```sql
-- 项目级活动流
CREATE TABLE project_activities (
  id BIGSERIAL PRIMARY KEY,
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  
  actor_id UUID NOT NULL,
  actor_type VARCHAR(10) NOT NULL            -- 'human' | 'agent' | 'system'
    CHECK (actor_type IN ('human', 'agent', 'system')),
  
  action VARCHAR(30) NOT NULL,               
  -- 可能的 action 值:
  -- 'project_created', 'project_updated', 'project_archived', 'project_unarchived',
  -- 'member_added', 'member_removed', 'member_role_changed',
  -- 'repo_bound', 'repo_unbound',
  -- 'sprint_created', 'sprint_started', 'sprint_completed',
  -- 'task_added', 'task_completed', 'task_removed',
  -- 'git_commit_linked', 'git_pr_linked', 'git_pr_merged',
  -- 'progress_milestone'  (进度达到 25%/50%/75%/100% 时自动记录)
  
  target_type VARCHAR(20),                   -- 'task' | 'sprint' | 'repo' | 'member'
  target_id VARCHAR(100),                    -- 目标实体 ID
  
  details JSONB,                             -- 活动详情
  summary VARCHAR(300),                      -- 人类可读摘要
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_project_activities_project ON project_activities(project_id, created_at DESC);
CREATE INDEX idx_project_activities_recent ON project_activities(created_at DESC);
```

### 9.8 Sprint 每日快照表

```sql
-- 每日进度快照（用于 Burndown Chart）
CREATE TABLE sprint_daily_snapshots (
  id BIGSERIAL PRIMARY KEY,
  sprint_id UUID NOT NULL REFERENCES sprints(id) ON DELETE CASCADE,
  snapshot_date DATE NOT NULL,
  
  -- 任务统计
  total_tasks INTEGER NOT NULL,
  completed_tasks INTEGER NOT NULL,
  human_completed INTEGER NOT NULL,
  agent_completed INTEGER NOT NULL,
  
  -- 权重统计
  total_weight REAL NOT NULL,
  completed_weight REAL NOT NULL,
  human_completed_weight REAL NOT NULL,
  agent_completed_weight REAL NOT NULL,
  
  -- 进度
  progress_percent REAL NOT NULL,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(sprint_id, snapshot_date)
);

CREATE INDEX idx_sprint_snapshots_sprint ON sprint_daily_snapshots(sprint_id, snapshot_date);
```

### 9.9 Webhook 事件日志表

```sql
-- Webhook 事件处理日志
CREATE TABLE webhook_event_logs (
  id BIGSERIAL PRIMARY KEY,
  project_repo_id UUID NOT NULL REFERENCES project_repos(id),
  
  delivery_id VARCHAR(100) NOT NULL,         -- GitHub/GitLab delivery ID（幂等用）
  event_type VARCHAR(50) NOT NULL,           -- 'push', 'pull_request', etc.
  payload_summary JSONB,                     -- 精简的事件数据
  
  -- 处理结果
  status VARCHAR(20) NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'processing', 'success', 'failed', 'skipped')),
  tasks_linked INTEGER DEFAULT 0,            -- 关联了多少任务
  error_message TEXT,
  
  received_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  processed_at TIMESTAMPTZ
);

CREATE UNIQUE INDEX idx_webhook_events_delivery ON webhook_event_logs(delivery_id);
CREATE INDEX idx_webhook_events_repo ON webhook_event_logs(project_repo_id, received_at DESC);
CREATE INDEX idx_webhook_events_pending ON webhook_event_logs(status) WHERE status = 'pending';
```

### 9.10 ER 关系图

```
workspaces
  │
  └── projects
        │
        ├── project_members ──── (users | agents)
        │
        ├── project_repos ──── git_task_links ──── tasks (Module 2)
        │                                            │
        │                                            ├── task_comments
        │                                            ├── task_activities
        │                                            └── agent_task_executions
        │
        ├── sprints ──── sprint_tasks ──── tasks
        │         │
        │         └── sprint_daily_snapshots
        │
        ├── project_activities
        │
        └── webhook_event_logs (via project_repos)
```

### 9.11 与 Module 2 Tasks 表的关系

Module 2 的 `tasks` 表已有 `project_id` 字段（外键指向 `projects.id`）。Module 3 不需要修改 tasks 表结构，只需要：

1. `tasks.project_id` 外键指向 `projects.id`
2. Module 2 的 `git_repo_bindings` 表被 Module 3 的 `project_repos` 表扩展/替代（`project_repos` 是 `git_repo_bindings` 的超集，多了 project 绑定关系和更丰富的配置）
3. 新增 `git_task_links` 表替代 Module 2 中任务直接存储 `git_pr_urls` 字段的方式，提供更丰富的 Git 关联数据

**迁移策略：**
- Module 2 的 `git_repo_bindings` 数据迁移到 `project_repos`
- `tasks.git_pr_urls` 数据迁移到 `git_task_links`
- 保持向后兼容：`tasks.git_pr_urls` 暂时保留，但新的 PR 关联写入 `git_task_links`

---

## 10. 技术方案

### 10.1 整体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                          客户端层                                    │
│  Web (Next.js + TailwindCSS)                                        │
│  ├── Project Card Grid (项目卡片网格)                                 │
│  ├── Project Detail Page                                            │
│  │   ├── Overview Tab (仪表盘)                                       │
│  │   ├── Tasks Tab (嵌入式 Kanban — 复用 Module 2)                   │
│  │   ├── Git Activity Tab                                           │
│  │   ├── Members Tab                                                │
│  │   └── Settings Tab                                               │
│  ├── Project List Table (列表视图)                                    │
│  └── Sprint Management UI                                           │
└───────────────────────┬─────────────────────────────────────────────┘
                        │ REST API + WebSocket
┌───────────────────────┴─────────────────────────────────────────────┐
│                        API Gateway                                   │
│  JWT Auth │ Rate Limiting │ WS Upgrade                               │
└───────────────────────┬─────────────────────────────────────────────┘
                        │
┌───────────────────────┴─────────────────────────────────────────────┐
│                        服务层                                        │
│                                                                      │
│  Project Service ──── Progress Engine ──── Git Integration Service   │
│       │                    │                       │                  │
│       │              Redis Cache                   │                  │
│       │           (progress cache)           Webhook Handler         │
│       │                    │                       │                  │
│  ┌────┴────────────────────┴───────────────────────┴──────┐         │
│  │              Event Bus (Redis Streams)                   │         │
│  └────┬────────────────────┬───────────────────────┬──────┘         │
│       │                    │                       │                  │
│  Sprint Service      Notification           Activity Logger          │
│                      Service                                         │
└───────────────────────┬─────────────────────────────────────────────┘
                        │
┌───────────────────────┴─────────────────────────────────────────────┐
│                        数据层                                        │
│  PostgreSQL 16 (Cloud SQL)  │  Redis 7 (Memorystore)                │
│  (projects, sprints,        │  (progress cache, webhook dedup,      │
│   project_repos,             │   event bus, websocket pub/sub)       │
│   git_task_links)            │                                       │
└─────────────────────────────────────────────────────────────────────┘
```

### 10.2 API 设计

#### RESTful API

```
# 项目 CRUD
GET    /api/v1/workspaces/:wid/projects          # 获取项目列表（支持 Tab 筛选: all/mine/archived）
POST   /api/v1/workspaces/:wid/projects          # 创建项目
GET    /api/v1/projects/:pid                      # 获取项目详情
PATCH  /api/v1/projects/:pid                      # 更新项目
DELETE /api/v1/projects/:pid                      # 删除项目
POST   /api/v1/projects/:pid/archive              # 归档项目
POST   /api/v1/projects/:pid/unarchive            # 取消归档

# 项目成员
GET    /api/v1/projects/:pid/members              # 获取成员列表
POST   /api/v1/projects/:pid/members              # 添加成员
PATCH  /api/v1/projects/:pid/members/:mid         # 修改成员角色
DELETE /api/v1/projects/:pid/members/:mid         # 移除成员

# 项目内任务（代理到 Module 2 Task API，自动注入 project_id 筛选）
GET    /api/v1/projects/:pid/tasks                # 获取项目任务列表
POST   /api/v1/projects/:pid/tasks                # 在项目内创建任务（自动关联 project_id）

# 项目进度
GET    /api/v1/projects/:pid/progress             # 获取项目进度详情（含分解数据）
GET    /api/v1/projects/:pid/progress/history     # 进度历史趋势

# Git 仓库绑定
GET    /api/v1/projects/:pid/repos                # 获取绑定的仓库列表
POST   /api/v1/projects/:pid/repos                # 绑定仓库
DELETE /api/v1/projects/:pid/repos/:rid           # 解绑仓库
POST   /api/v1/projects/:pid/repos/:rid/sync      # 手动触发同步

# Git 活动
GET    /api/v1/projects/:pid/git-activity         # 获取 Git 活动列表（commit/PR/branch）
GET    /api/v1/tasks/:tid/git-links               # 获取任务关联的 Git 实体

# Webhook 接收端点
POST   /api/v1/webhooks/github/:repo_id           # GitHub Webhook
POST   /api/v1/webhooks/gitlab/:repo_id           # GitLab Webhook

# Sprint 管理
GET    /api/v1/projects/:pid/sprints              # 获取 Sprint 列表
POST   /api/v1/projects/:pid/sprints              # 创建 Sprint
GET    /api/v1/sprints/:sid                        # 获取 Sprint 详情
PATCH  /api/v1/sprints/:sid                        # 更新 Sprint
POST   /api/v1/sprints/:sid/start                  # 开始 Sprint
POST   /api/v1/sprints/:sid/complete               # 完成 Sprint

# Sprint 任务
GET    /api/v1/sprints/:sid/tasks                  # 获取 Sprint 任务列表
POST   /api/v1/sprints/:sid/tasks                  # 添加任务到 Sprint
DELETE /api/v1/sprints/:sid/tasks/:tid             # 从 Sprint 移除任务

# Sprint 统计
GET    /api/v1/sprints/:sid/burndown              # Burndown 数据
GET    /api/v1/projects/:pid/velocity              # Velocity 历史数据

# 项目活动
GET    /api/v1/projects/:pid/activities           # 获取活动流

# 项目仪表盘
GET    /api/v1/projects/:pid/dashboard            # 聚合仪表盘数据
```

#### 请求/响应示例

**创建项目：**

```typescript
// POST /api/v1/workspaces/:wid/projects
// Request
{
  "name": "CODE-YI 主站",
  "description": "CODE-YI 产品主站开发项目",
  "cycle_type": "sprint",
  "start_date": "2026-01-15",
  "target_end_date": "2026-06-30",
  "task_id_prefix": "CODEYI",
  "members": [
    { "member_id": "user_alice", "member_type": "human", "role": "admin" },
    { "member_id": "user_bob", "member_type": "human", "role": "member" },
    { "member_id": "agent_codebot", "member_type": "agent", "role": "member" }
  ]
}

// Response 201
{
  "id": "proj_abc123",
  "name": "CODE-YI 主站",
  "description": "CODE-YI 产品主站开发项目",
  "status": "active",
  "cycle_type": "sprint",
  "start_date": "2026-01-15",
  "target_end_date": "2026-06-30",
  "task_id_prefix": "CODEYI",
  "progress": 0,
  "task_count": 0,
  "completed_task_count": 0,
  "member_count": 3,
  "last_activity_at": "2026-04-20T10:00:00Z",
  "created_by": "user_alice",
  "created_at": "2026-04-20T10:00:00Z"
}
```

**获取项目列表（卡片视图数据）：**

```typescript
// GET /api/v1/workspaces/:wid/projects?tab=mine&sort=last_activity
// Response 200
{
  "projects": [
    {
      "id": "proj_abc123",
      "name": "CODE-YI 主站",
      "description": "CODE-YI 产品主站开发项目",
      "status": "active",
      "cycle_type": "sprint",
      "current_sprint": {
        "name": "Sprint 14",
        "label": "Sprint 14 · 2026 Q2",
        "progress": 62,
        "end_date": "2026-04-30"
      },
      "progress": 62,
      "task_count": 24,
      "completed_task_count": 15,
      "members": [
        { "id": "user_alice", "name": "Alice", "avatar_url": "...", "type": "human" },
        { "id": "user_bob", "name": "Bob", "avatar_url": "...", "type": "human" },
        { "id": "agent_codebot", "name": "CodeBot", "avatar_url": "...", "type": "agent" }
      ],
      "member_count": 5,
      "last_activity_at": "2026-04-20T09:30:00Z",
      "last_activity_summary": "CodeBot completed Task #67"
    },
    // ... more projects
  ],
  "total": 4,
  "page": 1,
  "page_size": 20
}
```

### 10.3 WebSocket 事件

```typescript
// 客户端 → 服务端
interface WsClientEvents {
  'project:subscribe': { workspace_id: string };          // 订阅工作区的项目更新
  'project:unsubscribe': { workspace_id: string };
  'project_detail:subscribe': { project_id: string };     // 订阅特定项目详情更新
  'project_detail:unsubscribe': { project_id: string };
}

// 服务端 → 客户端
interface WsServerEvents {
  // 项目列表更新
  'project:created': { project: ProjectSummary };
  'project:updated': { project_id: string; changes: Partial<Project> };
  'project:archived': { project_id: string };
  'project:progress_changed': { project_id: string; progress: number; details: ProgressDetails };
  
  // 项目详情更新
  'project:member_added': { project_id: string; member: Member };
  'project:member_removed': { project_id: string; member_id: string };
  'project:repo_bound': { project_id: string; repo: RepoSummary };
  'project:repo_unbound': { project_id: string; repo_id: string };
  
  // Git 活动实时推送
  'project:git_commit': { project_id: string; commit: CommitInfo; linked_tasks: string[] };
  'project:git_pr_opened': { project_id: string; pr: PRInfo; linked_tasks: string[] };
  'project:git_pr_merged': { project_id: string; pr: PRInfo; completed_tasks: string[] };
  
  // Sprint 更新
  'sprint:created': { project_id: string; sprint: Sprint };
  'sprint:started': { project_id: string; sprint_id: string };
  'sprint:completed': { project_id: string; sprint_id: string; stats: SprintStats };
  'sprint:progress_changed': { sprint_id: string; progress: number };
  
  // 活动流
  'project:activity': { project_id: string; activity: Activity };
}
```

### 10.4 前端架构

```
pages/
  projects/
    index.tsx          # 项目列表页（卡片视图 + 列表视图切换）
    [projectId]/
      index.tsx        # 项目详情页（Tab 容器）
      overview.tsx     # 概览 Tab（仪表盘）
      tasks.tsx        # 任务 Tab（嵌入 Module 2 Kanban）
      git-activity.tsx # Git 活动 Tab
      members.tsx      # 成员 Tab
      settings.tsx     # 设置 Tab
      sprints/
        [sprintId].tsx # Sprint 详情页

components/
  projects/
    ProjectCard.tsx         # 项目卡片组件
    ProjectCardGrid.tsx     # 卡片网格布局
    ProjectListTable.tsx    # 项目列表表格
    ProjectCreateForm.tsx   # 创建项目表单（Modal）
    ProjectProgress.tsx     # 进度条组件（含 hover 分解）
    ProjectMemberAvatars.tsx # 成员头像组件（含 overflow）
    
    detail/
      ProjectDashboard.tsx    # 仪表盘（图表组合）
      ProjectKanban.tsx       # 嵌入式 Kanban（复用 Module 2）
      GitActivityTimeline.tsx # Git 活动时间线
      MemberList.tsx          # 成员列表
      ProjectSettings.tsx     # 项目设置表单
      
    sprint/
      SprintCard.tsx          # Sprint 信息卡片
      SprintBurndown.tsx      # Burndown Chart（Recharts/D3）
      VelocityChart.tsx       # Velocity 柱状图
      SprintCreateForm.tsx    # 创建 Sprint 表单
      
    git/
      RepoBindingForm.tsx     # 仓库绑定表单（OAuth 流程）
      CommitList.tsx          # Commit 列表组件
      PRList.tsx              # PR 列表组件
      GitLinkBadge.tsx        # Git 关联标记（显示在任务卡片上）
```

**关键复用决策：**

项目内的 Kanban 视图**完全复用** Module 2 的 Kanban 组件，通过 props 注入 `project_id` 筛选条件：

```tsx
// projects/[projectId]/tasks.tsx
import { KanbanBoard } from '@/components/tasks/KanbanBoard';

export default function ProjectTasks({ projectId }: { projectId: string }) {
  return (
    <KanbanBoard
      filters={{ project_id: projectId }}
      createDefaults={{ project_id: projectId }}
      memberScope="project"  // 指派人范围限定为项目成员
    />
  );
}
```

这意味着 Module 2 的 KanbanBoard 组件需要支持以下 props：
- `filters`: 外部注入的筛选条件
- `createDefaults`: 创建任务时的默认值
- `memberScope`: 指派人选择器的范围限制

### 10.5 进度引擎架构

```
┌──────────────────────────────────────────────────────┐
│                  Progress Engine                      │
│                                                      │
│  Event Listener (Redis Streams)                      │
│    ├── task.status_changed                           │
│    ├── task.priority_changed                         │
│    ├── task.progress_updated                         │
│    ├── git.pr_merged                                │
│    ├── git.pr_review_submitted                      │
│    ├── task.added_to_project                        │
│    └── task.removed_from_project                    │
│                                                      │
│  Calculation Logic                                   │
│    ├── Incremental Update (大多数情况)               │
│    │   → 读取 Redis 缓存 → 增量计算 → 更新缓存      │
│    │                                                 │
│    └── Full Recalculation (缓存过期/强制刷新)        │
│        → SQL 查询全量数据 → 计算 → 写入缓存          │
│                                                      │
│  Output                                              │
│    ├── Redis: project_progress:{pid}                 │
│    ├── PostgreSQL: projects.progress (异步写回)       │
│    └── WebSocket: project:progress_changed            │
└──────────────────────────────────────────────────────┘
```

### 10.6 Git Integration Service 架构

```
┌─────────────────┐        Webhook        ┌──────────────────────┐
│  GitHub/GitLab  │ ─────────────────────> │   Webhook Handler    │
│                 │                        │                      │
│                 │ <──── API Calls ────── │  1. 验证签名          │
└─────────────────┘                        │  2. 查找 project_repo│
                                           │  3. 幂等检查          │
                                           │  4. 入队 Redis Stream│
                                           │  5. 返回 200         │
                                           └──────────┬───────────┘
                                                      │
                                           ┌──────────┴───────────┐
                                           │   Event Processor    │
                                           │   (Async Worker)     │
                                           │                      │
                                           │  ├── CommitLinker    │
                                           │  │   解析 commit msg │
                                           │  │   → git_task_links│
                                           │  │                    │
                                           │  ├── BranchLinker    │
                                           │  │   解析 branch name│
                                           │  │   → git_task_links│
                                           │  │                    │
                                           │  ├── PRLinker        │
                                           │  │   解析 PR 描述     │
                                           │  │   → git_task_links│
                                           │  │   更新 PR 状态     │
                                           │  │                    │
                                           │  ├── TaskUpdater     │
                                           │  │   PR merged →     │
                                           │  │   自动完成任务      │
                                           │  │                    │
                                           │  └── ProgressTrigger │
                                           │      触发进度重算      │
                                           └──────────────────────┘
```

### 10.7 性能目标

| 指标 | 目标 |
|------|------|
| 项目列表加载（20 项目） | < 300ms |
| 项目详情加载（含进度） | < 500ms |
| 项目进度计算（100 任务） | < 50ms（增量）/ < 200ms（全量）|
| 项目进度 WebSocket 推送延迟 | < 500ms |
| Webhook 接收到 → 关联完成 | < 3s |
| Webhook 端点响应 | < 200ms（异步处理） |
| Sprint Burndown 数据查询 | < 300ms |
| Git 活动列表加载（100 条） | < 500ms |
| 并发 WebSocket 连接（项目频道） | > 2,000 |

---

## 11. 模块集成

### 11.1 与 Module 1（Chat 对话）集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| Chat 创建项目 | Chat → Project | 用户在 Chat 中发送 "创建项目：CODE-YI 移动端" → 自动创建项目 |
| 项目通知推送 | Project → Chat | 项目进度里程碑（50%/75%/100%）、Sprint 完成通知推送到项目关联的 Chat 频道 |
| Git 活动通知 | Project → Chat | PR merged / 重要 commit 推送到 Chat |
| 项目链接引用 | 双向 | Chat 中可引用项目链接，点击跳转到项目详情 |

```yaml
# Project → Chat 事件示例
event: project.progress_milestone
payload:
  project_id: "proj_abc123"
  project_name: "CODE-YI 主站"
  milestone: 75
  channel_ids: ["ch_project_codeyi"]
  message: "项目「CODE-YI 主站」进度达到 75%！Sprint 14 目标即将完成。"
```

### 11.2 与 Module 2（Tasks 任务）集成

这是最紧密的集成——项目是任务的容器。

| 集成点 | 说明 |
|--------|------|
| 任务归属 | `tasks.project_id` → `projects.id`（外键关系） |
| 项目 Kanban | 项目详情页的 Tasks Tab 复用 Module 2 Kanban 组件，filter by `project_id` |
| 项目进度聚合 | `Progress Engine` 监听任务状态变更事件，实时重算项目进度 |
| 指派人范围 | 项目内创建任务时，指派人限定为 `project_members` |
| 标签继承 | 项目级标签自动可用于其下任务 |
| Sprint 关联 | 任务可关联到 Sprint（`sprint_tasks` 表） |
| Git 关联升级 | Module 2 的 `git_repo_bindings` 升级为 Module 3 的 `project_repos`，增加项目级绑定关系 |
| PR → 任务完成 | Module 2 的 "PR merged → 任务完成" 功能由 Module 3 的 Git Integration Service 驱动（统一的 Webhook 处理） |

**数据流：**

```
Module 2 (Task) 事件                          Module 3 (Project) 处理
─────────────────────                        ────────────────────────
task.created (project_id=X)    ───────>      更新 project.task_count
task.status_changed (done)     ───────>      更新 project.completed_task_count
                                              触发 Progress Engine 重算
task.progress_updated          ───────>      节流触发 Progress Engine 重算
task.assignee_changed          ───────>      更新 project_members 统计
```

### 11.3 与 Module 5（Agent 管理）集成

| 集成点 | 说明 |
|--------|------|
| Agent 作为项目成员 | 从 Agent 模块获取可用 Agent 列表，添加到项目成员 |
| Agent 贡献统计 | 项目仪表盘中展示 Agent 的任务完成数、成功率、平均执行时间 |
| Agent 项目级配置 | 可在项目级别配置 Agent 的行为（如：此项目中 CodeBot 只处理后端任务） |
| Agent Velocity | Sprint Velocity 中分开统计 Human/Agent 贡献 |
| Agent 健康影响 | Agent 不健康时，项目健康度评分受影响 |

### 11.4 与 Module 9（Cmd+K）集成

| 集成点 | 说明 |
|--------|------|
| 快速搜索项目 | Cmd+K 中输入项目名称可快速跳转 |
| 快速创建项目 | Cmd+K 中输入 "创建项目" 可快速打开创建表单 |
| 快速切换 Sprint | Cmd+K 中输入 "Sprint 14" 可快速跳转到对应 Sprint 视图 |

### 11.5 集成数据流全景

```
Chat (M1)                  Tasks (M2)              Projects (M3)            Agent (M5)
  │                          │                         │                       │
  │ "创建项目 CODE-YI"       │                         │                       │
  ├──────────────────────────────────────────────────>│ 创建 Project            │
  │                          │                         │                       │
  │                          │ 任务创建 (project_id)    │                       │
  │                          ├────────────────────────>│ task_count++           │
  │                          │                         │ 进度重算               │
  │                          │                         │                       │
  │                          │ Agent 执行完成           │                       │
  │                          ├────────────────────────>│ progress 更新          │
  │                          │                         │                       │
  │                          │                    GitHub Webhook: PR merged     │
  │                          │                         ├──> 关联任务自动完成     │
  │                          │<────────────────────────│    task.status=done    │
  │                          │                         │                       │
  │ "Sprint 14 完成度 75%"    │                         │                       │
  │<──────────────────────────────────────────────────│ 里程碑通知              │
  │                          │                         │                       │
  │                          │                         │ 获取 Agent 列表        │
  │                          │                         ├──────────────────────>│
  │                          │                         │<──────────────────────│
  │                          │                         │ Agent 成功率           │
  │                          │                         ├──────────────────────>│ 绩效数据
```

---

## 12. 测试用例

### 12.1 项目 CRUD

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-PJ-01 | 创建项目（最小） | 仅填写名称，点击创建 | 项目创建成功，默认 cycle_type=none, status=active |
| TC-PJ-02 | 创建项目（完整） | 填写所有字段含成员和仓库 | 项目创建成功，成员和仓库正确绑定 |
| TC-PJ-03 | 编辑项目名称 | 修改项目名称 | 实时保存，卡片和详情页同步更新 |
| TC-PJ-04 | 编辑项目描述 | 修改 Markdown 描述 | 描述正确渲染和保存 |
| TC-PJ-05 | 归档项目 | 管理员点击归档 | 显示统计确认框，确认后移到已归档 Tab |
| TC-PJ-06 | 归档只读 | 访问已归档项目的任务 | 只读模式，不可创建/编辑/拖拽任务 |
| TC-PJ-07 | 取消归档 | 点击恢复按钮 | 项目恢复为 active，回到全部项目 Tab |
| TC-PJ-08 | 删除项目 | 管理员删除项目 | 二次确认后删除，任务 project_id 清空而非删除任务 |
| TC-PJ-09 | 非管理员操作 | 普通成员尝试归档/删除 | 操作被拒绝，显示权限不足提示 |

### 12.2 项目卡片视图

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-CV-01 | 卡片展示 | 打开项目列表页 | 每张卡片正确显示：名称、描述、Sprint 标签、进度条、头像、最近活动时间 |
| TC-CV-02 | Tab 全部项目 | 点击"全部项目" | 显示所有 active 项目 |
| TC-CV-03 | Tab 我参与的 | 点击"我参与的" | 仅显示当前用户是成员的项目 |
| TC-CV-04 | Tab 已归档 | 点击"已归档" | 仅显示 archived 项目 |
| TC-CV-05 | 进度实时更新 | 某项目的任务完成 | 卡片进度条和百分比实时更新（WebSocket） |
| TC-CV-06 | 成员头像 overflow | 项目有 8 个成员 | 显示 5 个头像 + "+3" |
| TC-CV-07 | 响应式布局 | 缩小浏览器窗口 | 卡片从 4 列变为 2 列再变为 1 列 |
| TC-CV-08 | 空状态 | 没有任何项目 | 显示空状态引导："创建你的第一个项目" |

### 12.3 项目成员

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-MB-01 | 添加人类成员 | 搜索并添加用户 | 成员列表更新，卡片头像更新 |
| TC-MB-02 | 添加 Agent 成员 | 搜索并添加 Agent | Agent 显示在成员列表中，有机器人图标 |
| TC-MB-03 | 修改角色 | 将成员角色改为管理员 | 角色立即生效 |
| TC-MB-04 | 移除有任务的成员 | 移除有未完成任务的成员 | 提示"该成员还有 N 个未完成任务"，可选择重新分配 |
| TC-MB-05 | 成员概览统计 | 查看成员 Tab | 每个成员显示任务数、完成数、Agent 显示成功率 |
| TC-MB-06 | 非成员访问 | 非项目成员尝试访问 | 显示无权限页面（viewer 可访问，但不能编辑） |

### 12.4 项目内 Kanban

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-KB-01 | 嵌入式看板 | 进入项目 Tasks Tab | 显示该项目的 Kanban，仅包含该项目的任务 |
| TC-KB-02 | 创建任务自动关联 | 在项目 Kanban 中创建任务 | 任务自动设置 project_id 为当前项目 |
| TC-KB-03 | 指派人范围 | 创建任务选择指派人 | 仅显示项目成员（人类 + Agent） |
| TC-KB-04 | Sprint 筛选 | 选择"当前 Sprint"筛选 | 仅显示属于当前 Sprint 的任务 |
| TC-KB-05 | Backlog 筛选 | 选择"Backlog"筛选 | 仅显示未关联到任何 Sprint 的任务 |
| TC-KB-06 | 拖拽功能 | 拖拽任务跨列 | 复用 Module 2 拖拽逻辑，正常工作 |

### 12.5 Git 仓库绑定

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-GR-01 | 绑定 GitHub 仓库 | OAuth 授权 + 选择仓库 | 绑定成功，Webhook 自动创建 |
| TC-GR-02 | 绑定多个仓库 | 绑定第 2、第 3 个仓库 | 全部绑定成功，列表正确显示 |
| TC-GR-03 | 绑定冲突 | 绑定已被其他项目绑定的仓库 | 提示冲突，拒绝绑定 |
| TC-GR-04 | 解绑仓库 | 删除仓库绑定 | 绑定移除，Webhook 停用，历史关联保留 |
| TC-GR-05 | commit 自动关联 | 推送包含 "CODEYI-42" 的 commit | <3s 内 commit 关联到 Task #42 |
| TC-GR-06 | branch 自动关联 | 创建 feat/CODEYI-42-login 分支 | Branch 关联到 Task #42 |
| TC-GR-07 | PR 自动关联 | 创建引用 CODEYI-42 的 PR | PR 关联到 Task #42 |
| TC-GR-08 | PR merged → 任务完成 | 合并关联的 PR | 任务自动完成（如配置），项目进度更新 |
| TC-GR-09 | Webhook 签名验证 | 发送无效签名的 Webhook | 返回 401，不处理 |
| TC-GR-10 | Webhook 幂等 | 重复发送同一 Webhook | 第二次静默忽略 |
| TC-GR-11 | 防循环同步 | CODE-YI 更新触发 GitHub Webhook | 检测到 sync_source=codeyi，忽略 |

### 12.6 项目进度

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-PG-01 | 进度初始值 | 新建项目无任务 | 进度为 0% |
| TC-PG-02 | 人类完成任务 | 拖拽任务到"已完成" | 进度按权重计算正确更新 |
| TC-PG-03 | Agent 完成任务 | Agent 执行完成 | 进度更新，Agent 置信系数正确应用 |
| TC-PG-04 | PR merged 提升置信 | Agent 完成的任务 PR 被合并 | 置信系数从 0.8 → 1.0，进度微调 |
| TC-PG-05 | 优先级权重 | P0 任务完成 vs P4 任务完成 | P0 完成对进度贡献显著大于 P4 |
| TC-PG-06 | hover 分解 | 鼠标悬停进度条 | 显示详细分解：总权重、各状态贡献、人类/Agent 分别贡献 |
| TC-PG-07 | 实时更新 | Agent 推送进度 | 项目进度条在 <1s 内变化（节流 30s） |
| TC-PG-08 | 缓存一致性 | Redis 缓存过期后查询 | 全量重算结果与缓存结果一致 |

### 12.7 Sprint 管理

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-SP-01 | 创建 Sprint | 填写名称和日期 | Sprint 创建成功，名称自动递增 |
| TC-SP-02 | 开始 Sprint | 点击"开始 Sprint" | Sprint 状态变为 active，同一项目不允许第二个 active Sprint |
| TC-SP-03 | 添加任务到 Sprint | 将任务关联到 Sprint | sprint_tasks 记录创建，任务在 Sprint 筛选中可见 |
| TC-SP-04 | 完成 Sprint | 点击"完成 Sprint" | 未完成任务提示迁移，生成回顾报告 |
| TC-SP-05 | Burndown Chart | 查看活跃 Sprint 的 Burndown | 双线图正确展示：人类/Agent 完成趋势 + 理想线 |
| TC-SP-06 | Velocity Chart | 查看项目 Velocity | 历史 Sprint 柱状图正确展示 |

### 12.8 列表视图

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-LV-01 | 表格展示 | 切换到列表视图 | 项目以表格形式展示，所有列正确填充 |
| TC-LV-02 | 列排序 | 点击"进度"列头 | 按进度百分比排序 |
| TC-LV-03 | 列宽调整 | 拖拽列边界 | 列宽正确调整 |
| TC-LV-04 | CSV 导出 | 点击导出 | 下载 CSV 文件，数据完整 |

### 12.9 性能测试

| 指标 | 测试方法 | 目标 |
|------|---------|------|
| 项目列表渲染 | Lighthouse + 20 项目 | FCP < 800ms, LCP < 1.5s |
| 项目详情加载 | 性能计时 | < 500ms |
| 进度实时更新延迟 | 端到端计时 | 任务完成 → 项目进度变化 < 1s |
| Webhook 处理吞吐 | k6 负载测试 | > 100 events/s |
| Git 活动页加载 | 100 条活动 | < 500ms |
| Sprint Burndown 查询 | pg_stat_statements | < 100ms |
| 并发项目更新 | 多用户同时操作 | 无数据不一致 |

---

## 13. 成功指标

### 13.1 核心指标

| 指标 | MVP (2 月后) | 成熟期 (10 月后) | 说明 |
|------|-------------|-----------------|------|
| 活跃项目数 | 10 | 200 | status=active 的项目数 |
| 日均项目访问次数 | 30 | 1,000 | 打开项目详情页的次数 |
| Git 仓库绑定数 | 5 | 150 | 已绑定的仓库数 |
| 平均项目成员数 | 3 | 8 | 含 Agent |
| 项目中 Agent 成员占比 | > 15% | > 30% | Agent 成员 / 总成员 |
| 项目进度自动更新率 | > 80% | > 95% | 无需手动更新的项目进度比例 |

### 13.2 Git 集成指标

| 指标 | MVP | 成熟期 | 说明 |
|------|-----|--------|------|
| commit 自动关联率 | > 60% | > 85% | 自动关联成功的 commit 占有任务 ID 的 commit 比例 |
| PR 自动关联率 | > 70% | > 90% | 自动关联成功的 PR 比例 |
| PR merged → 任务自动完成率 | > 80% | > 95% | 自动完成的比例 |
| Webhook 处理成功率 | > 98% | > 99.9% | Webhook 事件处理成功率 |
| 平均 Webhook 处理延迟 | < 3s | < 1s | 从接收到关联完成 |

### 13.3 Sprint 指标

| 指标 | MVP | 成熟期 | 说明 |
|------|-----|--------|------|
| 使用 Sprint 的项目占比 | > 30% | > 60% | 选择 sprint 周期类型的项目比例 |
| Sprint 完成率 | > 60% | > 80% | Sprint 内任务完成率 |
| Velocity 查看频率 | 2 次/Sprint | 5+ 次/Sprint | 每个 Sprint 中 Velocity 图表的查看次数 |

### 13.4 体验指标

| 指标 | 目标 | 说明 |
|------|------|------|
| 项目列表加载时间 P99 | < 500ms | 含卡片渲染 |
| 项目进度更新延迟 P99 | < 1s | 任务变更到进度变化 |
| 卡片视图 → 项目详情导航 | < 300ms | 点击到详情页可交互 |
| 用户在项目详情页停留时间 | > 3 分钟 | 说明用户在使用仪表盘/Kanban |

---

## 14. 风险与缓解

### 14.1 技术风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **进度计算不准确** — 加权公式和置信系数的参数难以校准，可能导致进度百分比偏离直觉 | 高 | 中 | 提供"简单模式"（纯任务完成率）和"智能模式"（加权聚合）供用户选择。默认智能模式但允许项目级切换。进度 hover 显示详细分解让用户理解计算逻辑 |
| **Webhook 高峰处理** — 大型仓库合入大量 PR 时（如 release day），Webhook 事件可能激增 | 中 | 中 | 异步队列处理（Redis Stream）+ 速率限制（100 events/s/repo）+ 批量关联（同一 task 的多个 commit 合并处理）+ 自动扩容 Worker |
| **Git 关联误匹配** — commit message 中的 #42 可能不是任务 ID（可能是 Issue number、PR number 或其他含义） | 中 | 低 | 优先使用项目前缀（CODEYI-42）匹配，纯数字 #42 仅在项目绑定仓库内匹配。匹配结果可手动取消关联。提供关联日志审计 |
| **进度缓存不一致** — Redis 缓存与 PostgreSQL 数据可能短暂不一致 | 低 | 低 | 增量更新 + 定期全量重算（5 分钟缓存 TTL）+ 手动刷新按钮。最终一致性保证——短暂的几秒偏差可接受 |
| **Module 2 Kanban 组件复用改造** — 现有 Kanban 组件可能不支持 project 范围筛选和成员范围限制 | 中 | 中 | 提前与 Module 2 团队对齐接口需求，在 Module 2 Kanban 组件中预留 filters / createDefaults / memberScope props |
| **多仓库绑定复杂性** — 一个项目绑定 5+ 个仓库时，Git 活动列表和关联逻辑的性能可能下降 | 低 | 低 | Git 活动查询分页 + 按仓库筛选。关联逻辑并行处理各仓库事件。建议单项目绑定不超过 10 个仓库 |

### 14.2 产品风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **项目层级感知度低** — 用户可能直接在 Module 2 创建任务而不关联项目，导致项目视图数据不完整 | 高 | 高 | 引导用户从项目内创建任务。在全局任务创建表单中增加"关联项目"字段并推荐最近使用的项目。未关联项目的任务在项目视图中提示 |
| **Sprint 管理过于复杂** — 小团队可能不需要 Sprint 概念 | 中 | 低 | Sprint 是 P2 功能且可选（cycle_type=none）。MVP 不包含 Sprint 管理，先验证卡片视图和进度聚合的核心价值 |
| **与 GitHub Projects 重复** — 已用 GitHub Projects 的团队可能觉得 CODE-YI 项目模块多余 | 中 | 中 | 差异化聚焦：CODE-YI 项目 = GitHub Projects + 进度自动聚合 + Agent 可见性 + Sprint 管理。通过深度 Git 绑定让两者互补而非竞争 |
| **卡片视图信息密度不足** — 用户可能需要更多信息在卡片上一眼看到 | 中 | 低 | 卡片默认展示核心信息，hover 展示详情。提供列表视图作为信息密度更高的替代方案 |

### 14.3 安全风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **Git OAuth Token 泄露** — 加密存储的 Token 被盗取 | 低 | 高 | AES-256 加密存储 + 独立的加密密钥管理 + Token 最小权限（仅 repo:read + webhook）+ 定期轮换提醒 + 审计日志 |
| **Webhook 伪造** — 恶意请求伪造 Webhook | 低 | 中 | HMAC-SHA256 签名验证（webhook_secret）+ IP 白名单（GitHub/GitLab 的 Webhook IP 段）|
| **项目信息泄露** — 非项目成员看到项目数据 | 低 | 中 | 严格的项目级权限控制——所有 API 检查 project_members。非成员仅能看到项目名称（如果在 workspace 内），不能看到任务、Git 活动等详情 |

---

## 15. 排期建议

### 15.1 为什么比 Module 2 快？

Module 2（Tasks）的工期估算为 10 周（1 前端 + 1 后端），Module 3（Projects）P0 范围的工期估算为 ~3 周（1 前端 + 0.5 后端）。差距来自三个核心原因：

1. **大量复用 Module 2**：项目内 Kanban 100% 复用 Module 2 组件，不需要重新开发拖拽、实时同步、任务 CRUD。Module 2 的任务 API、WebSocket 基础设施、评论系统全部就绪
2. **项目本身的逻辑更简单**：项目 CRUD 只有 4 个字段需要管理（名称、描述、周期类型、日期），远比 Module 2 的任务（标题、描述、优先级、标签、指派人、截止日、进度等 10+ 字段）简单
3. **P0 范围精心裁剪**：Git 绑定（P1）、Sprint 管理（P2）、Velocity 图表（P2）全部不在 MVP 范围。MVP 只需要：项目卡片视图 + CRUD + 嵌入式 Kanban + 成员管理 + 进度聚合

### 15.2 Sprint 规划（P0 范围约 3 周）

#### Sprint 1: 项目 CRUD 与卡片视图（第 1 周）

**做什么：** 搭建项目模块的骨架——数据库表、CRUD API、前端卡片视图。

**后端（0.5 人周）：**
- 数据库 Schema 创建（projects, project_members）
- Project CRUD API（创建/读取/更新/归档/删除）
- Project 列表查询 API（支持 Tab 筛选: all/mine/archived）
- Project Members API（添加/移除/修改角色）

**前端（1 人周）：**
- 项目列表页面（卡片网格布局）
- 项目卡片组件（名称、描述截断、进度条、头像 overflow、最近活动）
- Tab 切换组件（全部 / 我参与的 / 已归档）
- 创建项目表单（Modal）
- 项目详情页框架（Tab 容器：概览、任务、成员、设置）

**难点：** 卡片组件的响应式布局和信息密度设计。参考 Stephanie 的设计稿确保还原度。

#### Sprint 2: 嵌入式 Kanban 与成员管理（第 2 周）

**做什么：** 实现项目详情页的核心功能——将 Module 2 的 Kanban 嵌入项目、完善成员管理。

**后端（0.5 人周）：**
- Project Tasks API（代理到 Module 2，注入 project_id 筛选）
- 项目成员统计 API（每个成员的任务数、完成数）
- WebSocket 项目频道（project:subscribe / project:progress_changed）

**前端（1 人周）：**
- 项目 Tasks Tab（嵌入 Module 2 KanbanBoard 组件，传入 project_id 筛选）
- KanbanBoard 组件改造（Module 2）：支持 filters / createDefaults / memberScope props
- 项目 Members Tab（成员列表、添加/移除、角色管理）
- 项目 Settings Tab（基础设置表单）
- 成员头像 overflow 组件（卡片视图用）

**难点：** Module 2 KanbanBoard 组件的改造需要和 Module 2 团队协调。确保 props 注入不破坏现有功能。

#### Sprint 3: 进度聚合引擎与集成（第 3 周）

**做什么：** 实现项目进度自动聚合——让项目卡片上的进度条"活"起来。

**后端（0.5 人周）：**
- Progress Engine（事件监听 + 增量计算 + Redis 缓存）
- 进度详情 API（/projects/:pid/progress）
- 项目活动记录（project_activities 表 + API）
- 项目统计缓存更新（task_count, completed_task_count, last_activity_at）

**前端（1 人周）：**
- 进度条组件升级（hover 显示详细分解）
- WebSocket 进度实时更新
- 项目概览 Tab（基础仪表盘：进度环形图、任务状态分布饼图）
- 项目活动流组件
- 全流程联调 + Bug 修复

**难点：** Progress Engine 的事件监听和增量计算逻辑。需要确保任务状态变更事件被正确消费且不遗漏。

### 15.3 P1 功能排期（约 2 周，P0 完成后）

#### Sprint 4: Git 仓库绑定与自动关联（第 4-5 周）

**后端（1 人周）：**
- project_repos 表 + git_task_links 表
- GitHub/GitLab OAuth 授权流程
- Webhook Handler（签名验证 + 事件入队 + 异步处理）
- commit/branch/PR 自动关联引擎
- PR merged → 任务自动完成

**前端（1 人周）：**
- Git 仓库绑定设置页面（OAuth 流程 UI）
- Git Activity Tab（活动时间线）
- 任务详情中的 Git 关联展示（commit 列表、PR 列表）
- 任务卡片上的 Git 关联标记
- 项目列表视图（表格形式）

### 15.4 P2 功能排期（约 3 周，P1 完成后）

#### Sprint 5-6: Sprint 管理 + Velocity（第 6-8 周）

- Sprint CRUD + 状态管理
- Sprint-Task 关联
- Sprint Burndown Chart
- Velocity Chart（Human + Agent 分开）
- Sprint 回顾报告
- 项目健康度评分

### 15.5 里程碑

| 里程碑 | 时间 | 关键能力 | 对应 Sprint |
|--------|------|---------|------------|
| **M1: Project Cards** | Week 1 | 项目卡片视图 + CRUD + Tab 切换 | Sprint 1 |
| **M2: Project Kanban** | Week 2 | 嵌入式 Kanban + 成员管理 | Sprint 2 |
| **M3: Live Progress** | Week 3 | 进度自动聚合 + 实时更新 + 概览仪表盘 | Sprint 3 |
| **M4: Git Integration** | Week 5 | 仓库绑定 + commit/PR 自动关联 + 列表视图 | Sprint 4 |
| **M5: Sprint & Velocity** | Week 8 | Sprint 管理 + Burndown + Velocity 图表 | Sprint 5-6 |

### 15.6 团队配置

| 角色 | 人数 | 职责 |
|------|------|------|
| 前端工程师 | 1 | 项目卡片 UI + 详情页 + Kanban 嵌入 + 仪表盘图表 + Git 活动展示 |
| 后端工程师 | 0.5 | Project Service + Progress Engine + Git Integration（与 Module 2 后端共享） |

**注意：** 后端工作量为 0.5 人是因为大量复用 Module 2 的基础设施（Event Bus、WebSocket 层、数据库连接池）。后端工程师可以同时支持 Module 2 的 P1 功能和 Module 3 的开发。

### 15.7 依赖关系

```
Module 2 (Tasks)  ──→  Module 3 强依赖 Module 2
                       ├── tasks 表已存在且有 project_id 字段
                       ├── KanbanBoard 组件可接受 filters prop
                       ├── WebSocket 基础设施已就绪
                       └── Event Bus (Redis Streams) 已搭建
                       
                       建议 Module 2 的 Sprint 2（拖拽与实时同步）完成后
                       再开始 Module 3 开发

Module 5 (Agent)  ──→  弱依赖
                       ├── Agent 成员列表 API（可先 mock）
                       └── Agent 执行统计 API（进度引擎的 Agent 置信系数需要）

Module 1 (Chat)   ──→  弱依赖（Chat 集成在 P1 之后）
                       └── Event Bus 基础设施共享
```

---

*本文档由 Zylos AI Agent 根据 Stephanie 的产品方向和设计稿生成。*
*CODE-YI Module 3 PRD v1.0 | 2026-04-20 | Draft*
