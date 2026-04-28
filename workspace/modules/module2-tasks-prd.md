# CODE-YI Module 2: 任务 (Tasks) — 产品需求文档

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
7. [Agent 任务透明化模型](#7-agent-任务透明化模型)
8. [GitHub/GitLab 双向同步架构](#8-githubgitlab-双向同步架构)
9. [数据模型](#9-数据模型)
10. [技术方案](#10-技术方案)
11. [Zylos 可复用组件](#11-zylos-可复用组件)
12. [测试用例](#12-测试用例)
13. [成功指标](#13-成功指标)
14. [风险与缓解](#14-风险与缓解)
15. [排期建议](#15-排期建议)

---

## 1. 问题陈述

### 1.1 现有任务管理工具的根本性失败

当前主流任务管理工具（Linear、Jira、Asana、GitHub Issues）均诞生于"人类手动执行任务"的范式。它们对 AI Agent 的支持停留在"通知推送"和"简单自动化"的层级，无法满足 AI-Native 团队的核心需求：

**Linear 的致命限制：**
- **无 Agent 指派概念**：Linear 的 Assignee 只支持人类用户，无法将 Issue 指派给一个 AI Agent 并触发自动执行
- **进度不可感知**：Linear 的 status 只有离散状态（Backlog → Todo → In Progress → Done），缺乏 Agent 执行过程中的实时进度流（0-100% 进度条、实时日志输出）
- **自动化局限于状态流转**：Linear Automations 只能做 "当 X 状态时触发 Y 状态" 的简单规则，无法编排 Agent 执行链
- **API Webhook 单向**：Linear 的 Webhook 可以推送事件，但无法从 Agent 侧实时回写执行进度

**Jira 的致命限制：**
- **Automation 是规则引擎而非 Agent 编排器**：Jira Automation Rules 只能做 "if-then" 的条件触发，无法表达 "Agent A 执行完后 Agent B 审查" 的链式工作流
- **Bot 集成是通知层**：Jira 的 Slack/Teams 集成只能推送通知，无法让 Bot 成为任务的执行者
- **字段臃肿**：Jira 的 Issue 字段体系（Epic → Story → Sub-task → Bug）针对人类项目管理设计，缺乏 Agent 执行元数据（执行日志 URL、Token 消耗、成功率、Agent 身份信息）
- **看板体验沉重**：Jira Board 的渲染性能和交互体验在大数据量下严重退化，拖拽操作延迟高

**GitHub Projects / Issues 的致命限制：**
- **Projects 是视图层而非执行层**：GitHub Projects V2 本质上是 Issue/PR 的看板视图封装，无法关联一个 Agent 运行时
- **Copilot Workspace 只能处理编码任务**：GitHub 的 Coding Agent 可以从 Issue 生成 PR，但这是单一场景——设计任务、文档任务、测试任务无法由 Agent 执行
- **Issue ↔ 任务是 1:1 而非 N:N**：一个复杂的 CODE-YI 任务可能需要多个 Git Issue（前端 + 后端 + 测试），但 GitHub 无法原生表达这种关系
- **没有实时进度**：Issue 只有 Open/Closed 两种状态，Agent 在执行过程中的中间状态（编译中、测试中、部署中）无法实时反映在 Issue 上

**Asana 的局限：**
- Task 的 Assignee 仅支持人类用户
- 自动化（Rules）仅覆盖状态变更和通知，不支持外部执行器回调
- 缺乏开发者工具集成（无 Git 同步、无 CI/CD 联动）
- Custom Fields 可以模拟 Agent 状态，但缺乏实时更新机制

**ClickUp 的局限：**
- ClickUp Automations 支持 "When X happens, do Y"，但 Y 只限于 ClickUp 内部操作
- 缺乏原生的 Agent/Bot 执行者概念
- AI 功能限于 ClickUp Brain（内容生成、总结），非任务执行
- 自定义字段可以表达 Agent 状态，但需要手动维护或通过 API 外部更新

**Notion 的局限：**
- Notion AI 只能辅助内容创作（写作、总结、翻译），不是任务执行者
- Database 可以做 Kanban 视图，但无原生的拖拽排序 API（需 Notion API + 手动维护 sort order）
- 缺乏实时协作的任务进度更新（Notion 的实时协作针对文档编辑，非任务状态流）
- 无 Git 集成

**Shortcut（原 Clubhouse）的局限：**
- 面向软件团队的任务管理，有 GitHub/GitLab 集成
- 但 Integration 仅支持 "PR merged → Story moved to Done" 级别的自动化
- 无 Agent 指派、无实时进度、无 Agent 执行日志

**核心痛点（Stephanie 原话）：** "我是想通过这个 agent 来透明化它究竟有哪些任务在跑啊" —— 这反映的是**所有现有任务管理工具的结构性缺陷**：它们不是为 AI Agent 作为任务执行者而设计的。用户无法一眼看到 Agent 在做什么、做到哪了、成功还是失败。

### 1.2 市场机会

- 2025-2026 年，Agentic AI 从单一 Coding Agent 扩展到多领域 Agent（设计、测试、运维、内容），但**没有一个看板工具**原生支持"Agent 是任务执行者"
- GitHub Copilot Workspace 的 Mission Control 面板验证了"多 Agent 任务并行可视化"的需求真实存在，但它仅限于编码场景
- Linear、Notion 等新一代工具在 UI/UX 上极优，但在 AI Agent 集成方面仍停留在"辅助内容生成"而非"任务执行"
- 这是 CODE-YI 的蓝海：**将 Agent 升级为任务的一等执行者，让任务看板不只是人类的项目管理工具，更是 Agent 工作的透明化面板**

---

## 2. 产品愿景

### 2.1 一句话定位

**CODE-YI 任务模块是全球首个将 AI Agent 作为一等任务执行者（First-Class Task Executor）的 Kanban 看板系统，让团队实时看到人类和 Agent 的任务全景。**

### 2.2 两种执行模式

```
┌─────────────────────────────────────────────────┐
│              CODE-YI 任务系统                      │
├─────────────────────┬───────────────────────────┤
│ Human Executor      │ Agent Executor            │
│ 人类执行模式          │ Agent 执行模式             │
│                     │                           │
│ 人工拖拽状态变更      │ 指派后自动开始执行           │
│ 手动更新进度         │ 进度实时流式更新             │
│ 文字评论汇报         │ 执行日志 + 结果报告自动生成   │
│ 完成后手动关闭       │ 完成后自动关闭 + 附报告       │
│ Git 操作需手动关联    │ Git 操作自动关联（PR/Issue） │
└─────────────────────┴───────────────────────────┘
```

### 2.3 核心差异化

| 维度 | 传统看板 (Linear/Jira) | CODE-YI |
|------|------------------------|---------|
| 任务执行者 | 仅人类 | 人类 + Agent 平等 |
| 任务进度 | 离散状态（3-5 列） | 离散状态 + 连续进度（0-100%） |
| 状态更新 | 人工拖拽/手动更新 | Agent 自动更新 + 人工操作并存 |
| 执行透明度 | 依赖人类文字汇报 | Agent 执行日志实时可见 |
| Git 同步 | 单向（Webhook 通知） | 双向实时同步（Task ↔ Issue） |
| 自动化 | 规则引擎（if-then） | Agent 编排 + 规则引擎 |
| 结果交付 | 人工提交产出物 | Agent 自动附加结果报告 |

### 2.4 任务流转全景

```
创建任务（人工或从 Chat @Bot 自动创建）
       ↓
指派执行者
  ├── 指派给人类 → 常规 Kanban 流程
  └── 指派给 Agent → 自动触发执行
              ↓
       Agent 开始执行
       ├── 状态自动变为"进行中"
       ├── 进度条实时更新（0% → 30% → 70% → 100%）
       ├── 执行日志实时流入任务评论
       └── 如需 Git 操作 → 自动创建 PR/Issue 并双向同步
              ↓
       Agent 执行完成
       ├── 自动生成结果报告（附到评论区）
       ├── 状态自动变为"已完成"
       ├── 关联的 Git Issue 自动关闭
       └── 通知指派人/创建人
              ↓
       人工验收（可选）
       ├── 通过 → 归档
       └── 不通过 → 退回，附反馈意见，Agent 重新执行
```

---

## 3. 竞品对标

### 3.1 竞品矩阵

| 维度 | Linear | Jira | GitHub Projects | Asana | ClickUp | Notion | Shortcut | **CODE-YI** |
|------|--------|------|-----------------|-------|---------|--------|----------|-------------|
| **看板 UI/UX** | ★★★★★ | ★★★ | ★★★ | ★★★★ | ★★★★ | ★★★★ | ★★★★ | ★★★★★ |
| **Agent 指派** | - | - | ★ | - | - | - | - | ★★★★★ |
| **实时进度** | ★ | ★ | - | ★ | ★★ | - | ★ | ★★★★★ |
| **Agent 执行日志** | - | - | ★★ | - | - | - | - | ★★★★★ |
| **Git 双向同步** | ★★ | ★★★ | ★★★★★ | ★ | ★★ | - | ★★★ | ★★★★ |
| **自动化能力** | ★★★ | ★★★★ | ★★★ | ★★★ | ★★★★ | ★★ | ★★★ | ★★★★★ |
| **任务评论协作** | ★★★★ | ★★★★ | ★★★★ | ★★★ | ★★★ | ★★★ | ★★★ | ★★★★★ |
| **AI 辅助** | ★★ | ★★ | ★★★★ | ★★ | ★★★ | ★★★ | ★ | ★★★★★ |

### 3.2 深度分析

**Linear：**
- 优势：极致的 UI/UX 体验（快捷键、拖拽流畅度、暗色主题），Issue 自动编号，Cycle/Project 组织层级清晰，开发者体验好
- 劣势：Automation 仅支持规则式触发（状态变更→通知/指派），GitHub 同步是单向（GitHub Issue/PR → Linear Issue 状态），无法将 Issue 指派给外部 Agent
- AI 能力：Linear AI 仅用于自动分类、优先级建议、写 Issue 描述，不是任务执行者
- 核心缺失：无 Agent Executor 概念，无实时进度流，无执行日志面板

**Jira（Atlassian）：**
- 优势：企业级功能完整（权限、审计、合规），Automation Rules 支持 100+ 条件/动作，Marketplace 插件生态丰富，Atlassian Intelligence（AI）提供总结和建议
- 劣势：Automation 是"规则引擎"而非"Agent 编排器"——只能做 "当 PR merged 时把 Issue 移到 Done"，不能编排 "Agent A 执行→Agent B 审查→自动合并"
- AI 能力：Atlassian Intelligence 提供 Issue 内容生成和 JQL 自然语言查询，但不执行任务
- 核心缺失：无 Agent 指派、无实时进度条、UI 性能在大看板下退化严重

**GitHub Projects / Issues：**
- 优势：与代码仓库深度绑定，Projects V2 支持自定义字段和视图，GitHub Actions 提供 CI/CD 自动化，Copilot Workspace 支持从 Issue 自动生成 PR
- 劣势：Projects 本质上是 Issue/PR 的视图层封装，不是独立的任务管理系统；Copilot Workspace 仅处理编码类 Issue；缺乏 Kanban 级别的拖拽排序体验
- AI 能力：Copilot Workspace 可以从 Issue 描述生成代码并创建 PR——这是目前最接近"Agent 执行任务"的产品，但局限在编码场景
- 可借鉴：Mission Control 面板展示多个 Copilot Agent 的并行任务状态——这是 CODE-YI Agent 任务透明化的直接参考
- 核心缺失：非编码任务无法由 Agent 执行，Progress tracking 仅有 Open/Closed，Projects V2 无独立的 Task 数据模型（依赖 Issue）

**Asana：**
- 优势：UI 友好（List/Board/Timeline/Calendar 多视图），Goals & Portfolios 提供高层进度追踪，Rules 自动化覆盖常见场景
- 劣势：面向非技术团队，Git 集成弱（需第三方插件），Assignee 仅支持人类用户，无 API 级别的实时进度回写
- AI 能力：Asana AI 提供智能状态更新建议和项目摘要，非执行者
- 核心缺失：无 Agent 指派、无 Git 同步、无开发者工具集成

**ClickUp：**
- 优势：功能极其丰富（Docs、Whiteboards、Goals、时间追踪一体化），Automations 支持 50+ 触发条件和外部 Webhook
- 劣势：功能过载导致学习曲线陡峭，AI（ClickUp Brain）仅辅助内容生成和搜索，Automations 的外部 Webhook 只能触发/接收通知，无法控制 Agent 执行
- AI 能力：ClickUp Brain 是内置 AI 助手，能回答关于项目状态的问题、生成摘要、写任务描述，但不能执行任务
- 核心缺失：无 Agent 执行者概念，AI 定位是"辅助人类"而非"替代执行"

**Notion：**
- 优势：Database + 多视图（Kanban/Table/Calendar/Gallery）灵活性极高，Notion AI 文本能力强，用户基数大
- 劣势：Database 不是真正的任务管理系统（缺乏 Workflow、Sprint、Cycle 等概念），拖拽排序依赖手动维护 sort_order，无 Git 集成，实时协作针对文档编辑而非任务状态
- AI 能力：Notion AI 是文本辅助工具（写作、总结、翻译），无任务执行能力
- 核心缺失：无 Agent 指派、无 Git 同步、无自动化工作流、不是为任务管理设计的产品

**Shortcut（原 Clubhouse）：**
- 优势：面向软件团队，GitHub/GitLab 集成成熟（PR → Story 状态自动更新），UI 简洁，Iteration/Epic 组织层级合理
- 劣势：自动化仅覆盖 "Git 事件 → 状态变更"，无 Agent 概念，无实时进度
- AI 能力：有限的 AI 辅助功能（搜索增强、内容建议）
- 核心缺失：与 Linear 类似——无 Agent 执行者、无实时进度、无执行日志

### 3.3 竞品差距总结

所有现有任务管理工具存在相同的结构性缺陷：

1. **Agent 不是 Assignee**：没有一个工具原生支持将任务"指派给 AI Agent"并自动触发执行
2. **进度是离散的**：状态只有 3-7 个列（Todo/In Progress/Done...），缺乏 0-100% 连续进度
3. **执行过程是黑盒**：Agent 在做什么、做到哪了、为什么失败——用户看不到
4. **Git 同步是单向的**：大多只有 "Git Event → Task Status Update"，缺乏 "Task Creation → Git Issue Creation" 的反向同步
5. **AI 是辅助者不是执行者**：所有产品的 AI 功能定位在"帮人类写描述/总结/搜索"，而非"替代人类执行任务"

**CODE-YI 的机会就在这个五重缺口中。**

---

## 4. 技术突破点分析

### 4.1 现有工具的技术架构限制

经深度调研，现有任务管理工具无法支持 Agent 执行的根因分析：

| 限制项 | 技术根因 | 影响 |
|--------|----------|------|
| Assignee 只能是人类 | 数据模型中 assignee_id 只关联 users 表 | Agent 无法成为任务执行者 |
| 进度只有离散状态 | Status 是枚举值（enum），无连续进度字段 | 无法表达 Agent 执行的中间进度 |
| 无执行日志 | 任务模型无 log stream 关联 | Agent 的执行过程不可观测 |
| 单向 Git 同步 | Webhook 只有 inbound 处理器，无 outbound 同步引擎 | 无法从任务侧主动创建/更新 Git Issue |
| 自动化是规则引擎 | Automation 基于 if-then 规则，非 Agent 调度框架 | 无法编排多 Agent 链式执行 |
| 无实时推送 | 基于 HTTP Polling 或低频 Webhook | 进度更新延迟高（秒级到分钟级） |

### 4.2 需要的技术突破

#### 突破 1：多态 Assignee 模型（Polymorphic Assignee）

传统模型：
```
task.assignee_id → users.id  (只能指向人类)
```

CODE-YI 模型：
```
task.assignee_id   → 可以是 user_id 或 agent_id
task.assignee_type → 'human' | 'agent'

当 assignee_type = 'agent' 时:
  → 自动触发 Agent 执行引擎
  → 建立 WebSocket 进度通道
  → 挂载执行日志收集器
```

这不是简单的字段扩展——它需要整个任务生命周期引擎识别 assignee_type 并分流处理。

#### 突破 2：实时进度流（Real-time Progress Stream）

传统看板的 "In Progress" 是一个黑盒状态。CODE-YI 需要：

```
┌──────────────────────────────────────────┐
│  任务卡片：实现用户登录模块                  │
│  执行者：Code-Agent                       │
│  状态：进行中                              │
│                                          │
│  ████████████████░░░░░░░░  67%           │
│                                          │
│  [实时日志]                               │
│  15:30:01 正在分析需求...                  │
│  15:30:15 生成代码架构...                  │
│  15:31:02 编写 auth.service.ts...         │
│  15:31:45 编写 login.controller.ts...     │
│  15:32:10 运行单元测试... (3/5 passed)     │
│  15:32:30 修复测试失败...                  │
│  (光标闪烁，实时输出中)                     │
│                                          │
│  PR #142 (自动创建)                       │
└──────────────────────────────────────────┘
```

技术要求：
- WebSocket 双向通道：Agent → Task Progress Stream → 前端卡片实时渲染
- 进度百分比的语义计算（不是随机数，而是基于步骤完成度）
- 日志分级（info/warn/error）+ 时间戳
- 进度数据的持久化（断线重连后可恢复到断点）

#### 突破 3：Agent 执行生命周期管理

Agent 执行任务不是"调用一次 API 然后等结果"。它是一个有状态的生命周期：

```
ASSIGNED → PREPARING → EXECUTING → REVIEWING → COMPLETED/FAILED

ASSIGNED:    Agent 收到任务
PREPARING:   Agent 分析需求、规划步骤
EXECUTING:   Agent 正在执行（进度 0-100%）
REVIEWING:   Agent 完成初步执行，等待自检或人工审查
COMPLETED:   执行成功，结果已附加
FAILED:      执行失败，错误报告已附加

异常路径:
EXECUTING → BLOCKED:     Agent 遇到阻塞（需要人工输入/权限不足）
EXECUTING → CANCELLED:   人工取消执行
FAILED → RETRYING:       自动重试
FAILED → REASSIGNED:     转给其他 Agent 或人类
```

#### 突破 4：Git 双向同步引擎（Bidirectional Git Sync）

不是 Webhook 的 if-then 规则，而是一个持续运行的同步引擎：

```
CODE-YI Task                    GitHub/GitLab Issue
    │                                 │
    │  创建 Task                       │
    ├──────────────────────────→      │  自动创建 Issue
    │                                 │
    │                                 │  外部修改 Issue 标题
    │      ←──────────────────────────┤
    │  自动更新 Task 标题               │
    │                                 │
    │  Agent 执行完毕，关闭 Task        │
    ├──────────────────────────→      │  自动关闭 Issue
    │                                 │
    │                                 │  外部 Reopen Issue
    │      ←──────────────────────────┤
    │  自动 Reopen Task                │
    │                                 │
    │                                 │  PR merged (via webhook)
    │      ←──────────────────────────┤
    │  自动完成关联 Task                │
```

技术要求：
- 冲突检测与解决（双方同时修改同一字段时的策略）
- 幂等同步（相同的变更不触发循环更新）
- 字段映射（Task priority P0-P4 ↔ GitHub Labels）
- 同步状态追踪（哪些字段已同步、最后同步时间）

#### 突破 5：对话-任务跨模块联动

CODE-YI 的任务模块不是孤立的——它与 Module 1 对话系统深度联动：

```
[对话中] @agent "帮我实现用户登录模块"
         ↓
[自动创建任务] 标题="实现用户登录模块", 指派=Agent, 来源=对话消息
         ↓
[任务执行中] 进度更新同步到对话线程
         ↓
[执行完成] 结果报告发送到对话 + 任务卡片
```

---

## 5. 用户故事

### 5.1 看板管理

#### US-2.1：看板视图
**作为**项目成员，**我希望**看到项目的 Kanban 看板，**以便**一眼了解所有任务的状态。
- **AC1**: 看板默认四列：待办（Todo）→ 进行中（In Progress）→ 已完成（Done）
- **AC2**: 每列显示任务卡片，按排序权重（sort_order）排列
- **AC3**: 支持拖拽卡片在列间移动（更新 status）和列内排序（更新 sort_order）
- **AC4**: 拖拽操作的 P99 延迟 < 100ms（乐观更新 + 后端异步确认）
- **AC5**: 看板支持按项目（project_id）过滤

#### US-2.2：任务卡片信息
**作为**项目成员，**我希望**任务卡片显示关键信息，**以便**不用点进详情就能了解任务状态。
- **AC1**: 卡片显示：标题、标签（颜色编码）、优先级标识（P0 红 / P1 橙 / P2 黄 / P3 蓝 / P4 灰）
- **AC2**: 卡片显示指派人头像（人类或 Agent 头像，Agent 有机器人标记）
- **AC3**: 卡片显示截止日期（超期高亮为红色）
- **AC4**: 卡片显示进度条（0-100%）—— Agent 任务时实时更新，人类任务时手动更新
- **AC5**: Agent 任务卡片显示执行状态徽章（准备中/执行中/已阻塞/审查中）
- **AC6**: 卡片显示评论数量和最近一条评论摘要

#### US-2.3：任务创建
**作为**项目成员，**我希望**快速创建任务，**以便**随时记录工作项。
- **AC1**: 在任意列点击"+"快速创建任务（只需输入标题）
- **AC2**: 展开后填写完整信息：描述（Markdown）、标签、优先级、指派人、截止日期
- **AC3**: 指派人下拉列表同时显示人类成员和可用 Agent（分组展示）
- **AC4**: 支持从对话消息一键创建任务（预填描述 = 消息内容）
- **AC5**: 支持 Cmd+K 全局快速创建

#### US-2.4：任务详情
**作为**项目成员，**我希望**查看任务完整详情，**以便**了解任务的上下文和执行情况。
- **AC1**: 侧栏或全屏展示任务详情
- **AC2**: 详情包含：标题、描述（Markdown 渲染）、状态、优先级、标签、指派人、截止日期、进度
- **AC3**: 详情包含：评论区（时间线形式，人类和 Agent 评论混合展示）
- **AC4**: 详情包含：活动日志（状态变更、指派人变更、标签修改等自动记录）
- **AC5**: 详情包含：关联 Git Issue/PR 链接
- **AC6**: 详情包含：子任务列表（如果有）

### 5.2 Agent 任务执行

#### US-2.5：指派给 Agent
**作为**项目负责人，**我希望**将任务指派给 Agent，**以便**让 AI 自动完成工作。
- **AC1**: 在指派人选择器中选择 Agent 后，任务自动进入"进行中"状态
- **AC2**: Agent 开始执行前显示"准备中"状态（Agent 接收任务 + 分析需求）
- **AC3**: 执行开始后，任务卡片上的进度条开始实时更新
- **AC4**: Agent 的执行日志实时流入任务评论区（可折叠的日志视图）
- **AC5**: 如果指派的 Agent 不可用（离线/过载），显示错误提示并建议替代 Agent
- **AC6**: 人类可以中途取消 Agent 的执行

#### US-2.6：Agent 执行过程可视化
**作为**团队成员，**我希望**实时看到 Agent 的执行过程，**以便**了解 AI 正在做什么。
- **AC1**: 任务详情页有"执行面板"Tab，展示 Agent 的实时日志流
- **AC2**: 日志支持分级显示（信息/警告/错误）
- **AC3**: 进度条显示百分比 + 当前步骤描述（"正在编写测试用例 3/7"）
- **AC4**: 如果 Agent 创建了 Git PR，PR 链接实时出现在任务详情中
- **AC5**: 执行完成后，Agent 自动生成结构化结果报告（摘要 + 详情 + 产出物链接）
- **AC6**: 执行失败时，显示错误原因和建议操作（重试/转人工/修改任务描述）

#### US-2.7：Agent 任务筛选
**作为**团队负责人，**我希望**筛选出所有 Agent 正在执行的任务，**以便**监控 AI 的工作负载。
- **AC1**: 筛选栏有"Agent 执行中"快速筛选标签
- **AC2**: 筛选结果显示所有 assignee_type='agent' 且 status='in_progress' 的任务
- **AC3**: 每张卡片显示实时进度和执行时长
- **AC4**: 支持按 Agent 分组查看（"Code-Agent: 3 tasks | Review-Agent: 1 task"）

### 5.3 筛选与视图

#### US-2.8：筛选视图
**作为**项目成员，**我希望**快速筛选任务，**以便**聚焦关注的内容。
- **AC1**: 预设筛选：全部 / 我负责的 / Agent 执行中 / 高优先级（P0+P1）
- **AC2**: 支持按项目、标签、优先级、指派人、截止日期范围、状态组合筛选
- **AC3**: 筛选条件可保存为自定义视图
- **AC4**: 筛选结果实时更新（不需要手动刷新）
- **AC5**: 支持按项目过滤：选择特定 project_id 只显示该项目的任务

#### US-2.9：搜索
**作为**项目成员，**我希望**搜索任务，**以便**快速找到特定任务。
- **AC1**: 支持按标题、描述全文搜索
- **AC2**: 搜索结果高亮关键词
- **AC3**: 支持 Cmd+K 全局搜索快速入口
- **AC4**: 搜索范围覆盖所有可见项目的任务

### 5.4 任务评论与协作

#### US-2.10：任务评论
**作为**项目成员，**我希望**在任务中留评论，**以便**讨论任务细节。
- **AC1**: 评论支持 Markdown 格式
- **AC2**: 评论支持 @mention 人类和 Agent
- **AC3**: Agent 可以自动发表评论（执行进度更新、结果报告）
- **AC4**: 评论按时间线排列，显示作者头像和时间戳
- **AC5**: 支持评论中附加图片和文件

#### US-2.11：Agent 结果报告
**作为**任务创建人，**我希望** Agent 完成任务后自动附上结果报告，**以便**我快速验收。
- **AC1**: Agent 执行完成后自动在评论区发布结构化报告
- **AC2**: 报告包含：执行摘要、产出物链接（PR/文件/部署 URL）、耗时、Token 消耗
- **AC3**: 报告包含：自检结果（测试通过率、代码质量评分等，如适用）
- **AC4**: 报告中的链接可直接点击跳转

### 5.5 Git 同步

#### US-2.12：Task → Git Issue 同步
**作为**开发者，**我希望**创建 Task 时自动创建 GitHub/GitLab Issue，**以便**代码仓库与任务系统保持同步。
- **AC1**: 项目设置中配置 Git 仓库关联（支持多仓库）
- **AC2**: 创建 Task 时可选择"同步到 Git"（默认开启）
- **AC3**: Task 标题、描述、标签自动映射到 Git Issue 字段
- **AC4**: Task 状态变更自动反映到 Git Issue（关闭/重开）
- **AC5**: 同步状态可见：任务详情显示"已同步到 GitHub #123"

#### US-2.13：Git Issue → Task 同步
**作为**开发者，**我希望** GitHub/GitLab Issue 的变更自动同步回 Task，**以便**看板始终反映最新状态。
- **AC1**: Git Issue 标题/描述修改自动同步到 Task
- **AC2**: Git Issue 关闭/重开自动更新 Task 状态
- **AC3**: PR merged 事件自动将关联 Task 标记为已完成
- **AC4**: 新建的 Git Issue（在已关联仓库中）可自动创建 Task（可配置）
- **AC5**: 冲突时优先保留最后修改方，并在任务活动日志中记录冲突

### 5.6 自动化规则

#### US-2.14：自动化规则配置
**作为**项目管理员，**我希望**配置自动化规则，**以便**减少重复操作。
- **AC1**: 支持配置触发条件 + 动作的规则
- **AC2**: 内置模板："PR merged → 任务自动完成"、"Agent 成功率 < 80% → 通知管理员"、"任务超期 → 提升优先级"
- **AC3**: 支持自定义规则（选择触发事件 + 条件过滤 + 执行动作）
- **AC4**: 规则可启用/禁用，有执行日志可查

---

## 6. 功能拆分

### 6.1 P0 — 核心功能（MVP 必备，~5 周）

#### F-P0-01：Kanban 看板
- 四列看板：待办 → 进行中 → 已完成
- 任务卡片渲染（标题、标签、优先级、指派人头像、截止日期、进度条）
- 拖拽排序（列间移动 = 状态变更，列内排序 = sort_order 更新）
- 乐观更新 + 后端确认（拖拽即时响应，后端异步持久化）
- 看板按项目过滤

**验收标准：**
- 看板加载 P99 < 500ms（100 张卡片以内）
- 拖拽操作感知延迟 < 100ms
- 支持 200+ 张卡片无性能退化
- 多用户同时拖拽无冲突（最后写入胜出 + 冲突提示）

#### F-P0-02：任务 CRUD
- 快速创建（仅标题）
- 完整创建/编辑（标题、描述、标签、优先级、指派人、截止日期）
- 任务详情侧栏/全屏
- 任务删除（软删除）
- 任务归档

**验收标准：**
- 创建任务 API 响应 < 200ms
- 描述支持完整 Markdown 渲染（含代码块、表格、链接）
- 标签支持自定义颜色和名称
- 优先级 P0-P4 五级

#### F-P0-03：多态指派（Human + Agent）
- 指派人选择器：人类成员 + 可用 Agent 混合列表
- Agent 有类型标识（机器人图标 + 角色描述）
- 指派给 Agent 后自动触发执行（status → in_progress）
- Agent 执行状态徽章（preparing/executing/blocked/reviewing）
- Agent 进度条实时更新（WebSocket）
- 人工取消 Agent 执行

**验收标准：**
- 指派给 Agent 后 < 3s 内状态变为"进行中"
- 进度更新延迟（Agent 侧到前端显示）< 500ms
- 取消操作 < 2s 内生效
- Agent 离线时显示明确错误提示

#### F-P0-04：任务筛选
- 预设筛选：全部 / 我负责的 / Agent 执行中 / 高优先级
- 按项目过滤
- 组合筛选：标签 + 优先级 + 指派人 + 状态
- 筛选条件实时更新结果

**验收标准：**
- 筛选操作响应 < 200ms
- 支持多条件组合（AND 逻辑）
- 筛选结果计数准确

#### F-P0-05：任务评论
- 人类发表评论（Markdown）
- Agent 自动发表评论（执行进度、结果报告）
- 评论时间线展示
- @mention 人类和 Agent

**验收标准：**
- 评论发送 < 500ms
- Agent 自动评论实时出现（WebSocket 推送）
- Markdown 渲染正确

### 6.2 P1 — 重要功能（第二阶段）

#### F-P1-01：GitHub/GitLab 双向同步
- OAuth 授权连接 GitHub/GitLab
- Task → Issue 正向同步（创建/更新/关闭）
- Issue → Task 反向同步（Webhook 接收）
- PR 事件关联（PR merged → Task Done）
- 字段映射配置
- 同步状态指示器

#### F-P1-02：任务评论增强
- 评论中附加图片/文件
- Agent 结构化结果报告（模板化展示）
- 评论搜索
- 评论引用

#### F-P1-03：Agent 执行日志面板
- 任务详情中的"执行"Tab
- 实时日志流（WebSocket）
- 日志分级（info/warn/error）
- 执行步骤可视化（步骤条）
- 历史执行记录

#### F-P1-04：任务搜索
- 全文搜索（标题 + 描述）
- 高级搜索过滤
- Cmd+K 全局搜索集成
- 搜索结果高亮

#### F-P1-05：自定义视图
- 保存筛选条件为视图
- 视图命名和管理
- 团队共享视图

### 6.3 P2 — 增强功能（第三阶段）

#### F-P2-01：自动化规则引擎
- 触发条件配置（任务状态变更、Git 事件、定时触发）
- 动作配置（状态变更、通知、指派、标签修改）
- 内置规则模板
- 规则执行日志
- Agent 成功率监控告警

#### F-P2-02：子任务
- 任务拆分为子任务
- 子任务独立指派（不同人/不同 Agent）
- 子任务进度汇总到父任务
- 子任务看板视图

#### F-P2-03：对话-任务联动
- 从对话消息一键创建任务
- Agent 任务进度同步到对话线程
- 任务完成通知到对话
- 对话中的 @Agent 自动创建并执行任务

#### F-P2-04：任务统计仪表板
- Agent 任务执行统计（成功率、平均耗时、Token 消耗）
- 项目进度概览
- 团队工作负载分布
- 趋势图表（完成速度、积压趋势）

#### F-P2-05：任务模板
- 创建任务模板（预设标题、描述、标签、优先级）
- Agent 执行配置模板（预设 Agent + 执行参数）
- 模板库管理

#### F-P2-06：批量操作
- 多选任务批量修改（状态、标签、优先级、指派人）
- 批量指派给 Agent
- 批量归档/删除

---

## 7. Agent 任务透明化模型

### 7.1 设计理念

Agent 任务透明化是 CODE-YI 任务模块的**核心差异化**。Stephanie 的原话精准定义了需求："我是想通过这个 agent 来透明化它究竟有哪些任务在跑啊"。

这不是一个附加功能——它是整个任务模块存在的核心理由。

### 7.2 Agent 执行生命周期

```
              ┌──────────┐
              │ ASSIGNED │  Agent 被指派为执行者
              └────┬─────┘
                   │ Agent 确认接收
                   ↓
              ┌──────────┐
              │PREPARING │  Agent 分析任务需求，规划执行步骤
              └────┬─────┘
                   │ 规划完成
                   ↓
              ┌──────────┐
              │EXECUTING │  Agent 正在执行（进度 0→100%）
              └────┬─────┘
                   │
         ┌─────────┼──────────┐
         ↓         ↓          ↓
   ┌──────────┐ ┌───────┐ ┌──────────┐
   │ BLOCKED  │ │SUCCESS│ │ FAILED   │
   │(需人工)   │ │       │ │          │
   └────┬─────┘ └───┬───┘ └────┬─────┘
        │            │          │
        │ 解除阻塞    ↓          │ 自动重试
        │     ┌──────────┐      │
        └────→│REVIEWING │←─────┘ (max retries内)
              │(自检/审查) │
              └────┬─────┘
                   │
              ┌────┴────┐
              ↓         ↓
        ┌──────────┐ ┌──────────┐
        │COMPLETED │ │REJECTED  │
        │(完成)     │ │(退回修改) │
        └──────────┘ └────┬─────┘
                          │ Agent 重新执行
                          ↓
                     EXECUTING (retry)
```

### 7.3 透明化的四个层级

#### Layer 1：状态透明（任何人一眼可见）

在看板卡片上直接展示 Agent 的执行阶段：

```
┌────────────────────────────────┐
│ [前端]  [Agent]                │
│                                │
│ 实现用户登录页面                 │
│                                │
│ Code-Agent                     │
│ 执行中 — 编写组件代码            │
│ ████████████░░░░░░  63%        │
│                                │
│ P1  Apr 22  5 comments         │
└────────────────────────────────┘
```

- 执行阶段用颜色编码的徽章显示
- 进度条显示 0-100% 进度
- 当前步骤的一行描述
- Agent 头像带机器人标记

#### Layer 2：进度透明（点开卡片可见）

任务详情页的"执行"Tab 展示 Agent 的执行步骤：

```
执行计划（3 步）
─────────────────────────────────
[done] Step 1: 分析需求                 2m 15s
   → 解析任务描述，确定组件结构

[active] Step 2: 编写代码               进行中...
   → 正在编写 LoginForm.tsx
   → 正在编写 useAuth.ts

[pending] Step 3: 运行测试              待执行
   → 单元测试 + 集成测试
```

每个步骤包含：
- 状态图标（done / active / pending / failed / blocked）
- 步骤标题和描述
- 耗时（已完成步骤）或"进行中..."（当前步骤）
- 子步骤展开（可折叠）

#### Layer 3：日志透明（开发者调试级）

实时执行日志流，类似终端输出：

```
[15:30:01] INFO   Agent 接收任务: "实现用户登录页面"
[15:30:03] INFO   分析任务需求...
[15:30:15] INFO   规划完成: 3 个步骤, 预计 8-12 分钟
[15:30:16] INFO   Step 1/3: 分析需求
[15:32:01] INFO   Step 1 完成 (2m 15s)
[15:32:02] INFO   Step 2/3: 编写代码
[15:32:03] INFO   创建文件 src/components/LoginForm.tsx
[15:33:15] INFO   创建文件 src/hooks/useAuth.ts
[15:34:02] WARN   注意: 检测到已有 auth 相关代码，将复用现有接口
[15:34:30] INFO   代码编写完成，准备测试
[15:34:31] INFO   Step 3/3: 运行测试
[15:34:45] INFO   运行 vitest... 5 tests
[15:35:10] ERROR  Test failed: login.test.ts — Expected 200, got 401
[15:35:12] INFO   修复测试: 更新 mock auth token
[15:35:30] INFO   重新运行测试... 5/5 passed
[15:35:31] INFO   任务完成
```

日志特性：
- 实时流（WebSocket 推送），光标闪烁效果
- 颜色编码（INFO 白 / WARN 黄 / ERROR 红）
- 可搜索、可导出
- 断线重连后自动补齐缺失日志

#### Layer 4：结果透明（Agent 交付物）

Agent 完成任务后自动生成的结果报告：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
执行报告 — 实现用户登录页面
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

状态: 成功完成
耗时: 5m 31s
Token 消耗: 12,450 tokens

产出物:
  - PR #142: feat(auth): add login page
    https://github.com/coco/code-yi/pull/142
  - 新增文件: LoginForm.tsx, useAuth.ts, login.test.ts
  - 测试: 5/5 passed

执行摘要:
  根据任务描述，创建了用户登录页面组件。
  包含邮箱+密码表单、输入验证、错误处理、
  OAuth 第三方登录按钮。复用了现有的 auth API 接口。

自检结果:
  - TypeScript 类型检查: 通过
  - ESLint: 0 warnings
  - 单元测试: 5/5 passed
  - 代码行数: +187 lines
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 7.4 Agent 任务面板（全局视图）

除了单个任务的透明化，还需要一个全局 Agent 监控面板：

```
┌──────────────────────────────────────────────┐
│  Agent 任务总览                               │
├──────────────────────────────────────────────┤
│                                              │
│  Code-Agent                    2 tasks       │
│  ├── 实现用户登录页面  63%   P1              │
│  └── 修复支付接口 bug  28%   P0              │
│                                              │
│  Review-Agent                  1 task        │
│  └── 审查 PR #138     80%   P2              │
│                                              │
│  Test-Agent                    1 task        │
│  └── 回归测试套件     45%   P1              │
│                                              │
│  Design-Agent                  (idle)        │
│                                              │
│  ─────────────────────────────────────────   │
│  总计: 4 tasks running | 2 agents idle       │
│  今日完成: 7 tasks | 成功率: 85.7%            │
└──────────────────────────────────────────────┘
```

### 7.5 Agent 执行通信协议

Agent 与任务系统之间的实时通信协议：

#### 7.5.1 Agent → Task System（进度上报）

```json
{
  "type": "task_progress",
  "task_id": "task_xxx",
  "agent_id": "agent_code_01",
  "payload": {
    "execution_phase": "executing",
    "progress": 63,
    "current_step": {
      "index": 2,
      "total": 3,
      "title": "编写代码",
      "description": "正在编写 LoginForm.tsx"
    },
    "log_entry": {
      "level": "info",
      "message": "创建文件 src/components/LoginForm.tsx",
      "timestamp": "2026-04-20T15:32:03Z"
    }
  }
}
```

#### 7.5.2 Task System → Agent（任务下发/控制）

```json
// 任务下发
{
  "type": "task_assign",
  "task_id": "task_xxx",
  "payload": {
    "title": "实现用户登录页面",
    "description": "根据设计稿，实现登录页面组件...",
    "priority": "p1",
    "labels": ["前端", "Agent"],
    "context": {
      "project_id": "proj_xxx",
      "related_tasks": ["task_yyy"],
      "git_repo": "coco/code-yi",
      "git_branch": "feat/login-page"
    }
  }
}
```

```json
// 执行控制
{
  "type": "task_control",
  "task_id": "task_xxx",
  "action": "cancel"
}
```

#### 7.5.3 WebSocket 事件清单

| 事件类型 | 方向 | 说明 |
|----------|------|------|
| `task_assign` | System → Agent | 下发任务 |
| `task_control` | System → Agent | 控制执行（取消/暂停/恢复/重试） |
| `task_progress` | Agent → System | 进度更新（进度%、当前步骤、日志） |
| `task_phase_change` | Agent → System | 执行阶段变更 |
| `task_log` | Agent → System | 执行日志条目 |
| `task_result` | Agent → System | 执行结果报告 |
| `task_blocked` | Agent → System | 执行阻塞（需人工输入） |
| `task_completed` | Agent → System | 执行完成 |
| `task_failed` | Agent → System | 执行失败 |

### 7.6 进度百分比的语义计算

Agent 报告的进度百分比不应是随机数，而是有语义的：

**基于步骤的进度计算：**
```
总步骤 = N
当前完成步骤 = M
当前步骤内进度 = P (0-100%)

总进度 = (M * 100 + P) / N
```

**示例：**
```
3 步任务:
  Step 1 完成 (100%), Step 2 进行中 (50%), Step 3 待执行 (0%)
  总进度 = (1*100 + 50) / 3 = 50%
```

**Agent 端实现建议：**
- Agent 在 PREPARING 阶段确定步骤列表和权重
- 每个步骤的权重可以不同（如"编写代码"占 60%，"运行测试"占 30%，"生成报告"占 10%）
- Agent 按步骤权重报告加权进度

---

## 8. GitHub/GitLab 双向同步架构

### 8.1 设计理念

Git 同步不是简单的 Webhook 事件处理——它是一个持续运行的双向同步引擎，确保 CODE-YI 任务和 Git Issue 始终保持一致。

### 8.2 同步架构总览

```
┌─────────────────────────────────────────────────────┐
│                  CODE-YI Task System                  │
│                                                      │
│  ┌──────────────┐    ┌────────────────────────┐      │
│  │ Task Service  │    │  Git Sync Engine        │      │
│  │              │    │                        │      │
│  │  CRUD API    │───→│  Outbound Sync Queue    │──┐   │
│  │  Events      │    │  (Task → Git Issue)     │  │   │
│  │              │←───│  Inbound Sync Handler   │  │   │
│  │              │    │  (Git Event → Task)     │  │   │
│  │              │    │                        │  │   │
│  │              │    │  Conflict Resolver      │  │   │
│  │              │    │  Sync State Tracker     │  │   │
│  └──────────────┘    └────────────────────────┘  │   │
│                                                  │   │
└──────────────────────────────────────────────────┼───┘
                                                   │
                   ┌───────────────────────────────┘
                   │
                   ↓  REST API / GraphQL
┌──────────────────────────────────────────────────────┐
│           GitHub / GitLab                             │
│                                                      │
│  ┌──────────┐  ┌──────────┐  ┌────────────────┐     │
│  │  Issues   │  │   PRs    │  │  Webhooks      │     │
│  └──────────┘  └──────────┘  │  (→ inbound)    │     │
│                              └────────────────┘     │
└──────────────────────────────────────────────────────┘
```

### 8.3 连接配置

#### 8.3.1 OAuth 授权流程

```
用户 → CODE-YI 设置页 → "连接 GitHub"
  → OAuth 授权页面（scope: repo, webhook, read:org）
  → 回调后存储 access_token
  → 选择要同步的仓库
  → 配置同步策略
```

#### 8.3.2 同步配置数据模型

```json
{
  "project_id": "proj_xxx",
  "git_provider": "github",
  "git_owner": "coco-org",
  "git_repo": "code-yi",
  "access_token_encrypted": "...",
  "sync_config": {
    "direction": "bidirectional",
    "auto_create_issue": true,
    "auto_create_task": false,
    "auto_close_on_merge": true,
    "field_mapping": {
      "priority": {
        "p0": ["priority:critical"],
        "p1": ["priority:high"],
        "p2": ["priority:medium"],
        "p3": ["priority:low"],
        "p4": []
      },
      "labels": {
        "前端": ["frontend"],
        "后端": ["backend"],
        "Agent": ["agent"],
        "设计": ["design"],
        "DevOps": ["devops"],
        "文档": ["documentation"],
        "测试": ["testing"]
      },
      "status": {
        "todo": "open",
        "in_progress": "open",
        "done": "closed",
        "archived": "closed"
      }
    }
  }
}
```

### 8.4 正向同步（Task → Git Issue）

#### 8.4.1 同步触发时机

| 事件 | 同步动作 |
|------|----------|
| Task 创建（auto_create_issue=true） | 创建 Git Issue |
| Task 标题修改 | 更新 Git Issue 标题 |
| Task 描述修改 | 更新 Git Issue 描述 |
| Task 标签变更 | 更新 Git Issue labels |
| Task 关闭 | 关闭 Git Issue |
| Task 重开 | 重开 Git Issue |
| Task 评论新增 | 创建 Git Issue comment |

#### 8.4.2 正向同步流程

```
Task Event (创建/修改/关闭)
     │
     ↓
Outbound Sync Queue (Redis)
     │
     ↓ 消费者
Sync Worker
     │
     ├── 1. 检查 sync_state: 该变更是否由 inbound 同步触发？
     │      └── 是 → 跳过（避免循环）
     │
     ├── 2. 检查 conflict: 是否有 pending 的 inbound 变更？
     │      └── 有 → 进入冲突解决
     │
     ├── 3. 字段映射: Task fields → Git Issue fields
     │
     ├── 4. API 调用: GitHub/GitLab REST API
     │      └── 创建/更新/关闭 Issue
     │
     ├── 5. 记录 sync_state:
     │      {task_id, git_issue_id, synced_at, sync_hash}
     │
     └── 6. 更新 Task: git_issue_url = Issue URL
```

#### 8.4.3 GitHub API 调用示例

```typescript
// 创建 Issue
async function createGitHubIssue(task: Task, config: SyncConfig): Promise<string> {
  const labels = mapLabels(task.labels, config.field_mapping.labels);
  const priorityLabels = config.field_mapping.priority[task.priority] || [];

  const response = await octokit.rest.issues.create({
    owner: config.git_owner,
    repo: config.git_repo,
    title: task.title,
    body: buildIssueBody(task),
    labels: [...labels, ...priorityLabels],
    assignees: task.assignee_type === 'human'
      ? [await getGitHubUsername(task.assignee_id)]
      : [],   // Agent 不映射为 GitHub assignee
  });

  return response.data.html_url;
}

function buildIssueBody(task: Task): string {
  return [
    task.description,
    '',
    '---',
    `> Synced from CODE-YI Task \`${task.id}\``,
    `> Priority: ${task.priority.toUpperCase()}`,
    task.due_date ? `> Due: ${task.due_date}` : '',
    task.assignee_type === 'agent'
      ? `> Assigned to Agent: ${task.assignee_name}`
      : '',
  ].filter(Boolean).join('\n');
}
```

### 8.5 反向同步（Git Event → Task）

#### 8.5.1 Webhook 事件处理

| Git 事件 | 同步动作 |
|----------|----------|
| `issues.opened` | 创建 Task（如 auto_create_task=true） |
| `issues.edited` | 更新 Task 标题/描述 |
| `issues.closed` | 关闭 Task（status → done） |
| `issues.reopened` | 重开 Task（status → todo） |
| `issues.labeled` | 更新 Task 标签 |
| `issues.unlabeled` | 移除 Task 标签 |
| `issue_comment.created` | 创建 Task 评论 |
| `pull_request.merged` | 关闭关联 Task（如 auto_close_on_merge） |
| `pull_request.opened` | 在 Task 中显示 PR 链接 |

#### 8.5.2 Webhook 处理流程

```
GitHub Webhook POST /api/v1/webhooks/github
     │
     ↓
Webhook Signature Verification (HMAC-SHA256)
     │
     ↓
Event Router
     │
     ├── issues.* → Issue Sync Handler
     ├── pull_request.* → PR Sync Handler
     └── other → Ignore

Issue Sync Handler:
     │
     ├── 1. 查找关联 Task (by git_issue_url or sync_state)
     │      └── 找不到 + auto_create_task → 创建新 Task
     │
     ├── 2. 检查 sync_state: 该变更是否由 outbound 同步触发？
     │      └── 是 → 跳过（避免循环）
     │
     ├── 3. 字段映射: Git Issue fields → Task fields
     │
     ├── 4. 更新 Task
     │
     └── 5. 记录 sync_state
```

### 8.6 冲突检测与解决

#### 8.6.1 冲突场景

```
T=0  Task 标题 = "实现登录"    Git Issue 标题 = "实现登录"
T=1  用户在 CODE-YI 修改标题为 "实现登录页面"
T=2  另一用户在 GitHub 修改标题为 "Implement login"
T=3  两个变更几乎同时到达同步引擎
```

#### 8.6.2 冲突解决策略

**默认策略：Last-Write-Wins + 审计日志**

```
1. 每次同步记录 {field, value, timestamp, source}
2. 当检测到两侧都有变更时（sync_hash 不匹配）:
   a. 比较两侧变更的 timestamp
   b. 保留最后修改方的值
   c. 在 Task 活动日志中记录冲突:
      "冲突: 标题同时在 CODE-YI 和 GitHub 被修改。
       保留了 GitHub 侧的修改 (更晚)。
       CODE-YI 侧被覆盖的值: '实现登录页面'"
```

#### 8.6.3 防循环机制

```
每次同步操作标记 sync_source:

Outbound sync 写入 Git Issue 时:
  → 在 sync_state 表记录 {operation_id, direction: 'outbound', timestamp}

Inbound webhook 到达时:
  → 检查该变更是否匹配最近 60s 内的 outbound operation
  → 如果匹配（通过内容 hash 比较）→ 跳过
  → 如果不匹配 → 正常处理
```

### 8.7 PR ↔ Task 关联

```
PR 关联规则:
  1. PR 描述中包含 "Closes #123" / "Fixes #123" → 关联到 sync 了 Issue #123 的 Task
  2. PR 分支名包含 task ID → 直接关联
  3. Agent 创建的 PR → 自动关联到触发 Agent 执行的 Task

PR 事件处理:
  PR opened  → Task 详情显示 "PR #142 opened"
  PR merged  → Task 自动完成（如配置 auto_close_on_merge）
  PR closed  → Task 详情显示 "PR #142 closed without merge"
```

### 8.8 多仓库支持

一个 CODE-YI 项目可以关联多个 Git 仓库：

```
Project: "CODE-YI 主项目"
├── github.com/coco/code-yi-frontend  (前端仓库)
├── github.com/coco/code-yi-backend   (后端仓库)
└── gitlab.com/coco/code-yi-infra     (基础设施仓库)

任务创建时:
  → 用户选择同步到哪个仓库（或多个仓库）
  → Task 可以关联多个 Git Issue（一对多）
```

---

## 9. 数据模型

### 9.1 核心实体关系

```
┌────────────┐    ┌──────────────┐    ┌────────────┐
│   users    │    │    tasks     │    │   agents   │
├────────────┤    ├──────────────┤    ├────────────┤
│ id         │──┐ │ id           │ ┌──│ id         │
│ name       │  │ │ workspace_id │ │  │ name       │
│ email      │  │ │ project_id   │ │  │ type       │
│ avatar_url │  │ │ title        │ │  │ status     │
└────────────┘  │ │ assignee_id  │─┘  └────────────┘
                │ │ assignee_type│
                │ │ created_by   │
                │ │ status       │
                └─│ priority     │
                  │ labels[]     │
                  │ progress     │
                  │ due_date     │
                  │ sort_order   │
                  └──────┬───────┘
                         │
              ┌──────────┼──────────┐
              ↓          ↓          ↓
     ┌──────────────┐ ┌─────────┐ ┌──────────────┐
     │task_comments │ │task_git │ │task_execution│
     │              │ │_sync    │ │_logs         │
     └──────────────┘ └─────────┘ └──────────────┘
```

### 9.2 表结构定义

#### tasks（任务表）
```sql
CREATE TABLE tasks (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id    UUID NOT NULL REFERENCES workspaces(id),
    project_id      UUID REFERENCES projects(id),

    -- 基础字段
    title           VARCHAR(500) NOT NULL,
    description     TEXT,                    -- Markdown 格式
    status          VARCHAR(20) NOT NULL DEFAULT 'todo',
                    -- 'todo' | 'in_progress' | 'done' | 'archived'
    priority        VARCHAR(5) NOT NULL DEFAULT 'p3',
                    -- 'p0' | 'p1' | 'p2' | 'p3' | 'p4'
    labels          TEXT[] DEFAULT '{}',     -- ['设计','前端','Agent','DevOps','文档','测试']

    -- 指派（多态：人类或 Agent）
    assignee_id     UUID,                    -- user_id 或 agent_id
    assignee_type   VARCHAR(10),             -- 'human' | 'agent' | NULL

    -- 进度
    progress        INTEGER DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),

    -- Agent 执行状态（仅 assignee_type='agent' 时有意义）
    execution_phase VARCHAR(20),
                    -- 'assigned' | 'preparing' | 'executing' | 'blocked' | 'reviewing'
                    -- | 'completed' | 'failed' | 'cancelled'
    execution_started_at TIMESTAMPTZ,
    execution_completed_at TIMESTAMPTZ,

    -- 时间
    due_date        DATE,

    -- 排序
    sort_order      FLOAT NOT NULL DEFAULT 0,  -- 支持插入排序（取两个相邻值的中间值）

    -- Git 同步
    git_issue_url   TEXT,                    -- 主要 Git Issue 链接（快速访问）

    -- 元数据
    created_by      UUID NOT NULL,
    created_by_type VARCHAR(10) NOT NULL DEFAULT 'human',  -- 'human' | 'agent' | 'system'
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ              -- 软删除
);

-- 索引
CREATE INDEX idx_tasks_workspace_project ON tasks(workspace_id, project_id)
    WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_status ON tasks(workspace_id, status)
    WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_assignee ON tasks(assignee_id, assignee_type)
    WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_priority ON tasks(workspace_id, priority)
    WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_project_sort ON tasks(project_id, status, sort_order)
    WHERE deleted_at IS NULL;
CREATE INDEX idx_tasks_due_date ON tasks(due_date)
    WHERE due_date IS NOT NULL AND deleted_at IS NULL;
CREATE INDEX idx_tasks_execution_phase ON tasks(execution_phase)
    WHERE assignee_type = 'agent' AND deleted_at IS NULL;
CREATE INDEX idx_tasks_labels ON tasks USING gin(labels);
CREATE INDEX idx_tasks_search ON tasks USING gin(
    to_tsvector('simple', coalesce(title, '') || ' ' || coalesce(description, ''))
);
```

#### task_comments（任务评论表）
```sql
CREATE TABLE task_comments (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id         UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,

    -- 作者（多态：人类或 Agent）
    author_id       UUID NOT NULL,
    author_type     VARCHAR(10) NOT NULL,    -- 'human' | 'agent' | 'system'

    -- 内容
    content         TEXT NOT NULL,            -- Markdown 格式
    content_type    VARCHAR(20) DEFAULT 'text',
                    -- 'text' | 'execution_report' | 'status_change' | 'git_event'

    -- 结构化数据（用于 Agent 报告等）
    metadata        JSONB DEFAULT '{}',
    -- execution_report 示例:
    -- {
    --   "status": "success",
    --   "duration_ms": 331000,
    --   "token_usage": 12450,
    --   "artifacts": [
    --     {"type": "pr", "url": "https://github.com/..."},
    --     {"type": "file", "path": "src/components/LoginForm.tsx"}
    --   ],
    --   "test_results": {"passed": 5, "failed": 0, "total": 5}
    -- }

    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_task_comments_task ON task_comments(task_id, created_at)
    WHERE deleted_at IS NULL;
CREATE INDEX idx_task_comments_author ON task_comments(author_id, author_type);
```

#### task_execution_logs（Agent 执行日志表）
```sql
CREATE TABLE task_execution_logs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id         UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    agent_id        UUID NOT NULL,

    -- 执行批次（每次执行/重试一个新的 execution_id）
    execution_id    UUID NOT NULL,

    -- 日志内容
    log_level       VARCHAR(10) NOT NULL DEFAULT 'info',
                    -- 'info' | 'warn' | 'error' | 'debug'
    message         TEXT NOT NULL,

    -- 步骤信息
    step_index      INTEGER,                  -- 当前步骤序号
    step_total      INTEGER,                  -- 总步骤数
    step_title      VARCHAR(255),

    -- 进度快照
    progress        INTEGER,                  -- 该日志时刻的进度百分比

    timestamp       TIMESTAMPTZ DEFAULT NOW()
);

-- 按任务+执行批次查询日志
CREATE INDEX idx_execution_logs_task ON task_execution_logs(task_id, execution_id, timestamp);
-- 按时间范围查询（用于日志清理）
CREATE INDEX idx_execution_logs_time ON task_execution_logs(timestamp);
```

#### task_git_sync（Git 同步状态表）
```sql
CREATE TABLE task_git_sync (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id         UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,

    -- Git 侧信息
    git_provider    VARCHAR(10) NOT NULL,     -- 'github' | 'gitlab'
    git_owner       VARCHAR(255) NOT NULL,
    git_repo        VARCHAR(255) NOT NULL,
    git_issue_number INTEGER NOT NULL,
    git_issue_url   TEXT NOT NULL,

    -- 同步状态
    sync_status     VARCHAR(20) DEFAULT 'synced',
                    -- 'synced' | 'pending_outbound' | 'pending_inbound' | 'conflict' | 'error'
    last_synced_at  TIMESTAMPTZ,
    last_sync_hash  VARCHAR(64),              -- 最后同步内容的 hash，用于冲突检测
    last_sync_error TEXT,

    -- 配置
    sync_config_id  UUID REFERENCES git_sync_configs(id),

    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(task_id, git_provider, git_owner, git_repo, git_issue_number)
);

CREATE INDEX idx_task_git_sync_task ON task_git_sync(task_id);
CREATE INDEX idx_task_git_sync_issue ON task_git_sync(git_provider, git_owner, git_repo, git_issue_number);
```

#### git_sync_configs（Git 同步配置表）
```sql
CREATE TABLE git_sync_configs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id      UUID NOT NULL REFERENCES projects(id),

    -- Git 仓库信息
    git_provider    VARCHAR(10) NOT NULL,     -- 'github' | 'gitlab'
    git_owner       VARCHAR(255) NOT NULL,
    git_repo        VARCHAR(255) NOT NULL,

    -- 认证
    access_token_encrypted BYTEA NOT NULL,    -- AES-256-GCM 加密
    webhook_secret  VARCHAR(255),

    -- 同步策略
    sync_direction  VARCHAR(20) DEFAULT 'bidirectional',
                    -- 'to_git' | 'from_git' | 'bidirectional'
    auto_create_issue  BOOLEAN DEFAULT true,
    auto_create_task   BOOLEAN DEFAULT false,
    auto_close_on_merge BOOLEAN DEFAULT true,

    -- 字段映射
    field_mapping   JSONB NOT NULL DEFAULT '{}',

    -- 状态
    status          VARCHAR(20) DEFAULT 'active',  -- 'active' | 'paused' | 'error'
    last_error      TEXT,

    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(project_id, git_provider, git_owner, git_repo)
);
```

#### task_activity_log（任务活动日志表）
```sql
CREATE TABLE task_activity_log (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    task_id         UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,

    -- 操作者
    actor_id        UUID NOT NULL,
    actor_type      VARCHAR(10) NOT NULL,     -- 'human' | 'agent' | 'system'

    -- 活动类型
    action          VARCHAR(50) NOT NULL,
    -- 'created' | 'status_changed' | 'assignee_changed' | 'priority_changed'
    -- 'labels_changed' | 'title_changed' | 'description_changed'
    -- 'due_date_changed' | 'comment_added' | 'git_synced' | 'execution_started'
    -- 'execution_completed' | 'execution_failed' | 'archived' | 'deleted'

    -- 变更详情
    changes         JSONB,
    -- 示例: {"field": "status", "from": "todo", "to": "in_progress"}
    -- 示例: {"field": "assignee", "from": null, "to": {"id": "agent_01", "type": "agent"}}

    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_task_activity_log_task ON task_activity_log(task_id, created_at);
```

#### automation_rules（自动化规则表）
```sql
CREATE TABLE automation_rules (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id    UUID NOT NULL REFERENCES workspaces(id),
    project_id      UUID REFERENCES projects(id),  -- NULL = workspace 级别规则

    name            VARCHAR(255) NOT NULL,
    description     TEXT,

    -- 触发条件
    trigger_event   VARCHAR(50) NOT NULL,
    -- 'task_status_changed' | 'task_assigned' | 'pr_merged' | 'agent_execution_failed'
    -- 'task_overdue' | 'cron'
    trigger_config  JSONB NOT NULL,
    -- 示例: {"from_status": "in_progress", "to_status": "done"}
    -- 示例: {"agent_success_rate_below": 80, "time_window": "24h"}
    -- 示例: {"cron": "0 9 * * 1"}

    -- 条件过滤（可选）
    conditions      JSONB DEFAULT '[]',
    -- 示例: [{"field": "priority", "operator": "in", "value": ["p0","p1"]}]

    -- 执行动作
    actions         JSONB NOT NULL,
    -- 示例: [
    --   {"type": "change_status", "to": "done"},
    --   {"type": "notify", "channel": "chat", "message": "任务已自动完成"},
    --   {"type": "change_priority", "to": "p0"},
    --   {"type": "assign_to", "assignee_type": "human", "assignee_id": "user_xxx"}
    -- ]

    -- 状态
    enabled         BOOLEAN DEFAULT true,
    execution_count INTEGER DEFAULT 0,
    last_executed_at TIMESTAMPTZ,

    created_by      UUID NOT NULL REFERENCES users(id),
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_automation_rules_workspace ON automation_rules(workspace_id, enabled);
CREATE INDEX idx_automation_rules_trigger ON automation_rules(trigger_event, enabled);
```

### 9.3 Prisma Schema（与技术栈对齐）

```prisma
model Task {
  id                    String    @id @default(uuid()) @db.Uuid
  workspaceId           String    @db.Uuid @map("workspace_id")
  projectId             String?   @db.Uuid @map("project_id")

  title                 String    @db.VarChar(500)
  description           String?
  status                String    @default("todo") @db.VarChar(20)
  priority              String    @default("p3") @db.VarChar(5)
  labels                String[]  @default([])

  assigneeId            String?   @db.Uuid @map("assignee_id")
  assigneeType          String?   @db.VarChar(10) @map("assignee_type")

  progress              Int       @default(0)
  executionPhase        String?   @db.VarChar(20) @map("execution_phase")
  executionStartedAt    DateTime? @map("execution_started_at")
  executionCompletedAt  DateTime? @map("execution_completed_at")

  dueDate               DateTime? @db.Date @map("due_date")
  sortOrder             Float     @default(0) @map("sort_order")
  gitIssueUrl           String?   @map("git_issue_url")

  createdBy             String    @db.Uuid @map("created_by")
  createdByType         String    @default("human") @db.VarChar(10) @map("created_by_type")
  createdAt             DateTime  @default(now()) @map("created_at")
  updatedAt             DateTime  @updatedAt @map("updated_at")
  deletedAt             DateTime? @map("deleted_at")

  comments              TaskComment[]
  executionLogs         TaskExecutionLog[]
  gitSync               TaskGitSync[]
  activityLog           TaskActivityLog[]

  @@index([workspaceId, projectId])
  @@index([workspaceId, status])
  @@index([assigneeId, assigneeType])
  @@map("tasks")
}

model TaskComment {
  id            String    @id @default(uuid()) @db.Uuid
  taskId        String    @db.Uuid @map("task_id")
  authorId      String    @db.Uuid @map("author_id")
  authorType    String    @db.VarChar(10) @map("author_type")
  content       String
  contentType   String    @default("text") @db.VarChar(20) @map("content_type")
  metadata      Json      @default("{}")
  createdAt     DateTime  @default(now()) @map("created_at")
  updatedAt     DateTime  @updatedAt @map("updated_at")
  deletedAt     DateTime? @map("deleted_at")

  task          Task      @relation(fields: [taskId], references: [id], onDelete: Cascade)

  @@index([taskId, createdAt])
  @@map("task_comments")
}

model TaskExecutionLog {
  id            String    @id @default(uuid()) @db.Uuid
  taskId        String    @db.Uuid @map("task_id")
  agentId       String    @db.Uuid @map("agent_id")
  executionId   String    @db.Uuid @map("execution_id")
  logLevel      String    @default("info") @db.VarChar(10) @map("log_level")
  message       String
  stepIndex     Int?      @map("step_index")
  stepTotal     Int?      @map("step_total")
  stepTitle     String?   @db.VarChar(255) @map("step_title")
  progress      Int?
  timestamp     DateTime  @default(now())

  task          Task      @relation(fields: [taskId], references: [id], onDelete: Cascade)

  @@index([taskId, executionId, timestamp])
  @@map("task_execution_logs")
}

model TaskGitSync {
  id              String    @id @default(uuid()) @db.Uuid
  taskId          String    @db.Uuid @map("task_id")
  gitProvider     String    @db.VarChar(10) @map("git_provider")
  gitOwner        String    @db.VarChar(255) @map("git_owner")
  gitRepo         String    @db.VarChar(255) @map("git_repo")
  gitIssueNumber  Int       @map("git_issue_number")
  gitIssueUrl     String    @map("git_issue_url")
  syncStatus      String    @default("synced") @db.VarChar(20) @map("sync_status")
  lastSyncedAt    DateTime? @map("last_synced_at")
  lastSyncHash    String?   @db.VarChar(64) @map("last_sync_hash")
  lastSyncError   String?   @map("last_sync_error")
  syncConfigId    String?   @db.Uuid @map("sync_config_id")
  createdAt       DateTime  @default(now()) @map("created_at")
  updatedAt       DateTime  @updatedAt @map("updated_at")

  task            Task      @relation(fields: [taskId], references: [id], onDelete: Cascade)

  @@unique([taskId, gitProvider, gitOwner, gitRepo, gitIssueNumber])
  @@index([taskId])
  @@map("task_git_sync")
}

model TaskActivityLog {
  id          String    @id @default(uuid()) @db.Uuid
  taskId      String    @db.Uuid @map("task_id")
  actorId     String    @db.Uuid @map("actor_id")
  actorType   String    @db.VarChar(10) @map("actor_type")
  action      String    @db.VarChar(50)
  changes     Json?
  createdAt   DateTime  @default(now()) @map("created_at")

  task        Task      @relation(fields: [taskId], references: [id], onDelete: Cascade)

  @@index([taskId, createdAt])
  @@map("task_activity_log")
}
```

### 9.4 实体关系图

```
users ──────1:N────→ tasks (created_by)
agents ─────1:N────→ tasks (assignee_id, assignee_type='agent')
users ──────1:N────→ tasks (assignee_id, assignee_type='human')
projects ───1:N────→ tasks
workspaces ─1:N────→ tasks

tasks ──────1:N────→ task_comments
tasks ──────1:N────→ task_execution_logs
tasks ──────1:N────→ task_git_sync
tasks ──────1:N────→ task_activity_log

git_sync_configs ──1:N──→ task_git_sync
projects ──────────1:N──→ git_sync_configs

automation_rules ←──N:1── workspaces
automation_rules ←──N:1── projects (optional)
```

---

## 10. 技术方案

### 10.1 总体架构

```
┌─────────────────────────────────────────────────────────────────┐
│                          客户端层                                │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────────────┐  │
│  │ Web App  │  │ Desktop  │  │ Agent SDK (Node/Python)       │  │
│  │ (Next.js)│  │ (Electron│  │ - 接收任务分配                  │  │
│  │          │  │  /Tauri) │  │ - 上报进度/日志                 │  │
│  │ Kanban UI│  │          │  │ - 提交结果                     │  │
│  └────┬─────┘  └────┬─────┘  └──────────────┬───────────────┘  │
│       │              │                       │                  │
│       └──────────────┴───────────────────────┘                  │
│                          │  WebSocket + REST                    │
└──────────────────────────┼──────────────────────────────────────┘
                           │
┌──────────────────────────┼──────────────────────────────────────┐
│                     API Gateway 层                              │
│  ┌───────────────────────────────────────────────────────┐      │
│  │                 API Gateway (Fastify)                   │      │
│  │  - Logto JWT 验证                                      │      │
│  │  - 限流 (rate limiting)                                │      │
│  │  - WebSocket 升级                                      │      │
│  │  - Agent API Key 验证                                  │      │
│  └────┬─────────────┬─────────────┬──────────────────────┘      │
└───────┼─────────────┼─────────────┼──────────────────────────────┘
        │             │             │
┌───────┼─────────────┼─────────────┼──────────────────────────────┐
│       │        服务层             │                               │
│  ┌────┴──────┐  ┌──┴──────────┐  ┌────┴──────────┐              │
│  │ Task      │  │ Agent       │  │ Git Sync      │              │
│  │ Service   │  │ Execution   │  │ Engine        │              │
│  │           │  │ Service     │  │               │              │
│  │- 任务 CRUD │  │- 任务分配    │  │- Outbound 队列│              │
│  │- 看板排序  │  │- 进度收集    │  │- Inbound 处理 │              │
│  │- 筛选查询  │  │- 日志聚合    │  │- 冲突解决     │              │
│  │- 评论管理  │  │- 结果报告    │  │- 字段映射     │              │
│  └────┬──────┘  └──────┬──────┘  └──────┬────────┘              │
│       │                │                │                        │
│  ┌────┴────────────────┴────────────────┴───────────────────┐   │
│  │                   Event Bus (Redis Streams)               │   │
│  │  - task.created / task.updated / task.status_changed      │   │
│  │  - agent.progress / agent.log / agent.completed           │   │
│  │  - git.webhook / git.sync_completed                       │   │
│  └──────────────────────────────────────────────────────────┘   │
│       │                │                │                        │
│  ┌────┴──────┐  ┌──────┴──────┐  ┌─────┴────────┐              │
│  │Automation │  │ Notification│  │ Search       │              │
│  │ Engine    │  │ Service     │  │ Service      │              │
│  │           │  │             │  │ (PostgreSQL  │              │
│  │- 规则评估  │  │- 看板推送    │  │  full-text)  │              │
│  │- 动作执行  │  │- 对话通知    │  │              │              │
│  └───────────┘  └─────────────┘  └──────────────┘              │
└────────────────────────────────────────────────────────────────┘
        │                │                │
┌───────┼────────────────┼────────────────┼────────────────────────┐
│       │            数据层               │                        │
│  ┌────┴─────┐  ┌───────┴─────┐  ┌──────┴──────┐                │
│  │ Cloud SQL│  │    Redis    │  │  GitHub/    │                │
│  │ Postgres │  │ (Memorystore│  │  GitLab API │                │
│  │ (主库)   │  │  缓存+事件)  │  │  (外部)     │                │
│  └──────────┘  └─────────────┘  └─────────────┘                │
└────────────────────────────────────────────────────────────────┘
```

### 10.2 看板实时同步设计

#### 10.2.1 乐观更新 + 服务端确认

```
用户拖拽卡片从 "待办" 到 "进行中"

前端:
  1. 立即更新本地状态（乐观更新，0 延迟感知）
  2. 发送 WebSocket 消息: { type: "task_move", task_id, to_status, sort_order }
  3. 等待服务端确认

服务端:
  1. 收到 task_move 消息
  2. 验证权限
  3. 更新 DB (tasks.status, tasks.sort_order, tasks.updated_at)
  4. 发布到 Redis Streams: task.status_changed
  5. 返回确认: { type: "task_move_ack", task_id, success: true }

其他客户端:
  1. 通过 WebSocket 订阅收到 task.status_changed 事件
  2. 更新本地看板状态
  3. 如果当前正在拖拽同一卡片 → 冲突提示

回滚:
  如果服务端返回 success: false（权限不足/并发冲突）:
  1. 前端撤销乐观更新
  2. 显示错误提示
```

#### 10.2.2 排序算法

```
使用 float 类型的 sort_order，支持无限次插入排序:

初始排序: [1.0, 2.0, 3.0, 4.0]

插入到位置 2 和 3 之间:
  new_sort_order = (2.0 + 3.0) / 2 = 2.5
  排序变为: [1.0, 2.0, 2.5, 3.0, 4.0]

当精度不足时（连续插入导致浮点精度耗尽）:
  触发 rebalance: 重新分配整数序列 [1.0, 2.0, 3.0, 4.0, 5.0]
  rebalance 是后台操作，不影响前端体验
```

#### 10.2.3 WebSocket 事件清单（看板相关）

| 事件 | 方向 | 说明 |
|------|------|------|
| `task_created` | Server → Client | 新任务创建（其他用户看到新卡片出现） |
| `task_updated` | Server → Client | 任务字段更新 |
| `task_moved` | Server → Client | 任务状态/排序变更（看板卡片移动） |
| `task_deleted` | Server → Client | 任务删除（卡片消失） |
| `task_progress` | Server → Client | Agent 进度更新（进度条实时变化） |
| `task_comment_added` | Server → Client | 新评论 |
| `task_execution_log` | Server → Client | Agent 执行日志条目 |
| `task_move` | Client → Server | 用户拖拽操作 |
| `task_move_ack` | Server → Client | 拖拽确认/回滚 |

### 10.3 Agent 任务分配与执行架构

```
┌──────────────────────────────────────────────────────┐
│            Agent Execution Service                    │
├──────────────────────────────────────────────────────┤
│                                                      │
│  ┌──────────────┐    ┌────────────────────────┐      │
│  │ Task         │    │ Agent Connection       │      │
│  │ Dispatcher   │    │ Manager                │      │
│  │              │    │                        │      │
│  │ 监听         │    │ 管理所有 Agent 的        │      │
│  │ task.assigned│───→│ WebSocket 连接           │      │
│  │ 事件         │    │                        │      │
│  └──────────────┘    └────────┬───────────────┘      │
│                               │                      │
│                        ┌──────↓──────┐               │
│                        │ Execution   │               │
│                        │ Tracker     │               │
│                        ├─────────────┤               │
│                        │ - 进度聚合   │               │
│                        │ - 日志收集   │               │
│                        │ - 超时检测   │               │
│                        │ - 重试管理   │               │
│                        └──────┬──────┘               │
│                               │                      │
│                        ┌──────↓──────┐               │
│                        │ Result      │               │
│                        │ Handler     │               │
│                        ├─────────────┤               │
│                        │ - 结果验证   │               │
│                        │ - 报告生成   │               │
│                        │ - 状态更新   │               │
│                        │ - 通知分发   │               │
│                        └─────────────┘               │
│                                                      │
└──────────────────────────────────────────────────────┘
```

#### 10.3.1 任务分配流程

```
1. 用户在看板上将任务 assignee 设为 Agent
2. Task Service 更新 DB:
   - assignee_id = agent_id
   - assignee_type = 'agent'
   - execution_phase = 'assigned'
3. 发布事件到 Redis Streams: task.assigned
4. Agent Execution Service 消费事件:
   a. 检查 Agent 可用性（通过 WebSocket 连接状态）
   b. 可用 → 通过 WebSocket 发送 task_assign 消息给 Agent
   c. 不可用 → 标记 execution_phase = 'failed'，通知用户
5. Agent 确认接收 → execution_phase = 'preparing'
6. Agent 开始执行 → execution_phase = 'executing'
7. Agent 持续上报进度 → 更新 progress + 写入 execution_logs
8. Agent 执行完成 → execution_phase = 'completed', progress = 100
```

#### 10.3.2 超时与重试

```
配置:
  - 默认超时: 30 分钟（可按任务/Agent 配置）
  - 最大重试: 2 次
  - 重试间隔: 30 秒

超时处理:
  1. Execution Tracker 检测到超时
  2. 向 Agent 发送 cancel 控制消息
  3. 等待 Agent 确认取消（5 秒超时）
  4. 标记 execution_phase = 'failed'
  5. 如 retries < max_retries → 自动重试
  6. 否则 → 通知用户，建议人工介入

重试流程:
  1. 创建新的 execution_id
  2. execution_phase = 'assigned'
  3. 重新分配给同一 Agent（或备选 Agent）
  4. 携带上次执行的上下文（Agent 可选择复用中间结果）
```

### 10.4 API 设计

#### 任务 API
```
POST   /api/v1/tasks                          # 创建任务
GET    /api/v1/tasks                          # 查询任务列表（支持筛选）
GET    /api/v1/tasks/:id                      # 获取任务详情
PATCH  /api/v1/tasks/:id                      # 更新任务
DELETE /api/v1/tasks/:id                      # 删除任务（软删除）
POST   /api/v1/tasks/:id/move                 # 移动任务（状态+排序）
POST   /api/v1/tasks/:id/assign              # 指派任务
POST   /api/v1/tasks/:id/archive             # 归档任务
```

#### 任务评论 API
```
GET    /api/v1/tasks/:id/comments            # 获取评论列表
POST   /api/v1/tasks/:id/comments            # 添加评论
PATCH  /api/v1/tasks/:id/comments/:cid       # 编辑评论
DELETE /api/v1/tasks/:id/comments/:cid       # 删除评论
```

#### Agent 执行 API
```
GET    /api/v1/tasks/:id/execution           # 获取执行状态和日志
POST   /api/v1/tasks/:id/execution/cancel    # 取消执行
POST   /api/v1/tasks/:id/execution/retry     # 重试执行
GET    /api/v1/tasks/:id/execution/logs      # 获取执行日志（分页）
```

#### Agent SDK API（Agent 侧调用）
```
WS     /api/v1/agent/ws                      # Agent WebSocket 连接
POST   /api/v1/agent/tasks/:id/progress      # 上报进度（HTTP 回退）
POST   /api/v1/agent/tasks/:id/log           # 上报日志（HTTP 回退）
POST   /api/v1/agent/tasks/:id/complete      # 报告完成
POST   /api/v1/agent/tasks/:id/fail          # 报告失败
POST   /api/v1/agent/tasks/:id/blocked       # 报告阻塞
```

#### Git 同步 API
```
POST   /api/v1/projects/:pid/git-sync        # 配置 Git 仓库关联
GET    /api/v1/projects/:pid/git-sync        # 获取同步配置
PATCH  /api/v1/projects/:pid/git-sync/:id    # 更新同步配置
DELETE /api/v1/projects/:pid/git-sync/:id    # 断开 Git 仓库关联
POST   /api/v1/webhooks/github               # GitHub Webhook 入口
POST   /api/v1/webhooks/gitlab               # GitLab Webhook 入口
GET    /api/v1/tasks/:id/git-sync            # 获取任务的 Git 同步状态
POST   /api/v1/tasks/:id/git-sync/force      # 强制同步
```

#### 自动化规则 API
```
POST   /api/v1/automation-rules              # 创建规则
GET    /api/v1/automation-rules              # 查询规则列表
PATCH  /api/v1/automation-rules/:id          # 更新规则
DELETE /api/v1/automation-rules/:id          # 删除规则
POST   /api/v1/automation-rules/:id/enable   # 启用规则
POST   /api/v1/automation-rules/:id/disable  # 禁用规则
GET    /api/v1/automation-rules/:id/logs     # 规则执行日志
```

#### 筛选/视图 API
```
GET    /api/v1/tasks/filters                 # 获取可用筛选选项
POST   /api/v1/views                         # 保存自定义视图
GET    /api/v1/views                         # 获取视图列表
PATCH  /api/v1/views/:id                     # 更新视图
DELETE /api/v1/views/:id                     # 删除视图
```

### 10.5 API 请求/响应示例

#### 创建任务
```http
POST /api/v1/tasks
Content-Type: application/json
Authorization: Bearer <jwt>

{
  "workspace_id": "ws_xxx",
  "project_id": "proj_xxx",
  "title": "实现用户登录页面",
  "description": "根据设计稿 Screen-05，实现包含邮箱+密码的登录页面...",
  "priority": "p1",
  "labels": ["前端", "Agent"],
  "assignee_id": "agent_code_01",
  "assignee_type": "agent",
  "due_date": "2026-04-25"
}
```

```http
HTTP/1.1 201 Created

{
  "id": "task_abc123",
  "workspace_id": "ws_xxx",
  "project_id": "proj_xxx",
  "title": "实现用户登录页面",
  "description": "根据设计稿 Screen-05...",
  "status": "in_progress",
  "priority": "p1",
  "labels": ["前端", "Agent"],
  "assignee_id": "agent_code_01",
  "assignee_type": "agent",
  "assignee": {
    "id": "agent_code_01",
    "name": "Code-Agent",
    "avatar_url": "https://...",
    "type": "agent"
  },
  "progress": 0,
  "execution_phase": "assigned",
  "due_date": "2026-04-25",
  "sort_order": 5.0,
  "git_issue_url": null,
  "created_by": "user_stephanie",
  "created_at": "2026-04-20T15:30:00Z",
  "updated_at": "2026-04-20T15:30:00Z"
}
```

#### 查询任务列表（筛选 Agent 执行中）
```http
GET /api/v1/tasks?workspace_id=ws_xxx&assignee_type=agent&status=in_progress&sort=priority
Authorization: Bearer <jwt>
```

```http
HTTP/1.1 200 OK

{
  "data": [
    {
      "id": "task_abc123",
      "title": "实现用户登录页面",
      "status": "in_progress",
      "priority": "p1",
      "labels": ["前端", "Agent"],
      "assignee": {
        "id": "agent_code_01",
        "name": "Code-Agent",
        "type": "agent"
      },
      "progress": 63,
      "execution_phase": "executing",
      "due_date": "2026-04-25",
      "comment_count": 5,
      "git_issue_url": "https://github.com/coco/code-yi/issues/47"
    }
  ],
  "total": 1,
  "page": 1,
  "page_size": 50
}
```

### 10.6 前端技术方案

#### 10.6.1 看板组件

```
技术选型:
- 拖拽库: dnd-kit (React DnD 的现代替代，性能更好)
- 虚拟列表: react-window (大数据量看板卡片虚拟渲染)
- 状态管理: Zustand + React Query (乐观更新 + 服务端状态同步)
- 实时通信: 原生 WebSocket + 自动重连

组件层级:
  <KanbanBoard>
    ├── <KanbanColumn status="todo">
    │   ├── <TaskCard task={task1} />
    │   ├── <TaskCard task={task2} />
    │   └── <AddTaskButton />
    ├── <KanbanColumn status="in_progress">
    │   ├── <TaskCard task={task3}>
    │   │   └── <AgentProgressBar progress={63} />
    │   └── <TaskCard task={task4} />
    ├── <KanbanColumn status="done">
    │   └── <TaskCard task={task5} />
    └── <KanbanColumn status="archived">
        └── <TaskCard task={task6} />

  <TaskDetailPanel>
    ├── <TaskHeader />
    ├── <TaskDescription />
    ├── <TaskMetadata />
    ├── <TaskExecution />
    ├── <TaskComments />
    └── <TaskActivity />
```

#### 10.6.2 Agent 进度条组件

```typescript
// AgentProgressBar.tsx 核心逻辑

interface AgentProgress {
  taskId: string;
  progress: number;         // 0-100
  executionPhase: string;
  currentStep?: {
    index: number;
    total: number;
    title: string;
  };
}

// WebSocket 实时订阅
function useAgentProgress(taskId: string): AgentProgress {
  const [progress, setProgress] = useState<AgentProgress>({
    taskId,
    progress: 0,
    executionPhase: 'assigned'
  });

  useEffect(() => {
    const ws = getWebSocket();
    const handler = (event: TaskProgressEvent) => {
      if (event.task_id === taskId) {
        setProgress({
          taskId,
          progress: event.payload.progress,
          executionPhase: event.payload.execution_phase,
          currentStep: event.payload.current_step,
        });
      }
    };
    ws.on('task_progress', handler);
    return () => ws.off('task_progress', handler);
  }, [taskId]);

  return progress;
}
```

### 10.7 缓存策略

```
Redis 缓存层:

1. 看板数据缓存 (快速加载):
   Key: kanban:{workspace_id}:{project_id}:{status}
   Value: 排序后的 task 列表 (JSON)
   TTL: 5 分钟
   失效: task 创建/更新/删除时主动失效

2. Agent 进度缓存 (高频更新):
   Key: task_progress:{task_id}
   Value: { progress, execution_phase, current_step, updated_at }
   TTL: 10 分钟（Agent 长时间无更新则过期）
   更新频率: Agent 每次上报即更新（不走 DB）

3. 执行日志缓冲 (批量写入优化):
   Key: task_logs_buffer:{task_id}:{execution_id}
   Value: List of log entries
   策略: 先写 Redis List，定时(每 5 秒)批量刷入 PostgreSQL

4. 筛选结果缓存:
   Key: task_filter:{workspace_id}:{filter_hash}
   Value: 任务 ID 列表
   TTL: 30 秒
```

---

## 11. Zylos 可复用组件

### 11.1 可复用组件分析

经过对 Zylos 现有架构的深度分析，以下组件可以直接复用或作为 CODE-YI 任务模块的设计参考：

#### 11.1.1 C5 Scheduler — 任务调度器

**组件概要：** C5 是 Zylos 的任务调度器，支持一次性、cron、interval 任务，具备完整的任务生命周期管理。

**可复用的核心能力：**

| 能力 | C5 实现 | CODE-YI 任务模块中的应用 |
|------|---------|--------------------------|
| 任务生命周期 | add/update/done/pause/resume/remove | Agent 任务执行的生命周期管理（assigned→executing→completed） |
| 状态机 | pending→running→done/failed | 任务状态机参考，扩展为更细粒度的执行阶段 |
| Cron 调度 | 标准 cron 表达式 | 自动化规则中的定时触发（"每周一自动创建Sprint任务"） |
| 空闲检测 | 检查 runtime 是否存活后再分发 | Agent 可用性检测——只有在线的 Agent 才接收任务分配 |
| 优先级队列 | 任务优先级排序 | 任务优先级调度——P0 任务优先分配给 Agent |

**直接可复用：**
- 任务状态机设计模式（状态转换规则 + 持久化）
- Cron 表达式解析和调度逻辑（用于自动化规则的定时触发）
- 优先级队列的实现方式

#### 11.1.2 C4 通信桥 — 消息路由

**组件概要：** C4 是 Zylos 的中央消息网关，管理多渠道消息路由。

**可复用的核心能力：**

| 能力 | C4 实现 | CODE-YI 任务模块中的应用 |
|------|---------|--------------------------|
| 统一消息格式 | 所有渠道消息标准化 | Agent 进度上报的统一协议格式 |
| 优先级队列 | SQLite 队列 + 优先级调度 | Git 同步队列的优先级处理（PR merged 事件优先于 label 变更） |
| Checkpoint 机制 | 会话断点恢复 | Agent 执行的断点续跑（Agent 重启后从上次进度继续） |
| 健康状态检测 | agent-status.json + fail-open | Agent 健康检测——离线 Agent 不分配新任务 |

**可复用的设计模式：**
- 消息队列的优先级调度逻辑
- Checkpoint/断点恢复机制（用于 Agent 执行中断后的恢复）
- 健康检查的 fail-open 语义（Agent 健康未知时仍允许分配，避免假死锁）

#### 11.1.3 HXA-Connect — WebSocket 通信

**组件概要：** HXA-Connect 是 Zylos 的 WebSocket 实时通信系统。

**可复用的核心能力：**

| 能力 | HXA-Connect 实现 | CODE-YI 任务模块中的应用 |
|------|-------------------|--------------------------|
| WebSocket 连接管理 | 连接建立、心跳、重连 | Agent ↔ 任务系统的 WebSocket 通道 |
| 实时消息推送 | 双工通信 | 看板实时更新（多用户同时操作看板） |
| Access Control | DM/Thread 级别的访问控制 | 任务级别的访问控制（谁能看/编辑哪些任务） |

**直接可复用的代码/设计：**
- WebSocket 连接管理和自动重连逻辑
- 心跳检测机制（用于 Agent 存活检测）
- 消息的 JSON 序列化/反序列化协议

#### 11.1.4 Activity Monitor — 服务监控

**组件概要：** Zylos 的 PM2 服务监控组件，检测服务存活状态并自动重启。

**可复用的核心能力：**

| 能力 | Activity Monitor 实现 | CODE-YI 任务模块中的应用 |
|------|----------------------|--------------------------|
| 存活检测 | 定时心跳 + 超时判定 | Agent 存活检测——Agent 超时未心跳则标记为离线 |
| 自动恢复 | 服务异常时自动重启 | Agent 任务执行超时时的自动重试 |
| 状态报告 | 健康检查报告 | Agent 执行状态面板的数据来源 |

### 11.2 可复用组件映射

```
Zylos 现有组件                    CODE-YI 任务模块目标组件
─────────────────────────    →    ─────────────────────────
C5 Scheduler                 →    Agent Task Dispatcher
  - 任务状态机              →      - 执行生命周期管理
  - Cron 调度               →      - 自动化规则定时触发
  - 优先级队列              →      - 任务优先级分配

C4 通信桥                    →    Task Event Bus
  - 优先级队列              →      - Git Sync Queue
  - Checkpoint              →      - Agent 执行断点
  - 健康检测                →      - Agent 可用性检测

HXA-Connect                  →    Real-time Task Channel
  - WebSocket 管理           →      - 看板实时推送
  - 双工通信                →      - Agent 进度通道
  - Access Control          →      - 任务访问控制

Activity Monitor             →    Agent Health Monitor
  - 心跳检测                →      - Agent 存活检测
  - 自动恢复                →      - 执行超时自动重试
```

### 11.3 复用建议

1. **第一阶段（MVP）**：参考 C5 Scheduler 的状态机设计实现 Agent 执行生命周期，参考 HXA-Connect 的 WebSocket 管理实现看板实时推送
2. **第二阶段**：基于 C4 的 Checkpoint 机制实现 Agent 执行断点续跑，基于 C5 的 Cron 引擎实现自动化规则定时触发
3. **第三阶段**：结合 Activity Monitor 的健康检测模式，构建 Agent 全局监控面板

---

## 12. 测试用例

### 12.1 看板操作测试

| 编号 | 测试场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|----------|----------|----------|----------|
| TC-KB-01 | 看板加载 | 项目有 50 张卡片 | 进入看板页面 | 四列看板渲染完成，P99 < 500ms |
| TC-KB-02 | 拖拽状态变更 | 任务在"待办"列 | 拖拽到"进行中"列 | 卡片即时移动，status 更新为 in_progress |
| TC-KB-03 | 拖拽排序 | 列内有 3 张卡片 | 拖拽卡片 A 到卡片 B 和 C 之间 | A 的 sort_order 更新为 B 和 C 之间的值 |
| TC-KB-04 | 并发拖拽 | 两个用户同时操作 | User A 和 B 同时拖拽不同卡片 | 两个操作均成功，看板状态一致 |
| TC-KB-05 | 并发冲突 | 两个用户同时操作 | User A 和 B 同时拖拽同一卡片 | 后到的操作覆盖先到的，被覆盖方收到冲突提示 |
| TC-KB-06 | 大数据量 | 项目有 200 张卡片 | 滚动看板 | 虚拟列表渲染，无卡顿（FPS > 30） |
| TC-KB-07 | 项目过滤 | 多个项目有任务 | 选择特定项目过滤 | 只显示该项目的任务卡片 |
| TC-KB-08 | 实时同步 | 两个用户同时查看看板 | User A 创建新任务 | User B 的看板 < 1s 内出现新卡片 |

### 12.2 任务 CRUD 测试

| 编号 | 测试场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|----------|----------|----------|----------|
| TC-TASK-01 | 快速创建 | 在看板页面 | 点击"+"，输入标题，回车 | 任务创建成功，卡片出现在对应列 |
| TC-TASK-02 | 完整创建 | 在看板页面 | 填写所有字段并提交 | 任务包含标题/描述/标签/优先级/指派人/截止日期 |
| TC-TASK-03 | 编辑任务 | 已有任务 | 修改标题和优先级 | 字段更新成功，活动日志记录变更 |
| TC-TASK-04 | 删除任务 | 已有任务 | 删除任务 | 任务软删除，从看板消失 |
| TC-TASK-05 | 归档任务 | 任务状态为"已完成" | 归档任务 | 任务移到归档列 |
| TC-TASK-06 | Markdown 描述 | 创建任务 | 输入含代码块/表格/链接的 Markdown | 渲染正确 |
| TC-TASK-07 | 标签管理 | 创建任务 | 添加多个标签 | 标签颜色编码显示正确 |
| TC-TASK-08 | 优先级显示 | 创建 P0-P4 各一个任务 | 查看卡片 | 优先级颜色正确（P0红/P1橙/P2黄/P3蓝/P4灰） |

### 12.3 Agent 执行测试

| 编号 | 测试场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|----------|----------|----------|----------|
| TC-AGENT-01 | 指派给在线 Agent | Agent 在线 | 设置 assignee 为 Agent | 3s 内 status→in_progress, execution_phase→assigned |
| TC-AGENT-02 | 指派给离线 Agent | Agent 离线 | 设置 assignee 为 Agent | 显示错误"Agent 不可用"，建议替代方案 |
| TC-AGENT-03 | 进度实时更新 | Agent 正在执行 | Agent 上报 progress=50 | 前端进度条 < 500ms 内更新到 50% |
| TC-AGENT-04 | 执行日志流 | Agent 正在执行 | Agent 上报日志 | 任务详情的执行面板实时显示日志 |
| TC-AGENT-05 | 执行成功 | Agent 正在执行 | Agent 报告完成 | execution_phase→completed, 自动生成结果报告 |
| TC-AGENT-06 | 执行失败 | Agent 正在执行 | Agent 报告失败 | execution_phase→failed, 显示错误原因 |
| TC-AGENT-07 | 手动取消 | Agent 正在执行 | 用户点击"取消执行" | 2s 内执行停止，execution_phase→cancelled |
| TC-AGENT-08 | 执行超时 | 超时设置 5min | Agent 执行超过 5 分钟 | 自动取消，尝试重试 |
| TC-AGENT-09 | 自动重试 | 执行失败，retries < max | Agent 报告可重试的错误 | 30s 后自动重试，创建新 execution_id |
| TC-AGENT-10 | 执行阻塞 | Agent 需要人工输入 | Agent 报告 blocked | execution_phase→blocked, 通知相关人员 |
| TC-AGENT-11 | 结果报告 | Agent 执行完成 | 查看任务评论区 | 结构化报告包含摘要/产出物/耗时/Token消耗 |
| TC-AGENT-12 | 断线重连 | Agent 网络中断 | Agent 重新连接 | 自动恢复执行状态，补齐缺失日志 |

### 12.4 筛选视图测试

| 编号 | 测试场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|----------|----------|----------|----------|
| TC-FILTER-01 | 我负责的 | 用户有 5 个任务 | 点击"我负责的"筛选 | 只显示当前用户作为 assignee 的任务 |
| TC-FILTER-02 | Agent 执行中 | 3 个 Agent 任务在执行 | 点击"Agent 执行中"筛选 | 只显示 assignee_type=agent 且 status=in_progress |
| TC-FILTER-03 | 高优先级 | 有 P0-P4 各种任务 | 点击"高优先级"筛选 | 只显示 P0 和 P1 任务 |
| TC-FILTER-04 | 组合筛选 | 各种任务 | 选择"前端"标签 + P0 优先级 | 只显示同时满足两个条件的任务 |
| TC-FILTER-05 | 项目过滤 | 多个项目有任务 | 选择特定项目 | 只显示该项目的任务 |
| TC-FILTER-06 | 保存视图 | 设置了筛选条件 | 保存为"我的前端任务" | 视图保存成功，下次可直接加载 |

### 12.5 Git 同步测试

| 编号 | 测试场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|----------|----------|----------|----------|
| TC-GIT-01 | Task → Issue 创建 | Git 仓库已关联 | 创建 Task | GitHub Issue 自动创建，URL 回填到 Task |
| TC-GIT-02 | Task 标题修改同步 | Task 已同步 Issue | 修改 Task 标题 | Git Issue 标题同步更新 |
| TC-GIT-03 | Task 关闭同步 | Task 已同步 Issue | 关闭 Task | Git Issue 自动关闭 |
| TC-GIT-04 | Issue 修改反向同步 | Task 已同步 Issue | 在 GitHub 修改 Issue 标题 | Task 标题自动更新（Webhook 到达后） |
| TC-GIT-05 | Issue 关闭反向同步 | Task 已同步 Issue | 在 GitHub 关闭 Issue | Task 状态变为 done |
| TC-GIT-06 | PR merged 自动完成 | auto_close_on_merge=true | PR merged | 关联 Task 自动变为 done |
| TC-GIT-07 | 冲突处理 | 双方同时修改 | CODE-YI 和 GitHub 几乎同时修改标题 | Last-Write-Wins + 冲突记录在活动日志 |
| TC-GIT-08 | 防循环 | 正常同步中 | Task→Issue 同步触发 Webhook 回来 | 不再触发 Issue→Task 同步（跳过循环） |
| TC-GIT-09 | Webhook 签名验证 | 无效签名的 Webhook | 发送伪造 Webhook | 返回 401，不处理 |
| TC-GIT-10 | 多仓库同步 | 项目关联 2 个仓库 | 创建 Task 同步到两个仓库 | 两个 Git Issue 分别创建 |

### 12.6 评论测试

| 编号 | 测试场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|----------|----------|----------|----------|
| TC-CMT-01 | 人类发表评论 | 任务详情页 | 输入 Markdown 评论并提交 | 评论出现在时间线，Markdown 正确渲染 |
| TC-CMT-02 | Agent 自动评论 | Agent 正在执行 | Agent 报告进度 | 执行进度评论自动出现 |
| TC-CMT-03 | Agent 结果报告 | Agent 执行完成 | Agent 报告完成 | 结构化报告评论自动出现 |
| TC-CMT-04 | @mention | 评论中 @人 | 输入 @username | 被 mention 的人收到通知 |
| TC-CMT-05 | 评论排序 | 多条评论 | 查看评论区 | 按时间正序排列 |

### 12.7 性能测试

| 编号 | 测试场景 | 指标 | 目标值 |
|------|----------|------|--------|
| TC-PERF-01 | 看板加载（100 卡片） | P99 延迟 | < 500ms |
| TC-PERF-02 | 看板加载（500 卡片） | P99 延迟 | < 1.5s（虚拟列表） |
| TC-PERF-03 | 拖拽操作 | 感知延迟 | < 100ms |
| TC-PERF-04 | 任务创建 | API 响应时间 | < 200ms |
| TC-PERF-05 | Agent 进度更新 | 端到端延迟 | < 500ms |
| TC-PERF-06 | Git 同步延迟 | Webhook 到 Task 更新 | < 5s |
| TC-PERF-07 | 筛选查询 | 响应时间（1 万任务） | < 300ms |
| TC-PERF-08 | WebSocket 并发连接 | 连接数 | > 5,000 |
| TC-PERF-09 | Agent 并发执行 | 同时执行的 Agent 任务 | > 20 |
| TC-PERF-10 | 执行日志写入 | 吞吐量 | > 1,000 条/秒 |

---

## 13. 成功指标

### 13.1 产品指标

| 指标 | 定义 | MVP 目标 (3 个月) | 成熟期目标 (12 个月) |
|------|------|-------------------|---------------------|
| **任务创建量** | 日均创建任务数 | 30 | 500 |
| **Agent 任务占比** | Agent 执行的任务 / 总任务 | > 20% | > 50% |
| **Agent 执行成功率** | Agent 任务成功完成 / Agent 任务总数 | > 70% | > 90% |
| **Agent 执行平均耗时** | 从指派到完成的平均时间 | - | < 15 min |
| **人工修改率** | Agent 完成后需人工修改的比例 | < 50% | < 20% |
| **看板 DAU** | 每日访问看板的用户数 | 20 | 500 |
| **Git 同步任务占比** | 同步到 Git 的任务 / 总任务 | > 30% | > 60% |
| **拖拽操作频次** | 每日拖拽操作次数 | 50 | 2,000 |

### 13.2 技术指标

| 指标 | 目标 |
|------|------|
| 看板加载 P99 | < 500ms (100 卡片) |
| 拖拽感知延迟 | < 100ms |
| Agent 进度推送延迟 | < 500ms |
| Git 同步延迟 | < 5s (Webhook 到 Task 更新) |
| API 可用性 | > 99.9% |
| 数据一致性 | Git ↔ Task 同步一致率 > 99.5% |
| WebSocket 连接稳定性 | > 99% (自动重连成功率) |
| 执行日志无丢失率 | > 99.99% |

### 13.3 用户体验指标

| 指标 | 目标 |
|------|------|
| 用户满意度 (NPS) | > 40 |
| Agent 任务结果评分 | > 4.0 / 5.0（用户评分） |
| 首次创建 Agent 任务到看到结果 | < 10 分钟 |
| 看板操作流畅度评分 | > 4.5 / 5.0 |
| "我能清楚知道 Agent 在做什么"（调研） | > 80% 正面反馈 |

---

## 14. 风险与缓解

### 14.1 技术风险

| 风险 | 影响 | 概率 | 缓解措施 |
|------|------|------|----------|
| **Agent 执行不可控** | Agent 长时间无进度、卡死 | 高 | 1. 强制超时（默认 30 分钟）2. 心跳检测（Agent 每 30 秒心跳，60 秒无心跳视为死亡）3. 自动重试（最多 2 次）4. 人工接管按钮 |
| **Git 同步循环** | Task 和 Issue 互相触发更新导致无限循环 | 中 | 1. sync_source 标记（同步触发的变更不回写）2. 内容 hash 比对（相同内容跳过）3. 60 秒防抖窗口 |
| **看板性能退化** | 大量卡片导致渲染卡顿 | 中 | 1. 虚拟列表渲染（只渲染可视区域）2. 乐观更新减少网络等待 3. 看板数据分页加载 |
| **WebSocket 连接风暴** | 大量用户同时操作看板 | 中 | 1. 连接池管理 2. 事件合并（批量推送）3. 降级到 HTTP Polling |
| **Agent 进度上报丢失** | 网络不稳定导致进度丢失 | 低 | 1. Agent 侧本地缓冲 2. 重连后自动补报 3. 进度快照定期同步 |
| **排序精度耗尽** | 频繁拖拽导致 float 精度不足 | 低 | 1. 检测精度阈值 2. 自动 rebalance（后台重新分配整数序列）|
| **Git API 限流** | GitHub/GitLab API Rate Limit | 中 | 1. 同步队列限速 2. 批量操作合并 3. 缓存 Git 数据减少查询 4. 使用 GraphQL 减少请求数 |

### 14.2 产品风险

| 风险 | 影响 | 概率 | 缓解措施 |
|------|------|------|----------|
| **Agent 执行质量不稳定** | 用户失去对 Agent 的信任 | 高 | 1. 结果报告透明化（用户看到 Agent 做了什么）2. 简单任务先行（从低风险任务开始）3. 人工验收环节 4. Agent 成功率监控告警 |
| **用户不习惯指派给 Agent** | Agent 任务占比低 | 高 | 1. 引导流程（"试试让 Agent 帮你做这个"）2. 推荐适合 Agent 的任务 3. 成功案例展示 |
| **看板 UI 不如 Linear** | 用户体验短板 | 中 | 1. 以 Linear 为 UI 标杆 2. 聚焦差异化功能（Agent 透明化）而非基础看板体验 3. 持续迭代 |
| **Git 同步与团队现有工作流冲突** | 任务状态混乱 | 中 | 1. 同步配置灵活可调 2. 支持单向同步模式 3. 冲突解决透明可见 |

### 14.3 安全风险

| 风险 | 影响 | 概率 | 缓解措施 |
|------|------|------|----------|
| **Agent 越权操作** | Agent 执行了不该执行的操作 | 中 | 1. Agent 权限沙箱 2. 敏感操作需人工确认 3. 操作审计日志 |
| **Git Token 泄露** | 仓库被恶意访问 | 低 | 1. Token 加密存储（AES-256-GCM）2. Token scope 最小化 3. Token 定期轮转提醒 |
| **Webhook 伪造** | 虚假 Git 事件导致任务状态错误 | 低 | 1. HMAC-SHA256 签名验证 2. 源 IP 白名单（可选）3. 事件去重 |
| **任务数据泄露** | 跨项目/跨 Workspace 数据泄露 | 低 | 1. 查询层 workspace_id 强制过滤 2. API 鉴权 3. 行级安全策略（RLS）|

---

## 15. 排期建议

### 15.1 阶段划分

```
Phase 1: MVP 看板 + Agent 执行           5 周（1 前端 + 1 后端）
├── Sprint 1: 基础看板                    2 周
│   ├── 后端: 任务 CRUD API, 数据模型, WebSocket 基础
│   ├── 前端: Kanban 看板 UI, 拖拽排序, 任务卡片
│   ├── 后端: 筛选查询 API（预设筛选 + 项目过滤）
│   └── 前端: 筛选栏 UI, 任务详情侧栏
│
├── Sprint 2: Agent 执行 + 评论            2 周
│   ├── 后端: Agent 执行生命周期引擎, WebSocket 进度通道
│   ├── 后端: Agent SDK API（任务接收/进度上报/结果报告）
│   ├── 前端: Agent 进度条, 执行状态徽章
│   ├── 前端: 任务评论区（人类+Agent 混合时间线）
│   └── 后端: 评论 CRUD API, Agent 自动评论
│
└── Sprint 3: 联调 + 打磨                 1 周
    ├── 前后端联调
    ├── Agent SDK 联调测试
    ├── 看板性能优化（虚拟列表、乐观更新）
    └── Bug 修复 + UI 打磨

Phase 2: Git 同步 + 增强功能              4 周
├── Sprint 4: GitHub/GitLab 同步           2 周
│   ├── 后端: OAuth 授权流, Git Sync Engine
│   ├── 后端: Outbound 同步（Task → Issue）
│   ├── 后端: Inbound Webhook 处理（Issue → Task, PR → Task）
│   ├── 后端: 冲突检测 + 防循环
│   └── 前端: Git 关联配置 UI, 同步状态指示器
│
├── Sprint 5: 增强功能                    2 周
│   ├── 后端: Agent 执行日志持久化 + 分页查询
│   ├── 前端: 执行日志面板 UI
│   ├── 后端: 任务搜索（全文搜索）
│   ├── 前端: Cmd+K 搜索集成
│   └── 前端: 自定义视图保存/加载

Phase 3: 自动化 + 统计                   3 周
├── Sprint 6: 自动化规则引擎              2 周
│   ├── 后端: 规则引擎（触发条件评估 + 动作执行）
│   ├── 后端: 内置规则模板
│   ├── 前端: 规则配置 UI
│   └── 前端: 规则执行日志
│
└── Sprint 7: 统计 + 打磨                1 周
    ├── 前端: Agent 任务统计仪表板
    ├── 前端: 对话-任务联动（从对话创建任务）
    └── 全面测试 + Bug 修复
```

### 15.2 里程碑

| 里程碑 | 时间 | 交付物 | 关键能力 |
|--------|------|--------|----------|
| **M1: 看板 MVP** | Week 2 | 基础看板可用 | 四列 Kanban、拖拽排序、任务 CRUD、筛选 |
| **M2: Agent 执行** | Week 4 | Agent 任务可用 | Agent 指派、实时进度、执行日志、结果报告 |
| **M3: MVP Launch** | Week 5 | MVP 发布 | 完整 P0 功能、联调完成、性能达标 |
| **M4: Git 同步** | Week 7 | Git 集成可用 | GitHub/GitLab 双向同步、PR 关联 |
| **M5: 增强发布** | Week 9 | P1 功能发布 | 搜索、执行日志面板、自定义视图 |
| **M6: 自动化** | Week 12 | 自动化发布 | 规则引擎、统计仪表板、对话联动 |

### 15.3 团队配置

| 角色 | 人数 | 职责 |
|------|------|------|
| 后端工程师 | 1 | 任务 API、Agent 执行引擎、Git 同步、自动化规则 |
| 前端工程师 | 1 | Kanban UI、拖拽交互、Agent 进度渲染、Git 配置界面 |
| **总计** | **2** | 5 周 MVP + 7 周增强 |

**注：** P0 范围（5 周）由 1 前端 + 1 后端完成。P1/P2 可根据团队容量安排。Agent SDK 开发由 Agent 模块（Module 5）负责，任务模块只定义接口协议。

### 15.4 依赖关系

| 依赖项 | 来源 | 影响 | 缓解 |
|--------|------|------|------|
| 用户系统 (users 表) | Module 4 Teams | 指派人数据 | MVP 阶段硬编码测试用户 |
| Agent 系统 (agents 表) | Module 5 Agent | Agent 注册/执行 | MVP 阶段用 Mock Agent |
| 对话系统 (对话联动) | Module 1 Chat | 从对话创建任务 | P2 功能，不阻塞 MVP |
| 项目系统 (projects 表) | Module 3 Projects | 项目归属 | MVP 阶段创建基础 projects 表 |
| Workspace 系统 | 平台基础设施 | 多租户隔离 | 共用基础 workspaces 表 |

---

## 附录 A：设计稿参考

**Screen 2 设计稿要素还原：**
- 12 个任务的 Kanban 看板
- 标签类型：设计、前端、Agent、DevOps、文档、测试
- 指派人头像显示
- 优先级标识 P1-P4
- 截止日期
- 进度百分比
- "Agent 执行中"筛选标签

## 附录 B：术语表

| 术语 | 定义 |
|------|------|
| Kanban | 看板，一种可视化的任务管理方法，任务在列之间流转 |
| Polymorphic Assignee | 多态指派，同一个指派人字段可以指向人类或 Agent |
| Execution Phase | 执行阶段，Agent 执行任务时的细粒度状态 |
| Progress Stream | 进度流，Agent 通过 WebSocket 实时上报的进度数据 |
| Bidirectional Sync | 双向同步，Task ↔ Git Issue 的双向数据同步 |
| Optimistic Update | 乐观更新，前端先更新 UI 再等待服务端确认，提升感知性能 |
| Sort Order | 排序权重，float 类型，支持无限次插入排序 |
| Sync Engine | 同步引擎，管理 CODE-YI 与 Git 仓库之间的数据同步 |
| Execution Report | 执行报告，Agent 完成任务后自动生成的结构化结果文档 |
| Automation Rule | 自动化规则，基于触发条件自动执行动作的配置 |
| Last-Write-Wins | 最后写入胜出，冲突解决策略，保留最后修改方的值 |
| Virtual List | 虚拟列表，只渲染可视区域的列表项，提升大数据量性能 |
| Agent SDK | Agent 开发工具包，Agent 用于与任务系统交互的 API 和协议 |

## 附录 C：与 Module 1 Chat 的交互接口

任务模块与对话模块的跨模块交互点：

| 交互场景 | 触发方 | 接口 |
|----------|--------|------|
| 从对话创建任务 | Chat → Tasks | `POST /api/v1/tasks` with `source_message_id` |
| Agent 任务进度通知到对话 | Tasks → Chat | `POST /api/v1/messages` with `content_type='task_update'` |
| 任务完成通知到对话 | Tasks → Chat | `POST /api/v1/messages` with `content_type='task_completed'` |
| @Agent 创建并执行任务 | Chat → Tasks | 对话中的 @Agent 触发 → 自动创建 Task → 自动指派 Agent |
| 任务评论同步到对话线程 | Tasks → Chat | 可选配置：任务评论镜像到关联的对话线程 |
