# CODE-YI Module 8: 设置 (Settings) — 产品需求文档

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
7. [OAuth 集成框架](#7-oauth-集成框架)
8. [通知系统架构](#8-通知系统架构)
9. [数据模型](#9-数据模型)
10. [技术方案](#10-技术方案)
11. [模块集成](#11-模块集成)
12. [测试用例](#12-测试用例)
13. [成功指标](#13-成功指标)
14. [风险与缓解](#14-风险与缓解)
15. [排期建议](#15-排期建议)

---

## 1. 问题陈述

### 1.1 分散的设置体验：现有工具的结构性碎片化

当前开发团队日常使用 5-15 个 SaaS 工具（GitHub、Slack、Jira、Notion、Figma、Vercel、AWS Console、Linear、Datadog 等），每个工具都有独立的设置页面、独立的 OAuth 授权流程、独立的通知偏好。这种碎片化带来三个层面的痛点：

**痛点一：个人资料碎片化**

开发者在每个平台维护独立的个人资料——头像、显示名称、邮箱、角色标签分散在十几个工具中。修改一处不会同步到其他平台。当团队成员想了解一个同事的角色定位时，需要在多个工具中逐一查看。在 AI-Native 工作空间中，人类成员的角色不仅是传统的"开发者/设计师/PM"，还涉及其与 Agent 的协作关系（如"谁是哪个 Agent 的审核者"），这些信息在现有工具中完全不可见。

**痛点二：OAuth 集成管理混乱**

- **授权状态不透明**：开发者不知道自己授权了哪些服务、授权了什么范围的权限、Token 何时过期。当某个集成突然失效（Token 过期、权限撤销），用户只能看到一个模糊的"连接失败"错误，不知道该如何修复
- **授权分散在各平台**：GitHub OAuth 在 GitHub Settings 里管理，Slack OAuth 在 Slack App Directory 里管理，AWS 凭证在 IAM Console 里管理——没有一个统一的视图让用户看到"我的所有第三方连接"
- **撤销授权困难**：想要撤销某个平台的授权，需要分别登录该平台的设置页面操作。用户离职时，无法一键清理所有授权
- **HxA 场景的新需求**：在 CODE-YI 中，Agent 需要通过用户授权的 OAuth Token 访问第三方服务（如：代码 Agent 通过用户的 GitHub Token 推送代码）。这意味着 OAuth 连接不仅是"用户的个人集成"，还是 Agent 执行能力的基础。现有工具完全没有考虑这一维度

**痛点三：通知过载与失控**

- **通知轰炸**：开发者每天收到来自 Slack、GitHub、Jira、Linear、邮件的数百条通知。研究表明，开发者平均每天在通知处理上花费 45-60 分钟
- **粒度不足**：大多数工具的通知设置只有"全开/全关"或粗糙的分类（如"所有任务通知"/"所有评论通知"）。无法精细控制"只在 Agent 完成我分配的任务时通知我，其他任务不通知"
- **跨工具通知无法统一管理**：每个工具的通知偏好分散在各自的设置页面中。没有一个地方可以一眼看到并管理所有通知开关
- **AI-Native 场景的特殊需求**：当 Agent 成为团队成员后，通知场景大幅增加——Agent 任务完成通知、Agent 异常通知、Agent 需要人类审批的通知。这些新型通知在现有工具中不存在

### 1.2 核心洞察

现有工具的设置页面基于一个隐含假设：**设置是低频操作，用户偶尔进来改改头像和通知开关就走了**。但在 AI-Native 工作空间中，设置页面承担了新的战略职能：

1. **OAuth 连接是 Agent 能力的基石**：Agent 能否代你推送代码、能否代你创建 Jira Issue、能否代你发送 Slack 消息——取决于你在设置页面中授权了哪些 OAuth 连接。设置页面从"低频偏好管理"升级为"Agent 能力授权中心"
2. **通知偏好决定了 HxA 协作效率**：在人与 Agent 高频协作的场景中，通知是"人类保持掌控"的关键机制。通知偏好不再是"要不要收邮件"，而是"在什么情况下 Agent 应该打断我"
3. **个人资料是 HxA 身份的载体**：你的角色标签不仅定义了你在团队中的职责，还影响 Agent 与你的交互方式（管理员看到更多控制选项，普通成员看到更简洁的视图）

```
现状（碎片化模型）：
  GitHub Settings → GitHub 个人资料 + GitHub OAuth
  Slack Settings → Slack 个人资料 + Slack 通知
  Jira Settings → Jira 个人资料 + Jira 通知
  Notion Settings → Notion 个人资料 + Notion 连接
  ...每个工具各管各的

  ↓ 问题：用户在 10+ 个设置页面中疲于奔命，Agent 无法获取跨平台授权

CODE-YI 模型（统一设置中心）：
  设置页面 = 个人资料（统一身份）
            + OAuth 集成面板（所有第三方连接一目了然）
            + 通知偏好（HxA 场景精细控制）
  
  → 一个页面管理所有：身份、连接、通知
  → Agent 能力直接由 OAuth 面板决定
  → 通知偏好精确到 HxA 协作场景
```

### 1.3 市场机会

- 2025-2026 年，**Unified Settings / Integration Hub** 成为 B2B SaaS 的差异化趋势。Notion 在 2025 年重构了设置页面，将"My Connections"提升为一级入口。Linear 在 2025 年推出了统一的 Integrations 页面。但这些仍是"用户自己管集成"的模式，没有考虑"Agent 代理执行"的场景
- OAuth 2.0 + PKCE 已成为行业标准，但**没有一个产品**提供统一的 OAuth 管理面板（跨 20+ 平台的连接状态、Token 健康度、权限范围一览）
- 当 AI Agent 需要代用户操作第三方平台时，OAuth Token 管理的重要性被放大了 10 倍——Token 过期 = Agent 停摆。但现有工具没有 Token 健康监控和自动刷新的可视化
- 这是 CODE-YI 的差异化点：**一个 AI-Native 的设置中心，让用户在一个页面内管理身份、授权 Agent 访问第三方平台、精细控制 HxA 通知偏好**

---

## 2. 产品愿景

### 2.1 一句话定位

**CODE-YI 设置模块是一个 AI-Native 的统一设置中心，包含个人资料管理、20+ 平台 OAuth 集成面板和 HxA 场景通知偏好引擎，让用户在一个页面内完成身份配置、Agent 能力授权和通知精细控制。**

### 2.2 核心价值主张

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        CODE-YI 设置中心                                   │
├──────────────────┬──────────────────────┬────────────────────────────────┤
│ 个人资料          │ OAuth 集成面板        │ 通知偏好                       │
│                  │                      │                                │
│ 统一身份卡片     │ 20+ 平台一目了然      │ Agent 任务完成通知              │
│ 头像/名称/邮箱   │ 已连接/未连接状态     │ 任务分配通知                   │
│ 角色标签显示     │ 一键连接/断开         │ @提及通知                      │
│ HxA 角色感知     │ Token 健康度监控      │ 开关粒度到场景                  │
│ 编辑即时生效     │ 自动刷新 + 告警       │ 渠道选择(站内/邮件/推送)        │
└──────────────────┴──────────────────────┴────────────────────────────────┘
```

### 2.3 核心差异化

| 维度 | Slack Settings | GitHub Settings | Notion Settings | Linear Settings | Vercel Settings | **CODE-YI Settings** |
|------|---------------|-----------------|-----------------|-----------------|-----------------|----------------------|
| 统一个人资料 | 仅 Slack 身份 | 仅 GitHub 身份 | 仅 Notion 身份 | 仅 Linear 身份 | 仅 Vercel 身份 | **跨平台统一身份 + HxA 角色** |
| OAuth 集成面板 | Apps 管理 | OAuth Apps | My Connections | Integrations | Integrations | **20+ 平台统一面板 + Token 健康监控** |
| Agent 代理授权 | 无 | 无 | 无 | 无 | 无 | **OAuth Token 可授权给 Agent 使用** |
| 通知偏好粒度 | 频道级 | 仓库级 | 页面级 | 项目级 | 部署级 | **HxA 场景级 (Agent 完成/分配/@提及)** |
| 通知渠道选择 | 站内+邮件 | 站内+邮件 | 站内+邮件 | 站内+邮件 | 站内+邮件 | **站内+邮件+推送+Webhook** |

### 2.4 设计理念

**"One Panel, Full Control"** ——一个面板，掌控全局。

Stephanie 的设计稿（Screen 10）体现了这一理念：设置页面分为三个清晰区域。顶部是个人资料卡（头像、名称、邮箱、角色标签、编辑按钮），简洁而完整；中部是 OAuth 集成面板（20+ 平台图标网格，已连接的高亮显示），一眼看到所有第三方连接状态；底部是通知偏好（三个 Toggle 开关，每个附带说明文字），直觉式操作。整个页面无需滚动太多即可掌握所有设置项——这是对"设置页面就应该简单明了"的最佳诠释。

---

## 3. 竞品对标

### 3.1 设置页面能力对比

| 功能 | Slack | GitHub | Notion | Linear | Vercel | Figma | Teams | **CODE-YI** |
|------|-------|--------|--------|--------|--------|-------|-------|-------------|
| 个人资料编辑 | ★★★★ | ★★★★ | ★★★ | ★★★ | ★★★ | ★★★★ | ★★★★ | ★★★★ |
| 头像上传 | ★★★★★ | ★★★★★ | ★★★★ | ★★★ | ★★★ | ★★★★★ | ★★★★ | ★★★★ |
| 角色标签展示 | ★★★ | ★★ | ★★ | ★★ | ★★ | ★★ | ★★★ | ★★★★★（含 HxA 角色） |
| OAuth 集成数量 | ★★★★★ | ★★★★ | ★★★★ | ★★★ | ★★★ | ★★ | ★★★★ | ★★★★★（20+ 平台） |
| 连接状态可视化 | ★★ | ★★ | ★★★ | ★★★ | ★★★ | ★★ | ★★ | ★★★★★（健康度面板） |
| Token 健康监控 | - | - | - | - | - | - | - | ★★★★ |
| Agent 代理授权 | - | - | - | - | - | - | - | ★★★★ |
| 通知偏好粒度 | ★★★★ | ★★★★ | ★★★ | ★★★ | ★★★ | ★★ | ★★★★ | ★★★★★（HxA 场景级） |
| 通知渠道选择 | ★★★★ | ★★★ | ★★★ | ★★★ | ★★★ | ★★ | ★★★★ | ★★★★★ |

### 3.2 深度分析

**Slack：**
- 优势：设置页面组织清晰（Profile / Notifications / Accessibility / Advanced）。通知偏好粒度到频道级别（每个频道可独立设置"所有消息/仅提及/无"）。支持 Do Not Disturb 时段设置
- 劣势：OAuth 集成管理不在个人设置中——App 管理在 Workspace 级别的"Apps"侧边栏，用户级别只能看到"已授权的 App"列表，无法看到 Token 状态或权限范围。没有 Agent 代理授权概念
- 核心缺失：用户无法在一个视图中看到"我的所有第三方连接 + 每个连接的健康状态"

**GitHub：**
- 优势：Settings 页面结构完整（Profile / Account / Appearance / Notifications / SSH & GPG / Applications / Security）。OAuth Apps 管理清晰（Authorized OAuth Apps 列表，可查看权限范围和撤销）。通知偏好支持仓库级粒度
- 劣势：OAuth Apps 页面只展示"已授权的第三方应用"——被动视角。没有"我想连接哪些服务"的主动连接面板。通知设置虽然粒度到仓库，但不支持"Agent 行为通知"这类新场景
- 核心缺失：没有统一的 Integration Hub。GitHub 的集成管理分散在 Marketplace + OAuth Apps + GitHub Apps + Personal Access Tokens 四个地方

**Notion：**
- 优势：2025 年重构后的 Settings 页面在"My Connections"中展示了所有已连接服务的卡片视图，视觉效果好。支持一键连接和断开
- 劣势：连接管理偏简单——只展示连接状态（已连接/未连接），不展示 Token 过期时间、权限范围等详细信息。通知偏好只有全局级开关，粒度不如 Slack
- 核心缺失：Notion 的连接管理是"用户自己管"的模式，没有考虑 Agent 代理执行的场景

**Linear：**
- 优势：设置页面极简设计，符合 Linear 的品牌调性。Integrations 页面按分类展示（Issue Tracking / Code / Communication / Design），组织清晰
- 劣势：通知偏好粒度只到项目级别。连接管理只展示开关状态，无详细信息
- 核心缺失：Linear 的 AI 功能（Linear AI）不需要用户级别的 OAuth 管理——因为 Linear AI 是平台内置功能，不需要代理访问第三方服务

**Vercel：**
- 优势：Integrations 页面支持 Marketplace 浏览和一键安装。Git Provider 连接（GitHub / GitLab / Bitbucket）管理清晰
- 劣势：Vercel 的集成偏向 DevOps 场景（Git + CI/CD），不覆盖协作工具（Slack / Notion / Jira 等）
- 核心缺失：没有个人级别的 OAuth 管理——Vercel 的集成是项目级别的，不是用户级别的

**Figma：**
- 优势：个人资料编辑体验好（头像拖拽上传、实时预览）。设置页面简洁
- 劣势：集成管理几乎没有——Figma 的第三方连接在 Community Plugins 中管理，与设置页面分离。通知偏好极其简单（仅"邮件通知"一个开关）
- 核心缺失：Figma 的设置页面只解决"个人偏好"，没有集成管理能力

### 3.3 竞品演进方向判断

| 竞品 | 可能的演进方向 | CODE-YI 的时间窗口 |
|------|--------------|-------------------|
| Slack | Agent Orchestration 可能增加用户级 OAuth 管理 | 12-18 个月——Slack 的 App 权限模型重构需要大量兼容性工作 |
| GitHub | Copilot Agent 可能需要用户级 OAuth Token 代理 | 6-12 个月——GitHub 已在探索 Copilot Extensions |
| Notion | AI Connectors 可能演进为用户级 OAuth 集成面板 | 12 个月——Notion 的集成生态仍在早期 |
| Linear | 可能引入 Agent 通知偏好 | 6-12 个月——Linear 迭代速度快 |

**结论：** 设置模块本身不是竞争壁垒，但**OAuth 集成面板作为 Agent 能力授权中心**是差异化点。CODE-YI 有 6-12 个月的窗口期，在这个窗口内建立"OAuth 连接 = Agent 能力"的产品认知。

---

## 4. 技术突破点分析

### 4.1 统一 OAuth 集成框架 (Unified OAuth Framework)

**传统模型：**
```
每个 SaaS 工具各自管理 OAuth：
  GitHub Settings → "Authorized OAuth Apps" 列表
  Slack Settings → "Connected Apps" 列表
  Notion Settings → "My Connections" 卡片

→ 用户在 10+ 个设置页面中分散管理 OAuth 连接
→ 没有统一视图、没有健康监控、没有自动刷新
```

**CODE-YI 模型：**
```
统一 OAuth 集成框架：
  设置页面 → OAuth 集成面板（20+ 平台图标网格）
  
  每个平台连接 = {
    provider: "github",
    status: "connected" | "disconnected" | "expired" | "error",
    scopes: ["repo", "read:org", "workflow"],
    token_health: { expires_at, refresh_available, last_refreshed_at },
    agent_delegation: { enabled: true, allowed_agents: ["agent_codebot"] }
  }
  
  → 一个面板管理所有 OAuth 连接
  → Token 健康度实时监控
  → Agent 代理授权可视化
```

**核心突破：** 将 20+ 平台的 OAuth 连接抽象为统一的 `OAuthConnection` 模型，每个连接封装了平台差异（OAuth 2.0 / OAuth 2.0 + PKCE / API Key / Personal Access Token），对上层暴露一致的接口（connect / disconnect / refresh / check_health）。

**技术关键点：**
- **Provider Adapter 模式**：每个平台实现一个 `OAuthProviderAdapter`，封装该平台的 OAuth 端点、Scope 定义、Token 刷新逻辑
- **Token 加密存储**：所有 OAuth Token 使用 AES-256-GCM 加密后存入 `oauth_tokens` 表，密钥由 KMS 管理
- **自动刷新引擎**：后台 Worker 定期检查 Token 过期时间，在过期前自动刷新（支持 refresh_token 的平台）
- **健康度评分**：每个连接的健康度基于 Token 有效性、API 可达性、权限完整性综合评估

### 4.2 HxA 感知通知引擎 (HxA-Aware Notification Engine)

**传统模型：**
```
通知偏好 = {
  email_notifications: true | false,
  push_notifications: true | false,
  categories: {
    tasks: true | false,
    comments: true | false,
    mentions: true | false
  }
}

→ 粒度停留在"类别"级别
→ 不区分"人类行为触发"和"Agent 行为触发"
```

**CODE-YI 模型：**
```
通知偏好（MVP — Screen 10）= {
  agent_task_completed: { enabled: true, description: "Agent完成任务后发送通知" },
  task_assigned:        { enabled: true, description: "新任务分配给你时通知" },
  mention_notification: { enabled: true, description: "对话中被提及时通知" }
}

→ MVP 三个 Toggle 开关，简洁直觉
→ 每个开关对应一个 HxA 场景
→ P2 扩展：渠道选择、时段控制、Agent 级粒度
```

**核心突破：** 通知偏好的分类维度从"功能类型"（任务/评论/提及）变为"HxA 场景"（Agent 完成任务/被分配任务/被@提及）。MVP 阶段仅三个开关——极简但精准。

### 4.3 角色感知个人资料 (Role-Aware Profile)

**传统模型：**
```
个人资料 = { avatar, name, email, bio }
→ 纯粹的身份信息，与系统角色无关
```

**CODE-YI 模型：**
```
个人资料 = {
  avatar, name, email,
  role_label: "管理员",                    // 来自 Module 4 Team 角色
  workspace_role: "admin",                  // Workspace 级别角色
  team_memberships: [                       // 所属团队及角色
    { team: "产品开发团队", role: "admin" },
    { team: "运营团队", role: "member" }
  ]
}

→ 个人资料卡片直接展示角色标签
→ 角色标签来自 Module 4 团队角色系统
→ 点击角色标签可跳转到团队管理页面
```

**核心突破：** 个人资料不是孤立的身份信息页，而是用户在 CODE-YI 生态中的"身份中心"——展示用户在各个团队中的角色，让用户一眼看到自己在系统中的定位。

### 4.4 Provider Adapter 架构

**核心突破：** 通过 Provider Adapter 模式，将 20+ 平台的 OAuth 差异封装在适配器层，上层代码无需关心具体平台的授权流程差异。

```typescript
// 统一的 OAuth Provider 适配器接口
interface OAuthProviderAdapter {
  // 平台标识
  provider_id: string;                    // 如 "github", "feishu", "slack"
  display_name: string;                   // 如 "GitHub", "飞书", "Slack"
  icon_url: string;                       // 平台图标
  
  // OAuth 配置
  auth_type: 'oauth2' | 'oauth2_pkce' | 'api_key' | 'pat';
  authorization_url: string;              // 授权端点
  token_url: string;                      // Token 端点
  scopes: OAuthScope[];                   // 可用权限范围
  default_scopes: string[];               // 默认请求的权限
  
  // 核心方法
  buildAuthorizationUrl(state: string, scopes: string[]): string;
  exchangeCodeForToken(code: string): Promise<OAuthTokenSet>;
  refreshToken(refresh_token: string): Promise<OAuthTokenSet>;
  revokeToken(access_token: string): Promise<void>;
  validateToken(access_token: string): Promise<TokenValidationResult>;
  getUserInfo(access_token: string): Promise<ProviderUserInfo>;
}
```

---

## 5. 用户故事

### 5.1 个人资料管理

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-ST-01 | 用户 | 作为用户，我想在设置页面看到我的个人资料卡片（头像、名称、邮箱、角色标签），以便确认我的身份信息 | 页面加载后展示个人资料卡片，包含头像、显示名称、邮箱、角色标签（如"管理员"），信息来自 Logto 和 Module 4 | P0 |
| US-ST-02 | 用户 | 作为用户，我想点击"编辑"按钮修改我的显示名称和头像，以便更新我的身份展示 | 点击编辑按钮弹出编辑表单，可修改名称（1-50 字符）和头像（上传或选择预设），保存后实时生效 | P0 |
| US-ST-03 | 用户 | 作为用户，我想上传自定义头像，以便使用个性化的形象 | 支持 JPG/PNG/GIF 格式，最大 5MB，上传后自动裁剪为正方形，生成多尺寸缩略图 | P0 |
| US-ST-04 | 用户 | 作为用户，我想看到我在各团队中的角色标签，以便了解我在系统中的定位 | 角色标签从 Module 4 团队成员数据获取，展示在个人资料卡片中。如"管理员"标签紫色显示 | P0 |

### 5.2 OAuth 集成管理

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-ST-05 | 用户 | 作为用户，我想在 OAuth 集成面板看到所有支持的平台图标，一眼区分已连接和未连接 | 20+ 平台图标以网格排列，已连接的图标高亮并显示勾号，未连接的灰色显示 | P1 |
| US-ST-06 | 用户 | 作为用户，我想点击一个未连接的平台图标发起 OAuth 授权，以便连接该服务 | 点击图标 → 弹出确认对话框（显示请求的权限范围）→ 跳转到平台授权页 → 授权成功后回调 → 图标变为已连接 | P1 |
| US-ST-07 | 用户 | 作为用户，我想断开已连接的平台，以便撤销该服务的访问权限 | 点击已连接的平台图标 → 显示"断开连接"按钮 → 确认后撤销 Token + 更新状态 → 图标变为未连接 | P1 |
| US-ST-08 | 用户 | 作为用户，我想查看已连接平台的详细信息（授权范围、连接时间、Token 状态），以便了解授权详情 | 点击已连接平台 → 展开详情面板：授权范围列表、连接时间、Token 过期时间、最后使用时间 | P1 |
| US-ST-09 | 管理员 | 作为管理员，我想看到 Token 健康状态（正常/即将过期/已过期/异常），以便及时处理连接问题 | Token 状态徽标颜色：正常(绿)/即将过期(黄)/已过期(红)/异常(红闪)。即将过期 = 7 天内到期 | P1 |
| US-ST-10 | 用户 | 作为用户，我想手动刷新即将过期的 Token，以便保持连接有效 | 详情面板中显示"刷新 Token"按钮（仅 Token 支持刷新时可用），点击后自动刷新并更新状态 | P1 |
| US-ST-11 | 用户 | 作为用户，我想授权 Agent 使用我的 OAuth 连接（如允许代码 Agent 通过我的 GitHub Token 推送代码），以便 Agent 能代我操作 | 连接详情面板中增加"Agent 代理"开关 + Agent 选择列表。启用后指定的 Agent 可使用该 Token | P2 |
| US-ST-12 | 用户 | 作为用户，当 Token 过期或异常时，我想收到提醒通知，以便及时重新授权 | Token 过期前 3 天推送站内通知 + 邮件提醒，过期后在设置页面顶部显示警告横幅 | P2 |

### 5.3 通知偏好

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-ST-13 | 用户 | 作为用户，我想通过 Toggle 开关控制"Agent 任务完成通知"，以便决定是否在 Agent 完成任务后收到提醒 | Toggle 开关默认开启，关闭后不再收到 Agent 任务完成的站内通知和推送 | P1 |
| US-ST-14 | 用户 | 作为用户，我想通过 Toggle 开关控制"任务分配通知"，以便决定是否在被分配新任务时收到提醒 | Toggle 开关默认开启，关闭后不再收到新任务分配的通知 | P1 |
| US-ST-15 | 用户 | 作为用户，我想通过 Toggle 开关控制"@提及通知"，以便决定是否在对话中被提及时收到提醒 | Toggle 开关默认开启，关闭后不再收到 @提及的通知 | P1 |
| US-ST-16 | 用户 | 作为用户，我想看到每个通知开关的说明文字，以便理解该通知的触发场景 | 每个 Toggle 下方显示灰色说明文字（如"Agent完成任务后发送通知"） | P1 |
| US-ST-17 | 用户 | 作为用户，我想设置通知免打扰时段，以便在下班后不收到非紧急通知 | 时间段选择器（如 22:00-08:00），免打扰期间仅紧急通知可达 | P2 |
| US-ST-18 | 用户 | 作为用户，我想为不同通知类型选择渠道（站内/邮件/推送），以便精细控制通知到达方式 | 每个通知类型展开后显示渠道选择（三个独立开关：站内、邮件、推送） | P2 |

---

## 6. 功能拆分

### 6.1 P0 功能（MVP，必须实现）——约 1 周

#### 6.1.1 个人资料卡片

**展示内容：**
```
┌──────────────────────────────────────────────────┐
│  设置                                             │
│                                                   │
│  ┌─────────────────────────────────────────────┐ │
│  │                                             │ │
│  │  [Avatar]  陈明辉                    [编辑]  │ │
│  │            chen@code-yi.com                 │ │
│  │            [管理员]                          │ │
│  │                                             │ │
│  └─────────────────────────────────────────────┘ │
│                                                   │
└──────────────────────────────────────────────────┘
```

**卡片元素：**
- 头像：圆形，80px，来自 Logto 用户头像或自定义上传。支持点击查看大图
- 显示名称：16px Medium，最长 50 字符
- 邮箱：14px Regular，灰色文字
- 角色标签：Badge 样式，颜色编码（管理员-紫色、成员-蓝色、审核者-橙色），来自 Module 4 团队角色
- 编辑按钮：卡片右上角，点击弹出编辑模态框

**编辑功能：**
- 可编辑字段：显示名称、头像
- 不可编辑字段：邮箱（通过 Logto 账户系统修改）、角色标签（通过 Module 4 团队管理修改）
- 头像上传：支持 JPG/PNG/GIF，最大 5MB，自动裁剪为 200x200，生成 40/80/200 三种尺寸
- 保存：即时保存（Auto-save on blur 或显式保存按钮），保存后全局同步（名称/头像变更在 Chat、任务、团队页面实时生效）

**数据来源：**
- 头像、名称、邮箱：Logto 用户数据 + `user_profiles` 表覆盖
- 角色标签：Module 4 `team_members` 表的 `human_role` 字段（取用户所在主团队的角色）

### 6.2 P1 功能——约 4 周

#### 6.2.1 OAuth 集成面板

**面板布局：**
```
┌──────────────────────────────────────────────────┐
│  OAuth 集成                                       │
│                                                   │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐    │
│  │ GH │ │ 飞书│ │Slk │ │Jira│ │Ntn │ │ GM │    │
│  │ ✓  │ │ ✓  │ │    │ │    │ │ ✓  │ │    │    │
│  └────┘ └────┘ └────┘ └────┘ └────┘ └────┘    │
│                                                   │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐    │
│  │AWS │ │Dkr │ │ GL │ │Cnfl│ │Vrcl│ │Lnr │    │
│  │    │ │    │ │    │ │    │ │    │ │    │    │
│  └────┘ └────┘ └────┘ └────┘ └────┘ └────┘    │
│                                                   │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐    │
│  │Fgm │ │npm │ │Okta│ │ DD │ │Zoom│ │Disc│    │
│  │    │ │    │ │    │ │    │ │    │ │    │    │
│  └────┘ └────┘ └────┘ └────┘ └────┘ └────┘    │
│                                                   │
│  ┌────┐ ┌────┐                                   │
│  │ 微信│ │ Tw │                                   │
│  │    │ │    │                                   │
│  └────┘ └────┘                                   │
│                                                   │
└──────────────────────────────────────────────────┘
```

**平台列表（20+ 平台）：**

| 序号 | 平台 | OAuth 类型 | 典型 Scope | 优先级 |
|------|------|-----------|------------|--------|
| 1 | GitHub | OAuth 2.0 | repo, read:org, workflow | P1 第一批 |
| 2 | 飞书 (Feishu) | OAuth 2.0 | contact:user.base, im:message | P1 第一批 |
| 3 | Slack | OAuth 2.0 | channels:read, chat:write | P1 第一批 |
| 4 | Jira | OAuth 2.0 (3LO) | read:jira-work, write:jira-work | P1 第二批 |
| 5 | Notion | OAuth 2.0 | read_content, update_content | P1 第二批 |
| 6 | Gmail | OAuth 2.0 + PKCE | gmail.readonly, gmail.send | P1 第三批 |
| 7 | AWS | API Key (IAM) | 自定义 Policy | P1 第三批 |
| 8 | Docker Hub | OAuth 2.0 | repo:read, repo:write | P1 第三批 |
| 9 | GitLab | OAuth 2.0 | read_api, read_repository | P1 第二批 |
| 10 | Confluence | OAuth 2.0 (3LO) | read:confluence-content.all | P1 第三批 |
| 11 | Vercel | OAuth 2.0 | read, write | P1 第三批 |
| 12 | Linear | OAuth 2.0 | read, write | P1 第二批 |
| 13 | Figma | OAuth 2.0 | file_read, file_write | P1 第三批 |
| 14 | npm | Token (PAT) | read, publish | P1 第三批 |
| 15 | Okta | OAuth 2.0 | openid, profile | P1 第三批 |
| 16 | Datadog | API Key + App Key | 自定义权限 | P1 第三批 |
| 17 | Zoom | OAuth 2.0 | meeting:read, meeting:write | P1 第三批 |
| 18 | Discord | OAuth 2.0 | identify, guilds | P1 第三批 |
| 19 | 微信 (WeChat) | OAuth 2.0 | snsapi_userinfo | P1 第三批 |
| 20 | Twitter (X) | OAuth 2.0 + PKCE | tweet.read, tweet.write | P1 第三批 |

**MVP 策略（P1 阶段）：**
- 第一批（第 1-2 周）：GitHub + 飞书 + Slack — 开发者最高频使用的三个平台
- 第二批（第 3 周）：Jira + Notion + GitLab + Linear — 项目管理和代码托管
- 第三批（第 4 周+）：按客户需求优先级排序，每周接入 2-3 个平台

**连接状态图标设计：**
- 未连接：灰色图标 + 灰色边框
- 已连接（健康）：彩色图标 + 绿色勾号 Badge
- 已连接（即将过期）：彩色图标 + 黄色警告 Badge
- 已连接（已过期/异常）：彩色图标 + 红色感叹号 Badge

**连接详情面板（点击已连接图标展开）：**
```
┌─────────────────────────────────────────────┐
│  GitHub 连接详情                              │
│                                              │
│  状态：已连接 ●                               │
│  连接时间：2026-03-15 14:30                   │
│  Token 过期：2026-06-15 14:30 (57天后)        │
│  最后使用：2026-04-20 09:30                   │
│                                              │
│  授权范围：                                   │
│  ☑ repo (仓库完整访问)                        │
│  ☑ read:org (组织信息读取)                    │
│  ☑ workflow (GitHub Actions)                 │
│                                              │
│  [刷新 Token]  [断开连接]                     │
└─────────────────────────────────────────────┘
```

#### 6.2.2 通知偏好面板

**面板布局（匹配 Screen 10 设计稿）：**
```
┌──────────────────────────────────────────────────┐
│  通知偏好                                         │
│                                                   │
│  Agent任务完成通知                        [ON ]   │
│  Agent完成任务后发送通知                           │
│                                                   │
│  ──────────────────────────────────────────────   │
│                                                   │
│  任务分配通知                              [ON ]   │
│  新任务分配给你时通知                              │
│                                                   │
│  ──────────────────────────────────────────────   │
│                                                   │
│  @提及通知                                 [ON ]   │
│  对话中被提及时通知                                │
│                                                   │
└──────────────────────────────────────────────────┘
```

**三个通知场景：**

| 通知类型 | 触发条件 | 默认状态 | 关联模块 |
|---------|---------|---------|---------|
| Agent 任务完成通知 | Agent（Module 5）完成了分配给它的任务（Module 2），且该任务是当前用户分配的或当前用户是审核者 | ON | Module 2 + Module 5 |
| 任务分配通知 | 有新任务被分配给当前用户（由人类或协调者 Agent 分配）| ON | Module 2 |
| @提及通知 | 在 Chat（Module 1）中被 @提及（由人类或 Agent 提及）| ON | Module 1 |

**Toggle 交互：**
- Toggle 组件使用标准 Switch 样式
- ON 状态：绿色背景 + 白色滑块在右
- OFF 状态：灰色背景 + 白色滑块在左
- 切换动画：200ms ease-in-out
- 切换即时生效（乐观更新 + 后台持久化）
- 切换时不需要刷新页面

### 6.3 P2 功能

#### 6.3.1 Agent 代理授权

- OAuth 连接详情中增加"Agent 代理"区域
- Toggle 开关控制是否允许 Agent 使用该连接的 Token
- Agent 选择列表：从当前用户所在团队的 Agent 中选择
- 权限范围限制：可限制 Agent 只能使用部分 Scope（如只给 Agent repo:read 权限，不给 repo:write）
- 审计日志：记录 Agent 通过代理 Token 执行的所有操作

#### 6.3.2 通知高级设置

- 免打扰时段（Do Not Disturb）：设置时间范围，期间静音非紧急通知
- 渠道选择：每个通知类型可独立选择渠道（站内通知、邮件、推送、Webhook）
- Agent 级粒度：按 Agent 维度细分通知（如：只关注代码助手的完成通知，忽略测试 Agent 的通知）
- 通知摘要：将低优先级通知按时段聚合为摘要（如"过去 1 小时，3 个 Agent 完成了 5 项任务"）

#### 6.3.3 安全与隐私设置

- 登录设备管理：查看当前登录的设备和会话，支持远程注销
- 两步验证（2FA）配置
- API Key 管理：生成和管理个人 API Key
- 数据导出：导出个人数据（GDPR 合规）

---

## 7. OAuth 集成框架

### 7.1 OAuth 2.0 / PKCE 授权流程

CODE-YI 的 OAuth 集成框架支持多种授权协议，根据平台特性自动选择最佳流程。

#### 7.1.1 标准 OAuth 2.0 Authorization Code Flow

适用平台：GitHub、Slack、Jira、Notion、GitLab、Linear、飞书等大多数平台。

```
用户                    CODE-YI 前端              CODE-YI 后端              第三方平台
 │                         │                         │                        │
 ├─ 点击"连接 GitHub" ───→│                         │                        │
 │                         ├─ POST /oauth/initiate ─→│                        │
 │                         │  { provider: "github" } │                        │
 │                         │                         ├─ 生成 state (CSRF)     │
 │                         │                         ├─ 生成 PKCE verifier    │
 │                         │                         ├─ 存储 state → Redis    │
 │                         │                         │   (TTL: 10min)         │
 │                         │ ←── authorization_url ──┤                        │
 │                         │                         │                        │
 │ ←── redirect ──────────│                         │                        │
 │                         │                         │                        │
 ├─ 登录并授权 ────────────────────────────────────────────────────────────→│
 │                         │                         │                        │
 │ ←── redirect + code ─────────────────────────────────────────────────────┤
 │                         │                         │                        │
 ├─ 回调到 CODE-YI ──────→│                         │                        │
 │                         ├─ POST /oauth/callback ─→│                        │
 │                         │  { code, state }        │                        │
 │                         │                         ├─ 验证 state            │
 │                         │                         ├─ 用 code 换 token ────→│
 │                         │                         │                        ├─ 返回 token
 │                         │                         │ ←── access_token ──────┤
 │                         │                         │      refresh_token     │
 │                         │                         │      expires_in        │
 │                         │                         │                        │
 │                         │                         ├─ AES-256 加密 token    │
 │                         │                         ├─ 存入 oauth_tokens 表  │
 │                         │                         ├─ 更新 oauth_connections│
 │                         │                         │                        │
 │                         │ ←── { status: "connected" }                     │
 │ ←── 更新 UI（图标高亮）│                         │                        │
```

#### 7.1.2 OAuth 2.0 + PKCE Flow

适用平台：Gmail、Twitter (X) 等要求 PKCE 的平台。

```
在标准流程基础上增加：
  1. 前端生成 code_verifier (随机 43-128 字符)
  2. 计算 code_challenge = BASE64URL(SHA256(code_verifier))
  3. authorization_url 附加 code_challenge + code_challenge_method=S256
  4. token 请求附加 code_verifier（替代 client_secret）
  
安全优势：即使 authorization_code 被截获，没有 code_verifier 也无法换取 token
```

#### 7.1.3 API Key / Personal Access Token Flow

适用平台：AWS (IAM Key)、npm (Access Token)、Datadog (API Key + App Key)。

```
用户                    CODE-YI 前端              CODE-YI 后端
 │                         │                         │
 ├─ 点击"连接 AWS" ──────→│                         │
 │                         ├─ 弹出输入框 ──────────→│
 │                         │  (Access Key ID +       │
 │                         │   Secret Access Key)    │
 │ ←── 输入凭证 ─────────→│                         │
 │                         ├─ POST /oauth/connect ──→│
 │                         │  { provider: "aws",     │
 │                         │    credentials: {...} }  │
 │                         │                         ├─ 验证凭证有效性
 │                         │                         ├─ AES-256 加密
 │                         │                         ├─ 存入 oauth_tokens 表
 │                         │ ←── { status: "ok" } ──┤
 │ ←── 更新 UI ───────────│                         │
```

### 7.2 Token 生命周期管理

#### 7.2.1 Token 自动刷新引擎

```
┌──────────────────────────────────────────────────────────┐
│              Token Refresh Engine (后台 Worker)            │
│                                                           │
│  定时任务 (每 30 分钟)：                                    │
│    1. 查询所有 status='connected' 的 oauth_tokens          │
│    2. 筛选 expires_at < NOW() + INTERVAL '24 hours'       │
│    3. 对每个即将过期的 Token：                               │
│       ├── 检查是否有 refresh_token                         │
│       │   ├── 有 → 调用 provider.refreshToken()           │
│       │   │      ├── 成功 → 更新 access_token + expires_at│
│       │   │      └── 失败 → 标记 status='expired'         │
│       │   │                + 发送通知给用户                 │
│       │   └── 无 → 标记 status='expiring_soon'            │
│       │            + 发送提醒给用户"请重新授权"             │
│       └── 记录刷新日志                                     │
│                                                           │
│  立即刷新（用户手动触发或 API 调用失败时）：                  │
│    1. 调用 provider.refreshToken()                         │
│    2. 成功 → 更新 Token + 返回新 Token                     │
│    3. 失败 → 标记异常 + 通知用户                            │
└──────────────────────────────────────────────────────────┘
```

#### 7.2.2 Token 健康度评估

```typescript
interface TokenHealth {
  status: 'healthy' | 'expiring_soon' | 'expired' | 'error';
  score: number;              // 0-100 健康评分
  expires_at: string | null;  // Token 过期时间
  days_until_expiry: number;  // 距离过期天数（-1 = 永不过期）
  last_used_at: string;       // 最后使用时间
  last_refresh_at: string;    // 最后刷新时间
  refresh_available: boolean; // 是否支持自动刷新
  error_message?: string;     // 异常时的错误信息
}

// 健康度评分规则
function calculateTokenHealth(token: OAuthToken): TokenHealth {
  let score = 100;
  
  // 过期时间因素 (权重 50%)
  if (token.expires_at) {
    const daysLeft = daysBetween(now(), token.expires_at);
    if (daysLeft <= 0) { score -= 50; status = 'expired'; }
    else if (daysLeft <= 3) { score -= 40; status = 'expiring_soon'; }
    else if (daysLeft <= 7) { score -= 20; status = 'expiring_soon'; }
    else if (daysLeft <= 30) { score -= 10; }
  }
  
  // 刷新能力因素 (权重 20%)
  if (!token.refresh_token) { score -= 20; }
  
  // 最近使用因素 (权重 15%)
  const daysSinceUse = daysBetween(token.last_used_at, now());
  if (daysSinceUse > 90) { score -= 15; }  // 90+ 天未使用
  else if (daysSinceUse > 30) { score -= 10; }
  
  // 错误历史因素 (权重 15%)
  if (token.consecutive_errors > 3) { score -= 15; status = 'error'; }
  else if (token.consecutive_errors > 0) { score -= 5; }
  
  return { score, status, ... };
}
```

### 7.3 平台适配器详解

#### 7.3.1 GitHub Adapter

```typescript
const GitHubAdapter: OAuthProviderAdapter = {
  provider_id: 'github',
  display_name: 'GitHub',
  icon_url: '/icons/providers/github.svg',
  auth_type: 'oauth2',
  
  authorization_url: 'https://github.com/login/oauth/authorize',
  token_url: 'https://github.com/login/oauth/access_token',
  
  scopes: [
    { id: 'repo', name: '仓库完整访问', description: '读写仓库代码、Issue、PR' },
    { id: 'read:org', name: '组织信息读取', description: '读取组织和团队信息' },
    { id: 'workflow', name: 'GitHub Actions', description: '管理 workflow 运行' },
    { id: 'read:user', name: '用户信息', description: '读取用户资料' },
    { id: 'gist', name: 'Gist', description: '创建和管理 Gist' },
  ],
  default_scopes: ['repo', 'read:org', 'read:user'],
  
  // GitHub OAuth Token 不过期（除非用户撤销）
  // 但 Fine-grained PAT 有过期时间
  token_expiry_behavior: 'never_expires',
  refresh_supported: false,
  
  buildAuthorizationUrl(state, scopes) {
    return `https://github.com/login/oauth/authorize?` +
      `client_id=${GITHUB_CLIENT_ID}&` +
      `redirect_uri=${CALLBACK_URL}&` +
      `scope=${scopes.join(' ')}&` +
      `state=${state}`;
  },
  
  async exchangeCodeForToken(code) {
    // POST https://github.com/login/oauth/access_token
    // Returns: access_token (no refresh_token, no expiry)
  },
  
  async validateToken(access_token) {
    // GET https://api.github.com/user with Bearer token
    // 200 = valid, 401 = invalid
  },
  
  async getUserInfo(access_token) {
    // GET https://api.github.com/user
    // Returns: { login, name, email, avatar_url }
  }
};
```

#### 7.3.2 飞书 (Feishu) Adapter

```typescript
const FeishuAdapter: OAuthProviderAdapter = {
  provider_id: 'feishu',
  display_name: '飞书',
  icon_url: '/icons/providers/feishu.svg',
  auth_type: 'oauth2',
  
  authorization_url: 'https://open.feishu.cn/open-apis/authen/v1/authorize',
  token_url: 'https://open.feishu.cn/open-apis/authen/v1/oidc/access_token',
  
  scopes: [
    { id: 'contact:user.base', name: '用户基础信息', description: '读取用户姓名、头像' },
    { id: 'im:message', name: '消息读写', description: '发送和接收消息' },
    { id: 'drive:drive', name: '云文档', description: '读写云文档内容' },
    { id: 'bitable:app', name: '多维表格', description: '读写多维表格' },
  ],
  default_scopes: ['contact:user.base', 'im:message'],
  
  // 飞书 Token 有效期 2 小时，支持 refresh_token
  token_expiry_behavior: 'expires_with_refresh',
  refresh_supported: true,
  
  async refreshToken(refresh_token) {
    // POST https://open.feishu.cn/open-apis/authen/v1/oidc/refresh_access_token
    // Returns: new access_token + new refresh_token
  }
};
```

#### 7.3.3 Slack Adapter

```typescript
const SlackAdapter: OAuthProviderAdapter = {
  provider_id: 'slack',
  display_name: 'Slack',
  icon_url: '/icons/providers/slack.svg',
  auth_type: 'oauth2',
  
  authorization_url: 'https://slack.com/oauth/v2/authorize',
  token_url: 'https://slack.com/api/oauth.v2.access',
  
  scopes: [
    { id: 'channels:read', name: '频道读取', description: '读取频道列表和信息' },
    { id: 'chat:write', name: '消息发送', description: '在频道中发送消息' },
    { id: 'users:read', name: '用户读取', description: '读取工作区用户信息' },
    { id: 'files:read', name: '文件读取', description: '读取共享文件' },
  ],
  default_scopes: ['channels:read', 'chat:write', 'users:read'],
  
  // Slack Bot Token 不过期，User Token 不过期
  token_expiry_behavior: 'never_expires',
  refresh_supported: false,
};
```

### 7.4 Token 安全架构

```
┌────────────────────────────────────────────────────────────┐
│                   Token 安全分层架构                         │
│                                                             │
│  应用层（API Service）                                      │
│    ├── 永远不在日志中输出 Token 原文                         │
│    ├── 永远不在 API 响应中返回完整 Token                     │
│    ├── Token 在内存中的生存周期尽可能短                      │
│    └── 使用 Token 时通过 TokenVault 解密获取                 │
│                                                             │
│  加密层（TokenVault Service）                               │
│    ├── 加密算法：AES-256-GCM                                │
│    ├── 密钥管理：Google Cloud KMS / AWS KMS                 │
│    ├── 密钥轮转：每 90 天自动轮转 DEK                       │
│    ├── 信封加密：DEK 加密 Token，KEK 加密 DEK               │
│    └── 每个 Token 独立 IV (Initialization Vector)           │
│                                                             │
│  存储层（PostgreSQL oauth_tokens 表）                       │
│    ├── access_token_encrypted: BYTEA (AES-256-GCM 密文)     │
│    ├── refresh_token_encrypted: BYTEA (AES-256-GCM 密文)    │
│    ├── encryption_key_id: VARCHAR (指向 KMS 密钥版本)       │
│    └── token_iv: BYTEA (加密 IV)                            │
│                                                             │
│  审计层                                                     │
│    ├── 每次 Token 读取记录审计日志                            │
│    ├── 每次 Token 使用记录操作日志                            │
│    └── 异常访问模式检测（同一 Token 短时间内高频使用）         │
└────────────────────────────────────────────────────────────┘
```

### 7.5 连接/断开流程状态机

```
                  ┌───────────────┐
                  │  disconnected │ ←── 用户手动断开
                  └───────┬───────┘     或初始状态
                          │
                  用户点击"连接"
                          │
                          ▼
                  ┌───────────────┐
                  │  connecting   │ ←── OAuth 流程进行中
                  └───────┬───────┘
                          │
                 ┌────────┴────────┐
                 │                 │
           授权成功          授权失败/取消
                 │                 │
                 ▼                 ▼
         ┌───────────────┐  ┌───────────────┐
         │   connected   │  │  disconnected │
         └───────┬───────┘  └───────────────┘
                 │
        ┌────────┼────────┐
        │        │        │
   Token 即将  Token 过期  API 错误
   过期(7天内)  /撤销      (连续3次)
        │        │        │
        ▼        ▼        ▼
  ┌──────────┐ ┌──────┐ ┌──────┐
  │ expiring │ │expired│ │error │
  └────┬─────┘ └──┬───┘ └──┬───┘
       │          │        │
  自动/手动    用户重新   自动重试
  刷新成功     授权       成功
       │          │        │
       ▼          ▼        ▼
  ┌───────────────────────────┐
  │        connected          │
  └───────────────────────────┘
```

---

## 8. 通知系统架构

### 8.1 通知流水线 (Notification Pipeline)

```
┌──────────────────────────────────────────────────────────────────────┐
│                       通知流水线 (Notification Pipeline)               │
│                                                                       │
│  事件源 (Event Sources)                                               │
│    ├── Module 2 (Tasks):  task.completed (by agent)                   │
│    ├── Module 2 (Tasks):  task.assigned (to user)                     │
│    ├── Module 1 (Chat):   message.mention (@user)                     │
│    └── Module 5 (Agents): agent.error (Agent 异常, P2)                │
│                                                                       │
│  ↓ Redis Streams                                                      │
│                                                                       │
│  通知路由器 (Notification Router)                                      │
│    1. 确定通知类型 → notification_type                                 │
│    2. 确定接收者 → target_user_id                                      │
│    3. 查询用户通知偏好 → notification_preferences 表                   │
│       ├── agent_task_completed = true/false                            │
│       ├── task_assigned = true/false                                   │
│       └── mention_notification = true/false                            │
│    4. 如果该通知类型已关闭 → 丢弃（不记录）                             │
│    5. 如果该通知类型已开启 → 进入投递管道                               │
│                                                                       │
│  ↓                                                                    │
│                                                                       │
│  投递管道 (Delivery Pipeline)                                         │
│    ├── 站内通知 (In-App) → 写入 notification_logs 表                   │
│    │                       + WebSocket 推送到前端                       │
│    ├── 邮件 (Email, P2) → 发送到用户邮箱                               │
│    ├── 推送 (Push, P2) → 发送 Web Push / Mobile Push                  │
│    └── Webhook (P2) → POST 到用户配置的 Webhook URL                    │
│                                                                       │
│  ↓                                                                    │
│                                                                       │
│  投递记录 (Delivery Log)                                              │
│    └── 记录每条通知的投递状态（delivered / failed / read）              │
└──────────────────────────────────────────────────────────────────────┘
```

### 8.2 通知类型定义

```typescript
// 通知类型枚举
enum NotificationType {
  // P1: MVP 三种通知
  AGENT_TASK_COMPLETED = 'agent_task_completed',   // Agent 完成任务
  TASK_ASSIGNED = 'task_assigned',                  // 被分配新任务
  MENTION = 'mention',                              // 被 @提及
  
  // P2: 扩展通知类型
  AGENT_ERROR = 'agent_error',                      // Agent 异常告警
  TASK_OVERDUE = 'task_overdue',                    // 任务逾期提醒
  OAUTH_TOKEN_EXPIRING = 'oauth_token_expiring',   // Token 即将过期
  TEAM_MEMBER_JOINED = 'team_member_joined',        // 新成员加入团队
}

// 通知数据结构
interface Notification {
  id: string;
  type: NotificationType;
  
  // 接收者
  target_user_id: string;
  
  // 内容
  title: string;                    // 通知标题
  body: string;                     // 通知正文
  icon_url?: string;                // 通知图标（Agent 头像/平台图标）
  action_url?: string;              // 点击通知跳转的 URL
  
  // 触发者
  actor_id: string;                 // 触发事件的实体 ID
  actor_type: 'human' | 'agent' | 'system';
  actor_name: string;
  
  // 关联实体
  related_entity_type?: string;     // 'task' | 'message' | 'oauth_connection'
  related_entity_id?: string;
  
  // 状态
  status: 'pending' | 'delivered' | 'read' | 'dismissed';
  
  // 时间
  created_at: string;
  delivered_at?: string;
  read_at?: string;
}
```

### 8.3 通知偏好引擎

```typescript
// 通知偏好查询逻辑
async function shouldDeliverNotification(
  userId: string,
  notificationType: NotificationType
): Promise<boolean> {
  // 1. 从 Redis 缓存读取偏好（缓存未命中则查数据库）
  const prefs = await getNotificationPreferences(userId);
  
  // 2. 检查该通知类型是否开启
  switch (notificationType) {
    case NotificationType.AGENT_TASK_COMPLETED:
      return prefs.agent_task_completed;
    case NotificationType.TASK_ASSIGNED:
      return prefs.task_assigned;
    case NotificationType.MENTION:
      return prefs.mention_notification;
    default:
      return true;  // 未知类型默认投递
  }
  
  // 3. P2: 检查免打扰时段
  // if (isInDndPeriod(userId)) { ... }
  
  // 4. P2: 检查渠道偏好
  // return { inApp: prefs.channels.in_app, email: prefs.channels.email, ... }
}
```

### 8.4 通知投递策略

| 通知类型 | 投递渠道 (MVP) | 投递延迟 | 聚合策略 |
|---------|---------------|---------|---------|
| Agent 任务完成 | 站内通知 | 实时 (< 2s) | 同一 Agent 的多个任务完成可聚合（P2） |
| 任务分配 | 站内通知 | 实时 (< 2s) | 不聚合（每次分配都通知） |
| @提及 | 站内通知 | 实时 (< 1s) | 同一对话中的连续提及可聚合（P2） |

### 8.5 通知与其他模块的事件映射

```
Module 1 (Chat) 事件                        通知类型
────────────────────                       ──────────
message.created (with @mention)  ────→     MENTION

Module 2 (Tasks) 事件                       通知类型
─────────────────────                      ──────────
task.assigned (to user)          ────→     TASK_ASSIGNED
task.completed (by agent)        ────→     AGENT_TASK_COMPLETED

Module 5 (Agents) 事件                      通知类型
──────────────────────                     ──────────
agent.status_changed (to error)  ────→     AGENT_ERROR (P2)
```

---

## 9. 数据模型

### 9.1 用户资料表

```sql
-- 用户资料扩展表（补充 Logto 用户数据）
-- Logto 存储核心身份数据（email, password_hash, oauth_identities）
-- 此表存储 CODE-YI 特有的扩展资料
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE,                -- 关联 Logto user_id
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  
  -- 显示信息（可覆盖 Logto 数据）
  display_name VARCHAR(50),                     -- 显示名称（NULL 时使用 Logto 名称）
  avatar_url VARCHAR(500),                      -- 自定义头像（NULL 时使用 Logto 头像）
  avatar_thumbnail_40 VARCHAR(500),             -- 40px 缩略图
  avatar_thumbnail_80 VARCHAR(500),             -- 80px 缩略图
  avatar_thumbnail_200 VARCHAR(500),            -- 200px 缩略图
  
  -- 补充信息
  title VARCHAR(100),                           -- 职位/头衔（如"技术负责人"）
  department VARCHAR(100),                      -- 部门
  bio TEXT,                                     -- 个人简介（最长 500 字符）
  timezone VARCHAR(50) DEFAULT 'Asia/Shanghai', -- 时区
  locale VARCHAR(10) DEFAULT 'zh-CN',           -- 语言偏好
  
  -- 元数据
  last_profile_update_at TIMESTAMPTZ,
  
  -- 审计
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_user_profiles_user ON user_profiles(user_id);
CREATE INDEX idx_user_profiles_workspace ON user_profiles(workspace_id);
```

### 9.2 OAuth 连接表

```sql
-- OAuth 连接表（用户级别的第三方服务连接）
CREATE TABLE oauth_connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,                        -- 所属用户
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  
  -- 平台信息
  provider_id VARCHAR(50) NOT NULL,             -- 如 'github', 'feishu', 'slack'
  provider_user_id VARCHAR(200),                -- 用户在第三方平台的 ID
  provider_username VARCHAR(200),               -- 用户在第三方平台的用户名
  provider_email VARCHAR(255),                  -- 用户在第三方平台的邮箱
  provider_avatar_url VARCHAR(500),             -- 用户在第三方平台的头像
  
  -- 授权范围
  granted_scopes TEXT[],                        -- 已授权的权限范围数组
  
  -- 连接状态
  status VARCHAR(20) NOT NULL DEFAULT 'disconnected'
    CHECK (status IN (
      'disconnected',    -- 未连接
      'connecting',      -- 连接中（OAuth 流程进行中）
      'connected',       -- 已连接（正常）
      'expiring_soon',   -- 即将过期（7天内）
      'expired',         -- 已过期
      'error'            -- 异常
    )),
  
  -- 状态详情
  error_message TEXT,                           -- 异常时的错误信息
  error_count INTEGER DEFAULT 0,                -- 连续错误次数
  
  -- Agent 代理授权 (P2)
  agent_delegation_enabled BOOLEAN DEFAULT FALSE,
  delegated_agent_ids UUID[],                   -- 被授权使用的 Agent ID 列表
  delegated_scopes TEXT[],                      -- Agent 可使用的权限范围子集
  
  -- 时间
  connected_at TIMESTAMPTZ,                     -- 首次连接时间
  last_used_at TIMESTAMPTZ,                     -- 最后使用时间
  disconnected_at TIMESTAMPTZ,                  -- 最后断开时间
  
  -- 审计
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- 一个用户在一个平台只能有一个连接
  UNIQUE(user_id, provider_id)
);

-- 索引
CREATE INDEX idx_oauth_connections_user ON oauth_connections(user_id);
CREATE INDEX idx_oauth_connections_status ON oauth_connections(status) 
  WHERE status IN ('connected', 'expiring_soon', 'expired', 'error');
CREATE INDEX idx_oauth_connections_provider ON oauth_connections(provider_id, status);
CREATE INDEX idx_oauth_connections_workspace ON oauth_connections(workspace_id, provider_id);
```

### 9.3 OAuth Token 表

```sql
-- OAuth Token 表（加密存储）
-- 与 oauth_connections 分离，确保 Token 密文不会出现在连接列表查询中
CREATE TABLE oauth_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  connection_id UUID NOT NULL UNIQUE REFERENCES oauth_connections(id) ON DELETE CASCADE,
  
  -- 加密的 Token（AES-256-GCM）
  access_token_encrypted BYTEA NOT NULL,        -- 加密后的 access_token
  refresh_token_encrypted BYTEA,                -- 加密后的 refresh_token（部分平台无）
  
  -- 加密元数据
  encryption_key_id VARCHAR(100) NOT NULL,      -- KMS 密钥版本 ID
  token_iv BYTEA NOT NULL,                      -- 加密初始化向量
  
  -- Token 元数据（明文，用于健康度监控）
  token_type VARCHAR(20) DEFAULT 'bearer',      -- 'bearer' | 'bot' | 'api_key'
  expires_at TIMESTAMPTZ,                       -- access_token 过期时间（NULL = 不过期）
  refresh_token_expires_at TIMESTAMPTZ,         -- refresh_token 过期时间
  
  -- 刷新记录
  last_refreshed_at TIMESTAMPTZ,                -- 最后刷新时间
  refresh_count INTEGER DEFAULT 0,              -- 累计刷新次数
  next_refresh_at TIMESTAMPTZ,                  -- 下次计划刷新时间
  
  -- 使用记录
  last_used_at TIMESTAMPTZ,                     -- 最后使用时间（API 调用时更新）
  use_count INTEGER DEFAULT 0,                  -- 累计使用次数
  
  -- 错误记录
  last_error_at TIMESTAMPTZ,
  last_error_message TEXT,
  consecutive_errors INTEGER DEFAULT 0,
  
  -- 审计
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_oauth_tokens_connection ON oauth_tokens(connection_id);
CREATE INDEX idx_oauth_tokens_expiry ON oauth_tokens(expires_at) 
  WHERE expires_at IS NOT NULL;
CREATE INDEX idx_oauth_tokens_refresh ON oauth_tokens(next_refresh_at) 
  WHERE next_refresh_at IS NOT NULL;
```

### 9.4 通知偏好表

```sql
-- 通知偏好表（用户级别）
CREATE TABLE notification_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE,                  -- 所属用户
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  
  -- MVP 三个通知开关
  agent_task_completed BOOLEAN NOT NULL DEFAULT TRUE,   -- Agent 任务完成通知
  task_assigned BOOLEAN NOT NULL DEFAULT TRUE,           -- 任务分配通知
  mention_notification BOOLEAN NOT NULL DEFAULT TRUE,    -- @提及通知
  
  -- P2 扩展通知开关
  agent_error BOOLEAN DEFAULT TRUE,                      -- Agent 异常通知
  task_overdue BOOLEAN DEFAULT TRUE,                     -- 任务逾期通知
  oauth_token_expiring BOOLEAN DEFAULT TRUE,             -- Token 过期提醒
  team_member_joined BOOLEAN DEFAULT TRUE,               -- 新成员加入通知
  
  -- P2 免打扰设置
  dnd_enabled BOOLEAN DEFAULT FALSE,                     -- 免打扰开关
  dnd_start_time TIME,                                   -- 免打扰开始时间（如 22:00）
  dnd_end_time TIME,                                     -- 免打扰结束时间（如 08:00）
  dnd_timezone VARCHAR(50) DEFAULT 'Asia/Shanghai',
  
  -- P2 渠道偏好（JSON 格式，每个通知类型可独立设置渠道）
  channel_preferences JSONB DEFAULT '{
    "agent_task_completed": { "in_app": true, "email": false, "push": false },
    "task_assigned":        { "in_app": true, "email": false, "push": false },
    "mention":              { "in_app": true, "email": false, "push": false }
  }'::jsonb,
  
  -- 审计
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_notification_prefs_user ON notification_preferences(user_id);
CREATE INDEX idx_notification_prefs_workspace ON notification_preferences(workspace_id);
```

### 9.5 通知日志表

```sql
-- 通知日志表（记录所有已投递的通知）
CREATE TABLE notification_logs (
  id BIGSERIAL PRIMARY KEY,
  
  -- 通知内容
  notification_type VARCHAR(50) NOT NULL,         -- 通知类型
  target_user_id UUID NOT NULL,                   -- 接收者
  
  -- 内容
  title VARCHAR(200) NOT NULL,                    -- 通知标题
  body TEXT NOT NULL,                             -- 通知正文
  icon_url VARCHAR(500),                          -- 通知图标
  action_url VARCHAR(500),                        -- 跳转 URL
  
  -- 触发者
  actor_id UUID,
  actor_type VARCHAR(10)
    CHECK (actor_type IN ('human', 'agent', 'system')),
  actor_name VARCHAR(100),
  
  -- 关联实体
  related_entity_type VARCHAR(30),                -- 'task' | 'message' | 'oauth_connection'
  related_entity_id VARCHAR(100),
  
  -- 投递状态
  delivery_status VARCHAR(20) NOT NULL DEFAULT 'pending'
    CHECK (delivery_status IN ('pending', 'delivered', 'read', 'dismissed', 'failed')),
  delivery_channel VARCHAR(20) DEFAULT 'in_app'
    CHECK (delivery_channel IN ('in_app', 'email', 'push', 'webhook')),
  
  -- 时间
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  delivered_at TIMESTAMPTZ,
  read_at TIMESTAMPTZ,
  dismissed_at TIMESTAMPTZ
);

-- 索引
CREATE INDEX idx_notification_logs_user ON notification_logs(target_user_id, created_at DESC);
CREATE INDEX idx_notification_logs_unread ON notification_logs(target_user_id, delivery_status)
  WHERE delivery_status IN ('pending', 'delivered');
CREATE INDEX idx_notification_logs_type ON notification_logs(notification_type, created_at DESC);
CREATE INDEX idx_notification_logs_time ON notification_logs(created_at DESC);

-- 分区策略（P2: 按月分区，历史通知自动归档）
-- CREATE TABLE notification_logs_2026_04 PARTITION OF notification_logs
--   FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');
```

### 9.6 OAuth 审计日志表

```sql
-- OAuth 操作审计日志
CREATE TABLE oauth_audit_logs (
  id BIGSERIAL PRIMARY KEY,
  
  -- 操作者
  user_id UUID NOT NULL,
  agent_id UUID,                                  -- 如果是 Agent 代理使用
  
  -- 连接
  connection_id UUID NOT NULL REFERENCES oauth_connections(id),
  provider_id VARCHAR(50) NOT NULL,
  
  -- 操作
  action VARCHAR(30) NOT NULL,
  -- 可能的 action 值:
  -- 'connect'            : 发起连接
  -- 'connected'          : 连接成功
  -- 'disconnect'         : 断开连接
  -- 'token_refreshed'    : Token 刷新
  -- 'token_expired'      : Token 过期
  -- 'token_error'        : Token 异常
  -- 'token_used'         : Token 被使用（API 调用）
  -- 'agent_delegated'    : Agent 代理授权
  -- 'agent_revoked'      : Agent 代理撤销
  -- 'scopes_changed'     : 权限范围变更
  
  -- 详情
  details JSONB,                                  -- 操作详情
  ip_address INET,                                -- 操作者 IP
  user_agent VARCHAR(500),                        -- 操作者 User-Agent
  
  -- 时间
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_oauth_audit_user ON oauth_audit_logs(user_id, created_at DESC);
CREATE INDEX idx_oauth_audit_connection ON oauth_audit_logs(connection_id, created_at DESC);
CREATE INDEX idx_oauth_audit_action ON oauth_audit_logs(action, created_at DESC);
CREATE INDEX idx_oauth_audit_time ON oauth_audit_logs(created_at DESC);
```

### 9.7 ER 关系图

```
users (Logto)
  │
  ├── user_profiles (CODE-YI 扩展资料)
  │     ├── display_name, avatar, title, department
  │     └── timezone, locale
  │
  ├── oauth_connections (第三方平台连接)
  │     ├── provider_id, status, granted_scopes
  │     ├── agent_delegation_enabled (P2)
  │     │
  │     └── oauth_tokens (加密 Token 存储)
  │           ├── access_token_encrypted
  │           ├── refresh_token_encrypted
  │           └── expires_at, refresh_count
  │
  ├── notification_preferences (通知偏好)
  │     ├── agent_task_completed, task_assigned, mention_notification
  │     ├── dnd_enabled, dnd_start_time, dnd_end_time (P2)
  │     └── channel_preferences (P2)
  │
  ├── notification_logs (通知投递记录)
  │     ├── notification_type, title, body
  │     └── delivery_status, read_at
  │
  └── oauth_audit_logs (OAuth 操作审计)
        ├── action, details
        └── ip_address, user_agent

外部关联：
  user_profiles.user_id → Logto users.id
  oauth_connections.user_id → Logto users.id
  notification_logs.actor_id → users.id | agents.id (Module 5)
  notification_logs.related_entity_id → tasks.id (Module 2) | messages.id (Module 1)
  team_members.member_id → user_profiles.user_id (Module 4)
```

### 9.8 与现有模块的数据关系

**与 Logto (认证系统) 的关系：**
- `user_profiles` 补充 Logto 用户数据（Logto 存储核心身份，`user_profiles` 存储 CODE-YI 特有的扩展信息）
- 头像和显示名称优先从 `user_profiles` 读取，回退到 Logto 数据
- 邮箱和密码由 Logto 管理，`user_profiles` 不存储

**与 Module 4 (Team) 的关系：**
- 个人资料卡片中的角色标签来自 `team_members.human_role`
- 用户名称/头像变更时需要同步更新 `team_members.display_name` 和 `avatar_url` 冗余字段

**与 Module 2 (Tasks) 的关系：**
- "Agent 任务完成通知"和"任务分配通知"的事件源来自 Module 2
- 通知内容中的任务信息（标题、链接）来自 `tasks` 表

**与 Module 1 (Chat) 的关系：**
- "@提及通知"的事件源来自 Module 1 的消息 @提及
- 通知内容中的对话信息来自 `messages` 表

**与 Module 5 (Agents) 的关系：**
- OAuth 连接的 Agent 代理授权引用 `agents.id`
- Agent 通过 Token 代理执行操作时记录 `oauth_audit_logs.agent_id`

---

## 10. 技术方案

### 10.1 整体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                          客户端层                                    │
│  Web (Next.js + TailwindCSS)                                        │
│  ├── Settings Page                                                  │
│  │   ├── Profile Card (个人资料卡片)                                │
│  │   ├── OAuth Integration Panel (OAuth 集成面板)                   │
│  │   └── Notification Preferences (通知偏好面板)                    │
│  └── Notification Center (通知中心 — 全局组件)                      │
└───────────────────────┬─────────────────────────────────────────────┘
                        │ REST API + WebSocket
┌───────────────────────┴─────────────────────────────────────────────┐
│                        API Gateway                                   │
│  JWT Auth │ Rate Limiting │ CORS │ WS Upgrade                       │
└───────────────────────┬─────────────────────────────────────────────┘
                        │
┌───────────────────────┴─────────────────────────────────────────────┐
│                        服务层                                        │
│                                                                      │
│  Profile Service ── OAuth Service ── Notification Service            │
│       │                  │                    │                       │
│       │            TokenVault             Notification                │
│       │            (AES-256)              Router                      │
│       │                  │                    │                       │
│       │            Token Refresh          Preference                  │
│       │            Engine (Worker)        Engine                      │
│       │                  │                    │                       │
│  ┌────┴──────────────────┴────────────────────┴──────┐              │
│  │              Event Bus (Redis Streams)              │              │
│  └────┬──────────────────┬────────────────────┬──────┘              │
│       │                  │                    │                       │
│  Avatar Upload       OAuth Audit          Notification               │
│  Service (S3)        Logger               Delivery                   │
│                                           (in-app / email / push)    │
└───────────────────────┬─────────────────────────────────────────────┘
                        │
┌───────────────────────┴─────────────────────────────────────────────┐
│                        数据层                                        │
│  PostgreSQL 16 (Cloud SQL)  │  Redis 7 (Memorystore)                │
│  (user_profiles,             │  (notification preferences cache,     │
│   oauth_connections,         │   oauth state, token health cache,    │
│   oauth_tokens,              │   notification queue,                 │
│   notification_preferences,  │   websocket pub/sub)                  │
│   notification_logs,         │                                       │
│   oauth_audit_logs)          │  Cloud Storage (GCS/S3)               │
│                              │  (avatar uploads)                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 10.2 API 设计

#### RESTful API

```
# 个人资料
GET    /api/v1/users/me/profile                    # 获取当前用户资料
PATCH  /api/v1/users/me/profile                    # 更新资料（名称、头像等）
POST   /api/v1/users/me/avatar                     # 上传头像（multipart/form-data）
DELETE /api/v1/users/me/avatar                      # 删除自定义头像（回退到 Logto）

# OAuth 集成
GET    /api/v1/users/me/oauth/connections           # 获取所有 OAuth 连接状态
GET    /api/v1/users/me/oauth/connections/:provider  # 获取单个连接详情
POST   /api/v1/users/me/oauth/initiate              # 发起 OAuth 授权（返回 authorization_url）
POST   /api/v1/users/me/oauth/callback              # OAuth 回调处理（code + state）
POST   /api/v1/users/me/oauth/connect               # API Key 类型的直接连接
DELETE /api/v1/users/me/oauth/connections/:provider  # 断开连接
POST   /api/v1/users/me/oauth/connections/:provider/refresh  # 手动刷新 Token
GET    /api/v1/users/me/oauth/connections/:provider/health   # Token 健康度查询

# OAuth Provider 配置（公开 API，无需认证）
GET    /api/v1/oauth/providers                      # 获取所有支持的平台列表
GET    /api/v1/oauth/providers/:provider             # 获取平台详情（Scope 列表等）

# 通知偏好
GET    /api/v1/users/me/notifications/preferences   # 获取通知偏好
PATCH  /api/v1/users/me/notifications/preferences   # 更新通知偏好

# 通知日志
GET    /api/v1/users/me/notifications                # 获取通知列表（分页）
PATCH  /api/v1/users/me/notifications/:nid           # 标记通知已读/已忽略
POST   /api/v1/users/me/notifications/read-all       # 全部标记已读
GET    /api/v1/users/me/notifications/unread-count    # 获取未读通知数
```

#### 请求/响应示例

**获取个人资料：**

```typescript
// GET /api/v1/users/me/profile
// Response 200
{
  "user_id": "user_chenmh",
  "display_name": "陈明辉",
  "email": "chen@code-yi.com",
  "avatar_url": "https://cdn.codeyi.com/avatars/chenmh_200.jpg",
  "avatar_thumbnails": {
    "40": "https://cdn.codeyi.com/avatars/chenmh_40.jpg",
    "80": "https://cdn.codeyi.com/avatars/chenmh_80.jpg",
    "200": "https://cdn.codeyi.com/avatars/chenmh_200.jpg"
  },
  "title": "技术负责人",
  "department": "产品开发",
  "role_label": "管理员",
  "team_memberships": [
    { "team_id": "team_abc", "team_name": "产品开发团队", "role": "admin" }
  ],
  "timezone": "Asia/Shanghai",
  "locale": "zh-CN",
  "created_at": "2026-01-10T08:00:00Z"
}
```

**获取所有 OAuth 连接状态：**

```typescript
// GET /api/v1/users/me/oauth/connections
// Response 200
{
  "connections": [
    {
      "provider_id": "github",
      "display_name": "GitHub",
      "icon_url": "/icons/providers/github.svg",
      "status": "connected",
      "provider_username": "chenmh-dev",
      "provider_email": "chen@github.com",
      "granted_scopes": ["repo", "read:org", "workflow"],
      "connected_at": "2026-03-15T14:30:00Z",
      "last_used_at": "2026-04-20T09:30:00Z",
      "token_health": {
        "status": "healthy",
        "score": 95,
        "expires_at": null,
        "refresh_available": false,
        "days_until_expiry": -1
      }
    },
    {
      "provider_id": "feishu",
      "display_name": "飞书",
      "icon_url": "/icons/providers/feishu.svg",
      "status": "connected",
      "provider_username": "陈明辉",
      "granted_scopes": ["contact:user.base", "im:message"],
      "connected_at": "2026-03-20T10:00:00Z",
      "last_used_at": "2026-04-20T08:00:00Z",
      "token_health": {
        "status": "healthy",
        "score": 85,
        "expires_at": "2026-04-20T12:00:00Z",
        "refresh_available": true,
        "days_until_expiry": 0
      }
    },
    {
      "provider_id": "slack",
      "display_name": "Slack",
      "icon_url": "/icons/providers/slack.svg",
      "status": "disconnected",
      "provider_username": null,
      "granted_scopes": [],
      "connected_at": null,
      "token_health": null
    },
    {
      "provider_id": "notion",
      "display_name": "Notion",
      "icon_url": "/icons/providers/notion.svg",
      "status": "connected",
      "provider_username": "chenmh",
      "granted_scopes": ["read_content", "update_content"],
      "connected_at": "2026-02-10T09:00:00Z",
      "last_used_at": "2026-04-15T16:00:00Z",
      "token_health": {
        "status": "healthy",
        "score": 90,
        "expires_at": null,
        "refresh_available": false,
        "days_until_expiry": -1
      }
    }
    // ... 更多平台
  ],
  "summary": {
    "total_providers": 20,
    "connected": 4,
    "disconnected": 16,
    "expiring_soon": 0,
    "expired": 0,
    "error": 0
  }
}
```

**发起 OAuth 授权：**

```typescript
// POST /api/v1/users/me/oauth/initiate
// Request
{
  "provider_id": "github",
  "scopes": ["repo", "read:org", "workflow"]
}

// Response 200
{
  "authorization_url": "https://github.com/login/oauth/authorize?client_id=xxx&redirect_uri=https://app.codeyi.com/oauth/callback&scope=repo+read:org+workflow&state=abc123def456",
  "state": "abc123def456",
  "expires_in": 600
}
```

**更新通知偏好：**

```typescript
// PATCH /api/v1/users/me/notifications/preferences
// Request
{
  "agent_task_completed": true,
  "task_assigned": true,
  "mention_notification": false
}

// Response 200
{
  "agent_task_completed": true,
  "task_assigned": true,
  "mention_notification": false,
  "updated_at": "2026-04-20T10:05:00Z"
}
```

**获取通知列表：**

```typescript
// GET /api/v1/users/me/notifications?status=unread&limit=20
// Response 200
{
  "notifications": [
    {
      "id": "notif_001",
      "type": "agent_task_completed",
      "title": "代码助手 完成了任务",
      "body": "任务「实现用户认证模块」已完成，等待你的审核。",
      "icon_url": "https://cdn.codeyi.com/agent-icons/codebot.png",
      "action_url": "/tasks/task_xyz",
      "actor_name": "代码助手",
      "actor_type": "agent",
      "delivery_status": "delivered",
      "created_at": "2026-04-20T09:30:00Z"
    },
    {
      "id": "notif_002",
      "type": "task_assigned",
      "title": "新任务分配给你",
      "body": "李思琪 将「优化首页加载性能」分配给了你。",
      "icon_url": "https://cdn.codeyi.com/avatars/lisq_80.jpg",
      "action_url": "/tasks/task_abc",
      "actor_name": "李思琪",
      "actor_type": "human",
      "delivery_status": "delivered",
      "created_at": "2026-04-20T09:15:00Z"
    }
  ],
  "unread_count": 5,
  "total": 42,
  "has_more": true
}
```

### 10.3 WebSocket 事件

```typescript
// 服务端 → 客户端
interface WsServerEvents {
  // 通知推送
  'notification:new': {
    notification: Notification;         // 新通知内容
  };
  
  // 未读数更新
  'notification:unread_count': {
    count: number;                      // 当前未读数
  };
  
  // OAuth 连接状态变更
  'oauth:status_changed': {
    provider_id: string;
    old_status: string;
    new_status: string;
    details?: object;
  };
  
  // Token 健康度变更
  'oauth:token_health_changed': {
    provider_id: string;
    health: TokenHealth;
  };
  
  // 个人资料变更（其他模块可订阅）
  'profile:updated': {
    user_id: string;
    changes: {
      display_name?: string;
      avatar_url?: string;
    };
  };
}
```

### 10.4 前端架构

```
pages/
  settings/
    index.tsx                   # 设置主页（包含三个区域）

components/
  settings/
    SettingsPage.tsx              # 设置页面容器
    
    profile/
      ProfileCard.tsx            # 个人资料卡片
      ProfileEditModal.tsx       # 资料编辑弹窗
      AvatarUploader.tsx         # 头像上传组件（拖拽 + 裁剪）
      RoleBadge.tsx              # 角色标签（复用 Module 4 组件）
      
    oauth/
      OAuthPanel.tsx             # OAuth 集成面板容器
      ProviderGrid.tsx           # 平台图标网格
      ProviderIcon.tsx           # 单个平台图标（含状态 Badge）
      ConnectionDetailPanel.tsx  # 连接详情面板（Drawer）
      ScopeList.tsx              # 权限范围列表
      TokenHealthBadge.tsx       # Token 健康度徽标
      ConnectConfirmDialog.tsx   # 连接确认对话框
      DisconnectConfirmDialog.tsx # 断开确认对话框
      
    notifications/
      NotificationPrefsPanel.tsx # 通知偏好面板
      NotificationToggle.tsx     # 单个通知开关（Toggle + 说明文字）
      
  notifications/
    NotificationCenter.tsx       # 全局通知中心（Header 中的铃铛图标 + 下拉列表）
    NotificationItem.tsx         # 单条通知展示
    NotificationBadge.tsx        # 未读数徽标
```

**关键组件设计：**

**ProviderIcon（平台图标组件）：**

```tsx
// components/settings/oauth/ProviderIcon.tsx
interface ProviderIconProps {
  provider: OAuthProvider;
  connection?: OAuthConnection;
  onClick: (provider: OAuthProvider) => void;
}

export function ProviderIcon({ provider, connection, onClick }: ProviderIconProps) {
  const isConnected = connection?.status === 'connected';
  const statusBadge = getStatusBadge(connection?.status);
  
  return (
    <button
      className={cn(
        "relative w-16 h-16 rounded-xl border-2 flex items-center justify-center",
        "hover:shadow-md transition-all cursor-pointer",
        isConnected 
          ? "border-green-300 bg-white" 
          : "border-gray-200 bg-gray-50 opacity-60 hover:opacity-100"
      )}
      onClick={() => onClick(provider)}
    >
      <img 
        src={provider.icon_url} 
        alt={provider.display_name}
        className={cn("w-8 h-8", !isConnected && "grayscale")}
      />
      {statusBadge && (
        <span className="absolute -top-1 -right-1">{statusBadge}</span>
      )}
    </button>
  );
}

function getStatusBadge(status?: string) {
  switch (status) {
    case 'connected':      return <CheckCircle className="w-4 h-4 text-green-500" />;
    case 'expiring_soon':  return <AlertCircle className="w-4 h-4 text-yellow-500" />;
    case 'expired':        return <XCircle className="w-4 h-4 text-red-500" />;
    case 'error':          return <AlertTriangle className="w-4 h-4 text-red-500 animate-pulse" />;
    default:               return null;
  }
}
```

**NotificationToggle（通知开关组件）：**

```tsx
// components/settings/notifications/NotificationToggle.tsx
interface NotificationToggleProps {
  label: string;              // 通知类型名称
  description: string;        // 说明文字
  enabled: boolean;
  onChange: (enabled: boolean) => void;
}

export function NotificationToggle({ label, description, enabled, onChange }: NotificationToggleProps) {
  return (
    <div className="flex items-center justify-between py-4 border-b border-gray-100">
      <div className="flex-1">
        <h3 className="text-sm font-medium text-gray-900">{label}</h3>
        <p className="text-sm text-gray-500 mt-1">{description}</p>
      </div>
      <Switch
        checked={enabled}
        onCheckedChange={onChange}
        className="ml-4"
      />
    </div>
  );
}
```

### 10.5 OAuth 回调处理架构

```
用户浏览器                    CODE-YI 前端                CODE-YI 后端
  │                             │                           │
  │ (从第三方平台重定向回来)      │                           │
  │                             │                           │
  ├── /oauth/callback?code=xxx  │                           │
  │   &state=abc123             │                           │
  │                             │                           │
  │ ──→ OAuthCallback 页面 ────→│                           │
  │                             │                           │
  │                             ├── POST /oauth/callback ──→│
  │                             │   { code, state, provider }│
  │                             │                           │
  │                             │                           ├── 验证 state
  │                             │                           │   (Redis 查找 + 比对)
  │                             │                           │
  │                             │                           ├── 删除 Redis state
  │                             │                           │   (防止重放)
  │                             │                           │
  │                             │                           ├── 用 code 换 Token
  │                             │                           │   (调用 Provider Adapter)
  │                             │                           │
  │                             │                           ├── 获取用户信息
  │                             │                           │   (provider.getUserInfo)
  │                             │                           │
  │                             │                           ├── 加密 Token
  │                             │                           │   (TokenVault.encrypt)
  │                             │                           │
  │                             │                           ├── 存储连接 + Token
  │                             │                           │   (oauth_connections +
  │                             │                           │    oauth_tokens)
  │                             │                           │
  │                             │                           ├── 记录审计日志
  │                             │                           │
  │                             │ ←── { status: "connected" }
  │                             │                           │
  │ ←── 关闭回调窗口            │                           │
  │     刷新设置页面             │                           │
  │     (WebSocket 推送更新)     │                           │
```

### 10.6 性能目标

| 指标 | 目标 |
|------|------|
| 设置页面加载（个人资料） | < 200ms |
| OAuth 面板渲染（20 图标） | < 100ms |
| OAuth 授权发起 → 重定向 | < 500ms |
| OAuth 回调处理（code → connected） | < 2s |
| Token 刷新（后台自动） | < 3s |
| 通知偏好切换 → 生效 | < 200ms（乐观更新） |
| 通知推送延迟（事件 → 前端） | < 2s |
| 通知列表加载（20 条） | < 200ms |
| 头像上传 + 裁剪 + 三尺寸生成 | < 5s |
| 通知偏好缓存命中率 | > 95% |

---

## 11. 模块集成

### 11.1 与 Module 1 (Chat 对话) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| @提及通知 | Chat → Settings | Chat 中的 @提及事件触发通知流水线，Settings 根据用户偏好决定是否投递 |
| 用户名称/头像同步 | Settings → Chat | 用户修改名称或头像后，Chat 消息列表和成员列表实时更新 |
| 通知投递 | Settings → Chat | 站内通知通过 Chat 模块的 WebSocket 通道推送到前端 |

```yaml
# Chat → Settings 事件示例
event: message.mention
payload:
  mentioned_user_id: "user_chenmh"
  message_id: "msg_xyz"
  channel_id: "ch_abc"
  actor_id: "user_lisq"
  actor_type: "human"
  actor_name: "李思琪"
  message_preview: "请@陈明辉 帮忙看一下这个问题"

→ Settings Notification Router:
  1. 查询 user_chenmh 的 notification_preferences
  2. mention_notification = true → 投递
  3. 创建 notification_log 记录
  4. WebSocket 推送 notification:new 事件
```

### 11.2 与 Module 2 (Tasks 任务) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| 任务分配通知 | Tasks → Settings | 任务分配给用户时触发通知，Settings 根据偏好投递 |
| Agent 任务完成通知 | Tasks → Settings | Agent 完成任务时触发通知（通知分配者和审核者） |
| 任务执行 OAuth Token | Settings → Tasks | Agent 执行任务时可能需要通过用户的 OAuth Token 访问第三方服务（P2） |

```yaml
# Tasks → Settings 事件示例
event: task.completed
payload:
  task_id: "task_xyz"
  task_title: "实现用户认证模块"
  completed_by: "agent_codebot"
  completed_by_type: "agent"
  assigned_by: "user_chenmh"
  assigned_by_type: "human"

→ Settings Notification Router:
  1. 通知接收者 = assigned_by (user_chenmh)
  2. 查询 user_chenmh 的 notification_preferences
  3. agent_task_completed = true → 投递
  4. 生成通知：
     title: "代码助手 完成了任务"
     body: "任务「实现用户认证模块」已完成，等待你的审核。"
     action_url: "/tasks/task_xyz"
```

### 11.3 与 Module 4 (Team 团队) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| 角色标签 | Team → Settings | 个人资料卡片中的角色标签来自 Module 4 团队成员角色 |
| 名称/头像同步 | Settings → Team | 用户修改名称或头像后，同步更新 team_members 表的冗余字段 |
| 团队通知 (P2) | Team → Settings | 新成员加入团队时可触发通知 |

### 11.4 与 Module 5 (Agent 管理) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| Agent 代理授权 (P2) | Settings → Agents | 用户在 OAuth 面板中授权 Agent 使用其 Token |
| Agent 任务完成事件 | Agents → Settings | Agent 状态变更和任务完成事件触发通知 |
| Agent Token 使用审计 | Agents → Settings | Agent 使用代理 Token 时记录审计日志 |

### 11.5 集成数据流全景

```
Chat (M1)              Tasks (M2)           Settings (M8)         Team (M4)
  │                      │                     │                     │
  │ @提及事件             │                     │                     │
  ├──────────────────────────────────────→    │ 通知路由             │
  │                      │                     │ 偏好检查             │
  │                      │                     │ 投递/丢弃            │
  │                      │                     │                     │
  │                      │ 任务分配事件         │                     │
  │                      ├──────────────────→  │ 通知路由             │
  │                      │                     │                     │
  │                      │ Agent 任务完成       │                     │
  │                      ├──────────────────→  │ 通知路由             │
  │                      │                     │                     │
  │                      │                     │ 名称/头像变更         │
  │ ←──────────────────────────────────────── │──────────────────→  │
  │ 更新消息列表展示      │                     │                     │ 更新成员冗余字段
  │                      │                     │                     │
  │                      │                     │ 角色标签查询          │
  │                      │                     │ ←────────────────── │
  │                      │                     │                     │
  │                      │         P2: Agent 代理 Token              │
  │                      │ ←───────────────── │                     │
  │                      │  Agent 使用 Token    │                     │
  │                      │  执行任务            │                     │

Agent (M5)
  │
  │ Agent 状态/完成事件
  ├──────────────────────────────────────→  Settings (M8)
  │                                          通知路由
  │
  │ P2: Agent Token 代理请求
  ├──────────────────────────────────────→  Settings (M8)
  │                                          TokenVault 解密
  │ ←──────────────────────────────────────  返回 Token
  │                                          记录审计日志
```

---

## 12. 测试用例

### 12.1 个人资料

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-ST-01 | 资料卡片展示 | 打开设置页面 | 显示头像、名称、邮箱、角色标签，数据正确 |
| TC-ST-02 | 编辑名称 | 点击编辑 → 修改名称 → 保存 | 名称更新成功，其他模块（Chat、Team）同步更新 |
| TC-ST-03 | 名称校验 | 输入空名称或超过 50 字符 | 显示校验错误提示，不允许保存 |
| TC-ST-04 | 上传头像（JPG） | 选择 JPG 文件上传 | 上传成功，自动裁剪为正方形，生成三种尺寸 |
| TC-ST-05 | 上传头像（PNG） | 选择 PNG 文件上传 | 上传成功 |
| TC-ST-06 | 上传头像（超大文件） | 选择 > 5MB 文件 | 提示"文件大小不能超过 5MB" |
| TC-ST-07 | 上传头像（非图片格式） | 选择 .pdf 文件 | 提示"只支持 JPG/PNG/GIF 格式" |
| TC-ST-08 | 删除自定义头像 | 删除已上传的头像 | 回退到 Logto 默认头像 |
| TC-ST-09 | 角色标签展示 | 用户有管理员角色 | 显示紫色"管理员"徽标 |
| TC-ST-10 | 角色标签联动 | 在 Module 4 变更用户角色 | 设置页面角色标签实时更新 |

### 12.2 OAuth 集成面板

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-OA-01 | 面板展示 | 打开设置页面 | 20+ 平台图标网格正确渲染，已连接的高亮 |
| TC-OA-02 | 连接 GitHub | 点击 GitHub 图标 → 确认 → 授权 | 跳转 GitHub 授权 → 回调成功 → 图标高亮 + 绿色勾号 |
| TC-OA-03 | 连接飞书 | 点击飞书图标 → 确认 → 授权 | 跳转飞书授权 → 回调成功 → 图标高亮 |
| TC-OA-04 | 断开 GitHub | 点击已连接的 GitHub → 断开连接 → 确认 | Token 撤销，图标变灰，审计日志记录 |
| TC-OA-05 | 连接详情展示 | 点击已连接的平台图标 | 展开详情面板：授权范围、连接时间、Token 状态 |
| TC-OA-06 | Token 健康 — 正常 | 查看已连接平台（Token 未过期） | 健康度徽标绿色，分数 > 80 |
| TC-OA-07 | Token 健康 — 即将过期 | 模拟 Token 7 天内过期 | 健康度徽标黄色，显示"即将过期"提示 |
| TC-OA-08 | Token 健康 — 已过期 | 模拟 Token 已过期 | 健康度徽标红色，显示"已过期，请重新授权" |
| TC-OA-09 | 手动刷新 Token | 点击详情面板中的"刷新 Token" | Token 成功刷新，过期时间更新 |
| TC-OA-10 | 手动刷新失败 | Refresh Token 也过期时尝试刷新 | 提示"刷新失败，请重新授权"，状态变为 expired |
| TC-OA-11 | OAuth 授权取消 | 在第三方授权页面点击取消/拒绝 | 回调到设置页面，连接状态不变，显示"授权已取消" |
| TC-OA-12 | CSRF 保护 | 伪造 state 参数请求回调 | 返回 403，state 校验失败 |
| TC-OA-13 | 重复连接 | 已连接 GitHub 时再次点击连接 | 提示"已连接，是否重新授权？"确认后覆盖旧连接 |
| TC-OA-14 | API Key 类型连接 | 连接 AWS（输入 Key） | 弹出凭证输入框，输入后验证 → 连接成功 |
| TC-OA-15 | API Key 校验失败 | 输入无效的 AWS Key | 提示"凭证无效，请检查后重试" |
| TC-OA-16 | 自动刷新 | Token 即将过期（< 24h） | 后台 Worker 自动刷新，无需用户干预 |

### 12.3 通知偏好

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-NP-01 | 默认状态 | 新用户打开通知偏好 | 三个 Toggle 均为 ON（默认开启） |
| TC-NP-02 | 关闭 Agent 任务完成通知 | Toggle OFF | 不再收到 Agent 任务完成的站内通知 |
| TC-NP-03 | 关闭任务分配通知 | Toggle OFF | 不再收到新任务分配通知 |
| TC-NP-04 | 关闭 @提及通知 | Toggle OFF | 不再收到对话 @提及通知 |
| TC-NP-05 | 重新开启通知 | Toggle ON | 恢复接收该类型通知 |
| TC-NP-06 | 即时生效 | Toggle OFF 后，触发对应事件 | 不收到通知（偏好已即时生效） |
| TC-NP-07 | 说明文字展示 | 查看通知偏好面板 | 每个 Toggle 下方显示灰色说明文字 |
| TC-NP-08 | 偏好持久化 | 修改偏好 → 刷新页面 | 偏好状态保持不变（已持久化到数据库） |

### 12.4 通知投递

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-ND-01 | Agent 完成任务 → 通知 | Agent 完成被分配的任务 | 分配者收到站内通知："代码助手 完成了任务「XXX」" |
| TC-ND-02 | 任务分配 → 通知 | 人类给用户分配任务 | 被分配者收到通知："李思琪 将「XXX」分配给了你" |
| TC-ND-03 | @提及 → 通知 | 在 Chat 中 @用户 | 被提及者收到通知："李思琪 在 #产品开发 中提及了你" |
| TC-ND-04 | 通知偏好关闭 → 不投递 | 关闭 Agent 任务完成通知后，Agent 完成任务 | 不收到通知，不写入 notification_logs |
| TC-ND-05 | 通知列表展示 | 点击铃铛图标 | 下拉展示最近通知，未读的高亮显示 |
| TC-ND-06 | 标记已读 | 点击一条通知 | 通知标记为已读，未读数减 1 |
| TC-ND-07 | 全部已读 | 点击"全部已读" | 所有未读通知标记为已读，未读数归零 |
| TC-ND-08 | 通知跳转 | 点击通知 | 跳转到对应页面（任务详情/对话） |
| TC-ND-09 | 未读数实时更新 | 新通知到达 | WebSocket 推送，铃铛图标未读数 +1 |
| TC-ND-10 | 高并发通知 | 短时间内触发 10+ 条通知 | 全部正确投递，无遗漏 |

### 12.5 安全测试

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-SC-01 | Token 加密存储 | 直接查询 oauth_tokens 表 | access_token_encrypted 为密文，无法直接读取 |
| TC-SC-02 | CSRF 防护 | 伪造 OAuth state 回调 | 校验失败，返回 403 |
| TC-SC-03 | Token 不泄露 | API 响应中检查 Token | 永远不返回完整 Token 明文 |
| TC-SC-04 | 跨用户访问 | 用户 A 尝试访问用户 B 的连接 | 返回 403/404 |
| TC-SC-05 | 审计日志完整 | 执行连接/断开/刷新操作 | 每次操作在 oauth_audit_logs 中有记录 |
| TC-SC-06 | Token 撤销彻底 | 断开连接后使用旧 Token | Token 已在第三方平台撤销，API 调用返回 401 |

### 12.6 性能测试

| 指标 | 测试方法 | 目标 |
|------|---------|------|
| 设置页面加载 | API 响应时间 + Lighthouse | < 200ms (API) + FCP < 800ms |
| OAuth 面板渲染 | Performance timing | 20 图标 < 100ms |
| OAuth 回调处理 | 端到端计时 | < 2s (code → connected) |
| Token 刷新 | 后台 Worker 计时 | < 3s per token |
| 通知偏好切换 | 乐观更新 + 持久化 | UI < 50ms, API < 200ms |
| 通知推送延迟 | 事件 → 前端 | < 2s |
| 通知列表查询 | API 响应时间 | < 200ms (20 条) |
| 头像上传 | 端到端计时 | < 5s (含裁剪 + 三尺寸) |
| 并发 Token 刷新 | 同时刷新 50 个 Token | 全部成功，无死锁 |

---

## 13. 成功指标

### 13.1 核心指标

| 指标 | MVP (2 月后) | 成熟期 (10 月后) | 说明 |
|------|-------------|-----------------|------|
| 个人资料完善率 | > 70% | > 90% | 设置了自定义名称和头像的用户占比 |
| OAuth 连接数/用户 | 1.5 | 4+ | 平均每个用户的 OAuth 连接数 |
| 通知偏好自定义率 | > 30% | > 60% | 修改过至少一个通知偏好的用户占比 |
| 设置页面周访问率 | 1 次/用户/周 | 0.5 次/用户/周 | 设置页面属于低频操作，减少是正常趋势 |

### 13.2 OAuth 集成指标

| 指标 | MVP | 成熟期 | 说明 |
|------|-----|--------|------|
| OAuth 平台支持数 | 5 | 20+ | 已接入的平台数量 |
| Token 自动刷新成功率 | > 95% | > 99% | 自动刷新成功 / 自动刷新尝试 |
| Token 过期导致的 Agent 停摆次数 | < 5/周 | < 1/月 | Agent 因 Token 过期无法执行任务的次数 |
| 用户主动断开连接率 | < 5% | < 3% | 断开连接 / 总连接数（过高说明用户不信任） |
| OAuth 连接成功率 | > 90% | > 95% | 连接成功 / 连接尝试（含用户取消） |

### 13.3 通知系统指标

| 指标 | MVP | 成熟期 | 说明 |
|------|-----|--------|------|
| 通知投递成功率 | > 99% | > 99.9% | 成功投递 / 应投递总数 |
| 通知打开率 | > 40% | > 50% | 已读通知 / 已投递通知 |
| 通知响应时间（Agent 任务完成） | < 5 分钟 | < 2 分钟 | 从收到通知到用户审核任务的时间 |
| 通知偏好调整后的满意度 | 无投诉 | NPS > 0 | 用户是否因通知过多/过少投诉 |
| 通知推送延迟 P99 | < 5s | < 2s | 事件触发到前端收到通知 |

### 13.4 体验指标

| 指标 | 目标 | 说明 |
|------|------|------|
| 设置页面加载 P99 | < 500ms | 含资料 + OAuth 面板 + 通知偏好 |
| OAuth 授权完成时间 | < 30s | 从点击连接到授权成功 |
| 头像上传完成时间 | < 5s | 含裁剪和多尺寸生成 |
| 通知偏好切换延迟 | < 200ms | 从 Toggle 到偏好生效 |
| Token 健康度查询延迟 | < 300ms | 含缓存命中场景 |

---

## 14. 风险与缓解

### 14.1 技术风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **OAuth Token 泄露** — Token 加密密钥泄露或数据库被攻破，导致用户的第三方账户被非法访问 | 低 | 极高 | 1. Token 使用 AES-256-GCM 加密，密钥由 KMS 管理。2. 信封加密：DEK 加密 Token，KEK 加密 DEK。3. 密钥每 90 天自动轮转。4. 数据库访问受 IAM 策略严格限制。5. Token 表与连接表分离，减少暴露面。6. 所有 Token 访问记录审计日志 |
| **OAuth Provider API 变更** — 第三方平台修改 OAuth 端点、Scope 名称或 Token 格式，导致连接失效 | 中 | 中 | 1. Provider Adapter 模式隔离平台差异，变更只影响单个 Adapter。2. 定期运行平台连通性测试（Canary Test）。3. 监控每个平台的 Token 刷新成功率，异常时告警。4. 主要平台（GitHub/Slack/飞书）订阅其 Changelog 及时响应 |
| **Token 刷新风暴** — 大量 Token 同时到期，后台 Worker 短时间内发起大量刷新请求，被第三方平台 Rate Limit | 中 | 低 | 1. Token 创建时添加随机偏移量（jitter），错开过期时间。2. 刷新请求使用指数退避 + 抖动（Exponential Backoff with Jitter）。3. 每个平台独立的 Rate Limit 桶。4. 刷新失败不阻塞——标记为 expiring_soon 并通知用户 |
| **通知风暴** — 短时间内大量事件触发，用户收到过多通知导致体验下降 | 中 | 低 | 1. MVP 只有三种通知类型，天然限制了通知量。2. P2 引入聚合策略：同类通知在时间窗口内聚合（如"过去 5 分钟，代码助手完成了 3 项任务"）。3. 每用户每小时通知上限（如 50 条），超出后自动聚合为摘要 |
| **头像上传安全** — 用户上传恶意文件（如伪装为图片的可执行文件）或超大图片导致服务端 OOM | 低 | 低 | 1. 服务端验证文件 MIME Type（不仅检查扩展名）。2. 使用 Sharp/ImageMagick 重新编码图片（消除隐藏的恶意内容）。3. 文件大小限制 5MB。4. 图片尺寸限制 4096x4096。5. 处理超时 10s |
| **通知偏好缓存不一致** — Redis 缓存与数据库不同步，用户关闭了通知但仍收到 | 低 | 低 | 1. 偏好变更时同步清除 Redis 缓存。2. 缓存 TTL 5 分钟兜底。3. 投递前如缓存未命中则查数据库（不降级为"默认投递"） |

### 14.2 产品风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **OAuth 授权恐惧** — 用户不愿意在 CODE-YI 中授权第三方账户（GitHub/Slack 等），担心安全风险 | 中 | 高 | 1. 授权确认框清晰展示请求的权限范围 + 解释用途。2. 最小权限原则：默认只请求必要 Scope，不贪多。3. 断开操作一键完成，降低用户心理门槛。4. 设置页面展示安全说明（Token 加密存储、不保存密码、可随时撤销） |
| **通知偏好使用率低** — 用户不知道或不关心通知偏好设置，保持默认后被过多通知打扰 | 高 | 低 | 1. MVP 默认三个通知全开——对新用户来说是合理的默认值。2. 当用户连续收到 10+ 条通知时，在通知中心底部温柔提示"可以在设置中自定义通知偏好"。3. P2 引入智能推荐：根据用户行为推荐通知偏好调整 |
| **OAuth 平台覆盖不足** — 用户需要的平台不在支持列表中，影响 Agent 能力 | 中 | 中 | 1. P1 优先接入开发者最高频的 3-5 个平台。2. 提供"请求新平台"反馈入口。3. Provider Adapter 架构让新平台接入标准化（每个平台约 1-2 天开发量）。4. 开放 API 允许企业自行对接私有平台（P2） |
| **设置页面存在感低** — 设置页面作为辅助功能，用户很少主动访问 | 高 | 低 | 1. 这是预期行为——设置页面本身就是"设好就忘"的。2. 关键场景主动引导：首次使用时引导设置资料，Agent 需要 OAuth 时引导连接平台。3. Token 异常时在全局 Header 显示警告 Badge，引导用户进入设置页面处理 |

### 14.3 安全风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **OAuth CSRF 攻击** — 攻击者伪造 OAuth 回调请求，尝试将受害者账户绑定到攻击者的第三方账户 | 低 | 高 | 1. state 参数使用 crypto.randomUUID() 生成，存入 Redis（TTL 10 分钟）。2. 回调时严格比对 state。3. state 使用后立即删除（防止重放）。4. PKCE 额外保护（code_verifier 只在发起方拥有） |
| **Token 越权使用** — Agent 使用代理 Token 执行超出用户授权范围的操作 | 低 | 高 | 1. Agent 代理 Token 可限制 Scope 子集（P2）。2. 所有 Agent Token 使用记录审计日志。3. 用户可随时撤销 Agent 代理权限。4. Token 使用异常检测（如短时间高频调用第三方 API） |
| **通知内容注入** — 恶意用户通过 @提及或任务标题注入恶意内容到通知中 | 低 | 低 | 1. 通知内容 HTML 转义。2. 通知 action_url 仅允许 CODE-YI 域名。3. 通知标题和正文有长度限制 |

---

## 15. 排期建议

### 15.1 为什么 P0 约 1 周、P1 约 4 周？

**P0（个人资料页面）约 1 周的原因：**
1. **功能单一**：P0 只有个人资料卡片（头像 + 名称 + 邮箱 + 角色标签 + 编辑功能），没有复杂交互
2. **数据模型简单**：`user_profiles` 表只有不到 15 个字段，CRUD 操作标准化
3. **头像上传是成熟模式**：图片上传 + 裁剪 + 多尺寸生成有大量成熟组件可复用（如 react-avatar-editor, Sharp）
4. **角色标签只需读取**：角色标签从 Module 4 查询，设置模块只展示不修改
5. **复用基础设施**：Auth、API Gateway、Cloud Storage 均已在 Module 1-4 中搭建

**P1（OAuth 集成 + 通知偏好）约 4 周的原因：**
1. **OAuth 框架是核心投入**：Provider Adapter 架构 + TokenVault 加密 + Token 刷新引擎需要扎实的工程投入（~2 周）
2. **平台差异大**：每个 OAuth 平台的授权端点、Scope 定义、Token 行为各不相同，需要逐个适配
3. **安全要求高**：Token 加密存储、CSRF 防护、审计日志不能跳过
4. **通知系统是新增基础设施**：通知路由器 + 偏好引擎 + WebSocket 推送虽然单个不复杂，但串联起来需要完整的管道（~1 周）
5. **前 3-5 个平台接入**：每个平台约 1-2 天的适配 + 测试工作（~1 周）

### 15.2 Sprint 规划

#### Sprint 1: 个人资料页面（P0，第 1 周）

**做什么：** 搭建设置页面框架，实现个人资料卡片的展示和编辑。

**后端（0.5 人周）：**
- 数据库 Schema 创建（user_profiles 表）
- Profile API（GET /users/me/profile, PATCH /users/me/profile）
- 头像上传 API（POST /users/me/avatar，Cloud Storage 集成）
- 头像处理（裁剪 + 三尺寸缩略图生成，Sharp 库）
- Logto 用户数据关联查询

**前端（0.5 人周）：**
- 设置页面框架（SettingsPage 布局）
- 个人资料卡片组件（ProfileCard）
- 资料编辑弹窗（ProfileEditModal）
- 头像上传组件（AvatarUploader，拖拽 + 预览）
- 角色标签展示（复用 Module 4 RoleBadge）

**难点：** 头像上传的用户体验（拖拽上传 + 实时预览 + 裁剪交互）。名称/头像变更后需要通知其他模块同步更新冗余字段。

#### Sprint 2: OAuth 框架 + GitHub 连接（P1，第 2 周）

**做什么：** 搭建统一 OAuth 集成框架的核心架构，并接入第一个平台 GitHub。

**后端（1 人周）：**
- 数据库 Schema（oauth_connections, oauth_tokens, oauth_audit_logs 表）
- Provider Adapter 接口定义 + GitHub Adapter 实现
- OAuth 核心流程 API（initiate, callback, connect, disconnect）
- TokenVault 加密服务（AES-256-GCM + KMS 集成）
- Token 健康度查询 API
- OAuth 审计日志记录

**前端（1 人周）：**
- OAuth 集成面板容器（OAuthPanel）
- 平台图标网格组件（ProviderGrid + ProviderIcon）
- 连接确认对话框（ConnectConfirmDialog）
- OAuth 回调页面（OAuthCallbackPage）
- 连接详情面板（ConnectionDetailPanel）
- Token 健康度徽标（TokenHealthBadge）

**难点：** TokenVault 加密实现需确保安全性。OAuth 回调页面的状态管理（弹出窗口回调 vs 页面重定向）。GitHub OAuth 的完整端到端测试。

#### Sprint 3: 更多平台 + Token 刷新引擎（P1，第 3 周）

**做什么：** 接入飞书 + Slack + Jira + Notion + GitLab，实现 Token 自动刷新。

**后端（1 人周）：**
- 飞书 Adapter（OAuth 2.0，Token 有过期时间 + refresh）
- Slack Adapter（OAuth 2.0，Token 不过期）
- Jira Adapter（OAuth 2.0 3LO）
- Notion Adapter（OAuth 2.0）
- GitLab Adapter（OAuth 2.0）
- Token 自动刷新 Worker（定时任务，每 30 分钟扫描即将过期的 Token）
- Token 过期告警（写入 notification_logs，为 Sprint 4 做准备）

**前端（1 人周）：**
- 断开确认对话框（DisconnectConfirmDialog）
- Scope 列表组件（ScopeList）
- API Key 输入表单（用于 AWS、npm 等非 OAuth 平台）
- 平台状态 Badge 样式完善（未连接/连接中/已连接/过期/异常）
- 面板空状态和加载状态

**难点：** 飞书 OAuth 的 Token 刷新逻辑与其他平台不同（需要用 tenant_access_token 刷新 user_access_token）。多平台并行适配的测试工作量大。

#### Sprint 4: 通知系统 + 更多平台（P1，第 4 周）

**做什么：** 实现通知偏好面板和通知投递流水线，接入剩余平台（Linear + 第三批 2-3 个）。

**后端（1 人周）：**
- 数据库 Schema（notification_preferences, notification_logs 表）
- 通知偏好 API（GET/PATCH preferences）
- 通知路由器（Notification Router —— Redis Streams 消费者）
- 通知投递管道（站内通知写入 + WebSocket 推送）
- 通知列表 API（分页查询 + 标记已读）
- WebSocket 通知事件（notification:new, notification:unread_count）
- Linear Adapter + 2-3 个第三批平台 Adapter

**前端（1 人周）：**
- 通知偏好面板（NotificationPrefsPanel）
- 通知开关组件（NotificationToggle x 3）
- 全局通知中心（NotificationCenter —— Header 铃铛 + 下拉列表）
- 通知列表项组件（NotificationItem）
- 未读数徽标（NotificationBadge）
- 全流程联调 + Bug 修复

**难点：** 通知路由器需要监听 Module 1/2/5 的事件总线——跨模块协调。WebSocket 通知推送需要确保与现有 WebSocket 频道（Chat、Team）不冲突。通知投递的端到端测试（事件触发 → 偏好检查 → 投递 → 前端展示）。

#### Sprint 5: 联调 + 剩余平台接入（第 5 周）

**做什么：** 全流程联调，修复集成问题，接入剩余平台。

**后端 + 前端（1 人周共享）：**
- 跨模块联调（名称/头像变更同步、通知事件流）
- 剩余平台 Adapter 接入（Gmail, AWS, Docker, Confluence, Vercel 等）
- 性能优化（通知偏好缓存、Token 健康度缓存）
- Bug 修复 + 边界条件处理
- 安全审计（Token 加密、CSRF 防护、审计日志完整性）

### 15.3 P2 功能排期（约 2-3 周，P1 完成后）

#### Sprint 6-7: Agent 代理授权 + 通知高级设置（第 6-8 周）

- Agent 代理授权 UI + API（OAuth 连接中增加 Agent 委托功能）
- Agent Token 使用审计
- 通知免打扰时段
- 通知渠道选择（邮件/推送集成）
- Agent 级通知粒度
- 通知聚合策略
- 剩余平台 Adapter 接入

### 15.4 里程碑

| 里程碑 | 时间 | 关键能力 | 对应 Sprint |
|--------|------|---------|------------|
| **M1: Profile** | Week 1 | 个人资料卡片 + 头像上传 + 编辑功能 | Sprint 1 |
| **M2: OAuth Core** | Week 2 | OAuth 框架 + TokenVault + GitHub 连接 | Sprint 2 |
| **M3: OAuth Scale** | Week 3 | 5+ 平台 + Token 自动刷新 | Sprint 3 |
| **M4: Notifications** | Week 4 | 通知偏好 + 投递流水线 + 通知中心 | Sprint 4 |
| **M5: Integration** | Week 5 | 全流程联调 + 剩余平台 + 性能优化 | Sprint 5 |
| **M6: Advanced** | Week 8 | Agent 代理授权 + 通知高级设置 | Sprint 6-7 |

### 15.5 团队配置

| 角色 | 人数 | 职责 |
|------|------|------|
| 前端工程师 | 1 | 设置页面 UI + OAuth 面板 + 通知偏好 + 全局通知中心 |
| 后端工程师 | 1 | Profile Service + OAuth Service (Provider Adapters + TokenVault + Refresh Engine) + Notification Service (Router + Delivery Pipeline) |

**注意：** OAuth 框架的后端工作量较大（Provider Adapter 架构 + 加密 + 多平台适配），是本模块的核心技术投入。前端工作量相对均匀，OAuth 面板和通知中心的交互复杂度适中。

### 15.6 依赖关系

```
Logto (认证系统)      ──→  Module 8 依赖 Logto 用户数据和 OAuth 基础
Module 1 (Chat)       ──→  Module 8 依赖 M1 的 @提及事件（通知源）
Module 2 (Tasks)      ──→  Module 8 依赖 M2 的任务分配/完成事件（通知源）
Module 4 (Team)       ──→  Module 8 依赖 M4 的团队角色数据（角色标签展示）
Module 5 (Agents)     ──→  Module 8 依赖 M5 的 Agent 数据（P2 Agent 代理授权）
Cloud Storage (GCS/S3) ──→  Module 8 依赖 Cloud Storage（头像上传）
Cloud KMS             ──→  Module 8 依赖 KMS（Token 加密密钥管理）

Module 8 输出：
  ├── Profile API → M1/M2/M4 使用（用户名称和头像查询）
  ├── OAuth Token API → M5 使用（P2 Agent 代理 Token 获取）
  ├── Notification Service → 全局使用（所有模块通过事件总线触发通知）
  └── Notification Preferences → 通知路由决策
```

**关键依赖：**
- Module 1 和 Module 2 的事件总线是通知系统的数据源。如果这些模块的事件尚未标准化，需要在 Sprint 4 前协调事件格式
- Cloud KMS 是 Token 加密的前置条件。需要在 Sprint 2 前完成 KMS 配置和 IAM 权限设置
- 通知系统是横切关注点，上线后所有模块可通过事件总线触发通知——这是 Module 8 的核心基础设施输出

---

> **文档结束。** 本 PRD 由 Zylos AI Agent 在 Stephanie 的产品指导下撰写。如有调整需求，请直接反馈。
