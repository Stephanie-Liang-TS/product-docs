# PRD — COCO Workspace (CODE-YI) AI-Native 团队协作平台

**Version**: 2.0
**Status**: Draft
**Author**: Zylos (Product Management)
**Date**: 2026-04-19
**Target release**: Q2-Q3 2026 (MVP Beta)
**Design reference**: CODE-YI v0.1 设计稿 (10 screens)

---

## Problem Statement

**Who has this problem**: 5-50 人的技术开发团队（初创公司、中小型团队）

**Problem**: 团队使用 AI 工具时面临三个核心问题：
1. AI 是"工具"不是"队友" — 用完即弃，没有持续记忆，没有任务意识
2. 人机协作碎片化 — 开发用 Copilot，沟通用 Slack/飞书，项目管理用 Jira/Linear，AI 不在任何一个系统里
3. 多 Agent 无法协作 — 代码 AI 不知道测试 AI 在做什么，产品 AI 不知道代码进展

**Frequency**: 每天，贯穿整个开发流程

**Current workaround**: 团队成员各自使用 ChatGPT/Claude/Copilot，手动复制粘贴 AI 产出到项目管理工具

**Cost of not solving**: 团队 AI 能力无法积累，重复提示词浪费，人机协作效率仅达理论值的 20-30%

---

## Proposed Solution

**What we're building**: 一个 AI-Native 团队协作平台，人类和 AI Agent 作为平级团队成员共同完成项目。内置对话、任务管理、项目追踪、Agent 管理，集成开发工具链（GitHub/GitLab/Lark/Jira）。

**What this is NOT**:
- 不是在现有 COCO Dashboard 上加功能 — 全新独立产品
- 不是又一个 ChatGPT/Claude wrapper — Agent 有角色、有任务、有绩效
- 不是项目管理工具 — PM 功能服务于人机协作，不是取代 Jira
- 不含语音/视频通话 — 纯文本 + 文件协作

**Hypothesis**: 如果我们让 AI Agent 成为团队的正式成员（有任务分配、有执行结果、有用量追踪），团队的 AI 利用率将从手动调用提升到系统化协作，开发效率提升 40%+。

---

## Impact Analysis

**Systems affected**:
- 新建独立代码库（不影响现有 coco-dashboard）
- 共享 Logto 认证实例（新增 Workspace 应用）
- 共享 Stripe 商户账户（新增 Workspace 产品线）
- 新增 Cloud SQL 数据库（同实例）
- 新增 GCE VM / Docker 运行时（Agent 容器）

**User segments affected**:
- 现有个人用户（300+）：不受影响，Dashboard 继续服务
- 新目标用户（开发团队）：全新获客
- 内部团队：需要 6-7 人工程团队

**Dependencies**:
- Must ship before: Agent 容器化运行时 PoC 验证（W1-2）
- Must ship alongside: 新的定价模型 + Stripe 产品配置

---

## Requirements

### Module 1: 对话 (Chat)

**Story 1.1**: As a 团队成员, I want to 在频道中跟 Agent 和队友对话 so that 所有协作发生在一个地方

Acceptance Criteria:
- Given 用户在工作区频道中, when 发送消息, then 所有频道成员（含 Agent）实时收到
- Given 用户 @提及一个 Agent, when 消息发送, then Agent 在 5 秒内开始流式响应
- Given Agent 生成代码块, when 渲染完成, then 代码有语法高亮 + 一键复制按钮

**Story 1.2**: As a 团队成员, I want to 跟 Agent 进行私人对话 so that 我的个人问题不暴露给整个团队

Acceptance Criteria:
- Given 用户发起与 Agent 的 DM, when 对话进行, then 内容仅该用户和 Agent 可见
- Given 管理员查看管理后台, when 查看席位列表, then 能看到 DM 存在但无法看到内容

**Story 1.3**: As a 团队成员, I want to 在消息中附加文件和图片 so that 我可以给 Agent 提供上下文

Acceptance Criteria:
- Given 用户拖拽文件到对话框, when 文件上传完成, then 文件作为附件展示在消息中
- Given 文件大小超过 50MB, when 尝试上传, then 显示错误提示

**Complexity**: XL (WebSocket + 流式渲染 + 文件上传)

---

### Module 2: 任务 (Tasks)

**Story 2.1**: As a 团队负责人, I want to 创建任务并分配给 Agent so that Agent 自动执行开发工作

Acceptance Criteria:
- Given 用户在看板中创建任务, when 选择 Agent 为指派人, then 任务状态自动变为「进行中」，Agent 开始执行
- Given Agent 完成任务, when 执行结果生成, then 任务状态变为「已完成」，结果报告附在任务评论中
- Given Agent 执行失败, when 错误发生, then 任务标记为需要注意，通知任务创建者

**Story 2.2**: As a 团队成员, I want to 在 Kanban 看板上拖拽任务 so that 我可以直观管理任务状态

Acceptance Criteria:
- Given 看板显示四列（待办/进行中/已完成/已归档）, when 拖拽任务卡到另一列, then 状态实时更新
- Given 多人同时操作, when 另一用户拖拽了同一张卡, then 我的界面实时同步变化

**Story 2.3**: As a 团队成员, I want to 按项目/指派人/优先级筛选任务 so that 我能快速找到关注的任务

Acceptance Criteria:
- Given 任务列表包含多个项目的任务, when 选择「我负责的」标签, then 只显示我被指派的任务
- Given 选择「Agent 执行中」筛选, when 筛选生效, then 只显示状态为进行中且指派给 Agent 的任务

**Complexity**: L (Kanban 拖拽 + 实时同步 + Agent 执行集成)

---

### Module 3: 项目 (Projects)

**Story 3.1**: As a 团队负责人, I want to 创建项目并绑定团队成员 so that 任务有组织归属

Acceptance Criteria:
- Given 用户点击「新建项目」, when 填写名称/描述/Sprint 标签, then 项目卡片出现在列表中
- Given 进入项目详情, when 查看任务, then 显示该项目下的 Kanban 视图

**Story 3.2**: As a 团队负责人, I want to 查看所有项目的进度概览 so that 我知道哪些项目需要关注

Acceptance Criteria:
- Given 项目列表页, when 查看卡片, then 每个卡片显示进度百分比 + 最近活动时间 + 团队成员头像
- Given 项目进度低于 30% 但已过半周期, when 查看列表, then 该项目卡片有视觉告警

**Complexity**: M

---

### Module 4: 团队 (Team)

**Story 4.1**: As a 管理员, I want to 邀请人类成员加入工作区 so that 团队可以协作

Acceptance Criteria:
- Given 管理员点击「邀请成员」, when 输入邮箱并发送, then 目标用户收到邮件邀请，点击链接加入
- Given 用户接受邀请, when 加入工作区, then 立即可见所有公开频道和项目

**Story 4.2**: As a 管理员, I want to 添加 Agent 成员并设置角色 so that Agent 在团队中有明确分工

Acceptance Criteria:
- Given 管理员在 Agent 页面创建了一个 Agent, when 在团队页添加该 Agent, then 可选择角色（执行者/审核者/协调者/观察者）
- Given Agent 角色为「观察者」, when Agent 被分配任务, then 系统阻止并提示「观察者不可执行任务」

**Story 4.3**: As a 团队成员, I want to 查看人和 Agent 的统一团队视图 so that 我知道团队组成

Acceptance Criteria:
- Given 进入团队页, when 页面加载, then 分两区展示：人类成员（含角色标签）+ Agent 成员（含模型标签 + 在线状态）

**Complexity**: M

---

### Module 5: Agent 管理

**Story 5.1**: As a 管理员, I want to 从预设模板创建 Agent so that 快速部署专业 AI 队友

Acceptance Criteria:
- Given 管理员点击「创建 Agent」, when 选择「代码助手」模板, then 自动填充模型(Claude Sonnet)、技能(代码生成/重构/Code Review)、persona
- Given 创建完成, when Agent 部署成功, then 状态变为「在线」，Agent 卡片出现在管理页

**Story 5.2**: As a 管理员, I want to 查看每个 Agent 的运行状态和绩效 so that 我知道 Agent 是否正常工作

Acceptance Criteria:
- Given Agent 仪表板, when 查看卡片, then 显示本周任务数 / 成功率 / 平均执行时长
- Given Agent 成功率低于 80%, when 查看状态, then 卡片显示告警标记

**Story 5.3**: As a 管理员, I want to 修改 Agent 的 persona 和技能配置 so that Agent 行为符合团队需求

Acceptance Criteria:
- Given 进入 Agent 配置页, when 修改系统 prompt, then 下一次 Agent 响应使用新 prompt
- Given 禁用某个技能, when Agent 尝试调用该技能, then 操作被阻止

**Complexity**: XL (含 Agent 运行时编排)

---

### Module 6: 工具箱 (Toolbox) — P1

**Story 6.1**: As a 管理员, I want to 浏览和安装工具集成 so that Agent 能连接外部服务

Acceptance Criteria:
- Given 工具箱页面, when 浏览技能列表, then 按分类展示（内置/MCP/社区），含评分和安装数
- Given 点击「安装」GitHub 集成, when OAuth 授权完成, then Agent 可以调用 GitHub API

**Complexity**: L

---

### Module 7: 管理后台 (Admin)

**Story 7.1**: As a 管理员, I want to 查看系统概览 so that 我了解 AI 使用情况和成本

Acceptance Criteria:
- Given 进入管理后台, when 页面加载, then 展示 4 个 KPI 卡：Agent 数 / 活跃用户 / API 调用量 / Credits 消耗，各含周环比
- Given 查看趋势图, when 选择 7 天范围, then 显示每日 API 调用折线图

**Story 7.2**: As a 管理员, I want to 统一管理人和 Agent 的席位 so that 我能控制成本和权限

Acceptance Criteria:
- Given 席位管理表, when 查看列表, then 人和 Agent 混合展示，含角色/类型/最近活跃/本周 API 调用/状态列
- Given 点击某 Agent 行的「管理」, when 打开配置, then 可修改执行权限开关

**Story 7.3**: As a 管理员, I want to 控制 Agent 的执行权限 so that 高风险操作需要人工审批

Acceptance Criteria:
- Given 权限控制面板, when 关闭「数据库操作」开关, then 所有 Agent 无法执行 DB 操作
- Given 开启「高风险操作需人工审批」, when Agent 尝试执行文件删除, then 操作暂停，通知管理员审批

**Complexity**: M

---

### Module 8: 设置 (Settings) — P1

**Story 8.1**: As a 用户, I want to 管理我的 OAuth 连接 so that Agent 能代我访问外部服务

Acceptance Criteria:
- Given 设置页 OAuth 面板, when 点击 GitHub 图标, then 跳转 OAuth 授权流程，完成后显示「已连接」
- Given 已连接 GitHub, when 点击断开, then 撤销 token 并显示「未连接」

**Complexity**: M

---

### Module 9: 全局命令面板 (Cmd+K) — P2

**Story 9.1**: As a 用户, I want to 用 Cmd+K 快速搜索和操作 so that 我不用逐级导航

Acceptance Criteria:
- Given 按下 Cmd+K, when 输入关键词, then 实时展示匹配的任务/项目/频道/命令
- Given 选择某个搜索结果, when 按回车, then 直接跳转到对应页面

**Complexity**: S

---

### Non-Functional Requirements

- **Performance**: 对话消息延迟 < 200ms（本地）；Agent 首 token 响应 < 3s；看板拖拽无卡顿
- **Scalability**: MVP 支持 100 个 Workspace，每个最多 50 人 + 10 Agent
- **Security**: Agent 运行在沙箱容器中，无法访问宿主机；API key 不暴露给前端；私人对话端到端加密（P2）
- **Availability**: 99.5% uptime（Agent 运行时允许冷启动延迟）

### Out of Scope (MVP)

- 语音/视频通话
- 移动端原生 App（PWA 可选 P2）
- 外部 IM 双向桥接（Lark/Slack → P2）
- 社区技能上传和审核市场
- SOC 2 / HIPAA 合规认证
- 多语言 i18n（MVP 仅中文 + 英文）

---

## Test Cases

| Scenario | Input | Expected Result |
|----------|-------|-----------------|
| 频道对话 happy path | 用户在频道发消息 @代码助手 "帮我写一个 login 组件" | Agent 流式回复，代码块有高亮 |
| 任务分配给 Agent | 创建任务 "实现用户注册 API" 并分配给代码助手 | 任务变为进行中，Agent 开始执行 |
| Agent 执行失败 | Agent 执行超时（>5min） | 任务标记告警，通知管理员 |
| 权限阻止 | 管理员关闭 DB 操作权限，Agent 尝试执行 SQL | 操作被阻止，Agent 回复"无权限" |
| 成员邀请 | 管理员输入邮箱邀请 | 邮件发出，用户点击链接成功加入 |
| 私人对话隔离 | 用户 A 跟 Agent DM，用户 B 查看 | B 看不到 A 的 DM 内容 |
| 多人同时编辑看板 | A 和 B 同时拖拽同一列的任务 | 两端实时同步，无冲突 |

---

## Success Metrics

| Metric | Baseline | Target | Measurement method | Timeline |
|--------|----------|--------|--------------------|----------|
| 内测团队数 | 0 | 10 | 注册统计 | W16 |
| 团队周活 Agent 交互次数 | 0 | >50 次/团队/周 | 消息+任务计数 | W20 |
| Agent 任务完成率 | — | >85% | 任务状态统计 | W20 |
| Beta 注册团队 | 0 | 50 | 注册统计 | W24 |
| NPS (内测用户) | — | >40 | 调查问卷 | W20 |

**Leading indicators** (check within 2 weeks of 内测):
- 每个团队是否创建了 ≥2 个 Agent
- 任务系统是否被使用（vs 只用对话）

**Guardrail metrics** (should not regress):
- 现有 Dashboard 个人用户的服务不受影响
- Agent 运行时可用性 >99%

---

## Rollback Plan

**Trigger**: Beta 期间 Agent 运行时可用性 < 95%，或安全事故（Agent 越权操作）

**Mechanism**: 
- Agent 运行时：Docker 容器可立即停止，不影响平台其他功能
- 功能级：Feature flag 控制每个模块的启用状态
- 数据级：数据库支持 point-in-time recovery

**Steps**:
1. 关闭受影响模块的 feature flag
2. 停止相关 Agent 容器
3. 通知受影响用户
4. 分析根因并修复
5. 灰度重新开启

**Owner**: 技术负责人
**Estimated time to rollback**: < 30 分钟
**Data impact**: 用户数据不丢失（消息/任务持久化在 PostgreSQL）

---

## Risks & Assumptions

| Type | Description | Likelihood | Impact | Mitigation |
|------|-------------|------------|--------|------------|
| Assumption | 开发团队愿意在浏览器内跟 Agent 对话（而非继续用 IDE/IM） | — | — | 内测期间验证，如不成立则 P1 加 IM 桥接 |
| Assumption | Docker 容器隔离性足够满足多 Agent 安全需求 | — | — | W1-2 PoC 验证 |
| Risk | Agent 任务执行不可靠（LLM 幻觉/超时） | H | H | 超时机制 + 重试 + 人工兜底通知 |
| Risk | 实时通讯性能（WebSocket 在高并发下） | M | H | MVP 限制 50 人/Workspace，压测验证 |
| Risk | 多模型路由的成本和延迟 | M | M | 模型网关统一管理，限制可选模型 |
| Risk | 6-7 人工程团队的招聘/组建 | H | H | 尽快确认团队来源（内部调配 vs 新招） |
| Risk | 与现有 Dashboard 产品线的定位冲突 | L | M | 明确区分：Dashboard=个人，Workspace=团队 |
| Risk | Agent 运行时成本（每 Agent 一个容器） | M | H | 资源调度：空闲 Agent 休眠，按需唤醒 |

---

## Open Questions

- [ ] **D1: Agent 运行时方案** — Docker 容器 vs 独立 VM vs 进程级？建议 Docker。 — Owner: 技术负责人 — Due: W2
- [ ] **D2: 与现有 Dashboard 的关系** — 完全独立 vs 共享代码？建议完全独立。 — Owner: Stephanie — Due: W1
- [ ] **D3: MVP 预设 Agent 模板** — 哪 3 个先做？建议代码助手 + 测试 + 通用。 — Owner: Stephanie — Due: W1
- [ ] **D4: Git 集成深度** — P0 做双向同步还是只做 repo 绑定？建议 P0 只绑定。 — Owner: 技术负责人 — Due: W2
- [ ] **D5: Agent 模型选择** — 用户自选 vs Admin 统一配置？建议 Admin 在创建时选择。 — Owner: Stephanie — Due: W1
- [ ] **D6: 产品名称** — CODE-YI（设计稿）还是 COCO Workspace？ — Owner: Stephanie — Due: W1
- [ ] **D7: 定价模型** — 按人头 + Agent 数双维度？具体价格？ — Owner: Stephanie — Due: W4
- [ ] **D8: 团队组建** — 6-7 人从哪来？现有团队还是新招？ — Owner: Stephanie — Due: ASAP
- [ ] **D9: 技术评审** — 需要团队到位后进行架构评审 — Owner: 技术负责人 — Due: W2

---

## Appendix: Architecture Overview

详细架构参见：
- **产品架构 Spec**: https://zylos150.coco.site/coco-workspace-spec.html
- **初版系统架构**（基于扩展方案，已废弃）: https://zylos150.coco.site/workspace-architecture.html

### Tech Stack Summary

| Layer | Choice |
|-------|--------|
| Frontend | Next.js 16 + TailwindCSS v4 + Radix UI + Socket.IO client |
| Backend | Fastify 5 + TypeScript + Prisma 6 |
| Database | PostgreSQL 17 (Cloud SQL) |
| Real-time | Socket.IO + Redis Pub/Sub |
| Queue | BullMQ + Redis |
| Agent Runtime | Docker containers on GCE VM |
| Auth | Logto (shared) |
| Payments | Stripe (new product line) |
| Storage | GCS |
| CI/CD | GitHub Actions + Cloud Run |

### Team Requirement: 6-7 people

| Role | Count | Focus |
|------|-------|-------|
| Frontend | 2 | Chat UI (WebSocket), Kanban, Agent dashboard |
| Backend | 2 | API, WebSocket server, DB, Stripe |
| Agent/Infra | 1 | Docker runtime, model gateway, MCP |
| Design | 0.5 | Interaction detail (part-time) |
| Product | 1 | Stephanie: decisions + validation |

### Timeline: ~20-24 weeks to MVP Beta

- W2: Tech review + Agent runtime PoC
- W8: Core usable (chat + tasks + Agent execution)
- W12: All P0 modules integrated
- W16: Closed beta (5-10 teams)
- W20: Public beta

---

_PRD by Product Manager (Zylos) — requires Stephanie review + engineering review before development begins._
