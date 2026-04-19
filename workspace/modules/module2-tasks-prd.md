# CODE-YI Module 2: 任务 (Tasks) — 产品需求文档

> **版本:** v1.0  
> **日期:** 2026-04-19  
> **作者:** Zylos AI Agent (by Stephanie's direction)  
> **状态:** Draft  

---

## 目录

1. [问题陈述](#1-问题陈述)
2. [产品愿景](#2-产品愿景)
3. [竞品对标](#3-竞品对标)
4. [技术突破点](#4-技术突破点)
5. [用户故事](#5-用户故事)
6. [功能拆分](#6-功能拆分)
7. [Agent 任务执行模型](#7-agent-任务执行模型)
8. [数据模型](#8-数据模型)
9. [技术方案](#9-技术方案)
10. [与其他模块的集成](#10-与其他模块的集成)
11. [测试用例](#11-测试用例)
12. [成功指标](#12-成功指标)
13. [风险与缓解](#13-风险与缓解)
14. [排期建议](#14-排期建议)

---

## 1. 问题陈述

### 1.1 现有任务管理工具的结构性缺陷

当前主流任务管理工具（Jira、Linear、GitHub Projects、Asana、ClickUp）均诞生于"人管理人的工作"的范式。它们的核心假设是：**任务的执行者永远是人类**。AI 在这些系统中的角色始终是辅助性的——帮忙写摘要、推荐标签、预测工期——但从不真正"做"任务。

**Jira 的局限：**
- 2026 年 2 月推出"Agents in Jira"，允许将工单分配给 AI Agent，但**执行环境与 Jira 脱钩**：Agent 在外部系统执行，Jira 仅作为状态展示板
- 没有实时进度可视化——Agent 执行过程是黑箱，用户只能看到最终状态变更
- 任务模型过于复杂（Epic → Story → Subtask → Bug），对 Agent 不友好——Agent 不需要估点、不需要 Sprint Planning
- 自动化规则（Automation for Jira）停留在"状态变更触发"层面，不支持"Agent 执行结果 → 下一步决策"的智能路由

**Linear 的局限：**
- 2026 年 3 月推出 Linear Agent，支持 Skills（可重复工作流）和 Automations（自动触发），但**核心定位仍是 Issue Tracker**
- Code Intelligence 可以理解代码库，但 Agent 不能直接在 Linear 中执行代码——需要跳转到 Cursor/Devin 等外部工具
- 与第三方 AI Agent（Cursor、Devin）的连接通过 MCP（Mission Control Plane），但这意味着**任务执行发生在 Linear 之外**，用户必须切换多个工具才能看到完整的执行过程
- 自动化和 Code Intelligence 仅限 Business/Enterprise 计划，中小团队无法使用

**GitHub Projects 的局限：**
- Copilot Coding Agent 可以被分配 Issue 并自动创建 PR，这是最接近"Agent 做任务"的实现
- 但**局限于代码类任务**——无法处理设计、文档、测试、运维等非编码工作
- 项目管理能力薄弱——没有优先级体系（P0-P4）、没有标签分类、没有进度百分比
- Kanban 视图功能原始，不支持复杂筛选和视图自定义
- Agentic Workflows 要求用 Markdown 描述工作流并在 GitHub Actions 中运行，门槛高

**Asana 的局限：**
- AI Studio 提供无代码 Agent 构建器，但**Agent 仅能做内容生成和流程推进**——生成摘要、起草目标、分类请求
- AI Teammates 本质上是"智能表单填充器"，不能执行真正的开发任务
- 规则引擎（Asana Rules）固定于 trigger-action 模式，不支持 Agent 执行结果的条件路由
- 高级 AI 功能（AI Studio）作为付费 Add-on 仅限 Advanced/Enterprise 计划

**ClickUp 的局限：**
- ClickUp Brain 的 Autopilot Agents 可以自动创建任务、分配任务、更新状态
- 但核心问题与 Asana 相同：**Agent 做的是"项目管理"，不是"项目执行"**——Agent 帮你管理任务，而不是完成任务
- 自然语言自动化很方便，但限于 ClickUp 内部操作（移动任务、改状态、发评论）
- AI 功能需额外付费（$7/用户/月），且 Agent 能力依赖外部模型（GPT-5、Claude），没有自己的执行运行时

### 1.2 核心洞察

```
传统工具：人创建任务 → 人执行任务 → 人更新状态
Jira/Linear 2026：人创建任务 → Agent 辅助（外部执行）→ 人手动同步状态
CODE-YI：人或 Agent 创建任务 → Agent 原生执行 → 状态自动更新 → 结果实时可见
```

**没有任何现有工具实现了完整的闭环：** 在同一个界面中创建任务、分配给 Agent、实时观看 Agent 执行过程、自动获得执行结果——全部无需离开任务管理系统。

### 1.3 市场机会

- Gartner 预测 2026 年 30% 的软件开发任务将由 AI Agent 执行，但目前没有一个任务管理系统为此做好准备
- Linear CEO 宣布"Issue Tracking 已死"，但 Linear Agent 仍然是 Issue Tracker 上加 AI，没有从根本上重新设计任务管理
- GitHub Copilot Coding Agent 证明了"把 Issue 分配给 AI"的可行性，但其能力仅限于编码任务
- **空白市场：一个让 AI Agent 成为一等公民的任务管理系统，既能管理任务，又能执行任务**

---

## 2. 产品愿景

### 2.1 一句话定位

**CODE-YI 任务模块是全球首个将 AI Agent 作为一等任务执行者的 Kanban 系统——Agent 不只是被分配任务，而是自主执行任务、实时报告进度、自动交付结果。**

### 2.2 核心价值主张

```
┌─────────────────────────────────────────────────────────────────┐
│                    CODE-YI 任务系统                              │
├─────────────────┬──────────────────┬────────────────────────────┤
│ 人类任务管理     │ Agent 原生执行    │ 智能协作闭环                │
│                 │                  │                            │
│ Kanban 拖拽     │ 一键指派给 Agent  │ PR merged → 任务自动完成    │
│ 优先级/标签/截止日│ 实时进度条        │ Agent 失败 → 通知人类       │
│ 多视图筛选       │ 执行日志流式展示   │ Chat @创建 → Kanban 同步   │
│ 跨项目管理       │ 结果报告自动附加   │ GitHub Issue ↔ Task 双向   │
└─────────────────┴──────────────────┴────────────────────────────┘
```

### 2.3 核心差异化

| 维度 | Jira/Linear | GitHub Projects | ClickUp/Asana | CODE-YI |
|------|-------------|-----------------|---------------|---------|
| Agent 作为执行者 | 外部跳转执行 | 仅限编码任务 | 仅做管理不做执行 | **原生执行，全类型任务** |
| 执行过程可见性 | 黑箱，仅最终状态 | PR 为唯一产出物 | 无执行过程 | **实时进度条 + 执行日志流** |
| Agent 失败处理 | 手动检查 | PR Review 才发现 | 不适用 | **自动检测 + 人类降级 + 重试** |
| Git 集成深度 | Webhook 级别 | 原生但单向 | 浅层集成 | **Issue ↔ Task 双向实时同步** |
| 任务创建方式 | 表单/CLI | Issue 模板 | 表单/AI 生成 | **Chat @创建 + 表单 + Agent 创建** |
| 自动化智能度 | 规则引擎 (if-then) | GitHub Actions | 规则引擎 | **基于 Agent 执行结果的条件路由** |
| 进度追踪 | 手动更新百分比 | 无百分比 | 手动更新 | **Agent 自动更新，人工可覆盖** |

### 2.4 设计理念

**"Assign and Forget, but Always Visible"** ——指派即忘，但全程可见。

用户将任务指派给 Agent 后，不需要手动推进——Agent 自动拉取上下文、执行工作、更新进度、提交结果。但整个过程是透明的：用户随时可以查看 Agent 在做什么、到了哪一步、预计什么时候完成。如果 Agent 遇到问题，系统自动通知相关人员。

---

## 3. 竞品对标

### 3.1 Kanban 实现对比

| 功能 | Linear | Jira | GitHub Projects | Asana | ClickUp | CODE-YI |
|------|--------|------|-----------------|-------|---------|---------|
| 拖拽排序 | 流畅 | 中等 | 基础 | 流畅 | 流畅 | 流畅 |
| 自定义列 | 支持 | 支持 | 支持 | 支持 | 支持 | 4 列固定 + 可扩展 |
| 多人实时协作 | 支持 | 延迟较高 | 支持 | 支持 | 支持 | WebSocket 实时 |
| 卡片信息密度 | 中等 | 高（过多） | 低 | 中等 | 高 | **最优——标签/头像/优先级/进度/截止日** |
| 视图切换 | Kanban/List/Calendar | Kanban/Board/List | Table/Board | List/Board/Calendar/Timeline | 15+ 视图 | Kanban（P0）+ List/Calendar（P2）|
| WIP Limit | 不支持 | 支持 | 不支持 | 不支持 | 支持 | P2 考虑 |

### 3.2 AI/Agent 集成对比

| 能力 | Linear Agent | Jira AI | GitHub Copilot | Asana AI | ClickUp Brain | CODE-YI |
|------|-------------|---------|----------------|----------|---------------|---------|
| Agent 可被指派任务 | 间接（MCP 转发） | 支持（2026.2）| 支持（Issue → Copilot）| 不支持 | 间接 | **原生支持** |
| Agent 执行代码任务 | 通过 Cursor/Devin | 外部 Agent | 原生（创建 PR）| 不支持 | 不支持 | **原生执行** |
| 实时进度报告 | 不支持 | 不支持 | 无（PR ready 才可见）| 不支持 | 不支持 | **WebSocket 流式更新** |
| Agent 执行非编码任务 | Skills（有限）| 有限 | 不支持 | AI Studio（有限）| Autopilot（有限）| **全类型任务** |
| 失败自动处理 | 手动 | 手动 | PR Review | 不适用 | 不适用 | **自动重试 + 降级通知** |
| Agent 自动创建任务 | Automations | 支持 | 不支持 | 规则触发 | 支持 | **支持（Chat 触发 + 自主创建）** |
| Agent 成功率追踪 | 不支持 | 支持（2026）| 不支持 | 不支持 | 不支持 | **内置 Agent 绩效面板** |
| 价格门槛 | Business+ | Enterprise | Copilot 订阅 | Advanced+ Add-on | $7/人/月 Add-on | **核心功能免费** |

### 3.3 自动化能力对比

| 能力 | Linear | Jira | GitHub | Asana | ClickUp | CODE-YI |
|------|--------|------|--------|-------|---------|---------|
| 基础规则 (if-then) | 支持 | 支持 | Actions | Rules | 100+ 模板 | 支持 |
| PR merged → 任务完成 | 支持 | 插件实现 | 原生 | 不支持 | Webhook | **原生 + 自定义** |
| Agent 结果 → 下一步路由 | 不支持 | 不支持 | 不支持 | 不支持 | 不支持 | **支持** |
| 自然语言定义规则 | 不支持 | 不支持 | Markdown | 不支持 | 支持 | P2 |
| 跨系统自动化 | 有限 | 丰富 | GitHub 生态 | 丰富 | 丰富 | **聚焦 Git + Chat 深度集成** |

### 3.4 竞品总结

**Linear** 是最接近的竞争者——产品理念先进、Agent 集成方向正确。但 Linear 的 Agent 本质上是"Linear 内部的 AI 助手"，不是通用的任务执行者。它可以帮你分类 Issue、写规格文档，但不能帮你写代码、做设计、跑测试。

**GitHub Copilot Coding Agent** 在"Agent 执行编码任务"这个垂直领域做得最好——直接分配 Issue，自动创建 PR。但它不是通用任务管理系统，也没有 Kanban、优先级、标签等基础能力。

**CODE-YI 的独特定位：** 既有 Linear 级别的任务管理体验，又有 GitHub Copilot Agent 级别的执行能力，同时覆盖编码之外的所有任务类型。

---

## 4. 技术突破点

### 4.1 突破 1：Agent 作为一等任务执行者

**传统模型：** 任务系统只管理状态（待办 → 进行中 → 完成），执行发生在系统之外。

**CODE-YI 模型：** 任务系统既管理状态，又驱动执行。当任务被指派给 Agent 时，系统自动触发 Agent 运行时，在平台内完成整个执行生命周期。

```
传统: Task(status) ──手动更新──> Task(new_status)
                    ↑ 人类在外部工具执行

CODE-YI: Task(assigned_to_agent) ──自动触发──> AgentRuntime.execute()
              ──实时更新──> Task(progress: 45%)
              ──执行完成──> Task(done) + ResultReport + PR/Artifact
```

**关键技术要求：**
- Task → Agent 指派事件必须在 <500ms 内触发 Agent Runtime
- Agent Runtime 必须能访问任务上下文（标题、描述、标签、关联的 Git 仓库、历史评论）
- 进度更新必须是流式的（WebSocket），不是轮询

### 4.2 突破 2：实时进度可视化

Agent 执行任务不是黑箱。用户可以在 Kanban 卡片上直接看到：
- **进度条（0-100%）：** Agent 自动更新，基于执行阶段计算
- **当前步骤文字：** "正在分析代码库结构..." / "正在编写单元测试 (3/7)..."
- **执行日志流：** 点击卡片可展开实时日志，类似 CI/CD 的日志流
- **预估剩余时间：** 基于历史执行数据和当前进度推算

**传统 CI/CD 可视化 vs CODE-YI 任务可视化的区别：**
CI/CD 展示的是"机器在跑什么命令"，CODE-YI 展示的是"Agent 在做什么决策"。例如：
```
CI/CD: $ npm run test ... 45 passed, 2 failed
CODE-YI: Agent 分析了测试失败原因，发现是 API 端点变更导致。正在修改 2 个测试用例...
```

### 4.3 突破 3：基于执行结果的智能路由

传统自动化规则：`IF status changes to "done" THEN send notification`

CODE-YI 自动化规则：`IF Agent execution result contains "PR created" THEN auto-link PR to task AND trigger review Agent`

```yaml
# 传统规则引擎（所有竞品）
trigger: status_changed
condition: new_status == "done"
action: send_notification

# CODE-YI 智能路由
trigger: agent_execution_completed
conditions:
  - result.type == "code_change"
  - result.pr_url != null
actions:
  - link_pr_to_task(result.pr_url)
  - assign_review_agent("review-bot")
  - IF result.test_coverage < 80%:
      notify_human("测试覆盖率不足，请补充测试")
```

### 4.4 突破 4：双向 Git 同步

不是简单的 Webhook 通知，而是真正的双向实时同步：

| 方向 | 触发 | 结果 |
|------|------|------|
| GitHub Issue → Task | Issue 创建/更新 | 自动创建/更新 Task，映射标签和指派人 |
| Task → GitHub Issue | Task 创建/更新 | 自动创建/更新 Issue |
| PR merged | Webhook 事件 | 关联 Task 自动标记完成 |
| Task 指派 Agent | Agent 执行完成 | 自动在 Issue 中评论结果报告 |
| Issue 评论 | Webhook 事件 | 同步到 Task 评论 |
| Task 评论 | 用户/Agent 评论 | 同步到 Issue 评论 |

**冲突解决策略：** Last-Write-Wins + 冲突日志。双向同步的脏数据风险通过以下机制缓解：
- 每次同步携带 `sync_version` 字段
- 如果双方同时修改同一字段，以最后写入为准，同时记录冲突日志
- 管理员可在设置中选择"以 CODE-YI 为准"或"以 GitHub 为准"的冲突策略

### 4.5 突破 5：Chat → Task 无缝创建

在对话（Module 1）中 @提及即可创建任务：

```
用户在 Chat 中: "@TaskBot 创建一个 P1 任务：实现用户登录 API，指派给 CodeBot"
                           ↓
TaskBot 自动解析: title="实现用户登录 API", priority=P1, assignee=CodeBot
                           ↓
Kanban 中出现新卡片，CodeBot 自动开始执行
                           ↓
执行状态实时同步回 Chat 频道
```

---

## 5. 用户故事

### 5.1 人类创建和管理任务（基础 Kanban）

#### US-2.01: Kanban 看板

**作为**团队成员，**我希望**在 Kanban 看板上查看和管理任务，**以便**直观了解项目状态。

**验收标准：**
- 看板默认四列：待办（To Do）→ 进行中（In Progress）→ 已完成（Done）→ 已归档（Archived）
- 每列显示任务数量
- 支持拖拽任务在列之间移动，拖拽动画流畅（60fps），拖拽过程有占位指示器
- 多人同时操作时，其他用户的拖拽在 <300ms 内同步到我的界面
- 支持同一列内拖拽排序（sort_order 更新）
- 空列显示引导文案："拖拽任务到这里"或"暂无任务"
- 看板支持响应式布局（桌面端横向排列，移动端纵向折叠）

#### US-2.02: 任务卡片

**作为**团队成员，**我希望**任务卡片展示关键信息，**以便**不需要打开详情就能了解任务状况。

**验收标准：**
- 卡片显示：标题、标签（彩色标签，如 设计/前端/Agent/DevOps/文档/测试）、优先级标识（P0 红色 → P4 灰色）、指派人头像（人类圆形/Agent 带机器人角标）、截止日期（过期标红）、进度条（0-100%）
- Agent 执行中的卡片有"脉动"动画指示器
- P0 任务有红色左边框高亮
- 卡片支持右键菜单：编辑、指派、移动、归档、删除
- 点击卡片打开详情侧面板（不跳转页面）

#### US-2.03: 创建任务

**作为**团队成员，**我希望**快速创建任务，**以便**不被繁琐的表单打断工作流。

**验收标准：**
- 在任意列顶部点击"+"快速创建——仅需输入标题，按 Enter 即可
- 创建后可展开编辑：描述（支持 Markdown）、标签（多选）、优先级（P0-P4 下拉）、指派人（搜索人类或 Agent）、截止日期（日历选择器）、关联项目
- 支持 Cmd+K 全局快捷键创建任务
- 创建任务时如果选择 Agent 为指派人，显示确认提示："Agent 将自动开始执行此任务"

#### US-2.04: 筛选视图

**作为**团队成员，**我希望**按不同维度筛选任务，**以便**快速聚焦关注的内容。

**验收标准：**
- 预设快捷筛选：全部 / 我负责的 / Agent 执行中 / 高优先级（P0+P1）
- 高级筛选：按项目、按标签、按指派人（支持多选）、按截止日期范围、按创建者
- 筛选条件可组合，支持保存为自定义视图
- URL 携带筛选参数（可分享链接）
- 筛选结果数量显示在筛选标签旁

### 5.2 人类指派任务给 Agent，Agent 自动执行

#### US-2.05: 指派给 Agent

**作为**团队负责人，**我希望**将任务指派给 Agent，**以便** Agent 自动执行开发工作。

**验收标准：**
- 在指派人下拉中，Agent 与人类混合展示，Agent 有机器人图标标识
- 选择 Agent 后弹出确认对话框："确认将此任务指派给 [Agent名]？Agent 将自动开始执行。"
- 确认后，任务状态自动从"待办"变为"进行中"
- Agent 在 <5s 内开始执行，卡片出现"执行中"脉动指示器
- 如果 Agent 当前有其他正在执行的任务，系统提示"Agent 当前正在执行 [X] 个任务，新任务将排队等待"或根据 Agent 并发能力直接开始

#### US-2.06: Agent 实时进度展示

**作为**任何团队成员，**我希望**看到 Agent 执行任务的实时进度，**以便**了解工作推进情况。

**验收标准：**
- Kanban 卡片上的进度条实时更新（WebSocket 推送，非轮询）
- 进度条下方显示当前步骤文字（如"正在分析需求..."、"代码编写中 3/5..."）
- 点击卡片打开详情面板，显示完整的执行日志流（类似 CI/CD 日志，自动滚动到底部）
- 执行日志中不同类型的事件用不同颜色标识：信息（蓝色）、成功（绿色）、警告（橙色）、错误（红色）
- 如果 Agent 在等待外部响应（如 CI 运行），状态显示"等待中"并说明原因

#### US-2.07: Agent 执行完成

**作为**任务创建者，**我希望** Agent 完成任务后自动提交结果，**以便**我无需手动收集产出物。

**验收标准：**
- Agent 完成后，任务状态自动变为"已完成"
- 任务评论区自动附加结果报告，包含：执行摘要、耗时、产出物链接（PR URL、文件链接等）
- 如果产出物包含 PR，PR URL 自动关联到任务详情
- 结果报告使用结构化格式渲染（不是纯文本）
- 任务创建者收到完成通知（通知方式遵循用户偏好设置）

#### US-2.08: Agent 执行失败

**作为**任务创建者，**我希望** Agent 失败时系统自动通知我，**以便**我能及时介入处理。

**验收标准：**
- Agent 执行失败后，任务状态变为"需要关注"（特殊子状态，仍在"进行中"列但有错误图标）
- 任务评论区附加错误报告：失败原因、失败时的步骤、Agent 的诊断分析、建议的解决方案
- 任务创建者 + 项目管理员收到即时通知
- 通知中包含一键操作："重试" / "转给人类" / "查看详情"
- 如果配置了自动重试规则，Agent 在第一次失败后自动重试（最多 N 次，可配置）
- 重试次数用尽后才通知人类

### 5.3 GitHub/GitLab Issue 同步

#### US-2.09: GitHub Issue → Task 同步

**作为**使用 GitHub 的团队，**我希望** GitHub Issue 自动同步到 CODE-YI Task，**以便**我在一个界面管理所有任务。

**验收标准：**
- 管理员在项目设置中配置 GitHub 仓库绑定（OAuth 授权）
- 配置后，仓库中的 Issue 自动创建对应 Task
- 映射规则：Issue title → Task title, Issue body → Task description, Issue labels → Task labels（可配置映射表）, Issue assignee → Task assignee（如果匹配到已有成员）
- Issue 状态变更同步到 Task（open → 待办, closed → 已完成）
- 同步方向可配置：仅 GitHub → CODE-YI / 仅 CODE-YI → GitHub / 双向

#### US-2.10: Task → GitHub Issue 同步

**作为**团队成员，**我希望**在 CODE-YI 创建的任务自动同步到 GitHub Issue，**以便**外部协作者也能看到。

**验收标准：**
- 创建 Task 时可选择"同步到 GitHub"
- 同步后 Task 详情显示关联的 Issue URL
- Task 状态变更同步到 Issue（进行中 → 不变, 完成 → close Issue, 归档 → close + label:archived）
- Task 评论同步到 Issue 评论（可选，默认关闭以避免噪音）
- 避免同步风暴：CODE-YI 的更新触发 GitHub Webhook 返回时，通过 `sync_source` 标记避免循环

### 5.4 任务评论

#### US-2.11: 人类评论

**作为**团队成员，**我希望**在任务中留评论讨论细节，**以便**沟通集中在任务上下文中。

**验收标准：**
- 评论支持 Markdown、@mention（人类和 Agent）、文件附件
- @mention Agent 会触发 Agent 在评论区回复
- 评论实时推送给所有任务关注者
- 支持编辑和删除自己的评论

#### US-2.12: Agent 自动评论

**作为**任务关注者，**我希望** Agent 在执行过程中自动发布关键节点的评论，**以便**我了解执行进展。

**验收标准：**
- Agent 在以下节点自动发布评论：开始执行、遇到重大决策点、完成关键子步骤、执行完成/失败
- Agent 评论有特殊标识（机器人图标 + 自动生成标签）
- Agent 完成后的最终评论是结构化的结果报告
- 可在 Agent 设置中配置评论频率：精简（仅开始/结束）/ 标准（关键节点）/ 详细（全部步骤）

### 5.5 自动化规则

#### US-2.13: PR Merged 自动完成任务

**作为**开发者，**我希望** PR 合并后关联的任务自动标记为完成，**以便**不需要手动更新状态。

**验收标准：**
- 任务可关联 PR（手动关联或 Agent 执行时自动关联）
- 当关联的 PR 被合并，任务状态自动变为"已完成"
- 自动完成时在评论区附加说明："由 PR #123 合并自动完成"
- 如果任务关联多个 PR，可配置：全部合并后完成 / 任一合并后完成

#### US-2.14: Agent 成功率告警

**作为**管理员，**我希望** Agent 成功率过低时收到告警，**以便**我及时排查问题。

**验收标准：**
- 系统持续追踪每个 Agent 的任务成功率（过去 7 天滚动窗口）
- 当成功率 < 80% 时，发送告警通知给管理员
- 告警内容包含：Agent 名称、当前成功率、失败任务列表、常见失败原因统计
- 告警通知发送到管理员配置的渠道（Chat 通知 / 邮件）

#### US-2.15: 自定义自动化规则

**作为**管理员，**我希望**创建自定义自动化规则，**以便**团队特定的工作流被自动执行。

**验收标准：**
- 可视化规则构建器：触发条件（事件选择）→ 条件过滤 → 执行动作
- 支持的触发事件：任务创建、状态变更、Agent 执行完成/失败、PR 事件、评论新增、截止日期临近
- 支持的动作：修改任务属性、发送通知、指派给 Agent/人类、创建新任务、在 Chat 中发消息
- 规则可启用/禁用，支持测试运行（dry run）
- 规则执行有日志，可查看历史执行记录

---

## 6. 功能拆分

### P0 核心功能（MVP）

| 编号 | 功能 | 子功能 | 说明 |
|------|------|--------|------|
| F-P0-01 | **Kanban 看板** | 四列布局 | 待办/进行中/已完成/已归档 |
| | | 拖拽排序 | react-beautiful-dnd 或 @dnd-kit, 60fps 动画 |
| | | 实时同步 | WebSocket 推送多人操作，<300ms 同步 |
| | | 列统计 | 每列任务数、总进度 |
| F-P0-02 | **任务卡片** | 信息展示 | 标题/标签/优先级/指派人/截止日/进度 |
| | | 快速创建 | 列顶部"+"，仅需标题 |
| | | 详情面板 | 侧滑面板，不跳转页面 |
| | | 编辑/删除 | 右键菜单 + 详情面板内编辑 |
| F-P0-03 | **指派给 Agent** | Agent 选择器 | 指派人下拉中混合展示人类和 Agent |
| | | 自动触发执行 | 指派后 <5s 触发 Agent Runtime |
| | | 实时进度条 | WebSocket 推送进度 0-100% |
| | | 步骤文字 | 当前执行步骤的人类可读描述 |
| | | 结果附加 | 完成后自动附加结果报告到评论 |
| F-P0-04 | **筛选视图** | 快捷筛选 | 全部/我负责的/Agent 执行中/高优先级 |
| | | 高级筛选 | 项目/标签/指派人/日期/创建者组合 |
| | | URL 参数 | 筛选条件编码到 URL |
| F-P0-05 | **任务评论** | 人类评论 | Markdown + @mention + 附件 |
| | | Agent 自动评论 | 关键节点自动发布 |
| | | 结果报告 | Agent 完成后结构化报告 |
| F-P0-06 | **优先级体系** | P0-P4 | 5 级优先级，视觉区分 |
| | | 排序权重 | 高优先级任务默认排在列顶部 |
| F-P0-07 | **标签系统** | 预设标签 | 设计/前端/后端/Agent/DevOps/文档/测试 |
| | | 自定义标签 | 项目级自定义，颜色可选 |

### P1 重要功能（第二阶段）

| 编号 | 功能 | 子功能 | 说明 |
|------|------|--------|------|
| F-P1-01 | **GitHub/GitLab 同步** | OAuth 配置 | 仓库绑定向导 |
| | | Issue → Task | 自动创建 + 状态同步 |
| | | Task → Issue | 可选双向同步 |
| | | 标签映射 | 可配置的标签对应关系 |
| | | 冲突处理 | sync_version + 冲突日志 |
| F-P1-02 | **PR 关联** | 手动关联 | 任务详情中添加 PR URL |
| | | 自动关联 | Agent 执行创建的 PR 自动关联 |
| | | 状态联动 | PR merged → 任务完成 |
| F-P1-03 | **Agent 失败处理** | 自动重试 | 可配置重试次数和间隔 |
| | | 人类降级 | 重试用尽后通知人类接手 |
| | | 错误报告 | 结构化失败分析 |
| F-P1-04 | **执行日志流** | 实时日志 | 类 CI/CD 日志界面 |
| | | 颜色编码 | 信息/成功/警告/错误 |
| | | 日志搜索 | 全文搜索执行日志 |
| F-P1-05 | **任务通知** | 状态变更通知 | 指派/完成/失败 |
| | | 评论通知 | @mention + 新评论 |
| | | 截止提醒 | 截止日期临近提醒（1天前/当天） |
| | | 偏好设置 | 通知渠道和频率可配置 |
| F-P1-06 | **任务活动流** | 操作记录 | 所有变更的时间线 |
| | | 人/Agent 标识 | 区分人工操作和 Agent 操作 |

### P2 增强功能（第三阶段）

| 编号 | 功能 | 子功能 | 说明 |
|------|------|--------|------|
| F-P2-01 | **自动化规则引擎** | 可视化构建器 | 拖拽式规则配置 |
| | | 条件路由 | 基于 Agent 执行结果的智能路由 |
| | | 规则模板 | 预设常见自动化模板 |
| | | 执行日志 | 规则执行历史 |
| F-P2-02 | **Agent 成功率监控** | 绩效面板 | 成功率/平均耗时/任务量 |
| | | 告警规则 | 成功率 < 阈值时通知 |
| | | 失败分析 | 常见失败原因统计 |
| F-P2-03 | **多视图** | 列表视图 | 表格化展示 |
| | | 日历视图 | 按截止日期排列 |
| | | 时间线视图 | 甘特图风格 |
| F-P2-04 | **批量操作** | 多选 | Shift+点击多选 |
| | | 批量修改 | 批量改标签/优先级/指派人 |
| | | 批量归档 | 一键归档已完成任务 |
| F-P2-05 | **任务模板** | 预设模板 | 常见任务类型模板 |
| | | 自定义模板 | 保存任务为模板 |
| F-P2-06 | **任务依赖** | 前置任务 | 指定任务依赖关系 |
| | | 依赖阻塞 | 前置未完成时提示阻塞 |
| | | 自动触发 | 前置完成自动启动后续 |

---

## 7. Agent 任务执行模型

这是 CODE-YI 任务系统最核心的创新——定义 Agent 如何"做"一个任务的完整生命周期。

### 7.1 执行状态机

```
ASSIGNED ──(Agent 接收)──> PREPARING ──(上下文就绪)──> EXECUTING
    │                         │                          │
    │                         │ (上下文获取失败)          ├──(进度更新)──> EXECUTING (loop)
    │                         ↓                          │
    │                     CONTEXT_FAILED                  ├──(需要人类输入)──> WAITING_INPUT
    │                         │                          │                      │
    │                    (通知人类)                        │               (人类响应)
    │                         │                          │                      │
    │                         ↓                          │                      ↓
    │                     FAILED_PREP                     │               EXECUTING (resume)
    │                                                    │
    │                                               ┌────┴────┐
    │                                               │         │
    │                                          (成功完成)  (执行出错)
    │                                               │         │
    │                                               ↓         ↓
    │                                          COMPLETING   ERROR
    │                                               │         │
    │                                          (生成报告)  (自动重试?)
    │                                               │      ┌──┴──┐
    │                                               ↓     Yes    No
    │                                          COMPLETED    │     │
    │                                               │   RETRYING  ↓
    │                                               │      │   FAILED
    │                                          (归档/闭环)  │     │
    │                                                      │  (通知人类)
    │                                                      ↓
    │                                                 EXECUTING
    │
    └──(Agent 离线/不可用)──> AGENT_UNAVAILABLE ──(Agent 恢复)──> ASSIGNED
```

### 7.2 执行阶段详解

#### 阶段 1: ASSIGNED → PREPARING（上下文收集，<5s）

Agent 收到任务后，首先收集执行所需的上下文：

| 上下文类型 | 来源 | 说明 |
|-----------|------|------|
| 任务信息 | Task 表 | 标题、描述、标签、优先级、截止日 |
| 历史评论 | task_comments | 人类和 Agent 的讨论记录 |
| 项目上下文 | projects 表 | 项目描述、技术栈、关联仓库 |
| Git 上下文 | GitHub/GitLab API | 仓库结构、最近提交、相关 Issue |
| Agent 记忆 | Agent Context Store | 该 Agent 过去执行类似任务的经验 |
| 关联任务 | task_dependencies | 前置任务的产出物 |

**如果上下文收集失败**（如 GitHub API 不可达），进入 `CONTEXT_FAILED` 状态，通知任务创建者。

#### 阶段 2: PREPARING → EXECUTING（执行主循环）

Agent 进入执行主循环。不同类型的任务有不同的执行策略：

| 任务类型 | 执行策略 | 典型产出物 |
|----------|---------|-----------|
| 代码开发 | 分析需求 → 编写代码 → 跑测试 → 创建 PR | Pull Request |
| 代码审查 | 拉取 PR diff → 逐文件分析 → 写评审意见 | Review Comments |
| Bug 修复 | 复现问题 → 定位根因 → 编写修复 → 验证 | PR + 测试用例 |
| 文档编写 | 分析代码/需求 → 撰写文档 → 格式化 | Markdown 文件 |
| 测试编写 | 分析代码覆盖率 → 设计用例 → 编写测试 | 测试文件 + 覆盖率报告 |
| 设计任务 | 分析需求 → 生成设计方案 → 输出文件 | 设计文档 / 图片 |
| DevOps | 分析基础设施需求 → 编写配置 → 验证 | 配置文件 / Terraform |

**执行过程中的进度报告：**

```typescript
interface ProgressUpdate {
  task_id: string;
  progress: number;          // 0-100
  current_step: string;      // "正在编写单元测试 (3/7)"
  step_index: number;        // 当前步骤序号
  total_steps: number;       // 总步骤数
  estimated_remaining_s: number; // 预估剩余秒数
  log_entry?: {
    level: 'info' | 'success' | 'warning' | 'error';
    message: string;
    timestamp: string;
  };
}
```

Agent 通过 WebSocket 实时推送 `ProgressUpdate`，前端实时渲染。推送频率：
- 正常执行：每个有意义的步骤推送一次
- 长时间步骤：每 30s 推送一次心跳（"仍在处理..."）
- 出错时：立即推送错误信息

#### 阶段 3: EXECUTING → WAITING_INPUT（人类输入等待）

当 Agent 在执行过程中遇到需要人类确认的情况：

**触发条件：**
- 需求描述不明确，Agent 需要澄清
- 执行方案有多个选择，需要人类决策
- 涉及敏感操作（如删除资源、修改生产配置）
- Agent 信心值低于阈值（如 <60%）

**交互方式：**
- Agent 在任务评论区发布问题，@mention 任务创建者
- 任务状态变为"等待输入"（Kanban 卡片显示等待图标）
- 创建者收到通知
- 创建者在评论区回复后，Agent 继续执行
- 超时未回复（可配置，默认 4h）：Agent 尝试最佳猜测执行，并标记"基于假设执行"

#### 阶段 4: EXECUTING → COMPLETING → COMPLETED（完成交付）

Agent 完成执行后的交付流程：

1. **结果验证：** Agent 对自己的产出物做基础验证（代码能编译、测试通过、文档格式正确）
2. **结果报告生成：** 自动生成结构化报告

```markdown
## 任务执行报告

### 执行摘要
- **状态：** 成功完成
- **耗时：** 12 分 34 秒
- **步骤：** 5/5 完成

### 产出物
- [Pull Request #42](https://github.com/org/repo/pull/42) — 实现用户登录 API
- 新增文件：`src/auth/login.ts`, `tests/auth/login.test.ts`
- 修改文件：`src/routes/index.ts`

### 执行详情
1. 分析需求 (30s) — 从任务描述和项目上下文确定 API 规格
2. 代码编写 (8min) — 实现 JWT 认证登录端点
3. 测试编写 (3min) — 编写 5 个测试用例，覆盖率 92%
4. PR 创建 (1min) — 创建 PR 并关联此任务

### 备注
- 使用了项目中已有的 `bcrypt` 密码验证逻辑
- 建议后续添加 rate limiting（已创建 follow-up Task #67）
```

3. **产出物关联：** PR URL、文件链接等自动关联到任务
4. **状态更新：** 任务状态 → "已完成"，进度 → 100%
5. **通知：** 通知任务创建者和关注者

#### 阶段 5: ERROR → RETRYING / FAILED（错误处理）

**自动重试策略：**

| 错误类型 | 是否重试 | 重试间隔 | 最大重试次数 |
|----------|---------|---------|-------------|
| LLM API 超时 | 是 | 30s, 60s, 120s | 3 |
| LLM 速率限制 | 是 | 等待 rate limit 重置 | 3 |
| Git 操作失败 | 是 | 10s, 30s | 2 |
| 代码编译失败 | 是（Agent 修复后） | 立即 | 2 |
| 测试失败 | 是（Agent 修复后） | 立即 | 3 |
| 需求理解错误 | 否（需人类澄清） | - | 0 |
| Agent 内部崩溃 | 是 | 60s | 1 |

**重试用尽后进入 FAILED：**
1. 生成失败报告（失败原因、错误日志、Agent 诊断分析）
2. 任务状态变为"需要关注"（红色标记）
3. 通知任务创建者 + 管理员
4. 提供操作选项：手动重试 / 转给人类 / 修改描述后重试

### 7.3 Agent 并发模型

```
Agent 并发配置:
  max_concurrent_tasks: 3     # 单个 Agent 最大并发任务数
  queue_strategy: "priority"  # 队列策略：priority(P0优先) | fifo(先进先出)
  timeout_per_task: "4h"      # 单任务超时
  cooldown_between_tasks: "30s" # 任务间冷却时间
```

当 Agent 收到新任务但已达并发上限：
1. 新任务进入 Agent 的任务队列
2. 卡片显示"排队中"状态 + 队列位置
3. 当有任务完成后，自动从队列中取出下一个任务（按优先级）
4. 如果队列中所有任务都超时未执行（>2h），通知管理员

### 7.4 Agent 执行沙箱

Agent 执行代码任务时的安全隔离：

| 隔离层 | 机制 | 说明 |
|--------|------|------|
| 容器隔离 | Docker | 每次执行在独立容器中运行 |
| 网络限制 | 白名单 | 仅允许访问 GitHub API、npm registry 等白名单域名 |
| 资源限制 | cgroups | CPU 2核、内存 4GB、磁盘 10GB |
| 时间限制 | timeout | 单次执行最长 4 小时 |
| 文件系统 | tmpfs | 执行完毕自动清理，产出物需显式保存 |
| 代码权限 | Git branch | Agent 在独立分支操作，通过 PR 合入 |

---

## 8. 数据模型

### 8.1 核心表（扩展自基础规格）

```sql
-- 任务主表
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  project_id UUID REFERENCES projects(id),
  title VARCHAR(500) NOT NULL,
  description TEXT,                          -- Markdown 格式
  status VARCHAR(20) NOT NULL DEFAULT 'todo' 
    CHECK (status IN ('todo', 'in_progress', 'done', 'archived')),
  sub_status VARCHAR(30),                    -- 'executing', 'waiting_input', 'needs_attention', 'queued'
  priority VARCHAR(5) NOT NULL DEFAULT 'p3'
    CHECK (priority IN ('p0', 'p1', 'p2', 'p3', 'p4')),
  assignee_id UUID,                          -- user_id 或 agent_id
  assignee_type VARCHAR(10)                  -- 'human' | 'agent'
    CHECK (assignee_type IN ('human', 'agent')),
  labels TEXT[] DEFAULT '{}',                -- 标签数组
  progress SMALLINT DEFAULT 0                -- 0-100
    CHECK (progress >= 0 AND progress <= 100),
  current_step VARCHAR(200),                 -- Agent 当前执行步骤描述
  due_date TIMESTAMPTZ,
  git_issue_url VARCHAR(500),                -- 关联的 GitHub/GitLab Issue URL
  git_pr_urls TEXT[] DEFAULT '{}',           -- 关联的 PR URLs
  sort_order REAL NOT NULL DEFAULT 0,        -- 列内排序位置
  sync_version BIGINT DEFAULT 0,             -- 双向同步版本号
  sync_source VARCHAR(20),                   -- 最后同步来源: 'codeyi' | 'github' | 'gitlab'
  created_by UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_tasks_workspace_status ON tasks(workspace_id, status);
CREATE INDEX idx_tasks_project ON tasks(project_id);
CREATE INDEX idx_tasks_assignee ON tasks(assignee_id, assignee_type);
CREATE INDEX idx_tasks_priority ON tasks(workspace_id, priority);
CREATE INDEX idx_tasks_due_date ON tasks(due_date) WHERE due_date IS NOT NULL;
CREATE INDEX idx_tasks_sort_order ON tasks(workspace_id, status, sort_order);

-- 任务评论
CREATE TABLE task_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  author_id UUID NOT NULL,
  author_type VARCHAR(10) NOT NULL           -- 'human' | 'agent'
    CHECK (author_type IN ('human', 'agent')),
  content TEXT NOT NULL,                     -- Markdown 格式
  comment_type VARCHAR(20) DEFAULT 'general' -- 'general' | 'progress' | 'result_report' | 'error_report' | 'system'
    CHECK (comment_type IN ('general', 'progress', 'result_report', 'error_report', 'system')),
  attachments JSONB DEFAULT '[]',            -- [{name, url, size, mime_type}]
  is_edited BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_task_comments_task ON task_comments(task_id, created_at);
```

### 8.2 Agent 执行追踪表

```sql
-- Agent 任务执行记录
CREATE TABLE agent_task_executions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  agent_id UUID NOT NULL,
  execution_number SMALLINT NOT NULL DEFAULT 1,  -- 第几次执行（含重试）
  
  -- 状态机
  status VARCHAR(30) NOT NULL DEFAULT 'assigned'
    CHECK (status IN (
      'assigned', 'preparing', 'context_failed', 'failed_prep',
      'executing', 'waiting_input', 'completing', 'completed',
      'error', 'retrying', 'failed', 'cancelled', 'timeout',
      'agent_unavailable'
    )),
  
  -- 进度
  progress SMALLINT DEFAULT 0,
  current_step VARCHAR(200),
  step_index SMALLINT DEFAULT 0,
  total_steps SMALLINT,
  estimated_remaining_s INTEGER,
  
  -- 上下文
  context_snapshot JSONB,                    -- 执行时的上下文快照
  
  -- 结果
  result_type VARCHAR(20),                   -- 'code_change' | 'document' | 'review' | 'test' | 'config' | 'other'
  result_summary TEXT,                       -- 结果摘要
  result_artifacts JSONB DEFAULT '[]',       -- [{type, url, description}]
  error_message TEXT,
  error_details JSONB,                       -- 结构化错误详情
  
  -- 计量
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  duration_ms INTEGER,
  token_usage JSONB,                         -- {input_tokens, output_tokens, total_cost}
  retry_count SMALLINT DEFAULT 0,
  max_retries SMALLINT DEFAULT 3,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  UNIQUE(task_id, execution_number)
);

CREATE INDEX idx_agent_executions_task ON agent_task_executions(task_id);
CREATE INDEX idx_agent_executions_agent ON agent_task_executions(agent_id, status);
CREATE INDEX idx_agent_executions_status ON agent_task_executions(status) WHERE status IN ('executing', 'waiting_input', 'retrying');

-- Agent 执行日志（高频写入，考虑分区）
CREATE TABLE agent_execution_logs (
  id BIGSERIAL PRIMARY KEY,
  execution_id UUID NOT NULL REFERENCES agent_task_executions(id) ON DELETE CASCADE,
  level VARCHAR(10) NOT NULL                 -- 'info' | 'success' | 'warning' | 'error' | 'debug'
    CHECK (level IN ('info', 'success', 'warning', 'error', 'debug')),
  message TEXT NOT NULL,
  metadata JSONB,                            -- 额外结构化数据
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
) PARTITION BY RANGE (created_at);

-- 按月分区
CREATE TABLE agent_execution_logs_2026_04 PARTITION OF agent_execution_logs
  FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');
CREATE TABLE agent_execution_logs_2026_05 PARTITION OF agent_execution_logs
  FOR VALUES FROM ('2026-05-01') TO ('2026-06-01');

CREATE INDEX idx_exec_logs_execution ON agent_execution_logs(execution_id, created_at);
```

### 8.3 任务活动记录表

```sql
-- 任务活动流（所有变更记录）
CREATE TABLE task_activities (
  id BIGSERIAL PRIMARY KEY,
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  actor_id UUID NOT NULL,
  actor_type VARCHAR(10) NOT NULL            -- 'human' | 'agent' | 'system'
    CHECK (actor_type IN ('human', 'agent', 'system')),
  action VARCHAR(30) NOT NULL,               -- 'created' | 'status_changed' | 'assigned' | 'priority_changed' | 'label_added' | 'label_removed' | 'commented' | 'due_date_changed' | 'progress_updated' | 'pr_linked' | 'git_synced' | 'archived'
  old_value JSONB,                           -- 变更前值
  new_value JSONB,                           -- 变更后值
  metadata JSONB,                            -- 额外信息
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_task_activities_task ON task_activities(task_id, created_at DESC);
```

### 8.4 自动化规则表

```sql
-- 自动化规则定义
CREATE TABLE task_automations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  name VARCHAR(200) NOT NULL,
  description TEXT,
  is_enabled BOOLEAN DEFAULT TRUE,
  
  -- 触发条件
  trigger_event VARCHAR(30) NOT NULL,        -- 'task_created' | 'status_changed' | 'agent_completed' | 'agent_failed' | 'pr_merged' | 'pr_opened' | 'comment_added' | 'due_date_approaching'
  trigger_conditions JSONB DEFAULT '{}',     -- 过滤条件 {field: value}
  
  -- 执行动作
  actions JSONB NOT NULL,                    -- [{type, config}]
  -- 动作类型: 'change_status' | 'assign' | 'notify' | 'create_task' | 'send_chat_message' | 'add_label' | 'change_priority'
  
  -- 计量
  execution_count INTEGER DEFAULT 0,
  last_executed_at TIMESTAMPTZ,
  
  created_by UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_automations_workspace ON task_automations(workspace_id, is_enabled);
CREATE INDEX idx_automations_trigger ON task_automations(trigger_event) WHERE is_enabled = TRUE;

-- 自动化执行日志
CREATE TABLE task_automation_logs (
  id BIGSERIAL PRIMARY KEY,
  automation_id UUID NOT NULL REFERENCES task_automations(id) ON DELETE CASCADE,
  task_id UUID REFERENCES tasks(id),
  trigger_data JSONB,                        -- 触发时的上下文数据
  actions_executed JSONB,                    -- 实际执行的动作及结果
  success BOOLEAN NOT NULL,
  error_message TEXT,
  executed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_automation_logs_automation ON task_automation_logs(automation_id, executed_at DESC);
```

### 8.5 Git 同步表

```sql
-- Git 仓库绑定
CREATE TABLE git_repo_bindings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  project_id UUID REFERENCES projects(id),
  provider VARCHAR(10) NOT NULL              -- 'github' | 'gitlab'
    CHECK (provider IN ('github', 'gitlab')),
  repo_owner VARCHAR(100) NOT NULL,
  repo_name VARCHAR(100) NOT NULL,
  access_token_encrypted TEXT NOT NULL,       -- 加密存储
  sync_direction VARCHAR(10) DEFAULT 'both'  -- 'inbound' | 'outbound' | 'both'
    CHECK (sync_direction IN ('inbound', 'outbound', 'both')),
  label_mapping JSONB DEFAULT '{}',          -- GitHub label → Task label 映射
  conflict_strategy VARCHAR(10) DEFAULT 'lww' -- 'lww' | 'codeyi_wins' | 'git_wins'
    CHECK (conflict_strategy IN ('lww', 'codeyi_wins', 'git_wins')),
  webhook_secret VARCHAR(100),
  last_sync_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX idx_git_bindings_repo ON git_repo_bindings(provider, repo_owner, repo_name);

-- Git 同步日志
CREATE TABLE git_sync_logs (
  id BIGSERIAL PRIMARY KEY,
  binding_id UUID NOT NULL REFERENCES git_repo_bindings(id),
  direction VARCHAR(10) NOT NULL,            -- 'inbound' | 'outbound'
  entity_type VARCHAR(10) NOT NULL,          -- 'issue' | 'pr' | 'comment'
  entity_id VARCHAR(100),                    -- GitHub Issue/PR number
  task_id UUID REFERENCES tasks(id),
  action VARCHAR(20) NOT NULL,               -- 'created' | 'updated' | 'closed' | 'conflict'
  details JSONB,
  success BOOLEAN NOT NULL,
  error_message TEXT,
  synced_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sync_logs_binding ON git_sync_logs(binding_id, synced_at DESC);
```

### 8.6 ER 关系图

```
workspaces
  │
  ├── projects
  │     │
  │     └── tasks ──────────────── task_comments
  │           │                       │
  │           ├── task_activities      └── (author: user | agent)
  │           │
  │           ├── agent_task_executions
  │           │         │
  │           │         └── agent_execution_logs (partitioned)
  │           │
  │           └── git_sync_logs
  │
  ├── task_automations ──── task_automation_logs
  │
  └── git_repo_bindings
```

---

## 9. 技术方案

### 9.1 整体架构

```
┌─────────────────────────────────────────────────────────────────┐
│                        客户端层                                  │
│  Web (React + TailwindCSS) │ Desktop (Tauri) │ Mobile (RN)     │
│  ├── Kanban Board (dnd-kit)                                     │
│  ├── Task Detail Panel                                          │
│  ├── Execution Log Stream                                       │
│  └── Filter/Search Bar                                          │
└────────────────────┬────────────────────────────────────────────┘
                     │ WebSocket + REST API
┌────────────────────┴────────────────────────────────────────────┐
│                    API Gateway (Kong)                            │
│  JWT/OAuth2 │ Rate Limiting │ WS Upgrade │ Bot Key Auth         │
└────────────────────┬────────────────────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────────────────────┐
│                        服务层                                    │
│                                                                  │
│  Task Service ─── Agent Executor ─── Git Sync Service           │
│       │                 │                    │                   │
│       │           Agent Runtime              │                   │
│       │          (Docker Sandbox)             │                   │
│       │                 │                    │                   │
│  ┌────┴─────────────────┴────────────────────┴──────┐           │
│  │            Event Bus (Redis Streams)              │           │
│  └────┬─────────────────┬────────────────────┬──────┘           │
│       │                 │                    │                   │
│  Automation Engine  Notification Service  Activity Logger        │
│                                                                  │
└────────────────────┬────────────────────────────────────────────┘
                     │
┌────────────────────┴────────────────────────────────────────────┐
│                        数据层                                    │
│  PostgreSQL 16 │ Redis 7 │ MinIO (S3) │ MeiliSearch             │
│  (tasks, execs)  (cache,    (附件,       (任务搜索)               │
│                  pub/sub)   产出物)                               │
└─────────────────────────────────────────────────────────────────┘
```

### 9.2 API 设计

#### RESTful API

```
# 任务 CRUD
GET    /api/v1/workspaces/:wid/tasks          # 获取任务列表（支持筛选参数）
POST   /api/v1/workspaces/:wid/tasks          # 创建任务
GET    /api/v1/tasks/:tid                      # 获取任务详情
PATCH  /api/v1/tasks/:tid                      # 更新任务
DELETE /api/v1/tasks/:tid                      # 删除任务

# Kanban 操作
PATCH  /api/v1/tasks/:tid/move                 # 拖拽移动（status + sort_order）
PATCH  /api/v1/tasks/:tid/reorder              # 列内排序

# Agent 指派
POST   /api/v1/tasks/:tid/assign-agent         # 指派给 Agent
POST   /api/v1/tasks/:tid/cancel-execution     # 取消 Agent 执行
POST   /api/v1/tasks/:tid/retry-execution      # 手动重试
POST   /api/v1/tasks/:tid/reassign-human       # 转给人类

# 评论
GET    /api/v1/tasks/:tid/comments             # 获取评论列表
POST   /api/v1/tasks/:tid/comments             # 添加评论
PATCH  /api/v1/comments/:cid                   # 编辑评论
DELETE /api/v1/comments/:cid                   # 删除评论

# Agent 执行
GET    /api/v1/tasks/:tid/executions           # 获取执行记录
GET    /api/v1/executions/:eid/logs            # 获取执行日志

# 活动流
GET    /api/v1/tasks/:tid/activities           # 获取活动流

# 自动化
GET    /api/v1/workspaces/:wid/automations     # 获取自动化规则
POST   /api/v1/workspaces/:wid/automations     # 创建规则
PATCH  /api/v1/automations/:aid                # 更新规则
DELETE /api/v1/automations/:aid                # 删除规则
POST   /api/v1/automations/:aid/test           # 测试运行

# Git 集成
POST   /api/v1/workspaces/:wid/git-bindings    # 绑定 Git 仓库
GET    /api/v1/workspaces/:wid/git-bindings    # 获取绑定列表
DELETE /api/v1/git-bindings/:bid               # 解绑
POST   /api/v1/git-bindings/:bid/sync          # 手动触发同步
POST   /api/v1/webhooks/github                 # GitHub Webhook 接收端点
POST   /api/v1/webhooks/gitlab                 # GitLab Webhook 接收端点

# 筛选/搜索
GET    /api/v1/workspaces/:wid/tasks/search    # 全文搜索
```

#### WebSocket 事件

```typescript
// 客户端 → 服务端
interface WsClientEvents {
  'task:subscribe': { workspace_id: string; filters?: TaskFilters };
  'task:unsubscribe': { workspace_id: string };
  'execution:subscribe': { task_id: string };   // 订阅特定任务的执行日志流
  'execution:unsubscribe': { task_id: string };
}

// 服务端 → 客户端
interface WsServerEvents {
  // Kanban 实时同步
  'task:created': { task: Task };
  'task:updated': { task_id: string; changes: Partial<Task> };
  'task:moved': { task_id: string; old_status: string; new_status: string; sort_order: number; actor: Actor };
  'task:deleted': { task_id: string };
  
  // Agent 执行实时更新
  'execution:started': { task_id: string; execution_id: string; agent: Agent };
  'execution:progress': ProgressUpdate;
  'execution:log': { execution_id: string; log: LogEntry };
  'execution:waiting_input': { task_id: string; question: string };
  'execution:completed': { task_id: string; result: ExecutionResult };
  'execution:failed': { task_id: string; error: ExecutionError };
  
  // 评论实时推送
  'comment:added': { task_id: string; comment: Comment };
  'comment:updated': { comment_id: string; content: string };
  
  // 活动流
  'activity:added': { task_id: string; activity: Activity };
}
```

### 9.3 拖拽排序实现

**技术选型：** `@dnd-kit/core` + `@dnd-kit/sortable`（替代已停止维护的 react-beautiful-dnd）

**排序算法：** 采用分数排序（Fractional Indexing），避免频繁重排所有卡片。

```typescript
// 排序策略：中间值插入
function calculateSortOrder(before: number | null, after: number | null): number {
  if (before === null && after === null) return 1000;  // 空列
  if (before === null) return after! - 1000;           // 插入到最前
  if (after === null) return before + 1000;            // 插入到最后
  return (before + after) / 2;                         // 中间插入
}

// 当精度不够时（连续插入导致精度丢失），批量重排
function needsRebalance(sortOrders: number[]): boolean {
  for (let i = 1; i < sortOrders.length; i++) {
    if (Math.abs(sortOrders[i] - sortOrders[i-1]) < 0.001) return true;
  }
  return false;
}
```

**乐观更新 + 服务端确认：**
1. 用户拖拽 → 前端立即更新 UI（乐观更新）
2. 发送 `PATCH /tasks/:tid/move` 到服务端
3. 服务端验证 + 持久化 → 通过 WebSocket 广播给其他客户端
4. 如果服务端拒绝（并发冲突），前端回滚到服务端状态

**防止并发冲突：**
- 每次 move 操作携带 `expected_version`（基于 `updated_at`）
- 服务端检测版本冲突 → 返回 409 + 最新状态
- 前端收到 409 → 用最新状态替换本地状态（不丢失其他用户的操作）

### 9.4 Agent 执行器架构

```
┌──────────────────────────────────────────────┐
│              Agent Executor Service           │
│                                              │
│  Task Queue ──> Dispatcher ──> Sandbox Pool  │
│  (Redis)        (Node.js)     (Docker)       │
│                    │                         │
│              Agent Runtime                   │
│              ├── Context Collector           │
│              ├── LLM Gateway (LiteLLM)       │
│              ├── Tool Executor               │
│              │   ├── Git Tool (clone/commit) │
│              │   ├── Shell Tool (npm/test)   │
│              │   ├── File Tool (read/write)  │
│              │   └── API Tool (HTTP calls)   │
│              ├── Progress Reporter           │
│              │   └── WebSocket emitter       │
│              └── Result Packager             │
│                  └── Report generator        │
└──────────────────────────────────────────────┘
```

**执行流程：**
1. Task Service 发布 `task.assigned_to_agent` 事件到 Redis Streams
2. Agent Executor 消费事件，从 Sandbox Pool 获取容器
3. Context Collector 收集所有上下文，注入到 Agent Runtime
4. Agent Runtime 通过 LLM Gateway 调用 AI 模型，执行工具链
5. Progress Reporter 通过 Redis pub/sub 推送进度到 WebSocket 层
6. 执行完成后，Result Packager 生成报告并更新 Task

### 9.5 Git 集成架构

```
┌────────────────┐        Webhook        ┌──────────────────┐
│ GitHub/GitLab  │ ──────────────────────> │ Webhook Handler │
│                │                        │ (验签 + 解析)    │
│                │ <───── API Calls ────── │                  │
└────────────────┘                        └────────┬─────────┘
                                                   │
                                          ┌────────┴─────────┐
                                          │  Git Sync Engine  │
                                          │                   │
                                          │  ├── Inbound Sync │ GitHub → Task
                                          │  │   (Issue/PR/    │
                                          │  │    Comment)     │
                                          │  │                │
                                          │  ├── Outbound Sync│ Task → GitHub
                                          │  │   (Create/Update│
                                          │  │    Issue/Comment)│
                                          │  │                │
                                          │  └── Conflict     │
                                          │      Resolver     │
                                          │      (sync_version)│
                                          └───────────────────┘
```

**防循环同步机制：**
- 每次同步操作在 metadata 中标记 `sync_source: "codeyi"` 或 `sync_source: "github"`
- Webhook Handler 收到事件时检查 `sync_source`——如果来自 CODE-YI 的同步操作触发的 Webhook，忽略
- 附加保护：5s 内对同一 entity 的重复同步事件自动去重（Redis SET + TTL）

### 9.6 性能目标

| 指标 | 目标 |
|------|------|
| Kanban 加载（100 任务） | < 500ms |
| 拖拽同步延迟 | < 300ms（P99）|
| 任务创建响应 | < 200ms |
| Agent 执行触发延迟 | < 5s（从指派到 Agent 开始执行）|
| 进度更新推送延迟 | < 500ms |
| 执行日志流延迟 | < 1s |
| GitHub Webhook 处理 | < 2s |
| 并发 WebSocket 连接 | > 5,000 |
| 任务搜索延迟（10K 任务）| < 300ms（P99）|

---

## 10. 与其他模块的集成

### 10.1 与 Module 1（Chat 对话）集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| Chat 创建任务 | Chat → Task | 用户在 Chat 中 @TaskBot 创建任务，自然语言解析为结构化 Task |
| 任务状态通知 | Task → Chat | 任务状态变更（Agent 开始/完成/失败）自动发送到关联的 Chat 频道 |
| 任务讨论链接 | 双向 | 任务评论中可引用 Chat 消息；Chat 中可引用任务链接 |
| Agent 执行进度 | Task → Chat | Agent 执行中的关键节点推送到 Chat |
| @mention 触发 | Chat → Task | 在 Chat 中 @人或@Agent 可快速创建任务 |

**实现方式：** 通过 Event Bus (Redis Streams) 解耦。Chat Service 和 Task Service 互相订阅对方的事件。

```yaml
# Chat → Task 事件
event: chat.task_creation_request
payload:
  channel_id: "ch_xxx"
  requester_id: "user_123"
  raw_text: "创建一个 P1 任务：实现用户登录 API，指派给 CodeBot"
  parsed:
    title: "实现用户登录 API"
    priority: "p1"
    assignee: "code-bot"

# Task → Chat 事件
event: task.status_changed
payload:
  task_id: "task_xxx"
  old_status: "todo"
  new_status: "in_progress"
  channel_ids: ["ch_xxx"]  # 关联的 Chat 频道
  message: "任务「实现用户登录 API」已开始执行 (CodeBot)"
```

### 10.2 与 Module 3（Projects 项目）集成

| 集成点 | 说明 |
|--------|------|
| 任务归属 | 每个 Task 必须关联一个 Project |
| 项目进度 | Project 的整体进度 = 其下所有 Task 的加权进度 |
| 项目 Kanban | 进入 Project 详情即展示该项目的 Kanban 视图 |
| 成员范围 | Task 的指派人必须是 Project 成员 |
| 项目标签 | Project 定义的标签自动可用于其下 Task |
| Sprint 管理 | 如果 Project 使用 Sprint，Task 可关联到特定 Sprint |

### 10.3 与 Module 5（Agent 管理）集成

| 集成点 | 说明 |
|--------|------|
| Agent 列表 | 指派人选择器从 Agent Module 获取可用 Agent 列表 |
| Agent 能力 | 创建任务时，系统根据标签推荐匹配能力的 Agent |
| Agent 运行时 | Task 指派后，调用 Agent Module 的运行时启动执行 |
| Agent 绩效 | Agent 的任务成功率、平均耗时等指标回写到 Agent 管理面板 |
| Agent 健康 | 如果 Agent 离线/不健康，任务进入 `agent_unavailable` 状态 |
| Agent 配置 | Agent 的并发限制、重试策略等配置存储在 Agent Module |

### 10.4 集成数据流全景

```
Chat (M1)                    Tasks (M2)                 Projects (M3)
  │                             │                            │
  │ "@TaskBot 创建任务"         │                            │
  ├────────────────────────────>│ 创建 Task                  │
  │                             ├───────────────────────────>│ 更新项目进度
  │                             │                            │
  │                             │ 指派给 Agent               │
  │                             ├──────────────────┐         │
  │                             │                  ↓         │
  │                             │           Agent (M5)       │
  │                             │           执行任务          │
  │                             │                  │         │
  │ "任务已开始执行"             │<─────────────────┘         │
  │<────────────────────────────│ 进度更新                   │
  │                             │                            │
  │                             │ Agent 完成 → PR 创建       │
  │                             ├──────────────────┐         │
  │                             │                  ↓         │
  │                             │           GitHub/GitLab    │
  │                             │           PR merged        │
  │                             │<─────────────────┘         │
  │                             │ 任务自动完成               │
  │ "任务已完成"                │                            │
  │<────────────────────────────│                            │
  │                             ├───────────────────────────>│ 更新项目进度
```

---

## 11. 测试用例

### 11.1 Kanban 基础

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-KB-01 | 看板加载 | 进入任务页 | 四列正确显示，每列任务按 sort_order 排序 |
| TC-KB-02 | 拖拽跨列 | 将"待办"任务拖到"进行中" | 卡片移动，状态更新，动画流畅 |
| TC-KB-03 | 拖拽排序 | 在同列内拖拽排序 | sort_order 更新，其他卡片不动 |
| TC-KB-04 | 多人同步 | 两人同时拖拽不同卡片 | 双方界面在 <300ms 内同步 |
| TC-KB-05 | 并发冲突 | 两人同时拖拽同一张卡 | 后到的操作被拒绝，界面回滚到最新状态 |
| TC-KB-06 | 空列引导 | 所有任务清空 | 显示引导文案 |
| TC-KB-07 | 大量任务 | 加载 200+ 任务 | 虚拟滚动，列表流畅无卡顿 |

### 11.2 任务 CRUD

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-TK-01 | 快速创建 | 点击"+"输入标题，按 Enter | 任务创建成功，出现在列顶部 |
| TC-TK-02 | 完整创建 | 填写标题/描述/标签/优先级/指派人/截止日 | 所有字段正确保存，卡片显示完整 |
| TC-TK-03 | 编辑任务 | 打开详情面板修改描述 | 修改实时保存，其他用户看到更新 |
| TC-TK-04 | 删除任务 | 右键 → 删除 → 确认 | 任务消失，活动记录保留 |
| TC-TK-05 | 截止日过期 | 任务截止日早于今天 | 截止日文字标红 |

### 11.3 Agent 执行

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-AG-01 | 指派 Agent | 选择 Agent 为指派人 | 弹出确认框，确认后状态变为"进行中" |
| TC-AG-02 | 执行开始 | Agent 开始执行 | 卡片出现脉动指示器，进度条从 0% 开始更新 |
| TC-AG-03 | 进度更新 | Agent 推送进度 | 进度条实时变化，步骤文字更新 |
| TC-AG-04 | 执行日志 | 点击卡片查看日志 | 日志流实时滚动，颜色编码正确 |
| TC-AG-05 | 执行完成 | Agent 完成任务 | 状态变为"已完成"，结果报告附加到评论 |
| TC-AG-06 | 执行失败 | Agent 遇到错误 | 自动重试（如果配置），最终失败显示红色标记，通知创建者 |
| TC-AG-07 | 等待输入 | Agent 需要澄清 | 评论区出现问题，卡片显示等待图标，通知创建者 |
| TC-AG-08 | 取消执行 | 点击"取消执行" | Agent 停止，状态回到"待办"，日志记录取消操作 |
| TC-AG-09 | Agent 排队 | Agent 已满载时指派新任务 | 显示排队状态和队列位置 |
| TC-AG-10 | Agent 离线 | Agent 不可用时指派 | 状态变为 `agent_unavailable`，通知指派者 |

### 11.4 筛选与搜索

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-FT-01 | 快捷筛选-我的 | 点击"我负责的" | 仅显示自己被指派的任务 |
| TC-FT-02 | 快捷筛选-Agent | 点击"Agent 执行中" | 仅显示 assignee_type=agent 且 status=in_progress 的任务 |
| TC-FT-03 | 组合筛选 | 选择 P0+P1 + 前端标签 | 正确组合过滤 |
| TC-FT-04 | URL 参数 | 复制带筛选参数的 URL 打开 | 自动应用筛选条件 |
| TC-FT-05 | 搜索 | 输入关键词 | 模糊匹配标题和描述 |

### 11.5 Git 同步

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-GS-01 | GitHub 绑定 | OAuth 授权绑定仓库 | 绑定成功，历史 Issue 开始同步 |
| TC-GS-02 | Issue 入站 | 在 GitHub 创建 Issue | <10s 内 Task 自动创建 |
| TC-GS-03 | Task 出站 | 在 CODE-YI 创建 Task（开启同步）| GitHub 自动创建 Issue |
| TC-GS-04 | PR Merged | 合并关联 PR | 任务自动标记完成 |
| TC-GS-05 | 防循环 | CODE-YI 同步到 GitHub | GitHub Webhook 不触发反向同步 |
| TC-GS-06 | 冲突处理 | 双方同时修改同一字段 | 按配置策略解决，记录冲突日志 |

### 11.6 自动化

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-AT-01 | PR 合并自动完成 | 配置规则后合并 PR | 任务自动完成，评论说明 |
| TC-AT-02 | Agent 成功率告警 | Agent 成功率降到 75% | 管理员收到告警通知 |
| TC-AT-03 | 自定义规则 | 配置"创建 P0 任务时通知管理员" | P0 任务创建后管理员收到通知 |
| TC-AT-04 | 规则禁用 | 禁用一条规则 | 对应事件不再触发此规则 |
| TC-AT-05 | 测试运行 | 点击规则的"测试运行" | 显示模拟结果，不实际执行 |

### 11.7 性能测试

| 指标 | 测试方法 | 目标 |
|------|---------|------|
| Kanban 渲染 | Lighthouse + 100 任务 | FCP < 1s, LCP < 2s |
| 拖拽帧率 | Chrome DevTools Performance | 稳定 60fps |
| WebSocket 吞吐 | k6 WebSocket 负载测试 | > 5,000 并发连接 |
| API 延迟 | k6 HTTP 负载测试 | P99 < 200ms (CRUD), P99 < 300ms (搜索) |
| Agent 启动 | 端到端计时 | 指派 → 执行开始 < 5s |
| 数据库查询 | pg_stat_statements | 慢查询 < 1%（>100ms 的查询占比）|

---

## 12. 成功指标

### 12.1 核心指标

| 指标 | MVP (3 月后) | 成熟期 (12 月后) | 说明 |
|------|-------------|-----------------|------|
| 周活跃任务数 | 100 | 2,000 | 状态非"已归档"的任务数 |
| 日创建任务数 | 10 | 200 | 含人工和 Agent 创建 |
| Agent 执行任务占比 | > 20% | > 50% | Agent 指派的任务占总任务的比例 |
| Agent 任务成功率 | > 75% | > 90% | 成功完成/总指派 |
| Agent 平均执行时间 | < 30 min | < 15 min | 从开始到完成 |
| Agent 执行中实时查看率 | > 40% | > 60% | 用户在 Agent 执行期间打开过任务详情 |
| Kanban 拖拽频率 | > 50 次/天 | > 500 次/天 | 拖拽操作总数 |
| 日均任务评论 | 20 | 500 | 含人工和 Agent 评论 |

### 12.2 集成指标

| 指标 | MVP | 成熟期 | 说明 |
|------|-----|--------|------|
| Git 绑定仓库数 | 5 | 100 | 活跃绑定的仓库数 |
| Issue↔Task 同步成功率 | > 95% | > 99.5% | 同步操作成功率 |
| PR→任务自动完成率 | > 80% | > 95% | PR 合并后关联任务被自动完成的比例 |
| Chat→Task 创建占比 | > 10% | > 30% | 从 Chat 中创建的任务占总任务的比例 |
| 自动化规则触发成功率 | > 90% | > 99% | 规则触发后成功执行的比例 |

### 12.3 体验指标

| 指标 | 目标 | 说明 |
|------|------|------|
| Kanban 加载时间 P99 | < 1s | 首次加载到可交互 |
| 拖拽操作流畅度 | 60fps | 无丢帧 |
| Agent 进度更新延迟 P99 | < 1s | 从 Agent 推送到用户看到 |
| 任务创建到 Agent 开始执行 | < 10s | 端到端 |
| 用户满意度 (NPS) | > 40 | 季度调研 |

---

## 13. 风险与缓解

### 13.1 技术风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **Agent 执行不可预测** — LLM 输出不稳定，同一任务多次执行可能结果不同 | 高 | 高 | 结果验证机制（编译检查、测试通过率）+ 人类 Review 选项 + 温度参数调优 + 多轮重试 |
| **Agent 执行超时** — 复杂任务超出 4h 限制 | 中 | 中 | 动态超时（基于任务复杂度）+ 断点续传（保存中间状态）+ 超时前 10 min 告警 |
| **Git 同步风暴** — 大量 Issue 同时变更导致同步积压 | 中 | 中 | 速率限制（100 事件/分钟/仓库）+ 批量合并同步 + 队列缓冲 |
| **拖拽并发冲突** — 多人同时拖拽导致状态不一致 | 低 | 低 | 乐观锁 + 版本号 + 服务端仲裁 + 自动回滚 |
| **WebSocket 连接管理** — 大量连接导致内存/CPU 压力 | 中 | 中 | 连接池 + 心跳检测 + 自动重连 + 水平扩展（Redis pub/sub 跨实例广播）|
| **执行日志存储爆炸** — 大量 Agent 执行产生海量日志 | 中 | 中 | 按月分区 + 90 天归档 + 日志级别过滤（生产环境不存 debug）|

### 13.2 产品风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **用户不信任 Agent 执行结果** — 不敢把重要任务交给 Agent | 高 | 高 | 从低风险任务开始（测试、文档）→ 建立信任后扩展到核心编码。提供"仅草稿"模式：Agent 完成后需人类确认才算完成 |
| **任务描述质量差导致 Agent 执行偏差** — "实现登录功能"太模糊 | 高 | 高 | Agent 在执行前主动提问澄清 + 任务描述模板/引导 + 支持附加参考文档/代码片段 |
| **与现有工具迁移困难** — 团队不愿从 Jira/Linear 迁移 | 高 | 中 | GitHub 双向同步降低迁移成本 + 导入工具（Jira CSV/Linear API）+ 突出"Agent 执行"这个其他工具不具备的差异化 |
| **Kanban 过于简单** — 四列固定不满足复杂团队需求 | 中 | 中 | P2 支持自定义列 + 多视图（列表/日历/时间线）+ 但 MVP 保持简洁——Less is More |
| **Agent 执行成本不可控** — LLM API 调用费用超出预算 | 中 | 高 | 每任务 Token 上限 + 每月 Agent 执行预算 + 成本看板 + 低成本模型降级策略 |

### 13.3 安全风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **Agent 执行恶意代码** — 被注入的任务描述导致 Agent 执行危险操作 | 低 | 高 | Docker 沙箱隔离 + 网络白名单 + 文件系统限制 + Git 分支保护（Agent 只能操作独立分支）|
| **Git Token 泄露** — OAuth Token 被盗取 | 低 | 高 | Token 加密存储 + 最小权限原则 + Token 定期轮换 + 审计日志 |
| **Prompt 注入攻击** — 通过任务评论注入指令影响 Agent 行为 | 中 | 中 | 系统提示词隔离 + 用户输入消毒 + 输出检测 + 工具调用白名单 |

---

## 14. 排期建议

### 14.1 Sprint 规划（总工期约 10 周，1 前端 + 1 后端）

#### Sprint 1: 基础框架与数据层（第 1-2 周）

**做什么：** 搭建整个任务系统的骨架——数据库表、基础 API、前端页面框架。这是地基，后面所有功能都建在这上面。

**后端：**
- 数据库 Schema 创建（tasks, task_comments, task_activities）
- Task CRUD API（创建/读取/更新/删除）
- 列表查询 API（支持分页、基础筛选）
- WebSocket 基础连接建立

**前端：**
- Kanban 页面框架（四列布局）
- 基础任务卡片组件（标题 + 标签 + 优先级）
- 任务创建表单（快速创建 + 完整表单）
- API 对接层（React Query / SWR）

**难点：** 没有特别的技术难点，但数据模型的设计要一次到位——后期改表结构成本很高。特别是 `sort_order` 的设计（分数排序 vs 整数排序）和索引策略需要仔细考虑。

**潜在阻塞：** 需要前端/后端协商 API 接口规范。建议先写 OpenAPI Spec 再动手。

#### Sprint 2: 拖拽与实时同步（第 3-4 周）

**做什么：** 实现 Kanban 的核心交互——拖拽排序和多人实时同步。这是用户第一眼看到的交互体验，必须做到丝滑。

**后端：**
- Task move/reorder API（乐观锁 + 版本号）
- WebSocket 事件广播（task:moved, task:updated, task:created）
- Redis pub/sub 跨实例消息分发
- 并发冲突处理（409 + 最新状态返回）

**前端：**
- @dnd-kit 拖拽集成（跨列拖拽 + 列内排序）
- 乐观更新机制（拖拽即生效，服务端确认/回滚）
- WebSocket 客户端（自动重连 + 事件分发）
- 多人操作实时同步渲染
- 拖拽动画优化（60fps）

**难点：** 拖拽的实时同步是这个 Sprint 最难的部分。两个人同时拖同一张卡怎么办？网络延迟导致的短暂不一致如何处理？这些边界情况需要反复测试。@dnd-kit 的配置也比较复杂，尤其是跨列拖拽 + 列内排序的组合。

**潜在阻塞：** 如果 WebSocket 基础设施尚未搭建完成（可能依赖 Module 1 的 Chat 系统已经搭好的 WS 层），需要自行搭建。

#### Sprint 3: 任务详情与筛选（第 5-6 周）

**做什么：** 完善任务的信息展示和管理能力——详情面板、评论系统、筛选视图。这让任务从"卡片"变成完整的工作单元。

**后端：**
- 任务详情 API（含评论、活动流）
- 评论 CRUD API
- 高级筛选 API（组合条件、URL 参数化）
- 任务活动记录（所有变更自动记录到 task_activities）
- MeiliSearch 全文搜索索引

**前端：**
- 任务详情侧面板（slide-over，不跳转页面）
- 评论系统（Markdown 编辑器 + @mention + 文件附件）
- 筛选栏（快捷标签 + 高级筛选弹出面板）
- 活动流时间线组件
- URL 参数同步（筛选条件 ↔ URL）

**难点：** 评论系统中的 @mention 自动补全需要同时搜索人类和 Agent，并且要和 Chat 模块的 @mention 保持一致的体验。详情面板的响应式设计（桌面端侧滑 vs 移动端全屏）也需要仔细处理。

**潜在阻塞：** MeiliSearch 需要部署和配置中文分词。如果基础设施未就绪，搜索功能可以推迟到 Sprint 4。

#### Sprint 4: Agent 执行核心（第 7-8 周）—— **最关键的 Sprint**

**做什么：** 实现 CODE-YI 的核心差异化——Agent 任务执行。这是整个产品最有价值也最复杂的部分。

**后端：**
- Agent 执行表（agent_task_executions, agent_execution_logs）
- Agent Executor Service（事件消费 → 容器启动 → 执行管理）
- 执行状态机实现（完整的状态转换逻辑）
- 进度报告 API + WebSocket 推送
- 结果报告生成器
- 自动重试逻辑
- Agent 队列管理（并发限制 + 优先级排队）

**前端：**
- Agent 指派交互（确认对话框 + 执行中指示器）
- 实时进度条组件（WebSocket 驱动）
- 执行日志流组件（类 CI/CD 日志界面，颜色编码，自动滚动）
- Agent 结果报告渲染（结构化展示）
- 失败状态展示 + 操作按钮（重试/转人类/查看详情）
- 排队状态展示

**难点：** 这是最难的 Sprint。Agent Executor Service 需要与 Module 5 的 Agent Runtime 深度集成，如果 Module 5 还未就绪，需要先用 Mock Agent 代替（模拟执行过程、定时推送进度）。执行状态机的边界情况很多——Agent 崩溃、网络断开、超时、手动取消——每种情况都需要正确处理。Docker 沙箱的配置和资源限制也需要仔细调试。

**潜在阻塞：** 强依赖 Module 5（Agent 管理模块）的 Agent Runtime。如果 M5 未就绪，建议先实现 Mock Agent + 状态模拟，确保前端和状态机逻辑可以并行开发。

#### Sprint 5: Git 集成与自动化（第 9-10 周）

**做什么：** 实现 GitHub/GitLab 双向同步和自动化规则引擎，让任务系统成为开发工作流的枢纽。

**后端：**
- Git 仓库绑定（OAuth 授权流程）
- GitHub Webhook 处理器（Issue/PR/Comment 事件）
- 双向同步引擎（Inbound + Outbound）
- 防循环同步机制（sync_source + 去重）
- 自动化规则引擎（trigger → condition → action）
- 预设规则（PR merged → 任务完成, Agent 成功率告警）
- 通知系统集成

**前端：**
- Git 仓库绑定设置页面
- Issue ↔ Task 关联展示
- PR 关联展示（任务详情中）
- 自动化规则列表和创建界面
- 通知中心（或集成到全局通知）

**难点：** 双向同步的防循环是最容易出 Bug 的地方——CODE-YI 更新 GitHub Issue → GitHub 发 Webhook → CODE-YI 收到 Webhook 又去更新 Task → 无限循环。需要 `sync_source` 标记 + 去重窗口双重保险。OAuth 授权流程也需要处理 Token 过期和刷新。

**潜在阻塞：** 需要在 GitHub 开发者平台注册 OAuth App。如果是自托管的 GitLab，需要额外处理不同版本 GitLab 的 Webhook 格式差异。

### 14.2 里程碑

| 里程碑 | 时间 | 关键能力 | 对应 Sprint |
|--------|------|---------|------------|
| **M1: Kanban Alpha** | Week 2 | 基础 Kanban + 任务 CRUD | Sprint 1 |
| **M2: Interactive Kanban** | Week 4 | 拖拽排序 + 实时多人同步 | Sprint 2 |
| **M3: Full Task Management** | Week 6 | 详情面板 + 评论 + 筛选 + 搜索 | Sprint 3 |
| **M4: Agent Execution** | Week 8 | Agent 指派 + 实时进度 + 结果报告 | Sprint 4 |
| **M5: Full Integration** | Week 10 | Git 同步 + 自动化规则 + 通知 | Sprint 5 |

### 14.3 团队配置（2 人最小团队）

| 角色 | 人数 | 职责 |
|------|------|------|
| 后端工程师 | 1 | Task Service + Agent Executor + Git Sync + Automation Engine |
| 前端工程师 | 1 | Kanban UI + 拖拽 + 详情面板 + 实时更新 + Agent 执行可视化 |

**注意：** 2 人团队在 10 周内完成 P0 + 部分 P1 功能。P2 功能（自动化规则构建器、多视图、批量操作、任务模板、任务依赖）需要额外 4-6 周。完整的 Agent 执行能力依赖 Module 5 团队的配合。

### 14.4 依赖关系

```
Module 1 (Chat)  ──→  Task 模块需要 Chat 模块的 Event Bus 基础设施
                       Chat 创建任务功能需要 Task API 就绪

Module 3 (Projects) ──→  Task 需要 Project 表存在（可先用 mock project_id）
                          Project 进度依赖 Task 数据聚合

Module 5 (Agent)  ──→  Agent 执行功能强依赖 Agent Runtime
                       Sprint 4 开始时必须有至少一个可用的 Agent
                       建议 M5 团队在 Week 5 前提供 Agent API 接口定义
```

---

*本文档由 Zylos AI Agent 根据 Stephanie 的产品方向和设计稿生成。*
*CODE-YI Module 2 PRD v1.0 | 2026-04-19 | Draft*
