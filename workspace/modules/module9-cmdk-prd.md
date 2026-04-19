# CODE-YI Module 9: 全局命令面板 (Cmd+K) — 产品需求文档

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
7. [命令注册架构](#7-命令注册架构)
8. [搜索引擎](#8-搜索引擎)
9. [数据模型](#9-数据模型)
10. [技术方案](#10-技术方案)
11. [模块集成](#11-模块集成)
12. [测试用例](#12-测试用例)
13. [成功指标](#13-成功指标)
14. [风险与缓解](#14-风险与缓解)
15. [排期建议](#15-排期建议)

---

## 1. 问题陈述

### 1.1 现有工作区产品的导航效率瓶颈

当前主流协作工具（Slack、Linear、Notion、Jira、GitHub、Figma）随着功能不断膨胀，用户的操作路径越来越长。一个简单的需求——"找到上周的某个任务并重新分配给 Agent"——往往需要多次点击侧边栏导航、筛选列表、翻找页面。当 CODE-YI 包含 Chat（Module 1）、Tasks（Module 2）、Projects（Module 3）、Team（Module 4）、Agent（Module 5）、Toolbox（Module 6）、Admin（Module 7）、Settings（Module 8）八大模块时，传统的侧边栏 + 页面跳转模式面临严重的效率瓶颈：

**导航层级过深：**
- 用户需要先点击侧边栏模块图标 → 进入模块页面 → 定位子区域 → 执行操作。一次跨模块操作（如"在对话中看到一个需求 → 创建任务并分配给 Agent"）至少需要 4-6 次点击
- 模块间的切换成本高——用户每次跨模块操作都要"离开当前上下文 → 进入目标模块 → 找到目标实体 → 返回原来的上下文"
- 对于深度使用 CODE-YI 的高频用户（项目经理、技术负责人），每天在模块间的跳转可能消耗 15-30 分钟

**搜索能力碎片化：**
- Slack 的搜索只搜消息，不搜任务；Linear 的搜索只搜 Issue，不搜对话；Notion 的搜索只搜页面和数据库，不搜项目或团队成员
- 用户记得"某个东西"存在但不记得在哪个模块，需要逐个模块搜索
- 没有统一的全局搜索入口——每个模块有自己的搜索框，搜索范围和语法各不相同

**操作入口分散：**
- "创建任务"只能在 Tasks 模块完成，"创建频道"只能在 Chat 模块完成，"启动工作流"只能在 Toolbox 模块完成
- 用户需要记住每个操作的入口在哪个模块的哪个位置
- 快捷操作缺失——大量高频操作没有快捷键，只能通过 GUI 点击完成

**Agent 操作门槛高：**
- 当前触发 Agent 执行操作需要：进入 Agent 模块 → 找到对应 Agent → 查看能力列表 → 选择操作 → 填写参数 → 执行。全程至少 5 步
- 在 AI-Native 工作区中，Agent 是用户的"协作伙伴"，但触发 Agent 操作的路径和触发人类操作一样长——Agent 的"效率红利"被操作路径的摩擦力吞噬了
- 缺少"从任何地方快速调用 Agent"的能力——用户在 Chat 中看到一个 bug 报告，想让代码 Agent 修复，必须切到 Agent 模块操作

### 1.2 核心洞察

上述所有问题可以归纳为一句话：**用户知道自己想做什么，但不知道（或不想关心）入口在哪里**。

传统 GUI 的逻辑是"先导航，再操作"——用户必须先到达正确的页面，才能执行操作。但高效用户的思维模式是"先意图，再执行"——用户脑中已有明确意图（"创建一个任务"、"找到张伟"、"让代码助手修这个 bug"），需要的是**最短路径从意图到执行**。

命令面板（Command Palette）正是"意图驱动"交互模式的最佳实现：

```
传统 GUI 模式（导航驱动）：
  用户 → 侧边栏 → 模块页面 → 子页面 → 操作按钮 → 执行
  路径长度：4-6 步，耗时 5-15 秒

命令面板模式（意图驱动）：
  用户 → Cmd+K → 输入意图 → 选择结果 → 执行
  路径长度：2-3 步，耗时 1-3 秒

效率提升：3-5x
```

在 AI-Native 的语境下，命令面板还有一个独特的价值：**它是人类触发 Agent 操作的最短路径**。传统命令面板只能执行"人类操作"（导航、创建、设置），CODE-YI 的命令面板可以执行"Agent 操作"——用户输入"让代码助手修复登录 bug"，命令面板直接触发 Agent 执行，无需跳转到 Agent 模块。

### 1.3 市场机会

- 2024-2026 年，Cmd+K 命令面板已经从"开发者工具的高级功能"演变为"所有生产力工具的标配交互模式"。Linear、Raycast、Arc、Figma、GitHub、Vercel 等产品的命令面板已证明其用户接受度
- 但没有一个产品的命令面板能够**触发 AI Agent 操作**——Cmd+K 仍停留在"搜索 + 导航 + 人类操作"阶段，没有跨越到"HxA 命令执行"
- CODE-YI 的命令面板是全球首个 **HxA-aware Command Palette**：不仅可以搜索和导航，还可以直接调用 Agent 能力、触发 Agent 工作流、查看 Agent 状态——把 Agent 从"隐藏在模块深处的工具"变成"一个快捷键即可触达的协作伙伴"
- 这一差异化与 CODE-YI 整体的 AI-Native 定位完全一致——在每一个交互入口，Agent 都是一等公民

---

## 2. 产品愿景

### 2.1 一句话定位

**CODE-YI 全局命令面板是一个以 Cmd+K 快捷键唤出的意图驱动型操作中枢，支持跨模块模糊搜索（任务、消息、频道、项目、成员、Agent、文件）、快速操作（创建、跳转、@提及、启动工作流）、Agent 命令调用（从任何地方触发 Agent 执行），并通过可扩展命令注册架构让每个模块注册自己的命令。**

### 2.2 核心价值主张

```
┌──────────────────────────────────────────────────────────────────────────┐
│                    CODE-YI 全局命令面板 (Cmd+K)                           │
├──────────────────┬──────────────────────┬────────────────────────────────┤
│ 全局搜索          │ 快速操作              │ Agent 命令                     │
│                  │                      │                                │
│ 跨模块模糊搜索    │ 创建任务/频道/项目    │ 从任何页面调用 Agent            │
│ 任务/消息/频道    │ 切换频道/项目         │ "让代码助手修复 bug"           │
│ 项目/成员/文件    │ @提及成员/Agent       │ "让设计 Agent 出稿"            │
│ 最近访问历史      │ 打开设置/管理面板     │ Agent 状态快速查看             │
│ 上下文感知建议    │ 启动工作流/自动化     │ Agent 工作流快速启动           │
│ 实时联想补全      │ 键盘快捷键导航        │ 混合命令（人+Agent）           │
└──────────────────┴──────────────────────┴────────────────────────────────┘
```

### 2.3 核心差异化

| 维度 | Linear Cmd+K | Raycast | VS Code Palette | Slack Cmd+K | GitHub Cmd+K | **CODE-YI Cmd+K** |
|------|-------------|---------|-----------------|-------------|-------------|---------------------|
| 搜索范围 | Issue + Project | 系统级（App+文件） | 文件 + 命令 + 设置 | Channel + DM | Repo + Issue + PR | **全模块（8模块统一）** |
| Agent 命令 | 无 | 无 | Extension 命令 | 无 | 无 | **原生 Agent 操作** |
| 上下文感知 | 基于项目 | 基于当前 App | 基于打开文件 | 无 | 基于 Repo | **基于当前模块+任务** |
| 命令扩展性 | 固定命令集 | Extension Store | Extension API | 固定命令集 | 固定命令集 | **模块注册架构** |
| 快速操作 | 创建 Issue | 系统操作 | 编辑器命令 | 切换频道 | 导航 | **创建+切换+Agent执行** |
| 最近历史 | 有 | 有 | 有 | 有 | 有 | **有（含 Agent 命令）** |
| 模糊搜索 | ★★★★ | ★★★★★ | ★★★★ | ★★★ | ★★★★ | ★★★★★ |
| 键盘导航 | ★★★★★ | ★★★★★ | ★★★★★ | ★★★ | ★★★★ | ★★★★★ |

### 2.4 设计理念

**"One Keystroke to Anything"** ——一个按键到达任何地方、执行任何操作、调用任何 Agent。

Stephanie 的设计稿（Screen 9: Cmd+K）体现了这一理念：深色主题居中弹出的命令面板，顶部是搜索输入框（带有模式切换按钮），下方是分组的搜索结果列表（最近访问 / 任务 / 消息 / Agent 命令），每条结果右侧有快捷键提示。面板出现时，背景半透明模糊（Backdrop Blur），聚焦用户注意力到命令面板本身。按 Esc 或点击背景即可关闭。

这不只是一个搜索框——它是 CODE-YI 的**操作中枢**，是用户意图到系统行为的最短通路。

---

## 3. 竞品对标

### 3.1 命令面板能力全维度对比

| 功能 | Linear | Raycast | Spotlight | VS Code | Slack | Notion | GitHub | Figma | **CODE-YI** |
|------|--------|---------|-----------|---------|-------|--------|--------|-------|-------------|
| 全局快捷键 | Cmd+K | Cmd+Space | Cmd+Space | Cmd+Shift+P | Cmd+K | Cmd+K | Cmd+K | Cmd+/ | **Cmd+K** |
| 模糊搜索 | ★★★★ | ★★★★★ | ★★★★ | ★★★★ | ★★★ | ★★★★ | ★★★★ | ★★★ | ★★★★★ |
| 搜索实体类型数 | 3 | 10+ | 5+ | 4 | 2 | 3 | 5 | 3 | **8+** |
| 快速创建 | Issue | - | - | File | - | Page | - | - | **任务/频道/项目** |
| 导航跳转 | ★★★★★ | ★★★★★ | ★★★★ | ★★★★★ | ★★★ | ★★★★ | ★★★★ | ★★★★ | ★★★★★ |
| AI/Agent 命令 | 无 | AI 扩展 | 无 | Copilot Chat | 无 | AI 辅助 | Copilot | 无 | **原生 Agent 命令** |
| 上下文感知建议 | ★★★ | ★★★★ | ★★ | ★★★★ | ★ | ★★★ | ★★★ | ★★ | ★★★★★ |
| 命令注册扩展 | 无 | Extension | 无 | Extension | 无 | 无 | 无 | Plugin | **模块注册架构** |
| 最近历史 | ★★★★ | ★★★★★ | ★★★★ | ★★★ | ★★★ | ★★★★ | ★★★ | ★★ | ★★★★★ |
| 键盘完整操作 | ★★★★★ | ★★★★★ | ★★★ | ★★★★★ | ★★★ | ★★★ | ★★★★ | ★★★ | ★★★★★ |
| 响应速度 | ★★★★★ | ★★★★★ | ★★★★★ | ★★★★ | ★★★ | ★★★ | ★★★★ | ★★★★ | ★★★★★ |

### 3.2 深度分析

**Linear（最佳实践标杆）：**
- 优势：Cmd+K 是 Linear 最被称赞的交互设计。输入即搜索，支持 Issue、Project、Team 三种实体的模糊搜索。快速创建 Issue（在命令面板中直接输入标题 → 回车 → Issue 创建完成）。响应速度极快（< 50ms 出结果）
- 劣势：搜索范围限于 Linear 自身实体（Issue、Project、Cycle、Team），无法搜索外部系统。命令集固定，不支持第三方扩展。没有 AI Agent 命令——Linear AI 只在 Issue 详情页中可用，不在 Cmd+K 中
- 核心缺失：命令面板只执行"人类操作"，不能触发 Agent 操作

**Raycast（交互最佳）：**
- 优势：系统级命令面板，可搜索/启动任何应用、文件、联系人。Extension Store 生态丰富（3000+ Extensions）。AI Chat 集成到命令面板中。窗口管理、剪贴板历史、Snippet 等生产力功能
- 劣势：是独立的系统工具，不是协作平台的组成部分。Extension 开发门槛高（TypeScript + Raycast API）。AI 功能是通用对话，不是针对特定工作流的 Agent 命令
- 核心缺失：不了解用户的工作上下文（当前在哪个项目、看哪个任务），无法提供上下文感知建议

**VS Code Command Palette（扩展性最佳）：**
- 优势：Extension API 允许任何插件注册命令。命令数量可达数百个。Cmd+Shift+P 是开发者最熟悉的交互模式。Copilot Chat 可在命令面板中使用
- 劣势：命令面板只在编辑器上下文中工作，不跨应用。命令过多时找到目标命令的成本反而增加。Copilot 是通用 AI 对话，不是角色化的 Agent 命令
- 核心缺失：不是协作工具，没有团队、任务、项目等实体

**Slack Quick Switcher（Cmd+K）：**
- 优势：Cmd+K 唤出频道/DM 快速切换器，输入名称模糊匹配。界面简洁，聚焦"导航"这一核心场景
- 劣势：只能切换频道/DM，不能搜索消息内容。不支持任何操作（创建、设置、管理）。没有 Agent/Bot 命令。没有最近项历史权重排序
- 核心缺失：功能过于单一，只是"频道切换器"而非"命令面板"

**Notion Quick Find（Cmd+K / Cmd+P）：**
- 优势：全文搜索页面内容。AI 辅助搜索（Notion AI 可理解自然语言查询）。最近访问页面排在前面
- 劣势：搜索范围限于 Notion 页面和数据库。没有"操作"概念——只能导航到页面，不能在命令面板中执行操作（如创建页面、修改属性）。AI 功能是搜索辅助，不是 Agent 命令
- 核心缺失：只是搜索工具，不是操作中枢

**GitHub Command Palette（Cmd+K）：**
- 优势：搜索 Repository、Issue、PR、文件。支持"范围切换"（Cmd+K 后输入 > 切换到命令模式，# 搜索 Issue，! 搜索 PR）。导航高效
- 劣势：命令集固定，不可扩展。没有快速创建功能。Copilot 不在命令面板中。搜索延迟偶尔较高（依赖后端 API）
- 核心缺失：虽然有 Copilot，但命令面板中无法调用

**Figma Quick Actions（Cmd+/）：**
- 优势：搜索设计文件中的图层、组件和操作命令。Plugin 命令可注册到面板中
- 劣势：范围限于设计工具，无团队/项目/任务等实体。Plugin 扩展的命令混在一起，缺乏分类
- 核心缺失：无协作实体、无 AI Agent 能力

### 3.3 竞品命令面板的演进趋势

| 趋势 | 领先者 | 状态 | CODE-YI 的机会 |
|------|--------|------|---------------|
| AI 对话融入命令面板 | Raycast、Notion | 已实现（通用 AI 对话） | CODE-YI 做的是**角色化 Agent 命令**而非通用对话 |
| 跨应用统一搜索 | Raycast、Spotlight | 系统级工具已实现 | CODE-YI 做的是**跨模块统一搜索**（产品内） |
| 上下文感知建议 | VS Code、Linear | 初步实现 | CODE-YI 的上下文感知包含**Agent 状态和角色** |
| 命令注册扩展 | VS Code、Raycast | Extension 生态成熟 | CODE-YI 做的是**模块级注册**（更简单、更内聚） |
| 自然语言命令 | Raycast AI | 探索阶段 | P2 考虑——用自然语言描述意图，面板自动匹配命令 |

**结论：** 现有竞品的命令面板已经解决了"搜索 + 导航"的需求，但没有一个产品将 **AI Agent 操作**融入命令面板。CODE-YI 的机会是做全球第一个 HxA-aware Command Palette——把 Agent 命令和人类操作放在同一个面板中，让用户以统一的方式执行任何意图。

---

## 4. 技术突破点分析

### 4.1 HxA-aware 命令面板 (Human x Agent Command Palette)

**传统命令面板：**
```
命令集 = [人类操作]
  - 导航到页面
  - 创建实体
  - 修改设置
  - 搜索内容
```

**CODE-YI 命令面板：**
```
命令集 = [人类操作] + [Agent 操作] + [混合操作]
  - 人类操作：导航、创建、设置（同传统）
  - Agent 操作：让 Agent 执行任务、查看 Agent 状态、启动 Agent 工作流
  - 混合操作：创建任务并分配给 Agent（一步完成两个操作）
```

**核心突破：** 命令面板的"命令"不再局限于"人类在 GUI 上的操作"，而是扩展为"意图的表达"——用户的意图可能是自己操作，也可能是让 Agent 操作，命令面板统一处理。

**技术关键点：**
- 命令类型字段区分 `human_action` / `agent_action` / `hybrid_action`
- Agent 命令携带 `agent_id` 和 `action_params`，选择后直接调用 Agent Service（Module 5）的执行 API
- 混合命令（如"创建任务并分配给代码助手"）拆解为一个事务内的多步操作
- Agent 命令的权限检查复用 Module 4 的 Permission Engine——用户只能在命令面板中触发其有权限调用的 Agent

### 4.2 跨模块统一搜索引擎

**传统模式：**
```
Module 1 搜索 → 只搜消息
Module 2 搜索 → 只搜任务
Module 3 搜索 → 只搜项目
...每个模块独立搜索，互不相通
```

**CODE-YI 模式：**
```
Cmd+K 搜索 → 统一搜索引擎 → 同时搜索 8 大模块的实体
  ├── 消息 (Module 1)
  ├── 任务 (Module 2)
  ├── 项目 (Module 3)
  ├── 团队/成员 (Module 4)
  ├── Agent (Module 5)
  ├── 工具/工作流 (Module 6)
  ├── 频道 (Module 1)
  └── 文件 (附件系统)
```

**核心突破：** 搜索引擎不是简单地"并行查询 8 个模块的 API 再合并结果"，而是维护一个**统一的搜索索引**——预先将各模块的可搜索实体索引到一个专用的搜索数据结构中，查询时在单一索引中检索，保证 < 50ms 的响应速度。

**技术关键点：**
- 基于 PostgreSQL `pg_trgm` 扩展 + GIN 索引的模糊搜索（MVP 阶段，不引入 Elasticsearch）
- 各模块通过 Event Bus 实时同步实体变更到 `search_index` 表
- 搜索结果按相关度 + 时间衰减 + 上下文亲和度综合排序
- 搜索请求的去抖（Debounce 150ms）+ 取消（新请求自动取消旧请求）

### 4.3 上下文感知建议系统

**传统命令面板：** 无论用户在哪个页面，建议列表都一样。

**CODE-YI 命令面板：** 根据用户当前所在的模块、页面、任务状态，动态调整建议内容和排序。

```
上下文感知规则：
  用户在 Chat 模块 → 优先建议：切换频道、搜索消息、@提及成员
  用户在 Tasks 模块 → 优先建议：创建任务、搜索任务、分配给 Agent
  用户在 Projects 模块 → 优先建议：切换项目、查看 Sprint、项目成员
  用户在 Agent 模块 → 优先建议：Agent 命令、Agent 状态、Agent 配置
  用户正在查看某个任务 → 优先建议：与该任务相关的操作（修改状态、添加评论、分配给...）
  用户正在某个频道对话 → 优先建议：该频道的成员、最近的消息、频道设置
```

**核心突破：** 命令面板不是静态的命令列表，而是一个动态的、随上下文变化的**智能操作推荐系统**。

### 4.4 可扩展命令注册架构

**传统方式：** 命令面板的命令集在主应用中硬编码。

**CODE-YI 方式：** 每个模块通过统一的注册接口注册自己的命令。新模块开发时，只需实现注册接口即可自动出现在命令面板中。

```
命令注册架构：
  Module 1 (Chat)     → CommandRegistry.register([...chat 命令])
  Module 2 (Tasks)    → CommandRegistry.register([...task 命令])
  Module 3 (Projects) → CommandRegistry.register([...project 命令])
  Module 4 (Team)     → CommandRegistry.register([...team 命令])
  Module 5 (Agent)    → CommandRegistry.register([...agent 命令])
  Module 6 (Toolbox)  → CommandRegistry.register([...toolbox 命令])
  Module 7 (Admin)    → CommandRegistry.register([...admin 命令])
  Module 8 (Settings) → CommandRegistry.register([...settings 命令])
  
  CommandPalette → CommandRegistry.search(query, context) → 排序后的命令列表
```

**核心突破：** 命令面板是一个"平台"而非"功能"——它本身不定义命令，而是提供注册和检索机制。模块是命令的"供应商"，命令面板是命令的"集市"。这意味着未来新增模块时，命令面板自动扩展，无需修改面板代码。

---

## 5. 用户故事

### 5.1 全局搜索

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-CK-01 | 任何用户 | 作为用户，我想按 Cmd+K 唤出命令面板，输入关键词搜索任务/消息/频道/项目/成员，以便快速找到我需要的东西 | 按 Cmd+K 面板弹出 < 100ms，输入关键词后 150ms 内显示搜索结果，结果覆盖所有模块实体 | P0 |
| US-CK-02 | 任何用户 | 作为用户，我想通过模糊搜索找到名称相近的实体（如输入"lgn"匹配"登录模块任务"），以便不需要记住精确名称 | 支持拼音首字母、子串匹配、错别字容错，模糊匹配结果按相关度排序 | P0 |
| US-CK-03 | 任何用户 | 作为用户，我想在搜索结果中看到实体类型标签（任务/消息/频道/项目/成员/Agent），以便区分同名实体 | 每条结果显示类型图标 + 类型标签 + 名称 + 辅助信息（如任务状态、频道成员数） | P0 |
| US-CK-04 | 任何用户 | 作为用户，我想在没有输入时看到最近访问的项目列表，以便快速回到最近在用的东西 | 空输入时显示最近 10 条访问记录，按时间倒序排列 | P0 |

### 5.2 快速操作

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-CK-05 | 项目经理 | 作为项目经理，我想在命令面板中直接创建任务，输入标题后回车即创建，不需要跳转到 Tasks 模块 | 输入"创建任务"或"Create task" → 出现创建任务命令 → 回车后进入快速创建模式 → 输入标题 → 回车 → 任务创建成功 | P0 |
| US-CK-06 | 团队成员 | 作为成员，我想通过命令面板快速切换到某个聊天频道，不需要在侧边栏翻找 | 输入频道名称 → 选择 → 回车 → 直接跳转到该频道 | P0 |
| US-CK-07 | 团队成员 | 作为成员，我想通过命令面板快速 @提及某个人或 Agent，以便在当前频道中快速发起对话 | 输入 @ + 名称 → 显示匹配的成员/Agent 列表 → 选择后跳转到与该成员的 DM | P0 |
| US-CK-08 | 管理员 | 作为管理员，我想通过命令面板快速打开设置/管理面板的特定页面（如"通知设置"、"团队管理"），以便不需要逐级点击菜单 | 输入设置页面名称 → 选择 → 直接跳转到对应设置页 | P0 |

### 5.3 Agent 命令

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-CK-09 | 开发者 | 作为开发者，我想在命令面板中快速调用"代码助手"执行操作（如"让代码助手修复 issue #42"），不需要切到 Agent 模块 | 输入"代码助手"或 Agent 名称 → 显示该 Agent 的可用命令列表 → 选择命令 → 填写参数 → 执行 | P1 |
| US-CK-10 | 项目经理 | 作为项目经理，我想在命令面板中查看所有 Agent 的当前状态，以便快速掌握 Agent 工作情况 | 输入"Agent 状态" → 显示所有 Agent 的在线/忙碌/离线状态列表 | P1 |
| US-CK-11 | 团队成员 | 作为成员，我想通过命令面板快速启动一个预定义的 Agent 工作流（如"需求分析→任务拆解→分配执行"），以便一键触发多步自动化 | 输入"启动工作流" → 显示可用工作流列表 → 选择 → 确认参数 → 工作流启动 | P1 |
| US-CK-12 | 团队成员 | 作为成员，我想在命令面板中看到 Agent 推荐的操作（如"代码助手建议：修复 3 个 lint 告警"），以便快速采纳 Agent 的建议 | Agent 推荐以独立分组显示在建议列表中，带 Agent 头像和推荐理由 | P2 |

### 5.4 键盘导航

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-CK-13 | 任何用户 | 作为用户，我想用上/下方向键在搜索结果中导航，用 Enter 选择，用 Esc 关闭面板，全程不用鼠标 | 方向键导航当前选中项高亮移动，Enter 执行选中项操作，Esc 关闭面板 | P0 |
| US-CK-14 | 任何用户 | 作为用户，我想在面板中看到每个操作的快捷键提示（如 "Ctrl+N 创建任务"），以便学习快捷键 | 每条命令右侧显示快捷键标签（如果有），Mac/Windows 自适应显示 | P0 |
| US-CK-15 | 高频用户 | 作为高频用户，我想通过 Tab 键在不同搜索范围之间切换（全部/任务/消息/Agent），以便缩小搜索范围提高精度 | Tab 键循环切换范围 Tab，当前范围高亮显示，搜索结果实时刷新 | P1 |

### 5.5 上下文感知

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-CK-16 | 任何用户 | 作为用户，我想在不同模块打开命令面板时看到不同的默认建议（如在 Tasks 模块优先显示任务相关命令） | 空输入时的建议列表根据当前模块动态调整，当前模块的命令排在最前 | P1 |
| US-CK-17 | 开发者 | 作为开发者，我想在查看某个任务时打开命令面板，自动看到与该任务相关的操作（如"修改状态"、"添加评论"、"分配给..."） | 命令面板检测当前页面上下文（任务 ID），将相关操作置顶 | P1 |
| US-CK-18 | 团队成员 | 作为成员，我想命令面板记住我最常用的命令，并将它们排在建议列表的前面 | 系统追踪命令使用频率，高频命令在同等匹配度下排名更高 | P1 |

---

## 6. 功能拆分

### 6.1 P0 功能（MVP，必须实现）

#### 6.1.1 命令面板基础框架

**唤出与关闭：**
- Cmd+K（Mac）/ Ctrl+K（Windows/Linux）全局快捷键唤出
- Esc 键关闭
- 点击面板外部（Backdrop）关闭
- 再次按 Cmd+K 关闭（Toggle 行为）
- 面板打开时自动聚焦搜索输入框

**面板 UI：**
```
┌─────────────────────────────────────────────────────────┐
│  🔍  搜索任务、命令、成员...               [全部 ▾]     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  最近访问                                               │
│  ──────────                                             │
│  📋 登录模块重构         任务 · 进行中      ⏎           │
│  💬 #产品开发频道         频道 · 12 人       ⏎           │
│  📁 Sprint 23            项目 · 进行中      ⏎           │
│  🤖 代码助手              Agent · 在线       ⏎           │
│                                                         │
│  快速操作                                               │
│  ──────────                                             │
│  ➕ 创建任务                               ⌘N           │
│  ➕ 创建频道                               ⌘⇧C          │
│  ⚙ 打开设置                               ⌘,           │
│                                                         │
│                                                         │
│  ↑↓ 导航  ⏎ 选择  ⎋ 关闭                               │
└─────────────────────────────────────────────────────────┘
```

**搜索输入：**
- 实时搜索（Debounce 150ms）
- 搜索为空时显示"最近访问"和"快速操作"
- 搜索有输入时显示匹配结果
- 支持清空按钮（输入框右侧 × 图标）

#### 6.1.2 全局模糊搜索

**搜索范围：**
- 任务（Module 2）：标题、描述、标签
- 消息（Module 1）：消息内容、发送者名称
- 频道（Module 1）：频道名称、描述
- 项目（Module 3）：项目名称、描述
- 团队成员（Module 4）：人类成员名称、Agent 名称
- Agent（Module 5）：Agent 名称、能力标签
- 设置页面（Module 7/8）：页面标题

**搜索结果展示：**
- 每条结果包含：类型图标 + 名称 + 辅助信息 + 快捷键（如有）
- 结果按分组展示（最近访问 / 任务 / 频道 / 成员 / Agent / 命令）
- 每组最多显示 5 条，底部有"查看全部 N 条"链接
- 匹配关键词高亮（加粗或底色高亮）
- 搜索结果总数显示在顶部

**搜索算法：**
- 前缀匹配（"log" 匹配 "login-module"）
- 子串匹配（"模块" 匹配 "登录模块重构"）
- 模糊匹配（"lgn" 匹配 "login"，容忍编辑距离 ≤ 2）
- 拼音首字母匹配（"dlmk" 匹配 "登录模块"）
- 中文分词匹配（"登录" 匹配 "用户登录模块"）

#### 6.1.3 快速操作

**内置操作：**
- 创建任务（→ Module 2 快速创建表单）
- 创建频道（→ Module 1 频道创建表单）
- 切换频道（→ 直接导航）
- @提及成员（→ 跳转到 DM 或在当前频道插入 @）
- 打开设置（→ 导航到 Module 8）
- 打开管理面板（→ 导航到 Module 7）
- 切换项目（→ 导航到 Module 3 的项目详情）
- 切换暗色/亮色主题

**操作执行：**
- 导航类操作：关闭面板 → 跳转到目标页面
- 创建类操作：面板内嵌入简化表单 → 创建完成 → 关闭面板（或保持打开继续创建）
- 设置类操作：关闭面板 → 跳转到设置页面

#### 6.1.4 最近访问历史

**历史记录：**
- 记录用户最近访问过的实体（任务、频道、项目、成员、Agent、设置页面）
- 最多保留 50 条，按访问时间倒序
- 每次用户通过命令面板或正常导航访问实体时更新
- 历史数据存储在客户端本地（localStorage）+ 服务端持久化（支持跨设备同步）

**展示：**
- 命令面板空输入时，优先展示最近 10 条历史
- 历史项可通过搜索过滤（输入关键词同时匹配历史）
- 历史项支持"固定"（Pin），固定的项始终显示在最前面

#### 6.1.5 键盘导航

**按键映射：**
| 按键 | 操作 |
|------|------|
| Cmd+K / Ctrl+K | 打开/关闭命令面板 |
| ↑ / ↓ | 在结果列表中上下移动选中项 |
| Enter | 执行选中项的操作 |
| Esc | 关闭面板（如有输入，先清空输入） |
| Backspace（输入为空时） | 退出当前搜索范围过滤（如果有的话） |
| Cmd+Backspace | 清空搜索输入 |

### 6.2 P1 功能

#### 6.2.1 Agent 命令

**Agent 操作命令：**
- 在命令面板中搜索 Agent 名称 → 展示该 Agent 的可用命令列表
- 选择命令后，面板进入参数输入模式（如果命令需要参数）
- 参数输入完成后执行命令，面板显示"命令已发送给 [Agent 名称]"
- 支持查看所有 Agent 的当前状态（一览视图）

**Agent 状态查看：**
- 输入"Agent 状态"或 "/agents" → 显示所有团队 Agent 的状态列表
- 每个 Agent 显示：名称、角色、状态（在线/忙碌/离线/异常）、当前任务
- 点击 Agent → 跳转到 Agent 详情页（Module 5）

#### 6.2.2 上下文感知建议

**上下文采集：**
- 当前所在模块（chat / tasks / projects / team / agent / toolbox / admin / settings）
- 当前查看的实体（task_id / channel_id / project_id / agent_id）
- 当前用户角色（admin / member / reviewer）

**建议策略：**
- 当前模块的命令权重 +50%（在 Tasks 模块时，任务相关命令排名提升）
- 当前实体的关联操作置顶（查看任务 #42 时，"修改 #42 状态"排第一）
- 最近使用的命令权重 +30%（用户常用"创建任务"，该命令排名提升）

#### 6.2.3 搜索范围过滤

**范围 Tab：**
- 全部 | 任务 | 消息 | 频道 | 项目 | 成员 | Agent | 命令
- Tab 键循环切换（或鼠标点击）
- 选择范围后搜索结果只显示该类型的实体
- 范围选择器显示在搜索输入框下方

**快捷前缀：**
- `>` 开头 → 只搜索命令（类似 VS Code）
- `@` 开头 → 只搜索成员/Agent
- `#` 开头 → 只搜索频道
- `/` 开头 → 只搜索 Agent 命令

#### 6.2.4 命令使用频率追踪

**追踪数据：**
- 每次命令执行记录：命令 ID、时间、上下文
- 按用户聚合使用频率
- 用于搜索排序的个性化权重

### 6.3 P2 功能

#### 6.3.1 自然语言命令

- 用户输入自然语言意图（"帮我把这个任务分配给代码助手"）
- 系统使用 LLM 解析意图 → 匹配到对应的命令 + 参数
- 显示解析结果让用户确认后执行

#### 6.3.2 Agent 推荐操作

- Agent 基于当前工作上下文主动推荐操作
- 推荐以独立分组显示在命令面板中（"Agent 建议"区域）
- 用户可一键采纳或忽略

#### 6.3.3 自定义快捷键绑定

- 用户可为常用命令绑定自定义快捷键
- 快捷键管理页面（在 Settings 中）
- 冲突检测和提示

---

## 7. 命令注册架构

### 7.1 命令注册接口

命令面板的核心设计原则是**命令由模块提供，面板只负责检索和展示**。每个模块通过统一的 `CommandRegistry` 注册自己的命令。

```typescript
// 命令定义接口
interface Command {
  id: string;                              // 唯一标识，如 "tasks.create"
  module: string;                          // 所属模块，如 "tasks"
  
  // 展示信息
  title: string;                           // 显示名称，如 "创建任务"
  subtitle?: string;                       // 副标题/描述
  icon: string;                            // 图标名称或 URL
  keywords: string[];                      // 搜索关键词（别名、拼音首字母等）
  
  // 分类
  category: 'navigation' | 'action' | 'agent' | 'search' | 'setting';
  entity_type?: string;                    // 关联的实体类型（如 "task", "channel"）
  
  // 命令类型
  command_type: 'human_action' | 'agent_action' | 'hybrid_action';
  agent_id?: string;                       // 仅 agent_action/hybrid_action
  
  // 执行
  handler: CommandHandler;                 // 执行函数
  params_schema?: ParamsSchema;            // 参数 Schema（如果命令需要输入参数）
  
  // 上下文与权限
  context_filter?: ContextFilter;          // 在什么上下文中可用
  permission?: string;                     // 所需权限（如 "tasks.create"）
  
  // 展示控制
  shortcut?: string;                       // 快捷键（如 "⌘N"）
  priority?: number;                       // 基础优先级（0-100，影响默认排序）
  hidden?: boolean;                        // 是否隐藏（条件不满足时）
}

// 命令处理器
type CommandHandler = (params?: Record<string, any>, context?: CommandContext) => 
  | void                                    // 同步执行（如导航）
  | Promise<CommandResult>;                 // 异步执行（如创建实体、调用 Agent）

// 命令执行结果
interface CommandResult {
  success: boolean;
  message?: string;                        // 用户可见的结果消息
  navigate_to?: string;                    // 执行后导航到的页面
  toast?: { type: 'success' | 'error'; message: string };
}

// 命令上下文
interface CommandContext {
  current_module: string;                  // 当前模块
  current_entity?: {                       // 当前查看的实体
    type: string;
    id: string;
  };
  user_id: string;
  user_role: string;
  workspace_id: string;
  team_id?: string;
}

// 上下文过滤器
interface ContextFilter {
  modules?: string[];                      // 仅在这些模块中可用
  entity_types?: string[];                 // 仅在查看这些实体类型时可用
  roles?: string[];                        // 仅这些角色可见
}

// 参数 Schema
interface ParamsSchema {
  fields: ParamField[];
  inline?: boolean;                        // 是否在面板内联输入参数
}

interface ParamField {
  key: string;
  label: string;
  type: 'text' | 'select' | 'entity_picker';
  required: boolean;
  options?: { label: string; value: string }[];   // select 类型
  entity_type?: string;                            // entity_picker 类型
  placeholder?: string;
}
```

### 7.2 命令注册中心 (CommandRegistry)

```typescript
// 命令注册中心（全局单例）
class CommandRegistry {
  private commands: Map<string, Command> = new Map();
  private moduleCommands: Map<string, Set<string>> = new Map();
  
  /**
   * 注册命令
   * 每个模块在初始化时调用此方法注册自己的命令
   */
  register(command: Command): void {
    this.commands.set(command.id, command);
    
    if (!this.moduleCommands.has(command.module)) {
      this.moduleCommands.set(command.module, new Set());
    }
    this.moduleCommands.get(command.module)!.add(command.id);
  }
  
  /**
   * 批量注册
   */
  registerAll(commands: Command[]): void {
    commands.forEach(cmd => this.register(cmd));
  }
  
  /**
   * 注销模块的所有命令（模块卸载时）
   */
  unregisterModule(module: string): void {
    const commandIds = this.moduleCommands.get(module);
    if (commandIds) {
      commandIds.forEach(id => this.commands.delete(id));
      this.moduleCommands.delete(module);
    }
  }
  
  /**
   * 搜索命令
   * query: 搜索关键词
   * context: 当前上下文（影响过滤和排序）
   * options: 搜索选项
   */
  search(
    query: string,
    context: CommandContext,
    options?: { category?: string; limit?: number }
  ): ScoredCommand[] {
    const candidates = this.getVisibleCommands(context);
    
    if (!query) {
      // 空查询：返回最近使用 + 推荐命令
      return this.getDefaultSuggestions(candidates, context, options?.limit ?? 10);
    }
    
    // 模糊匹配 + 评分
    return candidates
      .map(cmd => ({
        command: cmd,
        score: this.calculateScore(cmd, query, context)
      }))
      .filter(item => item.score > 0)
      .sort((a, b) => b.score - a.score)
      .slice(0, options?.limit ?? 20);
  }
  
  /**
   * 获取当前上下文中可见的命令
   */
  private getVisibleCommands(context: CommandContext): Command[] {
    return Array.from(this.commands.values()).filter(cmd => {
      if (cmd.hidden) return false;
      if (cmd.context_filter) {
        if (cmd.context_filter.modules && 
            !cmd.context_filter.modules.includes(context.current_module)) {
          return false;
        }
        if (cmd.context_filter.roles && 
            !cmd.context_filter.roles.includes(context.user_role)) {
          return false;
        }
      }
      return true;
    });
  }
  
  /**
   * 计算命令与查询的匹配评分
   */
  private calculateScore(cmd: Command, query: string, context: CommandContext): number {
    let score = 0;
    const q = query.toLowerCase();
    
    // 标题精确匹配（最高分）
    if (cmd.title.toLowerCase() === q) score += 100;
    // 标题前缀匹配
    else if (cmd.title.toLowerCase().startsWith(q)) score += 80;
    // 标题子串匹配
    else if (cmd.title.toLowerCase().includes(q)) score += 60;
    
    // 关键词匹配
    for (const keyword of cmd.keywords) {
      if (keyword.toLowerCase().includes(q)) {
        score += 40;
        break;
      }
    }
    
    // 模糊匹配（编辑距离）
    if (score === 0) {
      const distance = this.fuzzyMatch(cmd.title.toLowerCase(), q);
      if (distance <= 2) score += 30 - distance * 10;
    }
    
    // 上下文加分
    if (cmd.module === context.current_module) score += 20;
    
    // 基础优先级
    score += (cmd.priority ?? 50) * 0.1;
    
    return score;
  }
  
  private fuzzyMatch(target: string, query: string): number {
    // Levenshtein 距离计算（简化版）
    // 实际实现使用 fuse.js 或自定义 trigram 匹配
    return levenshteinDistance(target, query);
  }
  
  private getDefaultSuggestions(
    commands: Command[], 
    context: CommandContext,
    limit: number
  ): ScoredCommand[] {
    // 按优先级 + 上下文相关性返回默认建议
    return commands
      .map(cmd => ({
        command: cmd,
        score: (cmd.module === context.current_module ? 50 : 0) + (cmd.priority ?? 50)
      }))
      .sort((a, b) => b.score - a.score)
      .slice(0, limit);
  }
}

interface ScoredCommand {
  command: Command;
  score: number;
}
```

### 7.3 各模块命令注册示例

#### 7.3.1 Module 1 (Chat) 命令注册

```typescript
// modules/chat/commands.ts
export function registerChatCommands(registry: CommandRegistry) {
  registry.registerAll([
    {
      id: 'chat.switch_channel',
      module: 'chat',
      title: '切换频道',
      subtitle: '快速切换到另一个聊天频道',
      icon: 'message-circle',
      keywords: ['频道', '切换', 'channel', 'switch', 'qd', 'qhpd'],
      category: 'navigation',
      entity_type: 'channel',
      command_type: 'human_action',
      shortcut: '⌘⇧C',
      priority: 80,
      handler: async (params) => {
        router.push(`/chat/channels/${params?.channel_id}`);
      },
      params_schema: {
        inline: true,
        fields: [{
          key: 'channel_id',
          label: '频道',
          type: 'entity_picker',
          entity_type: 'channel',
          required: true,
          placeholder: '搜索频道名称...'
        }]
      }
    },
    {
      id: 'chat.create_channel',
      module: 'chat',
      title: '创建频道',
      subtitle: '创建一个新的聊天频道',
      icon: 'plus-circle',
      keywords: ['新建频道', '创建频道', 'create channel', 'xjpd', 'cjpd'],
      category: 'action',
      command_type: 'human_action',
      permission: 'chat.channel.create',
      priority: 70,
      handler: async () => {
        openModal('CreateChannelModal');
      }
    },
    {
      id: 'chat.search_messages',
      module: 'chat',
      title: '搜索消息',
      subtitle: '在所有频道中搜索消息内容',
      icon: 'search',
      keywords: ['搜索', '查找消息', 'search messages', 'ssxx'],
      category: 'search',
      command_type: 'human_action',
      priority: 60,
      handler: async (params) => {
        router.push(`/chat/search?q=${params?.query}`);
      }
    },
    {
      id: 'chat.mention_member',
      module: 'chat',
      title: '@提及成员',
      subtitle: '在当前频道 @某个成员或 Agent',
      icon: 'at-sign',
      keywords: ['提及', '@', 'mention', 'at', 'tj'],
      category: 'action',
      command_type: 'human_action',
      context_filter: { modules: ['chat'] },
      priority: 65,
      handler: async (params) => {
        insertMention(params?.member_id);
      }
    }
  ]);
}
```

#### 7.3.2 Module 2 (Tasks) 命令注册

```typescript
// modules/tasks/commands.ts
export function registerTaskCommands(registry: CommandRegistry) {
  registry.registerAll([
    {
      id: 'tasks.create',
      module: 'tasks',
      title: '创建任务',
      subtitle: '快速创建一个新任务',
      icon: 'plus-square',
      keywords: ['新建任务', '新任务', 'create task', 'new task', 'xjrw', 'cjrw'],
      category: 'action',
      command_type: 'human_action',
      shortcut: '⌘N',
      permission: 'tasks.create',
      priority: 90,
      handler: async (params) => {
        const result = await createTask({ title: params?.title });
        return {
          success: true,
          message: `任务"${result.title}"创建成功`,
          navigate_to: `/tasks/${result.id}`,
          toast: { type: 'success', message: '任务创建成功' }
        };
      },
      params_schema: {
        inline: true,
        fields: [{
          key: 'title',
          label: '任务标题',
          type: 'text',
          required: true,
          placeholder: '输入任务标题后回车创建...'
        }]
      }
    },
    {
      id: 'tasks.search',
      module: 'tasks',
      title: '搜索任务',
      subtitle: '按名称或标签搜索任务',
      icon: 'search',
      keywords: ['查找任务', '搜索', 'search task', 'ssrw'],
      category: 'search',
      command_type: 'human_action',
      priority: 85,
      handler: async (params) => {
        router.push(`/tasks?search=${params?.query}`);
      }
    },
    {
      id: 'tasks.assign_to_agent',
      module: 'tasks',
      title: '将任务分配给 Agent',
      subtitle: '选择一个任务并分配给 Agent 执行',
      icon: 'user-plus',
      keywords: ['分配', 'Agent', 'assign', 'fp', 'fprw'],
      category: 'action',
      command_type: 'hybrid_action',
      context_filter: { entity_types: ['task'] },
      priority: 75,
      handler: async (params, context) => {
        await assignTask(context?.current_entity?.id, params?.agent_id);
        return {
          success: true,
          toast: { type: 'success', message: `任务已分配给 ${params?.agent_name}` }
        };
      },
      params_schema: {
        inline: true,
        fields: [{
          key: 'agent_id',
          label: 'Agent',
          type: 'entity_picker',
          entity_type: 'agent',
          required: true,
          placeholder: '选择 Agent...'
        }]
      }
    }
  ]);
}
```

#### 7.3.3 Module 5 (Agent) 命令注册

```typescript
// modules/agent/commands.ts
export function registerAgentCommands(registry: CommandRegistry) {
  registry.registerAll([
    {
      id: 'agent.status_overview',
      module: 'agent',
      title: 'Agent 状态总览',
      subtitle: '查看所有 Agent 的当前状态',
      icon: 'activity',
      keywords: ['Agent 状态', 'Agent status', 'agentzl', '状态'],
      category: 'navigation',
      command_type: 'human_action',
      priority: 70,
      handler: async () => {
        router.push('/agents?view=status');
      }
    },
    {
      id: 'agent.invoke_codebot',
      module: 'agent',
      title: '调用代码助手',
      subtitle: '让代码助手执行操作',
      icon: 'terminal',
      keywords: ['代码助手', '代码 Agent', 'codebot', 'dyzs'],
      category: 'agent',
      command_type: 'agent_action',
      agent_id: 'agent_codebot',
      priority: 80,
      handler: async (params) => {
        const result = await invokeAgent('agent_codebot', {
          action: params?.action,
          target: params?.target
        });
        return {
          success: true,
          message: `命令已发送给代码助手`,
          toast: { type: 'success', message: '代码助手正在执行...' }
        };
      },
      params_schema: {
        inline: true,
        fields: [
          {
            key: 'action',
            label: '操作',
            type: 'select',
            required: true,
            options: [
              { label: '修复 Bug', value: 'fix_bug' },
              { label: '代码审查', value: 'code_review' },
              { label: '编写测试', value: 'write_tests' },
              { label: '重构代码', value: 'refactor' }
            ]
          },
          {
            key: 'target',
            label: '目标',
            type: 'text',
            required: false,
            placeholder: '描述目标（如 Issue 编号）...'
          }
        ]
      }
    },
    {
      id: 'agent.start_workflow',
      module: 'agent',
      title: '启动工作流',
      subtitle: '启动一个预定义的 Agent 工作流',
      icon: 'git-branch',
      keywords: ['工作流', 'workflow', 'gzl', '自动化'],
      category: 'agent',
      command_type: 'agent_action',
      priority: 65,
      handler: async (params) => {
        await startWorkflow(params?.workflow_id);
        return {
          success: true,
          toast: { type: 'success', message: '工作流已启动' }
        };
      }
    }
  ]);
}
```

### 7.4 命令注册生命周期

```
应用启动流程：
  1. App 初始化
  2. CommandRegistry 单例创建
  3. 各模块按序初始化：
     Module 1 → registerChatCommands(registry)
     Module 2 → registerTaskCommands(registry)
     Module 3 → registerProjectCommands(registry)
     Module 4 → registerTeamCommands(registry)
     Module 5 → registerAgentCommands(registry)
     Module 6 → registerToolboxCommands(registry)
     Module 7 → registerAdminCommands(registry)
     Module 8 → registerSettingsCommands(registry)
  4. CommandPalette 组件绑定 registry
  5. Cmd+K 快捷键注册

动态命令注册：
  - Agent 被添加到团队 → 动态注册该 Agent 的命令
  - Agent 被移除 → 注销该 Agent 的命令
  - 工作流创建/删除 → 动态注册/注销工作流命令
  - 用户权限变更 → 命令可见性实时更新（通过 context_filter 检查）

模块卸载：
  - Module 卸载时调用 registry.unregisterModule(module)
  - 清除该模块所有命令
  - 命令面板搜索结果实时反映
```

### 7.5 命令注册约定

为保证各模块注册的命令一致性和可维护性，约定如下：

| 规则 | 说明 |
|------|------|
| ID 命名 | `{module}.{action}`，如 `tasks.create`、`chat.switch_channel` |
| keywords 包含拼音首字母 | 中文名称的拼音首字母必须在 keywords 中（如 "创建任务" → "cjrw"） |
| icon 使用统一图标库 | 使用 Lucide Icons 的图标名称 |
| priority 范围 0-100 | 0 = 最低优先级，100 = 最高优先级。跨模块通用命令（如创建任务）90+，模块内命令 60-80，设置类 40-60 |
| permission 对齐 RBAC | 命令的 permission 字段使用与 Module 4 Permission Engine 相同的 action 标识符 |
| handler 必须返回 CommandResult | 异步命令必须返回结果对象，用于面板内的反馈展示 |

---

## 8. 搜索引擎

### 8.1 搜索架构概览

```
用户输入 "登录"
    │
    ▼
┌─────────────┐
│  Debounce   │  150ms 去抖
│  Controller │  新输入取消旧请求
└──────┬──────┘
       │
       ▼
┌──────────────────┐
│  Search Router   │  根据前缀分流：
│                  │    > → 命令搜索
│                  │    @ → 成员搜索
│                  │    # → 频道搜索
│                  │    / → Agent 命令搜索
│                  │    其他 → 全局搜索
└──────┬───────────┘
       │
       ▼
┌──────────────────────────────────────────────┐
│              Search Engine                    │
│                                              │
│  ┌─────────────────┐  ┌──────────────────┐  │
│  │ Command Search  │  │  Entity Search   │  │
│  │ (本地内存)       │  │  (API + 缓存)    │  │
│  │                 │  │                  │  │
│  │ CommandRegistry │  │  search_index 表  │  │
│  │ .search()       │  │  + pg_trgm      │  │
│  └────────┬────────┘  └────────┬─────────┘  │
│           │                    │             │
│           └────────┬───────────┘             │
│                    │                         │
│            ┌───────┴──────┐                  │
│            │ Result Merger │                  │
│            │ & Ranker      │                  │
│            └───────┬──────┘                  │
│                    │                         │
└────────────────────┼─────────────────────────┘
                     │
                     ▼
            ┌────────────────┐
            │  Search Results │
            │  (分组 + 排序)  │
            └────────────────┘
```

### 8.2 搜索索引设计

命令面板的实体搜索不直接查询各模块的业务表，而是通过一个**统一的搜索索引表**（`search_index`）进行检索。这是为了：

1. **性能**：单表查询 + GIN 索引比跨表 JOIN 快 10x
2. **一致性**：搜索结果的展示格式统一
3. **解耦**：搜索引擎不依赖各模块的表结构变化

```
索引同步流程：
  Module 1 创建消息 → Event: message.created → Search Indexer → search_index INSERT
  Module 2 创建任务 → Event: task.created → Search Indexer → search_index INSERT
  Module 2 更新任务标题 → Event: task.updated → Search Indexer → search_index UPDATE
  Module 2 删除任务 → Event: task.deleted → Search Indexer → search_index DELETE
  ...各模块的实体变更都通过 Event Bus 同步到 search_index
```

### 8.3 模糊匹配算法

#### 8.3.1 匹配策略分层

```
查询 "lgn" 的匹配过程：

Layer 1: 精确前缀匹配（最高优先级）
  "lgn" → 无直接前缀匹配

Layer 2: 包含匹配
  "lgn" → 无直接包含匹配

Layer 3: 拼音首字母匹配
  "lgn" → 拼音数据库映射 → "登录" (dlgn 的子串匹配? 否)
  → 不匹配

Layer 4: Trigram 模糊匹配（pg_trgm）
  "lgn" → trigram: {"lgn"}
  "login-module" → trigrams: {"log", "ogi", "gin", ...}
  相似度 = trigram 交集 / trigram 并集 → 0.15（超过阈值 0.1）
  → 匹配，得分 0.15

Layer 5: 编辑距离（Levenshtein）
  "lgn" vs "login" → 编辑距离 2
  "lgn" vs "lng" → 编辑距离 1
  容忍 ≤ 2 → 匹配
```

#### 8.3.2 中文搜索优化

```
中文搜索特殊处理：

1. 拼音首字母索引
   "登录模块" → 拼音首字母 "dlmk"
   索引表存储 pinyin_initials 字段
   查询 "dlmk" → 精确匹配 pinyin_initials

2. 中文分词
   "登录模块重构" → 分词结果 ["登录", "模块", "重构"]
   查询 "登录" → 匹配分词 "登录"
   查询 "重构" → 匹配分词 "重构"

3. 全拼匹配
   "denglu" → 转换为 "登录"
   索引表存储 pinyin_full 字段
   查询 "denglu" → 匹配 pinyin_full
```

### 8.4 搜索结果排序算法

```
综合评分 = 匹配分 × 0.4 + 时效分 × 0.2 + 上下文分 × 0.25 + 频率分 × 0.15

匹配分 (0-100):
  精确匹配标题     = 100
  前缀匹配标题     = 80
  子串匹配标题     = 60
  关键词匹配       = 50
  拼音首字母匹配   = 45
  Trigram 匹配     = similarity × 100 (通常 15-40)
  编辑距离匹配     = max(0, 30 - distance × 10)

时效分 (0-100):
  最近 1 小时内更新   = 100
  最近 24 小时内更新  = 80
  最近 7 天内更新     = 60
  最近 30 天内更新    = 40
  更早               = 20

上下文分 (0-100):
  当前模块的实体       = 100
  当前查看实体的关联实体 = 80
  最近访问过的实体      = 60
  同一项目的实体        = 40
  其他                 = 0

频率分 (0-100):
  过去 7 天内访问 10+ 次 = 100
  过去 7 天内访问 5-9 次 = 70
  过去 7 天内访问 1-4 次 = 40
  未访问过              = 0
```

### 8.5 搜索性能优化

| 策略 | 说明 |
|------|------|
| 客户端去抖 | 150ms Debounce，避免每次按键都触发 API 请求 |
| 请求取消 | 新搜索请求自动取消上一个未完成的请求（AbortController） |
| 本地命令搜索 | 命令搜索在客户端内存中完成（CommandRegistry），不需要 API 请求 |
| 实体搜索缓存 | 热门查询结果 Redis 缓存 30 秒 |
| 分页搜索 | 首次只返回每类 5 条结果，"查看全部"时加载更多 |
| 索引预热 | 应用启动时预加载 search_index 到 Redis |
| 异步索引更新 | 实体变更通过 Event Bus 异步更新 search_index，不阻塞主流程 |
| GIN 索引 | PostgreSQL pg_trgm + GIN 索引加速模糊查询 |
| 拼音预计算 | 实体入索引时预计算拼音首字母和全拼，存储为独立字段 |

---

## 9. 数据模型

### 9.1 命令注册表（系统配置）

```sql
-- 命令注册表（存储各模块注册的静态命令——备份/审计用）
-- 注意：运行时的命令注册在前端内存中（CommandRegistry），此表用于持久化和管理后台
CREATE TABLE command_registry (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- 命令标识
  command_id VARCHAR(100) NOT NULL UNIQUE,     -- 如 "tasks.create"
  module VARCHAR(50) NOT NULL,                 -- 所属模块
  
  -- 展示信息
  title VARCHAR(200) NOT NULL,                 -- 显示名称
  subtitle VARCHAR(500),                       -- 副标题
  icon VARCHAR(100),                           -- 图标
  keywords JSONB DEFAULT '[]',                 -- 搜索关键词数组
  
  -- 分类
  category VARCHAR(20) NOT NULL
    CHECK (category IN ('navigation', 'action', 'agent', 'search', 'setting')),
  entity_type VARCHAR(50),                     -- 关联实体类型
  
  -- 命令类型
  command_type VARCHAR(20) NOT NULL
    CHECK (command_type IN ('human_action', 'agent_action', 'hybrid_action')),
  agent_id UUID,                               -- agent_action 时关联的 Agent
  
  -- 权限
  permission VARCHAR(100),                     -- 所需权限
  
  -- 展示控制
  shortcut VARCHAR(50),                        -- 快捷键
  priority INTEGER DEFAULT 50
    CHECK (priority >= 0 AND priority <= 100),
  is_active BOOLEAN DEFAULT TRUE,
  
  -- 参数 Schema（JSON）
  params_schema JSONB,
  
  -- 上下文过滤（JSON）
  context_filter JSONB,
  
  -- 审计
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_command_registry_module ON command_registry(module);
CREATE INDEX idx_command_registry_category ON command_registry(category);
CREATE INDEX idx_command_registry_active ON command_registry(is_active) WHERE is_active = TRUE;
```

### 9.2 搜索索引表

```sql
-- 统一搜索索引表
-- 各模块的可搜索实体同步到此表，命令面板搜索时查询此表
CREATE TABLE search_index (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- 实体标识
  entity_id UUID NOT NULL,                     -- 原始实体 ID
  entity_type VARCHAR(50) NOT NULL,            -- 实体类型：task, message, channel, project, member, agent, setting_page
  module VARCHAR(50) NOT NULL,                 -- 来源模块
  workspace_id UUID NOT NULL,
  
  -- 搜索内容
  title VARCHAR(500) NOT NULL,                 -- 主标题（如任务名、频道名、成员名）
  subtitle VARCHAR(500),                       -- 副标题（如任务状态、频道描述）
  content TEXT,                                -- 全文内容（如消息内容、任务描述）
  
  -- 中文搜索优化
  pinyin_initials VARCHAR(200),                -- 拼音首字母（如 "dlmk" 对应 "登录模块"）
  pinyin_full VARCHAR(500),                    -- 全拼（如 "denglumokuai"）
  
  -- 搜索向量（PostgreSQL tsvector）
  search_vector TSVECTOR,                      -- 全文搜索向量
  
  -- Trigram 索引字段（组合 title + subtitle 用于 pg_trgm 模糊匹配）
  trigram_text VARCHAR(1000),
  
  -- 展示信息
  icon VARCHAR(100),                           -- 结果显示的图标
  metadata JSONB DEFAULT '{}',                 -- 额外的展示数据（如状态、成员数）
  
  -- 导航
  navigate_url VARCHAR(500),                   -- 点击后导航的 URL
  
  -- 排序因子
  last_activity_at TIMESTAMPTZ,                -- 最近活跃时间（用于时效分排序）
  
  -- 权限
  visibility VARCHAR(20) DEFAULT 'workspace'
    CHECK (visibility IN ('workspace', 'team', 'private')),
  team_id UUID,                                -- team 可见性时的团队 ID
  owner_id UUID,                               -- private 可见性时的所有者 ID
  
  -- 状态
  is_active BOOLEAN DEFAULT TRUE,              -- 软删除标记
  
  -- 时间
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- 唯一约束：同一实体只有一条索引
  UNIQUE(entity_id, entity_type)
);

-- 核心索引
-- pg_trgm GIN 索引，支持模糊搜索
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_search_trgm_title ON search_index USING GIN (trigram_text gin_trgm_ops);

-- 全文搜索索引
CREATE INDEX idx_search_vector ON search_index USING GIN (search_vector);

-- 拼音首字母索引
CREATE INDEX idx_search_pinyin ON search_index USING GIN (pinyin_initials gin_trgm_ops);

-- 常规索引
CREATE INDEX idx_search_workspace ON search_index(workspace_id, entity_type) WHERE is_active = TRUE;
CREATE INDEX idx_search_module ON search_index(module) WHERE is_active = TRUE;
CREATE INDEX idx_search_activity ON search_index(workspace_id, last_activity_at DESC) WHERE is_active = TRUE;
CREATE INDEX idx_search_team ON search_index(team_id) WHERE team_id IS NOT NULL AND is_active = TRUE;
```

### 9.3 最近命令/访问记录表

```sql
-- 用户最近访问/执行记录（服务端持久化，支持跨设备同步）
CREATE TABLE recent_commands (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- 用户
  user_id UUID NOT NULL,
  workspace_id UUID NOT NULL,
  
  -- 访问的实体或执行的命令
  item_type VARCHAR(20) NOT NULL
    CHECK (item_type IN ('entity', 'command')),
  
  -- 实体访问（item_type = 'entity'）
  entity_id UUID,
  entity_type VARCHAR(50),
  
  -- 命令执行（item_type = 'command'）
  command_id VARCHAR(100),
  
  -- 展示信息（快照，避免反查）
  title VARCHAR(500) NOT NULL,
  subtitle VARCHAR(500),
  icon VARCHAR(100),
  navigate_url VARCHAR(500),
  
  -- 固定（Pin）
  is_pinned BOOLEAN DEFAULT FALSE,
  pinned_at TIMESTAMPTZ,
  
  -- 时间
  accessed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- 每个用户最多 50 条（应用层控制，超过则删除最旧的）
  CONSTRAINT unique_user_entity UNIQUE (user_id, workspace_id, entity_id, entity_type),
  CONSTRAINT unique_user_command UNIQUE (user_id, workspace_id, command_id)
);

-- 索引
CREATE INDEX idx_recent_user ON recent_commands(user_id, workspace_id, accessed_at DESC);
CREATE INDEX idx_recent_pinned ON recent_commands(user_id, workspace_id, is_pinned) 
  WHERE is_pinned = TRUE;
```

### 9.4 命令快捷键绑定表

```sql
-- 用户自定义快捷键绑定（P2 功能）
CREATE TABLE command_shortcuts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- 用户
  user_id UUID NOT NULL,
  workspace_id UUID NOT NULL,
  
  -- 绑定
  command_id VARCHAR(100) NOT NULL,            -- 命令 ID
  shortcut VARCHAR(50) NOT NULL,               -- 快捷键组合（如 "Ctrl+Shift+T"）
  
  -- 平台
  platform VARCHAR(10) NOT NULL DEFAULT 'all'
    CHECK (platform IN ('mac', 'windows', 'linux', 'all')),
  
  -- 状态
  is_active BOOLEAN DEFAULT TRUE,
  
  -- 时间
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- 唯一约束：同一用户在同一平台上，快捷键不能重复
  UNIQUE(user_id, workspace_id, shortcut, platform)
);

-- 索引
CREATE INDEX idx_shortcuts_user ON command_shortcuts(user_id, workspace_id) WHERE is_active = TRUE;
```

### 9.5 命令使用统计表

```sql
-- 命令使用频率统计（用于个性化排序）
CREATE TABLE command_usage_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- 用户
  user_id UUID NOT NULL,
  workspace_id UUID NOT NULL,
  
  -- 命令或实体
  item_type VARCHAR(20) NOT NULL
    CHECK (item_type IN ('command', 'entity')),
  command_id VARCHAR(100),                     -- 命令使用
  entity_id UUID,                              -- 实体访问
  entity_type VARCHAR(50),
  
  -- 统计（滚动窗口）
  use_count_7d INTEGER DEFAULT 0,              -- 过去 7 天使用次数
  use_count_30d INTEGER DEFAULT 0,             -- 过去 30 天使用次数
  use_count_total INTEGER DEFAULT 0,           -- 总使用次数
  
  -- 时间
  last_used_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- 唯一约束
  UNIQUE(user_id, workspace_id, item_type, command_id, entity_id, entity_type)
);

-- 索引
CREATE INDEX idx_usage_user ON command_usage_stats(user_id, workspace_id, item_type);
CREATE INDEX idx_usage_frequency ON command_usage_stats(user_id, workspace_id, use_count_7d DESC);
```

### 9.6 ER 关系图

```
command_registry
  │  （系统级：存储所有模块注册的命令定义）
  │
  ├── command_shortcuts (用户自定义快捷键绑定)
  │     └── user_id → users.id
  │
  └── command_usage_stats (命令使用频率统计)
        └── user_id → users.id

search_index
  │  （搜索索引：各模块实体的搜索快照）
  │
  ├── entity_id → tasks.id / messages.id / channels.id / projects.id / agents.id / users.id
  │               （多态关联，通过 entity_type 区分）
  │
  └── workspace_id → workspaces.id

recent_commands
  │  （用户最近访问/命令执行记录）
  │
  ├── user_id → users.id
  ├── entity_id → search_index.entity_id（可选）
  └── command_id → command_registry.command_id（可选）

外部关联：
  search_index.entity_id → tasks.id (Module 2, entity_type = 'task')
  search_index.entity_id → messages.id (Module 1, entity_type = 'message')
  search_index.entity_id → channels.id (Module 1, entity_type = 'channel')
  search_index.entity_id → projects.id (Module 3, entity_type = 'project')
  search_index.entity_id → agents.id (Module 5, entity_type = 'agent')
  search_index.entity_id → users.id (Module 4, entity_type = 'member')
```

### 9.7 与现有模块的数据关系

**与 Module 1 (Chat) 的关系：**
- 频道创建/更新/删除 → 同步到 search_index（entity_type = 'channel'）
- 消息创建/编辑/删除 → 同步到 search_index（entity_type = 'message'）
- 消息搜索可复用 Chat 模块现有的全文搜索，search_index 只索引标题级信息

**与 Module 2 (Tasks) 的关系：**
- 任务创建/更新/删除 → 同步到 search_index（entity_type = 'task'）
- 命令面板中"创建任务"直接调用 Module 2 的 API
- 任务状态变更反映在搜索结果的 metadata 中

**与 Module 3 (Projects) 的关系：**
- 项目创建/更新/删除 → 同步到 search_index（entity_type = 'project'）
- 命令面板中"切换项目"导航到 Module 3 页面

**与 Module 4 (Team) 的关系：**
- 成员变更 → 同步到 search_index（entity_type = 'member'）
- Agent 角色权限通过 Permission Engine 检查——命令面板中的 Agent 命令受权限约束

**与 Module 5 (Agent) 的关系：**
- Agent 创建/更新/删除 → 同步到 search_index（entity_type = 'agent'）
- Agent 命令执行通过 Module 5 的 Agent Invocation API
- Agent 状态变更实时反映在搜索结果和 Agent 命令列表中

---

## 10. 技术方案

### 10.1 整体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                          客户端层                                    │
│  Web (Next.js + TailwindCSS)                                        │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                  CommandPalette 组件                          │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌──────────────────────┐  │   │
│  │  │ SearchInput  │ │ ScopeFilter │ │ KeyboardNavigator    │  │   │
│  │  └──────┬──────┘ └──────┬──────┘ └──────────┬───────────┘  │   │
│  │         │               │                    │              │   │
│  │  ┌──────┴───────────────┴────────────────────┴──────────┐  │   │
│  │  │              SearchEngine (客户端)                      │  │   │
│  │  │  ┌─────────────────┐  ┌──────────────────┐          │  │   │
│  │  │  │ CommandRegistry │  │ EntitySearchAPI  │          │  │   │
│  │  │  │ (本地内存搜索)    │  │ (API 调用)       │          │  │   │
│  │  │  └─────────────────┘  └──────────────────┘          │  │   │
│  │  └──────────────────────────────────────────────────────┘  │   │
│  │  ┌──────────────────────────────────────────────────────┐  │   │
│  │  │              ResultList 组件                           │  │   │
│  │  │  ┌──────────┐ ┌──────────┐ ┌──────────┐            │  │   │
│  │  │  │ 最近访问  │ │ 实体结果  │ │ 命令结果  │            │  │   │
│  │  │  └──────────┘ └──────────┘ └──────────┘            │  │   │
│  │  └──────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  CommandRegistry (全局单例，各模块注册命令)                             │
│  ContextProvider (提供当前模块/实体/用户上下文)                          │
└───────────────────────┬─────────────────────────────────────────────┘
                        │ REST API
┌───────────────────────┴─────────────────────────────────────────────┐
│                        API Gateway                                   │
│  JWT Auth │ Rate Limiting                                            │
└───────────────────────┬─────────────────────────────────────────────┘
                        │
┌───────────────────────┴─────────────────────────────────────────────┐
│                        服务层                                        │
│                                                                      │
│  Search Service ──── Index Sync Worker ──── Recent Service          │
│       │                    │                       │                  │
│       │              Event Bus                     │                  │
│       │           (Redis Streams)                  │                  │
│       │                    │                       │                  │
│  ┌────┴────────────────────┴───────────────────────┴──────┐         │
│  │                  数据层                                  │         │
│  │  PostgreSQL 16                                          │         │
│  │  (search_index + pg_trgm,                               │         │
│  │   recent_commands, command_usage_stats)                  │         │
│  │                                                         │         │
│  │  Redis 7                                                │         │
│  │  (search result cache, recent items cache)              │         │
│  └─────────────────────────────────────────────────────────┘         │
└─────────────────────────────────────────────────────────────────────┘
```

### 10.2 API 设计

#### RESTful API

```
# 全局搜索
GET    /api/v1/search                                # 全局模糊搜索
       ?q=登录                                       # 搜索关键词
       &types=task,channel,agent                      # 实体类型过滤（可选）
       &scope=workspace                               # 搜索范围
       &limit=20                                      # 每类最大结果数
       &workspace_id=xxx

# 最近访问
GET    /api/v1/users/me/recent                       # 获取最近访问列表
POST   /api/v1/users/me/recent                       # 记录一次访问
DELETE /api/v1/users/me/recent/:id                   # 删除某条历史
PATCH  /api/v1/users/me/recent/:id/pin               # 固定/取消固定

# 命令使用统计
POST   /api/v1/commands/usage                        # 记录命令使用
GET    /api/v1/commands/usage/top                    # 获取用户最常用命令

# 搜索索引管理（内部 API，不对外暴露）
POST   /api/internal/search-index                    # 添加/更新索引
DELETE /api/internal/search-index/:entity_type/:entity_id  # 删除索引
POST   /api/internal/search-index/reindex            # 全量重建索引
```

#### 请求/响应示例

**全局搜索：**

```typescript
// GET /api/v1/search?q=登录&workspace_id=ws_001
// Response 200
{
  "query": "登录",
  "results": {
    "tasks": {
      "items": [
        {
          "entity_id": "task_001",
          "entity_type": "task",
          "title": "登录模块重构",
          "subtitle": "进行中 · Sprint 23",
          "icon": "check-square",
          "navigate_url": "/tasks/task_001",
          "metadata": { "status": "in_progress", "assignee": "代码助手" },
          "score": 92.5,
          "highlight": { "title": "<mark>登录</mark>模块重构" }
        },
        {
          "entity_id": "task_042",
          "entity_type": "task",
          "title": "修复登录页面 CSS 问题",
          "subtitle": "待办 · Sprint 23",
          "icon": "check-square",
          "navigate_url": "/tasks/task_042",
          "metadata": { "status": "todo" },
          "score": 88.0,
          "highlight": { "title": "修复<mark>登录</mark>页面 CSS 问题" }
        }
      ],
      "total": 5,
      "has_more": true
    },
    "messages": {
      "items": [
        {
          "entity_id": "msg_123",
          "entity_type": "message",
          "title": "登录接口的认证流程需要改一下",
          "subtitle": "#产品开发频道 · 张伟 · 2 小时前",
          "icon": "message-circle",
          "navigate_url": "/chat/channels/ch_001?msg=msg_123",
          "score": 75.0,
          "highlight": { "title": "<mark>登录</mark>接口的认证流程需要改一下" }
        }
      ],
      "total": 3,
      "has_more": false
    },
    "channels": {
      "items": [],
      "total": 0,
      "has_more": false
    },
    "members": {
      "items": [],
      "total": 0,
      "has_more": false
    },
    "agents": {
      "items": [],
      "total": 0,
      "has_more": false
    }
  },
  "total_results": 8,
  "took_ms": 32
}
```

**最近访问：**

```typescript
// GET /api/v1/users/me/recent?workspace_id=ws_001&limit=10
// Response 200
{
  "items": [
    {
      "id": "rec_001",
      "item_type": "entity",
      "entity_id": "task_001",
      "entity_type": "task",
      "title": "登录模块重构",
      "subtitle": "进行中 · Sprint 23",
      "icon": "check-square",
      "navigate_url": "/tasks/task_001",
      "is_pinned": true,
      "accessed_at": "2026-04-20T09:30:00Z"
    },
    {
      "id": "rec_002",
      "item_type": "entity",
      "entity_id": "ch_001",
      "entity_type": "channel",
      "title": "#产品开发频道",
      "subtitle": "12 位成员",
      "icon": "message-circle",
      "navigate_url": "/chat/channels/ch_001",
      "is_pinned": false,
      "accessed_at": "2026-04-20T09:15:00Z"
    },
    {
      "id": "rec_003",
      "item_type": "command",
      "command_id": "tasks.create",
      "title": "创建任务",
      "subtitle": "快速创建一个新任务",
      "icon": "plus-square",
      "is_pinned": false,
      "accessed_at": "2026-04-20T09:00:00Z"
    }
  ],
  "total": 10
}
```

### 10.3 前端架构

```
components/
  command-palette/
    CommandPalette.tsx              # 命令面板主组件（Modal）
    CommandPaletteProvider.tsx      # Context Provider（全局状态管理）
    
    search/
      SearchInput.tsx              # 搜索输入框
      ScopeFilter.tsx              # 搜索范围过滤 Tab
      SearchEngine.ts              # 搜索引擎（合并本地命令搜索和 API 实体搜索）
      
    results/
      ResultList.tsx               # 搜索结果列表
      ResultGroup.tsx              # 结果分组（如"任务"、"频道"、"Agent"）
      ResultItem.tsx               # 单条结果项
      EmptyState.tsx               # 空状态/无结果
      
    recent/
      RecentList.tsx               # 最近访问列表
      RecentItem.tsx               # 最近访问项
      PinButton.tsx                # 固定按钮
      
    keyboard/
      KeyboardNavigator.tsx        # 键盘导航管理
      ShortcutBadge.tsx            # 快捷键标签
      KeyboardHintBar.tsx          # 底部键盘提示栏
      
    actions/
      QuickCreateForm.tsx          # 面板内快速创建表单
      AgentCommandPanel.tsx        # Agent 命令参数面板
      CommandExecutor.ts           # 命令执行器
      
    hooks/
      useCommandPalette.ts         # 命令面板状态 Hook
      useSearch.ts                 # 搜索 Hook（去抖、取消、缓存）
      useRecentItems.ts            # 最近访问 Hook
      useKeyboardNav.ts            # 键盘导航 Hook
      useCommandRegistry.ts        # 命令注册 Hook
      
lib/
  command-registry/
    CommandRegistry.ts             # 命令注册中心（全局单例）
    types.ts                       # 类型定义
    fuzzy-match.ts                 # 模糊匹配算法
    pinyin.ts                      # 拼音转换工具
```

**关键组件设计：**

**CommandPalette（命令面板主组件）：**

```tsx
// components/command-palette/CommandPalette.tsx
interface CommandPaletteProps {
  isOpen: boolean;
  onClose: () => void;
}

export function CommandPalette({ isOpen, onClose }: CommandPaletteProps) {
  const [query, setQuery] = useState('');
  const [scope, setScope] = useState<string>('all');
  const [selectedIndex, setSelectedIndex] = useState(0);
  
  const context = useCommandContext();
  const { results, isLoading } = useSearch(query, scope, context);
  const { recentItems } = useRecentItems();
  
  const displayItems = query ? results : recentItems;
  
  // 键盘导航
  useKeyboardNav({
    itemCount: displayItems.length,
    selectedIndex,
    onSelect: setSelectedIndex,
    onEnter: () => executeItem(displayItems[selectedIndex]),
    onEscape: () => {
      if (query) setQuery('');
      else onClose();
    }
  });
  
  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      {/* Backdrop */}
      <div className="fixed inset-0 bg-black/50 backdrop-blur-sm" onClick={onClose} />
      
      {/* Panel */}
      <div className="fixed top-[20%] left-1/2 -translate-x-1/2 w-[640px] max-h-[480px]
                      bg-gray-900 border border-gray-700 rounded-xl shadow-2xl
                      flex flex-col overflow-hidden">
        {/* Search Input */}
        <SearchInput
          value={query}
          onChange={setQuery}
          placeholder="搜索任务、命令、成员..."
        />
        
        {/* Scope Filter (P1) */}
        {query && (
          <ScopeFilter value={scope} onChange={setScope} />
        )}
        
        {/* Results */}
        <div className="flex-1 overflow-y-auto py-2">
          {isLoading ? (
            <LoadingSpinner />
          ) : displayItems.length > 0 ? (
            <ResultList
              items={displayItems}
              selectedIndex={selectedIndex}
              onSelect={(index) => executeItem(displayItems[index])}
              query={query}
            />
          ) : (
            <EmptyState query={query} />
          )}
        </div>
        
        {/* Keyboard Hints */}
        <KeyboardHintBar />
      </div>
    </Dialog>
  );
}
```

**SearchInput（搜索输入框）：**

```tsx
// components/command-palette/search/SearchInput.tsx
interface SearchInputProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
}

export function SearchInput({ value, onChange, placeholder }: SearchInputProps) {
  const inputRef = useRef<HTMLInputElement>(null);
  
  // 打开面板时自动聚焦
  useEffect(() => {
    inputRef.current?.focus();
  }, []);
  
  return (
    <div className="flex items-center px-4 py-3 border-b border-gray-700">
      <SearchIcon className="w-5 h-5 text-gray-400 mr-3" />
      <input
        ref={inputRef}
        type="text"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        className="flex-1 bg-transparent text-white text-base
                   placeholder-gray-500 outline-none"
      />
      {value && (
        <button
          onClick={() => onChange('')}
          className="text-gray-400 hover:text-gray-300"
        >
          <XIcon className="w-4 h-4" />
        </button>
      )}
    </div>
  );
}
```

### 10.4 全局快捷键注册

```typescript
// lib/keyboard/global-shortcuts.ts

/**
 * 全局快捷键管理器
 * 在 App 根组件初始化
 */
export function initGlobalShortcuts(palette: CommandPaletteControl) {
  const handleKeyDown = (e: KeyboardEvent) => {
    // Cmd+K (Mac) / Ctrl+K (Windows/Linux) — 打开/关闭命令面板
    if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
      e.preventDefault();
      palette.toggle();
      return;
    }
  };
  
  document.addEventListener('keydown', handleKeyDown);
  
  return () => {
    document.removeEventListener('keydown', handleKeyDown);
  };
}

/**
 * 确保快捷键在以下场景下仍可生效：
 * - 用户在输入框中（Cmd+K 应优先于任何输入框行为）
 * - 用户在 Modal 中（Cmd+K 应关闭当前 Modal 并打开面板，或在面板 Modal 中关闭）
 * - 用户在全屏模式中
 * 
 * 确保快捷键在以下场景下不生效：
 * - 代码编辑器中（如 Monaco Editor 有自己的 Cmd+K 绑定）——通过 stopPropagation 处理
 */
```

### 10.5 索引同步机制

```
┌────────────────┐    Event Bus     ┌────────────────────┐
│  Module 1-8    │  (Redis Streams)  │  Index Sync Worker │
│                │                   │                    │
│  task.created  ├─────────────────→│  接收事件          │
│  task.updated  ├─────────────────→│  提取可搜索字段    │
│  task.deleted  ├─────────────────→│  计算拼音          │
│  message.created ├───────────────→│  生成 tsvector     │
│  channel.updated ├───────────────→│  写入 search_index │
│  agent.created ├─────────────────→│                    │
│  member.joined ├─────────────────→│                    │
└────────────────┘                   └────────────────────┘

处理逻辑：
  event.type = 'task.created'
    → 提取 title, description, labels
    → 计算 pinyin_initials: "dlmkcg" (登录模块重构)
    → 计算 pinyin_full: "denglumokuaichonggou"
    → 生成 trigram_text: title + subtitle
    → 生成 search_vector: to_tsvector('chinese', title || ' ' || description)
    → INSERT INTO search_index
    
  event.type = 'task.updated'
    → 提取变更字段
    → 重新计算拼音和向量
    → UPDATE search_index WHERE entity_id = ? AND entity_type = 'task'
    
  event.type = 'task.deleted'
    → UPDATE search_index SET is_active = FALSE WHERE entity_id = ? AND entity_type = 'task'
```

### 10.6 搜索查询执行流程

```typescript
// 搜索查询 SQL 示例

// 方案 1: pg_trgm 相似度搜索（适用于模糊匹配）
const searchQuery = `
  SELECT 
    entity_id,
    entity_type,
    title,
    subtitle,
    icon,
    navigate_url,
    metadata,
    similarity(trigram_text, $1) AS trgm_score,
    CASE
      WHEN title ILIKE $1 || '%' THEN 100          -- 前缀匹配
      WHEN title ILIKE '%' || $1 || '%' THEN 60     -- 子串匹配
      WHEN pinyin_initials ILIKE $1 || '%' THEN 45  -- 拼音首字母前缀
      WHEN pinyin_initials ILIKE '%' || $1 || '%' THEN 35  -- 拼音首字母子串
      ELSE 0
    END AS text_score,
    -- 时效分
    CASE
      WHEN last_activity_at > NOW() - INTERVAL '1 hour' THEN 100
      WHEN last_activity_at > NOW() - INTERVAL '1 day' THEN 80
      WHEN last_activity_at > NOW() - INTERVAL '7 days' THEN 60
      WHEN last_activity_at > NOW() - INTERVAL '30 days' THEN 40
      ELSE 20
    END AS time_score
  FROM search_index
  WHERE 
    workspace_id = $2
    AND is_active = TRUE
    AND ($3 IS NULL OR entity_type = ANY($3))  -- 类型过滤
    AND (
      trigram_text % $1                         -- pg_trgm 相似度 > 阈值
      OR title ILIKE '%' || $1 || '%'           -- 子串匹配
      OR pinyin_initials ILIKE '%' || $1 || '%' -- 拼音首字母匹配
      OR search_vector @@ plainto_tsquery('chinese', $1)  -- 全文搜索
    )
  ORDER BY 
    (text_score * 0.4 + trgm_score * 100 * 0.2 + time_score * 0.2) DESC
  LIMIT $4;
`;
```

### 10.7 性能目标

| 指标 | 目标 |
|------|------|
| 命令面板打开延迟 | < 100ms |
| 命令搜索（本地 CommandRegistry） | < 10ms |
| 实体搜索 API 响应（search_index 查询） | < 50ms |
| 搜索结果首次渲染 | < 200ms（含网络往返） |
| 键盘导航响应 | < 16ms（60fps） |
| 搜索输入去抖 | 150ms |
| 最近访问列表加载 | < 100ms |
| 索引同步延迟（实体变更 → search_index 更新） | < 2s |
| search_index 表大小（1000 实体） | < 5MB |
| 搜索结果缓存命中率 | > 30%（热门查询） |

---

## 11. 模块集成

### 11.1 与 Module 1 (Chat 对话) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| 频道搜索 | CmdK → Chat | 在命令面板中搜索频道名称，选择后直接跳转到频道 |
| 消息搜索 | CmdK → Chat | 在命令面板中搜索消息内容，选择后跳转到消息所在频道并高亮定位 |
| 创建频道 | CmdK → Chat | 在命令面板中执行"创建频道"命令，打开创建表单 |
| @提及 | CmdK → Chat | 在 Chat 模块中打开命令面板，搜索成员后插入 @提及 |
| 频道索引同步 | Chat → CmdK | 频道创建/更新/删除事件同步到 search_index |
| 消息索引同步 | Chat → CmdK | 消息创建/编辑/删除事件同步到 search_index |
| 命令注册 | Chat → CmdK | Chat 模块注册自己的命令（切换频道、搜索消息、创建频道、@提及） |

### 11.2 与 Module 2 (Tasks 任务) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| 任务搜索 | CmdK → Tasks | 在命令面板中搜索任务标题/描述，选择后跳转到任务详情 |
| 快速创建任务 | CmdK → Tasks | 面板内输入标题 → 回车 → 调用 Tasks API 创建任务 |
| 分配任务给 Agent | CmdK → Tasks+Agent | 混合命令：选择任务 + 选择 Agent → 调用 Tasks 分配 API |
| 任务索引同步 | Tasks → CmdK | 任务创建/更新/删除/状态变更事件同步到 search_index |
| 上下文感知 | Tasks → CmdK | 用户在查看某个任务时，命令面板优先显示该任务的操作 |
| 命令注册 | Tasks → CmdK | Tasks 模块注册命令（创建任务、搜索任务、修改任务状态、分配任务） |

### 11.3 与 Module 3 (Projects 项目) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| 项目搜索 | CmdK → Projects | 在命令面板中搜索项目名称，选择后跳转到项目详情 |
| 切换项目 | CmdK → Projects | "切换项目"命令导航到选定项目 |
| 项目索引同步 | Projects → CmdK | 项目创建/更新/删除事件同步到 search_index |
| 上下文感知 | Projects → CmdK | 在 Projects 模块中，命令面板优先显示项目相关命令 |
| 命令注册 | Projects → CmdK | Projects 模块注册命令（切换项目、查看 Sprint、创建项目） |

### 11.4 与 Module 4 (Team 团队) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| 成员搜索 | CmdK → Team | 在命令面板中搜索团队成员名称，选择后查看成员详情或发起 DM |
| 成员索引同步 | Team → CmdK | 成员加入/离开/角色变更事件同步到 search_index |
| 权限检查 | Team → CmdK | Agent 命令执行前通过 Permission Engine 检查权限 |
| 命令注册 | Team → CmdK | Team 模块注册命令（邀请成员、切换团队、查看拓扑图） |

### 11.5 与 Module 5 (Agent 管理) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| Agent 搜索 | CmdK → Agent | 在命令面板中搜索 Agent 名称/能力，选择后查看详情或执行命令 |
| Agent 命令执行 | CmdK → Agent | 在命令面板中选择 Agent 命令 → 传参 → 调用 Agent Invocation API |
| Agent 状态查看 | CmdK → Agent | "Agent 状态"命令显示所有 Agent 的实时状态 |
| Agent 索引同步 | Agent → CmdK | Agent 创建/更新/删除/状态变更事件同步到 search_index |
| 动态命令注册 | Agent → CmdK | Agent 被添加到团队时，动态注册该 Agent 的可用命令 |
| 命令注册 | Agent → CmdK | Agent 模块注册命令（Agent 状态总览、调用 Agent、启动工作流） |

### 11.6 与 Module 6 (Toolbox 工具箱) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| 工具搜索 | CmdK → Toolbox | 在命令面板中搜索可用工具 |
| 工作流启动 | CmdK → Toolbox | 在命令面板中选择并启动自动化工作流 |
| 命令注册 | Toolbox → CmdK | Toolbox 模块注册命令（启动工作流、搜索工具） |

### 11.7 与 Module 7/8 (Admin/Settings) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| 设置页面导航 | CmdK → Settings | 在命令面板中搜索设置页面名称，直接跳转 |
| 管理功能快捷访问 | CmdK → Admin | 管理员可在命令面板中快速访问管理功能 |
| 命令注册 | Settings/Admin → CmdK | 注册设置/管理相关命令（通知设置、主题切换、团队管理） |

### 11.8 集成数据流全景

```
Module 1 (Chat)           Module 2 (Tasks)          Module 9 (Cmd+K)
  │                         │                          │
  │ 频道/消息变更            │ 任务变更                  │
  ├────────────────→ Event Bus ←──────────────────────│
  │                         │                          │
  │                         │              ┌───────────┤
  │                         │              │ Index Sync│
  │                         │              │ Worker    │
  │                         │              └─────┬─────┤
  │                         │                    │     │
  │                         │              search_index│
  │                         │                    │     │
  │                         │              Search API  │
  │                         │                    │     │
Module 3 (Projects)    Module 4 (Team)     Module 5 (Agent)
  │                      │                      │
  │ 项目变更              │ 成员变更              │ Agent 变更/命令执行
  ├──────────→ Event Bus ←──────────────────────┤
  │                      │                      │
  │                      │ Permission Engine     │ Agent Invocation API
  │                      ├──────────→ 权限检查   ├──→ 命令执行
  │                      │                      │

命令注册流程（应用启动时）：
  Module 1 ─→ registerChatCommands(registry)
  Module 2 ─→ registerTaskCommands(registry)
  Module 3 ─→ registerProjectCommands(registry)
  Module 4 ─→ registerTeamCommands(registry)
  Module 5 ─→ registerAgentCommands(registry)
  Module 6 ─→ registerToolboxCommands(registry)
  Module 7 ─→ registerAdminCommands(registry)
  Module 8 ─→ registerSettingsCommands(registry)
              ↓
         CommandRegistry (全局单例，前端内存)
              ↓
         CommandPalette 组件
```

---

## 12. 测试用例

### 12.1 命令面板基础

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-CK-01 | 打开命令面板（Mac） | 按 Cmd+K | 命令面板弹出，搜索框聚焦，< 100ms |
| TC-CK-02 | 打开命令面板（Windows） | 按 Ctrl+K | 命令面板弹出，搜索框聚焦，< 100ms |
| TC-CK-03 | 关闭面板（Esc） | 面板打开时按 Esc | 面板关闭，焦点回到之前的页面元素 |
| TC-CK-04 | 关闭面板（Backdrop） | 点击面板外部区域 | 面板关闭 |
| TC-CK-05 | Toggle 行为 | 面板打开时再次按 Cmd+K | 面板关闭 |
| TC-CK-06 | Esc 先清空再关闭 | 有搜索输入时按 Esc | 第一次 Esc 清空输入，第二次 Esc 关闭面板 |
| TC-CK-07 | 在输入框中按 Cmd+K | 光标在页面某个 input 中，按 Cmd+K | 命令面板弹出（优先级高于输入框） |
| TC-CK-08 | 面板动画 | 打开/关闭面板 | 有平滑的 fade + scale 动画，Backdrop Blur 生效 |

### 12.2 全局搜索

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-SR-01 | 精确搜索任务 | 输入完整的任务标题"登录模块重构" | 该任务排在第一位，标题中"登录模块重构"高亮 |
| TC-SR-02 | 模糊搜索（子串） | 输入"登录" | 所有包含"登录"的实体出现（任务、消息、频道等） |
| TC-SR-03 | 模糊搜索（拼音首字母） | 输入"dlmk" | 匹配到"登录模块"相关实体 |
| TC-SR-04 | 模糊搜索（英文模糊） | 输入"lgn" | 匹配到"login"相关实体 |
| TC-SR-05 | 跨模块搜索 | 输入"Sprint" | 同时出现任务（Sprint 关联任务）和项目（Sprint 名称） |
| TC-SR-06 | 搜索成员 | 输入人名"张伟" | 成员结果显示，包含角色和在线状态 |
| TC-SR-07 | 搜索 Agent | 输入"代码助手" | Agent 结果显示，包含状态和角色 |
| TC-SR-08 | 搜索无结果 | 输入完全无关的内容"xyzxyz" | 显示空状态："未找到匹配结果" |
| TC-SR-09 | 搜索结果分组 | 输入一个跨模块关键词 | 结果按类型分组（任务/消息/频道/成员/Agent），每组有标题 |
| TC-SR-10 | 搜索结果高亮 | 搜索"登录" | 匹配文字"登录"在每条结果中高亮显示 |
| TC-SR-11 | 搜索响应速度 | 输入关键词 | 从输入结束到结果显示 < 200ms |
| TC-SR-12 | 搜索去抖 | 快速连续输入"登录模块" | 只发送一次 API 请求（150ms 去抖） |

### 12.3 快速操作

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-QA-01 | 快速创建任务 | 输入"创建任务" → 回车 → 输入标题 → 回车 | 任务创建成功，显示 Toast |
| TC-QA-02 | 切换频道 | 输入频道名 → 选择 → 回车 | 面板关闭，页面跳转到选定频道 |
| TC-QA-03 | 打开设置 | 输入"设置" → 选择"通知设置" → 回车 | 面板关闭，导航到通知设置页面 |
| TC-QA-04 | @提及成员（在 Chat 中） | 在 Chat 模块按 Cmd+K → 输入"@张" | 显示匹配的成员列表，选择后在对话中插入 @提及 |
| TC-QA-05 | 切换项目 | 输入项目名 → 回车 | 面板关闭，导航到项目详情页 |

### 12.4 Agent 命令

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-AG-01 | 调用 Agent 命令 | 输入"代码助手" → 选择"修复 Bug" → 填写参数 → 回车 | 命令发送给代码助手，Toast 提示"命令已发送" |
| TC-AG-02 | Agent 状态查看 | 输入"Agent 状态" → 回车 | 显示所有 Agent 的状态列表（名称、角色、在线/忙碌/离线） |
| TC-AG-03 | Agent 命令权限 | 非管理员用户尝试执行需权限的 Agent 命令 | 命令不可见或执行时提示权限不足 |
| TC-AG-04 | Agent 离线时命令 | 调用一个离线 Agent 的命令 | 提示"Agent 当前离线，命令将在 Agent 上线后执行" |
| TC-AG-05 | 启动工作流 | 输入"启动工作流" → 选择工作流 → 确认 | 工作流启动成功，Toast 提示 |

### 12.5 键盘导航

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-KB-01 | 上下导航 | 搜索出结果后按 ↓↓↑ | 选中项按预期移动：第1项→第3项→第2项 |
| TC-KB-02 | 循环导航 | 在最后一项按 ↓ | 选中项回到第一项 |
| TC-KB-03 | Enter 执行 | 选中某项后按 Enter | 执行该项操作（导航/创建/Agent 命令） |
| TC-KB-04 | 快捷键提示 | 查看搜索结果 | 有快捷键的命令在右侧显示快捷键标签 |
| TC-KB-05 | 全键盘操作 | 从打开面板到执行操作全程不用鼠标 | 操作流畅，无需触碰鼠标 |
| TC-KB-06 | Tab 切换范围 | 有搜索结果时按 Tab | 范围过滤在 全部/任务/消息/Agent... 间切换 |

### 12.6 最近访问

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-RC-01 | 空输入显示最近 | 打开面板不输入 | 显示最近 10 条访问记录 |
| TC-RC-02 | 访问记录更新 | 通过面板跳转到任务 → 再次打开面板 | 该任务出现在最近访问的第一位 |
| TC-RC-03 | 固定项 | 长按或右键某条历史 → 选择"固定" | 该项标记为固定，始终显示在列表顶部 |
| TC-RC-04 | 最多 50 条 | 访问超过 50 个不同实体 | 历史列表只保留最近 50 条，最旧的被移除 |
| TC-RC-05 | 跨设备同步 | 在设备 A 访问实体，在设备 B 打开面板 | 设备 B 的最近访问列表包含设备 A 的记录 |

### 12.7 上下文感知

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-CT-01 | Chat 模块上下文 | 在 Chat 模块打开面板 | 默认建议优先显示频道相关命令（切换频道、搜索消息） |
| TC-CT-02 | Tasks 模块上下文 | 在 Tasks 模块打开面板 | 默认建议优先显示任务相关命令（创建任务、搜索任务） |
| TC-CT-03 | 任务详情上下文 | 在查看任务 #42 时打开面板 | 建议置顶显示"修改 #42 状态"、"为 #42 添加评论"等 |
| TC-CT-04 | Agent 模块上下文 | 在 Agent 模块打开面板 | 默认建议优先显示 Agent 命令 |

### 12.8 命令注册

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-CR-01 | 模块命令注册 | 应用启动后打开面板输入"创建" | 显示所有模块注册的"创建"类命令（创建任务、创建频道、创建项目等） |
| TC-CR-02 | 动态注册 | Agent 被添加到团队 | 该 Agent 的命令自动出现在面板搜索结果中 |
| TC-CR-03 | 动态注销 | Agent 被移除出团队 | 该 Agent 的命令不再出现在面板搜索结果中 |
| TC-CR-04 | 权限过滤 | 普通成员打开面板 | 不显示管理员专属命令（如"删除团队"） |

### 12.9 性能测试

| 指标 | 测试方法 | 目标 |
|------|---------|------|
| 面板打开速度 | Performance timing | < 100ms |
| 命令搜索（本地） | 注册 200 条命令后搜索 | < 10ms |
| 实体搜索 API | 1000 条索引记录，模糊搜索 | < 50ms |
| 首次结果渲染 | 输入到结果展示端到端 | < 200ms |
| 键盘导航帧率 | 快速按方向键时 FPS | > 60fps |
| 并发搜索取消 | 快速输入 10 个字符 | 只有最后一次搜索完成 |
| 索引同步延迟 | 创建任务到搜索可见 | < 2s |
| 大量结果渲染 | 搜索返回 50+ 条结果 | 滚动流畅，无卡顿 |

---

## 13. 成功指标

### 13.1 核心使用指标

| 指标 | MVP (1 月后) | 成熟期 (6 月后) | 说明 |
|------|-------------|-----------------|------|
| 日均命令面板打开次数（DAU 用户均值） | 5 次/人 | 20+ 次/人 | 说明用户养成了 Cmd+K 习惯 |
| 命令面板覆盖率 | > 30% DAU | > 70% DAU | 使用过命令面板的日活用户比例 |
| 每日搜索次数 | 50 | 1000 | 全体用户搜索总量 |
| 搜索成功率（搜索后有点击） | > 60% | > 80% | 搜索后用户选择了某条结果 |

### 13.2 效率提升指标

| 指标 | MVP | 成熟期 | 说明 |
|------|-----|--------|------|
| 平均操作步骤数（使用面板 vs 不使用） | 减少 50% | 减少 70% | 通过面板完成操作的步骤数 vs 传统导航 |
| 平均操作时间（跨模块导航） | < 3s | < 2s | 从意图到到达目标页面 |
| Agent 命令触发从面板的比例 | 10% | 40% | 通过命令面板触发的 Agent 命令 / 总 Agent 命令 |
| 跨模块操作频率 | 2 次/天/人 | 10 次/天/人 | 通过命令面板完成的跨模块操作 |

### 13.3 Agent 命令指标（P1 阶段后）

| 指标 | P1 发布 1 月后 | 成熟期 | 说明 |
|------|---------------|--------|------|
| 日均 Agent 命令调用次数 | 5 | 50 | 通过命令面板触发的 Agent 命令总数 |
| Agent 命令搜索占比 | > 5% | > 20% | Agent 命令在搜索结果中被选择的比例 |
| Agent 命令成功率 | > 90% | > 95% | Agent 命令执行成功的比例 |

### 13.4 体验指标

| 指标 | 目标 | 说明 |
|------|------|------|
| 面板打开延迟 P99 | < 150ms | 从按键到面板可见 |
| 搜索响应时间 P99 | < 300ms | 从输入稳定到结果显示 |
| 键盘导航帧率 | > 60fps | 方向键导航时无卡顿 |
| 搜索结果相关度满意度 | > 4.0/5.0 | 用户调研评分 |
| 零结果搜索率 | < 10% | 搜索完全无结果的比例（越低越好） |

---

## 14. 风险与缓解

### 14.1 技术风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **搜索索引不一致** — Event Bus 消费延迟或失败导致 search_index 与业务数据不同步 | 中 | 中 | 1. 事件消费者使用 Consumer Group 确保至少一次处理。2. 索引写入失败时重试 3 次。3. 每日凌晨全量 reindex 兜底。4. 搜索结果点击后验证实体是否存在（404 则清除索引） |
| **模糊搜索性能退化** — 随着 search_index 数据量增长（10万+），pg_trgm 查询变慢 | 低 | 中 | 1. MVP 阶段 search_index 数据量预计 < 5000 条，pg_trgm 完全胜任。2. 当数据量超过 50000 时考虑迁移到 Elasticsearch/Meilisearch。3. 热门查询 Redis 缓存 30 秒减轻数据库压力 |
| **命令注册冲突** — 两个模块注册了相同 ID 的命令 | 低 | 低 | 1. 命令 ID 约定为 `{module}.{action}` 前缀，天然避免冲突。2. CommandRegistry.register() 检测重复 ID 时抛出开发环境告警。3. CI 中增加命令 ID 唯一性校验 |
| **Cmd+K 快捷键冲突** — 与第三方浏览器插件或 OS 快捷键冲突 | 中 | 低 | 1. Cmd+K 是 Web 应用中广泛使用的约定，冲突概率低。2. 如果检测到冲突，Settings 中提供自定义快捷键选项。3. 面板也可通过搜索框点击图标打开 |
| **Agent 命令执行失败** — Agent 离线或 API 超时导致命令无法执行 | 中 | 低 | 1. 命令面板显示 Agent 实时状态，离线 Agent 的命令标灰。2. 命令发送后显示加载状态。3. 超时 10 秒后提示用户"Agent 未响应，命令已排队"。4. 支持命令排队——Agent 上线后自动执行 |
| **拼音转换性能** — 大量中文内容实时拼音转换耗时 | 低 | 低 | 1. 拼音转换在索引同步阶段完成（异步 Worker），不影响搜索性能。2. 使用 pinyin-pro 库的缓存模式。3. 拼音字段预计算并存储在 search_index 中 |

### 14.2 产品风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **用户不知道 Cmd+K 的存在** — 命令面板是高级功能，新用户可能从不使用 | 高 | 中 | 1. 首次使用引导（Onboarding）中高亮展示 Cmd+K。2. 侧边栏顶部放置搜索图标 + "Cmd+K" 标签作为可视化入口。3. 在操作路径较长时（如跨模块导航），Toast 提示"试试 Cmd+K 快速到达"。4. 页面底部常驻键盘快捷键提示 |
| **搜索结果不相关** — 模糊匹配返回大量不相关结果，用户找不到目标 | 中 | 高 | 1. 排序算法中时效分和频率分权重较高，最近和常用的结果排前面。2. 支持范围过滤（Tab 切换或前缀），缩小搜索范围。3. 持续优化排序算法（基于搜索→点击数据的反馈闭环）。4. 搜索结果中展示类型标签帮助区分 |
| **Agent 命令使用率低** — 用户习惯在 Agent 模块操作，不习惯从命令面板调用 | 中 | 低 | 1. Agent 命令是 P1 功能，先验证基础搜索+导航的使用率。2. 在命令面板的默认建议中穿插 Agent 命令推荐。3. Agent 完成任务后的通知中附带"再次调用"链接（引导到命令面板） |
| **命令过多导致认知过载** — 8 个模块注册的命令数量过多，用户面对大量结果不知选哪个 | 低 | 中 | 1. 分组展示（按模块/类型），每组最多 5 条。2. 上下文感知只显示当前相关的命令。3. 个性化排序——常用命令排前面。4. 命令的 priority 和 context_filter 精心配置，非核心命令低优先级 |

### 14.3 安全风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **搜索越权** — 用户通过搜索看到无权限访问的实体 | 低 | 高 | 1. search_index 的 visibility 字段控制可见范围（workspace/team/private）。2. 搜索 API 中根据用户权限过滤结果。3. private 实体只对 owner_id 可见。4. Agent 命令受 Permission Engine 权限检查约束 |
| **Agent 命令越权执行** — 用户通过命令面板绕过权限检查执行 Agent 操作 | 低 | 高 | 1. Agent 命令执行最终调用 Module 5 的 Agent Invocation API，该 API 有独立的权限检查。2. 命令面板只是入口，不绕过任何权限层。3. CommandRegistry 的 permission 字段做前端预过滤（不可见） |
| **搜索注入** — 恶意搜索输入导致 SQL 注入 | 低 | 高 | 1. 搜索 API 使用参数化查询（$1, $2），不拼接 SQL。2. 输入在客户端和服务端双重过滤（去除特殊字符）。3. 搜索输入长度限制 200 字符 |

---

## 15. 排期建议

### 15.1 为什么是 2 周？

Module 9（Cmd+K 命令面板）的工期估算为 ~2 周（1 前端 + 1 后端），原因如下：

1. **面板 UI 是标准 Modal 组件**：命令面板的 UI 结构是"输入框 + 列表"，没有复杂的可视化（如 Module 4 的 D3.js 拓扑图）
2. **搜索引擎基于 PostgreSQL 扩展**：使用 pg_trgm + GIN 索引实现模糊搜索，不需要引入新的搜索中间件（Elasticsearch）
3. **命令注册是前端内存操作**：CommandRegistry 运行在客户端内存中，不需要后端支持
4. **复用已有基础设施**：Event Bus（Redis Streams）、Auth 中间件、API Gateway 全部复用现有基础设施
5. **P0 不含 Agent 命令**：Agent 命令是 P1 功能，MVP 只需要搜索 + 导航 + 快速操作
6. **各模块的命令注册由各模块团队完成**：Module 9 只提供注册接口，各模块注册自己的命令——这部分工作分摊到各模块，不集中在 Module 9

### 15.2 Sprint 规划（P0 范围约 2 周）

#### Sprint 1: 面板框架与搜索引擎（第 1 周）

**做什么：** 搭建命令面板的 UI 框架、实现 CommandRegistry、搭建 search_index 和搜索 API。

**后端（1 人周）：**
- 数据库 Schema 创建（search_index, recent_commands, command_usage_stats）
- pg_trgm 扩展启用 + GIN 索引创建
- Search API 实现（全局模糊搜索，支持类型过滤、分页、排序）
- Index Sync Worker 框架（监听 Event Bus，同步实体到 search_index）
- 拼音转换工具集成（pinyin-pro 库封装）
- 初始化索引：将现有实体（任务、频道、项目、成员、Agent）全量导入 search_index

**前端（1 人周）：**
- CommandPalette 主组件（Modal + Backdrop Blur）
- SearchInput 组件（实时搜索 + 去抖 + 取消）
- ResultList / ResultGroup / ResultItem 组件
- KeyboardNavigator（上/下/Enter/Esc 键盘导航）
- CommandRegistry 实现（全局单例 + 模糊匹配 + 评分排序）
- 全局快捷键注册（Cmd+K / Ctrl+K）
- Module 1-8 的基础命令注册（导航类命令为主）

**难点：** search_index 表的索引设计要同时支持精确匹配、前缀匹配、子串匹配、Trigram 模糊匹配和拼音首字母匹配——这些需要不同的索引策略。前端的 Debounce + Cancel 搜索请求管理。

#### Sprint 2: 最近访问、快速操作与联调（第 2 周）

**做什么：** 实现最近访问历史、快速操作（创建任务等）、命令使用统计，以及全流程联调。

**后端（1 人周）：**
- Recent API（记录访问、获取历史、固定/取消固定）
- Command Usage API（记录使用、获取 Top 命令）
- Index Sync Worker 完善（补齐所有模块的事件监听）
- Redis 搜索结果缓存
- 全量 reindex 脚本（定时任务，每日凌晨执行）
- 搜索结果权限过滤（visibility 字段 + 用户权限检查）

**前端（1 人周）：**
- RecentList 组件（空输入时展示最近访问）
- PinButton 组件（固定/取消固定历史项）
- QuickCreateForm 组件（面板内快速创建任务）
- ShortcutBadge 组件（快捷键标签）
- KeyboardHintBar 组件（底部键盘提示）
- EmptyState 组件（无结果状态）
- 全流程联调 + Bug 修复
- 搜索排序优化（基于测试数据调整权重参数）
- 响应式适配（移动端面板全屏）

**难点：** 快速创建任务的面板内表单需要和 Module 2 的创建 API 对接，确保创建成功后 search_index 实时更新（用户立即可以搜到刚创建的任务）。搜索排序算法的权重调优需要真实数据。

### 15.3 P1 功能排期（约 1.5 周，P0 完成后）

#### Sprint 3: Agent 命令与上下文感知（第 3 周 + 0.5 周）

**后端（0.5 人周）：**
- Agent 命令执行 API（代理调用 Module 5 的 Agent Invocation API）
- Agent 状态查询 API（聚合 Module 5 的 Agent 状态数据）
- 上下文感知后端支持（API 接受 context 参数，影响排序）

**前端（1 人周）：**
- AgentCommandPanel 组件（Agent 命令参数输入面板）
- Agent 状态列表视图（面板内展示）
- ScopeFilter 组件（搜索范围 Tab 过滤）
- 上下文感知建议（ContextProvider 提供当前模块/实体信息）
- 快捷前缀（>、@、#、/）解析
- 搜索频率追踪集成（前端埋点 + 调用 Usage API）
- 个性化排序（基于使用频率调整结果顺序）

### 15.4 里程碑

| 里程碑 | 时间 | 关键能力 | 对应 Sprint |
|--------|------|---------|------------|
| **M1: 搜索 + 导航** | Week 1 | 命令面板 UI + 全局搜索 + 键盘导航 + CommandRegistry | Sprint 1 |
| **M2: 历史 + 操作** | Week 2 | 最近访问 + 快速操作 + 使用统计 + 权限过滤 | Sprint 2 |
| **M3: Agent + 上下文** | Week 3.5 | Agent 命令 + 上下文感知 + 范围过滤 + 个性化 | Sprint 3 |

### 15.5 团队配置

| 角色 | 人数 | 职责 |
|------|------|------|
| 前端工程师 | 1 | 命令面板 UI + CommandRegistry + 键盘导航 + 搜索交互 + Agent 命令面板 |
| 后端工程师 | 1 | search_index + Search API + Index Sync Worker + Recent API + 拼音处理 |

**注意：** 各模块的命令注册（registerXxxCommands）由各模块的前端工程师完成，不计入 Module 9 的工时。Module 9 团队只负责提供 CommandRegistry 接口和文档，以及审核各模块注册的命令是否符合约定。

### 15.6 依赖关系

```
Module 1 (Chat)     ──→  Module 9 依赖 M1 的频道/消息数据（索引同步）
Module 2 (Tasks)    ──→  Module 9 依赖 M2 的任务数据（索引同步）+ 创建任务 API
Module 3 (Projects) ──→  Module 9 依赖 M3 的项目数据（索引同步）
Module 4 (Team)     ──→  Module 9 依赖 M4 的成员数据 + Permission Engine
Module 5 (Agents)   ──→  Module 9 依赖 M5 的 Agent 数据 + Agent Invocation API

Module 9 输出：
  ├── CommandRegistry → 各模块注册命令的接口
  ├── Search API → 全局统一搜索能力（其他模块也可调用）
  ├── search_index → 统一搜索索引（Index Sync Worker 维护）
  └── Recent API → 最近访问记录（可复用于其他场景）
```

**关键依赖：**
- 各模块的 Event Bus 事件格式需要与 Index Sync Worker 对齐。建议在 Sprint 1 第一天与各模块确认事件 payload 格式
- Module 5（Agent 管理）的 Agent Invocation API 是 P1 Agent 命令的前置条件。如果 Module 5 未就绪，Agent 命令使用 Mock 数据开发
- 各模块的命令注册可以并行进行——Module 9 提供 CommandRegistry 接口和示例后，各模块独立注册

---

> **文档结束。** 本 PRD 由 Zylos AI Agent 在 Stephanie 的产品指导下撰写。如有调整需求，请直接反馈。
