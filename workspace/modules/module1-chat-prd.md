# CODE-YI Module 1: 对话 (Chat) — 产品需求文档

> **版本:** v1.0  
> **日期:** 2026-04-19  
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
7. [消息可见性与上下文模型](#7-消息可见性与上下文模型)
8. [自动化工作流引擎](#8-自动化工作流引擎)
9. [数据模型](#9-数据模型)
10. [技术方案](#10-技术方案)
11. [Zylos 可复用组件](#11-zylos-可复用组件)
12. [测试用例](#12-测试用例)
13. [成功指标](#13-成功指标)
14. [风险与缓解](#14-风险与缓解)
15. [排期建议](#15-排期建议)

---

## 1. 问题陈述

### 1.1 现有 IM 工具的根本性失败

当前主流团队协作工具（飞书/Lark、Slack、Discord、钉钉）均诞生于"人与人沟通"的范式。它们对 AI Agent 的支持停留在"被动响应 @提及"的层级，无法满足 AI-Native 团队的核心需求：

**飞书/Lark 的致命限制：**
- **Bot 无法看到其他 Bot 的消息**：飞书平台的 `im.message.receive_v1` 事件订阅不会推送来自其他机器人发送的消息。这是平台级设计限制，直接封杀了 Bot↔Bot 自主协作的可能性。
- **自定义机器人只能单向推送**：自定义机器人（Webhook Bot）只能发送通知，无法响应 @提及，无法获取用户/租户信息。
- **3 秒超时响应限制**：应用接收消息后必须在 3 秒内返回 200 响应，否则飞书服务器视为投递失败并重试（5 秒、5 分钟、1 小时、6 小时），不适合需要长时间推理的 AI Agent。
- **群聊上下文缺失**：Bot 默认只接收 @自己的消息，需要额外申请 `im:message.group_msg` 权限才能获取群内全量消息，且频控策略严格。
- **不支持 Bot 间 @提及**：飞书官方插件不支持 bot 之间的 mention 操作，需要开发者自行实现"合成事件"机制绕行。

**Slack 的局限：**
- Bot 需手动检查消息来源以避免无限循环，框架层面默认忽略 bot 消息。
- 3 秒 ACK 超时，否则触发重复调用。
- Bot 间协作需要 `allowBots: true` + `requireMention: true` 的组合配置，体验不自然。

**Discord 的局限：**
- discord.py 等主流框架硬编码忽略 bot 消息（`process_commands` 中 `bot check` 不可配置，标记为 wontfix）。
- 平台禁止伪造 Interaction 事件，bot 无法触发其他 bot 的 slash command。
- 50 bot/服务器的 slash command 上限。

**核心痛点（Stephanie 原话）：** "在飞书里编排一个 PR review，需要手动给系统和 bot 发消息，不确定信息是否正确传递。" —— 这反映的是**所有现有 IM 的结构性缺陷**：它们不是为 AI Agent 之间的自主协作而设计的。

### 1.2 市场机会

- 2025-2026 年，超过 2/3 的 Agentic AI 市场已从单 Agent 转向多 Agent 协同系统（Landbase 报告）
- Gartner 2025 研究显示近 50% 的受访供应商将"AI 编排"视为首要差异化能力
- 但**没有一个主流 IM 产品**从底层架构上原生支持 Agent-to-Agent 通信 —— 这是 CODE-YI 的蓝海

---

## 2. 产品愿景

### 2.1 一句话定位

**CODE-YI 对话模块是全球首个将 Human↔Human、Human↔Bot、Bot↔Bot 三种对话模式作为一等公民（First-Class Citizen）的 AI-Native 协作平台。**

### 2.2 三种对话模式

```
┌─────────────────────────────────────────────────┐
│              CODE-YI 对话系统                      │
├──────────┬──────────────┬───────────────────────┤
│ H↔H      │ H↔Bot        │ Bot↔Bot               │
│ 基础 IM   │ 智能对话      │ 自主工作流             │
│          │              │                       │
│ 文字/语音  │ @Bot 触发任务  │ 代码 Bot → Review Bot  │
│ 文件共享   │ Bot 主动通知   │ 内容 Bot → QA Bot      │
│ 文档协作   │ 上下文感知     │ 24/7 无人值守          │
│ 表情/反应  │ 流式输出       │ 链式任务执行            │
└──────────┴──────────────┴───────────────────────┘
```

### 2.3 核心差异化

| 维度 | 传统 IM | CODE-YI |
|------|---------|---------|
| Bot 消息可见性 | Bot 无法看到其他 Bot 消息 | 全量消息对所有参与者（含 Bot）可见 |
| Bot 地位 | 二等公民，需 @触发 | 一等公民，与人类平级 |
| 对话发起权 | 人→Bot 单向 | 人↔Bot、Bot↔Bot 双向 |
| 工作流 | 手动编排 | 声明式自动链式执行 |
| 上下文 | 片段式，每次 @重置 | 持久化，跨会话保留 |
| 运行模式 | 工作时间响应 | 24/7 自主运行 |

### 2.4 文档协作流

```
开发者在对话中编写 PRD
       ↓
Push 到 GitHub/GitLab（一键操作）
       ↓
ClawMark 嵌入对话流，直接在文档上做行内标注
       ↓
评审意见以消息形式同步到对话
       ↓
修改 → 再推送 → 评审闭环
```

---

## 3. 竞品对标

### 3.1 竞品矩阵

| 维度 | 飞书/Lark | Slack | Discord | Cursor | GitHub Copilot Workspace | **CODE-YI** |
|------|-----------|-------|---------|--------|--------------------------|-------------|
| **H↔H 聊天** | ★★★★★ | ★★★★★ | ★★★★ | - | - | ★★★★ |
| **H↔Bot 对话** | ★★ | ★★★ | ★★ | ★★★★★ | ★★★★ | ★★★★★ |
| **Bot↔Bot 协作** | - | ★ | - | - | ★★ | ★★★★★ |
| **自主工作流** | - | ★ | - | - | ★★★ | ★★★★★ |
| **文档协作** | ★★★★ | ★★ | ★ | ★★★ | ★★★★ | ★★★★ |
| **消息上下文** | ★★ | ★★★ | ★★ | ★★★★★ | ★★★ | ★★★★★ |
| **24/7 无人值守** | - | - | - | - | ★★★ | ★★★★★ |

### 3.2 深度分析

**飞书/Lark：**
- 优势：文档协作生态成熟，UI 体验好，国内市场占有率高
- 劣势：Bot API 是"附加功能"而非核心架构，bot 无法看到彼此消息，事件订阅模型只覆盖人→bot 方向
- 核心缺失：没有原生的多 Agent 编排能力

**Slack：**
- 优势：2025 年推出 Agent Orchestration（Slackbot + Agentforce），支持 MCP 客户端连接 2600+ 应用
- 劣势：编排仍以 Slackbot 为中心枢纽，非真正的 Agent 对等通信；bot 间协作需要复杂配置
- 核心缺失：Agent 间不是直接对话，而是通过 Slackbot 中转路由

**Discord：**
- 优势：WebSocket 架构，天然支持实时通信
- 劣势：框架层面硬编码禁止 bot 间交互，社区/游戏定位不适合企业场景
- 核心缺失：完全不考虑 Agent 协作场景

**Cursor：**
- 优势：Editor 内 AI 对话体验极佳，上下文感知精准
- 劣势：纯 IDE 工具，无团队通信能力，无 Bot↔Bot 场景
- 核心缺失：只有 H↔Bot 单一模式

**GitHub Copilot Workspace：**
- 优势：Coding Agent（异步 PR 生成）、Mission Control（多任务并行管理）、Copilot Spaces（共享上下文容器）
- 劣势：局限在代码工作流，无通用 IM 能力；Coding Agent 冷启动 90+ 秒
- 可借鉴：Issue→Spec→Plan→Code 的 agentic 工作流范式，Mission Control 多 Agent 并行调度

---

## 4. 技术突破点分析

### 4.1 飞书/Lark IM 的人机对话局限（技术研究）

经深度调研，飞书在人机对话场景中的限制源于其**架构设计哲学**：

| 限制项 | 技术根因 | 影响 |
|--------|----------|------|
| Bot 无法接收其他 Bot 消息 | `im.message.receive_v1` 事件过滤器排除 bot 来源 | Bot↔Bot 通信不可能 |
| 3 秒响应超时 | Webhook 同步回调模型 | LLM 推理任务（通常 5-30 秒）无法直接响应 |
| 自定义 Bot 无法接收消息 | Webhook Bot 只有出站能力 | 需升级为应用 Bot 才能参与对话 |
| @all 误触发 Bot | 事件系统未区分 @all 和 @bot | Bot 被广播消息意外唤醒 |
| 群消息权限繁琐 | 需单独申请 `im:message.group_msg` 并审核发布 | 全量上下文获取门槛高 |
| 不支持 Bot 间 @提及 | mention 事件仅处理人→bot 方向 | 需要"合成事件"绕行 |

**社区绕行方案（如 OpenClaw）：**
- Bot Registry（`bot-relay.ts`）：注册所有 Bot 的 OpenID，解析 @mention 标签，创建合成事件触发目标 Bot
- Shared History（`shared-history.ts`）：在应用层维护跨 Bot 聊天记录共享
- 这些绕行方案证明了**需求真实存在**，但也暴露了现有平台的根本性不足

### 4.2 需要的技术突破

#### 突破 1：统一消息总线（Unified Message Bus）

```
所有消息（Human / Bot）
        ↓
  Unified Message Bus（UMB）
        ↓
  ┌─────┬─────┬──────┐
  │ H↔H │ H↔B │ B↔B  │
  │ 路由  │ 路由  │ 路由   │
  └─────┴─────┴──────┘
```

传统 IM 的事件系统按"发送方类型"过滤消息。CODE-YI 需要一个**类型无关的消息总线**：
- 所有消息（不论来源是人还是 Bot）统一进入消息总线
- 由订阅方自行决定是否处理（pull 模式，非 push 过滤模式）
- 消息携带完整元数据（发送方类型、角色、上下文 ID、工作流 ID）

#### 突破 2：Agent 上下文窗口管理

Bot 不是简单的 request-response 节点。每个 Bot 需要持久化的上下文：
- **会话级上下文**：当前对话的完整消息历史
- **Bot 身份上下文**：系统提示词、角色定义、技能列表
- **工作流上下文**：当前任务链的状态、前序 Bot 的输出
- **跨会话记忆**：关键决策、用户偏好、历史经验

关键挑战：LLM 的 context window 有限（4K-200K tokens），需要智能的上下文压缩/选择策略。

#### 突破 3：事件驱动工作流引擎

传统 IM 中的 bot 是"被唤醒执行单次任务"的模式。CODE-YI 需要：
- **声明式工作流定义**：用 YAML/JSON 定义 Bot 链 —— A 完成后触发 B，B 的输出作为 C 的输入
- **状态机管理**：工作流有明确的状态（pending → running → waiting → completed/failed）
- **异常处理**：某个 Bot 失败时的重试、降级、人工介入机制
- **并行执行**：支持 DAG（有向无环图）结构，多个 Bot 可并行工作

#### 突破 4：流式多 Agent 同步输出

当多个 Bot 同时工作时，需要：
- 各 Bot 的思考/输出以流式方式实时展示
- 类似 Cursor 的 "多文件编辑" 体验 —— 用户同时看到多个 Bot 的工作进展
- WebSocket 双工通信支持多通道流式传输

#### 突破 5：消息路由智能化

不是所有消息都需要所有 Bot 看到。需要智能路由层：
- **显式路由**：@mention 指定目标 Bot
- **隐式路由**：根据消息内容、上下文和 Bot 能力自动路由
- **工作流路由**：按工作流定义的链式关系自动传递
- **旁观模式**：Bot 可以"旁听"对话但不响应，只在需要时介入

---

## 5. 用户故事

### 5.1 Human↔Human 基础 IM

#### US-1.1：文字消息
**作为**团队成员，**我希望**能在私聊和群聊中发送文字消息，**以便**与同事实时沟通。
- **AC1**: 消息在 200ms 内送达对方
- **AC2**: 支持 Markdown 格式渲染
- **AC3**: 支持 @提及特定成员
- **AC4**: 支持回复/引用特定消息
- **AC5**: 支持消息编辑（发送后 15 分钟内）和撤回

#### US-1.2：文件与媒体共享
**作为**团队成员，**我希望**能在对话中发送文件、图片和代码片段，**以便**共享工作成果。
- **AC1**: 支持拖拽上传，单文件最大 100MB
- **AC2**: 图片在对话中内联预览
- **AC3**: 代码片段支持语法高亮（自动检测语言）
- **AC4**: 文件支持在线预览（PDF、Office、图片）

#### US-1.3：群聊管理
**作为**团队负责人，**我希望**能创建和管理群聊，**以便**组织团队沟通。
- **AC1**: 支持创建群聊并邀请成员（含 Bot 成员）
- **AC2**: 群聊支持设置名称、头像、描述
- **AC3**: 支持群公告/置顶消息
- **AC4**: 支持成员角色管理（管理员/成员）

#### US-1.4：消息搜索
**作为**团队成员，**我希望**能搜索历史消息，**以便**快速找到之前讨论的内容。
- **AC1**: 支持全文搜索
- **AC2**: 支持按发送者、时间范围、对话筛选
- **AC3**: 搜索结果高亮关键词，点击可跳转到上下文
- **AC4**: 搜索范围覆盖 Human 和 Bot 的全部消息

### 5.2 Human↔Bot 智能对话

#### US-2.1：@Bot 触发任务
**作为**开发者，**我希望**在群聊中 @Bot 分配任务，**以便**让 AI 帮我完成工作。
- **AC1**: @Bot 后 Bot 立即响应确认（<1 秒），然后开始流式输出
- **AC2**: Bot 能访问当前对话的完整上下文（不仅是 @消息本身）
- **AC3**: 长任务时 Bot 发送进度更新
- **AC4**: 任务完成后 Bot 发送结果摘要
- **AC5**: 用户可以中途取消任务

#### US-2.2：Bot 主动通知
**作为**开发者，**我希望** Bot 能主动发消息通知我重要事件，**以便**及时了解系统状态。
- **AC1**: Bot 可在私聊中主动发送消息（不需要人先 @）
- **AC2**: Bot 可在群聊中主动发送消息（如 CI/CD 结果、PR 状态变更）
- **AC3**: 用户可配置通知偏好（哪些事件要通知、通知方式）
- **AC4**: 支持静默小时（Do Not Disturb）

#### US-2.3：多轮对话与上下文保持
**作为**用户，**我希望**与 Bot 的对话能保持上下文，**以便**进行深度讨论。
- **AC1**: Bot 记住当前会话的所有历史消息
- **AC2**: 用户可以引用之前的消息继续讨论
- **AC3**: 用户可以要求 Bot "忘记"某些上下文或"从头开始"
- **AC4**: 上下文超出 LLM 窗口时，系统自动压缩摘要并保留关键信息

#### US-2.4：Bot 流式输出
**作为**用户，**我希望**看到 Bot 逐字输出回复，**以便**实时了解 AI 的思考过程。
- **AC1**: Bot 回复以流式方式逐 token 显示
- **AC2**: 流式输出中用户可以发送新消息（不阻塞输入）
- **AC3**: 支持 "Stop generating" 按钮中断输出
- **AC4**: 代码块在输出完成后自动格式化

### 5.3 Bot↔Bot 自主工作流

#### US-3.1：代码审查自动化循环
**作为**技术负责人，**我希望** Code Bot 和 Review Bot 能自主完成"写代码→提PR→审查→修改→重新提交"的循环，**以便**团队在睡觉时代码仍在推进。
- **AC1**: 用户 @Code-Bot 描述需求后，Code Bot 自主编写代码并创建 PR
- **AC2**: PR 创建后自动触发 Review Bot 进行代码审查
- **AC3**: Review Bot 的修改建议自动传递给 Code Bot
- **AC4**: Code Bot 根据建议修改代码并更新 PR
- **AC5**: 循环持续直到 Review Bot 批准或达到最大迭代次数
- **AC6**: 每次循环的结果摘要发送到对话中，人类可随时介入
- **AC7**: 人类可以在任何阶段设置"需要我确认才能继续"的检查点

#### US-3.2：内容生产流水线
**作为**内容负责人，**我希望**内容创作 Bot 和质检 Bot 能自主运行内容生产流水线，**以便**持续产出高质量内容。
- **AC1**: 内容 Bot 根据主题列表自动生成文章
- **AC2**: QA Bot 自动检查格式、语法、SEO、事实准确性
- **AC3**: 不合格的内容自动退回内容 Bot 修改
- **AC4**: 合格的内容自动推送到发布队列
- **AC5**: 每日生产报告发送到对话中
- **AC6**: 人类可以调整质量阈值、主题优先级

#### US-3.3：Bot 间信息共享
**作为**团队成员，**我希望**多个 Bot 能在群聊中互相看到消息并协作，**以便**利用不同 Bot 的专长。
- **AC1**: 群聊中 Bot A 的输出对 Bot B 完全可见
- **AC2**: Bot B 可以对 Bot A 的输出发表评论或补充
- **AC3**: Bot 之间可以通过 @mention 显式请求协助
- **AC4**: 支持"Bot 讨论线程" —— Bot 之间的深度讨论在子线程中进行，不打扰主对话

### 5.4 混合对话（群组中人+Bot）

#### US-4.1：混合群聊
**作为**项目负责人，**我希望**创建包含人类和 Bot 的项目群，**以便**统一管理项目沟通。
- **AC1**: 群聊成员列表同时显示人类和 Bot 成员，有明确的类型标识
- **AC2**: 人类消息和 Bot 消息在同一时间线上展示
- **AC3**: 支持 @任何成员（人或 Bot）
- **AC4**: Bot 的在线/离线状态实时显示
- **AC5**: 可以设置哪些 Bot 是"主动参与者"（会主动响应对话），哪些是"旁听者"（仅在被 @ 时响应）

#### US-4.2：会议纪要自动化
**作为**项目成员，**我希望**在群聊讨论后自动生成结构化纪要，**以便**追踪行动项。
- **AC1**: @Summary-Bot 生成当前讨论的结构化摘要
- **AC2**: 摘要包含：关键决定、行动项（含负责人和截止日期）、待讨论事项
- **AC3**: 行动项自动关联到任务管理系统
- **AC4**: 摘要发送到对话并同时保存到文档

### 5.5 文档协作（GitHub PR + ClawMark 标注）

#### US-5.1：对话中推送文档到 GitHub
**作为**开发者，**我希望**在对话中编写的 PRD 能一键推送到 GitHub/GitLab，**以便**进入正式的评审流程。
- **AC1**: 在对话中选择文档/消息内容，点击"Push to GitHub"
- **AC2**: 支持选择目标仓库、分支、文件路径
- **AC3**: 推送后自动创建 PR
- **AC4**: PR 链接自动发送到对话中

#### US-5.2：ClawMark 行内标注
**作为**评审者，**我希望**在对话流中直接对文档进行行内标注，**以便**高效完成评审。
- **AC1**: 文档在对话中以可标注模式嵌入展示
- **AC2**: 支持选中文字后添加批注
- **AC3**: 批注以消息形式同步到对话时间线
- **AC4**: 文档作者收到标注通知
- **AC5**: 支持标注状态管理（待处理/已解决）

#### US-5.3：评审闭环
**作为**文档作者，**我希望**评审意见和修改形成闭环，**以便**高效完成文档迭代。
- **AC1**: 评审意见逐条列出，每条有"处理"按钮
- **AC2**: 修改后重新推送自动更新 PR
- **AC3**: ClawMark 自动标记已解决的批注
- **AC4**: 所有批注解决后发送"评审完成"通知

---

## 6. 功能拆分

### 6.1 P0 — 核心功能（MVP 必备）

#### F-P0-01：统一消息系统
- 文字消息发送/接收（H↔H, H↔Bot）
- Markdown 渲染
- @mention（人和 Bot）
- 消息回复/引用
- 文件/图片上传与预览
- 消息编辑/撤回

#### F-P0-02：对话管理
- 私聊（H↔H, H↔Bot, Bot↔Bot）
- 群聊创建/管理
- 成员管理（人类和 Bot）
- 消息已读/未读标记
- 对话列表排序（按时间/置顶）

#### F-P0-03：Bot 运行时框架
- Bot 注册/注销
- Bot 身份（名称、头像、角色描述）
- Bot 消息发送/接收 API
- Bot 健康状态检测
- Bot 权限管理

#### F-P0-04：消息可见性引擎
- 统一消息总线（UMB）—— 所有消息不论来源统一投递
- 订阅机制 —— Bot 自主订阅感兴趣的对话/消息类型
- 消息元数据（发送方类型、角色、时间戳、上下文 ID）
- 可见性策略配置（全量可见 / 仅 @时可见 / 旁听模式）

#### F-P0-05：流式输出
- WebSocket 连接管理
- Bot 回复流式传输
- 多 Bot 同时输出时的 UI 分流
- 输出中断（Stop generating）

#### F-P0-06：上下文管理
- 会话级消息历史存储
- 上下文窗口自动管理（压缩/摘要）
- Bot 系统提示词配置
- 跨消息上下文传递

### 6.2 P1 — 重要功能（第二阶段）

#### F-P1-01：Bot↔Bot 自主对话
- Bot 间直接消息
- Bot 间 @mention
- Bot 对其他 Bot 输出的可见性（全量）
- 迭代循环上限与退出条件

#### F-P1-02：工作流引擎
- 工作流定义（YAML 格式）
- 任务链自动执行
- 工作流状态管理（状态机）
- 异常处理与重试
- 人工检查点（Human-in-the-Loop）

#### F-P1-03：GitHub/GitLab 集成
- 对话内容 Push 到仓库
- PR 创建与状态同步
- Commit/PR 事件回流到对话
- GitHub Actions 状态通知

#### F-P1-04：消息搜索
- 全文搜索引擎
- 高级过滤（发送者、时间、类型）
- 搜索结果上下文预览
- Bot 消息搜索（按 Bot 类型筛选）

#### F-P1-05：通知与偏好
- 通知偏好设置（按对话、按事件类型）
- 免打扰时段
- 桌面/移动推送
- 未读消息聚合

#### F-P1-06：线程（Thread）
- 消息回复线程
- Bot 讨论子线程
- 线程内的独立上下文
- 线程摘要折叠

### 6.3 P2 — 增强功能（第三阶段）

#### F-P2-01：ClawMark 文档标注
- 文档嵌入对话展示
- 行内标注/批注
- 标注状态管理
- 评审闭环工作流

#### F-P2-02：语音/视频消息
- 语音消息录制/播放
- 语音转文字（ASR）
- 短视频消息

#### F-P2-03：Bot Marketplace
- Bot 模板库
- 第三方 Bot 接入
- Bot 配置向导
- Bot 性能监控面板

#### F-P2-04：AI 会议纪要
- 自动讨论摘要
- 行动项提取
- 决策记录
- 任务系统集成

#### F-P2-05：多语言实时翻译
- 消息自动翻译
- 用户语言偏好设置
- Bot 多语言输出

#### F-P2-06：高级工作流
- DAG 并行执行
- 条件分支
- 工作流模板市场
- 工作流执行分析（耗时、成功率）

---

## 7. 消息可见性与上下文模型

### 7.1 消息可见性架构

这是 CODE-YI 与所有现有 IM 的**根本性差异**。

#### 7.1.1 统一消息总线（UMB）

```
                 ┌──────────────────────┐
                 │  Unified Message Bus  │
                 │    (Redis Streams)    │
                 └──────┬───────────────┘
                        │
        ┌───────────────┼───────────────┐
        ↓               ↓               ↓
   ┌─────────┐    ┌─────────┐    ┌─────────┐
   │ H↔H     │    │ H↔Bot   │    │ Bot↔Bot │
   │ Router   │    │ Router   │    │ Router   │
   └─────────┘    └─────────┘    └─────────┘
        ↓               ↓               ↓
   ┌─────────┐    ┌─────────┐    ┌─────────┐
   │ User A  │    │ Bot-X   │    │ Bot-Y   │
   │ User B  │    │ User C  │    │ Bot-Z   │
   └─────────┘    └─────────┘    └─────────┘
```

**核心原则**：消息进入 UMB 时**不做来源类型过滤**。所有消息（人类发的、Bot 发的）都以相同格式进入总线。

#### 7.1.2 可见性策略

每个对话参与者（人或 Bot）有独立的可见性策略：

| 策略 | 说明 | 适用场景 |
|------|------|----------|
| `full` | 看到对话中的所有消息 | 项目群中的核心 Bot |
| `mention_only` | 只看到 @自己的消息 + 系统通知 | 偶尔被召唤的工具型 Bot |
| `observer` | 看到所有消息但默认不响应，由 AI 判断是否需要介入 | 监控型 Bot |
| `workflow` | 只看到工作流引擎分发的消息 | 工作流中的专项 Bot |

```json
{
  "conversation_id": "conv_xxx",
  "participant": {
    "id": "bot_review",
    "type": "bot",
    "visibility": "full",
    "auto_respond": false,
    "respond_triggers": ["@review-bot", "workflow:code-review"]
  }
}
```

#### 7.1.3 消息格式

```json
{
  "id": "msg_20260419_abc123",
  "conversation_id": "conv_project_alpha",
  "sender": {
    "id": "user_stephanie",
    "type": "human",
    "display_name": "Stephanie",
    "avatar": "https://..."
  },
  "content": {
    "type": "text",
    "body": "@code-bot 请实现用户登录模块",
    "format": "markdown",
    "mentions": [
      { "id": "bot_code", "type": "bot", "offset": 0, "length": 9 }
    ]
  },
  "context": {
    "reply_to": null,
    "thread_id": null,
    "workflow_id": null
  },
  "metadata": {
    "timestamp": "2026-04-19T15:30:00Z",
    "edited": false,
    "visibility": "all"
  }
}
```

### 7.2 上下文管理模型

#### 7.2.1 三层上下文架构

```
┌───────────────────────────────────────┐
│  Layer 3: 跨会话记忆（Long-term Memory）│
│  - 用户偏好、历史决策、项目知识          │
│  - 存储: 向量数据库 + 结构化存储         │
│  - 加载: 按需检索                       │
├───────────────────────────────────────┤
│  Layer 2: 会话上下文（Session Context）  │
│  - 当前对话的消息历史                    │
│  - 存储: PostgreSQL + Redis 缓存        │
│  - 策略: 滑动窗口 + 摘要压缩            │
├───────────────────────────────────────┤
│  Layer 1: 即时上下文（Immediate Context）│
│  - Bot 系统提示词 + 当前任务描述         │
│  - 工作流上下文（前序 Bot 输出）          │
│  - 存储: 内存                           │
└───────────────────────────────────────┘
```

#### 7.2.2 上下文窗口管理策略

```
总 Context Window = System Prompt + Long-term Memory + Session History + Current Task

分配策略（以 128K token 模型为例）：
- System Prompt:           ~2K tokens（固定）
- Long-term Memory:        ~8K tokens（RAG 检索 top-K）
- Session History:        ~80K tokens（滑动窗口 + 摘要）
  - 最近 N 条消息: 完整保留
  - 更早的消息:     AI 摘要压缩（10:1 压缩比）
- Current Task:           ~30K tokens（当前输入 + 工作流上下文）
- 输出预留:               ~8K tokens
```

#### 7.2.3 Bot 上下文隔离

在群聊中，每个 Bot 有独立的上下文视图：

```
群聊消息流: [M1, M2, M3, M4, M5, M6, M7, M8, ...]

Bot-Code 的上下文:
  visibility=full → 看到全部消息
  实际送入 LLM 的上下文: System Prompt + [M1..M8 的摘要/完整内容]

Bot-QA 的上下文:
  visibility=mention_only → 只看到 @qa-bot 的消息
  实际送入 LLM 的上下文: System Prompt + [M3(@qa), M7(@qa)]

Bot-Monitor 的上下文:
  visibility=observer → 看到全部但只在触发条件满足时响应
  触发条件: 消息中包含 "error"/"failed"/"异常" 等关键词
```

---

## 8. 自动化工作流引擎

### 8.1 设计理念

工作流引擎是 CODE-YI 实现"24/7 无人值守"的核心。它不是一个独立的 workflow 系统，而是**深度嵌入对话系统**的执行引擎。

### 8.2 工作流定义

```yaml
# 代码审查自动循环工作流
workflow:
  id: "wf_code_review_loop"
  name: "代码审查自动循环"
  trigger:
    type: "mention"
    bot: "code-bot"
    pattern: "请实现.*"
  
  max_iterations: 5
  timeout: "4h"
  
  steps:
    - id: "write_code"
      bot: "code-bot"
      action: "generate_code"
      input: "{{trigger.message}}"
      output_to: "code_output"
    
    - id: "create_pr"
      bot: "code-bot"
      action: "create_github_pr"
      input: "{{code_output}}"
      output_to: "pr_url"
    
    - id: "review"
      bot: "review-bot"
      action: "review_code"
      input: "{{pr_url}}"
      output_to: "review_result"
      on_approve: "notify_complete"
      on_reject: "revise_code"
    
    - id: "revise_code"
      bot: "code-bot"
      action: "revise_code"
      input:
        original: "{{code_output}}"
        feedback: "{{review_result}}"
      output_to: "code_output"
      next: "create_pr"  # 回到创建 PR 步骤
    
    - id: "notify_complete"
      action: "send_message"
      to: "{{trigger.conversation}}"
      content: "代码审查通过！PR: {{pr_url}}"

  on_max_iterations:
    action: "send_message"
    to: "{{trigger.conversation}}"
    content: "已达到最大迭代次数({{max_iterations}})，请人工介入审查。PR: {{pr_url}}"
  
  on_error:
    action: "send_message"
    to: "{{trigger.conversation}}"
    content: "工作流执行异常: {{error.message}}，已暂停等待人工处理。"

  checkpoints:
    - after: "create_pr"
      condition: "{{trigger.user.preference.require_approval}}"
      message: "PR 已创建: {{pr_url}}，是否继续自动审查？"
```

### 8.3 工作流状态机

```
                    trigger
                      │
                      ↓
               ┌──────────┐
               │  PENDING  │
               └─────┬────┘
                     │ start
                     ↓
               ┌──────────┐     timeout/error
               │  RUNNING  │─────────────────┐
               └─────┬────┘                  │
                     │                       │
            ┌────────┼────────┐              │
            ↓        ↓        ↓              ↓
      ┌──────────┐ ┌────┐ ┌──────┐  ┌──────────┐
      │ WAITING  │ │LOOP│ │PAUSED│  │  FAILED   │
      │(人工确认) │ │    │ │(手动)│  │           │
      └────┬─────┘ └──┬─┘ └──┬───┘  └──────────┘
           │ approve   │loop  │resume
           │          ↓      │
           └──→ RUNNING ←────┘
                  │
                  │ complete
                  ↓
            ┌──────────┐
            │ COMPLETED │
            └──────────┘
```

### 8.4 内容生产流水线示例

```yaml
workflow:
  id: "wf_content_pipeline"
  name: "内容生产流水线"
  trigger:
    type: "schedule"
    cron: "0 9 * * *"  # 每天早上 9 点触发
  
  steps:
    - id: "select_topic"
      bot: "content-planner"
      action: "select_next_topic"
      input: "从主题库中选择下一个待创作主题"
      output_to: "topic"
    
    - id: "write_article"
      bot: "content-writer"
      action: "write_article"
      input: "{{topic}}"
      output_to: "draft"
    
    - id: "quality_check"
      bot: "qa-bot"
      action: "review_content"
      input: "{{draft}}"
      checks:
        - grammar
        - formatting
        - seo
        - fact_accuracy
      output_to: "qa_result"
      on_pass: "publish"
      on_fail: "revise"
    
    - id: "revise"
      bot: "content-writer"
      action: "revise_article"
      input:
        draft: "{{draft}}"
        feedback: "{{qa_result}}"
      output_to: "draft"
      next: "quality_check"
    
    - id: "publish"
      bot: "publisher-bot"
      action: "queue_for_publish"
      input: "{{draft}}"
  
  reporting:
    daily_summary:
      to: "conv_content_team"
      at: "18:00"
      include:
        - articles_produced
        - revision_counts
        - quality_scores
```

### 8.5 人工介入机制

工作流不是完全黑盒的。设计三种人工介入方式：

1. **检查点（Checkpoint）**：在关键步骤后暂停，等待人工确认
2. **实时干预（Interrupt）**：人类随时发送 "暂停/停止/修改" 指令
3. **旁观模式（Watch）**：工作流每个步骤的输入输出都实时同步到对话，人类可以随时看到进展

```
对话时间线：

[09:00] Bot Content-Planner: 今日主题选定 - "多 Agent 协作架构指南"
[09:01] Bot Content-Writer: 开始撰写文章...
[09:15] Bot Content-Writer: 初稿完成（3200 字），提交质检
[09:16] Bot QA-Bot: 质检进行中...
[09:17] Bot QA-Bot: 发现 2 个问题：
         1. SEO 标题缺失
         2. 第三段数据引用需要更新
[09:17] Bot Content-Writer: 收到，正在修改...
[09:20] Bot Content-Writer: 修改完成，重新提交
[09:21] Bot QA-Bot: 质检通过
[09:21] Bot Publisher-Bot: 已加入发布队列，预计 10:00 发布
[10:30] Stephanie: 不错，明天的主题换成"AI 对话系统设计"
[10:30] Bot Content-Planner: 收到，已更新明日主题为"AI 对话系统设计"
```

---

## 9. 数据模型

### 9.1 核心实体关系

```
┌────────────┐    ┌─────────────────┐    ┌────────────┐
│   users    │    │  conversations  │    │    bots    │
├────────────┤    ├─────────────────┤    ├────────────┤
│ id         │    │ id              │    │ id         │
│ name       │──┐ │ type (dm/group) │ ┌──│ name       │
│ email      │  │ │ title           │ │  │ avatar_url │
│ avatar_url │  │ │ created_at      │ │  │ role       │
│ status     │  │ │ updated_at      │ │  │ system_prompt│
│ created_at │  │ │ metadata        │ │  │ model      │
└────────────┘  │ └─────────────────┘ │  │ status     │
                │         │           │  │ config     │
                │         │           │  │ created_at │
                ↓         ↓           │  └────────────┘
        ┌──────────────────────────┐  │
        │  conversation_members    │  │
        ├──────────────────────────┤  │
        │ conversation_id          │  │
        │ member_id                │──┘
        │ member_type (human/bot)  │
        │ visibility_policy        │
        │ role (admin/member)      │
        │ joined_at                │
        └──────────────────────────┘
```

### 9.2 表结构定义

#### users（用户表）
```sql
CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(100) NOT NULL,
    email           VARCHAR(255) UNIQUE NOT NULL,
    avatar_url      TEXT,
    status          VARCHAR(20) DEFAULT 'active', -- active/inactive/banned
    preferences     JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);
```

#### bots（Bot 表）
```sql
CREATE TABLE bots (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(100) NOT NULL,
    display_name    VARCHAR(100),
    avatar_url      TEXT,
    role_description TEXT,              -- "代码审查专家"
    system_prompt   TEXT NOT NULL,      -- Bot 的系统提示词
    model           VARCHAR(50),        -- "claude-opus-4-6" / "gpt-4o"
    capabilities    JSONB DEFAULT '[]', -- ["code_review", "code_generation"]
    config          JSONB DEFAULT '{}', -- Bot 特定配置
    status          VARCHAR(20) DEFAULT 'active',
    health          VARCHAR(20) DEFAULT 'unknown', -- healthy/degraded/down/unknown
    owner_id        UUID REFERENCES users(id),
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);
```

#### conversations（对话表）
```sql
CREATE TABLE conversations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type            VARCHAR(20) NOT NULL, -- 'dm', 'group', 'bot_dm', 'bot_group'
    title           VARCHAR(255),
    description     TEXT,
    avatar_url      TEXT,
    metadata        JSONB DEFAULT '{}',
    created_by      UUID NOT NULL,       -- user_id 或 bot_id
    created_by_type VARCHAR(10) NOT NULL, -- 'human' / 'bot'
    pinned_message_id UUID,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);
```

#### conversation_members（对话成员表）
```sql
CREATE TABLE conversation_members (
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    member_id       UUID NOT NULL,
    member_type     VARCHAR(10) NOT NULL, -- 'human' / 'bot'
    role            VARCHAR(20) DEFAULT 'member', -- 'admin' / 'member'
    visibility      VARCHAR(20) DEFAULT 'full',   -- 'full'/'mention_only'/'observer'/'workflow'
    auto_respond    BOOLEAN DEFAULT false,
    respond_triggers JSONB DEFAULT '[]',
    mute_until      TIMESTAMPTZ,
    joined_at       TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (conversation_id, member_id, member_type)
);
```

#### messages（消息表）
```sql
CREATE TABLE messages (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id       UUID NOT NULL,
    sender_type     VARCHAR(10) NOT NULL, -- 'human' / 'bot' / 'system'
    content_type    VARCHAR(20) NOT NULL, -- 'text'/'image'/'file'/'code'/'card'/'workflow_event'
    content         JSONB NOT NULL,
    -- content 结构:
    -- { "body": "...", "format": "markdown", "mentions": [...], "attachments": [...] }
    reply_to        UUID REFERENCES messages(id),
    thread_id       UUID,                -- 所属线程（如果是线程回复）
    workflow_id     UUID,                -- 关联的工作流实例
    workflow_step   VARCHAR(100),        -- 工作流步骤 ID
    edited_at       TIMESTAMPTZ,
    deleted_at      TIMESTAMPTZ,         -- 软删除
    metadata        JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at);
CREATE INDEX idx_messages_sender ON messages(sender_id, sender_type);
CREATE INDEX idx_messages_thread ON messages(thread_id) WHERE thread_id IS NOT NULL;
CREATE INDEX idx_messages_workflow ON messages(workflow_id) WHERE workflow_id IS NOT NULL;
CREATE INDEX idx_messages_search ON messages USING gin(content jsonb_path_ops);
```

#### workflows（工作流定义表）
```sql
CREATE TABLE workflows (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(255) NOT NULL,
    description     TEXT,
    definition      JSONB NOT NULL,      -- 工作流 YAML 转 JSON 存储
    trigger_config  JSONB NOT NULL,      -- 触发条件配置
    owner_id        UUID REFERENCES users(id),
    status          VARCHAR(20) DEFAULT 'active', -- active/paused/archived
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);
```

#### workflow_instances（工作流执行实例表）
```sql
CREATE TABLE workflow_instances (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id     UUID REFERENCES workflows(id),
    conversation_id UUID REFERENCES conversations(id),
    trigger_message_id UUID REFERENCES messages(id),
    state           VARCHAR(20) NOT NULL DEFAULT 'pending',
    -- pending/running/waiting/paused/completed/failed
    current_step    VARCHAR(100),
    iteration       INTEGER DEFAULT 0,
    max_iterations  INTEGER DEFAULT 10,
    context         JSONB DEFAULT '{}',  -- 工作流运行时上下文（变量绑定）
    started_at      TIMESTAMPTZ,
    completed_at    TIMESTAMPTZ,
    error           JSONB,               -- 错误信息
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);
```

#### workflow_step_logs（工作流步骤执行日志）
```sql
CREATE TABLE workflow_step_logs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    instance_id     UUID REFERENCES workflow_instances(id) ON DELETE CASCADE,
    step_id         VARCHAR(100) NOT NULL,
    bot_id          UUID REFERENCES bots(id),
    state           VARCHAR(20) NOT NULL, -- pending/running/completed/failed/skipped
    input           JSONB,
    output          JSONB,
    error           JSONB,
    duration_ms     INTEGER,
    started_at      TIMESTAMPTZ,
    completed_at    TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);
```

#### bot_context（Bot 上下文存储）
```sql
CREATE TABLE bot_context (
    bot_id          UUID REFERENCES bots(id),
    conversation_id UUID REFERENCES conversations(id),
    context_type    VARCHAR(20) NOT NULL, -- 'session'/'memory'/'workflow'
    content         JSONB NOT NULL,
    token_count     INTEGER,
    expires_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (bot_id, conversation_id, context_type)
);
```

#### attachments（附件表）
```sql
CREATE TABLE attachments (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id      UUID REFERENCES messages(id) ON DELETE CASCADE,
    file_name       VARCHAR(500) NOT NULL,
    file_type       VARCHAR(100),
    file_size       BIGINT,
    storage_url     TEXT NOT NULL,       -- S3/MinIO URL
    thumbnail_url   TEXT,
    metadata        JSONB DEFAULT '{}',
    created_at      TIMESTAMPTZ DEFAULT NOW()
);
```

#### annotations（文档标注表 - ClawMark）
```sql
CREATE TABLE annotations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_url    TEXT NOT NULL,       -- GitHub 文件 URL
    conversation_id UUID REFERENCES conversations(id),
    author_id       UUID NOT NULL,
    author_type     VARCHAR(10) NOT NULL,
    line_start      INTEGER,
    line_end        INTEGER,
    selected_text   TEXT,
    comment         TEXT NOT NULL,
    status          VARCHAR(20) DEFAULT 'open', -- open/resolved/wontfix
    resolved_by     UUID,
    message_id      UUID REFERENCES messages(id), -- 关联的对话消息
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);
```

### 9.3 实体关系图

```
users ─────1:N────→ conversation_members ←────N:1──── conversations
bots ──────1:N────→ conversation_members              │
                                                      │
users ─────1:N────→ messages ←────────────N:1─────────┘
bots ──────1:N────→ messages
                    │
                    ├────1:N────→ attachments
                    ├────1:1────→ messages (reply_to - self ref)
                    └────N:1────→ workflow_instances

workflows ──1:N───→ workflow_instances ──1:N──→ workflow_step_logs
                                                │
                                                └────→ bots

bots ──────1:N────→ bot_context ←─────────N:1──── conversations
messages ──1:N────→ annotations
```

---

## 10. 技术方案

### 10.1 总体架构

```
┌─────────────────────────────────────────────────────────────────┐
│                          客户端层                                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────┐    │
│  │ Web App  │  │ Desktop  │  │ Mobile   │  │ Bot SDK/CLI  │    │
│  │ (React)  │  │ (Electron│  │ (React   │  │ (Node/Python)│    │
│  │          │  │  /Tauri) │  │  Native) │  │              │    │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └──────┬───────┘    │
│       │              │              │               │           │
│       └──────────────┴──────────────┴───────────────┘           │
│                          │  WebSocket + REST                    │
└──────────────────────────┼──────────────────────────────────────┘
                           │
┌──────────────────────────┼──────────────────────────────────────┐
│                     API Gateway 层                              │
│  ┌───────────────────────────────────────────────────────┐      │
│  │                 API Gateway (Kong/Traefik)             │      │
│  │  - 认证/鉴权 (JWT + OAuth2)                            │      │
│  │  - 限流                                                │      │
│  │  - WebSocket 升级                                      │      │
│  │  - Bot API Key 验证                                    │      │
│  └────┬─────────────┬─────────────┬──────────────────────┘      │
│       │             │             │                              │
└───────┼─────────────┼─────────────┼──────────────────────────────┘
        │             │             │
┌───────┼─────────────┼─────────────┼──────────────────────────────┐
│       │        服务层             │                               │
│  ┌────┴────┐  ┌─────┴─────┐  ┌───┴──────┐  ┌──────────────┐    │
│  │ Chat    │  │ Message   │  │ Workflow  │  │ Bot Runtime  │    │
│  │ Service │  │ Router    │  │ Engine    │  │ Manager      │    │
│  │         │  │ (UMB)     │  │          │  │              │    │
│  │- 对话CRUD│  │- 消息投递   │  │- 状态机   │  │- Bot 注册    │    │
│  │- 成员管理│  │- 可见性过滤 │  │- 步骤执行 │  │- 健康检查    │    │
│  │- 权限    │  │- 流式分发   │  │- 错误处理 │  │- 上下文管理  │    │
│  └────┬────┘  └─────┬─────┘  └───┬──────┘  └──────┬───────┘    │
│       │             │            │                 │            │
│  ┌────┴─────────────┴────────────┴─────────────────┴───────┐    │
│  │                   Event Bus (Redis Streams)              │    │
│  └─────────────────────────────────────────────────────────┘    │
│       │             │            │                 │            │
│  ┌────┴────┐  ┌─────┴─────┐  ┌──┴────────┐  ┌────┴───────┐    │
│  │ Search  │  │ File      │  │ GitHub    │  │ Notification│   │
│  │ Service │  │ Service   │  │ Integration│ │ Service     │   │
│  │(MeiliS.)│  │(S3/MinIO) │  │ Service   │  │(Push/Email)│    │
│  └─────────┘  └───────────┘  └───────────┘  └────────────┘    │
└────────────────────────────────────────────────────────────────┘
        │             │            │                 │
┌───────┼─────────────┼────────────┼─────────────────┼────────────┐
│       │         数据层            │                 │            │
│  ┌────┴────┐  ┌─────┴─────┐  ┌──┴──────┐  ┌──────┴─────┐      │
│  │ Postgres │  │   Redis   │  │  MinIO  │  │ MeiliSearch│      │
│  │ (主库)   │  │ (缓存+    │  │ (文件   │  │ (全文搜索) │      │
│  │         │  │  消息总线)  │  │  存储)  │  │           │      │
│  └─────────┘  └───────────┘  └─────────┘  └───────────┘      │
└────────────────────────────────────────────────────────────────┘
```

### 10.2 消息路由详细设计

#### 10.2.1 消息流转

```
发送方 (Human/Bot)
     │
     ↓ REST API / WebSocket
┌──────────────────┐
│  Message Router   │
│  (UMB Core)       │
├──────────────────┤
│ 1. 验证消息格式    │
│ 2. 鉴权检查       │
│ 3. 写入 PostgreSQL │
│ 4. 发布到 Redis    │
│    Streams        │
└────────┬─────────┘
         │
         ↓ Redis Streams
┌──────────────────────────────────────┐
│     消息分发器 (Message Dispatcher)    │
├──────────────────────────────────────┤
│                                      │
│  对每个订阅者 (conversation_member):   │
│  ┌────────────────────────────────┐  │
│  │ 1. 检查可见性策略 (visibility)   │  │
│  │ 2. 检查免打扰状态 (mute)        │  │
│  │ 3. 匹配触发条件 (triggers)       │  │
│  │ 4. 决定投递方式:                 │  │
│  │    - Human → WebSocket push     │  │
│  │    - Bot → Bot Runtime Queue    │  │
│  │    - Workflow → Workflow Engine  │  │
│  └────────────────────────────────┘  │
│                                      │
└──────────────────────────────────────┘
```

#### 10.2.2 WebSocket 连接管理

```javascript
// WebSocket 连接架构
// 每个客户端维护一个 WebSocket 连接
// 服务端维护 user/bot → connection 的映射

// 消息通道 (Channels):
// ws.subscribe('conversation:{conv_id}')    -- 对话消息
// ws.subscribe('typing:{conv_id}')          -- 正在输入状态
// ws.subscribe('stream:{msg_id}')           -- Bot 流式输出
// ws.subscribe('workflow:{wf_instance_id}') -- 工作流状态更新
// ws.subscribe('presence')                  -- 在线状态

// Bot 流式输出协议:
// 1. Bot Runtime 开始生成
// 2. 创建 stream channel: stream:{msg_id}
// 3. 逐 token 发送: { type: 'stream_chunk', msg_id, chunk, index }
// 4. 完成: { type: 'stream_end', msg_id, full_content }
// 5. 错误: { type: 'stream_error', msg_id, error }
```

#### 10.2.3 Bot Runtime 架构

```
┌──────────────────────────────────────────┐
│           Bot Runtime Manager             │
├──────────────────────────────────────────┤
│                                          │
│  ┌──────────────┐  ┌──────────────┐      │
│  │ Bot Instance │  │ Bot Instance │      │
│  │ (Code-Bot)   │  │ (Review-Bot) │ ...  │
│  ├──────────────┤  ├──────────────┤      │
│  │ LLM Client   │  │ LLM Client   │      │
│  │ Tool Runner   │  │ Tool Runner   │      │
│  │ Context Mgr   │  │ Context Mgr   │      │
│  │ State Store   │  │ State Store   │      │
│  └──────────────┘  └──────────────┘      │
│                                          │
│  ┌──────────────────────────────────┐    │
│  │     Shared Components             │    │
│  │  - LLM Gateway (multi-provider)   │    │
│  │  - Tool Registry                  │    │
│  │  - Memory Store (Vector DB)       │    │
│  │  - Metrics Collector              │    │
│  └──────────────────────────────────┘    │
│                                          │
└──────────────────────────────────────────┘
```

每个 Bot Instance 包含：
- **LLM Client**：对接 Claude/GPT/Gemini 等模型的统一客户端
- **Tool Runner**：执行 Bot 的工具（代码执行、API 调用、文件操作等）
- **Context Manager**：管理三层上下文（即时/会话/长期）
- **State Store**：Bot 的运行时状态

### 10.3 工作流引擎详细设计

```
┌──────────────────────────────────────────────────┐
│              Workflow Engine                       │
├──────────────────────────────────────────────────┤
│                                                  │
│  ┌────────────┐    ┌─────────────┐               │
│  │ Trigger    │    │ Workflow    │               │
│  │ Evaluator  │───→│ Scheduler  │               │
│  │            │    │            │               │
│  │ - mention  │    │ - queue    │               │
│  │ - schedule │    │ - priority │               │
│  │ - event    │    │ - timeout  │               │
│  │ - webhook  │    │            │               │
│  └────────────┘    └──────┬─────┘               │
│                           │                      │
│                    ┌──────↓──────┐               │
│                    │   Step      │               │
│                    │   Executor  │               │
│                    ├─────────────┤               │
│                    │ 1. 加载步骤  │               │
│                    │ 2. 解析输入  │               │
│                    │ 3. 调用 Bot  │               │
│                    │ 4. 等待输出  │               │
│                    │ 5. 评估条件  │               │
│                    │ 6. 路由下一步│               │
│                    └──────┬──────┘               │
│                           │                      │
│                    ┌──────↓──────┐               │
│                    │   State     │               │
│                    │   Machine   │               │
│                    │             │               │
│                    │ - 状态转换    │               │
│                    │ - 持久化      │               │
│                    │ - 恢复/重试   │               │
│                    └─────────────┘               │
│                                                  │
└──────────────────────────────────────────────────┘
```

### 10.4 技术选型

| 组件 | 选型 | 理由 |
|------|------|------|
| **后端语言** | TypeScript (Node.js) / Rust (性能关键路径) | TS 开发效率高；Rust 用于消息路由等热路径 |
| **API 框架** | Hono / Fastify | 高性能，原生支持 WebSocket |
| **数据库** | PostgreSQL 16 | JSONB 支持、全文搜索、可靠性 |
| **缓存/消息总线** | Redis 7 (Streams) | 消息总线 + 缓存 + pub/sub + 流式传输 |
| **文件存储** | MinIO (兼容 S3) | 自托管、高性能对象存储 |
| **全文搜索** | MeiliSearch | 轻量、快速、中文支持好 |
| **WebSocket** | ws (Node) / uWebSockets | 高性能 WebSocket 服务端 |
| **工作流引擎** | 自研 (基于 Redis Streams + PostgreSQL) | 深度集成对话系统需要自研 |
| **LLM Gateway** | LiteLLM / 自研 | 统一多模型调用接口 |
| **向量数据库** | Qdrant | 高性能相似性搜索，用于长期记忆 |
| **前端** | React + TailwindCSS | 组件生态丰富，适合复杂 IM UI |
| **移动端** | React Native | 复用 Web 组件逻辑 |
| **部署** | Docker + Kubernetes | 容器化部署，Bot 实例可弹性伸缩 |

### 10.5 API 设计概要

#### 消息 API
```
POST   /api/v1/messages                    # 发送消息
GET    /api/v1/conversations/{id}/messages  # 获取消息列表
PATCH  /api/v1/messages/{id}               # 编辑消息
DELETE /api/v1/messages/{id}               # 撤回消息
POST   /api/v1/messages/{id}/reactions     # 添加表情反应
```

#### 对话 API
```
POST   /api/v1/conversations               # 创建对话
GET    /api/v1/conversations                # 获取对话列表
GET    /api/v1/conversations/{id}           # 获取对话详情
PATCH  /api/v1/conversations/{id}           # 更新对话设置
POST   /api/v1/conversations/{id}/members   # 添加成员
DELETE /api/v1/conversations/{id}/members/{mid} # 移除成员
```

#### Bot API
```
POST   /api/v1/bots                        # 注册 Bot
GET    /api/v1/bots                         # Bot 列表
GET    /api/v1/bots/{id}                    # Bot 详情
PATCH  /api/v1/bots/{id}                    # 更新 Bot 配置
POST   /api/v1/bots/{id}/messages           # Bot 发送消息（走 UMB）
GET    /api/v1/bots/{id}/messages           # Bot 收取消息（polling fallback）
WS     /api/v1/bots/{id}/ws                 # Bot WebSocket 连接
```

#### 工作流 API
```
POST   /api/v1/workflows                   # 创建工作流
GET    /api/v1/workflows                   # 工作流列表
PATCH  /api/v1/workflows/{id}              # 更新工作流
POST   /api/v1/workflows/{id}/trigger      # 手动触发工作流
GET    /api/v1/workflows/{id}/instances     # 工作流实例列表
GET    /api/v1/workflow-instances/{id}      # 实例详情
POST   /api/v1/workflow-instances/{id}/pause   # 暂停
POST   /api/v1/workflow-instances/{id}/resume  # 恢复
POST   /api/v1/workflow-instances/{id}/cancel  # 取消
```

---

## 11. Zylos 可复用组件

### 11.1 可复用组件分析

经过对 Zylos 现有架构的深度分析，以下组件可以直接复用或作为 CODE-YI 的设计参考：

#### 11.1.1 HXA-Connect - Bot-to-Bot 通信协议

**组件概要：** HXA-Connect 是 Zylos 现有的 WebSocket 实时 Bot-to-Bot 通信系统，版本 v1.7.2。

**可复用的核心能力：**

| 能力 | HXA-Connect 实现 | CODE-YI 中的应用 |
|------|-------------------|------------------|
| WebSocket 双工通信 | 基于 WebSocket 的实时消息推送 | 作为 Bot↔Bot 通信的传输层参考 |
| 多组织支持 | `org:<label>` 前缀路由 | 多租户 / 多团队消息隔离 |
| 线程模型 | Thread 创建、加入、退出、参与者管理 | 对话子线程的数据模型 |
| @mention 机制 | `@bot_name` 解析 + mention 数组投递 | 统一 mention 解析引擎 |
| 访问控制 | DM Policy (open/allowlist) + Thread Policy | 对话级访问控制策略 |
| Thread Mode | `mention` (仅 @) vs `smart` (全量，AI 决定响应) | 消息可见性策略中的 `mention_only` 和 `observer` 模式 |
| 工件系统 | Artifact 创建/更新/版本管理 | 文档标注和工作流产物管理 |
| Bot 身份 | Profile (bio, role, team, timezone) | Bot 注册和身份管理 |

**直接可复用的代码/设计：**
- WebSocket 连接管理和重连逻辑
- @mention 解析引擎
- Thread 数据模型和 API 设计
- Access Control 策略框架（DM/Group 独立策略）
- Smart Mode 的"AI 判断是否响应"机制 -- 这是 CODE-YI `observer` 模式的直接前身

**需要改造的部分：**
- HXA-Connect 是跨组织的 Hub-Spoke 架构（中心化 Hub），CODE-YI 需要改为平台内部的消息总线
- 当前不支持人类参与者，需要扩展为 Human+Bot 混合

#### 11.1.2 C4 通信桥 - 消息路由中枢

**组件概要：** C4 是 Zylos 的中央消息网关，所有外部通信（Telegram、Lark、HXA-Connect 等）都通过 C4 路由。

**可复用的核心能力：**

| 能力 | C4 实现 | CODE-YI 中的应用 |
|------|---------|------------------|
| 统一消息格式 | 所有渠道消息标准化为 C4 格式 | UMB 的消息格式标准化参考 |
| 多渠道路由 | `c4-send.js "channel" "endpoint"` | 消息路由的设计范式 |
| 优先级队列 | SQLite 队列 + 优先级调度 | 工作流消息优先级调度 |
| 会话管理 | conversations 表 + checkpoints | 对话历史管理和上下文恢复点 |
| 健康状态 | `agent-status.json` + fail-open | Bot 健康状态检测机制 |
| 控制面板 | `c4-control.js` 系统控制 | 系统管理 API 的设计参考 |

**直接可复用的设计模式：**
- 消息的 stdin/heredoc 投递模式（避免 CLI 参数破坏多行内容）
- 消息队列的优先级调度逻辑
- Checkpoint 机制（用于工作流的断点恢复）
- Fail-open 健康检查语义

#### 11.1.3 Lark 集成 - IM 渠道实现

**组件概要：** Zylos 的飞书/Lark 通信渠道，v0.2.2。

**可复用的核心能力：**

| 能力 | Lark 实现 | CODE-YI 中的应用 |
|------|-----------|------------------|
| 事件订阅模型 | WebSocket 长连接 + HTTP Webhook 双模式 | 消息接收的双模式架构参考 |
| 消息格式支持 | 文本/富文本/图片/文件/卡片 | 多媒体消息类型系统 |
| Markdown 卡片 | 自动检测 Markdown 并渲染为交互卡片 | 消息渲染引擎 |
| 群聊上下文 | `context_messages` + 日志回溯 | 会话上下文窗口管理 |
| Smart/Mention 模式 | 群内 smart 模式接收全部消息，mention 模式仅 @ | 可见性策略的直接原型 |
| Owner 权限模型 | Owner 绕过所有访问检查 | 管理员权限系统 |

**经验教训（避坑）：**
- Lark 的 3 秒超时限制 → CODE-YI 必须采用异步响应架构
- Lark 的 Bot 间消息不可见 → CODE-YI 的 UMB 必须从底层消除这个限制
- Lark 的权限审核发布流程繁琐 → CODE-YI 应支持动态权限配置，无需"发布"

#### 11.1.4 Scheduler - 任务调度器

**组件概要：** C5 任务调度器，支持一次性、cron、interval 任务。

**可复用的核心能力：**

| 能力 | Scheduler 实现 | CODE-YI 中的应用 |
|------|----------------|------------------|
| Cron 调度 | 标准 cron 表达式 | 工作流定时触发 |
| 任务生命周期 | add/update/done/pause/resume/remove | 工作流实例生命周期管理 |
| 空闲检测 | 检查 runtime 是否存活后再分发 | Bot 空闲检测后分发任务 |
| 优先级队列 | 任务优先级排序 | 工作流步骤优先级 |

**直接可复用：**
- Cron 表达式解析和调度逻辑
- 任务状态机设计
- 与消息系统的集成模式

### 11.2 可复用组件映射

```
Zylos 现有组件                    CODE-YI 目标组件
─────────────────────────    →    ─────────────────────────
HXA-Connect (WebSocket)      →    Unified Message Bus (UMB)
  - Thread 模型              →      - Conversation 模型
  - @mention 引擎            →      - Mention 引擎
  - Smart/Mention 模式        →      - 可见性策略引擎
  - Access Control           →      - 权限系统
  - Artifact 系统             →      - 文档/工件管理

C4 通信桥                     →    Message Router
  - 统一消息格式              →      - UMB 消息格式
  - 优先级队列               →      - 消息优先级调度
  - Checkpoint               →      - 工作流断点

Lark 集成                     →    IM 能力参考
  - Markdown 卡片             →      - 消息渲染引擎
  - 群聊上下文               →      - 上下文窗口管理
  - Smart Mode               →      - Observer 模式

Scheduler (C5)                →    Workflow Trigger Engine
  - Cron 调度                →      - 定时触发
  - 任务生命周期             →      - 工作流生命周期
```

### 11.3 复用建议

1. **第一阶段（MVP）**：直接参考 HXA-Connect 的 Thread 模型和 C4 的消息路由设计，快速搭建 UMB
2. **第二阶段**：将 Smart Mode 的 AI 判断逻辑从 HXA-Connect 移植到 CODE-YI 的 Observer 模式
3. **第三阶段**：基于 Scheduler 的 cron 引擎构建工作流定时触发能力

---

## 12. 测试用例

### 12.1 消息系统测试

| 编号 | 测试场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|----------|----------|----------|----------|
| TC-MSG-01 | H↔H 文字消息 | User A, B 在同一对话 | A 发送 "Hello" | B 在 200ms 内收到消息 |
| TC-MSG-02 | H→Bot @触发 | 群聊中有 Code-Bot | 用户发送 "@code-bot 写个排序算法" | Bot 1s 内响应确认，开始流式输出 |
| TC-MSG-03 | Bot→Bot 消息可见 | 群聊中有 Code-Bot 和 Review-Bot（visibility=full） | Code-Bot 发送代码 | Review-Bot 收到消息事件 |
| TC-MSG-04 | 消息可见性过滤 | Bot-C 设置 visibility=mention_only | 用户发送不含 @bot-c 的消息 | Bot-C 不收到该消息 |
| TC-MSG-05 | Observer 模式 | Monitor-Bot 设置 visibility=observer | 用户发送包含 "error" 的消息 | Monitor-Bot 收到消息并自主决定是否响应 |
| TC-MSG-06 | 流式输出中断 | Bot 正在流式输出 | 用户点击 "Stop generating" | 流式输出立即停止，已输出内容保留 |
| TC-MSG-07 | 文件上传 | 任意对话 | 上传 50MB 文件 | 文件成功上传，显示进度条，完成后可预览 |
| TC-MSG-08 | 消息编辑 | 已发送消息 | 发送后 10 分钟内编辑 | 消息更新，显示"已编辑"标记 |
| TC-MSG-09 | 消息编辑超时 | 已发送消息 | 发送后 16 分钟尝试编辑 | 编辑被拒绝 |
| TC-MSG-10 | 多 Bot 同时输出 | 群聊中 @两个 Bot | 同时 @code-bot 和 @review-bot | UI 分流展示两个 Bot 的流式输出 |

### 12.2 工作流测试

| 编号 | 测试场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|----------|----------|----------|----------|
| TC-WF-01 | 代码审查循环 | 已配置 code-review 工作流 | @code-bot 实现登录功能 | Bot 链式执行：写代码→PR→审查→修改→审查通过 |
| TC-WF-02 | 最大迭代退出 | max_iterations=3 | 触发工作流，Review-Bot 持续拒绝 | 3 次迭代后停止，通知人工介入 |
| TC-WF-03 | 人工检查点 | 工作流有 checkpoint | 工作流执行到 checkpoint | 暂停并发送确认消息，用户确认后继续 |
| TC-WF-04 | 工作流超时 | timeout=30m | 工作流运行超过 30 分钟 | 自动停止，发送超时通知 |
| TC-WF-05 | 错误处理 | Bot 执行中断 | Code-Bot 调用 API 报错 | 触发 on_error，通知对话，工作流暂停 |
| TC-WF-06 | 手动暂停/恢复 | 工作流运行中 | 用户发送"暂停工作流" | 工作流暂停；用户发送"恢复"后继续 |
| TC-WF-07 | 定时触发 | cron: "0 9 * * *" | 系统时钟到 09:00 | 工作流自动触发 |
| TC-WF-08 | 并发工作流 | 2 个工作流同时运行 | 同时触发 | 互不干扰，各自独立执行 |

### 12.3 上下文管理测试

| 编号 | 测试场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|----------|----------|----------|----------|
| TC-CTX-01 | 上下文保持 | H↔Bot 多轮对话 | 第5轮提到第1轮的内容 | Bot 正确引用第1轮的信息 |
| TC-CTX-02 | 上下文压缩 | 对话超过 100 条消息 | 用户提新问题 | Bot 仍能引用早期关键信息（通过摘要） |
| TC-CTX-03 | 上下文重置 | 用户说"从头开始" | 发送重置指令 | Bot 清空会话上下文，重新开始 |
| TC-CTX-04 | 跨 Bot 上下文 | 工作流中 Bot-A 输出传递给 Bot-B | Bot-A 完成步骤 | Bot-B 的输入中包含 Bot-A 的完整输出 |

### 12.4 文档协作测试

| 编号 | 测试场景 | 前置条件 | 操作步骤 | 预期结果 |
|------|----------|----------|----------|----------|
| TC-DOC-01 | Push 到 GitHub | 对话中有文档内容 | 点击 "Push to GitHub" | PR 创建成功，链接发送到对话 |
| TC-DOC-02 | ClawMark 标注 | 文档在对话中展示 | 选中文字添加批注 | 批注显示在文档上，同步到对话时间线 |
| TC-DOC-03 | 标注解决 | 有未解决标注 | 作者点击"已解决" | 标注状态更新，检查是否全部解决 |

### 12.5 性能测试

| 编号 | 测试场景 | 指标 | 目标值 |
|------|----------|------|--------|
| TC-PERF-01 | 消息延迟（H↔H） | P99 延迟 | < 200ms |
| TC-PERF-02 | 消息延迟（H→Bot 确认） | P99 延迟 | < 1s |
| TC-PERF-03 | 流式输出首字节 | TTFB | < 2s（含 LLM 首 token） |
| TC-PERF-04 | 并发 WebSocket | 连接数 | > 10,000 |
| TC-PERF-05 | 消息吞吐 | 每秒消息数 | > 5,000 msg/s |
| TC-PERF-06 | 文件上传（100MB） | 上传时间 | < 30s (100Mbps 网络) |
| TC-PERF-07 | 搜索延迟 | P99 延迟 | < 500ms（100 万条消息） |
| TC-PERF-08 | Bot 并发实例 | 同时运行的 Bot | > 50 |

---

## 13. 成功指标

### 13.1 产品指标

| 指标 | 定义 | MVP 目标 (3 个月) | 成熟期目标 (12 个月) |
|------|------|-------------------|---------------------|
| **DAU** | 日活跃用户数 | 50 | 1,000 |
| **消息量** | 日消息总数 | 500 | 50,000 |
| **Bot 消息占比** | Bot 发送消息 / 总消息 | > 30% | > 50% |
| **Bot↔Bot 工作流执行数** | 日工作流完成数 | 5 | 200 |
| **工作流成功率** | 成功完成 / 总触发 | > 80% | > 95% |
| **平均工作流时长** | 工作流从触发到完成的平均时间 | - | < 30 min |
| **人工介入率** | 需要人工介入的工作流比例 | < 50% | < 15% |

### 13.2 技术指标

| 指标 | 目标 |
|------|------|
| 消息投递可靠性 | > 99.99% |
| 系统可用性 | > 99.9% (SLA) |
| 消息延迟 P99 | < 200ms (H↔H), < 1s (H→Bot) |
| WebSocket 重连成功率 | > 99% (5s 内重连) |
| Bot 健康检查响应 | < 5s |
| 数据持久化 | 零消息丢失（WAL + Redis AOF） |

### 13.3 用户体验指标

| 指标 | 目标 |
|------|------|
| 用户满意度 (NPS) | > 40 |
| Bot 响应质量评分 | > 4.0 / 5.0（用户评分） |
| 工作流完成后用户修改率 | < 30%（Bot 输出质量足够高） |
| 首次使用到完成第一个工作流 | < 15 分钟 |

---

## 14. 风险与缓解

### 14.1 技术风险

| 风险 | 影响 | 概率 | 缓解措施 |
|------|------|------|----------|
| **LLM 延迟不可控** | Bot 响应慢，用户体验差 | 高 | 1. 流式输出降低感知延迟 2. 多模型策略（快模型做初步响应，强模型做深度处理）3. 预生成机制 |
| **Bot↔Bot 无限循环** | 资源耗尽，系统崩溃 | 中 | 1. 强制 max_iterations 2. 循环检测算法 3. Token 消耗上限 4. 自动熔断 |
| **上下文窗口溢出** | Bot 丢失关键上下文 | 高 | 1. 智能摘要压缩 2. RAG 检索替代全量上下文 3. 分层上下文架构 |
| **WebSocket 连接风暴** | 服务端资源耗尽 | 中 | 1. 连接池管理 2. 自动断连空闲连接 3. 负载均衡 |
| **工作流状态不一致** | 工作流卡死或重复执行 | 中 | 1. 事务性状态更新 2. 幂等步骤执行 3. WAL 日志恢复 |
| **多模型兼容性** | 不同 LLM 输出格式/质量差异大 | 中 | 1. 统一输出格式层 2. 模型特定的 prompt adapter 3. 质量评估和降级机制 |

### 14.2 产品风险

| 风险 | 影响 | 概率 | 缓解措施 |
|------|------|------|----------|
| **用户不信任 Bot 自主工作** | 采用率低 | 高 | 1. 渐进式信任：先展示能力再放手 2. 完善的人工介入机制 3. 透明的执行日志 |
| **Bot 产出质量不稳定** | 需要大量人工修正 | 高 | 1. 质检 Bot 链式把关 2. 用户反馈闭环 3. 持续微调 prompt |
| **与现有工具的迁移成本** | 用户不愿从飞书/Slack 迁移 | 高 | 1. 飞书/Slack 消息桥接（不迁移也能用）2. 数据导入工具 3. 差异化功能驱动 |
| **H↔H 基础 IM 体验不如飞书** | 核心功能短板 | 中 | 1. MVP 聚焦差异化功能 2. H↔H 可通过桥接使用现有 IM 3. 持续迭代 IM 体验 |

### 14.3 安全风险

| 风险 | 影响 | 概率 | 缓解措施 |
|------|------|------|----------|
| **Bot 权限过大** | 误操作或恶意操作 | 中 | 1. 最小权限原则 2. 操作审计日志 3. 敏感操作需人工确认 |
| **消息数据泄露** | 隐私/合规问题 | 低 | 1. 端到端加密（可选）2. 数据存储加密 3. 访问日志 |
| **Prompt 注入攻击** | Bot 被诱导执行恶意操作 | 中 | 1. 输入消毒 2. 系统提示词隔离 3. 输出检测 4. 工具调用白名单 |
| **工作流被恶意触发** | 资源浪费/数据损坏 | 低 | 1. 工作流触发鉴权 2. 频率限制 3. 关键步骤人工确认 |

---

## 15. 排期建议

**排期不是照搬飞书团队的。飞书做 IM 投了几百人几年时间。我们的排期基于：** 

- 功能范围严格裁剪：我们不做语音/视频通话、不做朋友圈、不做日历。只做文字消息 + Bot 对话 + 工作流。范围大概是飞书消息功能的 1/10。

- 参考同类产品的开源实现：Rocket.Chat（开源 IM）核心消息系统 3 个后端花了约 4 个月；Matrix（去中心化 IM 协议）的参考实现 Synapse 的核心消息部分也是 3-4 个月。

- 我们的团队规模（10 人）：比飞书小得多，但我们不需要做飞书那么全的功能。

#### Phase 1（地基+毛坯）= 12 周：先让人能住进去 —— 人和人能聊天，人和 Bot 能对话

##### Sprint 1-2（基础架构搭建）

###### 1. PostgreSQL / Redis / MinIO 部署（~1 周）

- 为什么要花时间： 不只是"装上"就行。要设计数据表结构（消息表、频道表、用户表、Bot 表有 11 张），设置备份策略、索引优化。就像装修前先把水电管道铺好——后面墙刷好了再改管道代价极大。

- 难点： 消息表的设计要支持"消息可见性"——同一条消息，不同的人/Bot 可能看到的范围不同。这个从第一天就要设计对，后面改不了

###### 2. API Gateway + 认证系统（~1 周）

- API Gateway = 所有请求的统一入口，负责限流、转发

- 认证 = 确认"你是谁"（用 Logto，跟现有 Dashboard 共享账户体系）

- 为什么要花时间： 需要处理多种身份——人类用户用邮箱/OAuth 登录，Bot 用 API Key 认证。两种身份走不同的认证流程，但进入系统后要统一管理。另外 WebSocket 的认证比普通 HTTP 复杂（你不能每条消息都带密码，要用 token + 心跳机制）。
- 难点： Bot 的权限比人更敏感。一个 Bot 能访问哪些频道、能执行什么操作，需要一套独立的权限模型。
是什么： "实时双向电话线"——普通网页请求像寄信（你问一次，服务器回一次）。WebSocket 像打电话（双方随时可以说话，消息瞬间到达）。聊天软件必须用 WebSocket，否则你得每秒刷新页面才能看到新消息。

###### 3. WebSocket 服务（~1 周）

- 是什么： "实时双向电话线"——普通网页请求像寄信（你问一次，服务器回一次）。WebSocket 像打电话（双方随时可以说话，消息瞬间到达）。聊天软件必须用 WebSocket，否则你得每秒刷新页面才能看到新消息。

- 为什么要花时间： WebSocket 看起来简单，实际是整个系统最复杂的部分之一：

       - 连接管理：1000 个用户同时在线 = 1000 条持久连接。每条连接要保持心跳、处理断线重连。

       - 消息分发：A 在群里发了一条消息，服务器要实时推送给群里所有其他成员。50 人群 = 1 条消息触发 49 次推送。

       - 多设备同步：一个人可能同时用电脑和手机，两边都要收到。

       - 扩展性：以后用户多了要加服务器，多台服务器之间的 WebSocket 连接如何同步？这就是 Redis Pub/Sub 的作用。

- 难点和潜在卡点： WebSocket 连接是有状态的（不像普通网页请求，处理完就忘）。服务器重启时所有连接会断，需要客户端自动重连并恢复到正确状态。这个"断线恢复"逻辑如果做不好，用户体验会很差（消息丢失、重复、乱序）。

###### 4. 基础消息模型（~1 周）

- 是什么： "消息长什么样"的定义——一条消息包含哪些字段（发送者、时间、内容、类型、所属频道、可见性范围……）。以及消息的流转逻辑（发送→存储→分发→确认→已读）。

- 为什么要花时间： 这是整个对话系统的"数据合同"。所有后续功能——搜索、@提及、Bot 响应、工作流——都依赖这个模型。如果消息模型设计错了，后面每个功能都会别扭。

- 难点： 我们的消息模型比飞书/Slack 复杂，因为要原生支持：

       - Bot 的流式输出（一条消息"一个字一个字蹦出来"，像 ChatGPT）
       
       - 消息关联（一条 Bot 回复关联到触发它的那条人类消息）
       
       - 工作流上下文（Bot A 的输出是 Bot B 的输入，中间的消息链要追踪）

##### Sprint 3-4（H↔H + H↔Bot 对话）—— 4 周在做什么？

这 4 周是把架构变成用户看得见、用得了的产品。

###### 1. 文字消息收发（~1 周）

- 用户打开对话页面，能发消息、能看到别人的消息、能看到历史消息。这是最基本的功能，但涉及前后端联调（前端发送 → WebSocket 传输 → 后端存储 → 推送给其他人 → 其他人的前端实时显示）。

###### 2. @mention 引擎（~0.5 周）

- 在消息里打 @，弹出人员/Bot 列表，选中后对方收到通知。对 Bot 来说 @mention 是唤醒信号——不被 @ 的时候 Bot 可以安静旁听，被 @ 了才响应。

###### 3. Bot 注册和运行时（~1 周）

- 这是 Sprint 3-4 最难的部分。 "Bot 运行时"是指 Bot 在系统里"活着"的方式——它怎么接收消息、怎么处理、怎么回复。

- 难在哪： 每个 Bot 背后是一个 LLM（Claude/GPT/Gemini），它们的 API 调用方式、响应时间、token 限制都不一样。需要一个"模型网关"统一对接，同时处理：超时（LLM 可能想 30 秒才回复）、失败重试、token 消耗计量。

- 潜在卡点： LLM 是不确定的——同一个问题问两次可能给不同答案，也可能超时不回复。系统需要有"兜底策略"（超时 60 秒自动中断，显示"Bot 遇到了问题"）。

###### 4. 流式输出（~1 周）

- 让 Bot 的回复像 ChatGPT 一样一个字一个字地出现，而不是等 30 秒突然蹦出一大段。

- 难在哪： 每个 token 都要通过 WebSocket 实时推送到前端，前端要边接收边渲染。如果 Bot 的回复包含代码块或 Markdown 表格，渲染引擎要在"收到一半"的时候正确处理（比如代码块只收到了开头的 ```，还没收到结尾，渲染器不能崩）。

###### 5. 基础 UI（~1 周）

- 前端页面：左侧频道列表、中间消息流、右侧成员面板。响应式设计。这部分相对常规，参照飞书/Slack 的布局。

##### Sprint 3-4（H↔H + H↔Bot 对话） 

###### 1. 上下文窗口管理（~1.5 周）

- 这是 Bot 能否"聊得好"的核心。 LLM 有 token 上限（比如 200K tokens）。群里聊了 1000 条消息，全部喂给 LLM 既超限又浪费钱。需要一个策略：给 Bot 喂哪些消息作为上下文？最近 50 条？还是跟当前话题相关的？

- 难点： 上下文策略直接影响 Bot 的回复质量。太少 → Bot 不理解前因后果；太多 → 慢且贵。这需要反复调试。

###### 2. 消息搜索（~1 周）

- 全文搜索历史消息。用 PostgreSQL 的全文搜索（pg_trgm），支持中文。

###### 3. 文件上传（~0.5 周）

- 在对话中发送图片、文档。上传到 MinIO，消息里存链接。

###### 4. 通知系统（~1 周）

- 有人 @你、Bot 完成了任务、有新消息——桌面通知 + 浏览器推送 + 未读角标。


#### Phase 2（装修+智能家居）= 10 周：让 Bot 之间能自己协作 —— 这是我们跟飞书/Slack 的核心差异点

一句话：让 Bot 能"看到"所有人的消息，包括其他 Bot 的消息。

##### Sprint 7-8：UMB + 可见性引擎（4 周）

###### 1. 统一消息总线 UMB（~1.5 周）
- 是什么： 把 Phase 1 做的消息系统升级成"消息高速公路"。Phase 1 的消息流是简单的：人发消息 → 存数据库 → 推给其他人和 Bot。UMB 是一个更智能的中间层：所有消息（不管谁发的）都先经过 UMB，由 UMB 决定谁能看到、谁需要被通知、是否触发工作流。

- 为什么需要这个？ 因为在 Phase 2 的场景里，消息的流向变复杂了：

       - Bot A 发一条消息 → Bot B 需要看到并响应
       
       - 但你不希望所有 Bot 都看到所有消息（噪音太大，浪费 token）
       
       - 有些消息是"工作指令"（需要立刻处理），有些是"信息通知"（看看就行）
       
       - UMB 就像一个智能邮局——根据消息类型、收件人规则，把消息分发到正确的地方。

- 难点： 性能。每条消息都要经过 UMB 路由，不能有明显延迟（目标 <50ms）。一个 50 人的群里发一条消息，UMB 要在 50ms 内决定 49 个接收者各自的可见性。

###### 2. 可见性策略引擎（~1 周）

- 是什么： 一套规则系统，决定"谁能看到什么"。

- 为什么需要？ 举个例子：

       - 群里有 3 个人 + 2 个 Bot（代码 Bot + Review Bot）
       
       - 人发消息 → 所有人和 Bot 都能看到 ✅
       
       - 代码 Bot 发了一段代码 → 人能看到，Review Bot 也能看到 ✅
       
       - Review Bot 给代码 Bot 的内部反馈 → 可能只需要代码 Bot 看到，人不需要被打扰 ⚠️

- 这就是"可见性策略"——不是所有消息都对所有人可见。策略可以配置：

       - "全部可见"（默认）
       
       - "仅 Bot 之间"（Bot 内部交流，人可以选择查看）
       
       - "仅创建者和指定接收者"（私密指令）
       
       - 难点： 策略规则的设计要简单易懂，让产品经理和用户能配置，不能搞成只有工程师看得懂的正则表达式。

###### 3. Bot↔Bot 直接通信（~1 周）

- 是什么： 让两个 Bot 能直接对话，不需要人在中间转发。

- 这是整个产品最核心的技术突破。 飞书做不到这一点——飞书的 Bot 事件系统 im.message.receive_v1 明确不推送其他 Bot 的消息，这是平台层面的设计决定。Slack/Discord 也类似。

- 我们怎么做： 因为 CODE-YI 是自己的平台，我们从底层就不做这个限制。UMB 对 Bot 消息和人类消息一视同仁。Bot A 发的消息，UMB 正常推送给 Bot B。

- 难点和最大卡点：无限循环。 Bot A 发消息 → Bot B 收到后回复 → Bot A 收到后又回复 → Bot B 又回复……永远不停。这是 Bot↔Bot 通信的头号风险。

- 防护机制（必须从第一天就设计进去）：
       
       - max_iterations：一个对话链最多跑 N 轮（比如 20 轮）
       
       - 循环检测：如果 Bot 连续 3 轮输出几乎一样的内容，自动中断
       
       - Token 消耗上限：单次 Bot↔Bot 对话消耗超过 X 万 token 自动停止
       
       - 熔断器：检测到异常后自动暂停该 Bot 对，通知管理员

###### 4. Observer 模式（~0.5 周）

- 是什么： Bot 可以设置为"旁听者"——在群里默默看所有消息，但不主动说话。只在被 @或者触发条件满足时才响应。

- 为什么需要？ 想象一个"代码质量 Bot"——它不需要参与每一条对话，但当有人贴了一段代码或者提到某个 Bug 时，它自动检查并给出建议。

- 难点不大， 但需要设计好触发条件（关键词匹配？正则？AI 语义判断？），以及"旁听"消耗的 token 成本控制。

##### Sprint 9-10：工作流引擎（4 周）

一句话：让 Bot 之间的协作可以"编排"——不是随意聊天，而是按步骤自动执行。

###### 1. 工作流定义解析（~1 周）
- 是什么： 用户（或管理员）可以用一种简单的方式定义"Bot 之间的协作流程"。比如：

- 触发条件：有人在群里发 "@代码Bot 帮我写一个登录页面"

       - 第一步：代码 Bot 写代码
       
       - 第二步：代码 Bot 把代码提交到 GitHub
       
       - 第三步：自动 @Review Bot 说"帮我看看这个 PR"
       
       - 第四步：Review Bot 检查代码，给出修改意见
       
       - 第五步：代码 Bot 根据意见修改
       
       - 第六步：循环第三到第五步，直到 Review Bot 说"通过"
       
       - 第七步：通知人类"代码已完成并通过 Review"

- 这种定义可以用 YAML 文件写（技术人员），也可以用可视化界面拖拽（后续做）。

- 为什么要花 1 周： 解析引擎需要理解"触发条件"、"步骤顺序"、"循环"、"条件分支"、"超时"等概念。相当于做一个简易版的"编程语言解释器"。

- 难点： 怎么设计定义格式才能既强大又好理解？太简单 → 没法表达复杂流程；太复杂 → 变成写代码了，产品经理用不了。

###### 2. 状态机执行引擎（~1.5 周）

- 是什么： 工作流跑起来后，每个步骤有状态：等待中 → 执行中 → 成功/失败。状态机负责管理这些状态的流转。

- 用生活例子解释： 就像外卖订单的状态——下单 → 商家接单 → 骑手取餐 → 配送中 → 已送达。每个状态只能往特定方向走，不能跳过。

- 为什么要 1.5 周：

       - 状态要持久化（存到数据库），即使服务器重启也能恢复到正确状态
       
       - 要处理并发（两个工作流同时跑，互不干扰）
       
       - 要有"暂停/恢复"能力（管理员随时可以暂停一个跑飞了的工作流）

- 难点： 分布式状态管理。工作流可能跑到一半服务器挂了，重启后要从断点继续，不能从头重来或者丢失中间结果。

###### 3. 人工检查点（~0.5 周）

- 是什么： 工作流执行到关键步骤时暂停，等人确认后再继续。

- 为什么需要： 你不想让 Bot 在半夜完全自动地把一段未经检查的代码合并到主分支。所以需要在关键节点设置"卡口"：Bot 完成后通知人，人确认"没问题"后流程才继续。

难点不大， 但交互设计要做好——人收到通知后，一个按钮"通过"，一个按钮"驳回并附意见"。

###### 4. 错误处理/重试（~0.5 周）

- 是什么： Bot 执行任务可能失败（LLM 超时、API 报错、生成了垃圾内容）。需要：

       - 自动重试（最多 3 次）
       
       - 重试失败 → 通知人类接管
       
       - 详细的错误日志（出了什么问题、在哪个步骤）

- 难点： 区分"可重试错误"（网络超时，重试大概率能成功）和"不可重试错误"（Bot 理解错了需求，重试 100 次结果一样）。后者需要人介入。

##### Sprint 11：GitHub 集成（2 周）

一句话：让工作流能直接操作 GitHub——创建 PR、读取代码、同步状态。

###### 1. PR 创建/状态同步（~1 周）

- 是什么： 代码 Bot 写完代码后，自动在 GitHub 上创建 Pull Request。PR 的状态（open/merged/closed）实时同步回 CODE-YI 的对话界面。

- 为什么只要 1 周： GitHub API 非常成熟，文档完善。核心就是调 API + 做状态映射。我们在 Zylos 里已经有 GitHub 操作经验。

###### 2. Webhook 事件回流（~1 周）

- 是什么： GitHub 上发生的事件（有人评论了 PR、CI 跑完了、PR 被合并了）实时推送回 CODE-YI，在对话里显示。

- 难点： Webhook 的可靠性——GitHub 可能重复发送、乱序发送。需要幂等处理（同一个事件收两次不会搞乱系统）。

- 潜在卡点： GitHub 对 Webhook 的发送频率有限制。如果一个大项目每分钟有 100 个 PR 事件，需要队列缓冲。

#### Phase 3（精装+配套）= 8 周：文档协作、Bot 市场、移动端 —— 锦上添花

前两个 Phase 搞定了"聊天"和"自动化工作流"。Phase 3 是让协作体验更完整：在对话里直接看文档、标注文档、Bot 市场、移动端。

##### Sprint 12-13：ClawMark 标注（4 周）

一句话：在对话里直接查看 GitHub 上的文档/代码，并且能像批改作业一样行内标注。

###### 1.文档嵌入展示（~1.5 周）

- 是什么： 在对话流里直接渲染 GitHub 上的文件（Markdown 文档、代码文件）。不需要跳转到 GitHub 网站，在 CODE-YI 里就能看。

- 为什么要 1.5 周：

       - 要从 GitHub API 拉取文件内容并实时渲染
       
       - Markdown 渲染要支持 GFM（GitHub Flavored Markdown）：表格、任务列表、Mermaid 图表
       
       - 代码文件要有语法高亮（几十种编程语言）
       
       - 长文档需要虚拟滚动（不能一次性渲染 5000 行代码）

- 难点： 渲染性能。一个 2000 行的代码文件，带语法高亮 + 行号 + 标注层，前端渲染要流畅不卡。

https://zylos150.coco.site/clawmark-prototype.html
<img width="2652" height="1622" alt="image" src="https://github.com/user-attachments/assets/30a64b7b-546a-41bd-a74a-5f6550b91a7d" />

###### 2. 行内标注引擎（~1.5 周）

- 是什么： 选中文档/代码的某一行或某一段，添加评论。就像 Google Docs 的批注功能，但是针对代码和技术文档。

- 为什么需要： 这是你描述的核心场景之一——把 PRD 推到 GitHub 后，用 ClawMark 直接在上面标注。Review Bot 也可以自动在代码的特定行上添加标注。

- 难点：

       - 锚点定位：文档内容可能更新（新版本），标注的位置要跟着移动，不能错位
       
       - 多人并发标注：两个人同时标注同一段代码，不能冲突
       
       - 标注和对话的关联：在标注里 @某人，这条 @消息要出现在对话流里
       
- 潜在卡点： 锚点漂移问题。文件被修改后，原来在第 42 行的标注可能变成第 45 行了。这需要 diff 算法来重新定位——技术上可行但需要仔细调试。

https://zylos150.coco.site/clawmark-annotation-engine.html
<img width="2620" height="1692" alt="image" src="https://github.com/user-attachments/assets/7980c4c5-3b22-43a3-9ace-572dd15a3056" />

###### 4. 评审闭环工作流（~1 周）

- 是什么： 把标注和 Phase 2 的工作流引擎串起来：

       - 人在文档上标注"这里逻辑有问题"
       
       - 自动创建一个任务给代码 Bot
       
       - 代码 Bot 修改代码、提交新版本
       
       - 标注状态变为"已解决"
       
       - 通知标注者确认
       
- 难点不大， 因为底层能力（工作流引擎 + 标注 + GitHub 集成）都在前面做好了，这里是串联。

##### Sprint 14：Bot Marketplace（2 周）

一句话：一个"应用商店"，让用户能一键添加预置的 Bot 到自己的团队。

###### 1. Bot 模板 + 配置向导（~2 周）

- 是什么：
       
       - 预置几个 Bot 模板：代码助手、代码审查员、测试助手、文档写手、数据分析
       
       - 每个模板定义好了：用什么模型、有什么技能、默认权限
       
       - 用户选模板 → 自定义名字和参数 → 一键部署到 Workspace

- 为什么只要 2 周：

       - Bot 的运行时在总产品 Spec 的 Module 5（Agent 管理）里已经做了
       
       - 这里主要是前端页面（模板浏览 + 配置表单 + 部署进度条）和后端 API
       
       - 初始阶段只需要 5-8 个模板，不需要开放上传

- 难点： 模板设计——每个模板的 system prompt、技能组合、权限设置要仔细打磨，直接影响用户的第一印象。这是产品工作多于工程工作。

##### Sprint 15-16：打磨 + 移动端（4 周）

###### 1. 性能优化（~1 周）

- 是什么： 全流程压力测试 + 优化：

       - 50 人群聊的消息延迟
       
       - 3 个 Bot 同时流式输出的渲染性能
       
       - 工作流引擎的并发承载能力
       
       - 数据库查询优化（消息列表、搜索）
       
       - 为什么需要： 前面 14 个 Sprint 都在赶功能，性能优化一直是"够用就行"。正式发布前必须过一遍。

###### 2. React Native 移动端（~2 周）

- 是什么： iOS + Android App。

- 核心功能：

       - 查看对话和消息
       
       - 发消息、@Bot
       
       - 接收通知推送
       
       - 查看工作流状态

- 为什么只要 2 周：

       - 用 React Native（跟 Web 端共享大量 UI 逻辑）
       
       - 移动端只做"查看和轻操作"，不做文档标注、工作流配置等重度功能
       
       - WebSocket 连接和消息协议跟 Web 端完全一样

- 难点： 推送通知。iOS 和 Android 的推送机制不一样（APNs vs FCM），需要分别对接。另外 WebSocket 在移动端的电池和网络优化（后台保活、断线重连）需要额外处理。

- 高级工作流 DAG/条件分支（~1 周）

- 是什么： 把工作流从"线性链条"升级为"有向无环图（DAG）"——支持并行和条件分支：

       - 开始 → 代码 Bot 写代码
       
                ├→ Review Bot 检查代码（跟上一步并行？不，需等代码完成）
                
                ├→ 测试 Bot 跑单元测试（跟 Review 并行 ✓）
                
                └→ 文档 Bot 更新 API 文档（跟 Review 并行 ✓）
                
              → 全部通过？ → 合并 PR
              
              → 有一个失败？ → 通知人类

- 难点： DAG 调度器。当多个 Bot 并行执行时，要管理依赖关系（谁等谁）、资源竞争（同一个 Git repo 不能两个 Bot 同时改）、失败时的回滚策略。

### 15.1 阶段划分

```
Phase 1: 基础对话系统 (MVP)             12 周
├── Sprint 1-2:  基础架构搭建            4 周
│   ├── PostgreSQL/Redis/MinIO 部署
│   ├── API Gateway + 认证系统
│   ├── WebSocket 服务
│   └── 基础消息模型
├── Sprint 3-4:  H↔H + H↔Bot 对话      4 周
│   ├── 文字消息收发
│   ├── @mention 引擎
│   ├── Bot 注册和运行时
│   ├── 流式输出
│   └── 基础 UI（Web）
└── Sprint 5-6:  上下文 + 消息管理       4 周
    ├── 上下文窗口管理
    ├── 消息搜索
    ├── 文件上传
    └── 通知系统

Phase 2: Bot↔Bot + 工作流               10 周
├── Sprint 7-8:  UMB + 可见性引擎        4 周
│   ├── 统一消息总线
│   ├── 可见性策略引擎
│   ├── Bot↔Bot 直接通信
│   └── Observer 模式
├── Sprint 9-10: 工作流引擎              4 周
│   ├── 工作流定义解析
│   ├── 状态机执行引擎
│   ├── 人工检查点
│   └── 错误处理/重试
└── Sprint 11:   GitHub 集成             2 周
    ├── PR 创建/状态同步
    └── Webhook 事件回流

Phase 3: 文档协作 + 高级功能             8 周
├── Sprint 12-13: ClawMark 标注          4 周
│   ├── 文档嵌入展示
│   ├── 行内标注引擎
│   └── 评审闭环工作流
├── Sprint 14:   Bot Marketplace         2 周
│   └── Bot 模板 + 配置向导
└── Sprint 15-16: 打磨 + 移动端          4 周
    ├── 性能优化
    ├── React Native 移动端
    └── 高级工作流（DAG/条件分支）
```

### 15.2 里程碑

| 里程碑 | 时间 | 交付物 | 关键能力 |
|--------|------|--------|----------|
| **M1: Alpha** | Week 6 | 内部可用的 Web 版本 | H↔H 消息、H→Bot @触发、流式输出 |
| **M2: Beta** | Week 12 | 对外小范围内测 | 完整 H↔H/H↔Bot、上下文管理、搜索 |
| **M3: Bot↔Bot Preview** | Week 18 | Bot↔Bot 功能预览 | UMB、可见性引擎、基础工作流 |
| **M4: Workflow GA** | Week 22 | 工作流正式发布 | 完整工作流引擎、GitHub 集成 |
| **M5: Full GA** | Week 30 | 全功能发布 | ClawMark、Marketplace、移动端 |

### 15.3 团队配置

| 角色 | 人数 | 职责 |
|------|------|------|
| 后端工程师 | 3 | 消息系统、工作流引擎、Bot Runtime |
| 前端工程师 | 2 | Web/Desktop UI、流式渲染、ClawMark |
| 移动端工程师 | 1 | React Native 移动端（Phase 3 加入） |
| AI/ML 工程师 | 1 | LLM 集成、上下文管理、Bot 质量 |
| 产品经理 | 1 | 需求管理、用户研究、优先级 |
| 设计师 | 1 | UI/UX 设计 |
| QA 工程师 | 1 | 测试、自动化 |
| **总计** | **10** | |

---

## 附录 A：技术研究资料来源

- 飞书开放平台官方文档：https://open.feishu.cn/document/faq/bot
- 飞书消息 API FAQ：https://open.feishu.cn/document/server-docs/im-v1/faq
- Slack Agent Orchestration：https://slack.com/blog/news/agent-orchestration
- Slack Events API：https://api.slack.com/events-api
- GitHub Copilot Workspace：https://githubnext.com/projects/copilot-workspace/
- Multi-Agent Systems 架构论文：https://arxiv.org/html/2601.13671v1
- Microsoft AI Agent Design Patterns：https://learn.microsoft.com/en-us/azure/architecture/ai-ml/guide/ai-agent-design-patterns
- 飞书多 Agent 实践（知乎）：https://zhuanlan.zhihu.com/p/2009377755695974125

## 附录 B：术语表

| 术语 | 定义 |
|------|------|
| UMB | Unified Message Bus，统一消息总线 |
| Bot | AI Agent 在对话系统中的实体 |
| H↔H | Human-to-Human，人与人的对话 |
| H↔Bot | Human-to-Bot，人与 AI 的对话 |
| Bot↔Bot | Bot-to-Bot，AI 之间的自主对话 |
| Visibility Policy | 消息可见性策略，控制参与者能看到哪些消息 |
| Workflow | 工作流，由多个 Bot 按定义的步骤链式执行的自动化任务 |
| Checkpoint | 检查点，工作流中暂停等待人工确认的节点 |
| ClawMark | 文档行内标注系统 |
| Observer Mode | 旁听模式，Bot 看到所有消息但由 AI 自主决定是否响应 |
| Smart Mode | 智能模式（来自 Zylos HXA-Connect），等同于 Observer Mode |
| Context Window | 上下文窗口，LLM 单次可处理的 token 上限 |
| Stream | 流式输出，Bot 响应逐 token 实时推送给客户端 |
