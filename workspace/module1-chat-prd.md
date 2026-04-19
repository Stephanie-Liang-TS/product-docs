# CODE-YI 模块 1：对话 (Chat) — 产品需求文档 (PRD)

> 版本 1.0 · 2026-04-19 · 产品负责人：Stephanie · 基于 COCO Workspace Spec v1.0

---

## 目录

1. [问题陈述](#一问题陈述)
2. [竞品分析摘要](#二竞品分析摘要)
3. [用户故事与验收标准](#三用户故事与验收标准)
4. [功能拆解（P0 / P1 / P2）](#四功能拆解)
5. [Agent 原生特性（HxA 差异化）](#五agent-原生特性hxa-差异化)
6. [数据模型](#六数据模型)
7. [技术方案与架构](#七技术方案与架构)
8. [测试用例](#八测试用例)
9. [成功指标](#九成功指标)
10. [风险与缓解措施](#十风险与缓解措施)
11. [排期与依赖](#十一排期与依赖)
12. [附录：竞品功能对标矩阵](#附录竞品功能对标矩阵)

---

## 一、问题陈述

### 背景

CODE-YI（COCO Workspace）是一个 AI-Native 团队协作平台，核心模型为 HxA（Human × Agent）——人类和 AI Agent 作为平级团队成员共同协作。对话模块（Module 1: Chat）是整个产品的核心交互层，承载人与人、人与 Agent、Agent 与 Agent 之间的所有沟通。

### 问题

现有团队协作工具（Slack、飞书、Teams、Discord）的即时通讯功能都是为**人与人沟通**设计的。AI 在这些平台中要么是作为"Bot/插件"存在（Slack Bot、飞书机器人），要么是后期嫁接的 Copilot（Teams Copilot）。这导致：

1. **Agent 是二等公民**：Bot 消息样式不同、权限受限、无法参与正常的对话流程
2. **缺少流式响应**：传统 IM 不支持 ChatGPT 式的逐字输出，Agent 回复像"发了一条很长的消息"
3. **无任务执行上下文**：Agent 在 Slack 里回复消息后，用户无法看到执行进度、中间产物、审批流
4. **多 Agent 协作缺失**：现有平台没有为多个 Agent 在同一对话中协作设计交互模式

### 目标

构建一个**以 Agent 为一等公民**的即时通讯模块——人类和 Agent 使用统一的消息界面，Agent 响应支持流式输出、状态指示、产物展示、人工审批流。

### 非目标（MVP 不做）

- 音视频通话（纯文本 + 附件）
- 离线推送通知（P1）
- 外部 IM 桥接（P2）
- 端到端加密（不在路线图）
- 超过 50 人的 Workspace 支持

---

## 二、竞品分析摘要

> 以下基于 2026 年 4 月对 Lark/飞书、Slack、Microsoft Teams、Discord 四款产品的调研。

### 2.1 核心能力对标

| 能力维度 | 飞书/Lark | Slack | Microsoft Teams | Discord | CODE-YI（目标） |
|---------|----------|-------|----------------|---------|----------------|
| **频道/群组** | 公开/私密群组，支持外部群 | 公开/私密 Channel，Slack Connect 跨组织 | 公开/私密 Channel，跨租户共享频道 | 服务器 > 分类 > 频道（文字/语音/论坛） | 公开/私密频道，Agent 可作为频道成员 |
| **私聊** | 1:1 和多人（≤200） | 1:1 和多人（≤8） | 1:1 和群聊 | 1:1 和群 DM（≤10） | 1:1 人-人、人-Agent、Agent-Agent |
| **消息线程** | 引用回复 + 独立 thread | Thread（消息下展开子对话） | 2025 年新增 Thread，类 Slack 风格 | Thread（频道内子线程） + Forum Channel | 引用回复（P1），独立 Thread（P2） |
| **富文本** | Markdown、代码块、互动卡片（streaming 支持） | Markdown 子集、代码块、Canvas | Markdown、Adaptive Cards、Loop 组件 | Markdown 子集、Embed、代码块 | Markdown + 代码高亮 + Agent 产物卡片 |
| **AI/Bot 集成** | 自定义机器人 + MCP Server + CLI AI Agent 技能 | Agentforce + 2600+ App 市场 | Copilot（摘要/生成）+ Channel Agent | Bot 生态（MEE6/Carl-bot）+ AI 摘要 | **Agent 原生一等公民**（核心差异） |
| **流式响应** | 飞书互动卡片支持 streaming text | 不原生支持（Bot 发完整消息） | Copilot 支持流式，但仅限 Copilot 面板 | 不支持 | **全面支持**，SSE/WS 逐 token 推送 |
| **搜索** | 全文搜索 + CLI 搜索命令 | AI 语义搜索 + 跨 App 联合搜索 | AI 增强搜索 + 企业数据源 | 基础全文搜索 | 全文搜索（P1）+ 语义搜索（P2） |
| **在线状态** | 在线/离线/忙碌 | 活跃/离开/勿扰/自定义 | 可用/忙碌/离开/勿扰/离线 | 在线/空闲/勿扰/隐身 | 人类状态 + Agent 状态（空闲/思考中/执行中/错误） |
| **已读回执** | 群消息已读列表 | 无原生已读回执 | 已读回执（可关闭） | 2025 年新增 DM 已读回执 | DM 已读回执（P1） |
| **Emoji 反应** | 表情回应 + 贴纸 | 表情回应（自定义 emoji） | 表情回应 | 表情回应（自定义 emoji + 动画） | 表情回应（P0） |
| **文件分享** | 云端文件 + 拖拽上传 | 拖拽上传 + 跨 App 文件搜索 | OneDrive 集成 + 拖拽 | 拖拽上传（8MB 免费/500MB Nitro） | 拖拽上传 + Agent 产物文件（P0） |
| **通知** | 精细化通知设置 + 消息免打扰 | 精细化频道通知 + AI 摘要追赶 | 精细化 + AI 摘要 + @mention 汇总 | 频道级通知设置 | @mention 通知（P0）、精细化设置（P1） |
| **翻译** | 内置自动翻译 | AI 跨语言语义搜索 | Copilot 辅助翻译 | 实时翻译（2025 收购集成） | 不做（P2+） |

### 2.2 关键竞品洞察

**飞书/Lark：** 最具参考价值的竞品。飞书的互动卡片（Interactive Card）已经支持流式文本、状态指示（Thinking/Generating/Complete）和操作按钮——这与 CODE-YI 的 Agent 消息卡片需求高度一致。飞书 CLI 2026 年版本原生支持 AI Agent 22 种技能。飞书在中国开发者生态中占主导地位。

**Slack：** Thread 是行业标杆。Slack 的 AI 搜索（语义搜索 + 跨 App 联合搜索）代表了消息搜索的最高水平。Agentforce 和 Workflow Builder 展示了 Agent 在 IM 中执行任务的方向，但 Agent 仍是"App"而非"成员"。Split View（分屏）是高级用户的刚需。

**Microsoft Teams：** Channel Agent 概念与 CODE-YI 最接近——Agent 作为频道的"领域专家"，可查询 Jira/GitHub/Asana 数据。但 Teams 的 Agent 仍然是"叠加层"，不是原生对话参与者。Teams Mode（将 Copilot 对话转为群聊）是一个有趣的交互模式——让 AI 从私人助手变成群组参与者。

**Discord：** Forum Channel 是结构化讨论的最佳实践。Bot 生态极其丰富但碎片化。Discord 的 Embed（富媒体卡片）系统对 Agent 产物展示有参考价值。

### 2.3 CODE-YI 差异化定位

| 竞品现状 | CODE-YI 差异化 |
|---------|---------------|
| Agent/Bot 是"集成"——消息样式不同、权限受限 | Agent 是**一等成员**——统一头像、@mention、角色标签 |
| 无流式响应（或仅限 Copilot 面板） | **全消息流式输出**——Agent 回复像 ChatGPT 一样逐字出现 |
| Bot 消息是"最终结果" | Agent 消息可展示**执行过程**——思考中 → 执行中 → 完成 |
| 无多 Agent 协作 | **多 Agent 频道**——多个 Agent 在同一对话中交接协作 |
| 人工审批是外部流程（JIRA/审批系统） | **对话内审批**——Agent 请求权限 → 人类在消息中批准/拒绝 |
| 消息与任务割裂 | **消息关联任务**——Agent 执行结果自动关联对应 Task |

---

## 三、用户故事与验收标准

### US-01：频道对话（Channel Messaging）

**作为** Workspace 成员，**我想** 在公开频道中发送消息并看到所有成员（包括 Agent）的回复，**以便** 团队可以围绕项目进行公开讨论。

**验收标准：**
- [ ] 用户可以创建公开频道和私密频道
- [ ] 频道设置页可编辑名称、描述、成员列表
- [ ] 频道成员列表统一显示人类成员和 Agent 成员
- [ ] 消息按时间顺序排列，新消息自动滚动到底部
- [ ] 进入频道后加载最近 50 条消息，上滑加载更多（分页）
- [ ] 发送消息后 ≤200ms 在本地展示（乐观更新），≤500ms 其他成员收到
- [ ] 未读消息显示红色数字角标
- [ ] 频道列表按最近活跃时间排序

### US-02：私人对话（Direct Message）

**作为** Workspace 成员，**我想** 与另一个成员（人类或 Agent）进行 1:1 私聊，**以便** 进行不需要全团队看到的对话。

**验收标准：**
- [ ] 可以从成员列表发起 1:1 对话
- [ ] 私聊消息仅对对话双方可见
- [ ] 人-Agent 私聊可用于给 Agent 下达独立指令
- [ ] 私聊列表显示最近消息预览和时间戳
- [ ] 支持多人私聊（≤8 人，含 Agent）

### US-03：消息发送与展示

**作为** 消息发送者，**我想** 发送包含富文本、代码块和文件的消息，**以便** 表达清楚复杂的技术讨论内容。

**验收标准：**
- [ ] 支持 Markdown 语法：粗体、斜体、删除线、标题、列表、链接
- [ ] 支持代码块：行内代码 \`code\` 和多行代码块 \`\`\`lang ...，带语法高亮
- [ ] 支持图片上传：拖拽 + 粘贴 + 文件选择器，上传后显示缩略图
- [ ] 支持文件附件：拖拽上传，显示文件名 + 大小 + 下载链接
- [ ] 单个文件上传限制 50MB
- [ ] 消息输入框支持多行输入（Shift+Enter 换行，Enter 发送）
- [ ] 消息编辑：发送后 5 分钟内可编辑
- [ ] 消息删除：发送者可删除自己的消息，Admin 可删除任何消息

### US-04：消息归属与身份标识

**作为** 频道参与者，**我想** 清楚区分每条消息是谁发的（人类 vs Agent），**以便** 理解对话上下文和信息来源。

**验收标准：**
- [ ] 人类消息显示：头像 + 用户名 + 时间戳
- [ ] Agent 消息显示：Agent 图标 + Agent 名称 + Agent 角色标签（如"代码助手"） + 底层模型标签（如"Claude Sonnet"） + 时间戳
- [ ] Agent 消息有视觉区分（如淡色背景或左侧标记条）
- [ ] 消息归属信息不可伪造（后端校验 sender_id + sender_type）

### US-05：@提及与通知

**作为** 团队成员，**我想** @某人或 @某Agent 来引起注意或触发 Agent 行动，**以便** 精准地发起互动。

**验收标准：**
- [ ] 输入 `@` 后弹出成员选择器（人类 + Agent 混合列表）
- [ ] 选择器支持模糊搜索
- [ ] @人类 → 被提及者收到通知（页面内通知 + 未读提示）
- [ ] @Agent → Agent 被唤醒并在该对话中响应
- [ ] @channel / @all → 频道所有成员收到通知
- [ ] 被 @mention 的消息在消息列表中高亮显示
- [ ] @Agent 的消息以 Agent 名称后的内容作为指令输入

### US-06：Agent 流式响应

**作为** 与 Agent 对话的用户，**我想** 看到 Agent 的回复像 ChatGPT 一样逐字流式输出，**以便** 获得即时反馈而不是等待长时间后一次性出现。

**验收标准：**
- [ ] Agent 收到 @mention 或 DM 后，≤2 秒内开始流式输出
- [ ] 流式输出每 token 实时渲染，无明显卡顿（目标 ≥15 tokens/秒的渲染帧率）
- [ ] 流式输出过程中显示 Agent 状态指示器（见 US-07）
- [ ] 用户可以在流式输出过程中点击"停止生成"按钮中断
- [ ] 流式完成后消息变为普通消息（可复制、可引用）
- [ ] 代码块在流式过程中实时渲染高亮（关闭围栏后完整渲染）
- [ ] 多个 Agent 可同时流式输出（各自独立渲染）
- [ ] 流式中断/网络断开后可自动重连并接续

### US-07：Agent 状态指示

**作为** 团队成员，**我想** 看到 Agent 当前的工作状态，**以便** 知道 Agent 是否空闲、正在思考、或在执行任务。

**验收标准：**
- [ ] Agent 状态有 4 种：`idle`（空闲）、`thinking`（思考中）、`executing`（执行中）、`error`（异常）
- [ ] 频道成员列表和消息头像旁显示状态图标（绿点/转圈/闪烁/红点）
- [ ] `thinking` 状态：Agent 正在生成回复（流式输出前的思考阶段）
- [ ] `executing` 状态：Agent 正在执行任务（如运行代码、调用 API）——显示执行进度条
- [ ] `error` 状态：Agent 遇到错误——显示错误摘要，可点击查看详情
- [ ] 状态变化实时推送（WebSocket），延迟 ≤1 秒

### US-08：消息 Emoji 反应

**作为** 频道参与者，**我想** 对消息添加 Emoji 反应，**以便** 快速表达意见而不需要发新消息。

**验收标准：**
- [ ] 鼠标悬停/长按消息显示快捷反应栏（常用 6 个 emoji）
- [ ] 点击 `+` 展开完整 emoji 选择器
- [ ] 一条消息可有多个不同 emoji，每个 emoji 显示数量和反应者列表
- [ ] 支持自定义 Workspace Emoji（P1）
- [ ] Agent 也可以添加 Emoji 反应

### US-09：消息引用与回复（P1）

**作为** 频道参与者，**我想** 引用一条历史消息进行回复，**以便** 在多人对话中保持上下文清晰。

**验收标准：**
- [ ] 鼠标悬停消息可点击"回复"按钮
- [ ] 回复时在输入框上方显示被引用消息预览
- [ ] 发送后显示引用卡片（被引用消息的摘要 + 原作者 + "点击跳转"）
- [ ] 被回复的消息显示回复计数

### US-10：消息搜索（P1）

**作为** Workspace 成员，**我想** 搜索历史消息，**以便** 找到之前讨论过的内容。

**验收标准：**
- [ ] 全文搜索支持关键词匹配
- [ ] 搜索结果显示消息内容片段 + 发送者 + 频道 + 时间
- [ ] 支持按频道、发送者、时间范围筛选
- [ ] 点击搜索结果跳转到消息所在位置并高亮
- [ ] 搜索响应时间 ≤500ms（50 人 Workspace 规模）

### US-11：外部 IM 桥接（P2）

**作为** Workspace 管理员，**我想** 将 CODE-YI 频道与飞书/Slack 群组桥接，**以便** 团队在不切换工具的情况下保持同步。

**验收标准：**
- [ ] 支持飞书群 ↔ CODE-YI 频道双向消息同步
- [ ] 支持 Slack Channel ↔ CODE-YI 频道双向消息同步
- [ ] 桥接消息标注来源平台（如 "[Lark] 张三: ..."）
- [ ] 图片和文件附件同步传输
- [ ] 管理员可配置桥接映射关系

---

## 四、功能拆解

### P0 — MVP 核心（6 周）

> 最小可用对话模块：能聊天 + 能跟 Agent 流式对话 + 基本频道管理

#### 4.1 频道管理

| # | 子功能 | 描述 | 复杂度 |
|---|--------|------|--------|
| F-001 | 创建频道 | 名称、描述、公开/私密、初始成员选择 | S |
| F-002 | 频道列表 | 左侧导航显示已加入频道，按最近活跃排序，未读角标 | M |
| F-003 | 频道详情/设置 | 编辑名称/描述、查看成员列表、退出频道 | S |
| F-004 | 加入/离开频道 | 公开频道可直接加入，私密频道需邀请 | S |
| F-005 | 频道成员管理 | 添加/移除成员（人类 + Agent），Admin 可管理所有频道 | M |
| F-006 | 默认频道 | 新 Workspace 自动创建 #general 频道，所有成员自动加入 | S |

#### 4.2 私人对话

| # | 子功能 | 描述 | 复杂度 |
|---|--------|------|--------|
| F-007 | 发起私聊 | 从成员列表或 @mention 发起 1:1 对话 | S |
| F-008 | 私聊列表 | 最近对话列表，显示对方头像/名称 + 最近消息预览 + 时间 | M |
| F-009 | 多人私聊 | 2-8 人群聊（含 Agent），创建时选择参与者 | M |

#### 4.3 消息系统

| # | 子功能 | 描述 | 复杂度 |
|---|--------|------|--------|
| F-010 | 消息发送 | 文本消息发送，乐观更新，WebSocket 推送 | M |
| F-011 | 消息列表渲染 | 时间线排列，分组（日期分隔线），自动滚动到底部 | M |
| F-012 | 消息分页加载 | 初始加载最近 50 条，上滑触发加载更多（游标分页） | M |
| F-013 | 消息归属显示 | 人类：头像+名称+时间；Agent：图标+名称+角色标签+模型标签+时间 | S |
| F-014 | Markdown 渲染 | 粗体/斜体/删除线/标题/列表/链接/行内代码 | M |
| F-015 | 代码块渲染 | 多行代码块 + 语法高亮（支持 20+ 语言） + 复制按钮 | M |
| F-016 | 图片上传/预览 | 拖拽/粘贴/选择上传，缩略图预览，点击放大 | M |
| F-017 | 文件附件 | 拖拽上传（≤50MB），文件卡片（名称+大小+下载链接） | M |
| F-018 | 消息编辑 | 5 分钟内可编辑，显示"已编辑"标记 | S |
| F-019 | 消息删除 | 发送者可删除自己的消息，Admin 可删除任何消息 | S |
| F-020 | Emoji 反应 | 快捷反应栏 + 完整选择器 + 反应计数 | M |

#### 4.4 @提及与通知

| # | 子功能 | 描述 | 复杂度 |
|---|--------|------|--------|
| F-021 | @mention 选择器 | 输入 `@` 弹出人类+Agent 混合选择器，模糊搜索 | M |
| F-022 | @Agent 唤醒 | @Agent 后 Agent 在该对话中被唤醒并响应 | L |
| F-023 | @all / @channel | 通知频道所有成员 | S |
| F-024 | 页面内通知 | 被 @mention 时侧边栏/导航显示通知提示 | M |
| F-025 | 通知中心（简版） | 点击通知图标查看所有未读 @mention，点击跳转 | M |

#### 4.5 Agent 流式响应

| # | 子功能 | 描述 | 复杂度 |
|---|--------|------|--------|
| F-026 | 流式消息渲染 | SSE/WebSocket 接收 token 流，实时追加到消息 DOM | L |
| F-027 | Agent 状态指示 | 4 状态图标：idle/thinking/executing/error | M |
| F-028 | 停止生成 | 用户点击按钮中断 Agent 流式输出 | M |
| F-029 | Agent 消息样式 | Agent 消息带视觉区分（淡色背景 + 左侧标记条 + 角色标签） | S |
| F-030 | 多 Agent 并行流式 | 多个 Agent 在同一频道同时流式输出，各自独立 | L |
| F-031 | Agent 产物展示 | 代码块/文件/报告作为可折叠的"产物卡片"展示 | M |

#### 4.6 实时基础设施

| # | 子功能 | 描述 | 复杂度 |
|---|--------|------|--------|
| F-032 | WebSocket 连接管理 | 建连、心跳、自动重连（指数退避） | L |
| F-033 | 在线状态 | 人类：在线/离线；Agent：idle/thinking/executing/error | M |
| F-034 | 输入中指示 | "张三正在输入..."（仅人类，Agent 用状态指示替代） | S |
| F-035 | 消息投递确认 | 发送 → 已发送（单 ✓） → 已送达（双 ✓） | S |

---

### P1 — 增强（内测后 ~2 周）

| # | 子功能 | 描述 | 复杂度 |
|---|--------|------|--------|
| F-036 | 消息引用/回复 | 引用上下文回复，显示引用卡片 + 回复计数 | M |
| F-037 | 消息搜索 | 全文搜索 + 按频道/发送者/时间范围筛选 | L |
| F-038 | DM 已读回执 | 私聊消息已读/未读状态 | S |
| F-039 | 消息置顶 | 频道可置顶重要消息（Admin/发送者可操作） | S |
| F-040 | Agent 对话内审批 | Agent 请求权限时发送审批卡片，人类点击批准/拒绝 | L |
| F-041 | Agent 执行进度 | Agent 执行任务时在消息中显示步骤进度（步骤 1/5 ✓...） | M |
| F-042 | 频道通知设置 | 按频道设置：所有消息 / 仅 @mention / 静音 | S |
| F-043 | 消息撤回 | 2 分钟内撤回，其他人看到"xxx 撤回了一条消息" | S |
| F-044 | 键盘快捷键 | Ctrl+K 搜索、Esc 关闭、↑ 编辑上条消息 | S |
| F-045 | 拖拽排序频道 | 左侧频道列表可拖拽排序 | S |

### P2 — 规模化（P1 后 ~4 周）

| # | 子功能 | 描述 | 复杂度 |
|---|--------|------|--------|
| F-046 | 外部 IM 桥接 | 飞书/Slack ↔ CODE-YI 双向消息同步 | XL |
| F-047 | Thread（子线程） | 消息下展开子对话（类 Slack Thread） | L |
| F-048 | 消息转发 | 转发消息到其他频道或私聊 | S |
| F-049 | 消息书签/收藏 | 收藏消息，个人收藏列表 | S |
| F-050 | 自定义 Emoji | Workspace 级自定义 Emoji 上传 | M |
| F-051 | Agent 对话分支 | Agent 回复后可"分支"出新对话线（类 ChatGPT 分支） | L |
| F-052 | AI 摘要 | 频道对话 AI 摘要（追赶未读） | M |
| F-053 | 语义搜索 | 基于 embedding 的语义搜索 | L |
| F-054 | 消息翻译 | 单条消息一键翻译 | M |

---

## 五、Agent 原生特性（HxA 差异化）

> 这是 CODE-YI 区别于所有现有 IM 产品的核心。以下功能贯穿 P0-P2，是产品灵魂。

### 5.1 Agent 消息卡片设计

```
┌─────────────────────────────────────────────────┐
│ 🤖 代码助手  ·  执行者  ·  Claude Sonnet        │  ← Agent 身份行
│ ─────────────────────────────────────────────── │
│                                                  │
│  我来帮你实现这个登录页面。                          │  ← 流式文本内容
│                                                  │
│  ```tsx                                          │  ← 代码产物（可折叠）
│  export function LoginPage() {                   │
│    const [email, setEmail] = useState('')        │
│    ...                                           │
│  }                                               │
│  ```                                             │
│                                                  │
│  📎 login-page.tsx (2.3KB)                       │  ← 文件产物
│                                                  │
│  ───────────────────────────────────────         │
│  ✅ 代码生成完成 · 耗时 4.2s · 238 tokens        │  ← 状态尾行
│  [复制代码] [应用到项目] [查看 diff]                │  ← 操作按钮
└─────────────────────────────────────────────────┘
```

### 5.2 Agent 状态机

```
         @mention / DM
              │
              ▼
┌──────┐  触发   ┌──────────┐  生成完毕   ┌──────┐
│ idle │───────>│ thinking │──────────>│ idle │
└──────┘        └────┬─────┘           └──────┘
                     │
                     │ 需要执行操作（调 API / 跑代码）
                     ▼
                ┌───────────┐  完成/失败   ┌──────┐
                │ executing │───────────>│ idle │
                └─────┬─────┘             └──┬───┘
                      │                      │
                      │ 运行时异常             │
                      ▼                      │
                 ┌─────────┐  手动恢复        │
                 │  error  │─────────────────┘
                 └─────────┘
```

### 5.3 多 Agent 协作模式

场景示例：用户在频道中说 "@代码助手 实现登录页面，@测试Agent 写测试"

```
时间线：
T+0s   用户: @代码助手 实现登录页面，@测试Agent 写测试
T+1s   代码助手 状态 → thinking
T+2s   代码助手: [流式输出中] 好的，我来实现登录页面...
T+15s  代码助手: [完成] 登录页面代码如下... 📎 login-page.tsx
T+16s  测试Agent 状态 → thinking（可配置：等待前序 Agent 完成后启动）
T+17s  测试Agent: [流式输出中] 收到，我来基于登录页面写测试...
T+30s  测试Agent: [完成] 测试代码如下... 📎 login-page.test.tsx
```

多 Agent 协调策略（可配置）：
- **并行模式**：所有被 @mention 的 Agent 同时响应
- **串行模式**：按 @mention 顺序依次执行（默认）
- **触发模式**：Agent A 完成后，其产出自动作为 Agent B 的输入

### 5.4 对话内审批流（P1）

当 Agent 执行高风险操作（由 Admin 在权限设置中定义），需要人工批准：

```
┌─────────────────────────────────────────────────┐
│ 🤖 代码助手  ·  需要批准                          │
│ ─────────────────────────────────────────────── │
│                                                  │
│  ⚠️ 我需要执行以下操作，请批准：                     │
│                                                  │
│  操作：删除数据库表 `legacy_users`                  │
│  原因：该表已迁移到新结构，不再使用                    │
│  影响：删除 2,340 条记录，操作不可逆                  │
│                                                  │
│  [✅ 批准]  [❌ 拒绝]  [💬 追问详情]               │
└─────────────────────────────────────────────────┘
```

---

## 六、数据模型

### 6.1 核心表

```sql
-- 频道/对话
channels {
  id              UUID PRIMARY KEY,
  workspace_id    UUID NOT NULL REFERENCES workspaces(id),
  name            VARCHAR(100),          -- 频道名，DM 为 NULL
  type            ENUM('public', 'private', 'dm'),
  description     TEXT,
  created_by      UUID NOT NULL,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW(),
  archived_at     TIMESTAMPTZ            -- NULL = 活跃
}

-- 频道成员
channel_members {
  channel_id      UUID NOT NULL REFERENCES channels(id),
  member_id       UUID NOT NULL,          -- user_id 或 agent_id
  member_type     ENUM('human', 'agent'),
  role            ENUM('owner', 'admin', 'member'),
  joined_at       TIMESTAMPTZ DEFAULT NOW(),
  last_read_at    TIMESTAMPTZ,            -- 已读水位线
  notification    ENUM('all', 'mentions', 'muted') DEFAULT 'all',
  PRIMARY KEY (channel_id, member_id, member_type)
}

-- 消息
messages {
  id              UUID PRIMARY KEY,
  channel_id      UUID NOT NULL REFERENCES channels(id),
  sender_id       UUID NOT NULL,
  sender_type     ENUM('human', 'agent', 'system'),
  content         TEXT NOT NULL,           -- Markdown 原文
  content_type    ENUM('text', 'system', 'approval_request', 'agent_artifact'),
  reply_to_id     UUID REFERENCES messages(id),  -- 引用回复（P1）
  thread_id       UUID REFERENCES messages(id),  -- 子线程根（P2）
  attachments     JSONB,                   -- [{type, url, name, size, mime}]
  metadata        JSONB,                   -- Agent 元数据：{model, tokens, duration, status}
  edited_at       TIMESTAMPTZ,
  deleted_at      TIMESTAMPTZ,             -- 软删除
  created_at      TIMESTAMPTZ DEFAULT NOW()
}

-- 消息反应
message_reactions {
  id              UUID PRIMARY KEY,
  message_id      UUID NOT NULL REFERENCES messages(id),
  user_id         UUID NOT NULL,
  emoji           VARCHAR(50) NOT NULL,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (message_id, user_id, emoji)
}

-- Agent 产物（代码块、文件、报告）
agent_artifacts {
  id              UUID PRIMARY KEY,
  message_id      UUID NOT NULL REFERENCES messages(id),
  agent_id        UUID NOT NULL,
  type            ENUM('code', 'file', 'report', 'diff'),
  title           VARCHAR(255),
  content         TEXT,                    -- 代码内容或报告文本
  language        VARCHAR(50),             -- 代码语言
  file_url        VARCHAR(500),            -- 文件存储 URL
  file_size       BIGINT,
  metadata        JSONB,                   -- {line_count, test_passed, etc.}
  created_at      TIMESTAMPTZ DEFAULT NOW()
}

-- 审批请求（P1）
approval_requests {
  id              UUID PRIMARY KEY,
  message_id      UUID NOT NULL REFERENCES messages(id),
  channel_id      UUID NOT NULL REFERENCES channels(id),
  agent_id        UUID NOT NULL,
  action          VARCHAR(255) NOT NULL,   -- 操作描述
  reason          TEXT,
  risk_level      ENUM('low', 'medium', 'high', 'critical'),
  status          ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
  decided_by      UUID,                    -- 审批人 user_id
  decided_at      TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW()
}

-- 未读通知
notifications {
  id              UUID PRIMARY KEY,
  workspace_id    UUID NOT NULL,
  user_id         UUID NOT NULL,
  type            ENUM('mention', 'dm', 'approval', 'agent_complete', 'system'),
  channel_id      UUID REFERENCES channels(id),
  message_id      UUID REFERENCES messages(id),
  content_preview VARCHAR(200),
  is_read         BOOLEAN DEFAULT FALSE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
}
```

### 6.2 索引策略

```sql
-- 消息查询（频道内按时间分页）— 最核心的查询路径
CREATE INDEX idx_messages_channel_created ON messages(channel_id, created_at DESC)
  WHERE deleted_at IS NULL;

-- 全文搜索（P1）
CREATE INDEX idx_messages_fulltext ON messages
  USING GIN(to_tsvector('simple', content));

-- 用户未读通知
CREATE INDEX idx_notifications_user_unread ON notifications(user_id, is_read, created_at DESC)
  WHERE is_read = FALSE;

-- 频道成员快速查找
CREATE INDEX idx_channel_members_member ON channel_members(member_id, member_type);

-- 审批请求待处理
CREATE INDEX idx_approvals_pending ON approval_requests(channel_id, status)
  WHERE status = 'pending';
```

### 6.3 预估数据量（MVP: ≤50 人 Workspace）

| 表 | 日增量 | 月增量 | 备注 |
|---|--------|--------|------|
| messages | ~2,000 条 | ~60,000 条 | 50 人 × 40 条/天平均 |
| message_reactions | ~500 条 | ~15,000 条 | |
| agent_artifacts | ~100 条 | ~3,000 条 | |
| notifications | ~500 条 | ~15,000 条 | 自动清理 30 天 |

> 此规模下 PostgreSQL 单表完全够用，无需分表。全文搜索用 pg_trgm 即可，无需 Elasticsearch。

---

## 七、技术方案与架构

### 7.1 整体架构

```
┌──────────────────────────────────────────────────────────┐
│                       客户端 (Next.js)                     │
│  ┌───────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │ 频道列表   │  │ 消息列表      │  │ 消息输入框        │   │
│  │ Component  │  │ 流式渲染引擎  │  │ Markdown Editor  │   │
│  └───────────┘  └──────┬───────┘  └────────┬─────────┘   │
│                         │ WebSocket          │ REST API    │
└─────────────────────────┼────────────────────┼────────────┘
                          │                    │
┌─────────────────────────┼────────────────────┼────────────┐
│                    API 网关 (Fastify)                       │
│  ┌──────────────────────┼────────────────────┼──────────┐ │
│  │   Socket.IO Server   │     REST Routes    │          │ │
│  │   (ws://...)         │     (api/chat/...) │          │ │
│  └──────────┬───────────┘─────────┬──────────┘          │ │
│             │                     │                      │ │
│  ┌──────────▼─────────┐  ┌───────▼────────┐            │ │
│  │  Redis Pub/Sub      │  │  PostgreSQL    │            │ │
│  │  (消息扇出/在线状态)  │  │  (持久存储)    │            │ │
│  └──────────┬─────────┘  └────────────────┘            │ │
│             │                                            │ │
│  ┌──────────▼─────────┐  ┌────────────────┐            │ │
│  │  BullMQ 任务队列    │  │  GCS 对象存储   │            │ │
│  │  (Agent 任务分发)   │  │  (文件附件)     │            │ │
│  └──────────┬─────────┘  └────────────────┘            │ │
└─────────────┼──────────────────────────────────────────┘ │
              │                                              │
    ┌─────────▼─────────┐                                    │
    │  Agent 运行时容器   │ × N                               │
    │  (Docker)          │                                    │
    │  ┌──────────────┐  │                                    │
    │  │ LLM API 调用  │  │                                    │
    │  │ SSE 流式回传   │  │                                    │
    │  └──────────────┘  │                                    │
    └────────────────────┘                                    │
```

### 7.2 WebSocket 协议设计

#### 连接建立

```typescript
// 客户端
const socket = io('wss://workspace.codeyi.com', {
  auth: { token: jwt },
  query: { workspaceId }
});

// 自动加入已订阅的频道房间
socket.on('connect', () => {
  socket.emit('join:channels', { channelIds: [...] });
});
```

#### 事件清单

| 事件名 | 方向 | Payload | 说明 |
|--------|------|---------|------|
| `message:new` | S→C | `{id, channelId, sender, content, ...}` | 新消息 |
| `message:update` | S→C | `{id, content, editedAt}` | 消息编辑 |
| `message:delete` | S→C | `{id}` | 消息删除 |
| `message:reaction` | S→C | `{messageId, emoji, userId, action}` | 反应增删 |
| `agent:stream:start` | S→C | `{messageId, agentId}` | Agent 开始流式输出 |
| `agent:stream:token` | S→C | `{messageId, token}` | 流式 token |
| `agent:stream:end` | S→C | `{messageId, metadata}` | 流式完成 |
| `agent:status` | S→C | `{agentId, status, detail}` | Agent 状态变化 |
| `typing:start` | C→S/S→C | `{channelId, userId}` | 开始输入 |
| `typing:stop` | C→S/S→C | `{channelId, userId}` | 停止输入 |
| `presence:update` | S→C | `{userId, status}` | 在线状态变化 |
| `channel:updated` | S→C | `{channelId, changes}` | 频道信息更新 |

#### 流式输出协议（关键路径）

```
Client                   Server                  Agent Runtime
  │                        │                          │
  │── message:send ──────>│                          │
  │                        │── BullMQ job ──────────>│
  │                        │                          │
  │<── agent:status ──────│<── status:thinking ──────│
  │    {thinking}          │                          │
  │                        │                          │
  │<── agent:stream:start─│<── stream:start ─────────│
  │                        │                          │
  │<── agent:stream:token─│<── token ────────────────│  × N
  │    {token: "我"}       │                          │
  │<── agent:stream:token─│<── token ────────────────│
  │    {token: "来"}       │                          │
  │    ...                 │     ...                  │
  │                        │                          │
  │<── agent:stream:end ──│<── stream:end ───────────│
  │    {metadata}          │                          │
  │                        │                          │
  │<── agent:status ──────│<── status:idle ──────────│
  │    {idle}              │                          │
```

### 7.3 REST API 端点

```
频道管理
  POST   /api/chat/channels                   创建频道
  GET    /api/chat/channels                   列出已加入频道
  GET    /api/chat/channels/:id               获取频道详情
  PATCH  /api/chat/channels/:id               更新频道
  DELETE /api/chat/channels/:id               归档频道
  POST   /api/chat/channels/:id/members       添加成员
  DELETE /api/chat/channels/:id/members/:mid   移除成员

私聊
  POST   /api/chat/dm                         创建/获取 DM 频道
  GET    /api/chat/dm                         列出 DM 对话

消息
  GET    /api/chat/channels/:id/messages      获取消息（游标分页）
  POST   /api/chat/channels/:id/messages      发送消息
  PATCH  /api/chat/messages/:id               编辑消息
  DELETE /api/chat/messages/:id               删除消息

反应
  POST   /api/chat/messages/:id/reactions     添加反应
  DELETE /api/chat/messages/:id/reactions/:emoji  删除反应

文件
  POST   /api/chat/upload                     上传文件（返回 GCS URL）

搜索（P1）
  GET    /api/chat/search?q=...&channel=...   搜索消息

审批（P1）
  POST   /api/chat/approvals/:id/decide       批准/拒绝

通知
  GET    /api/chat/notifications               获取通知列表
  POST   /api/chat/notifications/read          标记已读
```

### 7.4 前端组件树

```
ChatModule/
├── ChatLayout                     # 三栏布局
│   ├── ChannelSidebar/            # 左侧栏
│   │   ├── ChannelList            # 频道列表（公开/私密分组）
│   │   ├── DMList                 # 私聊列表
│   │   └── ChannelSearch          # 频道搜索/创建
│   │
│   ├── MessagePane/               # 中间主区域
│   │   ├── ChannelHeader          # 频道名称 + 成员数 + 设置入口
│   │   ├── MessageList/           # 消息列表
│   │   │   ├── MessageGroup       # 同一发送者连续消息分组
│   │   │   ├── HumanMessage       # 人类消息组件
│   │   │   ├── AgentMessage/      # Agent 消息组件（核心差异化）
│   │   │   │   ├── AgentIdentity  # Agent 头像 + 名称 + 角色 + 模型
│   │   │   │   ├── StreamRenderer # 流式文本渲染引擎
│   │   │   │   ├── ArtifactCard   # 产物卡片（代码/文件/报告）
│   │   │   │   ├── StatusFooter   # 状态尾行（完成/耗时/token数）
│   │   │   │   └── ApprovalCard   # 审批请求卡片（P1）
│   │   │   ├── SystemMessage      # 系统消息（加入/离开/创建）
│   │   │   ├── DateDivider        # 日期分隔线
│   │   │   └── TypingIndicator    # "xxx正在输入..."
│   │   │
│   │   ├── MessageInput/          # 消息输入区
│   │   │   ├── MarkdownEditor     # 富文本编辑器
│   │   │   ├── MentionPopover     # @mention 选择器
│   │   │   ├── EmojiPicker        # Emoji 选择器
│   │   │   ├── FileUploader       # 文件/图片上传
│   │   │   └── ReplyPreview       # 引用回复预览（P1）
│   │   │
│   │   └── StopGenerateBar        # Agent 生成中 → 停止按钮
│   │
│   └── DetailPanel/               # 右侧面板（可折叠）
│       ├── MemberList             # 频道成员列表（人类+Agent，含状态）
│       ├── PinnedMessages         # 置顶消息（P1）
│       ├── SharedFiles            # 共享文件列表
│       └── SearchPanel            # 搜索面板（P1）
│
└── hooks/
    ├── useSocket                  # WebSocket 连接管理
    ├── useMessages                # 消息列表 + 分页 + 实时更新
    ├── useStreamRenderer          # 流式输出渲染
    ├── usePresence                # 在线状态
    ├── useNotifications           # 通知管理
    └── useChannels                # 频道列表 + CRUD
```

### 7.5 关键技术决策

| 决策 | 选型 | 理由 |
|------|------|------|
| WebSocket 框架 | Socket.IO v4 + Redis Adapter | 自动重连、房间、广播、多节点扇出 |
| 消息存储 | PostgreSQL 17 | 结构化查询 + JSONB 灵活字段，MVP 规模够用 |
| 全文搜索 | pg_trgm（P0）→ Elasticsearch（P2） | MVP 50 人规模 pg_trgm 足够，不引入额外依赖 |
| 缓存 | Redis 7 | 在线状态、频道成员列表、消息 ID 去重 |
| 文件存储 | GCS（Google Cloud Storage） | 现有基础设施，与 Workspace 其他模块统一 |
| Markdown 渲染 | react-markdown + rehype-highlight | 成熟方案，支持代码高亮和自定义组件 |
| 流式渲染 | 自建 StreamRenderer（基于 requestAnimationFrame） | 需要精细控制 token 缓冲 + 代码块状态机 |
| 消息列表虚拟化 | react-window 或 @tanstack/virtual | 大量消息时的性能保障 |
| 任务队列 | BullMQ（Redis-backed） | Agent 任务分发、重试、超时管理 |

### 7.6 流式渲染引擎设计

流式渲染是 Agent 消息的核心体验，需要专门设计：

```typescript
// StreamRenderer 核心逻辑
class StreamRenderer {
  private buffer: string = '';        // token 缓冲区
  private renderedContent: string = ''; // 已渲染内容
  private isInCodeBlock: boolean = false;
  private codeBlockBuffer: string = '';

  onToken(token: string) {
    this.buffer += token;

    // 代码块检测：在 ``` 围栏内缓冲，不逐 token 渲染
    if (this.detectCodeBlockStart()) {
      this.isInCodeBlock = true;
    }

    if (this.isInCodeBlock) {
      this.codeBlockBuffer += token;
      if (this.detectCodeBlockEnd()) {
        // 代码块结束，一次性渲染带高亮的完整代码块
        this.flushCodeBlock();
        this.isInCodeBlock = false;
      }
      return;
    }

    // 普通文本：节流渲染（requestAnimationFrame）
    this.scheduleRender();
  }

  private scheduleRender() {
    requestAnimationFrame(() => {
      this.renderedContent = this.buffer;
      this.notifyUI(); // 触发 React 重渲染
    });
  }
}
```

关键性能指标：
- token 接收到 DOM 更新 ≤ 16ms（60fps）
- 代码块围栏检测在 O(1) 时间完成
- 长消息（>10,000 字符）不会导致布局抖动
- 内存占用 < 5MB per 活跃流式消息

---

## 八、测试用例

### 8.1 功能测试

#### TC-001：频道消息发送与接收

| 步骤 | 操作 | 预期结果 |
|------|------|---------|
| 1 | 用户 A 在 #general 发送"Hello" | A 的消息立即显示（乐观更新） |
| 2 | 用户 B 已加入 #general | B 在 ≤500ms 内看到 A 的消息 |
| 3 | Agent 已加入 #general | Agent 收到消息事件 |

#### TC-002：Agent 流式响应

| 步骤 | 操作 | 预期结果 |
|------|------|---------|
| 1 | 用户发送 "@代码助手 写一个排序函数" | 代码助手状态变为 `thinking` |
| 2 | 等待 Agent 开始响应 | ≤2 秒内状态变为 `thinking`，开始流式输出 |
| 3 | 观察流式输出 | 文字逐字出现，无卡顿 |
| 4 | 流式输出包含代码块 | 代码块在围栏关闭后完整渲染，带语法高亮 |
| 5 | 流式完成 | 状态变为 `idle`，显示耗时和 token 数 |

#### TC-003：停止生成

| 步骤 | 操作 | 预期结果 |
|------|------|---------|
| 1 | Agent 正在流式输出 | 显示"停止生成"按钮 |
| 2 | 点击"停止生成" | 流式立即停止，已输出内容保留 |
| 3 | 检查 Agent 状态 | Agent 状态回到 `idle` |

#### TC-004：多 Agent 并行流式

| 步骤 | 操作 | 预期结果 |
|------|------|---------|
| 1 | 发送 "@代码助手 @测试Agent 各写一段代码" | 两个 Agent 均收到消息 |
| 2 | 两个 Agent 同时流式输出 | 各自独立渲染，互不干扰 |
| 3 | 两个 Agent 完成 | 各自显示完成状态 |

#### TC-005：文件上传与预览

| 步骤 | 操作 | 预期结果 |
|------|------|---------|
| 1 | 拖拽一张 PNG 图片到输入框 | 显示上传进度条 |
| 2 | 上传完成后发送 | 消息中显示图片缩略图 |
| 3 | 点击缩略图 | 全尺寸预览 |
| 4 | 上传 60MB 文件 | 提示"文件大小超过 50MB 限制" |

#### TC-006：@mention 与通知

| 步骤 | 操作 | 预期结果 |
|------|------|---------|
| 1 | 输入 "@" | 弹出成员选择器 |
| 2 | 输入 "代" | 选择器过滤显示"代码助手" |
| 3 | 选择"代码助手"并发送消息 | Agent 被唤醒并响应 |
| 4 | 被 @mention 的人类用户 | 收到通知提示 |

#### TC-007：消息编辑与删除

| 步骤 | 操作 | 预期结果 |
|------|------|---------|
| 1 | 发送消息后 3 分钟，点击编辑 | 可编辑，显示原始内容 |
| 2 | 修改并保存 | 消息更新，显示"已编辑"标记 |
| 3 | 发送消息后 6 分钟，尝试编辑 | 编辑按钮不可用 |
| 4 | 删除自己的消息 | 消息从列表中移除 |

#### TC-008：Emoji 反应

| 步骤 | 操作 | 预期结果 |
|------|------|---------|
| 1 | 悬停消息，点击 👍 | 消息下方显示 👍 ×1 |
| 2 | 另一用户也点击 👍 | 显示 👍 ×2 |
| 3 | 再次点击 👍 | 取消自己的反应，显示 👍 ×1 |

### 8.2 边界条件测试

| TC# | 场景 | 预期 |
|-----|------|------|
| TC-009 | 发送空消息 | 发送按钮禁用 |
| TC-010 | 发送 10,000 字符消息 | 正常发送和渲染 |
| TC-011 | 发送 100,000 字符消息 | 拒绝，提示超出字符限制 |
| TC-012 | 频道有 50 个成员同时在线 | 消息广播无明显延迟（≤1 秒） |
| TC-013 | WebSocket 断开 5 秒后重连 | 自动重连，补齐断线期间的消息 |
| TC-014 | WebSocket 断开 5 分钟后重连 | 自动重连，通过 REST API 拉取缺失消息 |
| TC-015 | Agent 流式输出中网络断开 | 重连后接续流式或显示已完成的消息 |
| TC-016 | 同时 3 个 Agent 流式输出 | 所有流式渲染正常，页面 FPS ≥ 30 |
| TC-017 | 频道内 10,000 条消息 | 虚拟列表正常滚动，内存 < 100MB |
| TC-018 | 用户不在频道中尝试发消息 | API 返回 403 |
| TC-019 | Agent 执行超时（>60 秒） | 自动终止，显示超时错误 |
| TC-020 | 上传非法文件类型（.exe） | 根据 Workspace 策略拒绝或允许 |

### 8.3 性能测试

| TC# | 场景 | 目标 |
|-----|------|------|
| TC-021 | 消息发送延迟（本地显示） | ≤200ms |
| TC-022 | 消息广播延迟（其他客户端收到） | ≤500ms (P95) |
| TC-023 | Agent 首 token 延迟 | ≤2 秒 |
| TC-024 | 流式渲染帧率 | ≥30 FPS |
| TC-025 | 消息分页加载（50 条） | ≤300ms |
| TC-026 | 频道切换耗时 | ≤500ms（含加载最近消息） |
| TC-027 | WebSocket 重连时间 | ≤3 秒（首次重试） |
| TC-028 | 全文搜索响应时间 | ≤500ms（10 万条消息） |

---

## 九、成功指标

### 9.1 核心指标（North Star）

| 指标 | 定义 | 目标（内测 30 天） |
|------|------|-------------------|
| **DAU/MAU** | 日活 / 月活比率 | ≥60% |
| **人均日消息数** | 每用户每天发送消息数 | ≥15 条 |
| **Agent 对话占比** | 含 Agent 参与的对话 / 总对话 | ≥40% |

### 9.2 体验指标

| 指标 | 定义 | 目标 |
|------|------|------|
| 消息送达延迟 P95 | 发送到其他客户端显示 | ≤500ms |
| Agent 首 token 延迟 P95 | @Agent 到开始流式输出 | ≤3 秒 |
| 流式渲染帧率 | Agent 输出时的渲染帧率 | ≥30 FPS |
| WebSocket 连接稳定性 | 24 小时内无故障断连率 | ≥99.5% |
| 崩溃率 | 页面崩溃 / 总会话 | ≤0.1% |

### 9.3 业务指标

| 指标 | 定义 | 目标 |
|------|------|------|
| Agent 任务触发率 | 通过对话 @Agent 触发的任务数 / 总任务数 | ≥30% |
| Agent 产物采纳率 | 用户采纳（复制/应用/下载）Agent 产物 / 总产物 | ≥50% |
| 频道活跃度 | 有消息的频道数 / 总频道数 | ≥70% |
| 审批响应时间（P1） | Agent 请求审批到人类响应 | ≤5 分钟 |

### 9.4 数据埋点

关键事件：
- `message.sent` — 消息发送（含 sender_type, channel_type, has_attachment, has_mention）
- `agent.triggered` — Agent 被唤醒（含 agent_id, trigger_type: mention/dm）
- `agent.stream.completed` — Agent 流式完成（含 duration, token_count, model）
- `agent.stream.stopped` — 用户中断流式（含 stop_reason, tokens_before_stop）
- `agent.artifact.action` — 产物操作（含 action: copy/apply/download, artifact_type）
- `channel.created` — 频道创建
- `channel.joined` — 加入频道
- `search.performed` — 搜索执行（P1）
- `approval.decided` — 审批决策（P1）

---

## 十、风险与缓解措施

### 10.1 技术风险

| 风险 | 严重度 | 概率 | 缓解措施 |
|------|--------|------|---------|
| **WebSocket 连接在弱网环境下频繁断开** | 高 | 中 | Socket.IO 内置重连机制（指数退避 1s→2s→4s→8s→max30s）；断线期间消息通过 REST API 补齐；本地消息缓存确保断线不丢失已展示内容 |
| **Agent 流式输出与消息列表渲染冲突导致卡顿** | 高 | 中 | 流式渲染使用 requestAnimationFrame 节流；token 缓冲批量更新（每帧最多处理 5 tokens）；消息列表虚拟化 |
| **多 Agent 同时流式输出的渲染性能** | 中 | 中 | 限制同时流式输出的 Agent 数量（默认 ≤3）；超出时排队等待；每个流式消息独立渲染上下文 |
| **Agent 响应超时或异常挂起** | 高 | 高 | 设置 60 秒硬超时；30 秒无新 token 自动判定为挂起并终止；错误状态显示在消息中 |
| **消息排序不一致（时钟偏移/网络延迟）** | 中 | 低 | 服务端统一分配消息时间戳；客户端乐观更新后以服务端时间为准重排序 |
| **大文件上传阻塞消息发送** | 低 | 低 | 文件上传异步进行，完成后生成附件引用再发送消息；上传进度在输入框上方显示 |

### 10.2 产品风险

| 风险 | 严重度 | 概率 | 缓解措施 |
|------|--------|------|---------|
| **Agent 频繁在频道中产生噪音（消息过多）** | 高 | 高 | Agent 响应规则：仅在被 @mention 或 DM 时响应；频道可设置 Agent 静默模式；Agent 消息可折叠 |
| **用户不理解人类消息和 Agent 消息的区别** | 中 | 中 | 视觉上明确区分（背景色 + 图标 + 标签）；新手引导 tooltip |
| **审批流阻塞 Agent 执行效率** | 中 | 中 | 审批超时自动拒绝（可配置）；低风险操作免审批；审批通知优先级最高 |
| **用户对 Agent 产出不信任** | 中 | 中 | 显示 Agent 模型标签、token 数、执行耗时；产物支持 diff 查看；引用源可追溯 |

### 10.3 工程风险

| 风险 | 严重度 | 概率 | 缓解措施 |
|------|--------|------|---------|
| **6 周工期不够完成所有 P0** | 高 | 中 | 严格控制 P0 范围（砍掉复杂度高的次要功能）；优先完成核心路径：频道+消息+Agent 流式 |
| **前后端 WebSocket 协议对接耗时** | 中 | 高 | W1 即定义完整协议文档；使用 TypeScript 共享类型（monorepo shared package） |
| **Agent 运行时通信协议不稳定** | 高 | 中 | W1-2 做 Agent 通信 PoC；定义清晰的 Agent SDK 接口 |

---

## 十一、排期与依赖

### 11.1 详细排期（6 周 P0）

```
周次   前端A              前端B              后端A              后端B
──────────────────────────────────────────────────────────────────────
W1     ChatLayout 框架     消息组件           channels API       WebSocket 服务
       ChannelSidebar     HumanMessage       channel_members    Socket.IO + Redis
       频道列表 UI         AgentMessage       messages API       消息存储 + 分页
                          MessageInput

W2     频道 CRUD UI        Markdown 渲染      DM API             Agent 消息路由
       频道设置页          代码高亮            @mention 解析      BullMQ 任务分发
       成员管理 UI         文件上传组件        文件上传 API       Agent ↔ 平台协议

W3     DM 列表 + 对话页    StreamRenderer     流式回传 API       在线状态 + Redis
       消息分页滚动       流式引擎核心        (SSE/WS 桥接)      Pub/Sub 扇出
       未读角标           token 缓冲逻辑      消息广播逻辑       通知存储

W4     Agent 状态 UI       多 Agent 流式      Agent 状态机        停止生成 API
       状态图标 + 动画     并行渲染           状态推送           超时管理
       AgentIdentity      StopGenerateBar    Agent 元数据存储    错误处理

W5     @mention 选择器     Emoji 反应         通知 API           Agent 产物 API
       通知中心 UI         产物卡片           @mention 通知      agent_artifacts
       输入中指示          消息编辑/删除      消息编辑/删除 API  Emoji 反应 API

W6     集成联调            UI polish          Bug fix            性能调优
       E2E 测试           响应式适配          压力测试           连接管理优化
       Edge case          动画细节            数据迁移脚本        监控 + 日志
──────────────────────────────────────────────────────────────────────
```

### 11.2 依赖关系

| 本模块依赖 | 提供方 | 说明 |
|-----------|--------|------|
| 用户认证（JWT） | 基础设施 / Logto | W1 前必须就绪 |
| Workspace + 成员数据 | M4 团队模块 | 至少需要 workspace_members 表和 API |
| Agent 运行时 | M5 Agent 模块 | Agent 创建 + 启动 + 通信协议 |
| Agent 模型网关 | Agent 基础设施 | 多模型路由 + API key 管理 |
| 数据库 | 基础设施 | PostgreSQL + Redis 实例 |
| 文件存储 | 基础设施 | GCS Bucket + 上传签名 URL |

| 依赖本模块的 | 说明 |
|-------------|------|
| M2 任务模块 | Agent 在对话中执行任务后的结果展示 |
| M5 Agent 模块 | Agent 通过对话接收指令和返回结果 |
| M7 管理后台 | 消息量统计、Agent 对话数据 |

### 11.3 MVP 发布标准（Exit Criteria）

- [ ] 50 人 Workspace 内消息收发延迟 ≤500ms（P95）
- [ ] Agent 流式输出正常工作（≥15 tokens/秒渲染）
- [ ] 多 Agent 同时流式输出无渲染冲突
- [ ] WebSocket 断线自动重连，消息无丢失
- [ ] 所有 P0 功能点通过验收测试
- [ ] 无 P0/P1 级 Bug

---

## 附录：竞品功能对标矩阵

| 功能 | 飞书/Lark | Slack | Teams | Discord | CODE-YI |
|------|----------|-------|-------|---------|---------|
| 频道/群组 | ✅ | ✅ | ✅ | ✅ | ✅ P0 |
| 私聊/DM | ✅ | ✅ | ✅ | ✅ | ✅ P0 |
| Thread 子线程 | ✅ | ✅ | ✅ (2025新增) | ✅ | P2 |
| Forum 频道 | ❌ | ❌ | ❌ | ✅ | 不做 |
| 富文本/Markdown | ✅ | ✅ 部分 | ✅ | ✅ 部分 | ✅ P0 |
| 代码块高亮 | ✅ | ✅ | ✅ | ✅ | ✅ P0 |
| 文件分享 | ✅ | ✅ | ✅ | ✅ | ✅ P0 |
| Emoji 反应 | ✅ | ✅ | ✅ | ✅ | ✅ P0 |
| 消息搜索 | ✅ | ✅ AI语义 | ✅ AI语义 | ✅ 基础 | P1 全文 → P2 语义 |
| AI 摘要 | ❌ | ✅ | ✅ | ✅ (2025) | P2 |
| 消息翻译 | ✅ 内置 | ✅ AI | ✅ Copilot | ✅ (2025) | P2 |
| 在线状态 | ✅ | ✅ | ✅ | ✅ | ✅ P0 |
| 已读回执 | ✅ | ❌ | ✅ | ✅ DM only | P1 DM |
| 消息置顶 | ✅ | ✅ | ✅ | ✅ | P1 |
| 输入中指示 | ✅ | ✅ | ✅ | ✅ | ✅ P0（仅人类） |
| 视频/音频 | ✅ | ✅ Huddles | ✅ | ✅ | ❌ 不做 |
| **Agent 流式响应** | ⚠️ 互动卡片 | ❌ | ⚠️ Copilot 面板 | ❌ | **✅ P0 核心** |
| **Agent 状态指示** | ⚠️ 卡片状态 | ❌ | ❌ | ❌ | **✅ P0 核心** |
| **多 Agent 协作** | ❌ | ❌ | ⚠️ Channel Agent | ❌ | **✅ P0 核心** |
| **对话内审批** | ❌ | ❌ | ❌ | ❌ | **✅ P1** |
| **Agent 产物展示** | ❌ | ❌ | ❌ | ❌ | **✅ P0** |
| **Agent 一等公民** | ❌ Bot | ❌ App | ❌ Copilot | ❌ Bot | **✅ 核心定位** |
| 外部 IM 桥接 | N/A | Slack Connect | 跨租户共享 | ❌ | P2 |
| 工作流自动化 | ✅ 审批流 | ✅ Workflow Builder | ✅ Power Automate | ❌ | 通过 Agent 实现 |
| 跨平台搜索 | ❌ | ✅ (Google/SFDC) | ✅ (M365生态) | ❌ | 不做 |

> **结论：** CODE-YI 在传统 IM 功能上与竞品保持基本对等（P0 覆盖 80%），而在 **Agent 原生体验**上（流式响应、状态指示、多 Agent 协作、产物展示、对话内审批）形成明确的差异化壁垒——这些功能在所有竞品中均为空白或初级阶段。

---

*CODE-YI Module 1: Chat PRD v1.0 · 2026-04-19 · 由 Zylos 基于竞品调研生成*

*下一步：Stephanie 审阅 → 技术评审 → W1 启动开发*
