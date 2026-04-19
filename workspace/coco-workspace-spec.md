# COCO Workspace 产品规格说明书

> 基于设计稿 v0.1（10 screens） · 2026-04-19 · 全新开发，非现有 Dashboard 扩展

| 核心模块 | MVP 到内测 | 最小团队 | 代码库 |
|:---:|:---:|:---:|:---:|
| **9** | **~24 周** | **6-7 人** | **全新** |

---

## 目录

1. [产品定位与核心模型](#一产品定位与核心模型)
2. [信息架构（9 模块总览）](#二信息架构)
3. [模块详细 Spec](#三模块详细-spec)
4. [数据模型](#四数据模型)
5. [技术选型建议](#五技术选型建议)
6. [P0 / P1 / P2 拆分](#六p0--p1--p2-拆分)
7. [团队配置与排期](#七团队配置与排期)
8. [风险与待决策项](#八风险与待决策项)

---

## 一、产品定位与核心模型

> **一句话定位：** AI-Native 团队协作平台 — 人类和 AI Agent 作为平级团队成员，共同完成项目开发。

### 核心概念模型：HxA（Human × Agent）

传统协作工具里，AI 是"工具"——人调用它，用完丢掉。COCO Workspace 的核心突破是：**Agent 是团队成员**，有角色、有任务、有绩效、有权限。

```
Workspace（工作空间）
├── Team（团队）
│   ├── 人类成员 ─── 角色（管理员/成员/审核者）
│   └── Agent 成员 ─── 角色（执行者/审核者/协调者/观察者）
├── Projects（项目）
│   ├── Sprint / Phase 周期
│   └── Tasks（任务） ─── 分配给 人类 或 Agent
├── Conversations（对话）
│   ├── 频道对话（团队可见）
│   └── 私人对话（1:1）
├── Toolbox（工具箱）
│   ├── MCP 集成（GitHub/Lark/Jira/...）
│   ├── 内置技能（数据库查询/安全扫描/...）
│   └── 社区技能
└── Admin（管理）
    ├── 席位管理（人 + Agent 统一视图）
    ├── 权限控制（Agent 执行权限 + 审批策略）
    └── 用量分析（API 调用/Credits 消耗）
```

### 与现有产品的关系

| 维度 | 现有 Dashboard | 新 Workspace |
|------|---------------|-------------|
| 定位 | 个人 AI 员工管理面板 | 团队 AI-Native 协作平台 |
| Agent 模型 | 1 用户 : 1 Agent (独立 VM) | 1 团队 : N Agent（多专业角色） |
| 交互 | 通过外部 IM（Lark/TG） | 内置对话界面 + 外部 IM 可选 |
| 任务 | 无 | 原生 Kanban + Git 集成 |
| 代码库 | coco-dashboard (Next.js + Fastify) | 全新代码库 |
| 用户群 | 现有 300+ 个人用户 | 新产品线，面向开发团队 |

> **关键决策：** 这是一个全新产品线，不是在现有 dashboard 上改。现有 dashboard 继续服务个人用户，Workspace 作为独立产品面向团队客户。两个产品可以共享用户账户体系（Logto），但代码库、部署、计费完全独立。

---

## 二、信息架构

基于设计稿左侧导航栏，Workspace 有 9 个一级模块：

```
左侧导航
═══════════════════════
工作区
  ● 对话        ③     ← 实时聊天，人机协作沟通
  ■ 任务        ⑫     ← Kanban 看板，连接 Git
  ◆ 项目              ← Sprint/Phase 管理
  👥 团队              ← 人 + Agent 成员管理
─────────────────────
平台
  🤖 Agent             ← Agent 管理 + 模板市场
  🧰 工具箱            ← MCP / 技能 市场
─────────────────────
系统
  📊 管理后台          ← 概览 + 席位 + 权限
  ⚙ 设置              ← 个人资料 + OAuth + 通知
─────────────────────
  ⌘ Cmd+K             ← 全局命令面板
```

---

## 三、模块详细 Spec

### 模块 1：对话 (Chat) `P0`

#### 功能描述

类飞书/Slack 的即时通讯界面。用户可以跟 Agent 对话、跟团队成员对话、或在频道中多人+多Agent 协作。

#### 核心功能

| 功能 | 说明 | 优先级 |
|------|------|--------|
| 频道对话 | 团队公开频道，人和 Agent 都能参与。消息实时推送。 | P0 |
| 私人对话 | 1:1 跟 Agent 或跟人。Agent 私聊内容不对其他成员可见。 | P0 |
| 消息归属 | 每条消息标记发送者（人类头像 or Agent 图标+名称） | P0 |
| @提及 | @人 或 @Agent 触发通知/唤醒 | P0 |
| 富文本 + 代码块 | Markdown 渲染、代码高亮、文件附件、图片 | P0 |
| 消息引用/回复 | 引用上下文回复，线程式讨论 | P1 |
| 消息搜索 | 全文搜索历史消息 | P1 |
| 外部 IM 桥接 | 可选连接 Lark/Slack，双向同步消息 | P2 |

#### 技术要点

- 实时通讯：WebSocket（推荐 Socket.IO 或原生 WS + Redis Pub/Sub 扇出）
- 消息存储：PostgreSQL（结构化）+ 全文搜索（pg_trgm 或 Elasticsearch）
- Agent 响应：消息发送后通过内部队列分发到对应 Agent 运行时，Agent 通过 SSE/WS 回传流式响应
- 文件上传：S3/GCS，消息中存引用

#### 设计稿对应

Screen 1 of navigation (对话③)。设计稿中未展示完整对话界面截图，需要补充 UI 设计。

#### 工时估算

**P0 范围：~6 周**（2 前端 + 1 后端）

---

### 模块 2：任务 (Tasks) `P0`

#### 功能描述

Kanban 看板式任务管理，直连 GitHub/GitLab。任务可以分配给人类或 Agent。Agent 执行任务时，进展实时可见。

#### 核心功能

| 功能 | 说明 | 优先级 |
|------|------|--------|
| Kanban 看板 | 四列：待办 → 进行中 → 已完成 → 已归档。拖拽排序。 | P0 |
| 任务卡片 | 标题、描述、标签（设计/前端/Agent/DevOps）、优先级（P0-P4）、指派人、进度条 | P0 |
| 指派给 Agent | 选择 Agent 为执行者 → Agent 自动开始执行 → 状态实时更新 | P0 |
| 筛选视图 | 全部 / 我负责的 / Agent 执行中 / 高优先级。按项目过滤。 | P0 |
| GitHub/GitLab 同步 | Issue ↔ Task 双向同步：在 Workspace 创建 Task 自动建 Issue，Git Issue 变化自动更新 Task | P1 |
| 任务评论 | 人和 Agent 可在任务中留评论，Agent 完成后自动附结果报告 | P1 |
| 自动化规则 | 如「PR merged → 任务自动完成」「Agent 成功率 < 80% → 通知管理员」 | P2 |

#### 设计稿参考

Screen 2：12 个任务的 Kanban。每个任务卡显示：标签（设计/前端/Agent/DevOps/文档/测试）、指派人头像、优先级（P1-P4）、截止日期、进度百分比。支持「Agent 执行中」筛选标签。

#### 数据模型

```sql
tasks {
  id, workspace_id, project_id,
  title, description, status (todo|in_progress|done|archived),
  priority (p0|p1|p2|p3|p4),
  assignee_id,        -- 可以是 user_id 或 agent_id
  assignee_type,      -- 'human' | 'agent'
  labels[],           -- ['设计','前端','Agent']
  progress,           -- 0-100
  due_date,
  git_issue_url,      -- GitHub/GitLab issue link
  sort_order,
  created_by, created_at, updated_at
}

task_comments {
  id, task_id, author_id, author_type, content, created_at
}
```

#### 工时估算

**P0 范围：~5 周**（1 前端 + 1 后端）

---

### 模块 3：项目 (Projects) `P0`

#### 功能描述

项目是任务的容器。每个项目有 Sprint/Phase 周期、进度追踪、团队成员。卡片视图展示整体状况。

#### 核心功能

| 功能 | 说明 | 优先级 |
|------|------|--------|
| 项目卡片视图 | 名称、描述、Sprint/Phase 标签、进度条、团队头像、最近活动时间 | P0 |
| 项目 CRUD | 创建/编辑/归档项目。Tab：全部项目 / 我参与的 / 已归档 | P0 |
| 项目内任务列表 | 进入项目后展示该项目的 Kanban（复用任务模块，filter by project_id） | P0 |
| 列表视图 | 表格形式查看所有项目 | P1 |
| Git repo 绑定 | 一个项目绑定一个或多个 Git repo，Task 自动关联 commit/PR | P1 |
| Sprint 管理 | 时间周期、Sprint 目标、velocity 图表 | P2 |

#### 设计稿参考

Screen 3：4 个项目卡片（CODE-YI主站 Sprint 14 62%、移动端 App Sprint 12 38%、MCP 集成层 Phase 1 25%、Agent 记忆系统 研发中 15%）。+ 新建项目 按钮。

#### 工时估算

**P0 范围：~3 周**（1 前端 + 0.5 后端 — 大量复用任务模块）

---

### 模块 4：团队 (Team) `P0`

#### 功能描述

统一管理人类成员和 Agent 成员。展示 HxA 协作拓扑。

#### 核心功能

| 功能 | 说明 | 优先级 |
|------|------|--------|
| 人类成员管理 | 邀请（邮件/链接）、角色设置（管理员/成员/审核者）、移除 | P0 |
| Agent 成员管理 | 添加 Agent（从市场选或创建）、设置角色（执行者/审核者/协调者/观察者） | P0 |
| 成员卡片展示 | 头像、名称、角色标签、在线/离线状态 | P0 |
| HxA 协作拓扑图 | 可视化展示人与 Agent 之间的协作关系 | P1 |
| 多团队 | 一个 Workspace 可有多个团队（如产品开发团队、运营团队） | P2 |

#### 设计稿参考

Screen 4：「产品开发团队」— 人类成员(4)和Agent成员(4)分区展示。每个 Agent 卡显示底层模型（Claude Sonnet / GPT-4 / Claude Opus / Gemini Pro）和在线状态。下方有 HxA 协作拓扑图。

#### Agent 角色说明

| 角色 | 权限 | 典型场景 |
|------|------|---------|
| 执行者 | 接收任务 → 自主执行 → 提交结果 | 代码助手写代码 |
| 审核者 | Review 其他 Agent/人的产出 → 提出修改建议 | 测试 Agent 做 Code Review |
| 协调者 | 拆解需求 → 分配子任务 → 跟踪进度 | 产品助手做需求分析 |
| 观察者 | 只读监控 → 收集数据 → 生成报告 | 数据分析 Agent |

#### 工时估算

**P0 范围：~3 周**（1 前端 + 1 后端）

---

### 模块 5：Agent 管理 `P0`

#### 功能描述

Agent 的全生命周期管理：创建、配置、监控、销毁。包含 Agent 模板市场。

#### 核心功能

| 功能 | 说明 | 优先级 |
|------|------|--------|
| Agent 仪表板 | 卡片视图：名称、类型图标(AI/QA/PM/数据)、底层模型、技能标签、本周任务数/成功率/平均时长 | P0 |
| 创建 Agent | 选择模板 → 配置模型/技能/权限 → 命名 → 部署 | P0 |
| Agent 配置 | 修改 persona（系统 prompt）、模型选择、技能启用/禁用、权限等级 | P0 |
| Agent 状态监控 | 在线/离线/错误状态、资源使用、最近活动 | P0 |
| Agent 模板市场 | 预设模板：全栈开发者、UI设计师、代码审查员、技术写作者、安全审计员等 | P1 |
| Fork Agent | 从已有 Agent 复制（包含 Memory + 技能配置） | P1 |
| 导入配置 | 从 JSON/YAML 导入 Agent 配置 | P1 |

#### 设计稿参考

Screen 1/5：4 个 Agent 卡片 — 代码助手(Claude 3.5 Sonnet, 23 tasks, 97%, 4.2min), 测试Agent(GPT-4 Turbo, 18 tasks, 94%, 6.8min), 产品助手(Claude Opus, 8 tasks, 100%, 12min), 数据分析Agent(Gemini 1.5 Pro, 12 tasks, 95%, 3.5min)。每个卡显示技能标签（代码生成/重构/Code Review/测试 等）。底部 Agent 模板市场有 5 个模板。

#### Agent 运行时架构

> **关键架构决策：** 每个 Agent 的运行时是什么？
>
> **方案 A：独立 VM（现有模式）** — 每个 Agent = 1 台 GCE VM。隔离性好，但成本高（4 Agent = 4 VM）。
>
> **方案 B：容器化** — 每个 Agent = 1 个 Docker 容器，共享宿主机。成本降 60-70%，隔离性略低但可控。
>
> **方案 C：进程级** — 同一 VM 内多个 Agent 进程（PM2 管理）。成本最低，但隔离性弱。
>
> **建议：** MVP 用方案 B（Docker 容器）。平衡成本和隔离性。每个 Workspace 一台宿主 VM，上面跑 N 个 Agent 容器。

#### 工时估算

**P0 范围：~5 周**（1 后端 + 1 前端。Agent 运行时改造是最重头的。）

---

### 模块 6：工具箱 (Toolbox) `P1`

#### 功能描述

Agent 的技能/工具市场。支持 MCP 协议集成、内置技能、社区技能。一键安装，OAuth 授权。

#### 核心功能

| 功能 | 说明 | 优先级 |
|------|------|--------|
| 技能浏览 | 分类 Tab：全部 / 内置技能 / MCP 集成 / 社区技能 / 我的技能 | P1 |
| 一键安装 | 点击安装 → 自动部署到 Agent 运行时 | P1 |
| OAuth 连接 | GitHub/Lark/Jira/Gmail 等需要授权的集成，一键 OAuth flow | P1 |
| 技能评分/安装数 | 社区评分（★4.5）+ 安装数量（12.3k） | P2 |
| 上传技能 | 用户可上传自定义技能到市场 | P2 |

#### 设计稿参考

Screen 6：8 个工具卡片。GitHub 集成(官方MCP, ★4.5, 12.3k, 已安装)、飞书集成(官方MCP, ★4.8, 8.7k, 已安装)、数据库查询(官方内置, ★4.6, 8.2k)、图像生成(★4.7, 9.1k, 已安装)、网页抓取(★4.3, 3.4k)、邮件管理(MCP, ★4.4, 5.1k)、Jira 集成(★4.2, 4.5k)、安全扫描(内置, 7.8k, 已安装)。

#### MVP 策略

P0 不做市场，而是**预装 3-5 个核心集成**（GitHub、数据库查询、文件操作），作为 Agent 内置能力。P1 再做完整的市场 UI 和安装流程。

#### 工时估算

**P1 范围：~4 周**（1 前端 + 1 后端）

---

### 模块 7：管理后台 (Admin) `P0`

#### 功能描述

Workspace 管理员的控制中心：系统概览、席位管理（人+Agent 统一视图）、权限控制、用量分析。

#### 核心功能

| 功能 | 说明 | 优先级 |
|------|------|--------|
| 系统概览 | 4 个 KPI 卡：Agent 数 / 活跃用户 / API 调用量 / Credits 消耗。7 天趋势图。 | P0 |
| 席位管理 | 统一表格：成员名 / 角色 / 类型(人类/Agent) / 最近活跃 / 本周 API 调用 / 状态(活跃/在线/离线)。支持操作列。 | P0 |
| Agent 执行权限 | 开关式控制：代码执行 ✓/✗、文件写入 ✓/✗、外部 API 调用 ✓/✗、数据库操作 ✓/✗ | P0 |
| 审批策略 | 高风险操作需人工审批、费用超限告警、自动回滚、操作日志审计 | P1 |
| 导出报告 | 一键导出系统使用报告 | P1 |

#### 设计稿参考

Screen 7-9：KPI 卡（4 Agents +1本月 / 28 活跃用户 +12% / 14.2k API +23% / $842 Credits +5%）。席位管理表含人类和 Agent 混合行。权限控制面板有 4 个执行权限开关 + 4 个审批策略选项。

#### 工时估算

**P0 范围：~3 周**（1 前端 + 0.5 后端）

---

### 模块 8：设置 (Settings) `P1`

#### 功能描述

个人资料、OAuth 集成管理、通知偏好。

#### 核心功能

| 功能 | 说明 | 优先级 |
|------|------|--------|
| 个人资料 | 头像、名称、邮箱、角色标签 | P0 |
| OAuth 集成面板 | 20+ 平台 OAuth 连接：GitHub/飞书/Slack/Jira/Notion/Gmail/AWS/Docker/GitLab/Confluence/Vercel/Linear/Figma/npm/Okta/Datadog/Zoom/Discord/微信/Twitter | P1 |
| 通知偏好 | 开关：Agent 任务完成通知 / 任务分配通知 / @提及通知 | P1 |

#### 设计稿参考

Screen 10：个人资料卡 + 20 个 OAuth 服务图标（部分高亮为已连接）+ 3 个通知开关。

#### MVP 策略

P0 只做个人资料。OAuth 集成在 P1 按需开通（先做 GitHub，其余按客户需求优先级排序）。

#### 工时估算

**P0: ~1 周**（基础设置页）**| P1: ~4 周**（OAuth 集成框架 + 前 3-5 个平台）

---

### 模块 9：全局命令面板 (Cmd+K) `P2`

全局快捷键唤出命令面板，类 Linear/Raycast。快速搜索任务、跳转页面、执行操作。

**P2，MVP 不做。** 工时 ~2 周。

---

## 四、数据模型

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│ workspaces  │────<│ workspace_   │>────│    users     │
│             │     │ members      │     │              │
│ id          │     │ workspace_id │     │ id           │
│ name        │     │ user_id      │     │ name         │
│ slug        │     │ role         │     │ email        │
│ owner_id    │     │ joined_at    │     │ avatar_url   │
│ plan        │     └──────────────┘     │ logto_id     │
└──────┬──────┘                          └──────────────┘
       │
       │ 1:N
       ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   agents     │────<│  agent_      │>────│   skills     │
│              │     │  skills      │     │              │
│ id           │     └──────────────┘     │ id           │
│ workspace_id │                          │ name         │
│ name         │     ┌──────────────┐     │ type (mcp/   │
│ type (code/  │     │  agent_      │     │  builtin/    │
│  test/pm/    │     │  configs     │     │  community)  │
│  data/custom)│     │              │     │ install_count│
│ model        │     │ agent_id     │     └──────────────┘
│ persona      │     │ key          │
│ status       │     │ value        │
│ role         │     └──────────────┘
│ stats_json   │
└──────┬──────┘
       │
       │
┌──────▼──────┐     ┌──────────────┐
│  projects   │────<│    tasks     │
│             │     │              │
│ id          │     │ id           │
│ workspace_id│     │ project_id   │
│ name        │     │ workspace_id │
│ description │     │ title        │
│ sprint_label│     │ status       │
│ progress    │     │ priority     │
│ repo_url    │     │ assignee_id  │
└─────────────┘     │ assignee_type│   ┌──────────────┐
                    │ labels[]     │   │  messages    │
                    │ progress     │   │              │
                    │ git_issue_url│   │ id           │
                    └──────────────┘   │ channel_id   │
                                       │ sender_id    │
┌──────────────┐                       │ sender_type  │
│  channels    │──────────────────────>│ content      │
│              │                       │ attachments  │
│ id           │                       │ created_at   │
│ workspace_id │                       └──────────────┘
│ name         │
│ type (public/│     ┌──────────────┐
│  private/dm) │     │ oauth_       │
│ members[]    │     │ connections  │
└──────────────┘     │              │
                     │ user_id      │
┌──────────────┐     │ provider     │
│ subscriptions│     │ access_token │
│              │     │ refresh_token│
│ workspace_id │     │ scopes       │
│ plan         │     │ expires_at   │
│ seats        │     └──────────────┘
│ stripe_sub_id│
│ period_start │     ┌──────────────┐
│ period_end   │     │ audit_logs   │
└──────────────┘     │              │
                     │ workspace_id │
                     │ actor_id     │
                     │ actor_type   │
                     │ action       │
                     │ target       │
                     │ details_json │
                     │ created_at   │
                     └──────────────┘
```

**核心表：~12 张**（workspaces, workspace_members, users, agents, agent_skills, agent_configs, skills, projects, tasks, channels, messages, subscriptions）+ 辅助表 ~6 张（task_comments, oauth_connections, audit_logs, notifications, invites, usage_metrics）

---

## 五、技术选型建议

| 层 | 推荐 | 理由 |
|---|------|------|
| 前端框架 | Next.js 16 (App Router) | 团队已有经验（现有 dashboard），SSR + RSC 性能好 |
| UI | TailwindCSS v4 + Radix UI + shadcn/ui | 设计稿风格匹配，组件生态成熟 |
| 实时通讯 | Socket.IO + Redis Adapter | 对话模块需要 WebSocket，Socket.IO 处理重连/房间/扇出 |
| 后端 | Fastify (TypeScript) | 团队已有经验，性能优于 Express |
| ORM | Prisma 6 | 团队已有经验，Type-safe |
| 数据库 | PostgreSQL 17 | 现有基础设施，复用 Cloud SQL |
| 缓存/实时 | Redis 7 (Pub/Sub + Cache) | 消息扇出、会话缓存、在线状态 |
| 任务队列 | BullMQ | Agent 任务调度、异步 Job |
| Agent 运行时 | Docker 容器（每 Agent 一个） | 隔离性 + 成本平衡。宿主 VM 上跑 Docker Compose。 |
| 对象存储 | GCS (Google Cloud Storage) | 文件附件、Agent 产出物 |
| 认证 | Logto (共享现有实例) | SSO + 社交登录 + RBAC |
| 支付 | Stripe (Workspace 级别订阅) | per-seat pricing 原生支持 |
| Monorepo | Turborepo + pnpm | 前后端 + shared types 共享 |

> **复用清单（来自现有 coco-dashboard）：**
>
> - ✅ Logto 认证实例
> - ✅ Cloud SQL PostgreSQL（新建数据库，同实例）
> - ✅ Redis Memorystore
> - ✅ Stripe 商户账户
> - ✅ GCE 基础设施 + VM 编排经验
> - ✅ Cloudflare DNS + 代理
> - ❌ 不复用前端代码（全新产品 UI）
> - ❌ 不复用后端路由（API 设计差异太大）
> - ⚠️ 可部分复用 Prisma schema 工具链和 Stripe 集成模式

---

## 六、P0 / P1 / P2 拆分

### P0 — MVP（能对外 demo + 内测的最小产品）

**用户故事：** 一个 5 人开发团队创建 Workspace → 添加 2 个 Agent（代码助手 + 测试）→ 在对话频道中跟 Agent 协作 → 创建项目和任务 → 把任务分配给 Agent → Agent 自动执行 → 在管理后台看用量。

| 模块 | P0 范围 | 工时 |
|------|---------|------|
| M1 对话 | 频道对话 + 私人对话 + @提及 + 富文本 + 流式 Agent 响应 | 6 周 |
| M2 任务 | Kanban 四列 + 任务 CRUD + 分配给人/Agent + 筛选 | 5 周 |
| M3 项目 | 项目卡片 + CRUD + 项目内任务列表 | 3 周 |
| M4 团队 | 人类成员邀请 + Agent 成员添加 + 角色设置 | 3 周 |
| M5 Agent | Agent 仪表板 + 创建(从预设模板) + 配置 + 状态监控 | 5 周 |
| M7 管理后台 | 系统概览 4 KPI + 席位管理 + Agent 执行权限开关 | 3 周 |
| M8 设置 | 个人资料基础页 | 1 周 |
| 基础设施 | 项目脚手架 + Auth + DB + Docker Agent 运行时 + CI/CD | 4 周 |
| **P0 合计（并行排期）** | | **~20-24 周** |

### P1 — 增强（内测后 8-10 周）

| 任务 | 工时 |
|------|------|
| M6 工具箱（技能市场 UI + 安装流程 + GitHub/Lark OAuth） | 4 周 |
| GitHub/GitLab Issue 双向同步 | 3 周 |
| Agent 模板市场 + Fork | 3 周 |
| HxA 协作拓扑图 | 1.5 周 |
| 消息搜索 + 引用回复 | 2 周 |
| 审批策略（高风险操作人工审批） | 2 周 |
| OAuth 集成框架 + 前 5 个平台 | 4 周 |
| 通知系统（Agent 完成/任务分配/@提及） | 2 周 |
| Workspace 计费（Stripe per-seat） | 4 周 |

### P2 — 规模化（P1 后 8-12 周）

| 任务 | 工时 |
|------|------|
| Cmd+K 全局命令面板 | 2 周 |
| Sprint 管理 + Velocity 图表 | 3 周 |
| 任务自动化规则引擎 | 3 周 |
| 外部 IM 桥接（Lark/Slack 双向同步） | 4 周 |
| 多团队支持 | 2 周 |
| 社区技能上传 + 审核 | 3 周 |
| SSO (SAML/OIDC) + SCIM | 4 周 |
| 审计日志完整实现 | 2 周 |
| 移动端适配 / PWA | 6 周 |

---

## 七、团队配置与排期

### 最小团队：6-7 人

| 角色 | 人数 | 主要职责 |
|------|------|---------|
| 前端工程师 | 2 | 对话 UI（WebSocket + 流式渲染）、任务看板、项目页、Agent 管理页、管理后台 |
| 后端工程师 | 2 | API 全套、WebSocket 服务、Agent 运行时编排、数据库、Stripe |
| Agent/基础设施工程师 | 1 | Docker Agent 运行时、模型网关、Agent ↔ 平台通信协议、MCP 集成 |
| 设计师 | 0.5 | 基于现有设计稿细化交互（可兼职） |
| 产品/项目 | 1 | Stephanie：优先级决策、验收、用户测试 |

> **对比之前方案：** 之前基于现有 dashboard 扩展是 4 人 16 周。现在全新产品需要 6-7 人 20-24 周。工程量是 **3 倍以上**。这是实话——不是在现有产品上加模块，而是从零造一个 Linear + Slack + GitHub Copilot 的合体。

### 并行排期（6 人工程团队）

```
周次   前端A         前端B         后端A          后端B          Agent工程师      里程碑
──────────────────────────────────────────────────────────────────────────────────
W1-2   项目脚手架     设计系统       DB schema +    Auth +         Docker Agent    🏁 技术评审
       Next.js 搭建   组件库搭建     Prisma 迁移    Logto 集成     运行时 PoC

W3-4   M1 对话 UI     M2 任务        M4 团队 API    M2 任务 API    Agent 创建 +    🏁 对话 PoC
       WebSocket      Kanban 组件    成员管理       CRUD + 分配    部署流程

W5-6   M1 对话        M2 任务看板    M1 消息 API    M3 项目 API    Agent ↔ 平台    🏁 任务可拖拽
       频道 + DM      拖拽 + 筛选    WebSocket      + 任务关联     通信协议

W7-8   M1 Agent       M3 项目        M5 Agent       M5 Agent       模型网关        🏁 可跟 Agent
       流式响应       卡片页         CRUD API       配置 + 监控    (多模型路由)    对话

W9-10  M5 Agent       M4 团队        M7 管理后台    M5 Agent       Agent 任务      🏁 Agent
       仪表板 UI      成员页 UI      概览 + 席位    模板系统       执行引擎        执行任务

W11-12 M7 管理后台    M8 设置        M7 权限控制    用量计量       Agent 权限      🏁 全功能
       UI             基础页         API            + 统计         沙箱            联调

W13-16 集成测试       UI polish      Bug fix        性能优化       稳定性测试      🏁 内测

W17-20 内测修复       内测修复       内测修复       内测修复       内测修复        🏁 Beta
──────────────────────────────────────────────────────────────────────────────────
```

**关键里程碑：**

- **W2：** 技术评审 — 架构对齐，Agent 运行时 PoC 验证
- **W4：** 对话 PoC — 能在浏览器里跟一个 Agent 聊天
- **W8：** 核心可用 — 能对话 + 能建任务 + Agent 能执行
- **W12：** 全功能联调 — 所有 P0 模块串通
- **W16：** 内测启动 — 5-10 个团队 closed beta
- **W20：** Beta 发布

---

## 八、风险与待决策项

### 技术风险

> **1. Agent 运行时架构（最大风险）**
>
> 多 Agent 共享 vs 独立 VM 是整个项目的地基决策。选错 → 后面全部要改。建议 W1-2 做 PoC 验证 Docker 容器方案的隔离性、冷启动时间、资源开销，再做最终决策。

> **2. Agent 任务执行的可靠性**
>
> Agent「自动执行任务」不是确定性的——LLM 可能失败、超时、产出垃圾。需要：超时机制、重试策略、人工兜底通知、结果审核流程。这不是一个单一功能点，而是贯穿整个系统的质量保障层。

> **3. 实时通讯的规模**
>
> 对话模块 = 造一个简版 Slack。WebSocket 连接管理、消息排序、离线消息同步、移动端推送 — 每一项都不简单。建议 MVP 严格限制：单 Workspace ≤ 50 人，消息不做离线推送（P1再加）。

> **4. 多模型路由**
>
> 设计稿中 4 个 Agent 用了 4 个不同模型（Claude Sonnet / GPT-4 / Claude Opus / Gemini Pro）。需要一个模型网关统一管理 API key、限流、fallback、成本计算。

### 产品决策项（需要 Stephanie 确认）

| # | 决策项 | 建议 | 影响 |
|---|--------|------|------|
| D1 | Agent 运行时方案 | Docker 容器（不是独立 VM） | 成本、部署复杂度、P0 Agent 工程师工作量 |
| D2 | 与现有 Dashboard 的关系 | 完全独立产品线，共享 Logto + Stripe 账户 | 代码库规划、团队分工 |
| D3 | MVP 预设 Agent 模板 | 先做 3 个：代码助手(Claude) + 测试(GPT-4) + 通用助手 | Agent 工程师工作量 |
| D4 | MVP 的 Git 集成深度 | P0 只做 repo 绑定 + 手动关联。双向同步放 P1 | 省 3 周开发 |
| D5 | 对话界面是否支持语音/视频 | 不做。纯文本 + 文件附件 | — |
| D6 | Agent 的模型由谁选？ | Admin 在创建时选择，不允许 Agent 自主切换 | 模型网关设计 |
| D7 | 产品名称 | 设计稿用 "CODE-YI"，正式产品名待定？ | 域名、品牌 |
| D8 | 定价模型 | 需要重新设计（不是之前 $79/人 方案）。建议按 Agent 数 + 人数 双维度 | Stripe 产品结构 |
| D9 | 开发团队从哪来？ | 6-7 人，现有团队还是新招？ | W1 能否启动 |

---

*COCO Workspace Product Spec v1.0 · 2026-04-19 22:30 SGT · 基于设计稿 v0.1 (10 screens) · 由 Zylos 分析生成*

*下一步：Stephanie 确认决策项 → 技术评审 → 启动开发*
