# CODE-YI Module 6: 工具箱 (Toolbox) — 产品需求文档

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
7. [MCP 协议集成引擎](#7-mcp-协议集成引擎)
8. [技能市场架构](#8-技能市场架构)
9. [数据模型](#9-数据模型)
10. [技术方案](#10-技术方案)
11. [模块集成](#11-模块集成)
12. [测试用例](#12-测试用例)
13. [成功指标](#13-成功指标)
14. [风险与缓解](#14-风险与缓解)
15. [排期建议](#15-排期建议)

---

## 1. 问题陈述

### 1.1 当前 AI Agent 技能/工具生态的结构性缺陷

当前 AI Agent 在扩展能力时，面临一个根本性矛盾：**Agent 的智能程度取决于它能调用多少外部工具，但现有的工具集成方式要么过于碎片化、要么需要大量开发工作、要么缺乏安全治理机制**。当用户希望让 Agent 连接 GitHub、查询数据库、管理飞书消息、扫描代码安全时，他们面对的不是一个统一的"技能市场"，而是一堆散落在不同生态中、需要手动拼接的零件。

**VS Code Extensions Marketplace 的局限：**
- **只服务 IDE 场景**：VS Code Extensions 本质上是编辑器插件——语法高亮、代码补全、调试器。它不是为"AI Agent 调用外部服务"设计的。Agent 需要的不是"在编辑器里看到 GitHub PR 列表"，而是"能自动创建 PR、Review 代码、合并分支"
- **没有 OAuth 授权流程**：Extensions 通过 VS Code 的 Authentication API 获取 Token，但这是编辑器级别的单用户授权，不支持"一个 Agent 代替多个团队成员操作 GitHub"的场景
- **不支持 MCP 协议**：Extensions 使用 VS Code Extension API，与 MCP（Model Context Protocol）完全无关。Agent 无法通过 Extension 获取结构化的工具描述和调用接口
- **安装后无法热加载**：Extension 安装后通常需要重启或 Reload Window，不支持"安装即可用"的热加载体验

**JetBrains Plugin Marketplace 的局限：**
- **重 IDE 绑定**：JetBrains 插件必须在特定 IDE 内运行（IntelliJ IDEA、PyCharm 等），无法脱离 IDE 独立为 Agent 提供能力
- **插件审核周期长**：JetBrains Marketplace 的审核流程通常需要 1-3 天，不适合社区快速迭代的技能发布
- **缺乏 Agent 视角**：插件面向人类开发者设计，没有"工具描述 → Agent 理解 → Agent 调用"的元数据结构

**Claude MCP 生态的局限：**
- **协议标准但无统一市场**：MCP 定义了 Agent 与工具交互的协议，但截至 2026 年 4 月，没有一个官方的"MCP Server 市场"。用户需要自己在 GitHub 上搜索 MCP Server、手动配置 JSON、手动启动进程
- **安装过程极其繁琐**：一个典型的 MCP Server 安装流程：`git clone → npm install → 配置 environment variables → 编辑 claude_desktop_config.json → 重启 Claude Desktop`。对非开发者用户来说几乎不可能完成
- **没有评分和安全审核**：GitHub 上的 MCP Server 质量参差不齐，没有安装量统计、用户评分、安全审核。用户无法判断哪个 MCP Server 可靠
- **OAuth 授权需手动处理**：GitHub MCP Server 需要用户手动生成 Personal Access Token 并填入配置文件。没有"一键 OAuth"的体验
- **版本管理缺失**：MCP Server 升级需要手动 `git pull → npm install`，没有自动更新机制

**GPT Actions / GPTs Store 的局限：**
- **封闭生态**：GPT Actions 只在 OpenAI 的 ChatGPT 生态内可用，不支持跨平台 Agent
- **OpenAPI Schema 限制**：GPT Actions 要求服务端暴露 OpenAPI 规范的 HTTP 端点，对不提供 REST API 的工具（如数据库直连、本地文件操作）无法支持
- **GPTs Store 质量问题**：GPTs Store 充斥大量低质量 GPT，搜索和发现体验差。没有企业级的审核和治理机制
- **不支持本地运行**：所有 Action 调用都通过 OpenAI 的服务器中转，敏感数据必须经过 OpenAI 的基础设施

**Zapier / Make 的局限：**
- **面向人类的自动化工具**：Zapier/Make 的核心设计是"人类定义触发条件 → 自动执行动作"。它不是为"AI Agent 在对话过程中动态决定调用哪个工具"设计的
- **缺乏 Agent 语义层**：Zapier 的 Action 是预定义的固定步骤，没有"工具描述 → LLM 理解 → LLM 选择调用"的语义层。Agent 无法根据用户指令自主选择合适的 Zapier Action
- **价格昂贵**：Zapier Professional 计划 $49.99/月仅支持 2,000 个任务。AI Agent 的高频调用场景下成本极高
- **延迟高**：每次 Zapier 调用需要经过 Zapier 的云端编排引擎，延迟通常在 2-10 秒

**npm / pip 作为技能注册中心的局限：**
- **包管理器 ≠ 技能市场**：npm 和 pip 管理的是代码包，不是"可被 Agent 即时调用的技能"。安装一个 npm 包后，还需要写代码集成
- **没有元数据标准**：package.json 描述的是代码包的依赖和入口，没有"这个工具能做什么、接受什么参数、返回什么结果"的语义化描述
- **没有 OAuth 集成**：npm 包不负责 OAuth 授权。每个需要授权的集成都需要开发者自行实现 OAuth 流程
- **安全审核弱**：npm 的安全审核主要靠自动化扫描（CVE 数据库匹配），没有人工审核。恶意包事件频发

**LangChain Tools / CrewAI Tools 的局限：**
- **代码级集成**：LangChain 和 CrewAI 的 Tools 是 Python/TypeScript 类库，需要开发者写代码注册和调用。没有 UI 层面的"浏览市场 → 一键安装"体验
- **没有运行时隔离**：Tool 代码直接在 Agent 进程中运行，一个有 Bug 的 Tool 可能导致整个 Agent 崩溃
- **缺乏版本管理和更新**：Tool 作为代码库的一部分，升级需要修改代码和重新部署
- **社区发现困难**：LangChain Hub 虽然有 Prompt 共享，但 Tool 共享极为有限。CrewAI 没有官方的 Tool 市场

### 1.2 核心洞察

所有现有方案可以分为两类——**协议层（MCP、OpenAPI）** 和**市场层（VS Code Marketplace、GPTs Store、npm）**——但没有一个方案同时做好了两者。

```
现状（碎片化生态）：
  协议层：
  - MCP：标准好但无市场、无 UI、安装繁琐
  - OpenAPI/GPT Actions：封闭在 OpenAI 生态内
  - LangChain Tools：代码级集成，无 UI
  
  市场层：
  - VS Code Marketplace：只服务 IDE，不服务 Agent
  - GPTs Store：封闭在 ChatGPT 内，质量差
  - npm/pip：包管理器，不是技能市场
  
  ↓ 问题：用户在"找到合适的工具"和"让 Agent 真正用上这个工具"之间隔着巨大鸿沟

CODE-YI 模型（统一技能市场）：
  协议层 + 市场层 = 一体化
  - MCP 协议原生支持（兼容所有 MCP Server）
  - 统一技能市场 UI（浏览、搜索、评分、安装）
  - 一键安装 + OAuth 授权（从发现到可用 < 30 秒）
  - 安全审核 + 沙箱运行 + 版本管理
  - 社区技能上传 + 官方认证
```

### 1.3 市场机会

- 2025-2026 年，MCP 协议正在成为 AI Agent 与外部工具交互的事实标准。Anthropic、Google、Microsoft 等主要 AI 厂商均已表态支持 MCP。但**没有一个产品**在 MCP 生态上构建了 VS Code Marketplace 级别的发现和安装体验
- GitHub 上已有 5,000+ MCP Server 项目（截至 2026 年 4 月），但用户发现它们的方式仍然是"搜 GitHub → 看 README → 手动安装"——这和 2010 年之前的软件安装体验没有区别
- GPTs Store 证明了"AI 技能市场"的用户需求真实存在（GPTs Store 上线首月访问量超过 1 亿），但 GPTs Store 的封闭性和质量问题限制了其价值。一个**开放的、基于 MCP 标准的、带安全审核的 Agent 技能市场**是巨大的蓝海
- 企业用户迫切需要"统一管理 Agent 能使用哪些工具"的治理能力——哪些 Agent 可以访问 GitHub、哪些可以查询数据库、哪些可以发送邮件。现有方案完全没有这种治理层
- 这是 CODE-YI 的差异化窗口：一个**以 MCP 协议为底座、以一键安装和 OAuth 授权为体验核心、以安全审核和权限治理为企业级保障的 AI-Native 技能市场**

---

## 2. 产品愿景

### 2.1 一句话定位

**CODE-YI 工具箱是全球首个以 MCP 协议为底座、融合内置技能/MCP 集成/社区技能的 AI Agent 统一技能市场——提供一键安装、自动 OAuth 授权、沙箱运行、安全审核的端到端技能管理体验，让 Agent 的能力扩展像手机装 App 一样简单。**

### 2.2 核心价值主张

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        CODE-YI 工具箱系统                                 │
├──────────────────┬──────────────────────┬────────────────────────────────┤
│ 统一技能市场       │ MCP 协议引擎          │ 安全与治理                      │
│                  │                      │                                │
│ 浏览/搜索/分类    │ MCP Server 自动发现   │ 技能沙箱隔离                    │
│ 评分/安装数统计   │ 协议握手 + 工具注册    │ OAuth 授权托管                  │
│ 一键安装/卸载    │ 工具调用 + 错误处理    │ 安全扫描 + 人工审核             │
│ 社区上传/分享    │ 热加载（无需重启）     │ 安装权限管理                    │
│ 版本管理/更新    │ 多协议适配            │ 调用频率限制                    │
└──────────────────┴──────────────────────┴────────────────────────────────┘
```

### 2.3 核心差异化

| 维度 | VS Code Marketplace | GPTs Store | MCP 生态（原生） | Zapier | npm | **CODE-YI Toolbox** |
|------|-------------------|------------|----------------|--------|-----|---------------------|
| 面向 Agent 设计 | 否（面向 IDE） | 部分（面向 ChatGPT） | 是（但无市场） | 否（面向自动化） | 否（面向代码） | **原生为 Agent 设计** |
| MCP 协议支持 | 不支持 | 不支持 | 原生 | 不支持 | 不支持 | **原生支持 + 兼容** |
| 一键安装 | 支持 | 部分 | 不支持（手动） | 支持 | 不支持 | **一键安装 + 热加载** |
| OAuth 授权 | 编辑器级 | 内置 | 手动配置 | 内置 | 无 | **一键 OAuth + 令牌托管** |
| 安全审核 | 弱 | 弱 | 无 | 强（企业级） | 弱 | **自动扫描 + 人工审核** |
| 社区市场 | 成熟 | 有（质量差） | GitHub 散落 | 无 | 成熟 | **分级审核 + 评分** |
| 沙箱运行 | Extension Host | 无 | 无 | 云端隔离 | 无 | **容器级沙箱** |
| 版本管理 | 支持 | 无 | 无 | 内部 | 支持 | **语义化版本 + 自动更新** |
| Agent 权限控制 | 无 | 粗粒度 | 无 | 无 | 无 | **角色级技能权限** |

### 2.4 设计理念

**"Skill as a Service"** ——每个技能都是一个可发现、可安装、可调用、可治理的独立服务。

Stephanie 的设计稿（Screen 6）完美体现了这一理念：页面顶部是分类 Tab（全部/内置技能/MCP 集成/社区技能/我的技能），右上角是"上传技能"入口；主体是 8 张技能卡片——每张卡片展示技能名称、来源标签（官方/社区）、评分、安装数、安装状态和一句话描述。用户打开工具箱页面，就能像逛 App Store 一样浏览和安装 Agent 技能——从发现到安装到使用，整个流程在 30 秒内完成。Stephanie 的批注"这个就是 skill"精确概括了设计意图：**技能是 Agent 的核心能力单元，工具箱是管理这些能力的统一入口**。

---

## 3. 竞品对标

### 3.1 Agent 技能/工具管理能力对比

| 功能 | VS Code Ext | JetBrains Plugin | Claude MCP | GPTs Store | Zapier | LangChain Tools | CrewAI Tools | **CODE-YI** |
|------|------------|------------------|-----------|------------|--------|----------------|-------------|-------------|
| 技能浏览市场 | ★★★★★ | ★★★★ | ★ | ★★★ | ★★★★ | ★ | ★ | ★★★★★ |
| 一键安装 | ★★★★★ | ★★★★ | ★ | ★★★★ | ★★★★ | ★ | ★ | ★★★★★ |
| MCP 协议支持 | - | - | ★★★★★ | - | - | ★★ | ★★ | ★★★★★ |
| OAuth 自动授权 | ★★ | ★ | ★ | ★★★ | ★★★★★ | ★ | ★ | ★★★★ |
| 安全审核 | ★★★ | ★★★★ | ★ | ★★ | ★★★★ | ★ | ★ | ★★★★ |
| 社区上传 | ★★★★★ | ★★★★ | ★★★ | ★★★★ | ★★ | ★★ | ★★ | ★★★★ |
| 热加载 | ★★ | ★ | ★ | ★★★★ | ★★★★ | ★ | ★ | ★★★★★ |
| 沙箱隔离 | ★★★ | ★★ | ★ | ★★★★ | ★★★★★ | ★ | ★ | ★★★★ |
| 版本管理 | ★★★★★ | ★★★★★ | ★ | ★ | ★★★ | ★★★ | ★★ | ★★★★ |
| Agent 权限控制 | - | - | - | ★ | ★★ | - | - | ★★★★ |

### 3.2 深度分析

**VS Code Extensions Marketplace：**
- 优势：成熟的市场基础设施——搜索、分类、评分、安装数、版本历史、自动更新。拥有超过 50,000 个 Extension，社区活跃度极高。Extension Host 提供了进程级别的隔离
- 劣势：完全围绕 IDE 场景设计。Extension API 不兼容 MCP 协议。安装后很多 Extension 需要 Reload Window（非热加载）。Extension 的能力边界是编辑器内操作，无法代表 Agent 执行外部服务调用（如创建 Jira Issue、发送飞书消息）
- 核心缺失：没有"Agent 技能"的概念。一个 Extension 可以增强编辑器功能，但不能成为 Agent 可调用的工具
- **可借鉴：** 市场 UI 设计、评分系统、版本管理、分类体系、自动更新机制

**JetBrains Plugin Marketplace：**
- 优势：严格的审核流程保证了插件质量。与 IDE 的深度集成提供了无缝体验。支持付费插件（Freemium 模式）
- 劣势：审核周期长（1-3 天），不适合社区快速迭代。Plugin 绑定特定 IDE 版本，兼容性问题频发。安装和更新通常需要重启 IDE
- 核心缺失：同 VS Code——面向 IDE 插件，不是 Agent 技能市场
- **可借鉴：** 审核流程、质量保证机制、付费模式设计

**Claude MCP 生态：**
- 优势：协议设计优秀——标准化的工具描述格式（JSON Schema）、双向通信（Server → Client 通知）、资源和提示词管理。社区增长迅速，GitHub 上 MCP Server 数量从 2024 年底的 100+ 增长到 2026 年 4 月的 5,000+
- 劣势：**没有市场**——用户通过 GitHub 搜索和 README 文档发现 MCP Server。安装过程纯手动（clone → install → 配置 JSON → 重启）。没有评分、安装数、安全审核。OAuth 授权需要用户手动获取 Token 并填入配置。版本升级需要手动 `git pull`
- 核心缺失：有协议标准但缺乏"发现 → 安装 → 使用"的完整闭环。MCP 是"引擎"，但没有"驾驶舱"
- **可借鉴：** MCP 协议标准——CODE-YI 应原生兼容 MCP，而非另起炉灶。协议层直接采用 MCP，市场层由 CODE-YI 补齐

**GPTs Store / GPT Actions：**
- 优势：在 ChatGPT 生态内，GPTs 数量超过 300 万（截至 2025 年底），证明了 AI 技能市场的需求。GPT Actions 通过 OpenAPI Schema 连接外部服务，设计思路清晰
- 劣势：**封闭生态**——GPTs 只在 ChatGPT 内可用，不能被其他 Agent 使用。GPTs Store 质量问题严重——大量标题党和低价值 GPT 占据搜索结果。GPT Actions 要求服务端必须暴露 REST API（不支持数据库直连、本地工具等场景）。安全审核形同虚设，多次出现数据泄露事件
- 核心缺失：封闭性是致命问题。企业无法将 GPT Actions 用于非 OpenAI 的 Agent
- **可借鉴：** "一键启用"的用户体验。Actions 的 OAuth 集成流程设计。GPTs Store 的分类和搜索 UI

**Zapier / Make：**
- 优势：连接 7,000+ 应用，OAuth 授权托管做得极好——用户点击"连接"即可完成授权，Token 管理完全透明。企业级安全合规（SOC 2, GDPR）。Webhook 和 API 调用的可靠性极高
- 劣势：面向人类设计的"触发 → 动作"自动化工具，没有 Agent 语义层。Agent 无法根据对话上下文动态决定调用哪个 Zapier Action。价格昂贵——高频 Agent 调用场景下月费可能达数百美元。延迟较高（每次调用 2-10 秒经过 Zapier 云端）
- 核心缺失：没有"工具描述 → Agent 理解 → Agent 自主选择"的能力。Zapier 是人类设定好规则后自动执行，不是 Agent 自主决策的工具库
- **可借鉴：** OAuth 授权托管架构。应用连接的可靠性工程。企业级安全合规标准

**LangChain Tools / CrewAI Tools：**
- 优势：面向开发者的 Agent 工具框架，工具定义清晰（名称、描述、参数 Schema、返回值）。LangChain 社区提供了 100+ 内置 Tool（搜索、数据库、文件、API 调用等）
- 劣势：代码级集成——需要开发者写 Python/TypeScript 代码注册和管理 Tool。没有 UI 层的发现和安装体验。没有运行时隔离——一个 Tool 的 Bug 会影响整个 Agent 进程。没有 OAuth 管理——每个需要授权的 Tool 都需要开发者自行处理
- 核心缺失：开发者友好但用户不友好。非开发者无法自助扩展 Agent 的工具能力
- **可借鉴：** 工具描述的元数据结构。Tool 的输入/输出 Schema 设计。Agent-Tool 交互的调用模式

### 3.3 竞品演进方向判断

| 竞品 | 可能的演进方向 | CODE-YI 的时间窗口 |
|------|--------------|-------------------|
| Claude MCP | Anthropic 可能推出官方 MCP Marketplace（类似 npm registry） | 6-12 个月——Anthropic 的核心精力在模型层，市场层可能慢半拍 |
| GPTs Store | 可能开放 MCP 兼容或提供更好的 Actions 市场体验 | 12-18 个月——OpenAI 的封闭策略短期内不会改变 |
| VS Code | 可能推出"AI Tools"分类或 Copilot Extensions Marketplace | 6-12 个月——GitHub/Microsoft 已在 Copilot Extensions 上探索 |
| Zapier | 可能推出"AI Agent Connector"产品 | 12-18 个月——Zapier 的商业模式依赖 Zap 计费，Agent 调用模式冲击其定价体系 |
| LangChain | 可能推出 LangChain Hub 的 Tool Marketplace | 6-12 个月——LangChain 社区活跃但商业化节奏慢 |

**结论：** CODE-YI 有 6-12 个月的窗口期。关键优势是**同时做好协议层（MCP 原生）和市场层（发现+安装+OAuth+安全）**。纯协议方案（MCP）缺市场体验，纯市场方案（GPTs Store）缺协议标准——CODE-YI 两者兼备。

---

## 4. 技术突破点分析

### 4.1 MCP 协议集成引擎 (MCP Integration Engine)

**传统工具集成模型：**
```
每个工具各自定义接口 → 每次集成都是定制开发 → 维护成本线性增长
工具 A: REST API
工具 B: GraphQL
工具 C: WebSocket
工具 D: 命令行
→ 开发者需要为每个工具写适配代码
```

**CODE-YI MCP 引擎模型：**
```
所有工具统一为 MCP Server → Agent 通过 MCP Client 统一调用 → 新工具即插即用
                  ┌── GitHub MCP Server
                  ├── 飞书 MCP Server
MCP Client ───────├── 数据库 MCP Server
                  ├── 邮件 MCP Server
                  └── 自定义 MCP Server
→ 一个 MCP Client 适配所有工具
```

**核心突破：** CODE-YI 不需要为每个第三方服务写集成代码，而是实现一个通用的 MCP Client Runtime。任何符合 MCP 协议的 Server 都可以被 Agent 直接调用。

**技术关键点：**
- MCP Client 实现符合 MCP 规范的完整协议栈（Initialize → Tool Discovery → Tool Call → Notification）
- 支持 MCP 的三种传输方式：stdio、HTTP+SSE、Streamable HTTP
- 工具描述自动提取：连接 MCP Server 后自动获取其提供的所有 Tool 列表和 JSON Schema
- 工具描述自动注入 Agent 的 System Prompt，让 Agent 了解可用工具

### 4.2 一键安装与热加载 (One-Click Install & Hot-Loading)

**传统 MCP Server 安装：**
```
1. git clone https://github.com/xxx/mcp-server-github
2. cd mcp-server-github && npm install
3. 配置 environment variables（GITHUB_TOKEN=xxx）
4. 编辑 claude_desktop_config.json，添加 server 配置
5. 重启 Claude Desktop
6. 验证连接是否成功
→ 6 个步骤，平均耗时 10-30 分钟，非开发者几乎无法完成
```

**CODE-YI 一键安装：**
```
1. 用户在工具箱中点击"安装"
→ 后台自动：拉取镜像/包 → 配置环境 → 启动 MCP Server → 注册工具 → 通知 Agent
→ 1 个步骤，耗时 < 30 秒，零代码
```

**核心突破：** 将 MCP Server 封装为标准化的"技能包"（Skill Package），包含运行时镜像、配置模板、OAuth 描述、权限声明。安装过程全自动化，安装后无需重启 Agent，工具立即可用（热加载）。

**技术关键点：**
- 技能包格式：Docker 镜像（容器化运行）或 Node.js 包（轻量级运行）
- 安装编排器（Install Orchestrator）：接收安装请求 → 拉取包 → 启动进程 → 健康检查 → 注册工具 → 通知 Agent
- 热加载：Agent 运行时维护一个"可用工具注册表"，安装新技能后动态更新注册表，无需重启 Agent 进程
- 回滚机制：安装失败自动回滚，不影响已有技能

### 4.3 OAuth 授权自动化 (OAuth Flow Automation)

**传统 OAuth 集成：**
```
开发者需要：
1. 在 GitHub/飞书/Jira 开发者平台注册应用，获取 Client ID/Secret
2. 实现 OAuth 回调端点
3. 处理 Token 交换流程
4. 存储和刷新 Access Token
5. 在 MCP Server 配置中注入 Token
→ 每个服务都要重复这套流程
```

**CODE-YI OAuth 自动化：**
```
用户点击"连接 GitHub" → 弹出 OAuth 授权页面 → 用户授权 → Token 自动存储并注入 MCP Server
→ 1 个步骤，耗时 < 10 秒
```

**核心突破：** CODE-YI 维护一个 OAuth Provider Registry（预配置的 OAuth 应用信息），以及一个 Token Vault（加密存储用户的 Access Token）。当用户安装需要 OAuth 的技能时，系统自动触发 OAuth 流程，授权完成后自动将 Token 注入 MCP Server 的运行环境。

**技术关键点：**
- OAuth Provider Registry：预配置 GitHub、飞书、Jira、Gmail、Outlook 等常见服务的 OAuth 应用信息（Client ID、Scopes、Authorize URL、Token URL）
- Token Vault：使用 AES-256-GCM 加密存储 Access Token 和 Refresh Token，支持自动刷新
- OAuth Callback Handler：统一的 OAuth 回调端点，根据 state 参数路由到正确的技能安装流程
- Token 注入：安装完成后，Token 通过环境变量注入 MCP Server 进程，MCP Server 无需知道 OAuth 细节

### 4.4 技能沙箱 (Skill Sandboxing)

**传统工具运行方式：**
```
Tool 代码直接在 Agent 进程中运行
→ 一个恶意/有 Bug 的 Tool 可能：
  - 读取 Agent 的 API Key 和其他敏感信息
  - 消耗过多内存/CPU 导致 Agent 崩溃
  - 发起恶意网络请求
  - 修改文件系统
```

**CODE-YI 沙箱模型：**
```
每个技能运行在独立的沙箱中
→ 隔离级别：
  - 进程隔离：每个 MCP Server 是独立进程
  - 网络隔离：只允许访问声明的域名
  - 文件系统隔离：只能访问指定的挂载目录
  - 资源限制：CPU/内存/磁盘配额
  - API 调用频率限制
```

**核心突破：** 通过容器化或进程级沙箱，确保每个技能运行在受控环境中。即使社区技能包含恶意代码，也无法突破沙箱边界影响 Agent 或其他技能。

**技术关键点：**
- 轻量级容器：使用 Docker 容器（官方技能）或 Node.js VM 隔离（轻量技能）
- 权限声明：技能包的 manifest 中声明所需权限（网络访问域名、文件访问路径、API 调用频率）
- 资源限额：CPU 限制（0.5 核）、内存限制（256MB）、磁盘限制（100MB）
- 超时控制：单次工具调用超时 30 秒，防止挂起

---

## 5. 用户故事

### 5.1 技能浏览与发现

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-TB-01 | 团队成员 | 作为团队成员，我想浏览工具箱中所有可用技能，以便了解 Agent 可以获得哪些能力 | 打开工具箱页面，显示技能卡片网格，每张卡片包含名称、来源标签、评分、安装数、一句话描述 | P1 |
| US-TB-02 | 团队成员 | 作为团队成员，我想通过分类 Tab 筛选技能类型（内置/MCP/社区/我的），以便快速找到目标类型 | 点击分类 Tab，技能列表实时过滤，显示对应分类的技能 | P1 |
| US-TB-03 | 团队成员 | 作为团队成员，我想搜索特定技能（如"GitHub"），以便快速定位 | 搜索框输入关键词，实时过滤技能列表，支持名称/描述/标签的模糊搜索 | P1 |
| US-TB-04 | 团队成员 | 作为团队成员，我想查看技能详情（能力描述、使用方法、评分详情、版本历史），以便决定是否安装 | 点击技能卡片 → 展开详情页/面板，显示完整信息 | P1 |
| US-TB-05 | 团队成员 | 作为团队成员，我想查看技能提供的工具列表和参数说明，以便了解 Agent 安装后能做什么 | 技能详情中显示工具列表，每个工具包含名称、描述、参数 Schema | P1 |

### 5.2 技能安装与管理

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-TB-06 | Workspace 管理员 | 作为管理员，我想一键安装技能到 Agent 运行时，以便扩展 Agent 能力 | 点击"安装"按钮 → 显示安装进度 → 安装完成 → 技能状态变为"已安装"，Agent 可立即使用 | P1 |
| US-TB-07 | Workspace 管理员 | 作为管理员，我想卸载不再需要的技能，以便释放资源并简化 Agent 工具列表 | 点击"卸载" → 确认提示 → 卸载完成 → 技能从 Agent 可用工具列表中移除 | P1 |
| US-TB-08 | Workspace 管理员 | 作为管理员，我想更新已安装技能到最新版本，以便获得 Bug 修复和新功能 | 技能卡片显示"有更新"标记 → 点击"更新" → 自动更新 → 版本号变化 | P1 |
| US-TB-09 | Workspace 管理员 | 作为管理员，我想在安装前查看技能所需的权限声明，以便评估安全风险 | 安装确认弹窗中显示权限列表（如"需要访问 github.com"、"需要读取文件系统"） | P1 |
| US-TB-10 | Workspace 管理员 | 作为管理员，我想禁用（而非卸载）某个技能，以便暂时停止 Agent 使用该技能但保留配置 | 禁用后技能状态变为"已禁用"，Agent 不可调用但配置和数据保留 | P1 |

### 5.3 OAuth 授权

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-TB-11 | Workspace 管理员 | 作为管理员，我想通过一键 OAuth 连接 GitHub，以便 Agent 能操作我的 GitHub 仓库 | 点击"连接 GitHub" → 弹出 GitHub 授权页 → 授权后自动连接成功，状态显示"已连接" | P1 |
| US-TB-12 | Workspace 管理员 | 作为管理员，我想通过 OAuth 连接飞书，以便 Agent 能收发飞书消息和管理日历 | 点击"连接飞书" → 弹出飞书授权页 → 授权后连接成功 | P1 |
| US-TB-13 | Workspace 管理员 | 作为管理员，我想查看已授权的 OAuth 连接列表和状态，以便管理已连接的服务 | 技能详情中显示 OAuth 连接状态（已连接/未连接/Token 过期），支持重新授权和断开连接 | P1 |
| US-TB-14 | Workspace 管理员 | 作为管理员，我想断开已连接的 OAuth 服务，以便撤销 Agent 对外部服务的访问权限 | 点击"断开连接" → 确认 → Token 删除 → 技能功能受限（显示"需要重新连接"） | P1 |
| US-TB-15 | 团队成员 | 作为团队成员，我想在 Agent 提示"需要 GitHub 授权"时直接完成授权流程，不需要手动操作 | Agent 对话中提示"需要连接 GitHub" → 用户点击提示中的按钮 → 完成 OAuth → Agent 自动重试操作 | P2 |

### 5.4 技能评分与反馈

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-TB-16 | 团队成员 | 作为使用者，我想为已安装的技能评分（1-5 星），以便帮助其他用户做决策 | 技能详情页显示评分入口 → 选择星级 → 可选填写评论 → 提交成功 → 评分实时更新 | P2 |
| US-TB-17 | 团队成员 | 作为使用者，我想查看其他用户的评分和评论，以便判断技能质量 | 技能详情页显示评分分布和用户评论列表，按时间/有用度排序 | P2 |
| US-TB-18 | 团队成员 | 作为使用者，我想举报有问题的技能（恶意行为/质量差），以便维护市场质量 | 技能详情页有"举报"按钮 → 选择举报类型 → 填写描述 → 提交 | P2 |

### 5.5 技能上传与发布

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-TB-19 | 开发者 | 作为开发者，我想上传自定义 MCP Server 到社区市场，以便分享给其他用户 | 点击"上传技能" → 填写信息（名称/描述/分类/Git 仓库 URL） → 提交审核 | P2 |
| US-TB-20 | 开发者 | 作为开发者，我想查看我上传的技能的安装数和评分，以便了解使用情况 | "我的技能"Tab 显示我上传的所有技能，包含安装数、评分、版本列表 | P2 |
| US-TB-21 | 开发者 | 作为开发者，我想发布新版本的技能，以便推送 Bug 修复和新功能 | 在"我的技能"中选择目标技能 → 提交新版本 → 审核通过后自动推送给已安装用户 | P2 |

### 5.6 技能治理

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-TB-22 | Workspace 管理员 | 作为管理员，我想控制哪些 Agent 可以使用哪些技能，以便实现最小权限原则 | 技能设置中可配置"允许使用的 Agent 角色"或"允许使用的 Agent 列表" | P2 |
| US-TB-23 | Workspace 管理员 | 作为管理员，我想查看技能的调用日志，以便审计 Agent 对外部服务的操作 | 技能详情中有"调用日志"Tab，显示调用时间、Agent、工具名、参数摘要、结果状态 | P2 |
| US-TB-24 | Workspace 管理员 | 作为管理员，我想设置技能的调用频率限制，以便防止 Agent 过度调用外部 API | 技能设置中可配置每分钟/每小时/每天的调用次数上限 | P2 |

---

## 6. 功能拆分

### 6.1 P0 功能（预装核心集成，MVP 策略）

根据 Stephanie 的 MVP 策略，P0 阶段不做市场 UI，而是预装 3-5 个核心集成作为 Agent 内置能力。

#### 6.1.1 预装核心技能

**GitHub 集成（官方 MCP）：**
- 连接 GitHub 仓库（OAuth 授权）
- 支持 PR 管理：创建/查看/合并 PR、添加 Review 评论
- 支持 Issue 追踪：创建/查看/更新 Issue、添加标签和里程碑
- 支持代码搜索：按关键词/文件名/语言搜索代码
- 支持 Actions 监控：查看 Workflow 运行状态、触发 Workflow

**数据库查询（官方内置）：**
- 支持 PostgreSQL、MySQL、MongoDB 连接
- 自然语言 → SQL 转换：Agent 理解用户意图后自动生成 SQL
- 只读查询模式（安全默认）+ 可配置的写入权限
- 查询结果结构化返回（表格/JSON/图表建议）
- 连接字符串加密存储

**文件操作（官方内置）：**
- 文件读取/写入/列表/搜索
- 工作目录沙箱（只允许操作指定目录）
- 支持常见格式：文本、JSON、CSV、Markdown
- 文件内容摘要生成

#### 6.1.2 P0 技术要求

- MCP Client Runtime 核心实现
- MCP Server 进程管理（启动/停止/健康检查）
- 基础 OAuth 流程（GitHub）
- 配置存储（加密的连接信息和 Token）
- Agent System Prompt 动态注入可用工具列表

### 6.2 P1 功能（完整市场 UI + 安装流程，~4 周）

#### 6.2.1 技能浏览市场

**页面布局（参考 Screen 6 设计稿）：**
```
┌─────────────────────────────────────────────────────────────────┐
│  工具箱                                           [上传技能]    │
├─────────────────────────────────────────────────────────────────┤
│  [全部] [内置技能] [MCP集成] [社区技能] [我的技能]  🔍搜索...  │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ GitHub集成    │  │ 飞书集成     │  │ 数据库查询   │          │
│  │ 官方MCP       │  │ 官方MCP      │  │ 官方内置     │          │
│  │ ★4.5  12.3k  │  │ ★4.8  8.7k  │  │ ★4.6  8.2k  │          │
│  │ 已安装 ✓      │  │ 已安装 ✓     │  │ [安装]       │          │
│  │              │  │              │  │              │          │
│  │ 连接GitHub   │  │ 连接飞书     │  │ 支持PG/MySQL │          │
│  │ 仓库...      │  │ 工作台...    │  │ MongoDB...   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ 图像生成      │  │ 网页抓取     │  │ 邮件管理     │          │
│  │              │  │ 社区         │  │ MCP          │          │
│  │ ★4.7  9.1k  │  │ ★4.3  3.4k  │  │ ★4.4  5.1k  │          │
│  │ 已安装 ✓      │  │ [安装]       │  │ [安装]       │          │
│  │              │  │              │  │              │          │
│  │ AI图像生成   │  │ 自动化网页   │  │ 邮件收发,    │          │
│  │ 多模型...    │  │ 数据采集...  │  │ 自动分类...  │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│  ┌──────────────┐  ┌──────────────┐                            │
│  │ Jira集成      │  │ 安全扫描     │                            │
│  │ 社区         │  │ 官方内置     │                            │
│  │ ★4.2  4.5k  │  │     7.8k    │                            │
│  │ [安装]       │  │ 已安装 ✓     │                            │
│  │              │  │              │                            │
│  │ 连接Jira项目 │  │ 代码安全     │                            │
│  │ 管理...      │  │ 扫描...      │                            │
│  └──────────────┘  └──────────────┘                            │
└─────────────────────────────────────────────────────────────────┘
```

**分类 Tab：**
- 全部：显示所有技能（默认视图）
- 内置技能：CODE-YI 官方提供的内置能力（数据库查询、文件操作、安全扫描等）
- MCP 集成：基于 MCP 协议的外部服务集成（GitHub、飞书、邮件等）
- 社区技能：社区用户上传的第三方技能
- 我的技能：当前 Workspace 已安装的技能 + 用户上传的技能

**技能卡片：**
- 技能名称
- 来源标签：官方（绿色 Badge）/ 社区（蓝色 Badge）/ MCP（紫色 Badge）/ 内置（灰色 Badge）
- 评分：★ 1-5 星，保留一位小数
- 安装数：格式化显示（如 12.3k、1.2M）
- 安装状态：已安装 ✓ / 安装按钮 / 需要更新
- 一句话描述：限制 50 字以内
- 操作按钮：安装 / 已安装 / 更新 / 连接（OAuth 类）

#### 6.2.2 一键安装流程

**安装流程（无 OAuth 的技能）：**
```
用户点击"安装"
  │
  ├── 1. 显示安装确认弹窗
  │     ├── 技能名称和版本
  │     ├── 权限声明（需要访问的资源）
  │     └── "确认安装"按钮
  │
  ├── 2. 安装进度
  │     ├── 拉取技能包 ████████░░ 80%
  │     ├── 配置环境 ██████████ 100%
  │     ├── 启动服务
  │     └── 验证连接
  │
  ├── 3. 安装完成
  │     ├── 状态变为"已安装 ✓"
  │     ├── Agent 可用工具列表更新
  │     └── Toast 通知"GitHub 集成安装成功"
  │
  └── 异常处理
        ├── 安装失败 → 显示错误原因 + "重试"按钮
        └── 超时 → 自动回滚 + 提示"安装超时，请稍后重试"
```

**安装流程（需要 OAuth 的技能）：**
```
用户点击"安装"
  │
  ├── 1. 显示安装确认弹窗
  │     ├── 技能信息 + 权限声明
  │     └── 提示"此技能需要连接 GitHub 账户"
  │
  ├── 2. OAuth 授权
  │     ├── 弹出 OAuth 窗口（GitHub 授权页）
  │     ├── 用户在 GitHub 页面点击"Authorize"
  │     ├── 回调处理 → Token 自动存储
  │     └── OAuth 窗口自动关闭
  │
  ├── 3. 安装进度（同上）
  │
  └── 4. 安装完成
        ├── 状态显示"已安装 ✓ · 已连接 GitHub"
        └── Agent 可以开始操作 GitHub
```

#### 6.2.3 OAuth 连接管理

**支持的 OAuth Provider（P1 阶段）：**
- GitHub：仓库读写、Issue 管理、PR 管理、Actions
- 飞书/Lark：消息收发、日历管理、文档协作、审批流程
- Jira：Issue 管理、Sprint 管理、看板数据
- Gmail：邮件收发、标签管理、搜索
- Outlook：邮件收发、日历管理

**OAuth 连接状态：**
```
已连接（绿色） → Token 有效，正常使用
未连接（灰色） → 尚未授权，功能不可用
已过期（橙色） → Token 过期，需要重新授权
    ↳ 系统自动尝试 Refresh Token
    ↳ 如 Refresh 失败，提示用户重新授权
```

#### 6.2.4 技能详情页

**详情页布局：**
```
┌─────────────────────────────────────────────────────────────────┐
│  ← 返回工具箱                                                   │
│                                                                 │
│  [图标]  GitHub 集成                                            │
│  官方 MCP · v2.1.0 · 更新于 2026-04-15                         │
│  ★ 4.5 (328 评价) · 12.3k 安装                                 │
│                                                                 │
│  连接GitHub仓库，支持PR管理、Issue追踪、代码搜索和Actions监控     │
│                                                                 │
│  [已安装 ✓]  [连接状态: 已连接 GitHub @user]  [卸载]            │
├─────────────────────────────────────────────────────────────────┤
│  [工具列表] [版本历史] [评价] [权限说明]                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  提供的工具 (12):                                               │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ create_pull_request                                      │    │
│  │ 创建 Pull Request                                        │    │
│  │ 参数: owner(string), repo(string), title(string),        │    │
│  │       body(string), head(string), base(string)           │    │
│  └─────────────────────────────────────────────────────────┘    │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ search_code                                              │    │
│  │ 搜索代码                                                 │    │
│  │ 参数: query(string), language?(string), repo?(string)    │    │
│  └─────────────────────────────────────────────────────────┘    │
│  ...                                                            │
└─────────────────────────────────────────────────────────────────┘
```

#### 6.2.5 技能评分系统

**评分规则：**
- 1-5 星评分，可半星（实际存储为 0.5 精度）
- 需要安装且使用过才能评分（安装后至少调用 1 次）
- 一个 Workspace 对一个技能只能评分一次（可修改）
- 评分附带可选文本评论（限制 500 字）
- 综合评分 = 加权平均（近 30 天评分权重更高）

### 6.3 P2 功能

#### 6.3.1 社区技能上传

- 上传表单：技能名称、描述、分类、Git 仓库 URL、README
- 自动检测：从 Git 仓库自动提取 MCP Server 的 manifest 信息
- 安全扫描：自动扫描代码是否包含恶意行为（网络请求审计、文件系统访问审计、依赖漏洞扫描）
- 人工审核：安全扫描通过后进入人工审核队列，审核员确认后发布
- 版本管理：每次提交新版本需要重新审核

#### 6.3.2 技能权限治理

- 按 Agent 角色控制技能可用性（如：观察者角色的 Agent 不能使用"代码提交"工具）
- 按 Workspace 控制技能安装白名单/黑名单
- 技能调用频率限制（每分钟/每小时/每天）
- 调用审计日志（谁在什么时间用什么 Agent 调用了什么工具）

#### 6.3.3 技能自动更新

- 已安装技能有新版本时显示更新提示
- 支持自动更新策略：自动更新 / 仅通知 / 忽略
- 更新前自动备份当前版本（支持回滚）
- 更新日志（Changelog）展示

---

## 7. MCP 协议集成引擎

### 7.1 MCP 协议概述

MCP（Model Context Protocol）是 Anthropic 于 2024 年底推出的开放标准协议，定义了 AI 模型（Client）与外部工具（Server）之间的通信规范。

```
┌──────────────────────┐          MCP Protocol          ┌──────────────────────┐
│                      │                                │                      │
│   MCP Client         │  ←── Initialize ──→            │   MCP Server         │
│   (CODE-YI Agent)    │  ←── List Tools ──→            │   (GitHub/飞书/DB)   │
│                      │  ←── Call Tool  ──→            │                      │
│                      │  ←── Notification ──→          │                      │
│                      │                                │                      │
└──────────────────────┘                                └──────────────────────┘
```

**MCP 核心概念：**
- **Tools**：Server 暴露的可调用工具，每个 Tool 有名称、描述和 JSON Schema 参数定义
- **Resources**：Server 暴露的数据资源（如文件列表、数据库表列表）
- **Prompts**：Server 提供的预定义 Prompt 模板
- **Notifications**：Server 向 Client 推送的通知（如资源变更）

### 7.2 MCP Client Runtime 架构

```
┌──────────────────────────────────────────────────────────────────────────┐
│                        MCP Client Runtime                                │
│                                                                          │
│  ┌───────────────────┐    ┌───────────────────┐    ┌──────────────────┐  │
│  │ Server Manager    │    │ Tool Registry     │    │ Call Dispatcher  │  │
│  │                   │    │                   │    │                  │  │
│  │ - 启动/停止 Server│    │ - 注册工具描述    │    │ - 路由 Agent 的  │  │
│  │ - 健康检查       │    │ - 生成工具清单    │    │   Tool Call 到   │  │
│  │ - 进程管理       │    │ - 冲突检测       │    │   正确的 Server  │  │
│  │ - 自动重启       │    │ - 版本管理       │    │ - 超时控制       │  │
│  └───────┬───────────┘    └───────┬───────────┘    └───────┬──────────┘  │
│          │                        │                        │              │
│  ┌───────┴────────────────────────┴────────────────────────┴──────────┐  │
│  │                     Transport Layer                                  │  │
│  │                                                                      │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────────────────┐     │  │
│  │  │ stdio        │  │ HTTP+SSE     │  │ Streamable HTTP        │     │  │
│  │  │ Transport    │  │ Transport    │  │ Transport              │     │  │
│  │  │              │  │              │  │                        │     │  │
│  │  │ 本地进程     │  │ 远程服务     │  │ 远程服务(流式)         │     │  │
│  │  │ (内置技能)   │  │ (MCP集成)    │  │ (高级集成)             │     │  │
│  │  └──────────────┘  └──────────────┘  └────────────────────────┘     │  │
│  └────────────────────────────────────────────────────────────────────┘  │
│                                                                          │
│  ┌───────────────────┐    ┌───────────────────┐                         │
│  │ OAuth Manager     │    │ Config Store      │                         │
│  │                   │    │                   │                         │
│  │ - Token 管理      │    │ - Server 配置     │                         │
│  │ - 自动刷新       │    │ - 环境变量        │                         │
│  │ - 注入环境变量   │    │ - 加密存储        │                         │
│  └───────────────────┘    └───────────────────┘                         │
└──────────────────────────────────────────────────────────────────────────┘
```

### 7.3 Server Discovery（MCP Server 发现）

```
MCP Server 发现流程：

1. 技能安装时：
   安装编排器 → 读取技能 manifest → 提取 MCP Server 配置
   ├── transport: "stdio"
   │   └── 启动本地进程，通过 stdin/stdout 通信
   ├── transport: "sse"
   │   └── 连接远程 SSE 端点
   └── transport: "streamable-http"
       └── 连接远程 HTTP 端点

2. Server 启动后：
   MCP Client → Initialize 请求 → Server 返回能力列表
   ├── serverInfo: { name, version }
   ├── capabilities: { tools, resources, prompts }
   └── protocolVersion: "2025-03-26"

3. 工具发现：
   MCP Client → tools/list 请求 → Server 返回工具清单
   [
     {
       name: "create_pull_request",
       description: "创建 GitHub Pull Request",
       inputSchema: {
         type: "object",
         properties: {
           owner: { type: "string", description: "仓库所有者" },
           repo: { type: "string", description: "仓库名" },
           title: { type: "string", description: "PR 标题" },
           ...
         },
         required: ["owner", "repo", "title", "head", "base"]
       }
     },
     ...
   ]

4. 工具注册：
   工具清单 → Tool Registry → 更新 Agent System Prompt
   → Agent 在下一次对话中可以使用新工具
```

### 7.4 Tool Call Flow（工具调用流程）

```
用户: "帮我在 code-yi/frontend 仓库创建一个 PR，把 feature/auth 合到 main"

Agent（LLM）:
  ├── 理解用户意图
  ├── 检查 Tool Registry → 发现 create_pull_request 工具可用
  ├── 构造 Tool Call:
  │   {
  │     "name": "create_pull_request",
  │     "arguments": {
  │       "owner": "code-yi",
  │       "repo": "frontend",
  │       "title": "Merge feature/auth to main",
  │       "head": "feature/auth",
  │       "base": "main"
  │     }
  │   }
  └── 发送 Tool Call 到 MCP Client Runtime

MCP Client Runtime:
  ├── 1. 权限检查
  │     ├── Agent 角色是否允许使用此工具？
  │     ├── 调用频率是否超限？
  │     └── 检查通过 → 继续
  │
  ├── 2. 路由到正确的 MCP Server
  │     ├── 查询 Tool Registry → create_pull_request 属于 GitHub MCP Server
  │     └── 获取 Server 的 Transport 连接
  │
  ├── 3. 发送 tools/call 请求到 MCP Server
  │     ├── 请求:
  │     │   {
  │     │     "method": "tools/call",
  │     │     "params": {
  │     │       "name": "create_pull_request",
  │     │       "arguments": { ... }
  │     │     }
  │     │   }
  │     │
  │     ├── MCP Server 执行：
  │     │   ├── 使用 OAuth Token 调用 GitHub API
  │     │   ├── POST /repos/code-yi/frontend/pulls
  │     │   └── 返回 PR 创建结果
  │     │
  │     └── 响应:
  │         {
  │           "content": [
  │             {
  │               "type": "text",
  │               "text": "PR #42 created: https://github.com/code-yi/frontend/pull/42"
  │             }
  │           ]
  │         }
  │
  ├── 4. 记录调用日志
  │     └── 写入 skill_call_logs 表
  │
  └── 5. 返回结果给 Agent

Agent:
  └── "已成功创建 PR #42，链接：https://github.com/code-yi/frontend/pull/42"
```

### 7.5 错误处理

```typescript
// MCP 工具调用错误分类
enum McpErrorType {
  // 连接级错误
  SERVER_UNAVAILABLE = 'server_unavailable',      // MCP Server 未运行
  CONNECTION_TIMEOUT = 'connection_timeout',       // 连接超时
  PROTOCOL_ERROR = 'protocol_error',              // 协议版本不匹配
  
  // 授权级错误
  OAUTH_TOKEN_EXPIRED = 'oauth_token_expired',    // Token 过期
  OAUTH_TOKEN_REVOKED = 'oauth_token_revoked',    // Token 被撤销
  INSUFFICIENT_SCOPE = 'insufficient_scope',      // 权限范围不足
  
  // 调用级错误
  TOOL_NOT_FOUND = 'tool_not_found',              // 工具不存在
  INVALID_PARAMS = 'invalid_params',              // 参数校验失败
  EXECUTION_ERROR = 'execution_error',            // 执行过程中出错
  RATE_LIMITED = 'rate_limited',                  // 调用频率超限
  CALL_TIMEOUT = 'call_timeout',                  // 单次调用超时
  
  // 沙箱级错误
  RESOURCE_EXCEEDED = 'resource_exceeded',        // 资源配额超限
  SANDBOX_VIOLATION = 'sandbox_violation',        // 沙箱规则违规
}

// 错误处理策略
interface ErrorStrategy {
  type: McpErrorType;
  action: 'retry' | 'refresh_token' | 'restart_server' | 'notify_user' | 'fallback';
  max_retries?: number;
  backoff_ms?: number;
  user_message?: string;  // 显示给用户的友好消息
}

const ERROR_STRATEGIES: ErrorStrategy[] = [
  {
    type: McpErrorType.SERVER_UNAVAILABLE,
    action: 'restart_server',
    max_retries: 3,
    backoff_ms: 2000,
    user_message: '工具服务暂时不可用，正在重启...'
  },
  {
    type: McpErrorType.OAUTH_TOKEN_EXPIRED,
    action: 'refresh_token',
    max_retries: 1,
    user_message: '正在刷新授权...'
  },
  {
    type: McpErrorType.OAUTH_TOKEN_REVOKED,
    action: 'notify_user',
    user_message: 'GitHub 授权已失效，需要重新连接。点击此处重新授权。'
  },
  {
    type: McpErrorType.RATE_LIMITED,
    action: 'retry',
    max_retries: 3,
    backoff_ms: 5000,
    user_message: '调用频率过高，稍后重试...'
  },
  {
    type: McpErrorType.CALL_TIMEOUT,
    action: 'retry',
    max_retries: 2,
    backoff_ms: 3000,
    user_message: '操作超时，正在重试...'
  },
  {
    type: McpErrorType.EXECUTION_ERROR,
    action: 'notify_user',
    user_message: '工具执行出错，请检查参数或稍后重试。'
  },
];
```

### 7.6 多 Transport 适配

```
┌──────────────────────────────────────────────────────────────────┐
│                    Transport Adapter                              │
│                                                                  │
│  ┌── stdio Transport ──────────────────────────────────────┐     │
│  │                                                          │     │
│  │  适用场景：内置技能、本地 MCP Server                      │     │
│  │  通信方式：子进程 stdin/stdout                            │     │
│  │  优势：低延迟、无网络开销                                 │     │
│  │  启动方式：spawn('node', ['server.js'])                   │     │
│  │                                                          │     │
│  │  消息格式：JSON-RPC 2.0 over stdio                       │     │
│  │  → 每条消息以 \n 分隔                                    │     │
│  └──────────────────────────────────────────────────────────┘     │
│                                                                  │
│  ┌── HTTP+SSE Transport ───────────────────────────────────┐     │
│  │                                                          │     │
│  │  适用场景：远程 MCP Server、第三方托管的 MCP 服务         │     │
│  │  通信方式：Client→Server: HTTP POST / Server→Client: SSE │     │
│  │  优势：兼容现有 HTTP 基础设施                             │     │
│  │  连接方式：                                              │     │
│  │    GET /sse → 建立 SSE 连接，接收 Server 消息             │     │
│  │    POST /message → 发送 Client 消息到 Server              │     │
│  └──────────────────────────────────────────────────────────┘     │
│                                                                  │
│  ┌── Streamable HTTP Transport ────────────────────────────┐     │
│  │                                                          │     │
│  │  适用场景：高级远程 MCP Server（2025+ 版本）              │     │
│  │  通信方式：双向 HTTP 流                                   │     │
│  │  优势：支持 Server-Initiated 消息、更高效的流式传输       │     │
│  │  连接方式：                                              │     │
│  │    POST /mcp → JSON-RPC over HTTP（支持 SSE 流式响应）    │     │
│  └──────────────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────────────┘
```

### 7.7 工具注册表 (Tool Registry)

```typescript
// Tool Registry 数据结构
interface RegisteredTool {
  // 唯一标识
  tool_id: string;              // 全局唯一：{skill_id}:{tool_name}
  skill_id: string;             // 所属技能
  
  // MCP 工具描述（直接从 MCP Server 获取）
  name: string;                 // 工具名称
  description: string;          // 工具描述（Agent 用此理解工具用途）
  input_schema: JSONSchema;     // 输入参数 JSON Schema
  
  // 路由信息
  server_id: string;            // 对应的 MCP Server 实例 ID
  transport_type: 'stdio' | 'sse' | 'streamable-http';
  
  // 状态
  is_available: boolean;        // 当前是否可用（Server 在线且授权有效）
  unavailable_reason?: string;  // 不可用原因
  
  // 统计
  call_count_total: number;
  call_count_24h: number;
  avg_latency_ms: number;
  success_rate: number;
  
  // 治理
  allowed_agent_roles?: string[];  // 允许使用此工具的 Agent 角色
  rate_limit?: {
    max_calls_per_minute: number;
    max_calls_per_hour: number;
  };
}

// Tool Registry 管理
interface ToolRegistry {
  // 注册工具（技能安装后调用）
  register(tools: RegisteredTool[]): void;
  
  // 注销工具（技能卸载后调用）
  unregister(skill_id: string): void;
  
  // 查询可用工具列表（注入 Agent System Prompt）
  listAvailable(agent_role?: string): RegisteredTool[];
  
  // 查找工具（Agent Tool Call 路由）
  findTool(tool_name: string): RegisteredTool | null;
  
  // 冲突检测（多个技能提供同名工具）
  detectConflicts(): ToolConflict[];
  
  // 生成工具描述文本（注入 Agent System Prompt）
  generateToolsPrompt(agent_role?: string): string;
}
```

---

## 8. 技能市场架构

### 8.1 技能包规范 (Skill Package Specification)

```yaml
# skill-manifest.yaml — 技能包的元数据描述文件
# 每个技能必须包含此文件

# 基本信息
name: "github-integration"           # 技能唯一标识（npm 包名风格）
display_name: "GitHub 集成"           # 显示名称
version: "2.1.0"                     # 语义化版本
description: "连接GitHub仓库，支持PR管理、Issue追踪、代码搜索和Actions监控"
author: "CODE-YI Official"
category: "mcp"                      # 分类：builtin | mcp | community
icon: "./assets/github-icon.svg"     # 图标文件

# MCP Server 配置
mcp:
  transport: "stdio"                 # stdio | sse | streamable-http
  command: "node"                    # 启动命令
  args: ["dist/server.js"]           # 命令参数
  env:                               # 环境变量模板
    GITHUB_TOKEN: "${oauth.github.access_token}"

# OAuth 配置（如需要）
oauth:
  - provider: "github"
    scopes: ["repo", "read:org", "workflow"]
    description: "需要访问您的 GitHub 仓库"

# 权限声明
permissions:
  network:
    - "api.github.com"
    - "github.com"
  filesystem: "none"                 # none | readonly | readwrite
  max_memory_mb: 256
  max_cpu_cores: 0.5

# 运行时要求
runtime:
  engine: "node"                     # node | python | docker
  engine_version: ">=18.0.0"
  
# 依赖（其他技能）
dependencies: []

# 标签（用于搜索和筛选）
tags: ["github", "git", "pr", "issue", "code-review", "ci-cd"]
```

### 8.2 技能生命周期

```
技能生命周期状态机：

  ┌─────────────────────────────────────────────────────────┐
  │                                                         │
  │  [发现]                                                 │
  │  用户在市场中浏览/搜索到技能                              │
  │       │                                                 │
  │       ▼                                                 │
  │  [安装中] ──── 失败 ──→ [安装失败] ──→ [重试/放弃]       │
  │       │                                                 │
  │       ▼                                                 │
  │  [OAuth 授权] ──── 拒绝 ──→ [安装取消]                   │
  │       │                （用户拒绝授权）                   │
  │       ▼                                                 │
  │  [已安装/活跃]                                           │
  │       │       │       │                                 │
  │       │       │       ├── 禁用 ──→ [已禁用]              │
  │       │       │       │              │                   │
  │       │       │       │              └── 启用 ──→ [活跃] │
  │       │       │       │                                 │
  │       │       │       ├── Token过期 ──→ [需要重连]       │
  │       │       │       │                  │               │
  │       │       │       │                  └── 重连 ──→ 活跃│
  │       │       │       │                                 │
  │       │       │       └── 更新 ──→ [更新中] ──→ [活跃]   │
  │       │       │                                         │
  │       │       └── 卸载 ──→ [已卸载]                      │
  │       │                                                 │
  │       └── Server崩溃 ──→ [异常] ──→ 自动重启 ──→ [活跃]  │
  │                            │                             │
  │                            └── 重启失败 ──→ [需要人工干预]│
  └─────────────────────────────────────────────────────────┘
```

### 8.3 安装编排器 (Install Orchestrator)

```
安装编排器工作流：

接收安装请求 (skill_id, workspace_id, user_id)
  │
  ├── 1. 验证
  │     ├── 检查用户权限（是否是 Workspace 管理员）
  │     ├── 检查技能是否已安装
  │     ├── 检查依赖是否满足
  │     └── 检查资源配额是否充足
  │
  ├── 2. 拉取技能包
  │     ├── 从 Skill Registry 获取技能包 URL
  │     ├── 下载技能包（Docker 镜像或 npm 包）
  │     ├── 校验完整性（SHA256 Hash）
  │     └── 存储到本地缓存
  │
  ├── 3. OAuth 授权（如需要）
  │     ├── 检查 skill-manifest.yaml 中的 oauth 配置
  │     ├── 触发 OAuth 流程 → 等待用户授权
  │     ├── 接收 OAuth 回调 → 存储 Token 到 Token Vault
  │     └── 将 Token 注入环境变量模板
  │
  ├── 4. 启动 MCP Server
  │     ├── 根据 runtime.engine 选择启动方式：
  │     │   ├── node: 直接 spawn 进程
  │     │   ├── python: spawn python 进程
  │     │   └── docker: docker run 容器
  │     ├── 注入环境变量（含 OAuth Token）
  │     ├── 等待 Server 就绪（健康检查）
  │     └── 超时控制：30 秒内 Server 必须就绪
  │
  ├── 5. 工具注册
  │     ├── 向 MCP Server 发送 Initialize 请求
  │     ├── 发送 tools/list 请求获取工具清单
  │     ├── 注册工具到 Tool Registry
  │     ├── 冲突检测（工具名重复处理）
  │     └── 更新 Agent System Prompt
  │
  ├── 6. 完成
  │     ├── 更新 skill_installations 表状态为 'active'
  │     ├── 更新技能的安装数统计
  │     ├── WebSocket 通知前端安装完成
  │     └── 记录安装日志
  │
  └── 异常回滚
        ├── 任何步骤失败 → 反向执行已完成的步骤
        ├── 停止 MCP Server 进程
        ├── 删除已下载的技能包
        ├── 撤销 OAuth Token
        ├── 更新状态为 'install_failed'
        └── 通知用户安装失败原因
```

### 8.4 审核流水线 (Review Pipeline)

```
社区技能审核流水线：

提交审核请求 (Git 仓库 URL, manifest)
  │
  ├── 阶段 1: 自动化检查 (< 5 分钟)
  │     ├── Manifest 格式校验
  │     │   ├── 必填字段是否完整
  │     │   ├── 版本号是否合规（semver）
  │     │   └── 分类标签是否有效
  │     │
  │     ├── 代码安全扫描
  │     │   ├── 依赖漏洞扫描（npm audit / pip safety）
  │     │   ├── 恶意代码模式检测
  │     │   │   ├── 检查是否读取 ~/.ssh/、~/.aws/ 等敏感路径
  │     │   │   ├── 检查是否发起未声明的网络请求
  │     │   │   └── 检查是否执行系统命令（exec、spawn 非 MCP 用途）
  │     │   └── 许可证兼容性检查
  │     │
  │     ├── 功能测试
  │     │   ├── 在沙箱中启动 MCP Server
  │     │   ├── 验证 Initialize 和 tools/list 是否正常
  │     │   ├── 调用每个 Tool（使用 Mock 数据）
  │     │   └── 检查返回格式是否符合 MCP 规范
  │     │
  │     └── 结果
  │         ├── 全部通过 → 进入阶段 2
  │         └── 任何失败 → 拒绝 + 反馈失败原因
  │
  ├── 阶段 2: 人工审核 (1-3 天)
  │     ├── 审核员 review 代码
  │     ├── 检查功能描述是否与实际一致
  │     ├── 检查是否有隐蔽的数据收集行为
  │     └── 审核结果
  │         ├── 通过 → 发布
  │         ├── 需要修改 → 反馈修改意见
  │         └── 拒绝 → 说明拒绝原因
  │
  └── 阶段 3: 发布
        ├── 构建技能包（打包代码 + 依赖）
        ├── 生成 SHA256 Hash
        ├── 上传到 Skill Registry
        ├── 更新技能市场索引
        └── 通知提交者发布成功
```

### 8.5 版本管理与依赖解析

```typescript
// 技能版本管理
interface SkillVersion {
  version: string;              // semver: "2.1.0"
  release_date: string;
  changelog: string;            // Markdown 格式
  min_platform_version: string; // CODE-YI 最低版本要求
  
  // 包信息
  package_url: string;          // 技能包下载地址
  package_hash: string;         // SHA256
  package_size_bytes: number;
  
  // 兼容性
  breaking_changes: boolean;    // 是否有破坏性变更
  migration_guide?: string;     // 破坏性变更时的迁移指南
  
  // 审核状态
  review_status: 'pending' | 'approved' | 'rejected';
  reviewed_at?: string;
  reviewed_by?: string;
}

// 依赖解析器
interface DependencyResolver {
  // 解析安装请求的依赖树
  resolve(skill_id: string, version: string): DependencyTree;
  
  // 检查依赖冲突
  checkConflicts(tree: DependencyTree): DependencyConflict[];
  
  // 计算安装顺序（拓扑排序）
  installOrder(tree: DependencyTree): string[];
}

// 依赖树节点
interface DependencyNode {
  skill_id: string;
  version: string;
  dependencies: DependencyNode[];
  is_installed: boolean;        // 是否已安装
  needs_upgrade: boolean;       // 是否需要升级
}
```

### 8.6 技能 Hot-Reload 机制

```
技能热加载（Hot-Reload）流程：

安装/卸载/更新技能 → 无需重启 Agent

1. 安装新技能：
   安装编排器完成安装 → MCP Server 启动
     │
     ├── Tool Registry 添加新工具
     ├── 生成新的 Tools Prompt 文本
     ├── Agent 的 System Prompt 动态更新
     │   └── 下一次对话轮次中 Agent 即可使用新工具
     └── WebSocket 通知前端更新技能列表

2. 卸载技能：
   停止 MCP Server 进程
     │
     ├── Tool Registry 移除相关工具
     ├── 重新生成 Tools Prompt 文本
     ├── Agent 的 System Prompt 动态更新
     │   └── Agent 不再看到已移除的工具
     └── 正在进行的 Tool Call 优雅中断
         └── 返回错误：工具已卸载

3. 更新技能：
   停止旧版 MCP Server → 启动新版 MCP Server
     │
     ├── 工具列表可能变化（新增/移除/修改工具）
     ├── Tool Registry 增量更新
     ├── Agent System Prompt 更新
     └── 更新期间的 Tool Call 排队等待
         └── 新版 Server 就绪后处理排队请求

关键技术：
  - Agent System Prompt 支持动态拼接
  - Tool Registry 是内存 + Redis 双层缓存
  - 工具变更通过 Event Bus 广播
  - 前端通过 WebSocket 实时感知变更
```

---

## 9. 数据模型

### 9.1 技能主表

```sql
-- 技能注册表（所有可用技能的元数据）
CREATE TABLE skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- 基本信息
  name VARCHAR(100) NOT NULL UNIQUE,            -- 技能唯一标识（slug 格式：github-integration）
  display_name VARCHAR(200) NOT NULL,           -- 显示名称（GitHub 集成）
  description TEXT NOT NULL,                    -- 一句话描述
  long_description TEXT,                        -- 详细描述（Markdown）
  icon_url VARCHAR(500),                        -- 图标 URL
  
  -- 分类
  category VARCHAR(20) NOT NULL
    CHECK (category IN ('builtin', 'mcp', 'community')),
  tags TEXT[],                                  -- 标签数组（用于搜索）
  
  -- 来源
  source_type VARCHAR(20) NOT NULL
    CHECK (source_type IN ('official', 'community', 'third_party')),
  source_url VARCHAR(500),                      -- 源代码 URL（如 GitHub 仓库）
  author_name VARCHAR(100),                     -- 作者名称
  author_id UUID,                               -- 作者 user_id（社区技能）
  
  -- 最新版本（缓存字段）
  latest_version VARCHAR(30),                   -- 如 "2.1.0"
  latest_version_id UUID,                       -- 关联 skill_versions 表
  
  -- 统计（缓存字段，异步更新）
  install_count INTEGER DEFAULT 0,              -- 总安装数
  avg_rating DECIMAL(2,1) DEFAULT 0.0,          -- 平均评分 (0.0 - 5.0)
  review_count INTEGER DEFAULT 0,               -- 评价数
  
  -- MCP 信息
  mcp_transport VARCHAR(20)                     -- MCP Transport 类型
    CHECK (mcp_transport IN ('stdio', 'sse', 'streamable-http')),
  tool_count INTEGER DEFAULT 0,                 -- 提供的工具数量
  
  -- OAuth 要求
  requires_oauth BOOLEAN DEFAULT FALSE,
  oauth_providers TEXT[],                       -- 需要的 OAuth Provider 列表
  
  -- 审核状态
  review_status VARCHAR(20) NOT NULL DEFAULT 'approved'
    CHECK (review_status IN ('pending', 'in_review', 'approved', 'rejected')),
  reviewed_at TIMESTAMPTZ,
  reviewed_by UUID,
  
  -- 状态
  is_published BOOLEAN DEFAULT TRUE,            -- 是否在市场中可见
  is_deprecated BOOLEAN DEFAULT FALSE,          -- 是否已弃用
  
  -- 时间
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  published_at TIMESTAMPTZ
);

-- 索引
CREATE INDEX idx_skills_category ON skills(category) WHERE is_published = TRUE;
CREATE INDEX idx_skills_source ON skills(source_type);
CREATE INDEX idx_skills_rating ON skills(avg_rating DESC, install_count DESC) 
  WHERE is_published = TRUE;
CREATE INDEX idx_skills_search ON skills USING gin(to_tsvector('simple', 
  display_name || ' ' || description || ' ' || COALESCE(array_to_string(tags, ' '), '')));
CREATE INDEX idx_skills_author ON skills(author_id) WHERE author_id IS NOT NULL;
CREATE INDEX idx_skills_review ON skills(review_status) WHERE review_status = 'pending';
```

### 9.2 技能分类表

```sql
-- 技能分类
CREATE TABLE skill_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  name VARCHAR(50) NOT NULL UNIQUE,             -- 分类标识（builtin, mcp, community）
  display_name VARCHAR(100) NOT NULL,           -- 显示名称（内置技能、MCP 集成、社区技能）
  description TEXT,                             -- 分类描述
  icon VARCHAR(50),                             -- 图标标识
  sort_order INTEGER DEFAULT 0,                 -- 排序权重
  
  -- 统计
  skill_count INTEGER DEFAULT 0,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 初始数据
INSERT INTO skill_categories (name, display_name, sort_order) VALUES
  ('builtin', '内置技能', 1),
  ('mcp', 'MCP 集成', 2),
  ('community', '社区技能', 3);
```

### 9.3 技能版本表

```sql
-- 技能版本历史
CREATE TABLE skill_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
  
  -- 版本信息
  version VARCHAR(30) NOT NULL,                 -- semver 格式
  changelog TEXT,                               -- 更新日志（Markdown）
  
  -- 包信息
  package_url VARCHAR(500) NOT NULL,            -- 技能包下载地址
  package_hash VARCHAR(64) NOT NULL,            -- SHA256 哈希
  package_size_bytes BIGINT NOT NULL,           -- 包大小
  
  -- 兼容性
  min_platform_version VARCHAR(30),             -- CODE-YI 最低版本要求
  breaking_changes BOOLEAN DEFAULT FALSE,
  migration_guide TEXT,
  
  -- MCP 工具清单（此版本提供的工具列表快照）
  tool_manifest JSONB,                          -- MCP tools/list 的快照
  
  -- 权限声明（此版本的权限要求）
  permissions JSONB NOT NULL DEFAULT '{}',      -- 网络、文件系统、资源限制等
  
  -- 审核
  review_status VARCHAR(20) NOT NULL DEFAULT 'pending'
    CHECK (review_status IN ('pending', 'in_review', 'approved', 'rejected')),
  review_notes TEXT,
  reviewed_at TIMESTAMPTZ,
  reviewed_by UUID,
  
  -- 时间
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  published_at TIMESTAMPTZ,
  
  UNIQUE(skill_id, version)
);

-- 索引
CREATE INDEX idx_skill_versions_skill ON skill_versions(skill_id, created_at DESC);
CREATE INDEX idx_skill_versions_review ON skill_versions(review_status) 
  WHERE review_status = 'pending';
```

### 9.4 技能安装表

```sql
-- 技能安装记录（Workspace 级别）
CREATE TABLE skill_installations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  skill_id UUID NOT NULL REFERENCES skills(id),
  
  -- 安装版本
  installed_version_id UUID NOT NULL REFERENCES skill_versions(id),
  installed_version VARCHAR(30) NOT NULL,
  
  -- 状态
  status VARCHAR(20) NOT NULL DEFAULT 'installing'
    CHECK (status IN (
      'installing',          -- 安装中
      'active',              -- 活跃（正常运行）
      'disabled',            -- 已禁用（手动暂停）
      'error',               -- 异常（Server 崩溃等）
      'updating',            -- 更新中
      'uninstalling',        -- 卸载中
      'needs_reauth',        -- 需要重新授权
      'install_failed'       -- 安装失败
    )),
  status_details JSONB,                         -- 状态详情（error 时有错误信息）
  
  -- MCP Server 运行时信息
  server_process_id INTEGER,                    -- MCP Server 进程 PID
  server_transport VARCHAR(20),                 -- 实际使用的 Transport 类型
  server_endpoint VARCHAR(500),                 -- sse/http 的端点 URL
  server_started_at TIMESTAMPTZ,                -- Server 启动时间
  server_last_heartbeat TIMESTAMPTZ,            -- 最后心跳时间
  
  -- 配置
  config JSONB DEFAULT '{}',                    -- 用户自定义配置
  env_overrides JSONB DEFAULT '{}',             -- 环境变量覆盖
  
  -- 统计
  total_calls INTEGER DEFAULT 0,                -- 总调用次数
  calls_24h INTEGER DEFAULT 0,                  -- 过去 24 小时调用次数
  avg_latency_ms INTEGER,                       -- 平均调用延迟
  success_rate DECIMAL(4,3) DEFAULT 1.000,      -- 调用成功率
  last_call_at TIMESTAMPTZ,                     -- 最后调用时间
  
  -- 治理
  allowed_agent_ids UUID[],                     -- 允许使用的 Agent ID（NULL=全部允许）
  rate_limit_per_minute INTEGER,                -- 每分钟调用上限
  rate_limit_per_hour INTEGER,                  -- 每小时调用上限
  
  -- 审计
  installed_by UUID NOT NULL,                   -- 安装者 user_id
  installed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  disabled_at TIMESTAMPTZ,
  disabled_by UUID,
  
  UNIQUE(workspace_id, skill_id)
);

-- 索引
CREATE INDEX idx_skill_inst_workspace ON skill_installations(workspace_id, status);
CREATE INDEX idx_skill_inst_skill ON skill_installations(skill_id);
CREATE INDEX idx_skill_inst_status ON skill_installations(status);
CREATE INDEX idx_skill_inst_active ON skill_installations(workspace_id) 
  WHERE status = 'active';
```

### 9.5 技能评价表

```sql
-- 技能评价
CREATE TABLE skill_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  user_id UUID NOT NULL,
  
  -- 评分
  rating DECIMAL(2,1) NOT NULL
    CHECK (rating >= 1.0 AND rating <= 5.0),
  
  -- 评论
  comment TEXT,                                 -- 评论内容（限 500 字）
  
  -- 有用度
  helpful_count INTEGER DEFAULT 0,              -- 有用票数
  
  -- 状态
  is_visible BOOLEAN DEFAULT TRUE,              -- 是否可见（被举报后可能隐藏）
  
  -- 时间
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- 唯一约束：一个 Workspace 对一个技能只能有一条评价
  UNIQUE(skill_id, workspace_id)
);

-- 索引
CREATE INDEX idx_skill_reviews_skill ON skill_reviews(skill_id, created_at DESC)
  WHERE is_visible = TRUE;
CREATE INDEX idx_skill_reviews_rating ON skill_reviews(skill_id, rating);
CREATE INDEX idx_skill_reviews_user ON skill_reviews(user_id);
```

### 9.6 OAuth 配置表

```sql
-- OAuth Provider 配置（系统级——预配置的 OAuth 应用信息）
CREATE TABLE oauth_providers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Provider 信息
  name VARCHAR(50) NOT NULL UNIQUE,             -- github, lark, jira, gmail, outlook
  display_name VARCHAR(100) NOT NULL,           -- GitHub, 飞书, Jira, Gmail, Outlook
  icon_url VARCHAR(500),
  
  -- OAuth 应用配置
  client_id VARCHAR(200) NOT NULL,              -- OAuth Client ID
  client_secret_encrypted BYTEA NOT NULL,       -- 加密存储的 Client Secret
  authorize_url VARCHAR(500) NOT NULL,          -- 授权 URL
  token_url VARCHAR(500) NOT NULL,              -- Token 交换 URL
  scopes TEXT[] NOT NULL,                       -- 默认 Scopes
  
  -- 回调配置
  redirect_uri VARCHAR(500) NOT NULL,           -- OAuth 回调 URL
  
  -- 额外配置
  extra_params JSONB DEFAULT '{}',              -- Provider 特有参数
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- OAuth 连接（用户级——用户授权后的 Token 存储）
CREATE TABLE oauth_connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  user_id UUID NOT NULL,                        -- 授权者
  provider_id UUID NOT NULL REFERENCES oauth_providers(id),
  skill_installation_id UUID REFERENCES skill_installations(id),
  
  -- Token（加密存储）
  access_token_encrypted BYTEA NOT NULL,
  refresh_token_encrypted BYTEA,
  token_type VARCHAR(20) DEFAULT 'Bearer',
  scopes TEXT[],
  
  -- Token 有效期
  access_token_expires_at TIMESTAMPTZ,
  refresh_token_expires_at TIMESTAMPTZ,
  
  -- 连接信息
  provider_user_id VARCHAR(200),                -- 在 Provider 中的用户 ID
  provider_user_name VARCHAR(200),              -- 在 Provider 中的用户名
  provider_user_email VARCHAR(200),             -- 在 Provider 中的邮箱
  
  -- 状态
  status VARCHAR(20) NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'expired', 'revoked', 'error')),
  status_details TEXT,
  
  -- 时间
  connected_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_refreshed_at TIMESTAMPTZ,
  disconnected_at TIMESTAMPTZ,
  
  -- 唯一约束：一个 Workspace 对一个 Provider 对一个技能只有一个连接
  UNIQUE(workspace_id, provider_id, skill_installation_id)
);

-- 索引
CREATE INDEX idx_oauth_conn_workspace ON oauth_connections(workspace_id, status);
CREATE INDEX idx_oauth_conn_provider ON oauth_connections(provider_id);
CREATE INDEX idx_oauth_conn_skill ON oauth_connections(skill_installation_id);
CREATE INDEX idx_oauth_conn_expiry ON oauth_connections(access_token_expires_at)
  WHERE status = 'active';
```

### 9.7 MCP 连接表

```sql
-- MCP Server 连接状态（运行时状态跟踪）
CREATE TABLE mcp_connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  skill_installation_id UUID NOT NULL REFERENCES skill_installations(id) ON DELETE CASCADE,
  
  -- Server 信息
  server_name VARCHAR(100) NOT NULL,            -- MCP Server 名称
  server_version VARCHAR(30),                   -- MCP Server 版本
  protocol_version VARCHAR(20),                 -- MCP 协议版本
  
  -- 连接信息
  transport_type VARCHAR(20) NOT NULL
    CHECK (transport_type IN ('stdio', 'sse', 'streamable-http')),
  process_id INTEGER,                           -- stdio 模式的进程 PID
  endpoint_url VARCHAR(500),                    -- sse/http 模式的端点
  
  -- 能力
  capabilities JSONB NOT NULL DEFAULT '{}',     -- Server 声明的能力
  -- 示例: { "tools": true, "resources": true, "prompts": false }
  
  -- 工具清单
  registered_tools JSONB NOT NULL DEFAULT '[]', -- 已注册的工具列表
  tool_count INTEGER DEFAULT 0,
  
  -- 状态
  status VARCHAR(20) NOT NULL DEFAULT 'connecting'
    CHECK (status IN ('connecting', 'connected', 'disconnected', 'error', 'restarting')),
  status_details TEXT,
  
  -- 健康
  last_heartbeat_at TIMESTAMPTZ,
  uptime_seconds BIGINT DEFAULT 0,
  restart_count INTEGER DEFAULT 0,              -- 自动重启次数
  
  -- 统计
  total_calls INTEGER DEFAULT 0,
  failed_calls INTEGER DEFAULT 0,
  avg_latency_ms INTEGER,
  
  -- 时间
  connected_at TIMESTAMPTZ,
  disconnected_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  UNIQUE(skill_installation_id)
);

-- 索引
CREATE INDEX idx_mcp_conn_skill ON mcp_connections(skill_installation_id);
CREATE INDEX idx_mcp_conn_status ON mcp_connections(status);
CREATE INDEX idx_mcp_conn_heartbeat ON mcp_connections(last_heartbeat_at)
  WHERE status IN ('connected');
```

### 9.8 技能调用日志表

```sql
-- 技能工具调用日志（审计 + 统计）
CREATE TABLE skill_call_logs (
  id BIGSERIAL PRIMARY KEY,
  workspace_id UUID NOT NULL,
  skill_installation_id UUID NOT NULL,
  mcp_connection_id UUID,
  
  -- 调用者
  agent_id UUID,                                -- 调用的 Agent ID
  agent_name VARCHAR(100),                      -- Agent 名称（冗余）
  conversation_id UUID,                         -- 所属对话 ID
  
  -- 工具信息
  tool_name VARCHAR(100) NOT NULL,              -- 调用的工具名称
  tool_arguments JSONB,                         -- 调用参数（可脱敏）
  
  -- 结果
  status VARCHAR(20) NOT NULL
    CHECK (status IN ('success', 'error', 'timeout', 'rate_limited', 'permission_denied')),
  result_summary TEXT,                          -- 结果摘要（不含敏感数据）
  error_type VARCHAR(50),                       -- 错误类型
  error_message TEXT,                           -- 错误消息
  
  -- 性能
  latency_ms INTEGER,                           -- 调用延迟（毫秒）
  
  -- 时间
  called_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引（使用分区或定期归档，因为此表增长快）
CREATE INDEX idx_call_logs_workspace ON skill_call_logs(workspace_id, called_at DESC);
CREATE INDEX idx_call_logs_skill ON skill_call_logs(skill_installation_id, called_at DESC);
CREATE INDEX idx_call_logs_agent ON skill_call_logs(agent_id, called_at DESC);
CREATE INDEX idx_call_logs_tool ON skill_call_logs(tool_name, called_at DESC);
CREATE INDEX idx_call_logs_status ON skill_call_logs(status, called_at DESC);
-- 分区建议：按月分区，保留 6 个月热数据
```

### 9.9 技能举报表

```sql
-- 技能举报
CREATE TABLE skill_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  skill_id UUID NOT NULL REFERENCES skills(id),
  reporter_id UUID NOT NULL,                    -- 举报者
  
  -- 举报信息
  report_type VARCHAR(30) NOT NULL
    CHECK (report_type IN (
      'malicious',        -- 恶意行为
      'poor_quality',     -- 质量差
      'misleading',       -- 描述不符
      'security_issue',   -- 安全问题
      'license_violation', -- 许可证违规
      'other'
    )),
  description TEXT NOT NULL,
  
  -- 处理
  status VARCHAR(20) NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'reviewing', 'resolved', 'dismissed')),
  resolution TEXT,
  resolved_by UUID,
  resolved_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_skill_reports_skill ON skill_reports(skill_id, status);
CREATE INDEX idx_skill_reports_status ON skill_reports(status, created_at);
```

### 9.10 ER 关系图

```
skills (技能元数据)
  │
  ├── skill_versions (版本历史)
  │     └── skill_installations.installed_version_id → skill_versions.id
  │
  ├── skill_installations (Workspace 安装记录)
  │     │
  │     ├── mcp_connections (MCP Server 连接状态)
  │     │
  │     └── oauth_connections (OAuth Token 存储)
  │           └── oauth_providers (系统级 OAuth 配置)
  │
  ├── skill_reviews (用户评价)
  │
  ├── skill_reports (举报记录)
  │
  └── skill_call_logs (调用日志)
  
skill_categories (分类)
  └── skills.category → skill_categories.name

外部关联：
  skill_installations.workspace_id → workspaces.id
  skill_installations.installed_by → users.id
  skill_reviews.user_id → users.id
  skill_call_logs.agent_id → agents.id (Module 5)
  skill_call_logs.conversation_id → conversations.id (Module 1)
```

### 9.11 与现有模块的数据关系

**与 Module 1 (Chat 对话) 的关系：**
- `skill_call_logs.conversation_id` 关联到 Module 1 的 `conversations` 表
- Agent 在对话中调用工具时，Tool Call 记录既出现在对话消息中（Module 1），也出现在调用日志中（Module 6）

**与 Module 5 (Agent 管理) 的关系：**
- `skill_call_logs.agent_id` 关联到 Module 5 的 `agents` 表
- Agent 的可用工具列表由 Module 6 的 Tool Registry 提供
- Agent 配置中的 System Prompt 由 Tool Registry 动态注入工具描述

**与 Module 4 (Team 团队) 的关系：**
- 技能的使用权限可与 Agent 角色（Module 4）关联——如"观察者角色的 Agent 不能使用写操作工具"
- `skill_installations.allowed_agent_ids` 可限制特定 Agent 使用特定技能

---

## 10. 技术方案

### 10.1 整体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                          客户端层                                    │
│  Web (Next.js + TailwindCSS)                                        │
│  ├── Skill Marketplace Page (技能市场浏览)                           │
│  │   ├── Category Tabs (分类 Tab)                                   │
│  │   ├── Skill Card Grid (技能卡片网格)                             │
│  │   └── Search Bar (搜索栏)                                        │
│  ├── Skill Detail Page (技能详情页)                                  │
│  │   ├── Tool List (工具列表)                                       │
│  │   ├── Version History (版本历史)                                 │
│  │   ├── Reviews (评价列表)                                         │
│  │   └── OAuth Status (连接状态)                                    │
│  ├── Install Flow (安装流程 UI)                                     │
│  │   ├── Permission Review (权限审查)                               │
│  │   ├── OAuth Flow (OAuth 弹窗)                                   │
│  │   └── Progress Indicator (进度指示)                              │
│  ├── My Skills Page (我的技能管理)                                   │
│  └── Upload Skill Page (上传技能)                                   │
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
│  Skill Market ──── Install ──── MCP Client ──── OAuth               │
│  Service           Orchestrator  Runtime        Manager              │
│       │                │            │               │                │
│       │                │            │          Token Vault            │
│       │                │            │          (AES-256-GCM)         │
│       │                │            │               │                │
│  ┌────┴────────────────┴────────────┴───────────────┴──────┐       │
│  │              Event Bus (Redis Streams)                     │       │
│  └────┬────────────────┬────────────────┬──────────────────┘       │
│       │                │                │                            │
│  Review            Tool Registry     Skill Call                      │
│  Pipeline          Service           Logger                          │
│                                                                      │
│  ┌──────────────────────────────────────────────────────┐           │
│  │              Sandbox Runtime                           │           │
│  │  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐     │           │
│  │  │ MCP    │  │ MCP    │  │ MCP    │  │ MCP    │     │           │
│  │  │ Server │  │ Server │  │ Server │  │ Server │     │           │
│  │  │ GitHub │  │ Lark   │  │ DB     │  │ Custom │     │           │
│  │  └────────┘  └────────┘  └────────┘  └────────┘     │           │
│  └──────────────────────────────────────────────────────┘           │
└───────────────────────┬─────────────────────────────────────────────┘
                        │
┌───────────────────────┴─────────────────────────────────────────────┐
│                        数据层                                        │
│  PostgreSQL 16 (Cloud SQL)  │  Redis 7 (Memorystore)                │
│  (skills, skill_versions,    │  (tool registry cache,               │
│   skill_installations,       │   oauth state, install locks,        │
│   oauth_connections,         │   rate limiting counters,            │
│   skill_call_logs)           │   event bus, websocket pub/sub)      │
└─────────────────────────────────────────────────────────────────────┘
```

### 10.2 API 设计

#### RESTful API

```
# 技能市场
GET    /api/v1/skills                            # 技能列表（支持分类/搜索/排序）
       ?category=mcp&search=github&sort=rating&page=1&limit=20
GET    /api/v1/skills/:sid                       # 技能详情
GET    /api/v1/skills/:sid/versions              # 技能版本列表
GET    /api/v1/skills/:sid/tools                 # 技能提供的工具列表
GET    /api/v1/skills/:sid/reviews               # 技能评价列表
GET    /api/v1/skills/categories                 # 技能分类列表

# 技能安装管理
POST   /api/v1/workspaces/:wid/skills/install    # 安装技能
POST   /api/v1/workspaces/:wid/skills/uninstall  # 卸载技能
POST   /api/v1/workspaces/:wid/skills/update     # 更新技能
POST   /api/v1/workspaces/:wid/skills/enable     # 启用已禁用的技能
POST   /api/v1/workspaces/:wid/skills/disable    # 禁用技能
GET    /api/v1/workspaces/:wid/skills/installed  # 已安装技能列表
GET    /api/v1/workspaces/:wid/skills/:sid/status # 技能安装状态详情

# OAuth 管理
GET    /api/v1/workspaces/:wid/oauth/connections # 已连接的 OAuth 列表
POST   /api/v1/workspaces/:wid/oauth/connect     # 发起 OAuth 连接
GET    /api/v1/oauth/callback                    # OAuth 回调端点
POST   /api/v1/workspaces/:wid/oauth/disconnect  # 断开 OAuth 连接
GET    /api/v1/workspaces/:wid/oauth/:pid/status # 连接状态

# 评价管理
POST   /api/v1/skills/:sid/reviews               # 提交评价
PATCH  /api/v1/skills/:sid/reviews/:rid          # 修改评价
DELETE /api/v1/skills/:sid/reviews/:rid          # 删除评价
POST   /api/v1/skills/:sid/reviews/:rid/helpful  # 标记评价有用

# 技能上传（社区）
POST   /api/v1/skills/upload                     # 上传新技能
POST   /api/v1/skills/:sid/versions/upload       # 上传新版本
GET    /api/v1/skills/my                         # 我上传的技能列表

# 技能举报
POST   /api/v1/skills/:sid/reports               # 举报技能

# MCP 工具注册表
GET    /api/v1/workspaces/:wid/tools             # 当前可用的工具列表
GET    /api/v1/workspaces/:wid/tools/:tid        # 工具详情

# 调用日志
GET    /api/v1/workspaces/:wid/skills/:sid/logs  # 技能调用日志
GET    /api/v1/workspaces/:wid/tools/logs        # 全局工具调用日志
       ?agent_id=xxx&tool=create_pull_request&from=2026-04-01&to=2026-04-20
```

#### 请求/响应示例

**获取技能列表：**

```typescript
// GET /api/v1/skills?category=mcp&sort=rating&page=1&limit=20
// Response 200
{
  "skills": [
    {
      "id": "skill_github",
      "name": "github-integration",
      "display_name": "GitHub 集成",
      "description": "连接GitHub仓库，支持PR管理、Issue追踪、代码搜索和Actions监控",
      "icon_url": "https://cdn.codeyi.com/skill-icons/github.svg",
      "category": "mcp",
      "source_type": "official",
      "latest_version": "2.1.0",
      "install_count": 12300,
      "avg_rating": 4.5,
      "review_count": 328,
      "tool_count": 12,
      "requires_oauth": true,
      "oauth_providers": ["github"],
      "tags": ["github", "git", "pr", "issue"],
      "is_installed": true,                   // 当前 Workspace 是否已安装
      "installed_status": "active"            // 安装状态
    },
    {
      "id": "skill_lark",
      "name": "lark-integration",
      "display_name": "飞书集成",
      "description": "连接飞书工作台，支持消息收发、日历管理、文档协作和审批流程",
      "icon_url": "https://cdn.codeyi.com/skill-icons/lark.svg",
      "category": "mcp",
      "source_type": "official",
      "latest_version": "1.8.0",
      "install_count": 8700,
      "avg_rating": 4.8,
      "review_count": 215,
      "tool_count": 18,
      "requires_oauth": true,
      "oauth_providers": ["lark"],
      "tags": ["lark", "feishu", "飞书", "messaging", "calendar"],
      "is_installed": true,
      "installed_status": "active"
    }
    // ... more skills
  ],
  "total": 156,
  "page": 1,
  "limit": 20,
  "has_more": true
}
```

**安装技能：**

```typescript
// POST /api/v1/workspaces/:wid/skills/install
// Request
{
  "skill_id": "skill_github",
  "version": "2.1.0",     // 可选，默认最新版本
  "config": {}             // 可选，自定义配置
}

// Response 202 (Accepted — 安装是异步操作)
{
  "installation_id": "inst_abc123",
  "skill_id": "skill_github",
  "status": "installing",
  "requires_oauth": true,
  "oauth_url": "https://app.codeyi.com/api/v1/oauth/connect?provider=github&state=xxx",
  "message": "安装已开始。此技能需要连接 GitHub 账户，请完成授权。"
}
```

**OAuth 连接：**

```typescript
// POST /api/v1/workspaces/:wid/oauth/connect
// Request
{
  "provider": "github",
  "skill_installation_id": "inst_abc123",
  "scopes": ["repo", "read:org", "workflow"]
}

// Response 200
{
  "authorize_url": "https://github.com/login/oauth/authorize?client_id=xxx&scope=repo%20read:org%20workflow&state=xxx&redirect_uri=xxx",
  "state": "oauth_state_xyz",
  "expires_in": 600   // state 有效期（秒）
}

// 用户完成授权后，GitHub 回调:
// GET /api/v1/oauth/callback?code=xxx&state=oauth_state_xyz
// 服务器处理:
// 1. 验证 state
// 2. 用 code 换取 access_token
// 3. 加密存储 token
// 4. 注入到 MCP Server 环境变量
// 5. 重定向到前端成功页面
```

**获取已安装技能的工具列表：**

```typescript
// GET /api/v1/workspaces/:wid/tools
// Response 200
{
  "tools": [
    {
      "tool_id": "skill_github:create_pull_request",
      "skill_id": "skill_github",
      "skill_name": "GitHub 集成",
      "name": "create_pull_request",
      "description": "创建 GitHub Pull Request",
      "input_schema": {
        "type": "object",
        "properties": {
          "owner": { "type": "string", "description": "仓库所有者" },
          "repo": { "type": "string", "description": "仓库名" },
          "title": { "type": "string", "description": "PR 标题" },
          "body": { "type": "string", "description": "PR 描述" },
          "head": { "type": "string", "description": "源分支" },
          "base": { "type": "string", "description": "目标分支" }
        },
        "required": ["owner", "repo", "title", "head", "base"]
      },
      "is_available": true,
      "call_count_24h": 15,
      "avg_latency_ms": 1200,
      "success_rate": 0.96
    },
    {
      "tool_id": "skill_github:search_code",
      "skill_id": "skill_github",
      "skill_name": "GitHub 集成",
      "name": "search_code",
      "description": "在 GitHub 仓库中搜索代码",
      "input_schema": {
        "type": "object",
        "properties": {
          "query": { "type": "string", "description": "搜索关键词" },
          "language": { "type": "string", "description": "编程语言筛选" },
          "repo": { "type": "string", "description": "限定仓库" }
        },
        "required": ["query"]
      },
      "is_available": true,
      "call_count_24h": 32,
      "avg_latency_ms": 800,
      "success_rate": 0.99
    },
    {
      "tool_id": "skill_db:query_sql",
      "skill_id": "skill_db",
      "skill_name": "数据库查询",
      "name": "query_sql",
      "description": "执行 SQL 查询",
      "input_schema": {
        "type": "object",
        "properties": {
          "connection_id": { "type": "string", "description": "数据库连接 ID" },
          "query": { "type": "string", "description": "SQL 查询语句" },
          "params": { "type": "array", "description": "查询参数" }
        },
        "required": ["connection_id", "query"]
      },
      "is_available": true,
      "call_count_24h": 45,
      "avg_latency_ms": 350,
      "success_rate": 0.92
    }
    // ... more tools
  ],
  "total_tools": 42,
  "total_available": 38
}
```

### 10.3 WebSocket 事件

```typescript
// 客户端 → 服务端
interface WsClientEvents {
  'skills:subscribe': { workspace_id: string };         // 订阅技能市场更新
  'skills:unsubscribe': { workspace_id: string };
  'installation:subscribe': { installation_id: string }; // 订阅安装进度
  'installation:unsubscribe': { installation_id: string };
}

// 服务端 → 客户端
interface WsServerEvents {
  // 安装进度
  'skill:install_progress': {
    installation_id: string;
    skill_id: string;
    step: 'downloading' | 'configuring' | 'starting' | 'registering' | 'verifying';
    progress: number;          // 0-100
    message: string;           // 人类可读的进度消息
  };
  
  // 安装完成
  'skill:installed': {
    installation_id: string;
    skill_id: string;
    skill_name: string;
    version: string;
    tools: string[];           // 新注册的工具名列表
  };
  
  // 安装失败
  'skill:install_failed': {
    installation_id: string;
    skill_id: string;
    error: string;
    retry_available: boolean;
  };
  
  // 技能状态变更
  'skill:status_changed': {
    installation_id: string;
    skill_id: string;
    old_status: string;
    new_status: string;
    details?: string;
  };
  
  // OAuth 连接状态
  'oauth:connected': {
    provider: string;
    skill_id: string;
    provider_user_name: string;
  };
  
  'oauth:disconnected': {
    provider: string;
    skill_id: string;
    reason: string;
  };
  
  'oauth:token_expired': {
    provider: string;
    skill_id: string;
    message: string;
  };
  
  // MCP Server 状态
  'mcp:server_status_changed': {
    skill_id: string;
    old_status: string;
    new_status: string;
    details?: string;
  };
  
  // 工具注册表变更
  'tools:updated': {
    added: string[];          // 新增的工具名
    removed: string[];        // 移除的工具名
    updated: string[];        // 更新的工具名
  };
  
  // 技能更新可用
  'skill:update_available': {
    skill_id: string;
    skill_name: string;
    current_version: string;
    new_version: string;
    changelog: string;
  };
}
```

### 10.4 前端架构

```
pages/
  toolbox/
    index.tsx              # 技能市场主页（卡片浏览 + 搜索 + 分类）
    [skillId]/
      index.tsx            # 技能详情页
      reviews.tsx          # 评价列表页
    my-skills.tsx          # 我的技能管理页
    upload.tsx             # 上传技能页

components/
  toolbox/
    SkillCard.tsx                 # 技能卡片组件
    SkillCardGrid.tsx             # 技能卡片网格
    SkillCategoryTabs.tsx         # 分类 Tab 组件
    SkillSearchBar.tsx            # 搜索栏组件
    SkillSortDropdown.tsx         # 排序下拉组件
    
    detail/
      SkillDetailHeader.tsx       # 详情页头部（名称、评分、安装按钮）
      SkillToolList.tsx           # 工具列表组件
      SkillVersionHistory.tsx     # 版本历史组件
      SkillReviewList.tsx         # 评价列表组件
      SkillPermissions.tsx        # 权限说明组件
      SkillOAuthStatus.tsx        # OAuth 连接状态组件
      
    install/
      InstallConfirmModal.tsx     # 安装确认弹窗
      PermissionReviewPanel.tsx   # 权限审查面板
      InstallProgress.tsx         # 安装进度组件
      OAuthFlowModal.tsx          # OAuth 授权弹窗
      UninstallConfirmModal.tsx   # 卸载确认弹窗
      
    upload/
      SkillUploadForm.tsx         # 上传表单
      ManifestPreview.tsx         # Manifest 预览
      ReviewStatusBadge.tsx       # 审核状态标签
      
    common/
      RatingStars.tsx             # 评分星星组件
      InstallCountBadge.tsx       # 安装数徽标
      SourceBadge.tsx             # 来源标签（官方/社区/MCP）
      SkillStatusIndicator.tsx    # 技能状态指示器
      OAuthConnectButton.tsx      # OAuth 连接按钮
```

**关键组件设计：**

**SkillCard（技能卡片）：**

```tsx
// components/toolbox/SkillCard.tsx
interface SkillCardProps {
  skill: Skill;
  isInstalled: boolean;
  installedStatus?: string;
  onInstall: (skillId: string) => void;
  onDetail: (skillId: string) => void;
}

export function SkillCard({ skill, isInstalled, installedStatus, onInstall, onDetail }: SkillCardProps) {
  return (
    <div className="rounded-lg border p-4 hover:shadow-md transition-shadow cursor-pointer"
         onClick={() => onDetail(skill.id)}>
      {/* 头部：图标 + 名称 + 来源标签 */}
      <div className="flex items-start gap-3">
        <img src={skill.icon_url} alt={skill.display_name} className="w-10 h-10 rounded-lg" />
        <div className="flex-1 min-w-0">
          <h3 className="font-medium truncate">{skill.display_name}</h3>
          <div className="flex items-center gap-2 mt-1">
            <SourceBadge type={skill.source_type} category={skill.category} />
          </div>
        </div>
      </div>
      
      {/* 评分 + 安装数 */}
      <div className="flex items-center gap-3 mt-3 text-sm text-gray-500">
        <span className="flex items-center gap-1">
          <RatingStars rating={skill.avg_rating} size="sm" />
          {skill.avg_rating.toFixed(1)}
        </span>
        <InstallCountBadge count={skill.install_count} />
      </div>
      
      {/* 描述 */}
      <p className="mt-2 text-sm text-gray-600 line-clamp-2">{skill.description}</p>
      
      {/* 安装按钮 */}
      <div className="mt-3">
        {isInstalled ? (
          <span className="inline-flex items-center text-sm text-green-600">
            <CheckIcon className="w-4 h-4 mr-1" /> 已安装
          </span>
        ) : (
          <button 
            className="px-3 py-1 text-sm bg-blue-600 text-white rounded-md hover:bg-blue-700"
            onClick={(e) => { e.stopPropagation(); onInstall(skill.id); }}>
            安装
          </button>
        )}
      </div>
    </div>
  );
}
```

**InstallProgress（安装进度）：**

```tsx
// components/toolbox/install/InstallProgress.tsx
interface InstallProgressProps {
  installationId: string;
  skillName: string;
}

const INSTALL_STEPS = [
  { key: 'downloading', label: '下载技能包', icon: DownloadIcon },
  { key: 'configuring', label: '配置环境', icon: SettingsIcon },
  { key: 'starting', label: '启动服务', icon: PlayIcon },
  { key: 'registering', label: '注册工具', icon: PlugIcon },
  { key: 'verifying', label: '验证连接', icon: CheckCircleIcon },
];

export function InstallProgress({ installationId, skillName }: InstallProgressProps) {
  const { currentStep, progress, message } = useInstallProgress(installationId);
  
  return (
    <div className="p-4">
      <h3 className="font-medium">正在安装 {skillName}...</h3>
      
      {/* 步骤列表 */}
      <div className="mt-4 space-y-3">
        {INSTALL_STEPS.map((step, index) => {
          const status = getStepStatus(step.key, currentStep, INSTALL_STEPS);
          return (
            <div key={step.key} className="flex items-center gap-3">
              <StepIcon status={status} Icon={step.icon} />
              <span className={cn(
                'text-sm',
                status === 'active' && 'text-blue-600 font-medium',
                status === 'completed' && 'text-green-600',
                status === 'pending' && 'text-gray-400',
              )}>
                {step.label}
              </span>
              {status === 'active' && (
                <div className="flex-1 h-1 bg-gray-200 rounded">
                  <div className="h-1 bg-blue-600 rounded transition-all" 
                       style={{ width: `${progress}%` }} />
                </div>
              )}
            </div>
          );
        })}
      </div>
      
      {/* 当前操作消息 */}
      <p className="mt-3 text-sm text-gray-500">{message}</p>
    </div>
  );
}
```

### 10.5 OAuth Flow 架构

```
┌──────────────────────────────────────────────────────────────────────┐
│                          OAuth Flow                                  │
│                                                                      │
│  1. 发起连接                                                         │
│     前端 → POST /oauth/connect { provider: "github" }                │
│     后端 → 生成 state + 返回 authorize_url                           │
│     前端 → 弹出 OAuth 窗口打开 authorize_url                         │
│                                                                      │
│  2. 用户授权                                                         │
│     OAuth 窗口 → GitHub 授权页                                       │
│     用户点击 "Authorize" → GitHub 回调到 /oauth/callback             │
│                                                                      │
│  3. Token 交换                                                       │
│     /oauth/callback 接收 code + state                                │
│       ├── 验证 state（防 CSRF）                                      │
│       ├── POST github.com/login/oauth/access_token { code, ... }     │
│       ├── 获取 access_token + refresh_token                          │
│       ├── 获取用户信息（user.login, user.email）                      │
│       └── 处理结果 ↓                                                 │
│                                                                      │
│  4. Token 存储                                                       │
│     Token Vault:                                                     │
│       ├── AES-256-GCM 加密 access_token 和 refresh_token             │
│       ├── 写入 oauth_connections 表                                   │
│       └── 加密密钥来源：                                              │
│           ├── 生产环境: Cloud KMS / HSM                              │
│           └── 开发环境: 环境变量中的 ENCRYPTION_KEY                   │
│                                                                      │
│  5. Token 注入                                                       │
│     Install Orchestrator:                                             │
│       ├── 读取 oauth_connections 的 access_token                      │
│       ├── 解密 → 明文 token                                          │
│       ├── 注入到 MCP Server 的环境变量                                │
│       │   env: GITHUB_TOKEN={access_token}                           │
│       └── MCP Server 使用 token 调用 GitHub API                      │
│                                                                      │
│  6. Token 自动刷新                                                   │
│     Token Refresh Worker (定时任务):                                  │
│       ├── 扫描即将过期的 oauth_connections（expires_at < NOW + 1h）    │
│       ├── 使用 refresh_token 获取新 access_token                      │
│       ├── 更新 oauth_connections 表                                   │
│       ├── 重新注入到 MCP Server 环境变量                              │
│       └── 如果 refresh_token 也过期 → 通知用户重新授权                │
│                                                                      │
│  7. OAuth 窗口关闭                                                   │
│     /oauth/callback 重定向到关闭页面                                  │
│       ├── postMessage 通知父窗口连接成功                              │
│       └── 父窗口更新 UI 状态                                         │
└──────────────────────────────────────────────────────────────────────┘
```

### 10.6 沙箱运行时架构

```
┌──────────────────────────────────────────────────────────────────────┐
│                     Sandbox Runtime                                   │
│                                                                      │
│  ┌── 隔离级别 ──────────────────────────────────────────────────┐    │
│  │                                                               │    │
│  │  Level 1: 进程隔离（所有技能）                                │    │
│  │    - 每个 MCP Server 是独立子进程                             │    │
│  │    - 进程崩溃不影响主进程和其他技能                           │    │
│  │    - 进程级 OOM Killer 保护                                   │    │
│  │                                                               │    │
│  │  Level 2: 资源限制（所有技能）                                │    │
│  │    - CPU: cgroup 限制（默认 0.5 核）                          │    │
│  │    - 内存: cgroup 限制（默认 256MB）                          │    │
│  │    - 磁盘: 挂载限制（默认 100MB tmpfs）                       │    │
│  │    - 单次调用超时: 30 秒                                      │    │
│  │                                                               │    │
│  │  Level 3: 网络隔离（社区技能）                                │    │
│  │    - 只允许访问 manifest 中声明的域名                         │    │
│  │    - iptables/nftables 规则                                   │    │
│  │    - DNS 解析限制                                             │    │
│  │                                                               │    │
│  │  Level 4: 容器隔离（高风险社区技能）                          │    │
│  │    - Docker 容器运行                                          │    │
│  │    - 独立 filesystem namespace                                │    │
│  │    - 独立 network namespace                                   │    │
│  │    - seccomp 系统调用过滤                                     │    │
│  │                                                               │    │
│  └───────────────────────────────────────────────────────────────┘    │
│                                                                      │
│  ┌── 监控 ──────────────────────────────────────────────────────┐    │
│  │                                                               │    │
│  │  Resource Monitor（资源监控）:                                 │    │
│  │    - CPU 使用率告警（> 90% 持续 30 秒）                       │    │
│  │    - 内存使用率告警（> 80%）                                  │    │
│  │    - 进程存活检查（心跳 15 秒）                               │    │
│  │    - 网络流量监控                                             │    │
│  │                                                               │    │
│  │  Auto-Recovery（自动恢复）:                                   │    │
│  │    - 进程崩溃 → 自动重启（最多 3 次）                         │    │
│  │    - OOM → 重启 + 通知管理员                                  │    │
│  │    - 超时 → Kill 进程 + 返回超时错误                          │    │
│  │    - 连续崩溃 → 标记异常 + 禁用技能 + 通知管理员              │    │
│  │                                                               │    │
│  └───────────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────────┘
```

### 10.7 性能目标

| 指标 | 目标 |
|------|------|
| 技能市场列表加载（20 个技能） | < 200ms |
| 技能搜索响应时间 | < 150ms |
| 技能卡片渲染（首屏 8 张） | < 100ms |
| 一键安装总耗时（无 OAuth） | < 30s |
| 一键安装总耗时（含 OAuth） | < 60s（含用户授权时间） |
| MCP Server 启动时间（stdio） | < 5s |
| MCP Server 启动时间（Docker） | < 15s |
| OAuth Token 交换延迟 | < 2s |
| 工具调用延迟（MCP 协议开销） | < 100ms（不含外部 API 调用时间） |
| Tool Registry 查询 | < 5ms |
| 工具热加载（安装后可用） | < 3s |
| WebSocket 安装进度推送 | < 200ms |
| 技能卸载完成时间 | < 5s |
| Token 自动刷新延迟 | < 3s |

---

## 11. 模块集成

### 11.1 与 Module 1 (Chat 对话) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| 工具调用上下文 | Toolbox → Chat | Agent 在对话中调用工具时，工具调用过程和结果显示在对话消息流中 |
| 工具可用性提示 | Toolbox → Chat | Agent 在对话中提到某个能力但未安装对应技能时，提示用户"安装 XX 技能后即可使用" |
| OAuth 对话内触发 | Toolbox → Chat | Agent 提示需要 OAuth 授权时，在对话中嵌入授权按钮，用户点击后完成 OAuth 流程 |
| 调用日志关联 | Toolbox ← Chat | 工具调用日志关联到对话 ID，可从对话中追溯工具调用历史 |
| 工具描述注入 | Toolbox → Chat | Tool Registry 生成的工具描述文本注入 Agent 的 System Prompt |

```yaml
# 对话中的工具调用展示
message:
  role: assistant
  content: "正在查询 GitHub PR 列表..."
  tool_calls:
    - tool_name: "list_pull_requests"
      skill_name: "GitHub 集成"
      arguments: { owner: "code-yi", repo: "frontend", state: "open" }
      status: "success"
      result_preview: "找到 3 个开放的 PR"
      latency_ms: 1200
```

### 11.2 与 Module 2 (Tasks 任务) 集成

| 集成点 | 说明 |
|--------|------|
| 任务执行中的工具调用 | Agent 执行任务时可调用工具箱中的技能——如执行"代码审查任务"时调用 GitHub 集成的 `list_pull_requests` 和 `create_review` 工具 |
| 任务自动化链 | 协调者 Agent 可在任务编排中指定工具依赖——如"先用数据库查询工具获取数据，再用邮件工具发送报告" |
| 工具调用权限 | Agent 的工具调用权限受 Module 4 角色约束——如观察者 Agent 不能调用有写操作的工具 |

**数据流：**

```
Module 2 (Task) 执行                         Module 6 (Toolbox) 处理
────────────────────                        ────────────────────────
Agent 执行代码审查任务
  ├── 需要获取 PR 列表       ────→    检查 Tool Registry → list_pull_requests 可用
  │                                   检查权限 → Agent 角色允许 ✓
  │                                   路由到 GitHub MCP Server
  │                                   返回 PR 列表结果
  │
  ├── 需要创建 Review         ────→    检查 Tool Registry → create_review 可用
  │                                   检查权限 → Agent 角色允许 ✓
  │                                   路由到 GitHub MCP Server
  │                                   返回 Review 创建结果
  │
  └── 任务完成                ────→    记录调用日志到 skill_call_logs
```

### 11.3 与 Module 4 (Team 团队) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| Agent 角色与工具权限 | Team → Toolbox | Agent 的团队角色决定其可使用的工具范围——观察者只能用只读工具，执行者可以用读写工具 |
| 技能安装通知 | Toolbox → Team | 安装/卸载技能时通知团队 Chat 频道："已为团队安装 GitHub 集成" |
| 技能治理 | Team → Toolbox | 团队管理员可在团队设置中配置技能使用策略（白名单/黑名单） |

**Agent 角色 → 工具权限映射：**

```
Agent 角色        可用工具类型
─────────────    ──────────────────────
执行者            读写工具（创建 PR、写文件、发消息等）
审核者            只读工具 + 审核工具（查看 PR、代码搜索等）
协调者            全部工具（含任务编排类工具）
观察者            只读工具（查询数据、搜索代码等）
```

### 11.4 与 Module 5 (Agent 管理) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| Agent 可用工具列表 | Toolbox → Agent | Agent 的 System Prompt 中动态注入当前 Workspace 已安装且活跃的工具列表 |
| Agent 创建时预装技能 | Toolbox ← Agent | 创建 Agent 时可选择预装技能套件（如"开发者 Agent"自动安装 GitHub + 数据库 + 文件操作） |
| Agent 能力标签 | Toolbox → Agent | Agent 的能力标签部分来源于已安装的技能（安装 GitHub 技能 → 自动添加"GitHub 管理"能力标签） |
| 技能调用统计 | Toolbox → Agent | Agent 的调用统计中包含各技能的使用频率，用于 Agent 详情页展示 |

```yaml
# Module 5 → Module 6：Agent System Prompt 工具注入
event: agent.system_prompt_build
handler:
  1. 查询该 Agent 所属 Workspace 的已安装技能
  2. 查询该 Agent 角色允许的工具列表
  3. 从 Tool Registry 获取工具描述
  4. 生成工具描述文本块
  5. 注入到 Agent System Prompt 的 [Available Tools] 区域

生成的 Prompt 片段示例:
  "你可以使用以下工具：
   
   ## GitHub 集成
   - create_pull_request: 创建 Pull Request。参数: owner, repo, title, body, head, base
   - search_code: 搜索代码。参数: query, language?, repo?
   - list_issues: 列出 Issues。参数: owner, repo, state?, labels?
   ...
   
   ## 数据库查询
   - query_sql: 执行 SQL 查询。参数: connection_id, query, params?
   - list_tables: 列出数据库表。参数: connection_id
   ..."
```

### 11.5 集成数据流全景

```
Chat (M1)              Tasks (M2)          Toolbox (M6)           Agent (M5)
  │                      │                     │                      │
  │                      │                     │                      │
  │ 对话中工具调用展示    │                     │ Tool Call 请求        │
  │ ←──────────────────────────────────────── │ ←────────────────── │ Agent 调用工具
  │                      │                     │ 路由到 MCP Server    │
  │                      │                     │ 返回工具结果 ────→  │
  │                      │                     │                      │
  │                      │ 任务执行需要工具     │                      │
  │                      ├──────────────────→  │ 权限检查             │
  │                      │                     │ 工具调用              │
  │                      │  ←──────────────── │ 返回结果             │
  │                      │                     │                      │
  │ 团队通知              │                     │                      │
  │ ←──────────────────────────────────────── │ 技能安装/卸载通知    │
  │                      │                     │                      │
  │                      │                     │ System Prompt 注入   │
  │                      │                     ├──────────────────→  │ 可用工具列表
  │                      │                     │                      │
  │                      │                     │ 调用日志关联对话     │
  │ ←──────────────────────────────────────── │                      │
  │                      │                     │                      │

Team (M4)                                      │
  │                                            │
  │ Agent 角色权限                              │
  ├──────────────────────────────────────────→ │ 工具权限过滤
  │                                            │
  │ 技能治理策略                                │
  ├──────────────────────────────────────────→ │ 安装白名单/黑名单
  │                                            │
```

---

## 12. 测试用例

### 12.1 技能市场浏览

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-TB-01 | 默认加载 | 打开工具箱页面 | 显示技能卡片网格，默认"全部"Tab，按评分降序排列 |
| TC-TB-02 | 分类筛选（内置） | 点击"内置技能"Tab | 只显示 category=builtin 的技能，卡片数量变化 |
| TC-TB-03 | 分类筛选（MCP） | 点击"MCP 集成"Tab | 只显示 category=mcp 的技能 |
| TC-TB-04 | 分类筛选（社区） | 点击"社区技能"Tab | 只显示 category=community 的技能 |
| TC-TB-05 | 分类筛选（我的） | 点击"我的技能"Tab | 显示当前 Workspace 已安装的技能 + 用户上传的技能 |
| TC-TB-06 | 搜索关键词 | 搜索框输入"GitHub" | 实时过滤，显示名称/描述/标签包含"GitHub"的技能 |
| TC-TB-07 | 搜索中文 | 搜索框输入"飞书" | 正确匹配飞书集成技能 |
| TC-TB-08 | 搜索无结果 | 搜索框输入"不存在的技能" | 显示空状态"未找到匹配的技能" |
| TC-TB-09 | 卡片信息完整性 | 检查技能卡片内容 | 每张卡片显示：图标、名称、来源标签、评分、安装数、描述、安装按钮 |
| TC-TB-10 | 已安装状态 | 查看已安装技能的卡片 | 安装按钮变为"已安装 ✓"（绿色） |
| TC-TB-11 | 分页加载 | 滚动到底部 | 自动加载更多技能（无限滚动或分页） |
| TC-TB-12 | 响应式布局 | 缩小浏览器窗口 | 卡片从 4 列变为 2 列再变为 1 列 |

### 12.2 技能安装

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-IN-01 | 安装无 OAuth 技能 | 点击"安装"→ 确认权限 → 安装 | 显示安装进度 → 完成后状态变为"已安装" |
| TC-IN-02 | 安装需 OAuth 技能 | 点击"安装"→ 确认 → OAuth 授权 | 弹出 OAuth 窗口 → 授权后自动继续安装 |
| TC-IN-03 | OAuth 授权拒绝 | 在 OAuth 页面点击"拒绝" | 安装取消，提示"需要授权才能安装此技能" |
| TC-IN-04 | 安装进度显示 | 安装进行中 | 进度条依次显示：下载→配置→启动→注册→验证 |
| TC-IN-05 | 安装失败重试 | 安装中网络中断 | 显示错误信息 + "重试"按钮 → 点击重试 → 重新开始安装 |
| TC-IN-06 | 安装超时 | MCP Server 启动超时 | 自动回滚 → 提示"安装超时" → 清理已下载的资源 |
| TC-IN-07 | 安装后热加载 | 安装完成 | Agent 立即可以使用新工具（无需重启） |
| TC-IN-08 | 重复安装 | 尝试安装已安装的技能 | 提示"此技能已安装"，按钮不可点击 |
| TC-IN-09 | 权限审查 | 安装前查看权限声明 | 弹窗显示"此技能需要访问 api.github.com"等权限信息 |
| TC-IN-10 | 非管理员安装 | 普通成员尝试安装技能 | 操作被拒绝，提示"需要管理员权限" |

### 12.3 技能卸载与管理

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-UN-01 | 正常卸载 | 点击"卸载"→ 确认 | MCP Server 停止 → 工具从 Registry 移除 → 状态变为"未安装" |
| TC-UN-02 | 卸载时有进行中调用 | Agent 正在使用工具时卸载 | 提示"当前有进行中的调用"，可选择等待或强制卸载 |
| TC-UN-03 | 禁用技能 | 点击"禁用" | 技能状态变为"已禁用"，MCP Server 停止，但配置和 Token 保留 |
| TC-UN-04 | 重新启用 | 禁用后点击"启用" | MCP Server 重新启动 → 工具重新注册 → 恢复可用 |
| TC-UN-05 | 更新技能 | 有新版本时点击"更新" | 停止旧版 → 安装新版 → 工具列表可能变化 → 通知前端 |
| TC-UN-06 | 更新失败回滚 | 更新过程中新版启动失败 | 自动回滚到旧版 → 提示"更新失败，已恢复旧版本" |

### 12.4 OAuth 管理

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-OA-01 | GitHub OAuth 连接 | 点击"连接 GitHub" | 弹出 GitHub 授权页 → 授权后显示"已连接 @username" |
| TC-OA-02 | 飞书 OAuth 连接 | 点击"连接飞书" | 弹出飞书授权页 → 授权后显示"已连接" |
| TC-OA-03 | 断开连接 | 点击"断开连接"→ 确认 | Token 删除 → 状态变为"未连接" → 相关工具不可用 |
| TC-OA-04 | Token 自动刷新 | access_token 即将过期 | 后台自动使用 refresh_token 刷新 → 用户无感 |
| TC-OA-05 | Token 过期通知 | refresh_token 也过期 | 技能状态变为"需要重新授权" → 通知用户 |
| TC-OA-06 | Token 加密存储 | 检查数据库中的 token 字段 | 存储的是加密后的 BYTEA，非明文 |
| TC-OA-07 | OAuth CSRF 防护 | 伪造 OAuth callback | state 验证失败 → 拒绝 → 返回 403 |
| TC-OA-08 | 并发 OAuth 流程 | 同时发起两个 GitHub 连接 | 第二个请求等待或拒绝，避免 state 冲突 |

### 12.5 MCP 协议

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-MC-01 | MCP Server 启动 | 安装技能后 | MCP Server 进程启动 → Initialize 成功 → 工具发现完成 |
| TC-MC-02 | 工具列表获取 | 技能安装完成 | tools/list 返回所有工具 → 注册到 Tool Registry |
| TC-MC-03 | 工具调用成功 | Agent 调用 create_pull_request | MCP Client 路由到 GitHub Server → 执行成功 → 返回结果 |
| TC-MC-04 | 工具调用超时 | 外部 API 无响应 | 30 秒超时 → 返回超时错误 → Agent 收到错误信息 |
| TC-MC-05 | MCP Server 崩溃 | Server 进程异常退出 | 自动检测 → 自动重启 → 重新注册工具 → 记录错误日志 |
| TC-MC-06 | MCP Server 连续崩溃 | 重启 3 次仍然失败 | 标记为异常 → 禁用技能 → 通知管理员 |
| TC-MC-07 | 协议版本不匹配 | MCP Server 使用旧版协议 | Initialize 阶段检测 → 提示"需要更新技能" |
| TC-MC-08 | 工具名冲突 | 两个技能提供同名工具 | 冲突检测 → 使用 skill_name:tool_name 格式消歧 |
| TC-MC-09 | stdio 传输 | 本地 MCP Server | 通过 stdin/stdout 正常通信 → 延迟 < 10ms |
| TC-MC-10 | SSE 传输 | 远程 MCP Server | SSE 连接建立 → 双向通信正常 → 支持 Server 推送 |

### 12.6 技能评分与举报

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-RV-01 | 提交评分 | 已安装技能，选择 4 星提交 | 评分提交成功 → 技能平均评分更新 |
| TC-RV-02 | 修改评分 | 修改之前的 4 星为 5 星 | 评分更新 → 平均评分重新计算 |
| TC-RV-03 | 附带评论 | 评分时填写评论文本 | 评论显示在技能详情页 |
| TC-RV-04 | 未安装不可评分 | 未安装技能尝试评分 | 提示"请先安装并使用后再评分" |
| TC-RV-05 | 举报技能 | 选择"恶意行为"举报 | 举报提交成功 → 进入审核队列 |

### 12.7 技能上传

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-UP-01 | 提交技能 | 填写信息 + Git 仓库 URL → 提交 | 进入自动审核 → 安全扫描 → 进入人工审核队列 |
| TC-UP-02 | Manifest 校验失败 | 提交缺少必填字段的技能 | 提示"manifest 格式错误：缺少 description 字段" |
| TC-UP-03 | 安全扫描发现问题 | 代码中有读取 ~/.ssh/ 的逻辑 | 自动审核拒绝 → 提示"发现安全风险：尝试读取 SSH 密钥" |
| TC-UP-04 | 审核通过发布 | 人工审核通过 | 技能出现在市场列表中 → 通知提交者 |
| TC-UP-05 | 提交新版本 | 对已发布技能提交 v2.0.0 | 新版本进入审核 → 通过后推送给已安装用户 |

### 12.8 沙箱安全

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-SB-01 | 内存超限 | MCP Server 分配超过 256MB 内存 | 进程被 OOM Killer 终止 → 自动重启 → 记录异常 |
| TC-SB-02 | CPU 超限 | MCP Server CPU 持续 100% | cgroup 限制生效 → 不影响其他进程 → 30 秒后告警 |
| TC-SB-03 | 网络访问控制 | 社区技能尝试访问未声明的域名 | 网络请求被拒绝 → 记录违规日志 |
| TC-SB-04 | 文件系统隔离 | 技能尝试读取 /etc/passwd | 访问被拒绝 → 记录违规日志 |
| TC-SB-05 | 调用超时 | 单次工具调用执行 > 30 秒 | 进程收到 SIGTERM → 返回超时错误 |

### 12.9 热加载

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-HL-01 | 安装后立即可用 | 安装新技能 | Agent 在下一次对话轮次中即可使用新工具 |
| TC-HL-02 | 卸载后立即失效 | 卸载技能 | Agent 在下一次对话轮次中不再看到已卸载的工具 |
| TC-HL-03 | 更新后工具变更 | 更新技能（新版本增加了工具） | 新工具自动注册 → Agent 可以使用新工具 |
| TC-HL-04 | 进行中调用不中断 | 更新技能时有正在执行的调用 | 等待当前调用完成 → 再执行更新 |

### 12.10 性能测试

| 指标 | 测试方法 | 目标 |
|------|---------|------|
| 市场列表加载 | API 响应时间 + Lighthouse | < 200ms (API) + FCP < 800ms |
| 搜索响应 | API 响应时间 | < 150ms |
| 安装总耗时 | 端到端计时（无 OAuth） | < 30s |
| MCP Server 启动 | 从 spawn 到 Initialize 完成 | < 5s（stdio），< 15s（Docker） |
| 工具调用协议开销 | MCP 协议层延迟（不含外部 API） | < 100ms |
| Tool Registry 查询 | 缓存命中 | < 5ms |
| 热加载延迟 | 从安装完成到 Agent 可用 | < 3s |
| 并发工具调用 | k6 负载测试 | > 100 calls/s |
| OAuth Token 刷新 | Token 刷新 Worker | < 3s |
| 调用日志写入 | 高频调用场景 | > 500 logs/s |

---

## 13. 成功指标

### 13.1 核心指标

| 指标 | MVP (2 月后) | 成熟期 (10 月后) | 说明 |
|------|-------------|-----------------|------|
| 已安装技能数（平均/Workspace） | 3 | 12 | 含预装和用户安装 |
| 市场可用技能总数 | 10 | 200+ | 含官方、MCP、社区 |
| 日均工具调用次数（全平台） | 100 | 10,000 | 所有 Agent 的工具调用总和 |
| 一键安装成功率 | > 90% | > 98% | 安装流程无人工干预完成 |
| OAuth 连接成功率 | > 85% | > 95% | 用户完成 OAuth 授权的比率 |

### 13.2 技能市场指标

| 指标 | MVP | 成熟期 | 说明 |
|------|-----|--------|------|
| 日均市场浏览量 | 50 PV | 2,000 PV | 工具箱页面的访问量 |
| 搜索使用率 | 20% 访问者使用搜索 | 40%+ | 搜索是发现技能的主要方式 |
| 技能转化率（浏览→安装） | 10% | 25% | 浏览技能后实际安装的比率 |
| 社区技能数量 | 0 | 50+ | 社区用户上传的技能 |
| 平均评分 | > 3.5 | > 4.0 | 所有技能的平均评分 |
| 评价覆盖率 | 30% 已安装技能有评价 | 60%+ | 安装后提交评价的比率 |

### 13.3 MCP 引擎指标

| 指标 | MVP | 成熟期 | 说明 |
|------|-----|--------|------|
| MCP Server 可用性 | > 95% | > 99.5% | Server 在线时间 / 总时间 |
| 工具调用成功率 | > 90% | > 97% | 调用成功 / 总调用（含超时和错误） |
| 平均工具调用延迟 | < 2s | < 1s | 含外部 API 调用时间 |
| MCP 协议开销 | < 100ms | < 50ms | 纯 MCP 协议层延迟 |
| Server 自动重启成功率 | > 80% | > 95% | 崩溃后自动重启成功的比率 |

### 13.4 OAuth 指标

| 指标 | MVP | 成熟期 | 说明 |
|------|-----|--------|------|
| OAuth 授权完成率 | > 80% | > 90% | 发起 OAuth 到完成授权 |
| Token 自动刷新成功率 | > 90% | > 99% | 自动刷新而非要求用户重新授权 |
| Token 过期通知及时率 | > 95% | > 99% | 过期前及时通知用户 |
| 平均连接数/Workspace | 2 | 5 | 每个 Workspace 的 OAuth 连接数 |

### 13.5 体验指标

| 指标 | 目标 | 说明 |
|------|------|------|
| 安装到可用时间（无 OAuth） | < 30 秒 | 从点击"安装"到 Agent 可使用 |
| 安装到可用时间（含 OAuth） | < 60 秒 | 含用户 OAuth 操作时间 |
| 工具箱页面 FCP | < 800ms | 首次内容绘制 |
| 搜索响应时间 P99 | < 300ms | 搜索框输入到结果显示 |
| 用户首次安装成功率 | > 85% | 第一次安装就成功的比率 |
| 工具调用错误恢复时间 | < 10 秒 | 从错误到自动恢复或提示用户 |

---

## 14. 风险与缓解

### 14.1 技术风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **MCP 协议变更** — Anthropic 发布 MCP 协议的不兼容更新（如 2025-03-26 版本引入的 Streamable HTTP 替代 SSE） | 中 | 高 | Transport Layer 抽象设计——新增传输协议只需添加 Adapter，不影响上层逻辑。同时支持多个协议版本（Initialize 阶段协商）。关注 MCP 社区动态，提前适配 |
| **MCP Server 质量参差不齐** — 社区 MCP Server 可能有 Bug、内存泄漏、性能问题，影响整个 Agent 运行时 | 高 | 高 | 沙箱隔离确保单个 Server 的问题不会蔓延。资源限制（CPU/内存/超时）防止资源耗尽。自动重启机制处理瞬时故障。连续崩溃自动禁用 + 通知管理员。官方技能经过严格测试，社区技能经过审核流水线 |
| **OAuth Token 泄露** — 加密存储的 Token 被攻击者获取 | 低 | 高 | AES-256-GCM 加密存储。加密密钥由 Cloud KMS / HSM 管理，不存储在数据库中。Token 解密仅在注入 MCP Server 环境变量时进行，解密后的明文不持久化。数据库访问严格控制。定期安全审计 |
| **安装流程可靠性** — 网络问题、包下载失败、MCP Server 启动失败等导致安装失败率高 | 中 | 中 | 安装编排器支持断点续传。每个步骤有重试机制（3 次指数退避）。安装失败自动回滚（不留残留）。技能包镜像缓存（CDN 加速）。详细的错误信息帮助用户排查问题 |
| **Tool Registry 一致性** — 多个 MCP Server 同时启动/停止时 Tool Registry 数据不一致 | 低 | 中 | Registry 更新使用分布式锁（Redis Lock）。每次更新是原子操作（旧工具列表 → 新工具列表）。定期一致性校验（对比 Registry 和实际运行的 MCP Server）。乐观并发控制（版本号） |
| **热加载时序问题** — Agent 正在构造 Tool Call 时，工具列表发生变化 | 低 | 低 | Agent System Prompt 的工具列表是"快照"——只在对话轮次开始时更新，轮次中不变。如果 Tool Call 的目标工具已被卸载，返回友好错误消息而非系统异常。下一轮次 Agent 自动获得更新后的工具列表 |

### 14.2 产品风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **用户不理解 MCP 概念** — MCP 是技术术语，非技术用户可能困惑"什么是 MCP 集成" | 高 | 中 | 在市场 UI 中弱化"MCP"技术术语。使用"集成"而非"MCP Server"。分类用"内置技能/外部集成/社区技能"而非"builtin/mcp/community"。技能卡片的描述聚焦于"能做什么"而非"使用什么协议" |
| **技能发现困难** — 技能数量增长后，用户难以找到合适的技能 | 中 | 中 | 搜索 + 分类 + 标签多维度发现。推荐算法（基于已安装技能推荐相关技能）。"编辑推荐"和"热门技能"置顶区域。按使用场景分类（"开发工具"、"办公协作"、"数据分析"） |
| **社区技能安全风险** — 恶意用户上传包含后门的技能 | 中 | 高 | 三层防护：自动化安全扫描 + 人工代码审核 + 运行时沙箱隔离。社区技能在安装时明确提示"此技能由社区提供，已通过安全审核但请谨慎评估"。举报机制 + 快速下架流程。官方技能和社区技能视觉区分（不同 Badge 颜色） |
| **OAuth 授权疲劳** — 用户需要为每个需要 OAuth 的技能单独授权，操作繁琐 | 中 | 低 | 一个 OAuth Provider 一次授权，多个技能共享（如 GitHub Token 被 GitHub 集成和 GitHub Actions 监控共用）。Token 持久化——卸载再安装不需要重新授权。连接状态在"我的技能"页面统一管理 |
| **技能更新不及时** — 社区技能作者不积极维护，技能版本过旧 | 中 | 低 | 显示"最后更新时间"帮助用户判断活跃度。长期未更新的技能降低排序权重。允许社区 Fork 和重新发布（类似 npm 的 fork 机制）。弃用标记（is_deprecated）+ 替代品推荐 |

### 14.3 安全风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **MCP Server 数据外泄** — MCP Server 将用户数据发送到未授权的第三方服务器 | 低 | 高 | 网络隔离——社区技能只能访问 manifest 中声明的域名。网络流量监控——异常外发流量告警。安全审核重点检查网络请求行为。官方技能源码完全可审计 |
| **OAuth Redirect 攻击** — 攻击者构造恶意 OAuth 回调绕过授权流程 | 低 | 高 | 严格的 redirect_uri 校验——只接受预注册的回调 URL。state 参数使用加密随机数 + 绑定 session。state 有效期短（10 分钟）。PKCE（Proof Key for Code Exchange）增强安全性 |
| **恶意技能提权** — 技能利用沙箱漏洞获取宿主机权限 | 低 | 高 | 多层沙箱（进程隔离 + cgroup + 网络隔离）。Docker 容器运行时使用 rootless 模式 + seccomp。定期更新沙箱运行时。安全赏金计划鼓励漏洞报告 |
| **供应链攻击** — 技能依赖的 npm/pip 包被投毒 | 低 | 高 | 依赖锁文件（package-lock.json / requirements.txt）固定版本。依赖漏洞扫描（npm audit / safety check）。官方技能使用最小依赖原则。社区技能审核时检查依赖链 |

---

## 15. 排期建议

### 15.1 为什么是 4 周？

Module 6（Toolbox）P1 范围的工期估算为 ~4 周（1 前端 + 1 后端），原因如下：

1. **MCP Client Runtime 是核心技术投入**：实现完整的 MCP 协议栈（三种 Transport、Initialize 握手、Tool Discovery、Tool Call、错误处理）需要约 1.5 人周后端工作量。这是 Module 6 最复杂的技术组件
2. **安装编排器逻辑复杂**：从"一键安装"到"MCP Server 启动 → 工具注册 → 热加载"的全流程编排涉及进程管理、异步任务、回滚机制，复杂度高于标准 CRUD
3. **OAuth 流程需要多 Provider 适配**：GitHub、飞书、Jira、Gmail 等 Provider 的 OAuth 实现细节各不相同（Scopes 格式、Token 刷新机制、用户信息端点），每个 Provider 都需要单独适配
4. **前端工作量集中在市场 UI**：技能卡片、详情页、安装流程、OAuth 弹窗、进度指示器等组件数量多，但交互逻辑相对标准
5. **P0 预装集成为 P1 铺路**：P0 阶段已完成 MCP Client Runtime 核心和 GitHub 集成，P1 可以在此基础上快速扩展市场 UI 和安装流程

### 15.2 Sprint 规划（P1 范围约 4 周）

#### Sprint 1: 技能市场 UI + 技能数据模型（第 1 周）

**做什么：** 搭建技能市场的前端页面和后端数据模型，实现技能浏览和搜索。

**后端（1 人周）：**
- 数据库 Schema 创建（skills, skill_categories, skill_versions, skill_installations）
- Skill Market API（技能列表、详情、搜索、分类筛选）
- 技能数据种子（初始化 8 个设计稿中的技能数据）
- 搜索索引（PostgreSQL 全文搜索 + GIN 索引）
- 技能卡片数据聚合（评分、安装数、工具数等统计字段）

**前端（1 人周）：**
- 工具箱主页面框架（页面路由、布局）
- 技能卡片组件（SkillCard）
- 技能卡片网格（SkillCardGrid，响应式布局）
- 分类 Tab 组件（SkillCategoryTabs）
- 搜索栏组件（SkillSearchBar，实时搜索防抖）
- 来源标签组件（SourceBadge：官方/社区/MCP/内置）
- 评分星星组件（RatingStars）
- 安装数徽标组件（InstallCountBadge）

**难点：** 搜索索引设计——需要支持中英文混合搜索、标签匹配、排序（评分/安装数/最新）。

#### Sprint 2: 一键安装 + MCP 集成引擎（第 2 周）

**做什么：** 实现技能安装的完整流程，包括 MCP Server 生命周期管理和工具注册。

**后端（1 人周）：**
- Install Orchestrator 核心（安装编排器：下载→配置→启动→注册→验证）
- MCP Server Manager（进程管理：启动/停止/重启/健康检查）
- Tool Registry Service（工具注册表：注册/注销/查询/冲突检测）
- Skill Installation API（安装/卸载/启用/禁用/更新）
- MCP Connection 状态管理（mcp_connections 表 + 心跳检测）
- 技能安装异步任务（Redis Queue + Worker）
- 安装失败回滚机制

**前端（1 人周）：**
- 技能详情页（SkillDetailPage：工具列表、版本历史、权限说明）
- 安装确认弹窗（InstallConfirmModal：权限审查面板）
- 安装进度组件（InstallProgress：步骤进度条 + WebSocket 实时更新）
- 卸载确认弹窗（UninstallConfirmModal）
- 技能状态指示器（SkillStatusIndicator：活跃/异常/需要重连等）
- WebSocket 集成（订阅安装进度和技能状态变更）

**难点：** MCP Server 进程管理的可靠性——启动超时、崩溃自动重启、资源限制。安装流程的原子性——任何步骤失败都要干净回滚。

#### Sprint 3: OAuth 授权 + 工具调用链路（第 3 周）

**做什么：** 实现 OAuth 授权自动化和完整的 Agent → MCP Server 工具调用链路。

**后端（1 人周）：**
- OAuth Provider Registry（预配置 GitHub/飞书/Jira/Gmail 的 OAuth 应用信息）
- OAuth Flow Handler（发起授权→回调处理→Token 交换→加密存储）
- Token Vault（AES-256-GCM 加密/解密 + Token 注入 MCP Server 环境变量）
- Token Refresh Worker（定时检查过期→自动刷新→通知用户）
- OAuth Connection API（连接/断开/状态查询）
- 工具调用完整链路（Agent Tool Call → 权限检查 → MCP Client → MCP Server → 结果返回）
- Skill Call Logger（调用日志写入 skill_call_logs 表）

**前端（1 人周）：**
- OAuth 连接按钮组件（OAuthConnectButton）
- OAuth 授权弹窗（OAuthFlowModal：弹出 OAuth 窗口 + postMessage 监听）
- OAuth 连接状态展示（已连接/未连接/已过期）
- 我的技能页面（MySkillsPage：已安装技能管理、OAuth 连接管理）
- Agent 对话中的工具调用展示（Tool Call 卡片 UI）
- 工具调用日志页面（调用历史列表）

**难点：** 多 OAuth Provider 的差异性处理（不同的 Scopes 格式、Token 刷新机制、错误码）。Token 加密存储的安全性——密钥管理方案。

#### Sprint 4: 评分系统 + 联调 + 沙箱（第 4 周）

**做什么：** 实现评分系统、沙箱安全机制，全流程联调和 Bug 修复。

**后端（1 人周）：**
- 评分系统 API（提交/修改/查询评价、评分统计计算）
- skill_reviews 表和 skill_reports 表实现
- 沙箱运行时强化（cgroup 资源限制、网络隔离规则、超时控制）
- 全流程联调（安装 → OAuth → 工具调用 → 日志 → 评分）
- 性能优化（Tool Registry 缓存、API 响应优化）
- 与 Module 5 集成（Agent System Prompt 工具注入）
- 与 Module 1 集成（对话中工具调用展示）

**前端（1 人周）：**
- 评分评论组件（ReviewForm、ReviewList）
- 举报弹窗（ReportModal）
- 全流程联调 + Bug 修复
- 空状态和错误状态设计
- Loading 状态和 Skeleton 屏
- 响应式适配（Mobile/Tablet/Desktop）
- 性能优化（列表虚拟化、图片懒加载）

**难点：** 沙箱的网络隔离实现——需要根据 manifest 中的网络声明动态生成 iptables 规则。跨模块联调——确保 Module 6 与 Module 1/5 的集成点全部正常。

### 15.3 P0 功能排期（约 1.5 周，在 P1 之前）

#### Sprint 0: 预装核心集成（第 -1.5 ~ 0 周）

**后端（1 人周）：**
- MCP Client Runtime 核心实现（Initialize + Tool Discovery + Tool Call）
- stdio Transport 实现
- GitHub MCP Server 预装和配置
- 数据库查询工具（内置，非 MCP）
- 文件操作工具（内置，非 MCP）
- 基础 OAuth 流程（GitHub Personal Access Token 或 OAuth）
- Agent System Prompt 工具描述注入

**前端（0.5 人周）：**
- Agent 设置中的"已连接工具"显示（简单列表，非完整市场 UI）
- 工具调用在对话中的基础展示

### 15.4 P2 功能排期（约 3 周，P1 完成后）

#### Sprint 5-6: 社区技能上传 + 审核（第 5-6 周）

**后端（1.5 人周）：**
- 技能上传 API（提交仓库 URL → 自动解析 manifest → 安全扫描 → 人工审核队列）
- 审核流水线（自动化检查：manifest 校验 + 依赖扫描 + 功能测试）
- 人工审核管理后台 API
- 版本管理（新版本提交 → 审核 → 发布 → 自动推送更新通知）

**前端（1.5 人周）：**
- 上传技能页面（UploadSkillForm：仓库 URL + 信息填写 + manifest 预览）
- 审核状态追踪页面
- 版本管理页面
- 更新通知 UI

#### Sprint 7: 技能治理 + 高级功能（第 7 周）

- 按 Agent 角色控制技能可用性
- 调用频率限制配置 UI
- 调用审计日志页面
- 自动更新策略配置
- 技能推荐算法（基于已安装技能推荐相关技能）

### 15.5 里程碑

| 里程碑 | 时间 | 关键能力 | 对应 Sprint |
|--------|------|---------|------------|
| **M0: Core MCP** | Week 0 | MCP Client Runtime + 预装 GitHub/DB/File | Sprint 0 |
| **M1: Skill Market** | Week 1 | 技能市场 UI + 浏览/搜索/分类 | Sprint 1 |
| **M2: One-Click Install** | Week 2 | 一键安装 + MCP Server 管理 + 工具注册 + 热加载 | Sprint 2 |
| **M3: OAuth + Call Chain** | Week 3 | OAuth 授权自动化 + 完整工具调用链路 | Sprint 3 |
| **M4: Rating + Launch** | Week 4 | 评分系统 + 沙箱 + 联调 + 上线 | Sprint 4 |
| **M5: Community** | Week 6 | 社区技能上传 + 审核流水线 | Sprint 5-6 |
| **M6: Governance** | Week 7 | 技能治理 + 高级功能 | Sprint 7 |

### 15.6 团队配置

| 角色 | 人数 | 职责 |
|------|------|------|
| 前端工程师 | 1 | 技能市场 UI + 安装流程 + OAuth 弹窗 + 详情页 + 评分组件 + 工具调用展示 |
| 后端工程师 | 1 | MCP Client Runtime + Install Orchestrator + OAuth Manager + Token Vault + Tool Registry + Sandbox + 调用日志 |

**注意：** 后端工作量高于 Module 4——MCP Client Runtime 是一个全新的协议层实现，Install Orchestrator 涉及进程管理和异步编排，OAuth Manager 需要适配多个 Provider。建议后端工程师熟悉 MCP 协议规范和 Node.js 进程管理。

### 15.7 依赖关系

```
Module 5 (Agents)  ──→  Module 6 强依赖 M5 的 Agent 运行时和 System Prompt 机制
Module 1 (Chat)    ──→  Module 6 依赖 M1 的对话消息流（展示工具调用过程）
Module 4 (Team)    ──→  Module 6 依赖 M4 的 Agent 角色体系（工具权限控制）

Module 6 输出：
  ├── Tool Registry → M5 使用（Agent System Prompt 工具注入）
  ├── Skill Call API → M1 使用（对话中的工具调用展示）
  ├── 工具权限检查 → M4 集成（Agent 角色决定可用工具范围）
  └── 技能安装状态 → M5 使用（Agent 能力标签自动更新）
```

**关键依赖：**
- Module 5（Agent 管理）的 Agent 运行时架构是前置条件——MCP Client Runtime 需要知道如何将工具注入 Agent 的 System Prompt。如果 Module 5 未就绪，Module 6 的工具调用链路需要使用 Mock Agent 开发
- OAuth Provider 的应用注册是前置条件——需要在 GitHub、飞书、Jira、Gmail 等平台注册 OAuth 应用并获取 Client ID/Secret。建议在 Sprint 1 并行完成 OAuth 应用注册

---

> **文档结束。** 本 PRD 由 Zylos AI Agent 在 Stephanie 的产品指导下撰写。如有调整需求，请直接反馈。
