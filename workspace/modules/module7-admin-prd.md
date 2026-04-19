# CODE-YI Module 7: 管理后台 (Admin) — 产品需求文档

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
7. [Agent 权限控制引擎](#7-agent-权限控制引擎)
8. [审批与审计系统](#8-审批与审计系统)
9. [数据模型](#9-数据模型)
10. [技术方案](#10-技术方案)
11. [模块集成](#11-模块集成)
12. [测试用例](#12-测试用例)
13. [成功指标](#13-成功指标)
14. [风险与缓解](#14-风险与缓解)
15. [排期建议](#15-排期建议)

---

## 1. 问题陈述

### 1.1 现有管理后台的结构性缺陷

当前主流协作与开发平台的管理后台（Slack Admin Console、Microsoft Teams Admin Center、Jira Administration、Linear Workspace Settings、GitHub Organization Settings、Vercel Dashboard、AWS IAM Console）均基于一个核心假设：**被管理对象全部是人类用户，AI/Bot 仅作为"集成应用"存在于管理视图的边缘**。当 AI Agent 成为 Workspace 中实际执行任务、消耗资源、产生成本的"工作实体"时，这些管理后台的治理模型立刻暴露出根本性不足：

**Slack Admin Console 的致命限制：**
- **席位管理只针对人类**：Slack 的 Admin Console → Members 页面只列出人类用户（Owner / Admin / Member / Guest）。Bot/App 在完全独立的"Apps"管理页面中，与人类成员列表物理隔离。管理员无法在一个统一视图中看到"这个 Workspace 里有多少人在工作、有多少 Agent 在工作、它们各自消耗了多少资源"
- **没有 Agent 级别权限控制**：Slack App 的权限（Scopes）在安装时一次性授予（如 `chat:write`、`channels:read`），无法在管理后台按"代码执行 / 文件写入 / 外部 API 调用 / 数据库操作"这样的操作维度进行开关式控制
- **没有 Agent 用量追踪**：Slack 的 Analytics 页面显示消息量、活跃用户数，但不追踪每个 Bot 的 API 调用次数、资源消耗。管理员看不到"代码助手 Agent 本周调用了 5,821 次 API"
- **没有审批策略**：Slack 没有"高风险操作需人工审批"的机制。一个被授予 `files:write` 权限的 Bot 可以无限制地写入文件，没有任何审批门控
- **没有成本归因**：Slack 的付费模式是按人类席位计费。Bot 不计入席位、不产生独立的成本记录。管理员无法回答"这个月 Agent 消耗了多少 Credits"

**Microsoft Teams Admin Center 的致命限制：**
- **Copilot 是全局功能而非被管对象**：Teams Admin Center 可以管理用户许可证、Teams 策略、会议设置，但 Copilot 不是一个可以在 Admin 中独立管理的"席位"。管理员可以启用/禁用 Copilot 许可证，但不能控制 Copilot 的具体操作权限（如"允许读文件但禁止写文件"）
- **Bot 权限管理分散**：Teams Bot 的权限通过 Azure AD App Registration 管理，与 Teams Admin Center 是两个独立系统。管理员需要在 Azure Portal 中配置 Bot 权限，然后回到 Teams Admin Center 管理策略——没有统一视图
- **用量分析不含 AI 维度**：Teams Admin Center 的 Usage Reports 显示活跃用户、消息数、会议数，但不追踪 Copilot 或 Bot 的 API 调用量、Token 消耗量、费用支出
- **没有 Agent 审批机制**：没有"Agent 执行高风险操作前需要人工审批"的策略配置。Copilot 的行为由全局策略控制，不支持操作级审批
- **没有统一席位概念**：人类用户有 M365 许可证，Bot/Copilot 有各自的许可证体系——管理员需要在多个页面间切换才能了解全局席位使用情况

**GitHub Organization Settings 的致命限制：**
- **成员管理只覆盖人类**：GitHub Org Settings → People 页面只列出人类成员。GitHub Apps 在 Developer Settings 中管理，Copilot 在 Copilot Settings 中管理——三个独立的管理入口
- **没有 Agent 执行权限控制**：GitHub App 的权限是仓库级别的（read/write Contents、Issues、Pull requests），不支持"代码执行 / 文件写入 / 外部 API 调用 / 数据库操作"这样的运行时权限开关
- **Copilot 用量追踪有限**：GitHub Copilot Metrics 显示接受/拒绝的代码建议数、活跃用户数，但不追踪 Copilot Coding Agent 的完整执行日志、API 调用量、执行时长
- **没有审批工作流**：GitHub 没有"Agent 提交代码前需要人工审批"的管理后台配置（Code Review 是代码层面的流程，不是管理后台的审批策略）
- **成本分摊不可见**：GitHub Copilot 按席位计费，但管理员看不到"代码助手 Agent 产生了多少 Token 费用"——只有一个总账单

**Jira Administration 的致命限制：**
- **用户管理与自动化割裂**：Jira 的 User Management 管理人类用户（添加/移除/角色），Automation Rules 在另一个入口管理。管理员无法在一个页面看到"人类用户 + 自动化 Agent"的统一席位表
- **没有 AI Agent 管理维度**：Atlassian Intelligence 是平台功能，不是一个可管理的"Agent 实体"。管理员无法看到 AI 的操作日志、用量统计
- **权限体系只针对人类**：Jira 的 Project Permissions Scheme 精细但只适用于人类用户。Automation Rules 的权限是"全有或全无"——要么启用自动化、要么禁用，不支持按操作类型开关
- **没有审计日志的 AI 维度**：Jira 的 Audit Log 记录人类操作，但 Automation Rules 的执行日志在另一个页面。管理员无法在一个统一的审计视图中审查所有操作——无论是人类还是 Agent 发起的

**Linear Workspace Settings 的致命限制：**
- **极简管理不支持 Agent**：Linear 的 Settings → Members 只列出人类用户，没有 Bot/Agent 管理入口。Linear AI 是内嵌功能，不可独立管理
- **没有细粒度权限控制**：Linear 的权限模型是 Admin / Member / Guest，没有针对 AI 行为的操作级开关
- **没有用量分析**：Linear 的 Settings 中没有 API 调用量、AI 使用量、Credits 消耗等分析页面
- **没有审批策略**：没有任何操作需要管理后台级别的审批配置

**Vercel Dashboard 的致命限制：**
- **团队管理只针对人类**：Vercel 的 Team Settings → Members 只管理人类开发者。Vercel AI SDK 的用量在 Usage 页面显示，但不与具体的 Agent 实体关联
- **用量分析缺乏 Agent 维度**：Vercel 的 Usage 页面显示带宽、函数调用、构建时间，但不追踪"哪个 Agent 消耗了多少资源"
- **权限管理不支持 Agent**：Vercel 的 Access Control（Owner / Member / Viewer）只适用于人类用户

**AWS IAM Console 的致命限制：**
- **过于复杂，不适合产品级 Agent 管理**：AWS IAM 的 Policy / Role / User / Group 体系对 Agent 权限管理来说过于底层和复杂。配置一个 Agent 的权限可能需要编写数十行 JSON Policy
- **没有可视化控制面板**：AWS IAM 没有"开关式"权限控制 UI——管理员需要编辑 JSON Policy 文档来修改权限
- **审计日志需要额外服务**：AWS CloudTrail 是独立服务，与 IAM Console 分离。管理员需要在多个控制台之间切换
- **没有审批工作流**：IAM 本身不提供"操作审批"机制——需要额外使用 AWS Systems Manager Change Manager 或第三方工具

### 1.2 核心洞察

所有现有管理后台可以用一句话概括：**"管理后台 = 管理人类用户 + 附带一些 App/Bot 配置页面"**。但 AI-Native 时代的管理后台应该是：**"管理后台 = 统一管理人类和 Agent 的席位、权限、用量、成本和审批策略，提供一个控制中心让管理员全局掌控 HxA 工作空间的运营状况"**。

```
现状（人类中心的管理模型）：
  管理后台（Slack Admin / Teams Admin / Jira Admin / GitHub Org Settings）
  - 席位管理：只管人类用户
  - 权限控制：只控制人类用户的操作权限
  - 用量分析：只统计人类用户的活跃度和消息量
  - AI/Bot：隐藏在"集成"或"应用"的子页面中，独立管理
  - 成本：按人类席位计费，AI 消耗不可见
  - 审批：无 Agent 操作审批机制
  
  ↓ 问题：管理员无法一站式掌控 HxA 工作空间的全貌

CODE-YI 模型（HxA 统一治理模型）：
  管理后台 = Workspace 管理员的控制中心
  - 系统概览：4 个 KPI 卡（Agent 数 / 活跃用户 / API 调用量 / Credits 消耗）+ 7 天趋势图
  - 席位管理：人类和 Agent 在同一张表格中统一展示和管理
  - 权限控制：开关式控制 Agent 的操作权限（代码执行 / 文件写入 / 外部 API / 数据库操作）
  - 审批策略：高风险操作需人工审批、费用超限告警、自动回滚、操作日志审计
  - 导出报告：一键导出系统使用报告
```

### 1.3 市场机会

- 2025-2026 年，企业级 AI Agent 部署量爆发式增长（GitHub Copilot、Amazon CodeWhisperer、Cursor Agent、Devin、OpenAI Codex 等），但**没有一个管理后台产品**能让 Workspace 管理员在同一个页面中看到"人类成员 + Agent 成员的统一席位表、每个 Agent 的操作权限开关、每个实体的资源消耗量、全局 Credits 成本"
- Gartner 2025 报告将"AI Agent Governance"列为企业 IT 治理的 Top 3 新兴需求——企业需要知道"谁部署了哪些 Agent、这些 Agent 有什么权限、它们消耗了多少资源、高风险操作是否经过审批"。但现有管理工具没有提供这些治理能力
- 随着 AI Agent 成为真正的"数字员工"（承担代码编写、测试、Review、部署等任务），Agent 的"人力成本"（API 调用费、Token 费、计算资源费）将成为企业运营成本的重要组成部分。管理者需要像管理人力成本一样管理 Agent 成本——但没有工具支持这一点
- 高风险 Agent 操作（代码执行、数据库操作、外部 API 调用）引发的安全事件正在增加。企业需要"审批 + 审计"的双保险机制，但现有管理后台没有 Agent 操作审批功能
- 这是 CODE-YI 的差异化窗口：一个**将人类和 Agent 作为统一席位管理、以开关式权限控制实现 Agent 治理、以审批工作流保障高风险操作安全、以 KPI 仪表盘提供运营全景的 AI-Native 管理后台**

---

## 2. 产品愿景

### 2.1 一句话定位

**CODE-YI 管理后台是全球首个将人类成员和 AI Agent 作为统一席位管理、以开关式权限控制实现 Agent 细粒度操作治理、以审批工作流和审计日志保障高风险操作安全、以 KPI 仪表盘和用量分析提供 HxA 工作空间运营全景的 AI-Native 管理控制中心。**

### 2.2 核心价值主张

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        CODE-YI 管理后台                                       │
├──────────────────┬──────────────────────┬──────────────────────┬─────────────┤
│ 系统概览          │ 席位管理             │ 权限控制              │ 审批与审计   │
│                  │                      │                      │             │
│ 4 KPI 卡片       │ 人类 + Agent 统一表格 │ Agent 操作权限开关    │ 高风险审批   │
│ 7 天趋势图        │ 角色/类型/状态       │ 代码执行 ON/OFF      │ 费用超限告警 │
│ Agent 数 +1      │ 最近活跃时间         │ 文件写入 ON/OFF      │ 自动回滚     │
│ 活跃用户 28 +12% │ 本周 API 调用量      │ 外部API ON/OFF       │ 操作日志审计 │
│ API 14.2k +23%   │ 在线/活跃/离线状态   │ 数据库操作 ON/OFF    │ 审计报告导出 │
│ Credits $842 +5% │ 操作列（编辑/移除）   │ 权限继承与覆盖       │ 合规追踪     │
└──────────────────┴──────────────────────┴──────────────────────┴─────────────┘
```

### 2.3 核心差异化

| 维度 | Slack Admin | Teams Admin | GitHub Org | Jira Admin | Linear Settings | Vercel Dashboard | AWS IAM | **CODE-YI Admin** |
|------|------------|-------------|------------|------------|-----------------|------------------|---------|-------------------|
| 人+Agent 统一席位 | 不支持 | 不支持 | 不支持 | 不支持 | 不支持 | 不支持 | 部分（IAM User/Role） | **原生支持，同一表格** |
| Agent 操作权限开关 | 无 | 无 | 无 | 无 | 无 | 无 | JSON Policy | **可视化开关** |
| KPI 仪表盘（含 Agent） | 部分 | 部分 | 部分 | 部分 | 无 | 部分 | CloudWatch | **4 KPI + 趋势图** |
| Agent 用量追踪 | 无 | 无 | 有限 | 无 | 无 | 有限 | CloudWatch | **每 Agent API 调用量** |
| Agent 成本归因 | 无 | 无 | 无 | 无 | 无 | 全局 | Cost Explorer | **每 Agent Credits** |
| 高风险操作审批 | 无 | 无 | 无 | 无 | 无 | 无 | 需额外服务 | **内置审批工作流** |
| 操作审计日志 | 基础 | 基础 | 基础 | 有 | 无 | 有限 | CloudTrail | **统一审计（人+Agent）** |
| 自动回滚 | 无 | 无 | Git revert | 无 | 无 | Rollback | 无 | **策略化自动回滚** |
| 一键导出报告 | 有 | 有 | 无 | 有 | 无 | 无 | 需额外配置 | **一键导出** |

### 2.4 设计理念

**"Control Center for HxA Workspace"** ——管理后台是 HxA 工作空间的控制塔，管理员在一个页面中掌控全局。

Stephanie 的设计稿（Screen 7-9）完美体现了这一理念：页面顶部是 4 个 KPI 卡片（Agent 数、活跃用户、API 调用量、Credits 消耗），每个卡片都有变化趋势标识；中间是统一的席位管理表格，人类成员（陈朗辉、李恩琪、张伟）和 Agent 成员（代码助手、测试 Agent、产品助手）在同一张表中并列显示，每行包含角色、类型、最近活跃时间、本周 API 调用量、状态等关键信息；右侧面板是 Agent 执行权限的开关控制和审批策略配置；右上角是"导出报告"按钮。管理员打开这一个页面，就能全局掌控 Workspace 的人力与 Agent 资源、权限配置、运营指标——不需要在多个管理页面之间来回切换。

---

## 3. 竞品对标

### 3.1 管理后台 AI 治理能力对比

| 功能 | Slack Admin | Teams Admin | GitHub Org | Jira Admin | Linear | Vercel | AWS IAM | **CODE-YI** |
|------|------------|-------------|------------|------------|--------|--------|---------|-------------|
| 人+Agent 统一席位表 | - | - | - | - | - | - | ★★ | **★★★★★** |
| Agent 操作权限开关 | - | - | - | - | - | - | ★★★ | **★★★★★** |
| KPI 仪表盘 | ★★★ | ★★★★ | ★★★ | ★★★ | ★★ | ★★★ | ★★★★ | **★★★★★** |
| Agent 用量追踪 | - | - | ★★ | - | - | ★★ | ★★★★ | **★★★★★** |
| 成本归因分析 | ★★ | ★★★ | ★★ | ★★ | ★★ | ★★★ | ★★★★ | **★★★★★** |
| 操作审批工作流 | - | - | - | - | - | - | ★★ | **★★★★** |
| 审计日志 | ★★★ | ★★★★ | ★★★ | ★★★★ | ★★ | ★★★ | ★★★★★ | **★★★★** |
| 自动回滚策略 | - | - | ★★ | - | - | ★★★ | - | **★★★★** |
| 报告导出 | ★★★★ | ★★★★ | ★★ | ★★★★ | ★ | ★★ | ★★★ | **★★★★** |
| 实时状态监控 | ★★★ | ★★★★ | ★★ | ★★ | ★★ | ★★★ | ★★★★ | **★★★★★** |

### 3.2 深度分析

**Slack Admin Console：**
- 优势：Workspace Analytics 提供消息量、活跃用户等基本指标。Audit Logs（Enterprise Grid 版本）记录管理操作。用户管理流程成熟（SCIM 同步、SSO 集成）
- 劣势：Bot/App 不纳入席位管理。没有 Bot 级别的用量追踪——Slack 的 Analytics 只追踪人类用户的行为。没有 API 调用量、Token 消耗等 AI 相关指标。没有审批工作流
- 核心缺失：无法回答"这个 Workspace 里有多少 Agent 在工作、它们本周调用了多少次 API、消耗了多少费用"

**Microsoft Teams Admin Center：**
- 优势：与 Azure AD 深度集成，支持大规模用户管理。Usage Reports 提供多维度分析。Compliance 功能（eDiscovery、Legal Hold）满足企业合规需求
- 劣势：Copilot 的管理在 M365 Admin Center 而非 Teams Admin Center——管理入口分散。没有 Agent 级别的权限开关。用量报告不追踪 AI/Bot 的资源消耗。审批需要通过 Power Automate 外部实现
- 核心缺失：管理员需要在 Teams Admin + M365 Admin + Azure AD + Azure Portal 四个管理入口之间切换才能完成"人类 + AI"的全面治理

**GitHub Organization Settings：**
- 优势：Organization Members 管理、Team 权限管理成熟。Copilot Metrics 提供代码建议接受率等 AI 特定指标。Audit Log 记录详细的组织操作
- 劣势：Members 页面只管人类。Copilot 设置在独立页面。GitHub Apps 在另一个入口。三个管理维度完全分离。没有 Agent 操作级权限开关。Copilot Metrics 不追踪 Coding Agent 的完整执行日志和资源消耗
- 核心缺失：无法在一个管理页面中看到"开发团队 5 人 + 3 个 Agent"的统一视图，也无法控制 Agent 的执行权限

**Jira Administration：**
- 优势：Permission Schemes + Project Roles 提供企业级权限粒度。Audit Log 功能完善。用户管理支持多种目录集成（AD、LDAP、Crowd）
- 劣势：权限体系只针对人类用户设计。Automation Rules 没有角色化管理——它们是全局规则，不是可被分配角色和权限的"Agent 实体"。没有 AI 用量追踪。Audit Log 不包含 AI/Automation 的操作维度
- 核心缺失：无法将 Automation Rules / Atlassian Intelligence 视为"Agent 席位"进行统一管理

**Linear Workspace Settings：**
- 优势：极简设计，管理操作直观高效。团队设置界面清爽
- 劣势：管理功能极度精简——只有成员管理、基本权限、集成管理。没有 Analytics、没有 Audit Log、没有 Usage Reports。Linear AI 不可独立管理
- 核心缺失：缺乏企业级管理能力——没有权限控制、审批、审计、分析中的任何一项

**Vercel Dashboard：**
- 优势：Team Settings 中的使用量追踪（带宽、函数调用、构建时间）清晰。成本透明（Usage → Billing）
- 劣势：用量追踪不区分"人类操作"和"AI/Bot 操作"。没有 Agent 席位概念。权限只有 Owner / Member / Viewer 三级，不支持 Agent 操作级控制
- 核心缺失：Vercel AI SDK 的使用量不与具体 Agent 实体关联——管理员看不到"哪个 Agent 消耗了多少资源"

**AWS IAM Console：**
- 优势：最精细的权限模型（Policy + Role + User + Group + Service Account）。与 CloudTrail 集成提供完整审计。与 Cost Explorer 集成支持成本分析
- 劣势：配置复杂度极高——定义一个 Agent 的权限可能需要编写数十行 JSON Policy。没有"开关式"权限 UI——管理员必须理解 IAM Policy 语法。审计日志需要额外配置 CloudTrail + S3 + Athena。成本分析需要额外配置 Cost Explorer 和 Tags
- 核心缺失：IAM 是基础设施级别的权限管理，不是产品级别的 Agent 治理——它对非 DevOps 人员不友好

### 3.3 竞品演进方向判断

| 竞品 | 可能的演进方向 | CODE-YI 的时间窗口 |
|------|--------------|-------------------|
| Slack | Admin Console 可能增加"Agent Analytics"页面，显示 Bot 的使用量 | 12-18 个月——Slack 的产品决策周期长，且当前重心在 Agent Orchestration 而非管理 |
| Microsoft | M365 Admin 可能整合 Copilot 管理页面，提供统一的 AI 用量视图 | 18-24 个月——Microsoft 的管理后台分散在多个产品中，整合需要时间 |
| GitHub | Organization Settings 可能增加 Copilot Agent 管理入口 | 12-18 个月——GitHub 已在 Copilot Metrics 中探索 AI 分析 |
| Vercel | Dashboard 可能增加 AI 用量追踪和 Agent 成本归因 | 6-12 个月——Vercel 的 AI 生态演进快 |
| AWS | IAM 可能推出"AI Agent 管理简化版" | 24+ 个月——AWS 的 IAM 重构周期极长 |

**结论：** CODE-YI 有 6-12 个月的差异化窗口。如果在这个窗口内建立"人+Agent 统一席位管理 + 开关式权限控制 + 审批审计 + KPI 仪表盘"的产品认知，就能占据 AI-Native 管理后台的定义权。

---

## 4. 技术突破点分析

### 4.1 人+Agent 统一席位模型 (Unified Seat Model)

**传统模型：**
```
Admin Console:
  Members Page: [Human_1, Human_2, Human_3]         // 人类席位
  Apps Page:    [Bot_A, Bot_B]                       // 独立管理，不在同一视图
  Analytics:    仅追踪人类活跃度
  Billing:      仅按人类席位计费
```

**CODE-YI 模型：**
```
Admin Console:
  Seats Table: [
    { name: "陈朗辉", role: "管理员", type: "人类", lastActive: "刚刚",    apiCalls: 1245, status: "活跃" },
    { name: "李恩琪", role: "成员",   type: "人类", lastActive: "2小时前", apiCalls: 876,  status: "活跃" },
    { name: "张伟",   role: "成员",   type: "人类", lastActive: "1天前",   apiCalls: 2103, status: "活跃" },
    { name: "代码助手", role: "Agent", type: "Agent", lastActive: "刚刚",  apiCalls: 5821, status: "在线" },
    { name: "测试Agent", role: "Agent", type: "Agent", lastActive: "30分钟前", apiCalls: 2456, status: "在线" },
    { name: "产品助手", role: "Agent", type: "Agent", lastActive: "1天前", apiCalls: 890,  status: "离线" },
  ]
```

**核心突破：** 人类和 Agent 共享同一个席位表格。管理员在一个视图中看到所有"工作实体"——无论是人类还是 Agent。每个实体都有角色、类型、活跃状态、API 调用量等统一维度的数据。这是 Stephanie 设计稿中最核心的创新——打破了"人类管理"和"Bot 管理"的物理隔离。

**技术关键点：**
- 数据库层：`workspace_seats` 表统一存储所有席位，通过 `seat_type` 字段区分人类和 Agent
- API 层：席位列表 API 统一返回 `Seat[]`，客户端无需调用两个不同的 API
- 前端层：统一的表格组件，通过 `type` 字段渲染不同的类型标签（"人类"蓝色标签 / "Agent"绿色标签）
- 统计层：用量指标（API 调用量、最近活跃时间）对人类和 Agent 使用相同的采集和展示逻辑

### 4.2 开关式 Agent 权限控制 (Toggle-Based Permission Control)

**传统模型（如 AWS IAM）：**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:GetObject"],
      "Resource": "arn:aws:s3:::my-bucket/*"
    }
  ]
}
```
→ 管理员需要理解 Policy 语法才能配置权限

**CODE-YI 模型：**
```
Agent 执行权限面板：
  ┌──────────────────────────────┐
  │ 代码执行     [████████ ON ]  │  ← Toggle 开关
  │ 文件写入     [████████ ON ]  │
  │ 外部API调用  [████████ ON ]  │
  │ 数据库操作   [░░░░░░░░ OFF]  │
  └──────────────────────────────┘
```
→ 管理员用开关切换权限，零学习成本

**核心突破：** 将复杂的权限策略简化为可视化的开关控制。每个权限维度（代码执行、文件写入、外部 API 调用、数据库操作）对应一个 Toggle Switch。管理员不需要理解权限策略语法——只需翻转开关。这种设计大幅降低了 Agent 权限管理的门槛，让非技术管理者也能安全地治理 Agent。

**技术关键点：**
- 权限维度预定义：系统内置四个核心操作权限维度，每个维度有明确的 Allow/Deny 语义
- 权限生效路径：Toggle 变更 → 更新 `agent_permissions` 表 → 清除 Redis 缓存 → 下次 Agent 操作时检查新权限
- 权限继承：Workspace 级默认权限 → Agent 类型级覆盖 → 单个 Agent 级覆盖
- 实时生效：开关切换后权限立即生效，无需重启 Agent

### 4.3 KPI 仪表盘与趋势分析 (KPI Dashboard)

**核心突破：** 将 Workspace 的运营状态浓缩为 4 个核心 KPI 卡片，每个卡片不仅显示当前值，还显示环比变化和 7 天趋势图。

```
KPI 卡片设计（来自 Stephanie 设计稿 Screen 7）：

┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  4 Agents    │  │ 28 活跃用户   │  │ 14.2k API    │  │ $842 Credits │
│  +1 本月      │  │ +12% ↑       │  │ +23% ↑       │  │ +5% ↑        │
│  ▁▂▃▄▅▆▇█   │  │  ▁▂▃▄▅▆▇█   │  │  ▁▂▃▄▅▆▇█   │  │  ▁▂▃▄▅▆▇█   │
│  (7天趋势)    │  │  (7天趋势)    │  │  (7天趋势)    │  │  (7天趋势)    │
└──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘
```

**技术关键点：**
- KPI 数据通过后台 Worker 定时聚合（每 5 分钟），写入 `usage_metrics` 表
- 趋势图数据从 `usage_metrics` 表的 7 天时间序列中提取
- 环比计算：当前值 vs 上一周期（本月 vs 上月、本周 vs 上周）
- 前端使用轻量 Sparkline 图表（如 Recharts 的 Sparkline 组件）渲染趋势

### 4.4 审批工作流引擎 (Approval Workflow Engine)

**传统模型：** 没有 Agent 操作审批机制——Agent 一旦获得权限就可以无限制执行。

**CODE-YI 模型：**
```
审批策略配置面板：
  ┌──────────────────────────────────────────┐
  │ 审批策略                                   │
  │                                          │
  │ ☑ 高风险操作需人工审批                     │
  │   → Agent 执行数据库删除、外部支付等操作前   │
  │     自动暂停并发送审批请求给管理员           │
  │                                          │
  │ ☑ 费用超限告警                             │
  │   → 单个 Agent 单日 Credits > $100 时      │
  │     自动通知管理员                          │
  │                                          │
  │ ☑ 自动回滚                                 │
  │   → Agent 操作导致错误率 > 阈值时           │
  │     自动撤销最近的操作                      │
  │                                          │
  │ ☑ 操作日志审计                             │
  │   → 所有 Agent 操作记录完整日志             │
  │     支持按时间/Agent/操作类型查询           │
  └──────────────────────────────────────────┘
```

**核心突破：** 在 Agent 操作和实际执行之间插入一个"审批门控"。高风险操作不是直接执行，而是先创建审批请求，等待管理员批准后才执行。这是 AI 安全治理的关键机制——确保 Agent 的高风险行为始终在人类监督之下。

**技术关键点：**
- 审批请求异步化：Agent 发起高风险操作 → 创建 `approval_request` → Agent 进入等待状态 → 管理员审批 → Agent 继续执行或取消
- 审批超时机制：超过 N 小时未审批 → 自动拒绝（安全优先）
- 费用预测：Agent 执行操作前，系统预估 Credits 消耗，超过阈值自动触发告警
- 自动回滚：基于操作日志的逆操作——每个操作记录"回滚操作"元数据

---

## 5. 用户故事

### 5.1 系统概览

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-AD-01 | Workspace 管理员 | 作为管理员，我想打开管理后台首页看到 4 个 KPI 卡片（Agent 数/活跃用户/API 调用量/Credits 消耗），以便快速了解 Workspace 运营状况 | 4 个 KPI 卡片正确展示当前值、环比变化百分比、7 天趋势迷你图 | P0 |
| US-AD-02 | Workspace 管理员 | 作为管理员，我想看到 KPI 的环比变化趋势（上升/下降/持平），以便判断 Workspace 健康度 | 环比变化以百分比和箭头展示（+12%↑ 绿色 / -5%↓ 红色 / 0% 灰色） | P0 |
| US-AD-03 | Workspace 管理员 | 作为管理员，我想看到过去 7 天的趋势图，以便发现异常波动 | 每个 KPI 卡片底部有 Sparkline 趋势图，7 个数据点，可 Hover 查看具体日期数值 | P0 |

### 5.2 席位管理

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-AD-04 | Workspace 管理员 | 作为管理员，我想在一张统一表格中看到所有人类成员和 Agent 成员，以便一览全局席位使用情况 | 表格含列：成员名、角色、类型（人类/Agent）、最近活跃、本周 API 调用、状态（活跃/在线/离线），数据按最近活跃时间降序排列 | P0 |
| US-AD-05 | Workspace 管理员 | 作为管理员，我想通过"类型"标签一眼区分人类成员和 Agent 成员，以便快速识别 | 人类类型显示蓝色"人类"标签，Agent 类型显示绿色"Agent"标签 | P0 |
| US-AD-06 | Workspace 管理员 | 作为管理员，我想看到每个席位（无论人类还是 Agent）的本周 API 调用量，以便了解资源消耗 | API 调用量以数字展示（如 1,245 / 5,821），支持排序 | P0 |
| US-AD-07 | Workspace 管理员 | 作为管理员，我想通过状态列了解每个成员的在线状态，以便知道当前可用的工作力量 | 人类：活跃（绿色）/ 离线（灰色）；Agent：在线（绿色）/ 在线（蓝色表示忙碌）/ 离线（灰色） | P0 |
| US-AD-08 | Workspace 管理员 | 作为管理员，我想在操作列中编辑成员角色或移除成员，以便管理席位 | 每行有操作按钮：编辑（打开角色设置）、移除（确认弹窗） | P0 |
| US-AD-09 | Workspace 管理员 | 作为管理员，我想搜索和筛选席位列表（按名称搜索、按类型筛选、按状态筛选），以便快速找到目标 | 表格上方有搜索框和筛选下拉 | P0 |
| US-AD-10 | Workspace 管理员 | 作为管理员，我想添加新的人类成员或 Agent 到 Workspace，以便扩充席位 | 点击"添加席位"按钮 → 选择类型（人类/Agent）→ 填写信息 → 添加成功 | P0 |

### 5.3 Agent 执行权限控制

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-AD-11 | Workspace 管理员 | 作为管理员，我想通过开关控制 Agent 是否可以执行代码，以便防止不可信 Agent 运行代码 | "代码执行"Toggle 开关，ON=允许，OFF=禁止。变更即时生效 | P0 |
| US-AD-12 | Workspace 管理员 | 作为管理员，我想通过开关控制 Agent 是否可以写入文件，以便防止文件系统被篡改 | "文件写入"Toggle 开关，ON=允许，OFF=禁止 | P0 |
| US-AD-13 | Workspace 管理员 | 作为管理员，我想通过开关控制 Agent 是否可以调用外部 API，以便防止数据泄露 | "外部 API 调用"Toggle 开关，ON=允许，OFF=禁止 | P0 |
| US-AD-14 | Workspace 管理员 | 作为管理员，我想通过开关控制 Agent 是否可以执行数据库操作，以便保护数据安全 | "数据库操作"Toggle 开关，ON=允许，OFF=禁止 | P0 |
| US-AD-15 | Workspace 管理员 | 作为管理员，我想为不同的 Agent 设置不同的权限组合，以便按需授权 | 选择特定 Agent → 独立设置其 4 个权限开关，覆盖 Workspace 默认配置 | P0 |

### 5.4 审批策略

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-AD-16 | Workspace 管理员 | 作为管理员，我想启用"高风险操作需人工审批"策略，以便在 Agent 执行危险操作前人工把关 | Checkbox 启用后，Agent 的高风险操作（数据库删除、外部支付等）自动暂停并生成审批请求 | P1 |
| US-AD-17 | Workspace 管理员 | 作为管理员，我想配置"费用超限告警"的阈值，以便控制 Agent 的成本 | 输入阈值金额（如 $100/天/Agent），超限时自动通知管理员 | P1 |
| US-AD-18 | Workspace 管理员 | 作为管理员，我想启用"自动回滚"策略，以便在 Agent 操作导致异常时自动恢复 | Checkbox 启用后，当 Agent 操作后错误率超过阈值时，自动撤销最近操作 | P1 |
| US-AD-19 | Workspace 管理员 | 作为管理员，我想启用"操作日志审计"，以便追溯所有 Agent 的操作历史 | Checkbox 启用后，所有 Agent 操作记录完整日志，可按时间/Agent/操作类型查询 | P1 |
| US-AD-20 | Workspace 管理员 | 作为管理员，我想查看待审批列表并批准或拒绝审批请求，以便处理 Agent 的高风险操作 | 审批列表展示请求详情（Agent 名称、操作类型、影响范围）、批准和拒绝按钮 | P1 |

### 5.5 用量分析与报告

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-AD-21 | Workspace 管理员 | 作为管理员，我想看到每个 Agent 的详细 API 调用趋势图，以便分析用量模式 | 点击 Agent 行 → 展开详细面板 → 显示 7天/30天 API 调用趋势折线图 | P1 |
| US-AD-22 | Workspace 管理员 | 作为管理员，我想看到 Workspace 级别的 Credits 消耗明细（按 Agent 分摊），以便做成本分析 | Credits 消耗饼图/条形图，按 Agent 分组展示 | P1 |
| US-AD-23 | Workspace 管理员 | 作为管理员，我想一键导出系统使用报告（PDF/CSV），以便向上级汇报或存档 | 点击"导出报告"按钮 → 选择格式（PDF/CSV）→ 下载包含 KPI、席位列表、用量分析的完整报告 | P1 |
| US-AD-24 | Workspace 管理员 | 作为管理员，我想设置定期自动发送使用报告到我的邮箱，以便持续跟踪 | 配置自动报告频率（每周/每月）和收件邮箱 | P2 |
| US-AD-25 | Workspace 管理员 | 作为管理员，我想查看审计日志并按条件筛选，以便排查问题 | 审计日志列表支持按时间范围、操作者（人类/Agent）、操作类型、结果筛选 | P1 |

---

## 6. 功能拆分

### 6.1 P0 功能（MVP，必须实现）

#### 6.1.1 系统概览仪表盘

**4 个 KPI 卡片：**
- **Agent 数量卡**：当前 Workspace 中活跃 Agent 数量 + 本月新增数 + 7 天趋势图
- **活跃用户卡**：过去 7 天活跃的用户数（人类+Agent）+ 环比变化百分比 + 7 天趋势图
- **API 调用量卡**：本周 API 调用总量 + 环比变化百分比 + 7 天趋势图
- **Credits 消耗卡**：本月 Credits 消耗金额 + 环比变化百分比 + 7 天趋势图

**KPI 数据源：**
```
Agent 数量:
  数据源: workspace_seats 表 WHERE seat_type='agent' AND status='active'
  本月新增: 本月 created_at 的 Agent 计数
  趋势: 过去 7 天每天的 Agent 总数快照

活跃用户:
  数据源: usage_metrics 表 WHERE metric_type='daily_active'
  环比: 本周活跃 vs 上周活跃
  趋势: 过去 7 天每天的活跃用户数

API 调用量:
  数据源: usage_metrics 表 WHERE metric_type='api_calls'
  环比: 本周调用量 vs 上周调用量
  趋势: 过去 7 天每天的 API 调用总量

Credits 消耗:
  数据源: cost_records 表 SUM(amount)
  环比: 本月消耗 vs 上月消耗
  趋势: 过去 7 天每天的 Credits 消耗
```

**卡片交互：**
- Hover 趋势图 → 显示具体日期和数值的 Tooltip
- 点击卡片 → 跳转到对应的详细分析页面（P1）

#### 6.1.2 统一席位管理表格

**表格结构（对应 Stephanie 设计稿 Screen 7）：**

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ 搜索 [________________]  筛选: 类型 [全部▾]  状态 [全部▾]      [+ 添加席位]   │
├──────────┬─────────┬─────────┬──────────┬───────────┬────────┬──────────────┤
│ 成员名    │ 角色     │ 类型     │ 最近活跃  │ 本周API调用 │ 状态   │ 操作          │
├──────────┼─────────┼─────────┼──────────┼───────────┼────────┼──────────────┤
│ 陈朗辉    │ 管理员   │ 🔵人类   │ 刚刚      │ 1,245      │ 🟢活跃  │ [编辑][移除]  │
│ 李恩琪    │ 成员     │ 🔵人类   │ 2小时前   │ 876        │ 🟢活跃  │ [编辑][移除]  │
│ 张伟      │ 成员     │ 🔵人类   │ 1天前     │ 2,103      │ 🟢活跃  │ [编辑][移除]  │
│ 代码助手  │ Agent   │ 🟢Agent  │ 刚刚      │ 5,821      │ 🟢在线  │ [编辑][移除]  │
│ 测试Agent │ Agent   │ 🟢Agent  │ 30分钟前  │ 2,456      │ 🟢在线  │ [编辑][移除]  │
│ 产品助手  │ Agent   │ 🟢Agent  │ 1天前     │ 890        │ ⚫离线  │ [编辑][移除]  │
└──────────┴─────────┴─────────┴──────────┴───────────┴────────┴──────────────┘
                                                                    第 1-6 / 6 条
```

**表格功能：**
- 排序：支持按每列排序（默认按最近活跃时间降序）
- 搜索：按成员名模糊搜索
- 筛选：按类型（全部/人类/Agent）、按状态（全部/活跃/在线/离线）筛选
- 分页：每页 20 条，支持翻页
- 操作列：编辑（修改角色）、移除（确认后移除，需要二次确认）

**添加席位：**
- 点击"添加席位" → 选择类型
  - 人类：输入邮箱发送邀请 / 生成邀请链接
  - Agent：从 Agent 市场（Module 5）选择 / 创建自定义 Agent

**移除席位：**
- 点击"移除" → 弹出确认框
  - 人类：提示是否有未完成任务，可选择重新分配
  - Agent：提示是否有执行中任务，可选择等待完成或强制移除

#### 6.1.3 Agent 执行权限控制面板

**权限开关面板（对应 Stephanie 设计稿 Screen 8）：**

```
┌──────────────────────────────────────────┐
│ Agent 执行权限                             │
│                                          │
│ 应用范围: [所有 Agent ▾]                   │
│                                          │
│ 代码执行                                  │
│ 允许 Agent 执行代码片段和脚本               │
│ [████████████ ON ]                        │
│                                          │
│ 文件写入                                  │
│ 允许 Agent 创建、修改和删除文件             │
│ [████████████ ON ]                        │
│                                          │
│ 外部 API 调用                              │
│ 允许 Agent 调用外部第三方 API               │
│ [████████████ ON ]                        │
│                                          │
│ 数据库操作                                 │
│ 允许 Agent 执行数据库读写操作               │
│ [░░░░░░░░░░░░ OFF]                        │
│                                          │
│            [保存配置]  [重置为默认]          │
└──────────────────────────────────────────┘
```

**权限维度定义：**

| 权限维度 | 说明 | 默认值 | 风险等级 |
|---------|------|--------|---------|
| 代码执行 (code_execution) | Agent 可以运行代码片段、执行脚本、编译和运行程序 | ON | 高 |
| 文件写入 (file_write) | Agent 可以创建、修改、删除文件系统中的文件 | ON | 高 |
| 外部 API 调用 (external_api) | Agent 可以向外部第三方服务发起 HTTP 请求 | ON | 中 |
| 数据库操作 (database_ops) | Agent 可以执行数据库查询、插入、更新、删除操作 | OFF | 极高 |

**权限应用范围：**
- Workspace 级默认：对所有 Agent 生效
- Agent 级覆盖：选择特定 Agent → 单独设置其权限（覆盖 Workspace 默认）

### 6.2 P1 功能

#### 6.2.1 审批策略配置

**审批策略面板（对应 Stephanie 设计稿 Screen 9）：**

```
┌──────────────────────────────────────────────────────┐
│ 审批策略                                               │
│                                                      │
│ ☑ 高风险操作需人工审批                                  │
│   当 Agent 执行以下操作时，需等待管理员审批：             │
│   ☑ 数据库删除操作 (DELETE / DROP)                      │
│   ☑ 外部支付 API 调用                                   │
│   ☑ 批量文件删除（> 10 个文件）                          │
│   ☐ 代码部署到生产环境                                   │
│   审批超时: [24小时 ▾]（超时自动拒绝）                    │
│                                                      │
│ ☑ 费用超限告警                                          │
│   单个 Agent 单日消耗 > [$100 ▾] 时通知管理员            │
│   Workspace 月度总消耗 > [$5000 ▾] 时通知管理员          │
│   通知方式: [站内通知 ▾] + [邮件 ▾]                      │
│                                                      │
│ ☑ 自动回滚                                              │
│   Agent 操作后 [5分钟 ▾] 内错误率超过 [30% ▾] 时         │
│   自动撤销该 Agent 最近 [1小时 ▾] 内的操作               │
│                                                      │
│ ☑ 操作日志审计                                          │
│   记录所有 Agent 操作的完整日志                           │
│   日志保留时间: [90天 ▾]                                 │
│   可导出格式: CSV / JSON                                │
│                                                      │
│                    [保存策略]  [重置为默认]                │
└──────────────────────────────────────────────────────┘
```

**审批请求列表：**

```
┌──────────────────────────────────────────────────────────────────────────┐
│ 待审批请求                                                     [全部已读] │
├──────────┬──────────────────────┬──────────┬──────────┬────────────────┤
│ 请求时间  │ Agent               │ 操作类型  │ 影响范围  │ 操作            │
├──────────┼──────────────────────┼──────────┼──────────┼────────────────┤
│ 5 分钟前  │ 代码助手            │ DB DELETE │ users 表  │ [批准] [拒绝]   │
│ 1 小时前  │ 测试 Agent          │ 批量删除  │ 23 个文件 │ [批准] [拒绝]   │
│ 昨天      │ 产品助手            │ 外部支付  │ $50.00   │ [已超时-拒绝]   │
└──────────┴──────────────────────┴──────────┴──────────┴────────────────┘
```

#### 6.2.2 用量分析

- 每个 Agent / 人类成员的 API 调用量趋势图（7天/30天）
- Credits 消耗按 Agent 分摊的饼图/条形图
- 最活跃 Agent Top 5 排行
- API 调用量峰值检测和告警

#### 6.2.3 审计日志查看

- 时间线形式展示所有操作日志
- 支持按时间范围、操作者（人类/Agent）、操作类型、结果（成功/失败/被拒绝）筛选
- 操作详情展开（请求参数、响应结果、执行时长）
- 支持导出为 CSV/JSON

#### 6.2.4 导出报告

- 一键导出当前时段的系统使用报告
- 报告内容：KPI 摘要、席位列表、权限配置、用量分析、审计摘要
- 导出格式：PDF（可视化报告）/ CSV（原始数据）
- 报告时间范围可选（本周/本月/自定义）

### 6.3 P2 功能

#### 6.3.1 定期自动报告

- 配置自动报告频率（每周/每月）
- 配置收件邮箱列表
- 报告模板自定义
- 报告历史记录查看

#### 6.3.2 高级审批工作流

- 多级审批（需要多个管理员同意）
- 审批委托（管理员休假时委托给其他管理员）
- 条件审批（金额 < $10 自动批准，> $10 人工审批）
- 审批 SLA 监控（审批响应时间追踪）

#### 6.3.3 自定义权限维度

- 除内置 4 个权限维度外，管理员可自定义新的权限维度
- 权限维度模板（开发环境/生产环境/测试环境）
- 基于时间的权限策略（如：Agent 只在工作时间可执行代码）

#### 6.3.4 成本预算管理

- Workspace 月度 Credits 预算设置
- 按 Agent 分配 Credits 配额
- 预算使用进度可视化
- 预算超额自动暂停 Agent

---

## 7. Agent 权限控制引擎

### 7.1 权限维度定义

CODE-YI 管理后台的 Agent 权限控制基于**四个核心操作维度**，每个维度对应一个 Toggle 开关：

```
┌──────────────────────────────────────────────────────────────────┐
│                   Agent 权限控制引擎                               │
│                                                                  │
│  ┌─── 权限维度 ───────────────────────────────────────────────┐  │
│  │                                                            │  │
│  │  code_execution （代码执行）                                │  │
│  │  ├── 覆盖范围: 代码片段运行、脚本执行、编译、测试运行         │  │
│  │  ├── 风险等级: 高                                           │  │
│  │  ├── 默认值:   ON                                           │  │
│  │  └── 审批要求: 可配置                                       │  │
│  │                                                            │  │
│  │  file_write （文件写入）                                    │  │
│  │  ├── 覆盖范围: 文件创建、修改、删除、目录操作                │  │
│  │  ├── 风险等级: 高                                           │  │
│  │  ├── 默认值:   ON                                           │  │
│  │  └── 审批要求: 批量删除需审批                               │  │
│  │                                                            │  │
│  │  external_api （外部 API 调用）                              │  │
│  │  ├── 覆盖范围: HTTP/HTTPS 出站请求、Webhook、第三方 SDK     │  │
│  │  ├── 风险等级: 中                                           │  │
│  │  ├── 默认值:   ON                                           │  │
│  │  └── 审批要求: 支付类 API 需审批                            │  │
│  │                                                            │  │
│  │  database_ops （数据库操作）                                 │  │
│  │  ├── 覆盖范围: SQL 查询、插入、更新、删除、DDL 操作          │  │
│  │  ├── 风险等级: 极高                                         │  │
│  │  ├── 默认值:   OFF                                          │  │
│  │  └── 审批要求: DELETE/DROP 操作强制审批                      │  │
│  │                                                            │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

### 7.2 权限层级与继承

CODE-YI 的权限控制采用三层继承模型：

```
优先级（从高到低）：

  Layer 3: 单 Agent 级覆盖（最高优先级）
     → 管理员为特定 Agent 单独设置的权限
     → 例如："代码助手"的代码执行=ON（即使 Workspace 级=OFF）
     
  Layer 2: Agent 类型级默认
     → 按 Agent 类型（执行者/审核者/协调者/观察者）的默认权限
     → 例如：观察者默认所有权限=OFF
     
  Layer 1: Workspace 级默认（最低优先级）
     → Workspace 管理后台中设置的全局默认权限
     → 例如：数据库操作默认=OFF
```

**权限计算规则：**

```typescript
function resolvePermission(
  agentId: string, 
  permissionDimension: string
): 'allow' | 'deny' {
  // Layer 3: 检查单 Agent 级覆盖
  const agentOverride = getAgentPermissionOverride(agentId, permissionDimension);
  if (agentOverride !== null) return agentOverride;
  
  // Layer 2: 检查 Agent 类型级默认
  const agentRole = getAgentRole(agentId);
  const roleDefault = getRolePermissionDefault(agentRole, permissionDimension);
  if (roleDefault !== null) return roleDefault;
  
  // Layer 1: 检查 Workspace 级默认
  const workspaceDefault = getWorkspacePermissionDefault(permissionDimension);
  if (workspaceDefault !== null) return workspaceDefault;
  
  // 全局兜底: 未配置的权限默认拒绝
  return 'deny';
}
```

### 7.3 权限检查流程

```
Agent 发起操作（如：执行代码）
  │
  ├── 1. 操作分类
  │     └── 判断操作属于哪个权限维度: code_execution
  │
  ├── 2. 权限计算（< 5ms，Redis 缓存）
  │     ├── 查 Redis: perm:{agent_id}:{dimension}
  │     │   └── 命中 → 直接返回 ALLOW/DENY
  │     │
  │     ├── 缓存未命中 → 三层计算
  │     │   ├── Layer 3: agent_permissions WHERE agent_id=xxx AND dimension='code_execution'
  │     │   ├── Layer 2: agent_role_default_permissions WHERE role='executor' AND dimension='code_execution'
  │     │   └── Layer 1: workspace_settings.default_permissions['code_execution']
  │     │
  │     └── 结果写入 Redis 缓存（TTL: 5 分钟）
  │
  ├── 3. 权限结果分支
  │     ├── ALLOW → 继续操作
  │     │     └── 4a. 审批检查（如果该操作需要审批）
  │     │           ├── 不需审批 → 直接执行
  │     │           └── 需审批 → 创建 approval_request → 等待审批
  │     │
  │     └── DENY → 拒绝操作
  │           └── 返回 403 + 权限不足说明 + 建议操作
  │
  └── 5. 写入审计日志（异步）
        └── audit_logs.insert({ agent_id, dimension, action, result, timestamp })
```

### 7.4 权限变更工作流

```
管理员切换权限开关
  │
  ├── 前端: Toggle Switch → API 请求
  │     POST /api/v1/admin/permissions
  │     { agent_id: "agent_codebot", dimension: "database_ops", value: "allow" }
  │
  ├── 后端: 权限更新
  │     ├── 更新 agent_permissions 表
  │     ├── 清除 Redis 缓存: perm:{agent_id}:database_ops
  │     ├── 记录变更日志: audit_logs.insert(...)
  │     └── 推送 WebSocket: admin:permission_changed
  │
  ├── 生效: Agent 下次操作时使用新权限
  │     └── 如果 Agent 正在执行中的操作不受影响（不中断正在进行的操作）
  │
  └── 通知: 可选通知 Agent（"你的数据库操作权限已开启"）
```

### 7.5 Agent 类型默认权限矩阵

不同角色（来自 Module 4 的 Agent 角色体系）有不同的默认权限配置：

| Agent 角色 | 代码执行 | 文件写入 | 外部 API | 数据库操作 | 说明 |
|-----------|---------|---------|---------|----------|------|
| 执行者 (Executor) | ON | ON | ON | OFF | 执行者需要代码、文件、API 权限来完成任务 |
| 审核者 (Reviewer) | OFF | OFF | OFF | OFF | 审核者只读——不执行代码、不写文件、不调外部 API |
| 协调者 (Coordinator) | OFF | ON | ON | OFF | 协调者需要文件写入（生成报告）和 API 调用（通知外部系统） |
| 观察者 (Observer) | OFF | OFF | OFF | OFF | 观察者纯只读——所有写操作权限默认关闭 |

> **注意：** 这是默认配置，管理员可以在管理后台中为任何 Agent 单独覆盖这些默认值。

### 7.6 权限拒绝的用户体验

当 Agent 的操作被权限拒绝时，系统需要提供清晰的反馈：

```typescript
// 权限拒绝响应
interface PermissionDeniedResponse {
  error: 'PERMISSION_DENIED';
  status: 403;
  details: {
    agent_id: string;
    agent_name: string;
    dimension: string;                    // 'code_execution' | 'file_write' | ...
    dimension_label: string;              // '代码执行' | '文件写入' | ...
    current_value: 'deny';
    
    // 帮助信息
    message: string;                      // "代码助手 的代码执行权限已关闭"
    suggestion: string;                   // "请联系 Workspace 管理员开启代码执行权限"
    admin_action_url: string;             // 管理后台中修改此权限的直链
    
    // 权限来源（帮助管理员定位配置位置）
    permission_source: 'workspace_default' | 'role_default' | 'agent_override';
  };
}
```

---

## 8. 审批与审计系统

### 8.1 审批工作流

#### 8.1.1 审批触发条件

系统内置四类审批触发条件，管理员可通过 Checkbox 启用/禁用：

```
审批触发条件：

  1. 高风险操作审批
     触发: Agent 发起 DELETE/DROP 数据库操作
     触发: Agent 发起外部支付 API 调用
     触发: Agent 批量删除文件（> 10 个文件）
     触发: Agent 修改系统配置文件
     → 操作暂停 → 创建审批请求 → 通知管理员 → 等待审批

  2. 费用超限审批
     触发: 单个 Agent 单日 Credits 消耗 > 阈值
     触发: Workspace 月度 Credits 消耗 > 阈值
     → 发送告警通知 → 可选暂停 Agent

  3. 异常检测审批
     触发: Agent 操作后错误率在时间窗口内超过阈值
     触发: Agent 短时间内重复执行同一操作（疑似循环）
     → 自动暂停 Agent → 通知管理员 → 可选自动回滚

  4. 自定义审批规则（P2）
     管理员自定义触发条件和审批流程
```

#### 8.1.2 审批请求生命周期

```
Agent 发起高风险操作
  │
  ├── 1. 创建审批请求
  │     ├── approval_requests.insert({
  │     │     agent_id, operation_type, operation_details,
  │     │     risk_level, estimated_impact,
  │     │     status: 'pending', created_at: now()
  │     │   })
  │     └── Agent 操作暂停，进入等待状态
  │
  ├── 2. 通知管理员
  │     ├── WebSocket 推送: admin:approval_required
  │     ├── 站内通知（管理后台通知中心）
  │     └── 可选：邮件/IM 通知
  │
  ├── 3. 管理员处理
  │     ├── 批准 → status='approved'
  │     │   └── 4a. Agent 恢复操作 → 执行原始操作 → 记录结果
  │     │
  │     ├── 拒绝 → status='rejected'
  │     │   └── 4b. Agent 收到拒绝通知 → 取消操作 → 通知发起者
  │     │
  │     └── 超时 → status='timeout_rejected'
  │           └── 4c. 自动拒绝 → Agent 取消操作 → 记录超时
  │
  └── 5. 记录审计日志
        └── audit_logs.insert({ ... approval_id, decision, decided_by, ... })
```

#### 8.1.3 审批请求详情

```typescript
interface ApprovalRequest {
  id: string;
  workspace_id: string;
  
  // 请求方
  agent_id: string;
  agent_name: string;
  
  // 操作详情
  operation_type: 'database_delete' | 'external_payment' | 'batch_file_delete' | 'config_modify';
  operation_details: {
    description: string;              // "删除 users 表中 status='inactive' 的 30 条记录"
    target_resource: string;          // "users 表"
    estimated_impact: string;         // "影响 30 条记录"
    estimated_cost?: number;          // 预估 Credits 消耗
    reversible: boolean;              // 是否可回滚
  };
  
  // 风险评估
  risk_level: 'low' | 'medium' | 'high' | 'critical';
  risk_factors: string[];             // ["涉及数据删除", "不可完全回滚"]
  
  // 状态
  status: 'pending' | 'approved' | 'rejected' | 'timeout_rejected' | 'cancelled';
  
  // 审批结果
  decided_by?: string;                // 审批人 user_id
  decided_at?: string;
  decision_note?: string;             // 审批备注
  
  // 时间
  created_at: string;
  expires_at: string;                 // 超时时间
  
  // 回调
  callback_url?: string;              // Agent 操作恢复的回调 URL
}
```

### 8.2 费用超限告警

#### 8.2.1 告警规则配置

```typescript
interface CostAlertRule {
  id: string;
  workspace_id: string;
  
  // 规则类型
  rule_type: 'agent_daily' | 'agent_weekly' | 'workspace_monthly';
  
  // 阈值
  threshold_amount: number;           // 如 100.00
  threshold_currency: string;         // 'USD'
  
  // 行为
  alert_action: 'notify_only' | 'notify_and_pause';
  notification_channels: ('in_app' | 'email' | 'webhook')[];
  notification_recipients: string[];   // user_ids
  
  // 状态
  enabled: boolean;
  
  created_at: string;
  updated_at: string;
}
```

#### 8.2.2 告警触发流程

```
Cost Tracking Worker（每 5 分钟运行）
  │
  ├── 1. 聚合 cost_records 表
  │     ├── 按 Agent 计算当日/当周 Credits 消耗
  │     └── 计算 Workspace 当月 Credits 消耗
  │
  ├── 2. 与告警规则比对
  │     ├── agent_daily: SUM(agent_x today) > threshold?
  │     ├── agent_weekly: SUM(agent_x this_week) > threshold?
  │     └── workspace_monthly: SUM(workspace this_month) > threshold?
  │
  ├── 3. 触发告警（如超限）
  │     ├── 创建 cost_alert 记录
  │     ├── 发送通知（站内 + 邮件 + Webhook）
  │     └── 如配置 notify_and_pause → 暂停 Agent
  │
  └── 4. 去重: 同一规则同一周期内只触发一次
```

### 8.3 自动回滚机制

#### 8.3.1 回滚策略配置

```typescript
interface RollbackPolicy {
  enabled: boolean;
  
  // 触发条件
  error_rate_threshold: number;       // 错误率阈值（如 0.3 = 30%）
  observation_window_minutes: number; // 观察窗口（如 5 分钟）
  min_operations_for_trigger: number; // 最少操作数（避免小样本误触发）
  
  // 回滚范围
  rollback_window_minutes: number;    // 回滚时间窗口（如 60 分钟 = 最近 1 小时的操作）
  
  // 回滚行为
  auto_pause_agent: boolean;          // 回滚后是否自动暂停 Agent
  notify_admin: boolean;              // 是否通知管理员
}
```

#### 8.3.2 回滚执行流程

```
Error Rate Monitor（实时监控）
  │
  ├── 1. 计算 Agent 操作错误率
  │     ├── 时间窗口内的操作总数
  │     ├── 时间窗口内的失败操作数
  │     └── 错误率 = 失败数 / 总数
  │
  ├── 2. 判断是否触发回滚
  │     ├── 错误率 > threshold?
  │     ├── 操作总数 > min_operations?
  │     └── 满足条件 → 触发回滚
  │
  ├── 3. 执行回滚
  │     ├── 查询 audit_logs 中该 Agent 在 rollback_window 内的操作
  │     ├── 按时间倒序执行逆操作
  │     │   ├── 文件创建 → 删除文件
  │     │   ├── 文件修改 → 恢复备份
  │     │   ├── DB INSERT → DELETE（按 ID）
  │     │   ├── DB UPDATE → 恢复原值（从日志中获取）
  │     │   └── DB DELETE → 尝试恢复（如有快照）
  │     │
  │     ├── 不可回滚的操作标记为"需人工处理"
  │     └── 记录回滚结果
  │
  ├── 4. 暂停 Agent（如配置）
  │     └── Agent 状态 → paused
  │
  └── 5. 通知管理员
        ├── 回滚摘要：回滚了 N 个操作，M 个需人工处理
        ├── 错误原因分析
        └── 恢复建议
```

### 8.4 审计日志系统

#### 8.4.1 审计日志记录规则

所有 Agent 操作和管理员操作都记录审计日志：

```typescript
interface AuditLogEntry {
  id: string;
  workspace_id: string;
  
  // 操作者
  actor_id: string;
  actor_type: 'human' | 'agent' | 'system';
  actor_name: string;
  
  // 操作
  action: string;                     // 操作标识
  action_category: string;            // 操作分类
  // 可能的 action 值：
  // 权限操作: 'permission.changed', 'permission.checked', 'permission.denied'
  // 席位操作: 'seat.added', 'seat.removed', 'seat.role_changed'
  // 审批操作: 'approval.requested', 'approval.approved', 'approval.rejected'
  // 策略操作: 'policy.updated', 'policy.enabled', 'policy.disabled'
  // Agent 操作: 'agent.code_executed', 'agent.file_written', 'agent.api_called', 'agent.db_operated'
  // 报告操作: 'report.exported', 'report.scheduled'
  
  // 目标
  target_type?: string;               // 'agent' | 'seat' | 'policy' | 'permission'
  target_id?: string;
  target_name?: string;
  
  // 详情
  details: Record<string, any>;       // 操作详情（如：旧值/新值、参数等）
  
  // 结果
  result: 'success' | 'failure' | 'denied' | 'pending';
  error_message?: string;
  
  // 元数据
  ip_address?: string;
  user_agent?: string;
  
  created_at: string;
}
```

#### 8.4.2 审计日志查询

```
审计日志查看界面：

┌──────────────────────────────────────────────────────────────────────────┐
│ 审计日志                                                                  │
│                                                                          │
│ 时间范围: [过去7天 ▾]  操作者: [全部 ▾]  操作类型: [全部 ▾]  结果: [全部 ▾] │
│ [搜索关键词: ________________]                              [导出 CSV]    │
├──────────┬──────────────┬─────────────────────┬────────┬─────────────────┤
│ 时间      │ 操作者        │ 操作                │ 结果    │ 详情             │
├──────────┼──────────────┼─────────────────────┼────────┼─────────────────┤
│ 10:23:45 │ 代码助手      │ 代码执行            │ ✅ 成功 │ [展开]           │
│ 10:22:30 │ 代码助手      │ 文件写入            │ ✅ 成功 │ [展开]           │
│ 10:20:00 │ 测试Agent     │ 数据库查询          │ ✅ 成功 │ [展开]           │
│ 10:15:22 │ 产品助手      │ 外部API调用         │ ⛔ 被拒 │ [展开]           │
│ 10:10:00 │ 陈朗辉        │ 权限变更            │ ✅ 成功 │ [展开]           │
│ 10:05:33 │ 系统          │ 费用超限告警        │ ⚠ 告警  │ [展开]           │
└──────────┴──────────────┴─────────────────────┴────────┴─────────────────┘
```

### 8.5 审批与审计的集成

```
Agent 操作流程（含审批和审计的完整路径）：

Agent 发起操作
  │
  ├── 1. 权限检查
  │     ├── ALLOW → 继续
  │     └── DENY → 拒绝 + 记录审计日志 → 结束
  │
  ├── 2. 审批检查
  │     ├── 不需要审批 → 继续
  │     └── 需要审批 → 创建审批请求 → 等待
  │           ├── 批准 → 继续
  │           ├── 拒绝 → 取消 + 记录审计日志 → 结束
  │           └── 超时 → 自动拒绝 + 记录 → 结束
  │
  ├── 3. 执行操作
  │     ├── 成功 → 记录审计日志
  │     └── 失败 → 记录审计日志
  │
  ├── 4. 后续监控
  │     ├── 错误率监控 → 是否触发自动回滚
  │     └── 费用监控 → 是否触发费用超限告警
  │
  └── 5. 所有步骤的结果都写入 audit_logs
```

---

## 9. 数据模型

### 9.1 Workspace 设置表

```sql
-- Workspace 级管理配置
CREATE TABLE workspace_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  
  -- Agent 默认权限配置
  default_permissions JSONB NOT NULL DEFAULT '{
    "code_execution": "allow",
    "file_write": "allow",
    "external_api": "allow",
    "database_ops": "deny"
  }',
  
  -- 审批策略配置
  approval_policies JSONB NOT NULL DEFAULT '{
    "high_risk_approval": { "enabled": false, "timeout_hours": 24 },
    "cost_alert": { "enabled": false, "agent_daily_limit": 100, "workspace_monthly_limit": 5000 },
    "auto_rollback": { "enabled": false, "error_rate_threshold": 0.3, "window_minutes": 5 },
    "audit_logging": { "enabled": true, "retention_days": 90 }
  }',
  
  -- 报告配置
  report_config JSONB DEFAULT '{
    "auto_report_enabled": false,
    "frequency": "monthly",
    "recipients": []
  }',
  
  -- 审计
  updated_by UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  UNIQUE(workspace_id)
);

-- 索引
CREATE INDEX idx_workspace_settings_ws ON workspace_settings(workspace_id);
```

### 9.2 统一席位表

```sql
-- 统一席位表（人类+Agent 在同一表中）
CREATE TABLE workspace_seats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  
  -- 席位实体（多态）
  entity_id UUID NOT NULL,                     -- 指向 users.id 或 agents.id
  seat_type VARCHAR(10) NOT NULL
    CHECK (seat_type IN ('human', 'agent')),
  
  -- 角色
  role VARCHAR(30) NOT NULL,
  -- 人类角色: 'owner', 'admin', 'member', 'viewer'
  -- Agent 角色: 'agent' (统一标识，具体角色由 Module 4 team_members 管理)
  
  -- 显示信息（冗余缓存）
  display_name VARCHAR(100) NOT NULL,
  avatar_url VARCHAR(500),
  
  -- 状态
  status VARCHAR(20) NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'online', 'offline', 'paused', 'suspended')),
  
  -- 统计（缓存，定时更新）
  api_calls_this_week INTEGER DEFAULT 0,
  api_calls_total BIGINT DEFAULT 0,
  credits_consumed_this_month DECIMAL(10, 2) DEFAULT 0,
  credits_consumed_total DECIMAL(12, 2) DEFAULT 0,
  
  -- 时间
  last_active_at TIMESTAMPTZ,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- 唯一约束
  UNIQUE(workspace_id, entity_id, seat_type)
);

-- 索引
CREATE INDEX idx_seats_workspace ON workspace_seats(workspace_id, status);
CREATE INDEX idx_seats_type ON workspace_seats(workspace_id, seat_type);
CREATE INDEX idx_seats_entity ON workspace_seats(entity_id, seat_type);
CREATE INDEX idx_seats_last_active ON workspace_seats(workspace_id, last_active_at DESC);
CREATE INDEX idx_seats_api_calls ON workspace_seats(workspace_id, api_calls_this_week DESC);
```

### 9.3 Agent 权限表

```sql
-- Agent 执行权限（管理后台的开关控制）
CREATE TABLE agent_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  
  -- 权限范围
  -- agent_id = NULL 表示 Workspace 级默认
  -- agent_id = 具体 ID 表示单 Agent 级覆盖
  agent_id UUID,                               -- NULL = workspace default
  
  -- 权限维度
  dimension VARCHAR(30) NOT NULL
    CHECK (dimension IN ('code_execution', 'file_write', 'external_api', 'database_ops')),
  
  -- 权限值
  value VARCHAR(10) NOT NULL
    CHECK (value IN ('allow', 'deny')),
  
  -- 审计
  changed_by UUID NOT NULL,                    -- 修改人 user_id
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- 唯一约束
  UNIQUE(workspace_id, agent_id, dimension)
);

-- 索引
CREATE INDEX idx_agent_perms_workspace ON agent_permissions(workspace_id)
  WHERE agent_id IS NULL;                      -- Workspace 级默认权限快速查询
CREATE INDEX idx_agent_perms_agent ON agent_permissions(workspace_id, agent_id)
  WHERE agent_id IS NOT NULL;                  -- Agent 级覆盖快速查询
CREATE INDEX idx_agent_perms_dimension ON agent_permissions(dimension);
```

### 9.4 审批策略表

```sql
-- 审批策略配置
CREATE TABLE approval_policies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  
  -- 策略类型
  policy_type VARCHAR(30) NOT NULL
    CHECK (policy_type IN (
      'high_risk_approval',                    -- 高风险操作审批
      'cost_alert',                            -- 费用超限告警
      'auto_rollback',                         -- 自动回滚
      'audit_logging'                          -- 操作日志审计
    )),
  
  -- 启用状态
  enabled BOOLEAN NOT NULL DEFAULT FALSE,
  
  -- 策略配置（JSON，不同类型有不同结构）
  config JSONB NOT NULL DEFAULT '{}',
  -- high_risk_approval:
  --   { "timeout_hours": 24, "operations": ["db_delete", "external_payment", "batch_file_delete"] }
  -- cost_alert:
  --   { "agent_daily_limit": 100, "workspace_monthly_limit": 5000,
  --     "notification_channels": ["in_app", "email"], "action": "notify_only" }
  -- auto_rollback:
  --   { "error_rate_threshold": 0.3, "window_minutes": 5,
  --     "rollback_window_minutes": 60, "auto_pause": true }
  -- audit_logging:
  --   { "retention_days": 90, "export_formats": ["csv", "json"] }
  
  -- 审计
  updated_by UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  UNIQUE(workspace_id, policy_type)
);

-- 索引
CREATE INDEX idx_approval_policies_ws ON approval_policies(workspace_id, enabled);
```

### 9.5 审批请求表

```sql
-- 审批请求
CREATE TABLE approval_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  policy_id UUID NOT NULL REFERENCES approval_policies(id),
  
  -- 请求方
  agent_id UUID NOT NULL,
  agent_name VARCHAR(100) NOT NULL,
  
  -- 操作详情
  operation_type VARCHAR(30) NOT NULL,
  -- 可能的值: 'database_delete', 'database_drop', 'external_payment',
  --          'batch_file_delete', 'config_modify', 'deployment'
  
  operation_details JSONB NOT NULL,
  -- {
  --   "description": "删除 users 表中 status='inactive' 的 30 条记录",
  --   "target_resource": "users 表",
  --   "estimated_impact": "30 条记录",
  --   "estimated_cost": 2.50,
  --   "reversible": true,
  --   "sql_statement": "DELETE FROM users WHERE status='inactive'",
  --   "callback_url": "internal://agent/resume/xxx"
  -- }
  
  -- 风险评估
  risk_level VARCHAR(10) NOT NULL DEFAULT 'medium'
    CHECK (risk_level IN ('low', 'medium', 'high', 'critical')),
  risk_factors TEXT[],                         -- ["涉及数据删除", "影响 30 条记录"]
  
  -- 审批状态
  status VARCHAR(20) NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'approved', 'rejected', 'timeout_rejected', 'cancelled')),
  
  -- 审批结果
  decided_by UUID,                             -- 审批人 user_id
  decided_at TIMESTAMPTZ,
  decision_note TEXT,                          -- 审批备注
  
  -- 时间
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,             -- 超时时间
  
  -- 执行结果（审批通过后的操作结果）
  execution_result VARCHAR(20)
    CHECK (execution_result IN ('success', 'failure', 'rolled_back')),
  execution_details JSONB
);

-- 索引
CREATE INDEX idx_approval_requests_ws ON approval_requests(workspace_id, status);
CREATE INDEX idx_approval_requests_pending ON approval_requests(workspace_id, created_at DESC)
  WHERE status = 'pending';
CREATE INDEX idx_approval_requests_agent ON approval_requests(agent_id, created_at DESC);
CREATE INDEX idx_approval_requests_expiry ON approval_requests(expires_at)
  WHERE status = 'pending';
```

### 9.6 审计日志表

```sql
-- 审计日志（核心审计表——记录所有操作）
CREATE TABLE audit_logs (
  id BIGSERIAL PRIMARY KEY,
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  
  -- 操作者
  actor_id UUID NOT NULL,
  actor_type VARCHAR(10) NOT NULL
    CHECK (actor_type IN ('human', 'agent', 'system')),
  actor_name VARCHAR(100) NOT NULL,
  
  -- 操作
  action VARCHAR(50) NOT NULL,
  action_category VARCHAR(30) NOT NULL,
  -- 可能的 action_category:
  -- 'permission'  : 权限变更
  -- 'seat'        : 席位管理
  -- 'approval'    : 审批流程
  -- 'policy'      : 策略配置
  -- 'agent_ops'   : Agent 操作
  -- 'report'      : 报告导出
  -- 'system'      : 系统事件
  
  -- 目标
  target_type VARCHAR(30),                     -- 'agent', 'seat', 'policy', 'permission', 'file', 'database'
  target_id VARCHAR(100),
  target_name VARCHAR(200),
  
  -- 详情
  details JSONB NOT NULL DEFAULT '{}',
  -- 权限变更: { "dimension": "database_ops", "old_value": "deny", "new_value": "allow" }
  -- Agent 操作: { "operation": "code_execution", "code_snippet": "...", "duration_ms": 1200 }
  -- 审批: { "approval_id": "xxx", "decision": "approved", "note": "确认安全" }
  
  -- 结果
  result VARCHAR(20) NOT NULL DEFAULT 'success'
    CHECK (result IN ('success', 'failure', 'denied', 'pending', 'alert')),
  error_message TEXT,
  
  -- 关联
  approval_request_id UUID,                    -- 关联的审批请求 ID
  
  -- 回滚信息（用于自动回滚）
  rollback_action JSONB,                       -- 逆操作描述
  -- { "type": "file_restore", "backup_path": "/backups/xxx", "original_path": "/data/xxx" }
  -- { "type": "db_restore", "table": "users", "row_id": "xxx", "original_values": {...} }
  
  is_rolled_back BOOLEAN DEFAULT FALSE,
  rolled_back_at TIMESTAMPTZ,
  
  -- 元数据
  ip_address INET,
  user_agent TEXT,
  request_id VARCHAR(100),                     -- 请求追踪 ID
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_audit_logs_workspace ON audit_logs(workspace_id, created_at DESC);
CREATE INDEX idx_audit_logs_actor ON audit_logs(actor_id, actor_type, created_at DESC);
CREATE INDEX idx_audit_logs_action ON audit_logs(workspace_id, action_category, created_at DESC);
CREATE INDEX idx_audit_logs_result ON audit_logs(workspace_id, result, created_at DESC);
CREATE INDEX idx_audit_logs_target ON audit_logs(target_type, target_id, created_at DESC);
-- 用于审计日志清理（保留期外删除）
CREATE INDEX idx_audit_logs_retention ON audit_logs(created_at)
  WHERE created_at < NOW() - INTERVAL '90 days';
-- 用于自动回滚查询
CREATE INDEX idx_audit_logs_rollback ON audit_logs(actor_id, created_at DESC)
  WHERE rollback_action IS NOT NULL AND is_rolled_back = FALSE;
```

### 9.7 用量指标表

```sql
-- 用量指标（KPI 仪表盘和趋势图的数据源）
CREATE TABLE usage_metrics (
  id BIGSERIAL PRIMARY KEY,
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  
  -- 指标类型
  metric_type VARCHAR(30) NOT NULL
    CHECK (metric_type IN (
      'active_agents',                         -- 活跃 Agent 数
      'active_users',                          -- 活跃用户数（含人类+Agent）
      'api_calls',                             -- API 调用总量
      'credits_consumed',                      -- Credits 消耗
      'api_calls_by_agent',                    -- 按 Agent 的 API 调用量
      'credits_by_agent'                       -- 按 Agent 的 Credits 消耗
    )),
  
  -- 关联实体（按 Agent 统计时使用）
  entity_id UUID,                              -- Agent ID（全局指标时为 NULL）
  entity_type VARCHAR(10),                     -- 'agent' | NULL
  
  -- 时间粒度
  period_type VARCHAR(10) NOT NULL
    CHECK (period_type IN ('hourly', 'daily', 'weekly', 'monthly')),
  period_start TIMESTAMPTZ NOT NULL,           -- 时间段开始
  period_end TIMESTAMPTZ NOT NULL,             -- 时间段结束
  
  -- 指标值
  metric_value DECIMAL(15, 2) NOT NULL,        -- 指标数值
  
  -- 环比
  previous_value DECIMAL(15, 2),               -- 上一周期的值
  change_percent DECIMAL(5, 2),                -- 环比变化百分比
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_usage_metrics_ws ON usage_metrics(workspace_id, metric_type, period_start DESC);
CREATE INDEX idx_usage_metrics_entity ON usage_metrics(entity_id, metric_type, period_start DESC)
  WHERE entity_id IS NOT NULL;
CREATE INDEX idx_usage_metrics_period ON usage_metrics(workspace_id, period_type, period_start DESC);
-- 7 天趋势查询优化
CREATE INDEX idx_usage_metrics_trend ON usage_metrics(workspace_id, metric_type, period_type, period_start)
  WHERE period_type = 'daily' AND period_start > NOW() - INTERVAL '7 days';
```

### 9.8 成本记录表

```sql
-- 成本记录（Credits 消耗的原始数据）
CREATE TABLE cost_records (
  id BIGSERIAL PRIMARY KEY,
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  
  -- 消耗实体
  entity_id UUID NOT NULL,                     -- Agent ID 或 User ID
  entity_type VARCHAR(10) NOT NULL
    CHECK (entity_type IN ('human', 'agent')),
  entity_name VARCHAR(100) NOT NULL,
  
  -- 成本明细
  cost_type VARCHAR(30) NOT NULL,
  -- 可能的值:
  -- 'api_call'       : API 调用费
  -- 'token_usage'    : Token 消耗费
  -- 'compute'        : 计算资源费
  -- 'storage'        : 存储费用
  -- 'external_api'   : 外部 API 调用费
  
  amount DECIMAL(10, 4) NOT NULL,              -- 金额（USD）
  currency VARCHAR(3) NOT NULL DEFAULT 'USD',
  
  -- 消耗详情
  details JSONB,
  -- api_call: { "endpoint": "/api/v1/xxx", "method": "POST", "tokens_in": 1500, "tokens_out": 800 }
  -- compute: { "duration_ms": 5000, "cpu_units": 0.5, "memory_mb": 256 }
  
  -- 关联操作
  audit_log_id BIGINT,                         -- 关联的审计日志 ID
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_cost_records_ws ON cost_records(workspace_id, created_at DESC);
CREATE INDEX idx_cost_records_entity ON cost_records(entity_id, entity_type, created_at DESC);
CREATE INDEX idx_cost_records_type ON cost_records(workspace_id, cost_type, created_at DESC);
-- 日粒度聚合查询
CREATE INDEX idx_cost_records_daily ON cost_records(workspace_id, entity_id, created_at)
  WHERE created_at > NOW() - INTERVAL '30 days';
-- 月度聚合查询
CREATE INDEX idx_cost_records_monthly ON cost_records(workspace_id, created_at)
  WHERE created_at > NOW() - INTERVAL '365 days';
```

### 9.9 费用告警记录表

```sql
-- 费用告警记录
CREATE TABLE cost_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  policy_id UUID NOT NULL REFERENCES approval_policies(id),
  
  -- 告警类型
  alert_type VARCHAR(20) NOT NULL
    CHECK (alert_type IN ('agent_daily', 'agent_weekly', 'workspace_monthly')),
  
  -- 相关实体
  entity_id UUID,                              -- Agent ID（workspace 级告警时为 NULL）
  entity_name VARCHAR(100),
  
  -- 告警详情
  threshold_amount DECIMAL(10, 2) NOT NULL,    -- 阈值
  actual_amount DECIMAL(10, 2) NOT NULL,       -- 实际金额
  overage_amount DECIMAL(10, 2) NOT NULL,      -- 超出金额
  
  -- 告警状态
  status VARCHAR(20) NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'acknowledged', 'resolved')),
  acknowledged_by UUID,
  acknowledged_at TIMESTAMPTZ,
  
  -- 采取的行动
  action_taken VARCHAR(30),
  -- 'notified_only', 'agent_paused', 'agent_suspended'
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_cost_alerts_ws ON cost_alerts(workspace_id, status, created_at DESC);
CREATE INDEX idx_cost_alerts_entity ON cost_alerts(entity_id, created_at DESC)
  WHERE entity_id IS NOT NULL;
```

### 9.10 ER 关系图

```
workspaces
  │
  ├── workspace_settings          (管理配置: 默认权限、审批策略、报告配置)
  │
  ├── workspace_seats             (统一席位表: 人类+Agent)
  │     ├── → users.id            (seat_type = 'human')
  │     └── → agents.id           (seat_type = 'agent', Module 5)
  │
  ├── agent_permissions           (Agent 执行权限: 开关控制)
  │     └── → agents.id           (单 Agent 级覆盖)
  │
  ├── approval_policies           (审批策略: 高风险/费用/回滚/审计)
  │     │
  │     └── approval_requests     (审批请求: 等待管理员决策)
  │           └── → agents.id     (请求方 Agent)
  │
  ├── audit_logs                  (审计日志: 所有操作记录)
  │     ├── → users.id / agents.id (操作者)
  │     └── → approval_requests.id (关联审批)
  │
  ├── usage_metrics               (用量指标: KPI + 趋势数据)
  │     └── → agents.id           (按 Agent 统计)
  │
  ├── cost_records                (成本记录: Credits 消耗明细)
  │     ├── → users.id / agents.id (消耗实体)
  │     └── → audit_logs.id       (关联操作)
  │
  └── cost_alerts                 (费用告警: 超限通知)
        └── → approval_policies.id (关联策略)

外部关联：
  workspace_seats.entity_id → users.id (seat_type = 'human')
  workspace_seats.entity_id → agents.id (seat_type = 'agent', Module 5)
  agent_permissions.agent_id → agents.id (Module 5)
  approval_requests.agent_id → agents.id (Module 5)
  cost_records.entity_id → users.id / agents.id
  audit_logs.actor_id → users.id / agents.id
```

### 9.11 与现有模块的数据关系

**与 Module 1 (Chat 对话) 的关系：**
- 审批通知推送到管理员的 DM 或指定频道（通过 Module 1 的消息 API）
- 费用超限告警通过 Module 1 的通知系统发送
- 管理员可在 Chat 中直接回复审批请求（P2）

**与 Module 2 (Tasks 任务) 的关系：**
- Agent 执行任务时产生的 API 调用量和 Credits 消耗记录到 `cost_records` 表
- Agent 权限检查影响任务执行——如果代码执行权限被关闭，Agent 无法执行代码类任务

**与 Module 3 (Projects 项目) 的关系：**
- 项目中 Agent 的活动数据纳入管理后台的用量统计
- 项目部署操作可配置为高风险操作，需要审批

**与 Module 4 (Team 团队) 的关系：**
- 团队成员变更同步到 `workspace_seats` 表
- Agent 的团队角色（执行者/审核者/协调者/观察者）决定其默认权限配置
- Module 4 的 Permission Engine 与 Module 7 的 Agent 权限开关协同工作

**与 Module 5 (Agent 管理) 的关系：**
- Agent 的核心数据（名称、模型、能力标签）从 Module 5 的 `agents` 表获取
- Agent 的运行时状态同步到席位表的 `status` 字段
- Agent 的 API 调用量和 Credits 消耗由 Module 5 的运行时采集，写入 `cost_records` 和 `usage_metrics`
- Agent 被 Module 7 暂停/恢复时，同步到 Module 5 的 Agent 生命周期管理

**与 Module 6 (AI 能力) 的关系：**
- AI 模型调用的 Token 消耗记录到 `cost_records` 表
- 模型调用量纳入管理后台的 API 调用量 KPI

---

## 10. 技术方案

### 10.1 整体架构

```
┌──────────────────────────────────────────────────────────────────────────┐
│                          客户端层                                         │
│  Web (Next.js + TailwindCSS)                                             │
│  ├── Admin Dashboard Page (KPI 卡片 + 趋势图)                            │
│  ├── Seat Management Page (统一席位表格)                                  │
│  ├── Permission Control Panel (Agent 权限开关)                            │
│  ├── Approval Policies Page (审批策略配置)                                │
│  ├── Approval Requests Page (审批请求列表)                                │
│  ├── Audit Logs Page (审计日志查看)                                       │
│  └── Report Export (报告导出)                                             │
└───────────────────────┬──────────────────────────────────────────────────┘
                        │ REST API + WebSocket
┌───────────────────────┴──────────────────────────────────────────────────┐
│                        API Gateway                                        │
│  JWT Auth │ Admin Role Check │ Rate Limiting │ WS Upgrade                 │
└───────────────────────┬──────────────────────────────────────────────────┘
                        │
┌───────────────────────┴──────────────────────────────────────────────────┐
│                        服务层                                              │
│                                                                           │
│  Admin Service ──── Permission Engine ──── Approval Engine                │
│       │                    │                    │                          │
│       │              Redis Cache           Notification                   │
│       │           (permissions,              Service                      │
│       │            KPI cache)                   │                          │
│       │                    │                    │                          │
│  ┌────┴────────────────────┴────────────────────┴──────────┐              │
│  │              Event Bus (Redis Streams)                    │              │
│  └────┬──────────────┬──────────────┬──────────────┬───────┘              │
│       │              │              │              │                       │
│  Usage Tracker   Cost Tracker   Audit Logger   Alert Monitor              │
│  (用量采集)       (成本采集)     (审计记录)     (告警监控)                 │
│       │              │              │              │                       │
│  ┌────┴──────────────┴──────────────┴──────────────┴───────┐              │
│  │          Background Workers                              │              │
│  │  ├── KPI Aggregator (每 5 分钟)                          │              │
│  │  ├── Cost Aggregator (每 5 分钟)                          │              │
│  │  ├── Seat Stats Updater (每 10 分钟)                      │              │
│  │  ├── Alert Checker (每 5 分钟)                            │              │
│  │  ├── Approval Timeout Checker (每 1 分钟)                 │              │
│  │  ├── Rollback Monitor (实时)                              │              │
│  │  └── Report Generator (按配置)                            │              │
│  └──────────────────────────────────────────────────────────┘              │
└───────────────────────┬──────────────────────────────────────────────────┘
                        │
┌───────────────────────┴──────────────────────────────────────────────────┐
│                        数据层                                              │
│  PostgreSQL 16 (Cloud SQL)           │  Redis 7 (Memorystore)             │
│  (workspace_settings,                │  (permission cache,                 │
│   workspace_seats,                   │   KPI cache,                        │
│   agent_permissions,                 │   approval queue,                   │
│   approval_policies,                 │   usage counters,                   │
│   approval_requests,                 │   alert dedup,                      │
│   audit_logs,                        │   event bus,                        │
│   usage_metrics,                     │   websocket pub/sub)                │
│   cost_records,                      │                                     │
│   cost_alerts)                       │                                     │
└──────────────────────────────────────────────────────────────────────────┘
```

### 10.2 API 设计

#### RESTful API

```
# 系统概览（KPI 仪表盘）
GET    /api/v1/admin/dashboard                    # 获取 4 个 KPI 卡片数据 + 7 天趋势
GET    /api/v1/admin/dashboard/trend              # 获取指定指标的趋势数据
       ?metric=api_calls&period=7d

# 席位管理
GET    /api/v1/admin/seats                        # 获取席位列表（支持搜索、筛选、排序、分页）
       ?search=代码&type=agent&status=online
       &sort=api_calls_this_week&order=desc
       &page=1&limit=20
POST   /api/v1/admin/seats                        # 添加席位（人类或 Agent）
GET    /api/v1/admin/seats/:sid                   # 获取席位详情
PATCH  /api/v1/admin/seats/:sid                   # 修改席位（角色等）
DELETE /api/v1/admin/seats/:sid                   # 移除席位
GET    /api/v1/admin/seats/:sid/usage             # 获取单席位用量详情

# Agent 权限控制
GET    /api/v1/admin/permissions                  # 获取当前权限配置（Workspace 级 + 各 Agent 级）
PUT    /api/v1/admin/permissions                  # 更新 Workspace 级默认权限
GET    /api/v1/admin/permissions/:agent_id        # 获取单 Agent 权限配置
PUT    /api/v1/admin/permissions/:agent_id        # 更新单 Agent 权限（覆盖默认）
DELETE /api/v1/admin/permissions/:agent_id        # 重置单 Agent 为默认权限
POST   /api/v1/admin/permissions/check            # 权限检查（内部 API）
       { "agent_id": "xxx", "dimension": "code_execution" }

# 审批策略
GET    /api/v1/admin/policies                     # 获取所有审批策略
PUT    /api/v1/admin/policies/:type               # 更新审批策略
       { "enabled": true, "config": { ... } }

# 审批请求
GET    /api/v1/admin/approvals                    # 获取审批请求列表
       ?status=pending&page=1&limit=20
GET    /api/v1/admin/approvals/:aid               # 获取审批请求详情
POST   /api/v1/admin/approvals/:aid/approve       # 批准审批请求
       { "note": "确认安全" }
POST   /api/v1/admin/approvals/:aid/reject        # 拒绝审批请求
       { "note": "风险过高" }

# 审计日志
GET    /api/v1/admin/audit-logs                   # 获取审计日志（支持筛选）
       ?start=2026-04-13&end=2026-04-20
       &actor_type=agent&action_category=agent_ops
       &result=denied
       &page=1&limit=50
GET    /api/v1/admin/audit-logs/:lid              # 获取单条审计日志详情
POST   /api/v1/admin/audit-logs/export            # 导出审计日志
       { "format": "csv", "filters": { ... } }

# 用量分析
GET    /api/v1/admin/usage                        # 获取用量摘要
GET    /api/v1/admin/usage/by-agent               # 按 Agent 分组的用量统计
GET    /api/v1/admin/usage/trend                  # 用量趋势
       ?metric=api_calls&entity_id=xxx&period=30d

# 成本分析
GET    /api/v1/admin/costs                        # 获取成本摘要
GET    /api/v1/admin/costs/by-agent               # 按 Agent 分组的成本统计
GET    /api/v1/admin/costs/trend                  # 成本趋势
       ?period=30d

# 报告导出
POST   /api/v1/admin/reports/export               # 导出系统使用报告
       { "format": "pdf", "period": "monthly", "sections": ["kpi", "seats", "usage", "audit"] }
GET    /api/v1/admin/reports/history               # 导出报告历史
```

#### 请求/响应示例

**获取 KPI 仪表盘数据：**

```typescript
// GET /api/v1/admin/dashboard
// Response 200
{
  "kpi": {
    "active_agents": {
      "value": 4,
      "change": "+1",
      "change_label": "+1 本月",
      "trend": [2, 2, 3, 3, 3, 4, 4]          // 7 天趋势数据
    },
    "active_users": {
      "value": 28,
      "change": "+12%",
      "change_direction": "up",
      "trend": [22, 23, 25, 24, 26, 27, 28]
    },
    "api_calls": {
      "value": 14200,
      "display_value": "14.2k",
      "change": "+23%",
      "change_direction": "up",
      "trend": [8500, 9200, 10800, 11500, 12300, 13100, 14200]
    },
    "credits_consumed": {
      "value": 842.00,
      "display_value": "$842",
      "currency": "USD",
      "change": "+5%",
      "change_direction": "up",
      "trend": [720, 750, 780, 800, 810, 830, 842]
    }
  },
  "generated_at": "2026-04-20T10:00:00Z"
}
```

**获取席位列表：**

```typescript
// GET /api/v1/admin/seats?sort=last_active_at&order=desc
// Response 200
{
  "seats": [
    {
      "id": "seat_001",
      "entity_id": "user_chenlh",
      "seat_type": "human",
      "display_name": "陈朗辉",
      "avatar_url": "https://cdn.codeyi.com/avatars/chenlh.jpg",
      "role": "管理员",
      "status": "active",
      "last_active_at": "2026-04-20T10:00:00Z",
      "last_active_label": "刚刚",
      "api_calls_this_week": 1245,
      "credits_consumed_this_month": 45.20
    },
    {
      "id": "seat_002",
      "entity_id": "user_lienqi",
      "seat_type": "human",
      "display_name": "李恩琪",
      "avatar_url": "https://cdn.codeyi.com/avatars/lienqi.jpg",
      "role": "成员",
      "status": "active",
      "last_active_at": "2026-04-20T08:00:00Z",
      "last_active_label": "2小时前",
      "api_calls_this_week": 876,
      "credits_consumed_this_month": 32.10
    },
    {
      "id": "seat_003",
      "entity_id": "user_zhangwei",
      "seat_type": "human",
      "display_name": "张伟",
      "avatar_url": "https://cdn.codeyi.com/avatars/zhangwei.jpg",
      "role": "成员",
      "status": "active",
      "last_active_at": "2026-04-19T10:00:00Z",
      "last_active_label": "1天前",
      "api_calls_this_week": 2103,
      "credits_consumed_this_month": 78.50
    },
    {
      "id": "seat_004",
      "entity_id": "agent_codebot",
      "seat_type": "agent",
      "display_name": "代码助手",
      "avatar_url": "https://cdn.codeyi.com/agent-icons/codebot.png",
      "role": "Agent",
      "status": "online",
      "last_active_at": "2026-04-20T10:00:00Z",
      "last_active_label": "刚刚",
      "api_calls_this_week": 5821,
      "credits_consumed_this_month": 342.80
    },
    {
      "id": "seat_005",
      "entity_id": "agent_testbot",
      "seat_type": "agent",
      "display_name": "测试Agent",
      "avatar_url": "https://cdn.codeyi.com/agent-icons/testbot.png",
      "role": "Agent",
      "status": "online",
      "last_active_at": "2026-04-20T09:30:00Z",
      "last_active_label": "30分钟前",
      "api_calls_this_week": 2456,
      "credits_consumed_this_month": 198.50
    },
    {
      "id": "seat_006",
      "entity_id": "agent_productbot",
      "seat_type": "agent",
      "display_name": "产品助手",
      "avatar_url": "https://cdn.codeyi.com/agent-icons/productbot.png",
      "role": "Agent",
      "status": "offline",
      "last_active_at": "2026-04-19T10:00:00Z",
      "last_active_label": "1天前",
      "api_calls_this_week": 890,
      "credits_consumed_this_month": 56.30
    }
  ],
  "total": 6,
  "page": 1,
  "limit": 20,
  "summary": {
    "total_humans": 3,
    "total_agents": 3,
    "active_count": 5,
    "offline_count": 1
  }
}
```

**更新 Agent 权限：**

```typescript
// PUT /api/v1/admin/permissions/agent_codebot
// Request
{
  "permissions": {
    "code_execution": "allow",
    "file_write": "allow",
    "external_api": "allow",
    "database_ops": "allow"        // 从 deny 改为 allow
  }
}

// Response 200
{
  "agent_id": "agent_codebot",
  "agent_name": "代码助手",
  "permissions": {
    "code_execution": { "value": "allow", "source": "agent_override" },
    "file_write": { "value": "allow", "source": "agent_override" },
    "external_api": { "value": "allow", "source": "agent_override" },
    "database_ops": { "value": "allow", "source": "agent_override" }
  },
  "updated_at": "2026-04-20T10:05:00Z",
  "updated_by": "user_chenlh"
}
```

**创建审批请求（内部 API，由 Agent 运行时调用）：**

```typescript
// POST /api/v1/admin/approvals (internal)
// Request
{
  "agent_id": "agent_codebot",
  "operation_type": "database_delete",
  "operation_details": {
    "description": "删除 users 表中 status='inactive' 的记录",
    "target_resource": "users 表",
    "estimated_impact": "约 30 条记录",
    "sql_statement": "DELETE FROM users WHERE status='inactive'",
    "reversible": false
  },
  "risk_level": "high"
}

// Response 201
{
  "id": "appr_001",
  "status": "pending",
  "expires_at": "2026-04-21T10:05:00Z",
  "message": "审批请求已创建，请等待管理员审批。超时时间：24小时。"
}
```

### 10.3 WebSocket 事件

```typescript
// 客户端 → 服务端
interface WsClientEvents {
  'admin:subscribe': { workspace_id: string };          // 订阅管理后台更新
  'admin:unsubscribe': { workspace_id: string };
}

// 服务端 → 客户端
interface WsServerEvents {
  // KPI 更新
  'admin:kpi_updated': {
    workspace_id: string;
    kpi: DashboardKPI;
  };
  
  // 席位变更
  'admin:seat_added': { workspace_id: string; seat: WorkspaceSeat };
  'admin:seat_removed': { workspace_id: string; seat_id: string };
  'admin:seat_updated': { workspace_id: string; seat_id: string; changes: Partial<WorkspaceSeat> };
  'admin:seat_status_changed': {
    workspace_id: string;
    seat_id: string;
    old_status: string;
    new_status: string;
  };
  
  // 权限变更
  'admin:permission_changed': {
    workspace_id: string;
    agent_id: string | null;           // null = Workspace 级
    dimension: string;
    old_value: string;
    new_value: string;
    changed_by: string;
  };
  
  // 审批相关
  'admin:approval_required': {
    workspace_id: string;
    request: ApprovalRequest;
  };
  'admin:approval_decided': {
    workspace_id: string;
    request_id: string;
    decision: 'approved' | 'rejected';
    decided_by: string;
  };
  'admin:approval_timeout': {
    workspace_id: string;
    request_id: string;
  };
  
  // 告警
  'admin:cost_alert': {
    workspace_id: string;
    alert: CostAlert;
  };
  'admin:rollback_triggered': {
    workspace_id: string;
    agent_id: string;
    agent_name: string;
    rollback_summary: string;
  };
  
  // 审计日志实时
  'admin:audit_log_entry': {
    workspace_id: string;
    entry: AuditLogEntry;
  };
}
```

### 10.4 前端架构

```
pages/
  admin/
    index.tsx                      # 管理后台首页（KPI 仪表盘 + 席位表格）
    permissions.tsx                 # Agent 权限控制页
    policies.tsx                   # 审批策略配置页
    approvals.tsx                  # 审批请求列表页
    audit-logs.tsx                 # 审计日志页
    usage.tsx                      # 用量分析页
    costs.tsx                      # 成本分析页
    reports.tsx                    # 报告管理页

components/
  admin/
    dashboard/
      KPICard.tsx                  # KPI 卡片组件
      KPICardGrid.tsx              # KPI 卡片网格（4 卡片横排）
      SparklineChart.tsx           # 迷你趋势图组件
      TrendBadge.tsx               # 变化趋势标签（+12%↑）
      
    seats/
      SeatTable.tsx                # 统一席位表格
      SeatTableRow.tsx             # 表格行组件
      SeatTypeTag.tsx              # 类型标签（人类/Agent）
      SeatStatusBadge.tsx          # 状态标签（活跃/在线/离线）
      SeatSearchBar.tsx            # 搜索+筛选栏
      SeatDetailPanel.tsx          # 席位详情面板（Drawer）
      AddSeatModal.tsx             # 添加席位弹窗
      RemoveSeatConfirm.tsx        # 移除确认弹窗
      
    permissions/
      PermissionPanel.tsx          # 权限控制面板
      PermissionToggle.tsx         # 权限开关组件（单个维度）
      PermissionScopeSelector.tsx  # 权限范围选择（所有Agent/特定Agent）
      PermissionSourceBadge.tsx    # 权限来源标签（默认/覆盖）
      
    policies/
      PolicyConfigPanel.tsx        # 审批策略配置面板
      HighRiskPolicyForm.tsx       # 高风险审批配置表单
      CostAlertPolicyForm.tsx      # 费用超限配置表单
      RollbackPolicyForm.tsx       # 自动回滚配置表单
      AuditPolicyForm.tsx          # 审计日志配置表单
      
    approvals/
      ApprovalList.tsx             # 审批请求列表
      ApprovalCard.tsx             # 审批请求卡片
      ApprovalDetailModal.tsx      # 审批详情弹窗
      ApprovalActions.tsx          # 批准/拒绝按钮
      
    audit/
      AuditLogList.tsx             # 审计日志列表
      AuditLogEntry.tsx            # 日志条目组件
      AuditLogFilters.tsx          # 筛选器
      AuditLogExport.tsx           # 导出功能
      
    reports/
      ReportExportModal.tsx        # 报告导出弹窗
      ReportFormatSelector.tsx     # 格式选择器
      ReportPreview.tsx            # 报告预览
```

**关键组件设计：**

**KPICard（KPI 卡片）：**

```tsx
// components/admin/dashboard/KPICard.tsx
interface KPICardProps {
  title: string;                    // "API 调用量"
  value: string;                    // "14.2k"
  change: string;                   // "+23%"
  changeDirection: 'up' | 'down' | 'flat';
  trend: number[];                  // 7 天趋势数据
  onClick?: () => void;
}

export function KPICard({ title, value, change, changeDirection, trend, onClick }: KPICardProps) {
  return (
    <div className="rounded-xl border bg-white p-6 hover:shadow-md transition-shadow cursor-pointer"
         onClick={onClick}>
      <div className="flex items-center justify-between">
        <span className="text-sm text-gray-500">{title}</span>
        <TrendBadge change={change} direction={changeDirection} />
      </div>
      <div className="mt-2 text-3xl font-bold">{value}</div>
      <div className="mt-4 h-12">
        <SparklineChart data={trend} color={changeDirection === 'up' ? '#10B981' : '#EF4444'} />
      </div>
    </div>
  );
}
```

**PermissionToggle（权限开关）：**

```tsx
// components/admin/permissions/PermissionToggle.tsx
interface PermissionToggleProps {
  dimension: string;                // 'code_execution'
  label: string;                    // '代码执行'
  description: string;              // '允许 Agent 执行代码片段和脚本'
  value: boolean;                   // true = ON
  source: 'workspace_default' | 'role_default' | 'agent_override';
  onChange: (dimension: string, value: boolean) => void;
  disabled?: boolean;
}

export function PermissionToggle({ 
  dimension, label, description, value, source, onChange, disabled 
}: PermissionToggleProps) {
  return (
    <div className="flex items-center justify-between py-4 border-b last:border-0">
      <div>
        <h4 className="font-medium">{label}</h4>
        <p className="text-sm text-gray-500 mt-1">{description}</p>
        {source !== 'workspace_default' && (
          <PermissionSourceBadge source={source} />
        )}
      </div>
      <Switch
        checked={value}
        onChange={(checked) => onChange(dimension, checked)}
        disabled={disabled}
        className={`${value ? 'bg-green-500' : 'bg-gray-300'} 
                    relative inline-flex h-6 w-11 items-center rounded-full transition-colors`}
      >
        <span className={`${value ? 'translate-x-6' : 'translate-x-1'}
                          inline-block h-4 w-4 transform rounded-full bg-white transition-transform`} />
      </Switch>
    </div>
  );
}
```

### 10.5 实时仪表盘数据流

```
┌──────────────────────────────────────────────────────────────────────┐
│                      实时仪表盘数据流                                  │
│                                                                      │
│  数据采集层                                                           │
│  ├── Agent Runtime Events (Redis Streams)                            │
│  │     ├── agent.api_called → usage counter +1                       │
│  │     ├── agent.task_completed → task stats update                  │
│  │     ├── agent.credits_consumed → cost record insert               │
│  │     └── agent.status_changed → seat status update                 │
│  │                                                                   │
│  ├── User Activity Events                                            │
│  │     ├── user.logged_in → active user counter                      │
│  │     ├── user.api_called → usage counter +1                        │
│  │     └── user.action_performed → audit log insert                  │
│  │                                                                   │
│  └── System Events                                                   │
│        ├── system.alert_triggered → cost alert                       │
│        └── system.rollback_executed → rollback log                   │
│                                                                      │
│  聚合层（Background Workers）                                         │
│  ├── KPI Aggregator (每 5 分钟)                                      │
│  │     ├── 从 Redis counters 读取实时计数                              │
│  │     ├── 聚合写入 usage_metrics 表                                  │
│  │     ├── 计算环比变化                                               │
│  │     └── 更新 Redis KPI 缓存                                       │
│  │                                                                   │
│  ├── Seat Stats Updater (每 10 分钟)                                  │
│  │     ├── 更新 workspace_seats.api_calls_this_week                  │
│  │     ├── 更新 workspace_seats.credits_consumed_this_month          │
│  │     └── 更新 workspace_seats.last_active_at                       │
│  │                                                                   │
│  └── Cost Aggregator (每 5 分钟)                                      │
│        ├── 聚合 cost_records 按 Agent 分组                            │
│        ├── 与告警规则比对                                              │
│        └── 触发超限告警（如需要）                                      │
│                                                                      │
│  推送层                                                               │
│  ├── WebSocket: admin:kpi_updated (KPI 变化时推送)                    │
│  ├── WebSocket: admin:seat_status_changed (席位状态变化)              │
│  ├── WebSocket: admin:cost_alert (费用超限告警)                       │
│  └── WebSocket: admin:audit_log_entry (实时审计日志)                  │
└──────────────────────────────────────────────────────────────────────┘
```

### 10.6 报告生成引擎

```
报告导出流程：

管理员点击 [导出报告]
  │
  ├── 前端: 打开 ReportExportModal
  │     ├── 选择格式: PDF / CSV
  │     ├── 选择时间范围: 本周 / 本月 / 自定义
  │     ├── 选择报告内容: ☑KPI ☑席位 ☑用量 ☑审计
  │     └── 确认导出
  │
  ├── API: POST /api/v1/admin/reports/export
  │     ├── 创建导出任务（异步）
  │     └── 返回 task_id + 预估等待时间
  │
  ├── 后端 Worker: Report Generator
  │     ├── PDF 格式:
  │     │   ├── 使用 Puppeteer 渲染 HTML 模板
  │     │   ├── 内容: KPI 概览 + 席位列表 + 用量图表 + 审计摘要
  │     │   ├── 图表使用 Chart.js 服务端渲染
  │     │   └── 生成 PDF 文件上传到 Object Storage
  │     │
  │     ├── CSV 格式:
  │     │   ├── 席位数据 → seats.csv
  │     │   ├── 用量数据 → usage.csv
  │     │   ├── 审计日志 → audit_logs.csv
  │     │   ├── 成本数据 → costs.csv
  │     │   └── 打包为 ZIP 上传到 Object Storage
  │     │
  │     └── 完成后发送 WebSocket 通知
  │
  └── 前端: 收到完成通知 → 自动下载
```

### 10.7 性能目标

| 指标 | 目标 |
|------|------|
| KPI 仪表盘加载（4 卡片 + 趋势） | < 300ms |
| 席位列表加载（50 条） | < 200ms |
| 席位搜索响应时间 | < 100ms |
| 权限开关切换生效延迟 | < 500ms |
| 权限检查（Redis 缓存命中） | < 5ms |
| 权限检查（缓存未命中） | < 50ms |
| 审批请求创建到通知管理员 | < 2s |
| 审批决策到 Agent 恢复执行 | < 1s |
| 审计日志写入（异步） | < 50ms |
| 审计日志查询（1万条范围内） | < 500ms |
| 费用告警检测延迟 | < 5 分钟（Worker 周期） |
| 报告导出（PDF，含图表） | < 30s |
| 报告导出（CSV，原始数据） | < 10s |
| WebSocket 广播延迟 | < 200ms |

---

## 11. 模块集成

### 11.1 与 Module 1 (Chat 对话) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| 审批通知推送 | Admin → Chat | 审批请求创建时，通过 Chat 推送通知到管理员的 DM 或指定管理频道 |
| 费用超限通知 | Admin → Chat | 费用超限告警通过 Chat 通知管理员 |
| 回滚通知 | Admin → Chat | 自动回滚发生时，通过 Chat 通知管理员和相关 Agent 的所有者 |
| Agent 权限变更通知 | Admin → Chat | Agent 权限开关变更时，通知相关用户 |
| Agent 消息权限联动 | Admin → Chat | Agent 的"外部 API 调用"权限被关闭时，影响 Chat 中的 Webhook 消息能力 |

```yaml
# Admin → Chat 通知示例
event: admin.approval_required
payload:
  workspace_id: "ws_001"
  approval_request:
    agent_name: "代码助手"
    operation: "数据库删除操作"
    risk_level: "high"
    details: "删除 users 表中 status='inactive' 的 30 条记录"
  notification:
    channel_type: "dm"
    recipient: "user_chenlh"    # Workspace 管理员
    message: "⚠️ 代码助手 请求执行高风险操作：删除 users 表中的 30 条记录。请在管理后台审批。"
```

### 11.2 与 Module 2 (Tasks 任务) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| 任务执行权限检查 | Admin ← Tasks | Agent 执行代码类任务前，Tasks 模块调用 Admin 的权限检查 API 确认 code_execution 权限 |
| 任务审批门控 | Admin ← Tasks | Agent 任务涉及高风险操作时，Tasks 模块通过 Admin 的审批 API 创建审批请求 |
| 任务用量采集 | Tasks → Admin | 任务执行过程中的 API 调用量和 Token 消耗写入 Admin 的 cost_records 和 usage_metrics |
| 任务回滚联动 | Admin → Tasks | Admin 触发自动回滚时，相关任务状态更新为"已回滚" |

**数据流：**

```
Module 2 (Tasks) 事件                      Module 7 (Admin) 处理
────────────────────                     ────────────────────────
Agent 执行代码任务 ────────────────→     权限检查: code_execution
                                         ├── ALLOW → 继续
                                         └── DENY → 返回 403, 任务失败

Agent 执行 DB DELETE 任务 ────────→      权限检查: database_ops
                                         ├── ALLOW → 审批检查
                                         │   ├── 需审批 → 创建 approval_request
                                         │   │   → 任务状态: waiting_approval
                                         │   └── 不需审批 → 继续执行
                                         └── DENY → 返回 403

任务完成，消耗 Token ──────────────→     cost_records.insert(...)
                                         usage_metrics 计数器 +1
                                         KPI 更新
```

### 11.3 与 Module 3 (Projects 项目) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| 部署审批 | Admin ← Projects | 项目部署到生产环境可配置为高风险操作，需要管理后台审批 |
| 项目级成本归因 | Projects → Admin | 按项目维度聚合 Agent 的 Credits 消耗（哪些成本归属于哪个项目） |
| 项目 Agent 权限 | Admin → Projects | 管理后台的权限控制影响项目中 Agent 的操作能力 |

### 11.4 与 Module 4 (Team 团队) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| 席位同步 | Team → Admin | 团队成员变更（加入/离开/角色变更）自动同步到 workspace_seats 表 |
| Agent 角色联动 | Team → Admin | Agent 的团队角色（执行者/审核者/协调者/观察者）决定其在管理后台的默认权限配置 |
| 权限引擎协作 | Admin ↔ Team | Module 4 的 Permission Engine（跨模块 RBAC）与 Module 7 的 Agent 权限开关（操作级控制）协同——两层权限都通过才允许操作 |
| 团队统计汇总 | Team → Admin | 团队级的成员活跃度和协作数据汇总到管理后台的 KPI |

```
权限检查的双层模型：

Agent 发起操作
  │
  ├── Layer 1: Module 4 Team RBAC（角色权限）
  │     └── Agent 的团队角色是否允许此操作？
  │         例如: 观察者不能创建任务 → DENY
  │
  ├── Layer 2: Module 7 Admin Permission（操作权限）
  │     └── Agent 的操作权限开关是否开启？
  │         例如: 代码执行=OFF → DENY
  │
  └── 两层都 ALLOW → 继续执行
      任一层 DENY → 拒绝操作
```

### 11.5 与 Module 5 (Agent 管理) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| Agent 数据同步 | Agent → Admin | Agent 的名称、模型、能力标签、头像等核心数据从 Module 5 同步 |
| Agent 状态同步 | Agent → Admin | Agent 的运行时状态（在线/离线/忙碌/异常）实时同步到 workspace_seats.status |
| Agent 用量采集 | Agent → Admin | Agent 运行时的 API 调用量、Token 消耗、计算资源使用量写入 Admin 的 usage_metrics 和 cost_records |
| Agent 暂停/恢复 | Admin → Agent | 管理后台暂停 Agent（因审批、费用超限或自动回滚）→ 同步到 Module 5 暂停 Agent 进程 |
| Agent 生命周期 | Agent → Admin | Agent 被全局停用/删除 → 自动从 workspace_seats 中移除 |

```yaml
# Module 5 → Module 7 状态同步事件
event: agent.status_changed
payload:
  agent_id: "agent_codebot"
  old_status: "online"
  new_status: "busy"
  details:
    current_task: "实现用户认证模块"
    api_calls_since_start: 142

→ Module 7 处理：
  1. 更新 workspace_seats WHERE entity_id='agent_codebot': status='online'
  2. 更新 Redis: seat_status:{agent_codebot} = "online"
  3. 推送 WebSocket: admin:seat_status_changed
  4. 前端席位表格状态列实时更新

# Module 5 → Module 7 用量采集事件
event: agent.api_called
payload:
  agent_id: "agent_codebot"
  endpoint: "/api/v1/tasks/execute"
  tokens_in: 1500
  tokens_out: 800
  cost: 0.023                       # USD

→ Module 7 处理：
  1. Redis INCR: api_calls:{agent_codebot}:{today}
  2. cost_records.insert({ entity_id: 'agent_codebot', amount: 0.023, ... })
  3. 每 5 分钟 → KPI Aggregator 聚合到 usage_metrics
```

### 11.6 与 Module 6 (AI 能力) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| 模型调用成本 | AI → Admin | AI 模型调用的 Token 消耗（按模型、按 Agent）记录到 cost_records |
| AI 用量统计 | AI → Admin | 各 AI 模型的调用次数纳入 API 调用量 KPI |
| 模型切换审计 | AI → Admin | Agent 切换 AI 模型的行为记录到审计日志 |

### 11.7 集成数据流全景

```
Module 1 (Chat)      Module 2 (Tasks)     Module 3 (Projects)
  │                      │                      │
  │                      │ 权限检查               │ 部署审批
  │                      ├──────────────────→   │──────────────────→
  │                      │                      │                    
  │ 审批/告警通知          │ 用量/成本数据          │ 成本归因            
  │ ←────────────────── │──────────────────→   │──────────────────→
  │                      │                      │                    
  │                      │                      │                    
  │                     Module 7 (Admin)                             
  │                      │ 管理控制中心                               
  │                      │                                           
  │                      ├── 系统概览 (KPI 仪表盘)                    
  │                      ├── 席位管理 (人+Agent 统一表)               
  │                      ├── 权限控制 (Agent 操作开关)                
  │                      ├── 审批策略 (高风险/费用/回滚)              
  │                      ├── 审计日志 (全操作记录)                    
  │                      └── 报告导出                                
  │                      │                      │                    
  │                      │ 席位/状态同步          │ Agent 暂停/恢复    
  │                      │ ←──────────────────  │──────────────────→ 
  │                     Module 4 (Team)        Module 5 (Agent)      
  │                      │                      │                    
  │                      │ 角色联动               │ 数据/状态/用量同步  
  │                      │──────────────────→   │──────────────────→ 
  │                      │                      │                    
  │                      │                     Module 6 (AI)         
  │                      │                      │                    
  │                      │                      │ 模型成本/用量        
  │                      │                      │──────────────────→ 
```

---

## 12. 测试用例

### 12.1 系统概览（KPI 仪表盘）

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-AD-01 | KPI 卡片展示 | 打开管理后台首页 | 4 个 KPI 卡片正确展示：Agent 数=4、活跃用户=28、API 调用=14.2k、Credits=$842 |
| TC-AD-02 | 环比变化 | 查看 KPI 卡片 | 每个卡片显示环比变化百分比和方向箭头（+12%↑ 绿色 / -5%↓ 红色） |
| TC-AD-03 | 趋势图展示 | 查看 KPI 卡片 | 每个卡片底部显示 7 天趋势 Sparkline 图，7 个数据点 |
| TC-AD-04 | 趋势图 Hover | Hover 趋势图数据点 | Tooltip 显示具体日期和数值 |
| TC-AD-05 | KPI 实时更新 | 新 Agent 加入 Workspace | Agent 数 KPI 卡片数值 +1，WebSocket 推送更新 |
| TC-AD-06 | KPI 空状态 | 新 Workspace 无数据 | KPI 卡片显示 0 值和"暂无数据"提示 |
| TC-AD-07 | 趋势数据不足 | Workspace 创建不满 7 天 | 趋势图只显示已有天数的数据点 |

### 12.2 席位管理

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-SM-01 | 席位列表展示 | 打开席位管理 | 表格正确显示所有人类+Agent 席位，按最近活跃时间降序 |
| TC-SM-02 | 类型标签区分 | 查看席位表格 | 人类显示蓝色"人类"标签，Agent 显示绿色"Agent"标签 |
| TC-SM-03 | 状态显示 | 查看状态列 | 人类：活跃（绿色）/ 离线（灰色）；Agent：在线（绿色）/ 离线（灰色） |
| TC-SM-04 | 搜索功能 | 输入"代码"搜索 | 筛选出"代码助手"，隐藏其他席位 |
| TC-SM-05 | 类型筛选 | 选择"Agent"筛选 | 只显示 Agent 类型的席位 |
| TC-SM-06 | 状态筛选 | 选择"在线"筛选 | 只显示在线/活跃状态的席位 |
| TC-SM-07 | 排序功能 | 按"本周 API 调用"降序排序 | 代码助手(5821) 排第一 |
| TC-SM-08 | 添加人类席位 | 点击添加 → 邮件邀请 | 邀请邮件发送成功，席位列表新增 pending 记录 |
| TC-SM-09 | 添加 Agent 席位 | 点击添加 → 从市场选择 Agent | Agent 添加成功，出现在席位列表 |
| TC-SM-10 | 移除人类席位 | 点击移除 → 确认 | 二次确认后席位移除，如有未完成任务提示重新分配 |
| TC-SM-11 | 移除 Agent 席位 | 移除有执行中任务的 Agent | 提示"Agent 正在执行 N 个任务"，可选等待完成或强制移除 |
| TC-SM-12 | 编辑角色 | 修改人类成员角色为管理员 | 角色即时更新，权限生效 |
| TC-SM-13 | 席位状态实时更新 | Agent 状态变更 | 状态列在 < 1s 内更新（通过 WebSocket） |
| TC-SM-14 | 分页功能 | 席位数 > 20 | 正确分页，翻页后加载正确数据 |
| TC-SM-15 | 空状态 | 新 Workspace 无席位 | 显示空状态引导："添加团队成员或 Agent" |

### 12.3 Agent 权限控制

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-PC-01 | 权限面板展示 | 打开权限控制页 | 4 个权限开关正确显示当前状态 |
| TC-PC-02 | 开启权限 | 切换"数据库操作"从 OFF 到 ON | 开关变为 ON，API 返回成功，权限即时生效 |
| TC-PC-03 | 关闭权限 | 切换"代码执行"从 ON 到 OFF | 开关变为 OFF，Agent 后续代码执行请求被拒绝 |
| TC-PC-04 | 权限生效验证 | 关闭 Agent 的代码执行 → Agent 尝试执行代码 | Agent 收到 403 错误，错误消息清晰说明原因 |
| TC-PC-05 | Workspace 级权限 | 修改 Workspace 级默认权限 | 所有没有单独配置的 Agent 受影响 |
| TC-PC-06 | Agent 级覆盖 | 为代码助手单独开启数据库操作 | 代码助手 database_ops=allow，其他 Agent 仍为 deny |
| TC-PC-07 | 重置为默认 | 点击"重置为默认" | Agent 级覆盖被删除，恢复使用 Workspace 默认权限 |
| TC-PC-08 | 权限来源显示 | 查看已覆盖的 Agent 权限 | 显示权限来源标签（"Workspace 默认"或"Agent 覆盖"） |
| TC-PC-09 | 权限缓存 | 权限变更后 Redis 缓存 | 缓存被清除，下次权限检查使用新值 |
| TC-PC-10 | 并发权限变更 | 两个管理员同时修改同一权限 | 最后写入的值生效，无数据不一致 |

### 12.4 审批策略

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-AP-01 | 启用高风险审批 | 启用"高风险操作需人工审批" | Checkbox 勾选，策略保存成功 |
| TC-AP-02 | 审批请求创建 | Agent 执行 DB DELETE（审批已启用） | 操作暂停，创建审批请求，通知管理员 |
| TC-AP-03 | 批准审批 | 管理员点击"批准" | 审批状态变为 approved，Agent 恢复执行，操作完成 |
| TC-AP-04 | 拒绝审批 | 管理员点击"拒绝" | 审批状态变为 rejected，Agent 取消操作 |
| TC-AP-05 | 审批超时 | 审批请求超过 24 小时未处理 | 自动变为 timeout_rejected，Agent 取消操作 |
| TC-AP-06 | 费用超限告警 | Agent 单日消耗超过阈值 | 告警通知发送给管理员，告警记录创建 |
| TC-AP-07 | 费用告警-暂停 | 配置为 notify_and_pause | 超限后 Agent 自动暂停 |
| TC-AP-08 | 自动回滚触发 | Agent 操作后错误率超过 30% | 自动回滚最近操作，Agent 暂停，通知管理员 |
| TC-AP-09 | 自动回滚执行 | 回滚涉及文件修改 | 文件恢复到操作前状态 |
| TC-AP-10 | 审计日志启用 | 启用操作日志审计 | 所有 Agent 操作记录完整日志 |
| TC-AP-11 | 策略禁用 | 禁用高风险审批 | Agent 操作不再需要审批，直接执行 |
| TC-AP-12 | 多策略同时生效 | 同时启用审批+费用告警+审计 | 三个策略独立运行，互不干扰 |

### 12.5 审计日志

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-AL-01 | 日志列表展示 | 打开审计日志页 | 按时间倒序显示所有操作日志 |
| TC-AL-02 | 时间范围筛选 | 选择"过去 7 天" | 只显示 7 天内的日志 |
| TC-AL-03 | 操作者筛选 | 选择"Agent" | 只显示 Agent 发起的操作日志 |
| TC-AL-04 | 操作类型筛选 | 选择"权限变更" | 只显示权限相关的日志 |
| TC-AL-05 | 结果筛选 | 选择"被拒绝" | 只显示被权限拒绝的操作 |
| TC-AL-06 | 组合筛选 | 同时选择多个筛选条件 | 条件取交集，正确筛选 |
| TC-AL-07 | 日志详情展开 | 点击日志条目的"展开" | 显示操作详情（参数、响应、时长） |
| TC-AL-08 | 实时日志推送 | 新操作发生 | 审计日志列表实时追加新条目（WebSocket） |
| TC-AL-09 | 日志导出 CSV | 点击导出 → 选择 CSV | 下载包含筛选条件内所有日志的 CSV 文件 |
| TC-AL-10 | 日志导出 JSON | 点击导出 → 选择 JSON | 下载 JSON 格式的日志文件 |
| TC-AL-11 | 日志保留策略 | 查看超过 90 天的日志 | 过期日志已被清理 |
| TC-AL-12 | 权限变更审计 | 管理员修改 Agent 权限 | 审计日志记录旧值、新值、修改人 |

### 12.6 报告导出

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-RP-01 | PDF 导出 | 点击导出 → PDF → 本月 | 生成包含 KPI、席位、用量、审计摘要的 PDF 报告 |
| TC-RP-02 | CSV 导出 | 点击导出 → CSV → 本月 | 下载 ZIP（含 seats.csv, usage.csv, audit.csv, costs.csv） |
| TC-RP-03 | 自定义时间 | 选择自定义时间范围 | 报告只包含选定时间范围的数据 |
| TC-RP-04 | 选择报告内容 | 只勾选 KPI 和席位 | 报告只包含 KPI 和席位内容 |
| TC-RP-05 | 大数据量导出 | Workspace 有 1000+ 审计日志 | 导出成功，文件完整 |
| TC-RP-06 | 导出进度 | 导出大型报告 | 显示进度条或加载状态，完成后自动下载 |

### 12.7 性能测试

| 指标 | 测试方法 | 目标 |
|------|---------|------|
| KPI 仪表盘加载 | API 响应时间 + FCP | < 300ms (API) + FCP < 1s |
| 席位列表加载（50 条） | API 响应时间 | < 200ms |
| 席位搜索 | API 响应时间 | < 100ms |
| 权限检查（缓存命中） | k6 负载测试 | P99 < 10ms |
| 权限开关变更生效 | 端到端计时 | < 500ms |
| 审批请求创建到通知 | 端到端计时 | < 2s |
| 审计日志写入 | k6 负载测试 | > 1000 entries/s |
| 审计日志查询（10k 条） | API 响应时间 | < 500ms |
| WebSocket 广播 | 端到端延迟 | < 200ms |
| PDF 报告生成 | 端到端计时 | < 30s |
| 并发管理员操作 | 多会话同时操作 | 无数据不一致 |

### 12.8 安全测试

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-SEC-01 | 非管理员访问 | 普通成员访问管理后台 API | 返回 403，无法查看任何管理数据 |
| TC-SEC-02 | Agent 访问管理后台 | Agent 调用管理后台 API | 返回 403，Agent 不能管理自己的权限 |
| TC-SEC-03 | 权限绕过测试 | Agent 直接调用操作 API（绕过权限检查） | 权限中间件阻止，返回 403 |
| TC-SEC-04 | 审批绕过测试 | Agent 在审批未通过时直接执行操作 | 操作被拒绝，记录安全审计日志 |
| TC-SEC-05 | 审计日志不可篡改 | 尝试修改已写入的审计日志 | 审计日志表无 UPDATE 权限，只允许 INSERT |
| TC-SEC-06 | 敏感信息脱敏 | 审计日志中的 SQL 语句包含密码 | 自动脱敏敏感字段 |

---

## 13. 成功指标

### 13.1 核心治理指标

| 指标 | MVP (2 月后) | 成熟期 (10 月后) | 说明 |
|------|-------------|-----------------|------|
| 管理后台日访问量 | 5 次/天 | 50 次/天 | 管理员打开管理后台的次数 |
| 席位管理操作频率 | 3 次/周 | 20 次/周 | 添加/移除/修改席位的操作次数 |
| Agent 权限配置覆盖率 | > 50% | > 90% | 配置了非默认权限的 Agent / 总 Agent |
| 权限检查触发量 | 500 次/天 | 10,000 次/天 | Agent 操作触发权限检查的总次数 |
| 权限拒绝率 | < 20% | < 5% | 被权限拒绝的操作 / 总操作（过高说明权限过严，过低说明形同虚设） |

### 13.2 审批效率指标

| 指标 | MVP | 成熟期 | 说明 |
|------|-----|--------|------|
| 审批请求量 | 5 次/周 | 50 次/周 | 每周创建的审批请求数 |
| 审批响应时间（中位数） | < 2 小时 | < 30 分钟 | 从创建到决策的时间 |
| 审批超时率 | < 20% | < 5% | 超时自动拒绝 / 总审批请求 |
| 审批批准率 | 60-80% | 70-90% | 批准 / 总审批（过低说明 Agent 频繁触发不必要审批） |

### 13.3 成本治理指标

| 指标 | MVP | 成熟期 | 说明 |
|------|-----|--------|------|
| Credits 消耗可见率 | > 80% | > 99% | 可追溯到具体 Agent 的成本 / 总成本 |
| 费用超限告警准确率 | > 90% | > 99% | 合理告警 / 总告警（避免误报） |
| Agent 月度成本标准差 | 下降趋势 | 稳定 | 各 Agent 成本波动收敛，说明成本可控 |
| 报告导出使用频率 | 1 次/月 | 4 次/月 | 报告导出功能的使用频率 |

### 13.4 安全审计指标

| 指标 | MVP | 成熟期 | 说明 |
|------|-----|--------|------|
| 审计日志覆盖率 | > 90% | 100% | 被审计的 Agent 操作 / 总 Agent 操作 |
| 自动回滚成功率 | > 70% | > 90% | 成功回滚 / 总回滚触发 |
| 审计日志查询使用率 | 2 次/周 | 10 次/周 | 管理员查询审计日志的频率 |
| 安全事件响应时间 | < 4 小时 | < 1 小时 | 从异常检测到管理员响应的时间 |

### 13.5 体验指标

| 指标 | 目标 | 说明 |
|------|------|------|
| 管理后台首页加载 P99 | < 1s | 含 KPI 卡片 + 席位表格 |
| 权限变更生效 P99 | < 1s | 开关切换到权限生效 |
| 审批通知到达 P99 | < 5s | 审批请求创建到管理员收到通知 |
| 审计日志查询 P99 | < 1s | 含筛选条件的查询 |
| 报告导出 P95 | < 30s | PDF 报告生成 |
| 管理员在管理后台停留时间 | > 3 分钟 | 说明管理员在使用管理功能 |

---

## 14. 风险与缓解

### 14.1 技术风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **权限检查延迟影响 Agent 性能** — 每个 Agent 操作都需要权限检查，如果权限检查成为瓶颈（Redis 不可用、缓存击穿），会严重影响 Agent 执行效率 | 中 | 高 | Redis 高可用集群部署。权限检查超时兜底（超过 50ms 默认放行但标记为"未验证"并记录告警）。本地内存二级缓存（权限矩阵在进程启动时加载到内存，5 分钟刷新）。权限检查结果持久化到 Redis 确保跨请求复用 |
| **审批工作流阻塞 Agent 执行** — Agent 发起高风险操作后进入等待审批状态，如果管理员响应慢，Agent 长时间被阻塞 | 高 | 中 | 审批超时机制（默认 24 小时自动拒绝——安全优先）。P2 支持条件自动审批（如金额 < $10 自动批准）。多通道通知管理员（站内 + 邮件 + IM）。审批响应时间 SLA 监控。Agent 在等待审批期间可执行其他非审批操作 |
| **审计日志存储膨胀** — 高活跃 Workspace 的审计日志量可能非常大（每天数万条），导致数据库存储和查询性能下降 | 中 | 中 | 审计日志保留策略（默认 90 天，可配置）。过期日志自动归档到 Object Storage（Cold Storage）。审计日志表使用 TimescaleDB 或表分区（按月分区）。查询时强制要求时间范围筛选，防止全表扫描 |
| **KPI 数据实时性与准确性** — KPI 数据依赖后台 Worker 聚合（每 5 分钟），存在最多 5 分钟的延迟。如果 Worker 故障，KPI 可能显示过时数据 | 中 | 低 | KPI 页面显示"数据更新时间"让管理员知道数据新鲜度。Worker 健康监控 + 自动重启。关键 KPI（如 Agent 在线状态）使用 WebSocket 实时推送而非 Worker 聚合。数据异常检测——KPI 突然归零时显示"数据可能不完整"警告 |
| **自动回滚误操作** — 错误率监控的误判可能导致自动回滚正常操作，造成数据损坏 | 低 | 高 | 回滚操作本身也写入审计日志。min_operations_for_trigger 参数避免小样本误判。回滚前自动创建操作快照。回滚失败时停止回滚并通知管理员（不强制继续）。回滚后 Agent 自动暂停，需管理员确认后才恢复 |
| **多管理员并发操作冲突** — 多个管理员同时修改权限或审批策略，可能导致配置不一致 | 低 | 低 | 乐观锁（基于 updated_at 的 Optimistic Locking）。操作冲突时前端提示"配置已被其他管理员修改，请刷新"。所有变更记录到审计日志，可追溯 |

### 14.2 产品风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **权限配置过于简单** — 四个 Toggle 开关可能无法满足企业客户的精细化权限需求（如：允许 SELECT 但禁止 DELETE） | 中 | 中 | MVP 先用四维度开关验证产品假设。P2 扩展为更细粒度的权限矩阵（如数据库操作拆分为：SELECT / INSERT / UPDATE / DELETE / DDL）。提供 API 级别的自定义权限规则（高级模式）。收集用户反馈迭代权限模型 |
| **管理后台使用频率低** — 管理后台是低频功能，管理员可能很少主动打开 | 高 | 低 | 主动推送关键指标变化（KPI 周报自动发送到管理员邮箱）。审批通知拉动管理员打开管理后台。KPI 异常检测主动告警（如 API 调用量突增 50%）。管理后台入口放在全局导航栏显眼位置 |
| **审批流程增加 Agent 延迟** — 用户可能认为审批流程降低了 AI Agent 的自动化效率 | 中 | 中 | 默认只对极高风险操作启用审批（如 DB DELETE），日常操作不需审批。审批策略可完全关闭。提供清晰的"审批 vs 风险"权衡说明。P2 支持智能审批（低风险操作自动批准） |
| **成本归因不准确** — 某些 Agent 操作的成本难以精确计算（如共享资源的分摊） | 中 | 低 | MVP 阶段按 API 调用次数和 Token 消耗计算直接成本。共享资源成本按比例分摊（基于 Agent 的 API 调用量占比）。成本数据显示"预估"标签，提醒管理员这是近似值。P2 引入更精确的成本模型 |

### 14.3 安全风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **Agent 权限提升攻击** — Agent 可能通过某种方式修改自己的权限配置（如：利用代码执行权限修改数据库中的权限记录） | 低 | 高 | Agent 的数据库连接使用独立的只读/受限 Schema，不能直接访问 agent_permissions 表。权限管理 API 只接受人类管理员的 JWT Token，Agent Token 被严格拒绝。所有权限变更记录审计日志，异常变更自动告警 |
| **审计日志被篡改** — 如果审计日志可以被修改或删除，审计就失去了意义 | 低 | 高 | audit_logs 表设计为 Append-Only（应用层面只允许 INSERT，不允许 UPDATE/DELETE）。数据库用户级别限制（Agent 使用的 DB role 没有 audit_logs 的 DELETE 权限）。定期将审计日志导出到不可变存储（如 S3 Object Lock）。审计日志完整性校验（P2：Merkle Tree 链式哈希） |
| **管理员账户被盗用** — 如果管理员账户被恶意获取，攻击者可以通过管理后台关闭所有权限控制 | 低 | 高 | 管理后台关键操作（如：关闭审批策略、全局开启数据库权限）需要二次认证（MFA）。管理员操作全部记录审计日志。管理员登录异常检测（异地登录、非工作时间登录）告警。P2 支持多管理员审批（关键配置变更需要两个管理员同意） |
| **费用告警失效** — Cost Tracking Worker 故障导致费用超限未告警，Agent 消耗大量 Credits | 中 | 中 | Worker 健康监控 + 自动重启。Worker 心跳检测——超过 15 分钟未运行告警。备用告警机制：数据库层面的触发器（当 cost_records 累计超过阈值时直接告警）。费用硬限制（P2：Agent 消耗超过绝对上限时自动暂停，不依赖 Worker） |

---

## 15. 排期建议

### 15.1 为什么是 3 周？

Module 7（Admin 管理后台）P0 范围的工期估算为 ~3 周（1 前端 + 0.5 后端），原因如下：

1. **KPI 仪表盘是数据展示**：4 个 KPI 卡片 + Sparkline 趋势图是纯展示组件，数据从后台 Worker 预聚合好，前端直接渲染。前端工作量主要在卡片组件和趋势图
2. **席位管理是标准 CRUD**：统一席位表格的增删改查是标准操作，复用 Module 4 的成员管理逻辑。表格组件可复用现有的 DataTable 组件
3. **权限开关是简单配置管理**：4 个 Toggle 开关对应数据库中的 4 行配置记录，CRUD 非常简单。Permission Engine 的核心逻辑（缓存 + 检查）在 Module 4 中已有基础
4. **审批和审计是 P1**：高风险审批、自动回滚、审计日志查看等复杂功能在 P1 中实现，P0 只需要基础的权限控制和席位管理
5. **复用已有基础设施**：WebSocket、Event Bus、Redis 缓存、Auth 中间件全部复用 Module 1-4 已搭建的基础设施。后台 Worker 框架复用已有的 cron 系统

### 15.2 Sprint 规划（P0 范围约 3 周）

#### Sprint 1: KPI 仪表盘与席位表格（第 1 周）

**做什么：** 搭建管理后台的核心界面——KPI 仪表盘和统一席位管理表格。

**后端（0.5 人周）：**
- 数据库 Schema 创建（workspace_settings, workspace_seats, agent_permissions, usage_metrics, cost_records）
- 席位管理 API（CRUD + 搜索 + 筛选 + 排序 + 分页）
- KPI 数据聚合 Worker（定时任务，每 5 分钟聚合 usage_metrics）
- KPI 仪表盘 API（GET /admin/dashboard，返回 4 KPI + 7 天趋势）
- 席位数据同步（监听 Module 4/5 的成员/Agent 变更事件，同步到 workspace_seats）

**前端（1 人周）：**
- 管理后台页面框架（Admin Layout + 导航）
- KPI 卡片组件（KPICard + SparklineChart + TrendBadge）
- KPI 卡片网格（4 卡片横排，响应式布局）
- 席位管理表格（SeatTable + SeatTableRow + SeatTypeTag + SeatStatusBadge）
- 搜索 + 筛选栏（SeatSearchBar）
- 添加/移除席位弹窗（AddSeatModal + RemoveSeatConfirm）

**难点：** KPI 数据的实时性——Worker 聚合周期 5 分钟，需要确保管理员看到的数据足够新鲜。席位表格的多维度筛选和排序需要后端支持复合查询。

#### Sprint 2: Agent 权限控制（第 2 周）

**做什么：** 实现 Agent 执行权限的开关式控制面板，以及权限检查中间件。

**后端（0.5 人周）：**
- Agent 权限 CRUD API（Workspace 级 + Agent 级）
- Permission Check API（内部 API，供其他模块调用）
- Permission Engine 中间件（Redis 缓存 + 三层计算）
- 权限变更审计日志记录
- WebSocket 推送权限变更事件

**前端（1 人周）：**
- 权限控制面板（PermissionPanel）
- 权限开关组件（PermissionToggle）
- 权限范围选择器（PermissionScopeSelector：所有 Agent / 特定 Agent）
- 权限来源标签（PermissionSourceBadge）
- 席位详情面板（SeatDetailPanel，展示单席位的详细用量数据）
- 实时状态更新（WebSocket 消费 + 席位表格状态刷新）

**难点：** 三层权限继承的计算逻辑。权限变更的即时生效（缓存清除 + WebSocket 通知）。权限面板的 UI 需要清晰展示当前权限来源。

#### Sprint 3: 集成联调与完善（第 3 周）

**做什么：** 将 Permission Engine 集成到 Module 2-5 的 API 中，实现端到端的权限控制。完善管理后台的各项细节。

**后端（0.5 人周）：**
- Permission Engine 集成到 Module 2 API（任务执行前的权限检查）
- Permission Engine 集成到 Module 5 API（Agent 操作的权限检查）
- 用量采集 pipeline（Agent API 调用 → usage_metrics + cost_records）
- 席位统计缓存定时更新（api_calls_this_week, credits_consumed_this_month）
- 导出报告基础版本（CSV 导出）

**前端（1 人周）：**
- 前端权限感知（根据管理员角色显示/隐藏管理功能）
- 导出报告功能（ReportExportModal + 格式选择 + 下载）
- 全流程联调 + Bug 修复
- 空状态和错误状态设计
- 响应式布局适配
- 管理后台导航和入口优化

**难点：** 跨模块权限集成需要和 Module 2/5 团队协调 API 变更。用量采集 pipeline 需要确保数据不丢失且性能可接受。

### 15.3 P1 功能排期（约 2 周，P0 完成后）

#### Sprint 4-5: 审批系统 + 审计日志 + 报告（第 4-5 周）

**后端（1 人周）：**
- 审批策略 CRUD API
- 审批请求生命周期管理（创建 → 通知 → 决策 → 执行/取消）
- 审批超时 Worker（每分钟检查过期审批）
- 审计日志记录 pipeline（所有 Agent 操作 → audit_logs）
- 审计日志查询 API（支持多维度筛选 + 导出）
- 费用超限检测 Worker
- 自动回滚引擎
- PDF 报告生成（Puppeteer）

**前端（1 人周）：**
- 审批策略配置面板
- 审批请求列表 + 审批操作 UI
- 审计日志查看页面（筛选器 + 时间线 + 详情展开）
- 审计日志导出功能
- 费用超限告警通知 UI
- PDF 报告预览和导出
- 用量分析图表（按 Agent 分组的趋势图、成本饼图）

### 15.4 P2 功能排期（约 2 周，P1 完成后）

#### Sprint 6-7: 高级功能（第 6-7 周）

- 定期自动报告（配置 + 邮件发送）
- 多级审批工作流
- 条件自动审批
- 自定义权限维度
- 成本预算管理
- Agent 级 Credits 配额
- 审计日志不可变存储
- 管理后台国际化

### 15.5 里程碑

| 里程碑 | 时间 | 关键能力 | 对应 Sprint |
|--------|------|---------|------------|
| **M1: Dashboard & Seats** | Week 1 | KPI 仪表盘 + 统一席位管理 + 数据聚合 | Sprint 1 |
| **M2: Permission Control** | Week 2 | Agent 权限开关 + Permission Engine + 实时状态 | Sprint 2 |
| **M3: Integration** | Week 3 | 跨模块权限集成 + 用量采集 + 报告导出（CSV） | Sprint 3 |
| **M4: Approval & Audit** | Week 5 | 审批系统 + 审计日志 + 费用告警 + 自动回滚 + PDF 报告 | Sprint 4-5 |
| **M5: Advanced** | Week 7 | 自动报告 + 高级审批 + 自定义权限 + 成本预算 | Sprint 6-7 |

### 15.6 团队配置

| 角色 | 人数 | 职责 |
|------|------|------|
| 前端工程师 | 1 | KPI 卡片 + 席位表格 + 权限面板 + 审批 UI + 审计日志 + 报告导出 + 图表组件 |
| 后端工程师 | 0.5 | Admin Service + Permission Engine + Approval Engine + Usage/Cost Workers + 审计日志 + 报告生成 |

**注意：** 后端工作量为 0.5 人（非全职投入），因为：
1. Permission Engine 的核心框架已在 Module 4 中搭建，Module 7 主要是在管理后台层面的配置和调用
2. 数据聚合 Worker 是标准的定时任务，逻辑简单
3. 席位管理和权限管理都是标准 CRUD，业务逻辑不复杂
4. 但 P1 的审批系统和自动回滚引擎需要额外的后端投入（Sprint 4-5 需要 1 人周后端）

### 15.7 依赖关系

```
Module 4 (Team)    ──→  Module 7 依赖 M4 的 Permission Engine 核心框架
Module 5 (Agents)  ──→  Module 7 强依赖 M5 的 Agent 数据和状态 API、用量数据
Module 2 (Tasks)   ──→  Module 7 的权限检查需集成到 M2 的任务执行 API
Module 1 (Chat)    ──→  Module 7 的通知推送通过 M1 的消息 API

Module 7 输出：
  ├── Permission Check API → M2/M5 调用（Agent 操作权限验证）
  ├── Approval API → M2/M5 调用（高风险操作审批）
  ├── Audit Log Pipeline → 全模块写入（操作审计）
  ├── Cost Tracking → 全模块写入（成本归因）
  └── KPI Dashboard → 面向管理员的运营视图
```

**关键依赖：**
- Module 5（Agent 管理）的 agents 表和状态 API 是前置条件。Agent 的名称、状态、用量数据全部来自 Module 5
- Module 4（Team）的 Permission Engine 是技术基础——Module 7 在其之上增加管理后台级别的操作权限控制
- 如果 Module 5 未就绪，Module 7 的 Agent 相关功能（Agent 席位、Agent 权限、Agent 用量）需要使用 Mock 数据开发
- Permission Check API 是 Module 7 的核心输出，需要 Module 2/5 团队配合集成。建议在 Sprint 2 完成 Permission Engine 后立即协调

---

> **文档结束。** 本 PRD 由 Zylos AI Agent 在 Stephanie 的产品指导下撰写。如有调整需求，请直接反馈。
