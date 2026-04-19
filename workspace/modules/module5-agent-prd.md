# CODE-YI Module 5: Agent 管理 (Agent Management) — 产品需求文档

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
7. [Agent 生命周期模型](#7-agent-生命周期模型)
8. [Agent 模板引擎](#8-agent-模板引擎)
9. [数据模型](#9-数据模型)
10. [技术方案](#10-技术方案)
11. [模块集成](#11-模块集成)
12. [测试用例](#12-测试用例)
13. [成功指标](#13-成功指标)
14. [风险与缓解](#14-风险与缓解)
15. [排期建议](#15-排期建议)

---

## 1. 问题陈述

### 1.1 现有 AI Agent 管理方式的结构性缺陷

当前主流 AI Agent 工具和框架（GitHub Copilot、Cursor、Devin、Replit Agent、CrewAI、AutoGen、LangGraph、Claude Code）在 Agent 管理上，均基于一个根深蒂固的假设：**Agent 是一次性的工具调用或临时进程，不需要像人类员工一样被"管理"——创建、配置、监控、销毁、复制**。当团队需要同时运行多个不同角色的 Agent 并持续管理其生命周期时，这些工具的管理模型立刻暴露出根本性不足：

**GitHub Copilot 的致命限制：**
- **没有 Agent 实体概念**：Copilot 是一个全局的编码辅助工具，不存在"创建一个 Copilot Agent"的操作。所有用户共享同一个 Copilot 实例，无法为不同用途创建不同配置的 Agent
- **不可配置 Persona**：Copilot 的行为由 GitHub 全局控制，用户无法自定义系统 Prompt、选择底层模型、或调整其技能组合。你不能让 Copilot A 专注于后端开发而 Copilot B 专注于代码审查
- **没有生命周期管理**：Copilot 没有"部署/启动/停止/销毁"的概念。它始终存在，始终运行（或不运行），用户无法控制
- **Coding Agent 模式局限**：2025 年推出的 Copilot Coding Agent 可以自动处理 Issue，但它是一个全局单例——你不能创建多个 Coding Agent 实例，每个负责不同类型的 Issue
- **没有模板市场**：不存在"从模板创建一个专门做 Code Review 的 Agent"的概念。所有 AI 功能都是 Copilot 这一个身份

**Cursor Agent 的致命限制：**
- **Agent 即编辑器会话**：Cursor 的 Agent 模式是一个编辑器内的对话会话，不是一个独立的可管理实体。关闭编辑器窗口，"Agent"就消失了
- **不可独立部署**：Cursor Agent 无法脱离编辑器独立运行。它不能在后台持续执行任务，必须有一个活跃的编辑器窗口
- **无法持久化配置**：每次开启新的 Agent 会话都需要重新设定上下文。没有"保存一个 Agent 配置并复用"的机制
- **单一模型绑定**：Cursor 支持切换模型（GPT-4、Claude 等），但这是全局设置，不是 per-Agent 设置。你不能让 Agent A 用 Claude 而 Agent B 用 GPT-4

**Devin 的致命限制：**
- **单 Agent 架构**：Devin 的核心设计是"一个 AI 软件工程师"，而不是"一个可以创建多个 AI 工程师的管理平台"。每个 Devin 会话是一个独立的任务执行环境，但无法同时管理多个长期运行的 Devin 实例
- **没有配置持久化**：Devin 的每次会话从零开始推断用户意图。没有"保存这个 Devin 的偏好和技能配置、下次直接复用"的功能
- **黑盒运行时**：Devin 的 Sandbox 环境对用户不透明。用户无法查看 Devin 的资源使用情况、运行状态、错误日志
- **不可复制/Fork**：你无法"复制一个已经配置好的 Devin"。如果你花了 1 小时让 Devin 理解你的代码库，你无法把这个上下文传递给另一个 Devin 实例
- **没有模板概念**：不存在"全栈开发者 Devin"和"QA 测试 Devin"的模板区分。每个 Devin 会话都是通用的

**Replit Agent 的致命限制：**
- **绑定项目生命周期**：Replit Agent 是项目级别的，与 Repl 绑定。不存在"创建一个跨项目的通用 Agent"的概念
- **不可自定义角色**：Replit Agent 只有一个角色——"帮你写代码"。你不能创建一个"代码审查 Agent"或"技术写作 Agent"
- **没有 Agent 管理界面**：Replit 没有"我的 Agent 列表"页面。Agent 隐藏在项目的 AI 功能按钮背后

**CrewAI / AutoGen / LangGraph 的共同问题：**
- **纯代码管理**：创建和配置 Agent 必须写 Python 代码。没有 GUI，没有可视化管理界面。对非开发者用户完全不友好
- **没有运行时管理**：这些框架负责"编排 Agent 协作"，但不管 Agent 的运行时生命周期——部署在哪里、何时启动、何时停止、资源使用多少。这些问题留给用户自行解决
- **配置即代码**：Agent 的 Persona、模型选择、技能组合全部硬编码在 Python 脚本中。修改配置 = 改代码 + 重新部署。没有热更新能力
- **没有状态监控**：Agent 跑起来后是一个黑盒。没有仪表板展示各 Agent 的运行状态、任务成功率、资源消耗
- **没有模板市场**：虽然 CrewAI 有一些示例 Crew 配置，但不存在一个"浏览 → 一键部署"的模板市场
- **Fork 机制缺失**：无法从一个已运行的 Agent 复制出一个新的 Agent，继承其 Memory 和配置

**Claude Code 的致命限制：**
- **CLI 工具而非平台**：Claude Code 是一个命令行工具，不是一个 Agent 管理平台。它不提供"创建多个 Agent"的能力
- **单会话模型**：每次 `claude` 命令启动一个新会话。虽然有 Session 持久化，但不存在"同时运行 5 个 Claude Code 实例并统一管理"的概念
- **没有可视化管理**：没有仪表板、没有状态监控、没有性能指标。一切通过终端交互

### 1.2 核心洞察

所有现有工具的 Agent 管理可以用一句话概括：**"Agent 是一个工具/功能/会话，不是一个可管理的实体"**。但 AI-Native 时代的 Agent 管理应该是：**"Agent 是一个有生命周期的数字员工——创建、配置、部署、监控、复制、销毁——和管理人类员工一样系统化"**。

```
现状（工具思维）：
  GitHub Copilot   → 一个全局编码助手，不可管理
  Cursor Agent     → 一个编辑器会话，关了就没了
  Devin            → 一个任务执行沙盒，用完即弃
  CrewAI/AutoGen   → 写 Python 代码定义 Agent，没有管理界面
  Claude Code      → 一个 CLI 工具，没有多实例管理
  
  ↓ 问题：当团队需要 5-10 个不同角色的 Agent 持续运行时，
         没有任何产品能让管理者统一查看、配置、监控这些 Agent

CODE-YI 模型（实体思维）：
  Agent = 可管理的数字实体
  - 仪表板：卡片视图展示所有 Agent 的名称、模型、技能、状态、性能
  - 创建：从模板选择 → 配置模型/技能/权限 → 命名 → 一键部署
  - 配置：Persona（系统 Prompt）、模型选择、技能启用/禁用、权限等级
  - 监控：在线/离线/错误状态、资源使用、最近活动、任务成功率
  - 复制：Fork 一个已有 Agent（包含 Memory + 技能配置）
  - 销毁：停止运行、清理资源、归档历史记录
  - 模板市场：预设模板一键创建，开箱即用
```

### 1.3 市场机会

- 2025-2026 年，多 Agent 系统从实验走向生产。企业开始部署 3-10 个不同职能的 Agent 参与日常工作流，但**没有一个产品**提供统一的 Agent 管理界面——管理者不得不在多个工具之间切换来查看不同 Agent 的状态
- Gartner 2025 报告指出，"AI Agent Lifecycle Management"将成为企业 IT 管理的新维度——从 Agent 的创建到退役，需要全流程可视化管理
- Agent 模板市场的需求迅速增长。CrewAI 的 Template Gallery 月访问量已达 100 万+，但它只是 YAML 文件的展示，缺乏"一键部署 + 实时管理"的闭环
- Model-Agnostic 的 Agent 管理需求明确——用户不想被锁定在单一 LLM 提供商上。需要一个管理平台让用户自由选择 Agent 的底层模型（Claude、GPT-4、Gemini、开源模型等）
- Stephanie 特别强调的"一步到位预置"概念——Agent 应该开箱即用，而不是每次都从零配置。这是模板市场和 Fork 机制的核心价值
- 这是 CODE-YI 的关键差异化窗口：一个**提供 Agent 全生命周期管理、模板市场一键部署、Model-Agnostic 架构、Fork 复制机制的 AI-Native Agent 管理平台**

---

## 2. 产品愿景

### 2.1 一句话定位

**CODE-YI Agent 管理模块是全球首个提供 Agent 全生命周期可视化管理（创建 → 配置 → 部署 → 监控 → Fork → 销毁）、内置 Model-Agnostic 模板市场（一键部署开箱即用的预配置 Agent）、支持 Docker 容器化运行时的 AI-Native Agent 管理平台。**

### 2.2 核心价值主张

```
┌──────────────────────────────────────────────────────────────────────────┐
│                     CODE-YI Agent 管理系统                                │
├──────────────────┬──────────────────────┬────────────────────────────────┤
│ Agent 仪表板      │ Agent 模板市场         │ Agent 运行时                    │
│                  │                      │                                │
│ 卡片视图全局总览  │ 预设模板一键部署       │ Docker 容器化隔离               │
│ 名称/模型/技能   │ 全栈开发者/UI设计师    │ 每个 Agent = 1 个容器           │
│ 任务数/成功率    │ 代码审查员/技术写作者  │ 独立资源配额                    │
│ 平均执行时长     │ 安全审计员/数据分析    │ 健康检查 + 自动恢复             │
│ 在线/离线/错误   │ 一步到位预置概念      │ 模型热切换无需重建              │
├──────────────────┼──────────────────────┼────────────────────────────────┤
│ Agent 配置中心    │ Fork 复制机制         │ 状态监控                        │
│                  │                      │                                │
│ Persona 系统提示 │ 从已有 Agent 复制    │ 实时心跳 + 健康指标             │
│ 模型选择(多LLM)  │ 继承 Memory + 配置   │ CPU/内存/API 调用量             │
│ 技能启用/禁用    │ 独立实例互不影响     │ 任务成功率趋势图               │
│ 权限等级设置     │ 团队 Agent 一键 Fork │ 错误日志 + 告警通知             │
└──────────────────┴──────────────────────┴────────────────────────────────┘
```

### 2.3 核心差异化

| 维度 | GitHub Copilot | Cursor Agent | Devin | CrewAI | AutoGen | **CODE-YI Agent** |
|------|---------------|--------------|-------|--------|---------|-------------------|
| Agent 作为独立实体 | 不支持（全局单例） | 不支持（编辑器会话） | 部分（单 Agent） | 支持（代码定义） | 支持（代码定义） | **原生支持，GUI 管理** |
| 多 Agent 管理 | 不支持 | 不支持 | 不支持 | 支持（纯代码） | 支持（纯代码） | **可视化仪表板** |
| 自定义 Persona | 不支持 | 部分（Rules） | 不支持 | 支持（代码） | 支持（代码） | **GUI 编辑器 + 实时预览** |
| Model-Agnostic | 不支持（固定模型） | 部分（全局切换） | 不支持（固定） | 支持 | 支持 | **Per-Agent 模型选择** |
| 模板市场 | 不支持 | 不支持 | 不支持 | 部分（示例） | 不支持 | **一键部署模板市场** |
| Fork 复制 | 不支持 | 不支持 | 不支持 | 不支持 | 不支持 | **含 Memory + 配置** |
| 状态监控 | 不支持 | 不支持 | 部分（任务状态） | 不支持 | 不支持 | **实时仪表板** |
| 容器化运行时 | 不支持 | 不支持 | 有（黑盒） | 不支持 | 不支持 | **Docker 容器化 + 可观测** |
| 生命周期管理 | 无 | 无 | 部分 | 无 | 无 | **完整生命周期** |
| 配置导入/导出 | 无 | 无 | 无 | YAML 文件 | 代码 | **JSON/YAML 导入导出** |

### 2.4 设计理念

**"Agent as a Service"** ——每个 Agent 是一个独立的、可管理的微服务。就像管理云服务一样管理 Agent——部署、扩缩容、监控、回滚。

Stephanie 的设计稿（Screen 1）完美体现了这一理念：页面主体是 4 张 Agent 卡片——代码助手（Claude 3.5 Sonnet, 23 tasks, 97%, 4.2min）、测试 Agent（GPT-4 Turbo, 18 tasks, 94%, 6.8min）、产品助手（Claude Opus, 8 tasks, 100%, 12min）、数据分析 Agent（Gemini 1.5 Pro, 12 tasks, 95%, 3.5min）。每张卡片清晰展示 Agent 的身份（名称+模型）、能力（技能标签）、表现（任务数+成功率+平均时长）。底部是 Agent 模板市场的入口，5 个预设模板等待一键部署。管理者打开这个页面，就能全局掌控所有 Agent 的运行状态和性能——不需要登录多个工具、查看多个终端。

Stephanie 的核心强调："一步到位预置"——Agent 应该开箱即用。模板市场提供经过验证的预配置 Agent，用户选择模板、命名、部署，三步完成。同时支持 Fork 已有团队 Agent 并设置权限，让新 Agent 直接继承前辈的经验和配置。

---

## 3. 竞品对标

### 3.1 Agent 管理能力全景对比

| 功能 | GitHub Copilot | Cursor Agent | Devin | Replit Agent | CrewAI | AutoGen | LangGraph | Claude Code | **CODE-YI** |
|------|---------------|--------------|-------|-------------|--------|---------|-----------|-------------|-------------|
| Agent 创建 GUI | - | - | - | - | - | - | - | - | **模板/自定义** |
| 多 Agent 实例 | - | - | - | - | ★★★（代码） | ★★★（代码） | ★★★（代码） | - | ★★★★★ |
| Persona 配置 | - | ★（Rules） | - | - | ★★★ | ★★★ | ★★★ | ★★（CLAUDE.md） | ★★★★★ |
| 模型选择 | ★（有限） | ★★★ | ★ | ★ | ★★★★ | ★★★★ | ★★★★ | ★ | ★★★★★ |
| 技能管理 | - | - | - | - | ★★★ | ★★★ | ★★★ | ★★（Skills） | ★★★★ |
| 状态监控 | - | - | ★ | - | - | - | ★ | - | ★★★★★ |
| 模板市场 | - | - | - | - | ★★ | - | - | - | ★★★★★ |
| Fork 复制 | - | - | - | - | - | - | - | - | ★★★★ |
| 配置导入/导出 | - | - | - | - | ★★★ | ★★ | ★★ | - | ★★★★ |
| 资源监控 | - | - | ★（黑盒） | - | - | - | ★ | - | ★★★★ |
| 生命周期 UI | - | - | ★ | - | - | - | - | - | ★★★★★ |

### 3.2 深度分析

**GitHub Copilot（含 Coding Agent）：**
- 优势：深度集成 GitHub 生态，Coding Agent 可以自动处理 Issue 和创建 PR。用户基数巨大
- 劣势：Copilot 是一个固定的全局工具，不是可管理的实体。Coding Agent 是单例——不能为不同仓库创建不同配置的 Agent。模型固定为 GitHub 提供的选项，不支持自定义模型。没有 Persona 配置、没有技能管理、没有状态监控
- 核心缺失："我想创建一个专门做 TypeScript 代码审查的 Agent，配置了严格的 lint 规则和安全检查技能"——Copilot 做不到

**Cursor Agent：**
- 优势：编辑器内 Agent 体验流畅，支持多模型切换（Claude、GPT-4、Gemini 等），Composer 模式可以编辑多文件
- 劣势：Agent 等于编辑器会话——关闭编辑器，Agent 消失。不支持后台运行。Rules for AI 只是项目级别的简单文本规则，不是完整的 Persona 配置系统。多模型切换是全局的，不是 per-Agent 的
- 核心缺失："我想同时运行 3 个 Agent——一个用 Claude 写代码、一个用 GPT-4 做 Review、一个用 Gemini 生成测试用例"——Cursor 做不到

**Devin：**
- 优势：最接近"Agent 实体"的产品——有独立的 Sandbox 环境，可以自主执行复杂任务（安装依赖、运行测试、创建 PR）
- 劣势：单 Agent 架构——每次只能运行一个 Devin 会话。没有持久化配置——每次会话从零开始。Sandbox 是黑盒——无法查看资源使用和运行状态。不可 Fork——花 1 小时让 Devin 熟悉代码库后，无法把这个上下文传给另一个实例。价格昂贵（$500/月）
- 核心缺失："我想让 5 个 Devin 分别处理 5 个不同的 Issue，并在仪表板上监控它们的进度和成功率"——Devin 做不到

**Replit Agent：**
- 优势：与 Replit 的云开发环境深度集成，可以直接部署 Agent 创建的应用
- 劣势：Agent 绑定到具体 Repl（项目），不能跨项目复用。只有"帮你写代码"一种角色，没有角色分化。没有 Agent 管理界面
- 核心缺失："我想创建一个通用的架构设计 Agent，可以在所有项目中复用"——Replit Agent 做不到

**CrewAI：**
- 优势：多 Agent 编排框架最成熟的之一。支持定义 Agent 角色、任务流程、工具调用。有 Template Gallery 提供示例配置
- 劣势：**纯 Python 代码定义**——创建 Agent 需要写 `Agent(role="...", goal="...", backstory="...")`，修改配置需要改代码并重新部署。没有 GUI 管理界面。没有运行时管理——Agent 跑起来后无法监控状态。Template Gallery 只是代码示例的展示，不支持一键部署。没有 Fork 机制。没有持久化管理——进程停止后一切状态丢失
- 核心缺失："我想在一个管理界面上创建 Agent、实时监控它的运行状态、在不停机的情况下切换底层模型"——CrewAI 做不到

**AutoGen（Microsoft）：**
- 优势：微软官方出品，与 Azure 生态深度集成。支持复杂的多 Agent 对话模式（Round-Robin、Speaker Selection）。AutoGen Studio 提供了初步的可视化界面
- 劣势：AutoGen Studio 仍处于早期——界面功能有限，只支持简单的 Agent 配置和测试，不具备生产级运行时管理。Agent 配置仍以代码为主。没有模板市场。没有状态监控仪表板。没有 Fork 机制
- 核心缺失："我想在一个仪表板上看到所有 Agent 的运行状态、任务成功率、资源消耗"——AutoGen Studio 做不到

**LangGraph（LangChain）：**
- 优势：基于图的 Agent 编排模型非常灵活。LangGraph Studio 提供了可视化的图编辑器。支持 Checkpointing（状态持久化）和 Human-in-the-loop
- 劣势：LangGraph Studio 专注于"编排图的设计和调试"，不是"Agent 实例的运行时管理"。没有多 Agent 仪表板。没有模板市场（有 Template 仓库但是代码级别）。Checkpointing 只是图状态的快照，不是 Agent 的完整 Fork
- 核心缺失："我想管理 10 个不同角色的 Agent，每个有独立的模型、技能、权限，并实时监控它们的性能"——LangGraph 做不到

**Claude Code：**
- 优势：CLI 工具体验极佳，Skill 系统提供了技能扩展机制（SKILL.md），Session 持久化保留上下文
- 劣势：CLI 工具而非管理平台。单实例运行——不支持同时管理多个 Claude Code 实例。没有 GUI 仪表板。Skill 系统是本地文件机制，没有技能市场。没有模板。没有 Fork
- 核心缺失："我想在一个 Web 界面上管理 5 个不同配置的 Claude Code 实例"——Claude Code 做不到

### 3.3 竞品演进方向判断

| 竞品 | 可能的演进方向 | CODE-YI 的时间窗口 |
|------|--------------|-------------------|
| GitHub Copilot | Coding Agent 可能支持多实例和自定义配置 | 12-18 个月——GitHub 的产品路线图优先级是扩展 Copilot 到非编码场景 |
| Cursor | 可能推出 Agent 管理界面（脱离编辑器的独立 Agent） | 12-18 个月——Cursor 的核心定位仍是编辑器 |
| Devin | 可能支持多 Agent 实例和配置持久化 | 6-12 个月——Devin 的迭代速度快 |
| CrewAI | CrewAI Studio 可能演进为完整的 Agent 管理平台 | 6-12 个月——CrewAI 已在朝平台化方向发展 |
| AutoGen | AutoGen Studio 可能演进为生产级 Agent 管理 GUI | 12-18 个月——微软的优先级在 Copilot 生态 |
| LangGraph | LangGraph Studio 可能增加运行时管理功能 | 12-18 个月——LangChain 的重心在平台化 |

**结论：** CODE-YI 有 6-12 个月的差异化窗口。核心差异点是"Agent 全生命周期 GUI 管理 + 模板市场一键部署 + Fork 机制 + Docker 容器化运行时"的完整闭环——目前没有任何产品提供这个组合。

---

## 4. 技术突破点分析

### 4.1 Docker 容器化 Agent 运行时

**传统模型：**
```
方案 A（独立 VM）：
  每个 Agent = 1 台 GCE VM
  - 隔离性极好（完全独立的操作系统）
  - 成本极高（4 Agent = 4 VM × $50-100/月 = $200-400/月）
  - 启动慢（VM 冷启动 1-3 分钟）
  - 弹性差（扩缩容需要创建/销毁 VM）

方案 C（进程级）：
  同一 VM 内多个 Agent 进程（PM2 管理）
  - 成本最低（所有 Agent 共享一台 VM）
  - 隔离性极差（进程间可互相影响、资源抢占、安全隔离弱）
  - 适合开发测试，不适合生产环境
```

**CODE-YI 模型（方案 B — Docker 容器化）：**
```
每个 Workspace = 1 台宿主 VM
每个 Agent = 1 个 Docker 容器

优势：
  - 隔离性好（容器级别的进程/网络/文件系统隔离）
  - 成本合理（降低 60-70%，4 Agent 共享 1 台 VM = $50-100/月）
  - 启动快（容器冷启动 < 10 秒）
  - 弹性好（docker create + docker start 即可扩容）
  - 资源可控（cgroup 限制 CPU/内存，避免单个 Agent 耗尽宿主资源）
  - 可观测（Docker stats、容器日志、健康检查均有成熟工具）

架构：
  ┌─────────────────────────────────────────────────┐
  │  宿主 VM（GCE, 4vCPU / 16GB RAM）                │
  │                                                  │
  │  ┌───────────┐ ┌───────────┐ ┌───────────┐      │
  │  │ Agent 容器 │ │ Agent 容器 │ │ Agent 容器 │     │
  │  │ 代码助手   │ │ 测试Agent  │ │ 产品助手   │     │
  │  │ Claude 3.5 │ │ GPT-4     │ │ Claude     │     │
  │  │ 1vCPU/2GB │ │ 1vCPU/2GB │ │ 0.5vCPU/1G│      │
  │  └───────────┘ └───────────┘ └───────────┘      │
  │                                                  │
  │  ┌───────────────────────────────────────┐       │
  │  │  Agent Manager（宿主进程）              │       │
  │  │  - 容器编排（创建/启动/停止/销毁）      │       │
  │  │  - 健康检查（心跳监控）                 │       │
  │  │  - 资源监控（CPU/内存/网络）            │       │
  │  │  - 日志收集（容器日志 → 集中存储）      │       │
  │  └───────────────────────────────────────┘       │
  └─────────────────────────────────────────────────┘
```

**核心突破：** 在"VM 完全隔离"和"进程级零隔离"之间找到了容器化的最佳平衡点。每个 Agent 的 Docker 容器拥有独立的文件系统、网络命名空间、进程空间，同时共享宿主机的内核和硬件资源，实现了 60-70% 的成本节约。

### 4.2 Model-Agnostic Agent 架构

**传统模型：**
```
Copilot Agent → 只能用 GitHub 提供的模型（GPT-4 / Claude）
Cursor Agent  → 支持多模型，但全局切换
Devin         → 固定底层模型
```

**CODE-YI 模型：**
```
Agent 配置层（与模型无关）
  │
  ├── Persona（系统 Prompt）
  ├── 技能列表（代码生成、代码审查、测试等）
  ├── 权限配置
  ├── Memory（上下文记忆）
  │
  └── 模型适配层（LLM Adapter）
        │
        ├── Claude Adapter（Anthropic API）
        ├── GPT Adapter（OpenAI API）
        ├── Gemini Adapter（Google AI API）
        ├── DeepSeek Adapter
        ├── Qwen Adapter
        └── OpenRouter Adapter（统一网关）

模型热切换：
  Agent 运行中 → 管理员修改模型配置 → 
  下一次 API 调用自动使用新模型 → 
  无需重建容器、无需重启 Agent
```

**核心突破：** Agent 的核心身份（Persona + 技能 + 权限 + Memory）与底层模型解耦。切换模型不影响 Agent 的其他配置，也不需要重建容器。这意味着用户可以：
- 同一个"代码助手"Agent，A/B 测试不同模型的效果
- 新模型发布时，无缝切换现有 Agent 到新模型
- 根据任务复杂度动态选择模型（简单任务用轻量模型降成本，复杂任务用旗舰模型提质量）

### 4.3 Fork 机制

**传统方式：** 要创建一个和现有 Agent 类似的新 Agent，只能从零配置。

**CODE-YI Fork 机制：**
```
源 Agent（已运行 2 个月，积累了丰富的 Memory 和优化过的配置）
  │
  ├── Fork 操作
  │   ├── 复制 Persona（系统 Prompt）
  │   ├── 复制技能配置
  │   ├── 复制权限设置
  │   ├── 复制 Memory 快照（可选：全量/精选/不复制）
  │   ├── 新 Agent 获得独立的实例 ID
  │   └── 新 Agent 与源 Agent 完全独立（修改互不影响）
  │
  └── Fork 后的新 Agent
      ├── 继承了源 Agent 的所有"经验"
      ├── 可以自由修改配置（换模型、调权限、改 Persona）
      ├── 独立运行在新的 Docker 容器中
      └── 可以添加到不同的团队

用例：
  1. "代码助手很好用，我想 Fork 一个给另一个项目" → 一键 Fork
  2. "想试试换个模型" → Fork 后修改模型配置，保留其他配置
  3. "新团队需要同样的 Agent" → Fork 并设置新的团队权限
```

**核心突破：** Fork 不是简单的"复制配置文件"，而是包含 Memory 快照的完整克隆。源 Agent 积累的上下文记忆（项目结构、代码风格偏好、历史决策）可以传递给新 Agent，避免"重新训练"的时间成本。

### 4.4 模板引擎

**传统方式：** CrewAI 的 Template Gallery 是一个代码示例仓库——用户需要 clone 代码、修改配置、手动部署。

**CODE-YI 模板引擎：**
```
模板定义：
  {
    name: "全栈开发者",
    description: "精通前后端开发的全能 Agent",
    icon: "...",
    persona: "你是一个经验丰富的全栈开发者...",
    recommended_model: "Claude 3.5 Sonnet",
    skills: ["代码生成", "代码重构", "Bug 修复", "Code Review"],
    permission_preset: "executor",
    resource_config: { cpu: "1vCPU", memory: "2GB" },
    tags: ["开发", "全栈", "推荐"]
  }

一键部署流程：
  1. 用户在模板市场浏览 → 选择"全栈开发者"模板
  2. 系统自动填充 Persona、技能、权限等配置
  3. 用户可选修改（命名、换模型、调技能）
  4. 点击"部署" → 系统创建 Docker 容器 → Agent 上线
  5. 从模板浏览到 Agent 上线 < 30 秒

模板来源：
  - 官方预设模板（CODE-YI 团队精心设计和测试）
  - 社区贡献模板（P2：用户分享自己的 Agent 配置到市场）
  - 企业私有模板（P2：企业内部的标准化 Agent 配置）
```

**核心突破：** 模板不是代码文件，而是结构化的配置数据，可以在 GUI 中浏览、预览、一键部署。"一步到位预置"——用户不需要理解系统 Prompt 的写法、不需要知道该启用哪些技能，模板已经做好了最佳实践配置。

### 4.5 实时状态监控与可观测性

**传统方式：** Agent 跑起来后是黑盒——用户不知道它在做什么、用了多少资源、有没有出错。

**CODE-YI 可观测性：**
```
Agent 仪表板卡片展示：
  ┌─────────────────────────────────────┐
  │  [🤖] 代码助手                       │
  │  Claude 3.5 Sonnet                   │
  │  ● 在线                              │
  │                                      │
  │  [代码生成] [重构] [Code Review] [测试]│
  │                                      │
  │  本周任务: 23                         │
  │  成功率:   97%                       │
  │  平均时长: 4.2 min                   │
  │                                      │
  │  CPU: ██░░ 48%   MEM: ███░ 62%      │
  │  最近活动: 2 分钟前                   │
  └─────────────────────────────────────┘

监控维度：
  1. 运行状态：online / offline / busy / error / updating
  2. 资源使用：CPU 使用率 / 内存使用量 / 网络 I/O
  3. 性能指标：任务数 / 成功率 / 平均执行时长 / 错误率
  4. API 调用：LLM API 调用次数 / Token 消耗 / 成本估算
  5. 健康指标：连续运行时间 / 最后心跳 / 24h 错误数
  6. 活动日志：最近操作记录 / 错误日志
```

**核心突破：** 从"黑盒 Agent"到"全透明 Agent"。管理者在一个仪表板上就能看到所有 Agent 的运行状态和性能，快速定位问题（"代码助手今天成功率从 97% 降到 80%——是模型 API 不稳定还是任务变复杂了？"）。

---

## 5. 用户故事

### 5.1 Agent 仪表板

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-AG-01 | Workspace 管理员 | 作为管理员，我想在一个仪表板上看到所有 Agent 的卡片视图，以便掌握 Agent 全貌 | 卡片展示：名称、类型图标、底层模型、技能标签、本周任务数/成功率/平均时长、在线状态 | P0 |
| US-AG-02 | Workspace 管理员 | 作为管理员，我想通过 Agent 卡片上的状态指示器快速区分在线/离线/异常的 Agent | 在线绿色、离线灰色、忙碌黄色、异常红色，状态变更 < 1s 内反映到 UI | P0 |
| US-AG-03 | 团队成员 | 作为成员，我想查看 Agent 的技能标签，以便了解它擅长做什么 | 技能标签 Badge 形式展示，如 [代码生成] [重构] [Code Review] | P0 |

### 5.2 创建 Agent

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-AG-04 | Workspace 管理员 | 作为管理员，我想从模板市场选择一个预设模板来创建 Agent，以便快速部署 | 浏览模板 → 选择 → 可选修改 → 命名 → 部署，全流程 < 30 秒 | P0 |
| US-AG-05 | Workspace 管理员 | 作为管理员，我想从零创建自定义 Agent，以便满足特殊需求 | 配置 Persona（系统 Prompt）→ 选择模型 → 选择技能 → 设置权限 → 命名 → 部署 | P0 |
| US-AG-06 | Workspace 管理员 | 作为管理员，我想在创建 Agent 时选择底层模型（Claude/GPT-4/Gemini 等），以便使用最适合的模型 | 模型选择下拉列表，展示可用模型列表及其特性说明 | P0 |
| US-AG-07 | Workspace 管理员 | 作为管理员，我想为新 Agent 命名并选择图标，以便在团队中容易辨识 | 名称输入框 + 图标选择器（预设图标或自定义上传） | P0 |

### 5.3 Agent 配置

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-AG-08 | Workspace 管理员 | 作为管理员，我想修改 Agent 的 Persona（系统 Prompt），以便调整其行为风格 | 富文本编辑器编辑 Persona，支持 Markdown，保存后即时生效 | P0 |
| US-AG-09 | Workspace 管理员 | 作为管理员，我想切换 Agent 的底层模型而不影响其他配置 | 模型切换下拉 → 确认 → 下次 API 调用使用新模型，无需重启容器 | P0 |
| US-AG-10 | Workspace 管理员 | 作为管理员，我想启用/禁用 Agent 的特定技能，以便控制其能力范围 | 技能列表展示，每个技能有开关按钮，变更即时生效 | P0 |
| US-AG-11 | Workspace 管理员 | 作为管理员，我想设置 Agent 的权限等级，以便控制其操作范围 | 权限等级选择（低/中/高），每个等级有详细的权限说明 | P0 |

### 5.4 Agent 状态监控

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-AG-12 | Workspace 管理员 | 作为管理员，我想实时查看每个 Agent 的运行状态（在线/离线/错误） | 状态指示器实时更新，错误状态附带错误类型和持续时间 | P0 |
| US-AG-13 | Workspace 管理员 | 作为管理员，我想查看 Agent 的资源使用情况（CPU/内存） | Agent 详情页展示实时资源使用图表 | P0 |
| US-AG-14 | Workspace 管理员 | 作为管理员，我想查看 Agent 的最近活动记录 | 活动时间线展示最近操作（任务开始/完成/错误/模型调用等） | P0 |
| US-AG-15 | Workspace 管理员 | 作为管理员，我想在 Agent 异常时收到通知 | Agent 状态变为 error 时，推送通知到管理员（Chat 消息 / 邮件） | P0 |

### 5.5 Agent 模板市场

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-AG-16 | Workspace 管理员 | 作为管理员，我想浏览预设的 Agent 模板市场 | 展示模板列表：名称、描述、推荐模型、技能列表、预览卡片 | P0 |
| US-AG-17 | Workspace 管理员 | 作为管理员，我想从模板一键创建 Agent | 选择模板 → 命名 → 部署，自动填充所有配置，可选修改 | P0 |
| US-AG-18 | 团队成员 | 作为成员，我想查看模板的详细说明和适用场景 | 模板详情页展示完整说明、推荐模型、技能列表、示例输出 | P0 |

### 5.6 Fork Agent

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-AG-19 | Workspace 管理员 | 作为管理员，我想 Fork 一个已有的 Agent，以便快速创建类似配置的新 Agent | Fork → 选择是否复制 Memory → 命名 → 部署，新 Agent 继承源 Agent 配置 | P1 |
| US-AG-20 | Workspace 管理员 | 作为管理员，我想在 Fork 时选择是否复制 Memory | 选项：全量复制 / 精选复制 / 不复制。默认全量复制 | P1 |
| US-AG-21 | Workspace 管理员 | 作为管理员，我想 Fork 后修改新 Agent 的配置而不影响源 Agent | Fork 后两个 Agent 完全独立，修改互不影响 | P1 |

### 5.7 导入配置

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-AG-22 | Workspace 管理员 | 作为管理员，我想从 JSON/YAML 文件导入 Agent 配置 | 上传配置文件 → 验证格式 → 预览配置 → 确认创建 | P1 |
| US-AG-23 | Workspace 管理员 | 作为管理员，我想导出 Agent 配置为 JSON/YAML 文件 | Agent 详情页 → 导出按钮 → 下载配置文件 | P1 |
| US-AG-24 | Workspace 管理员 | 作为管理员，我想批量导入多个 Agent 配置 | 上传包含多个 Agent 配置的 YAML 文件 → 批量创建 | P1 |

### 5.8 Agent 生命周期

| 编号 | 角色 | 用户故事 | 验收标准 | 优先级 |
|------|------|---------|---------|--------|
| US-AG-25 | Workspace 管理员 | 作为管理员，我想停止一个 Agent 的运行 | 停止 → 确认 → Agent 状态变为 offline，容器停止 | P0 |
| US-AG-26 | Workspace 管理员 | 作为管理员，我想重新启动一个已停止的 Agent | 启动 → Agent 状态变为 online，容器恢复运行 | P0 |
| US-AG-27 | Workspace 管理员 | 作为管理员，我想销毁一个不再需要的 Agent | 销毁 → 二次确认 → 容器删除 → 配置和历史归档 | P0 |
| US-AG-28 | Workspace 管理员 | 作为管理员，我想重启一个异常状态的 Agent | 重启 → 容器重建 → Agent 恢复在线 | P0 |

---

## 6. 功能拆分

### 6.1 P0 功能（MVP，必须实现）

#### 6.1.1 Agent 仪表板

**卡片视图：**
- 以网格卡片形式展示 Workspace 内所有 Agent
- 每张卡片显示：
  - Agent 名称和自定义图标
  - 类型图标（AI/QA/PM/数据等，由技能标签推断）
  - 底层模型名称（如 Claude 3.5 Sonnet、GPT-4 Turbo 等）
  - 技能标签 Badge（代码生成、重构、Code Review、测试等）
  - 本周任务数
  - 成功率（百分比）
  - 平均执行时长
  - 在线状态指示器
- 卡片支持点击进入 Agent 详情页

**卡片信息参考（来自 Stephanie 设计稿）：**
```
┌─────────────────────────────────┐    ┌─────────────────────────────────┐
│  [🤖] 代码助手                   │    │  [🧪] 测试 Agent                │
│  Claude 3.5 Sonnet               │    │  GPT-4 Turbo                    │
│  ● 在线                          │    │  ● 在线                         │
│                                  │    │                                 │
│  [代码生成] [重构] [Code Review]  │    │  [单元测试] [集成测试] [E2E]     │
│                                  │    │                                 │
│  本周: 23 任务                   │    │  本周: 18 任务                  │
│  成功率: 97%                     │    │  成功率: 94%                    │
│  平均: 4.2 min                   │    │  平均: 6.8 min                  │
└─────────────────────────────────┘    └─────────────────────────────────┘

┌─────────────────────────────────┐    ┌─────────────────────────────────┐
│  [📋] 产品助手                   │    │  [📊] 数据分析 Agent            │
│  Claude Opus                     │    │  Gemini 1.5 Pro                 │
│  ● 在线                          │    │  ● 在线                         │
│                                  │    │                                 │
│  [需求分析] [PRD撰写] [用户故事]  │    │  [数据清洗] [可视化] [报表生成]  │
│                                  │    │                                 │
│  本周: 8 任务                    │    │  本周: 12 任务                  │
│  成功率: 100%                    │    │  成功率: 95%                    │
│  平均: 12 min                    │    │  平均: 3.5 min                  │
└─────────────────────────────────┘    └─────────────────────────────────┘
```

**操作区：**
- 右上角"+ 创建 Agent"按钮（打开创建向导）
- 右上角"导入配置"按钮（上传 JSON/YAML 文件）
- 搜索/筛选：按名称搜索、按模型筛选、按状态筛选、按技能筛选
- 排序：按名称 / 成功率 / 任务数 / 最近活跃 排序

#### 6.1.2 创建 Agent

**创建向导（Step by Step）：**

```
Step 1: 选择创建方式
  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐
  │  从模板创建  │  │  自定义创建  │  │  导入配置   │
  │  (推荐)      │  │             │  │  (P1)       │
  └─────────────┘  └─────────────┘  └─────────────┘

Step 2a（模板创建）: 选择模板
  → 模板卡片列表，每张卡片显示名称/描述/推荐模型/技能
  → 选择后自动填充后续配置

Step 2b（自定义创建）: 配置模型和 Persona
  → 选择底层模型（Claude 3.5 Sonnet / GPT-4 Turbo / Gemini 1.5 Pro / ...）
  → 编辑 Persona（系统 Prompt）
  → 编辑器支持 Markdown 格式，预置 Persona 模板

Step 3: 配置技能
  → 技能列表（代码生成 / 代码审查 / 测试 / 文档撰写 / 数据分析 / ...）
  → 每个技能有开关和简要说明
  → 模板创建时已预选，可手动调整

Step 4: 配置权限和资源
  → 权限等级：低（只读 + 有限写入）/ 中（标准操作权限）/ 高（管理员级权限）
  → 资源配额：CPU (0.5-2 vCPU) / 内存 (512MB-4GB)
  → 说明不同配额的适用场景

Step 5: 命名和部署
  → 输入 Agent 名称
  → 选择图标（预设或自定义上传）
  → 预览配置摘要
  → 点击"部署"
```

**部署流程（后端）：**
1. 验证配置（名称唯一性、模型 API Key 可用性、资源配额在限制范围内）
2. 写入 `agents` 表 + `agent_configs` 表 + `agent_skills` 表
3. 构建 Docker 容器（基于标准 Agent 镜像 + 注入配置）
4. 启动容器
5. 等待容器健康检查通过
6. 更新状态为 online
7. 推送 WebSocket 事件通知前端

#### 6.1.3 Agent 配置

**Persona 编辑器：**
- Markdown 格式的系统 Prompt 编辑器
- 支持变量插值（如 `{{agent_name}}`、`{{workspace_name}}`）
- 预置 Persona 模板（可直接使用或在此基础上修改）
- 实时预览："发送一条测试消息，看 Agent 如何回复"（P1）
- 版本历史：每次保存自动创建版本，可回滚

**模型选择：**
- 下拉列表展示可用模型
- 每个模型显示：名称、提供商、上下文窗口大小、估算成本
- 切换模型后即时生效（下一次 API 调用使用新模型）
- 无需重启容器

**技能管理：**
- 技能列表，每个技能有：名称、描述、开关
- 预置技能（系统内置）：
  - 代码生成：根据描述生成代码
  - 代码审查：Review 代码并提出建议
  - 代码重构：重构优化现有代码
  - Bug 修复：分析和修复代码缺陷
  - 单元测试：编写和运行单元测试
  - 集成测试：编写集成测试用例
  - 文档撰写：生成技术文档
  - 需求分析：分析和结构化用户需求
  - 数据分析：处理和分析数据
  - 可视化：生成数据图表
- 自定义技能（P2）：用户定义的技能描述和工具调用

**权限等级：**
- 低权限：只读操作 + 有限写入（如只能编辑自己的任务、不能访问其他 Agent 的数据）
- 中权限：标准操作（创建/编辑任务、提交代码、发送消息）
- 高权限：管理员级别（管理项目设置、管理其他 Agent 配置的有限操作）
- 权限等级与 Module 4 的 Agent 角色（执行者/审核者/协调者/观察者）配合使用

#### 6.1.4 Agent 状态监控

**状态指示器：**
```
Agent 状态机：
  ┌─────────┐      deploy      ┌─────────┐
  │ created │ ───────────────→ │ starting│
  └─────────┘                  └────┬────┘
                                    │ health check pass
                                    ↓
  ┌─────────┐      stop        ┌─────────┐     task assigned
  │ stopped │ ←──────────────  │ online  │ ────────────────→  ┌──────┐
  └────┬────┘                  └────┬────┘                    │ busy │
       │                            │                         └──┬───┘
       │      start                 │ error detected              │ task done
       └──────────────→ starting    │                             │
                                    ↓                             ↓
                               ┌─────────┐                  ┌─────────┐
                               │  error  │ ←────────────── │ online  │
                               └────┬────┘                  └─────────┘
                                    │ restart
                                    ↓
                               ┌─────────┐
                               │ starting│
                               └─────────┘

  特殊状态:
  - updating: 配置更新中（模型切换、Persona 变更触发的重载）
  - destroying: 销毁中（清理资源、归档数据）
```

**状态详情页（点击 Agent 卡片进入）：**
- 基本信息：名称、模型、创建时间、最后活跃时间
- 运行状态：状态指示器 + 连续运行时间 + 最后心跳时间
- 资源使用：CPU/内存使用率实时图表（过去 1h/6h/24h）
- 性能指标：
  - 任务统计：总任务数 / 完成数 / 成功率 / 失败率
  - 时间统计：平均执行时长 / P95 执行时长
  - 本周/本月趋势图
- 最近活动：时间线形式的活动日志（最近 50 条）
- 错误日志：最近错误记录和堆栈信息
- 快捷操作：停止 / 重启 / 编辑配置 / Fork / 销毁

#### 6.1.5 Agent 模板市场

**模板列表：**
- 展示在 Agent 仪表板底部（参考 Stephanie 设计稿）
- 每个模板卡片显示：
  - 模板名称和图标
  - 简短描述
  - 推荐模型
  - 技能标签
  - 使用次数（社区热度）

**预设模板（P0 必须包含）：**

| 模板名称 | 描述 | 推荐模型 | 技能 | 适用场景 |
|---------|------|---------|------|---------|
| 全栈开发者 | 精通前后端开发的全能 Agent | Claude 3.5 Sonnet | 代码生成、代码重构、Bug 修复 | 日常开发任务 |
| UI 设计师 | 精通界面设计和前端实现的 Agent | GPT-4 Turbo | UI 设计、组件开发、样式优化 | 前端 UI 开发 |
| 代码审查员 | 严格的代码质量审查 Agent | Claude 3.5 Sonnet | Code Review、安全检查、性能分析 | PR 审查 |
| 技术写作者 | 撰写技术文档和 API 文档的 Agent | Claude Opus | 文档撰写、API 文档、README | 技术文档 |
| 安全审计员 | 专注安全漏洞检测和修复的 Agent | GPT-4 Turbo | 安全扫描、漏洞分析、修复建议 | 安全审计 |

**模板详情页：**
- 完整描述（使用场景、最佳实践）
- Persona 预览（可查看系统 Prompt）
- 技能列表和说明
- 推荐资源配额
- "使用此模板创建 Agent"按钮

### 6.2 P1 功能

#### 6.2.1 Fork Agent

**Fork 流程：**
- 在 Agent 详情页点击"Fork"按钮
- 选择 Memory 复制策略：
  - 全量复制：复制源 Agent 的所有 Memory（上下文记忆、决策历史等）
  - 精选复制：选择要复制的 Memory 范围（如只复制项目相关的记忆）
  - 不复制：只复制配置，不复制 Memory
- 命名新 Agent
- 可选修改配置（换模型、调技能等）
- 点击"创建 Fork"
- 系统创建新的 Docker 容器 + 复制选定的 Memory 数据
- 新 Agent 独立运行

**Fork 元数据：**
- 记录 Fork 关系（source_agent_id → forked_agent_id）
- Fork 时间戳
- Memory 复制策略记录
- 可在 Agent 详情页查看 Fork 谱系

#### 6.2.2 导入/导出配置

**导出格式（JSON/YAML）：**
```yaml
# agent-config.yaml
version: "1.0"
agent:
  name: "代码助手"
  description: "精通全栈开发的 AI Agent"
  icon: "code-bot"
  model:
    provider: "anthropic"
    model_id: "claude-3-5-sonnet-20241022"
  persona: |
    你是一个经验丰富的全栈开发者，精通 TypeScript、React、Node.js。
    你的代码风格注重可读性和可维护性...
  skills:
    - code_generation
    - code_refactoring
    - bug_fix
    - code_review
  permissions:
    level: "medium"
  resources:
    cpu: "1vCPU"
    memory: "2GB"
```

**导入流程：**
1. 点击"导入配置"按钮
2. 上传 JSON/YAML 文件
3. 系统验证格式和字段
4. 预览解析后的配置
5. 可修改部分字段（如名称、模型）
6. 确认创建

### 6.3 P2 功能（后续迭代）

#### 6.3.1 社区模板市场
- 用户分享自己的 Agent 配置到公共市场
- 评分和评价系统
- 分类和标签筛选
- 热门排行榜

#### 6.3.2 自定义技能系统
- 用户定义新技能（名称、描述、工具调用规则）
- 技能版本管理
- 技能导入/导出
- 技能市场（P3）

#### 6.3.3 Agent 版本管理
- 配置变更自动创建版本
- 版本对比（diff）
- 回滚到任意历史版本
- 版本标签和描述

#### 6.3.4 Agent 性能分析
- 详细的性能趋势图
- Token 消耗分析和成本估算
- 任务耗时分布分析
- 模型 A/B 测试支持

---

## 7. Agent 生命周期模型

### 7.1 完整生命周期

CODE-YI 的 Agent 具有明确的生命周期，从创建到销毁的每个阶段都有对应的状态、可执行操作和监控指标。

```
┌──────────────────────────────────────────────────────────────────────────┐
│                     Agent 生命周期状态机                                   │
│                                                                          │
│                    ┌────────┐                                            │
│                    │ DRAFT  │  ← 配置创建但未部署                         │
│                    └───┬────┘                                            │
│                        │ deploy                                          │
│                        ↓                                                 │
│                    ┌────────┐                                            │
│                    │STARTING│  ← 容器创建中                              │
│                    └───┬────┘                                            │
│                        │ health check pass                               │
│                        ↓                                                 │
│    restart ──→    ┌────────┐     task      ┌────────┐                   │
│    start  ──→    │ ONLINE │ ──────────→  │  BUSY  │                    │
│                   └───┬────┘  ←────────── └────────┘                    │
│                       │            task done                             │
│                       │                                                  │
│          stop ←───────┤───────→ error detected                          │
│                       │                                                  │
│                  ┌────┴────┐              ┌────────┐                    │
│                  │ STOPPED │              │ ERROR  │                     │
│                  └────┬────┘              └───┬────┘                    │
│                       │                       │ restart                  │
│                       │ destroy               │ → STARTING              │
│                       ↓                                                  │
│                  ┌─────────┐                                            │
│                  │DESTROYING│  ← 清理资源中                              │
│                  └────┬─────┘                                            │
│                       │ cleanup done                                     │
│                       ↓                                                  │
│                  ┌─────────┐                                            │
│                  │DESTROYED│  ← 已销毁（配置和历史归档）                   │
│                  └─────────┘                                            │
│                                                                          │
│  特殊转换:                                                               │
│    ONLINE/BUSY → UPDATING → ONLINE  （配置热更新）                       │
│    任意运行状态 → DESTROYING → DESTROYED  （强制销毁）                    │
└──────────────────────────────────────────────────────────────────────────┘
```

### 7.2 各阶段详细定义

#### 7.2.1 DRAFT（草稿）

```
描述：
  Agent 配置已创建但尚未部署。可能是创建流程中断或用户选择稍后部署。

数据状态：
  - agents 表记录已创建（status = 'draft'）
  - agent_configs 记录已创建
  - Docker 容器未创建

可执行操作：
  - 编辑配置（修改 Persona、模型、技能等）
  - 部署（deploy → STARTING）
  - 删除（直接删除记录，无需清理资源）

监控指标：无（未运行）

停留时间建议：
  - 正常：< 24 小时
  - 超过 7 天的 DRAFT 状态 Agent → 系统提示管理员清理或部署
```

#### 7.2.2 STARTING（启动中）

```
描述：
  Docker 容器正在创建和初始化。

流程：
  1. 拉取 Agent 基础镜像（如已缓存则跳过）
  2. 注入配置（Persona、模型 API Key、技能列表）
  3. 创建并启动容器
  4. 等待容器内健康检查端点响应
  5. 验证 LLM API 连接
  6. 上报健康状态 → 转为 ONLINE

超时处理：
  - 启动超时 120 秒 → 标记为 ERROR + 错误类型 'start_timeout'
  - 健康检查失败 → 标记为 ERROR + 错误类型 'health_check_failed'

可执行操作：
  - 取消部署（停止启动过程 → STOPPED）
  - 查看启动日志（实时流式输出）

预期时长：< 30 秒（镜像已缓存时 < 10 秒）
```

#### 7.2.3 ONLINE（在线）

```
描述：
  Agent 正常运行中，可接受任务分配。

行为：
  - 定期发送心跳（每 30 秒）
  - 监听任务队列
  - 响应 API 调用
  - 上报资源使用情况

可执行操作：
  - 分配任务（→ BUSY）
  - 编辑配置（热更新：Persona/模型变更 → UPDATING → ONLINE）
  - 停止（→ STOPPED）
  - 重启（→ STARTING）
  - Fork（创建新 Agent，不影响当前 Agent）
  - 销毁（→ DESTROYING）

监控指标：
  - 心跳状态（最后心跳时间、心跳间隔）
  - 资源使用（CPU%、内存 MB、网络 I/O）
  - 空闲时间（自上次任务完成以来的时间）
```

#### 7.2.4 BUSY（忙碌）

```
描述：
  Agent 正在执行任务。

行为：
  - 持续发送心跳
  - 上报任务进度
  - 可能调用 LLM API
  - 可能执行代码、运行测试、操作文件

可执行操作：
  - 查看当前任务详情
  - 查看实时执行日志
  - 强制停止当前任务（任务标记为 interrupted → ONLINE）
  - 停止 Agent（等待当前任务完成 → STOPPED，或强制停止）

监控指标：
  - 当前任务 ID 和标题
  - 任务进度百分比
  - 已执行时间
  - 资源使用（可能升高）
  - LLM API 调用次数
```

#### 7.2.5 STOPPED（已停止）

```
描述：
  Agent 容器已停止，但配置和数据保留。可以随时重新启动。

数据状态：
  - Docker 容器处于 stopped 状态（未删除）
  - 容器内数据保留（Volume mount）
  - Memory 数据保留

可执行操作：
  - 启动（→ STARTING → ONLINE）
  - 编辑配置（离线修改，启动时生效）
  - Fork（基于当前配置和 Memory 创建新 Agent）
  - 销毁（→ DESTROYING）
  - 导出配置

监控指标：
  - 停止时间
  - 停止原因（手动 / 错误后自动 / 资源不足）
  - 上次运行统计（总运行时间、任务数）
```

#### 7.2.6 ERROR（异常）

```
描述：
  Agent 遇到不可恢复的错误，需要人工介入。

可能的错误类型：
  - start_timeout: 启动超时
  - health_check_failed: 健康检查失败
  - oom_killed: 内存不足被 OOM Kill
  - api_key_invalid: LLM API Key 无效或过期
  - api_rate_limited: LLM API 频率限制
  - container_crash: 容器异常退出
  - heartbeat_timeout: 心跳超时（3 个周期 = 90 秒无心跳）

可执行操作：
  - 查看错误详情和日志
  - 重启（→ STARTING，尝试恢复）
  - 编辑配置（修复配置问题后重启，如更换 API Key）
  - 停止（→ STOPPED，放弃恢复）
  - 销毁（→ DESTROYING）

自动恢复机制：
  - 容器崩溃：自动重启（Docker restart policy = on-failure:3）
  - 3 次自动重启均失败 → 标记为 ERROR，等待人工介入
  - OOM Kill → 自动增加 20% 内存配额并重启（上限为模板最大值）

告警通知：
  - ERROR 状态触发通知推送到管理员
  - 通知渠道：Chat 消息 + 邮件（如已配置）
  - 包含错误类型、发生时间、建议操作
```

#### 7.2.7 UPDATING（更新中）

```
描述：
  Agent 配置正在热更新。

触发场景：
  - Persona（系统 Prompt）变更
  - 模型切换
  - 技能启用/禁用
  - 权限等级变更

更新流程：
  1. 暂停接受新任务
  2. 等待当前任务完成（如正在执行）
  3. 重新加载配置
  4. 验证新配置（如新模型的 API Key 是否有效）
  5. 恢复正常运行 → ONLINE

超时处理：
  - 更新超时 60 秒 → 回滚到旧配置 → ONLINE + 通知管理员更新失败

预期时长：< 10 秒（模型切换不需要重建容器）
```

#### 7.2.8 DESTROYING（销毁中）

```
描述：
  Agent 正在被销毁，资源清理中。

清理流程：
  1. 停止容器
  2. 导出并归档 Agent 数据：
     - 配置快照 → agent_archives 表
     - Memory 快照 → 归档存储
     - 活动日志 → 保留（只读）
     - 性能指标 → 保留（只读）
  3. 删除 Docker 容器和 Volume
  4. 从所有团队中移除该 Agent（触发 Module 4 事件）
  5. 更新状态为 DESTROYED

可执行操作：
  - 无（不可逆过程）

预期时长：< 30 秒
```

#### 7.2.9 DESTROYED（已销毁）

```
描述：
  Agent 已销毁，配置和历史数据已归档。

数据状态：
  - agents 表记录保留（status = 'destroyed'，软删除）
  - Docker 容器已删除
  - 配置快照可查看（只读）
  - 活动日志和性能指标可查看（只读）
  - Memory 已归档到冷存储

可执行操作：
  - 查看归档数据（只读）
  - 从归档恢复（P2：重新创建同配置的 Agent）
  - 永久删除（清除所有数据，不可恢复）
```

### 7.3 生命周期事件

每个状态转换都会产生一个事件，记录在 `agent_lifecycle_events` 表中，并触发相应的后续操作：

```typescript
interface AgentLifecycleEvent {
  id: string;
  agent_id: string;
  
  // 状态转换
  from_status: AgentStatus;
  to_status: AgentStatus;
  
  // 触发者
  triggered_by: string;        // user_id 或 'system'
  trigger_reason: string;      // 'manual' | 'auto_restart' | 'health_check' | 'oom' | 'config_update'
  
  // 详情
  details: {
    error_type?: string;       // ERROR 状态的错误类型
    error_message?: string;    // 错误消息
    config_changes?: object;   // UPDATING 时的配置变更内容
    cleanup_status?: string;   // DESTROYING 时的清理进度
  };
  
  // 时间
  created_at: string;
  duration_ms?: number;        // 状态转换耗时
}
```

### 7.4 Agent 自动恢复策略

```
自动恢复规则矩阵：

错误类型              自动恢复策略                  人工介入阈值
─────────────────   ─────────────────────────    ──────────────
container_crash      自动重启（最多 3 次）          3 次均失败
oom_killed           增加 20% 内存后重启            达到内存上限
heartbeat_timeout    自动重启（最多 2 次）          2 次均失败
api_key_invalid      不自动恢复，通知管理员          立即通知
api_rate_limited     等待 60s 后自动恢复            连续 5 次触发
health_check_failed  自动重启（最多 2 次）          2 次均失败
start_timeout        自动重试启动（最多 2 次）       2 次均失败

恢复冷却期：
  - 每次自动恢复后等待 30 秒再检测
  - 如果 5 分钟内触发 3 次以上自动恢复 → 停止自动恢复，转为 ERROR

恢复日志：
  - 所有自动恢复操作记录在 agent_lifecycle_events 表
  - trigger_reason = 'auto_restart'
```

---

## 8. Agent 模板引擎

### 8.1 模板定义规范

Agent 模板是结构化的配置数据，定义了创建特定类型 Agent 所需的所有预设参数。

```typescript
interface AgentTemplate {
  id: string;
  
  // 基本信息
  name: string;                            // 模板名称（如"全栈开发者"）
  slug: string;                            // URL 友好的标识符
  description: string;                     // 详细描述（Markdown）
  short_description: string;               // 简短描述（一行）
  icon: string;                            // 图标标识符
  category: TemplateCategory;              // 分类
  tags: string[];                          // 标签（如 ["开发", "全栈", "推荐"]）
  difficulty: 'beginner' | 'intermediate' | 'advanced';  // 适用难度
  
  // Persona 配置
  persona_template: string;                // 系统 Prompt 模板（支持变量插值）
  persona_variables: PersonaVariable[];    // Prompt 中可自定义的变量
  
  // 模型推荐
  recommended_model: {
    provider: string;                      // 推荐的模型提供商
    model_id: string;                      // 推荐的模型 ID
    reason: string;                        // 推荐理由
  };
  alternative_models: {                    // 可选替代模型
    provider: string;
    model_id: string;
    trade_off: string;                     // 与推荐模型的差异说明
  }[];
  
  // 技能预设
  skills: {
    skill_id: string;
    enabled: boolean;                      // 是否默认启用
    config?: object;                       // 技能特定配置
  }[];
  
  // 权限预设
  permission_preset: 'low' | 'medium' | 'high';
  recommended_team_role: 'executor' | 'reviewer' | 'coordinator' | 'observer';
  
  // 资源预设
  resource_config: {
    cpu: string;                           // 如 "1vCPU"
    memory: string;                        // 如 "2GB"
  };
  
  // 使用统计
  use_count: number;                       // 被使用创建 Agent 的次数
  rating: number;                          // 评分（P2）
  
  // 元数据
  source: 'official' | 'community' | 'enterprise';  // 模板来源
  author: string;                          // 作者
  version: string;                         // 模板版本
  created_at: string;
  updated_at: string;
}

// 模板分类
type TemplateCategory = 
  | 'development'    // 开发
  | 'testing'        // 测试
  | 'design'         // 设计
  | 'product'        // 产品
  | 'operations'     // 运维
  | 'security'       // 安全
  | 'data'           // 数据
  | 'content'        // 内容
  | 'general';       // 通用

// Persona 变量
interface PersonaVariable {
  key: string;                             // 变量名（如 "coding_style"）
  label: string;                           // 显示名称（如 "代码风格"）
  type: 'text' | 'select' | 'boolean';    // 输入类型
  default_value: string;                   // 默认值
  options?: string[];                      // select 类型的选项
  description: string;                     // 变量说明
}
```

### 8.2 官方预设模板详细定义

#### 8.2.1 全栈开发者

```yaml
name: "全栈开发者"
slug: "fullstack-developer"
description: |
  精通前后端开发的全能 Agent，能够独立完成从需求分析到代码实现的全流程。
  擅长 TypeScript/JavaScript 全栈开发，熟悉 React、Next.js、Node.js、PostgreSQL。
  注重代码质量和可维护性。
short_description: "精通前后端开发的全能 AI Agent"
icon: "code-brackets"
category: "development"
tags: ["开发", "全栈", "TypeScript", "推荐"]
difficulty: "intermediate"

persona_template: |
  你是 {{agent_name}}，一个经验丰富的全栈开发者。

  ## 核心能力
  - 前端：React、Next.js、TailwindCSS、TypeScript
  - 后端：Node.js、Express/Fastify、PostgreSQL、Redis
  - 工具：Git、Docker、CI/CD
  
  ## 工作风格
  - 代码风格：{{coding_style}}
  - 注重代码可读性和可维护性
  - 遵循项目的已有代码风格和约定
  - 提交清晰的 Commit Message
  
  ## 行为规范
  - 收到任务后先分析需求，确认理解再动手
  - 遇到不确定的决策点时主动上报
  - 代码完成后自测再提交
  - 提交结果时附带简要的实现说明

persona_variables:
  - key: "coding_style"
    label: "代码风格"
    type: "select"
    default_value: "简洁高效，注重可读性"
    options:
      - "简洁高效，注重可读性"
      - "详细注释，适合团队协作"
      - "最小实现，快速迭代"
    description: "选择 Agent 的代码编写风格偏好"

recommended_model:
  provider: "anthropic"
  model_id: "claude-3-5-sonnet"
  reason: "Claude 3.5 Sonnet 在代码生成和理解方面表现优异，性价比高"

alternative_models:
  - provider: "openai"
    model_id: "gpt-4-turbo"
    trade_off: "推理能力略强，但代码生成速度较慢，成本较高"
  - provider: "google"
    model_id: "gemini-1.5-pro"
    trade_off: "上下文窗口更大（1M tokens），适合处理大型代码库"

skills:
  - skill_id: "code_generation"
    enabled: true
  - skill_id: "code_refactoring"
    enabled: true
  - skill_id: "bug_fix"
    enabled: true
  - skill_id: "code_review"
    enabled: true
  - skill_id: "unit_testing"
    enabled: false  # 默认关闭，用户可启用

permission_preset: "medium"
recommended_team_role: "executor"

resource_config:
  cpu: "1vCPU"
  memory: "2GB"
```

#### 8.2.2 代码审查员

```yaml
name: "代码审查员"
slug: "code-reviewer"
description: |
  严格的代码质量审查 Agent，专注于发现代码中的问题和改进空间。
  从代码风格、性能、安全性、可维护性四个维度进行 Review。
  提供详细的审查报告和改进建议。
short_description: "严格的代码质量审查 Agent"
icon: "magnifying-glass-code"
category: "development"
tags: ["审查", "质量", "安全"]
difficulty: "intermediate"

persona_template: |
  你是 {{agent_name}}，一个严格的代码审查员。

  ## 审查维度
  1. **代码风格**：一致性、命名规范、格式化
  2. **性能**：时间复杂度、内存使用、数据库查询效率
  3. **安全性**：SQL 注入、XSS、认证/授权漏洞、敏感数据泄露
  4. **可维护性**：代码重复、模块化、接口设计、错误处理

  ## 审查风格
  - 严格程度：{{review_strictness}}
  - 每个问题附带改进建议和代码示例
  - 区分"必须修复"和"建议优化"
  - 先肯定做得好的地方，再指出需要改进的

  ## 行为规范
  - 只读访问被审查的代码——不直接修改
  - 审查结果以结构化报告形式输出
  - 严重安全问题标记为 Critical 并上报

persona_variables:
  - key: "review_strictness"
    label: "审查严格程度"
    type: "select"
    default_value: "中等"
    options:
      - "宽松（主要关注严重问题）"
      - "中等（平衡质量和效率）"
      - "严格（不放过任何细节）"
    description: "调整审查的严格程度"

recommended_model:
  provider: "anthropic"
  model_id: "claude-3-5-sonnet"
  reason: "Claude 在代码理解和安全分析方面表现出色"

skills:
  - skill_id: "code_review"
    enabled: true
  - skill_id: "security_audit"
    enabled: true
  - skill_id: "performance_analysis"
    enabled: true

permission_preset: "medium"
recommended_team_role: "reviewer"

resource_config:
  cpu: "1vCPU"
  memory: "2GB"
```

#### 8.2.3 技术写作者

```yaml
name: "技术写作者"
slug: "tech-writer"
description: |
  撰写清晰、准确、易读的技术文档的 Agent。
  擅长 API 文档、架构文档、用户指南、README、Change Log。
  输出格式规范，结构清晰。
short_description: "撰写技术文档和 API 文档的 Agent"
icon: "document-text"
category: "content"
tags: ["文档", "写作", "API"]
difficulty: "beginner"

persona_template: |
  你是 {{agent_name}}，一个专业的技术写作者。

  ## 核心能力
  - API 文档（OpenAPI/Swagger 格式）
  - 架构设计文档
  - 用户指南和教程
  - README 和 Change Log
  - 代码注释和 JSDoc/TSDoc

  ## 写作风格
  - 语言：{{writing_language}}
  - 风格：清晰、准确、不啰嗦
  - 结构：合理的标题层级、目录导航
  - 示例：每个 API/功能附带代码示例

  ## 行为规范
  - 先阅读代码和已有文档再开始撰写
  - 保持与已有文档的风格一致
  - 不编造不存在的 API 或功能
  - 文档完成后自查格式和链接

persona_variables:
  - key: "writing_language"
    label: "文档语言"
    type: "select"
    default_value: "中文"
    options:
      - "中文"
      - "English"
      - "中英双语"
    description: "选择文档的主要撰写语言"

recommended_model:
  provider: "anthropic"
  model_id: "claude-opus"
  reason: "Claude Opus 的长文本生成质量最高，适合撰写长篇技术文档"

skills:
  - skill_id: "doc_writing"
    enabled: true
  - skill_id: "api_doc"
    enabled: true
  - skill_id: "code_analysis"
    enabled: true

permission_preset: "low"
recommended_team_role: "executor"

resource_config:
  cpu: "0.5vCPU"
  memory: "1GB"
```

#### 8.2.4 UI 设计师

```yaml
name: "UI 设计师"
slug: "ui-designer"
description: |
  精通界面设计和前端实现的 Agent。
  能够根据需求设计 UI 组件、实现响应式布局、优化用户体验。
  擅长 TailwindCSS、Shadcn/UI 等现代前端样式方案。
short_description: "精通界面设计和前端实现的 Agent"
icon: "paint-brush"
category: "design"
tags: ["设计", "UI", "前端", "TailwindCSS"]
difficulty: "intermediate"

persona_template: |
  你是 {{agent_name}}，一个精通 UI 设计和前端实现的 Agent。

  ## 核心能力
  - 界面设计：布局、配色、排版、交互
  - 组件开发：React 组件、TailwindCSS 样式
  - 响应式设计：移动端适配、多分辨率支持
  - 设计系统：组件库维护、设计 Token 管理

  ## 设计风格
  - 设计体系：{{design_system}}
  - 注重一致性和可访问性
  - 遵循 WCAG 2.1 AA 标准

recommended_model:
  provider: "openai"
  model_id: "gpt-4-turbo"
  reason: "GPT-4 Turbo 的多模态能力支持更好的视觉理解"

skills:
  - skill_id: "ui_design"
    enabled: true
  - skill_id: "component_dev"
    enabled: true
  - skill_id: "css_styling"
    enabled: true

permission_preset: "medium"
recommended_team_role: "executor"

resource_config:
  cpu: "1vCPU"
  memory: "2GB"
```

#### 8.2.5 安全审计员

```yaml
name: "安全审计员"
slug: "security-auditor"
description: |
  专注安全漏洞检测和修复建议的 Agent。
  覆盖 OWASP Top 10、依赖漏洞、认证/授权缺陷、数据泄露风险。
  提供详细的安全审计报告和修复优先级建议。
short_description: "专注安全漏洞检测和修复的 Agent"
icon: "shield-check"
category: "security"
tags: ["安全", "审计", "OWASP", "漏洞"]
difficulty: "advanced"

persona_template: |
  你是 {{agent_name}}，一个专业的安全审计员。

  ## 审计范围
  - OWASP Top 10 漏洞检测
  - 依赖库漏洞扫描（CVE 数据库匹配）
  - 认证和授权机制审查
  - 敏感数据处理审查（加密、存储、传输）
  - API 安全审查（输入验证、速率限制、CORS）
  - 基础设施安全（Docker 配置、环境变量、密钥管理）

  ## 严重等级
  - Critical: 可被远程利用的高危漏洞
  - High: 可导致数据泄露的漏洞
  - Medium: 可被利用但影响有限
  - Low: 最佳实践建议
  - Info: 信息性发现

  ## 行为规范
  - 只读审计——不修改任何代码或配置
  - 发现 Critical/High 漏洞时立即上报
  - 每个发现附带修复建议和参考链接
  - 审计报告遵循行业标准格式

recommended_model:
  provider: "openai"
  model_id: "gpt-4-turbo"
  reason: "GPT-4 Turbo 的安全分析能力和最新知识覆盖面广"

skills:
  - skill_id: "security_audit"
    enabled: true
  - skill_id: "vulnerability_scan"
    enabled: true
  - skill_id: "code_review"
    enabled: true

permission_preset: "medium"
recommended_team_role: "reviewer"

resource_config:
  cpu: "1vCPU"
  memory: "2GB"
```

### 8.3 模板实例化流程

```
用户选择模板
  │
  ├── 1. 加载模板定义
  │     └── 填充默认 Persona 变量
  │
  ├── 2. 用户自定义（可选）
  │     ├── 修改 Agent 名称
  │     ├── 修改 Persona 变量值
  │     ├── 切换底层模型
  │     ├── 调整技能启用/禁用
  │     └── 调整资源配额
  │
  ├── 3. 变量插值
  │     └── 将 persona_template 中的 {{变量}} 替换为用户选择的值
  │
  ├── 4. 配置验证
  │     ├── 检查名称唯一性
  │     ├── 验证模型 API Key 可用
  │     ├── 验证资源配额在限制范围内
  │     └── 验证技能配置完整
  │
  ├── 5. 创建 Agent 记录
  │     ├── agents 表（基本信息 + status='starting'）
  │     ├── agent_configs 表（Persona + 模型配置）
  │     ├── agent_skills 表（技能列表）
  │     └── agent_deployments 表（部署记录 + template_id）
  │
  ├── 6. 部署 Docker 容器
  │     ├── 构建容器配置
  │     ├── 创建并启动容器
  │     └── 等待健康检查
  │
  └── 7. 上线
        ├── 更新 status = 'online'
        ├── 推送 WebSocket 通知
        └── 记录 template.use_count++
```

### 8.4 Persona 设计最佳实践

模板的 Persona（系统 Prompt）设计遵循以下原则：

```
1. 身份声明
   "你是 {{agent_name}}，一个 [角色描述]"
   → 明确 Agent 的身份认知

2. 核心能力
   列出 Agent 擅长的技能领域
   → 引导 Agent 聚焦在特定领域

3. 工作风格
   描述 Agent 的行为偏好（如代码风格、沟通方式）
   → 可通过变量让用户自定义

4. 行为规范
   明确 Agent 在不同场景下应如何行动
   → 特别是边界条件和异常处理

5. 限制声明
   明确 Agent 不应做的事情
   → 安全边界和权限约束

总长度建议：500-2000 字（太短缺乏指导，太长浪费 Token）
```

### 8.5 模板版本管理

```
模板版本更新场景：
  - 优化 Persona Prompt（发现更好的提示词表达）
  - 更新推荐模型（新模型发布）
  - 调整技能配置（新增或移除技能）
  - 修复模板问题

更新策略：
  - 已创建的 Agent 不受模板更新影响（配置在创建时已固化）
  - 新创建的 Agent 使用最新模板版本
  - 管理员可选择将已有 Agent 的配置同步到最新模板版本（P2）

版本记录：
  - 每次更新记录版本号（语义化版本 + 时间戳）
  - 保留历史版本，支持回溯
```

---

## 9. 数据模型

### 9.1 Agent 主表

```sql
-- Agent 主表
CREATE TABLE agents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id),
  
  -- 基本信息
  name VARCHAR(100) NOT NULL,
  description TEXT,
  icon_url VARCHAR(500),                     -- Agent 图标
  agent_type VARCHAR(30) NOT NULL DEFAULT 'custom'
    CHECK (agent_type IN ('custom', 'template_based', 'forked', 'imported')),
  
  -- 来源信息
  template_id UUID REFERENCES agent_templates(id),    -- 模板创建时记录
  forked_from UUID REFERENCES agents(id),             -- Fork 创建时记录
  
  -- 生命周期状态
  status VARCHAR(20) NOT NULL DEFAULT 'draft'
    CHECK (status IN (
      'draft', 'starting', 'online', 'busy', 'stopped',
      'error', 'updating', 'destroying', 'destroyed'
    )),
  
  -- 错误信息（status = 'error' 时）
  error_type VARCHAR(50),
  error_message TEXT,
  error_at TIMESTAMPTZ,
  
  -- 统计缓存（异步更新）
  total_tasks INTEGER DEFAULT 0,
  completed_tasks INTEGER DEFAULT 0,
  success_rate DECIMAL(5,4) DEFAULT 0,          -- 如 0.9700
  avg_task_duration_seconds INTEGER DEFAULT 0,
  tasks_this_week INTEGER DEFAULT 0,
  
  -- 审计
  created_by UUID NOT NULL,                     -- 创建者 user_id
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deployed_at TIMESTAMPTZ,                      -- 首次部署时间
  destroyed_at TIMESTAMPTZ,
  
  UNIQUE(workspace_id, name)
);

-- 索引
CREATE INDEX idx_agents_workspace ON agents(workspace_id, status);
CREATE INDEX idx_agents_status ON agents(status, updated_at DESC);
CREATE INDEX idx_agents_template ON agents(template_id) WHERE template_id IS NOT NULL;
CREATE INDEX idx_agents_forked ON agents(forked_from) WHERE forked_from IS NOT NULL;
CREATE INDEX idx_agents_created_by ON agents(created_by);
```

### 9.2 Agent 配置表

```sql
-- Agent 配置表（与 agents 表一对一）
CREATE TABLE agent_configs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID NOT NULL REFERENCES agents(id) ON DELETE CASCADE,
  
  -- Persona 配置
  persona TEXT NOT NULL,                       -- 系统 Prompt（Markdown）
  persona_version INTEGER DEFAULT 1,           -- Persona 版本号（每次修改递增）
  
  -- 模型配置
  model_provider VARCHAR(50) NOT NULL,         -- 'anthropic' | 'openai' | 'google' | 'deepseek' | 'openrouter'
  model_id VARCHAR(100) NOT NULL,              -- 如 'claude-3-5-sonnet-20241022'
  model_display_name VARCHAR(100),             -- 如 'Claude 3.5 Sonnet'
  model_config JSONB DEFAULT '{}',             -- 模型特定配置（temperature, max_tokens 等）
  
  -- 权限等级
  permission_level VARCHAR(10) NOT NULL DEFAULT 'medium'
    CHECK (permission_level IN ('low', 'medium', 'high')),
  
  -- 资源配额
  cpu_limit VARCHAR(20) DEFAULT '1vCPU',       -- 如 '0.5vCPU', '1vCPU', '2vCPU'
  memory_limit VARCHAR(20) DEFAULT '2GB',      -- 如 '512MB', '1GB', '2GB', '4GB'
  
  -- API 配置
  api_key_ref VARCHAR(200),                    -- API Key 引用（不存储明文，引用 secrets manager）
  
  -- 版本
  config_version INTEGER DEFAULT 1,            -- 整体配置版本号
  
  -- 时间
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  UNIQUE(agent_id)
);

-- 索引
CREATE INDEX idx_agent_configs_agent ON agent_configs(agent_id);
CREATE INDEX idx_agent_configs_model ON agent_configs(model_provider, model_id);
```

### 9.3 Agent 技能表

```sql
-- Agent 技能关联表
CREATE TABLE agent_skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID NOT NULL REFERENCES agents(id) ON DELETE CASCADE,
  
  -- 技能信息
  skill_id VARCHAR(50) NOT NULL,               -- 技能标识符（如 'code_generation'）
  skill_name VARCHAR(100) NOT NULL,            -- 技能显示名称（如 '代码生成'）
  enabled BOOLEAN NOT NULL DEFAULT TRUE,       -- 是否启用
  
  -- 技能特定配置
  config JSONB DEFAULT '{}',                   -- 技能级配置（如审查严格程度）
  
  -- 时间
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  UNIQUE(agent_id, skill_id)
);

-- 索引
CREATE INDEX idx_agent_skills_agent ON agent_skills(agent_id) WHERE enabled = TRUE;
CREATE INDEX idx_agent_skills_skill ON agent_skills(skill_id);
```

### 9.4 Agent 模板表

```sql
-- Agent 模板表
CREATE TABLE agent_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- 基本信息
  name VARCHAR(100) NOT NULL,
  slug VARCHAR(100) NOT NULL UNIQUE,
  description TEXT NOT NULL,                    -- Markdown 格式详细描述
  short_description VARCHAR(200) NOT NULL,
  icon VARCHAR(50) NOT NULL,
  category VARCHAR(30) NOT NULL
    CHECK (category IN (
      'development', 'testing', 'design', 'product',
      'operations', 'security', 'data', 'content', 'general'
    )),
  tags JSONB DEFAULT '[]',                      -- 标签数组
  difficulty VARCHAR(20) DEFAULT 'intermediate'
    CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  
  -- Persona 模板
  persona_template TEXT NOT NULL,               -- 含变量插值的 Prompt 模板
  persona_variables JSONB DEFAULT '[]',         -- PersonaVariable 数组
  
  -- 模型推荐
  recommended_model JSONB NOT NULL,             -- { provider, model_id, reason }
  alternative_models JSONB DEFAULT '[]',        -- [{ provider, model_id, trade_off }]
  
  -- 技能预设
  skills_preset JSONB NOT NULL,                 -- [{ skill_id, enabled, config }]
  
  -- 权限和资源预设
  permission_preset VARCHAR(10) DEFAULT 'medium'
    CHECK (permission_preset IN ('low', 'medium', 'high')),
  recommended_team_role VARCHAR(20) DEFAULT 'executor'
    CHECK (recommended_team_role IN ('executor', 'reviewer', 'coordinator', 'observer')),
  resource_config JSONB NOT NULL,               -- { cpu, memory }
  
  -- 使用统计
  use_count INTEGER DEFAULT 0,
  rating DECIMAL(3,2) DEFAULT 0,               -- 评分（P2）
  
  -- 来源
  source VARCHAR(20) NOT NULL DEFAULT 'official'
    CHECK (source IN ('official', 'community', 'enterprise')),
  author VARCHAR(100),
  
  -- 版本
  version VARCHAR(20) NOT NULL DEFAULT '1.0.0',
  
  -- 状态
  is_active BOOLEAN DEFAULT TRUE,               -- 是否在市场中展示
  
  -- 时间
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_templates_category ON agent_templates(category) WHERE is_active = TRUE;
CREATE INDEX idx_templates_source ON agent_templates(source) WHERE is_active = TRUE;
CREATE INDEX idx_templates_slug ON agent_templates(slug);
CREATE INDEX idx_templates_popular ON agent_templates(use_count DESC) WHERE is_active = TRUE;
```

### 9.5 Agent 性能指标表

```sql
-- Agent 性能指标（时序数据，定期聚合）
CREATE TABLE agent_metrics (
  id BIGSERIAL PRIMARY KEY,
  agent_id UUID NOT NULL REFERENCES agents(id) ON DELETE CASCADE,
  
  -- 时间窗口
  period_start TIMESTAMPTZ NOT NULL,
  period_end TIMESTAMPTZ NOT NULL,
  period_type VARCHAR(10) NOT NULL
    CHECK (period_type IN ('hourly', 'daily', 'weekly')),
  
  -- 任务指标
  tasks_total INTEGER DEFAULT 0,               -- 总任务数
  tasks_completed INTEGER DEFAULT 0,           -- 完成数
  tasks_failed INTEGER DEFAULT 0,              -- 失败数
  tasks_interrupted INTEGER DEFAULT 0,         -- 被中断数
  success_rate DECIMAL(5,4),                   -- 成功率
  
  -- 时间指标
  avg_task_duration_seconds INTEGER,           -- 平均任务时长
  p95_task_duration_seconds INTEGER,           -- P95 任务时长
  total_busy_seconds INTEGER DEFAULT 0,        -- 忙碌总时长
  total_online_seconds INTEGER DEFAULT 0,      -- 在线总时长
  
  -- 资源指标
  avg_cpu_percent DECIMAL(5,2),                -- 平均 CPU 使用率
  max_cpu_percent DECIMAL(5,2),                -- 最大 CPU 使用率
  avg_memory_mb INTEGER,                       -- 平均内存使用 (MB)
  max_memory_mb INTEGER,                       -- 最大内存使用 (MB)
  
  -- API 调用指标
  llm_api_calls INTEGER DEFAULT 0,             -- LLM API 调用次数
  llm_input_tokens BIGINT DEFAULT 0,           -- 输入 Token 数
  llm_output_tokens BIGINT DEFAULT 0,          -- 输出 Token 数
  estimated_cost_usd DECIMAL(10,4),            -- 估算成本 (USD)
  
  -- 错误指标
  error_count INTEGER DEFAULT 0,               -- 错误次数
  restart_count INTEGER DEFAULT 0,             -- 重启次数
  
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  UNIQUE(agent_id, period_start, period_type)
);

-- 索引
CREATE INDEX idx_agent_metrics_agent ON agent_metrics(agent_id, period_type, period_start DESC);
CREATE INDEX idx_agent_metrics_period ON agent_metrics(period_type, period_start DESC);
```

### 9.6 Agent Fork 记录表

```sql
-- Agent Fork 记录表
CREATE TABLE agent_forks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Fork 关系
  source_agent_id UUID NOT NULL REFERENCES agents(id),
  forked_agent_id UUID NOT NULL REFERENCES agents(id),
  
  -- Fork 配置
  memory_copy_strategy VARCHAR(20) NOT NULL DEFAULT 'full'
    CHECK (memory_copy_strategy IN ('full', 'selective', 'none')),
  memory_copy_details JSONB,                   -- selective 时的选择详情
  
  -- Fork 时的配置快照
  source_config_snapshot JSONB NOT NULL,        -- 源 Agent 在 Fork 时的配置
  config_changes JSONB,                        -- Fork 后用户修改的配置差异
  
  -- 审计
  forked_by UUID NOT NULL,                     -- 执行 Fork 的 user_id
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_forks_source ON agent_forks(source_agent_id);
CREATE INDEX idx_forks_forked ON agent_forks(forked_agent_id);
```

### 9.7 Agent 部署记录表

```sql
-- Agent 部署记录表
CREATE TABLE agent_deployments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID NOT NULL REFERENCES agents(id) ON DELETE CASCADE,
  
  -- 部署信息
  deployment_type VARCHAR(20) NOT NULL
    CHECK (deployment_type IN ('initial', 'restart', 'update', 'rollback')),
  
  -- 容器信息
  container_id VARCHAR(100),                    -- Docker 容器 ID
  container_image VARCHAR(200),                 -- Docker 镜像名称和标签
  host_vm_id VARCHAR(100),                     -- 宿主 VM ID
  
  -- 配置快照
  config_snapshot JSONB NOT NULL,               -- 部署时的完整配置快照
  
  -- 状态
  status VARCHAR(20) NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'running', 'succeeded', 'failed')),
  
  -- 耗时
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  duration_ms INTEGER,
  
  -- 错误信息（如果失败）
  error_message TEXT,
  
  -- 审计
  triggered_by UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_deployments_agent ON agent_deployments(agent_id, created_at DESC);
CREATE INDEX idx_deployments_status ON agent_deployments(status) WHERE status = 'running';
```

### 9.8 Agent 生命周期事件表

```sql
-- Agent 生命周期事件日志
CREATE TABLE agent_lifecycle_events (
  id BIGSERIAL PRIMARY KEY,
  agent_id UUID NOT NULL REFERENCES agents(id) ON DELETE CASCADE,
  
  -- 状态转换
  from_status VARCHAR(20) NOT NULL,
  to_status VARCHAR(20) NOT NULL,
  
  -- 触发者
  triggered_by UUID,                           -- user_id 或 NULL（系统触发）
  trigger_type VARCHAR(20) NOT NULL
    CHECK (trigger_type IN ('manual', 'auto_restart', 'health_check', 'oom', 'config_update', 'system')),
  trigger_reason TEXT,
  
  -- 详情
  details JSONB,
  
  -- 时间
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  duration_ms INTEGER                          -- 状态转换耗时
);

-- 索引
CREATE INDEX idx_lifecycle_agent ON agent_lifecycle_events(agent_id, created_at DESC);
CREATE INDEX idx_lifecycle_status ON agent_lifecycle_events(to_status, created_at DESC);
```

### 9.9 Agent 配置历史表

```sql
-- Agent 配置变更历史（版本管理）
CREATE TABLE agent_config_history (
  id BIGSERIAL PRIMARY KEY,
  agent_id UUID NOT NULL REFERENCES agents(id) ON DELETE CASCADE,
  
  -- 版本
  config_version INTEGER NOT NULL,
  
  -- 变更内容
  change_type VARCHAR(30) NOT NULL,            -- 'persona' | 'model' | 'skills' | 'permissions' | 'resources' | 'full'
  old_value JSONB,
  new_value JSONB,
  change_summary VARCHAR(200),                 -- 人类可读摘要
  
  -- 审计
  changed_by UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_config_history_agent ON agent_config_history(agent_id, config_version DESC);
```

### 9.10 ER 关系图

```
workspaces
  │
  └── agents ──────────────── agent_configs (1:1, Persona + 模型 + 权限 + 资源)
        │                         │
        │                         └── agent_config_history (配置变更记录)
        │
        ├── agent_skills (1:N, 技能列表)
        │
        ├── agent_metrics (1:N, 性能指标时序数据)
        │
        ├── agent_deployments (1:N, 部署记录)
        │
        ├── agent_lifecycle_events (1:N, 生命周期事件日志)
        │
        ├── agent_forks (N:1, Fork 关系)
        │     ├── source_agent_id → agents.id
        │     └── forked_agent_id → agents.id
        │
        └── agent_templates (N:1, 模板来源)
              └── agent_templates (模板市场)

外部关联：
  agents.id → team_members.member_id (当 member_type = 'agent', Module 4)
  agents.id → tasks.assignee_id (当 assignee_type = 'agent', Module 2)
  agents.workspace_id → workspaces.id
```

### 9.11 与 Module 4 的数据关系

```
Module 5 agents 表                    Module 4 team_members 表
─────────────────                    ─────────────────────────
agents.id           ─────────────→   team_members.member_id
                                      (当 member_type = 'agent')

agents.name          → display_name  (冗余缓存)
agents.icon_url      → avatar_url    (冗余缓存)
agents.status        → agent_team_status.status  (状态同步)

数据流向：
  1. Module 5 创建 Agent → Module 4 可在"Agent 市场浏览器"中看到
  2. Module 4 "添加 Agent 到团队" → 在 team_members 表创建记录，引用 agents.id
  3. Module 5 Agent 状态变更 → 同步到 Module 4 agent_team_status 表
  4. Module 5 Agent 被销毁 → 从 Module 4 所有团队中自动移除
```

---

## 10. 技术方案

### 10.1 整体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                          客户端层                                    │
│  Web (Next.js + TailwindCSS)                                        │
│  ├── Agent Dashboard (仪表板卡片网格)                                │
│  ├── Agent Create Wizard (创建向导)                                  │
│  ├── Agent Detail Page (详情页: 配置 + 监控 + 活动)                  │
│  ├── Template Market (模板市场浏览器)                                │
│  ├── Agent Config Editor (配置编辑器: Persona + 模型 + 技能)          │
│  └── Fork Dialog (Fork 对话框)                                      │
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
│  Agent Service ──── Container Manager ──── Health Monitor            │
│       │                    │                      │                  │
│       │             Docker Engine API        Status Updater          │
│       │                    │                      │                  │
│  ┌────┴────────────────────┴──────────────────────┴──────┐          │
│  │              Event Bus (Redis Streams)                   │          │
│  └────┬────────────────────┬───────────────────────┬──────┘          │
│       │                    │                       │                  │
│  Template              Metrics               Lifecycle               │
│  Service              Aggregator             Logger                   │
│       │                    │                       │                  │
│  Config Import/       LLM Token              Notification            │
│  Export Service        Counter                Service                 │
└───────────────────────┬─────────────────────────────────────────────┘
                        │
┌───────────────────────┴─────────────────────────────────────────────┐
│                        数据层                                        │
│  PostgreSQL 16 (Cloud SQL)  │  Redis 7 (Memorystore)                │
│  (agents, agent_configs,    │  (agent status cache, metrics buffer,  │
│   agent_templates,          │   event bus, websocket pub/sub,        │
│   agent_metrics)            │   container status)                    │
└─────────────────────────────────────────────────────────────────────┘
                        │
┌───────────────────────┴─────────────────────────────────────────────┐
│                      Docker Runtime Layer                            │
│                                                                      │
│  宿主 VM (每 Workspace 一台)                                         │
│  ├── Agent Container 1 (代码助手, Claude 3.5 Sonnet)                 │
│  ├── Agent Container 2 (测试 Agent, GPT-4 Turbo)                    │
│  ├── Agent Container 3 (产品助手, Claude Opus)                       │
│  └── Agent Manager (容器编排 + 健康检查 + 资源监控)                   │
└─────────────────────────────────────────────────────────────────────┘
```

### 10.2 API 设计

#### RESTful API

```
# Agent CRUD
GET    /api/v1/workspaces/:wid/agents                # 获取 Agent 列表（仪表板）
POST   /api/v1/workspaces/:wid/agents                # 创建 Agent（自定义或从模板）
GET    /api/v1/agents/:aid                            # 获取 Agent 详情
PATCH  /api/v1/agents/:aid                            # 更新 Agent 基本信息
DELETE /api/v1/agents/:aid                            # 销毁 Agent

# Agent 配置
GET    /api/v1/agents/:aid/config                     # 获取 Agent 配置
PATCH  /api/v1/agents/:aid/config                     # 更新 Agent 配置（Persona/模型/权限/资源）
GET    /api/v1/agents/:aid/config/history              # 获取配置变更历史
POST   /api/v1/agents/:aid/config/rollback             # 回滚到指定版本

# Agent 技能
GET    /api/v1/agents/:aid/skills                     # 获取 Agent 技能列表
PATCH  /api/v1/agents/:aid/skills/:sid                # 启用/禁用技能

# Agent 生命周期操作
POST   /api/v1/agents/:aid/deploy                     # 部署（DRAFT → STARTING）
POST   /api/v1/agents/:aid/start                      # 启动（STOPPED → STARTING）
POST   /api/v1/agents/:aid/stop                       # 停止（ONLINE/BUSY → STOPPED）
POST   /api/v1/agents/:aid/restart                    # 重启（任意运行状态 → STARTING）
POST   /api/v1/agents/:aid/destroy                    # 销毁（任意状态 → DESTROYING）

# Agent 状态与监控
GET    /api/v1/agents/:aid/status                     # 获取 Agent 实时状态
GET    /api/v1/agents/:aid/metrics                    # 获取性能指标（支持时间范围）
GET    /api/v1/agents/:aid/metrics/realtime           # 获取实时资源使用
GET    /api/v1/agents/:aid/activities                  # 获取活动日志
GET    /api/v1/agents/:aid/errors                     # 获取错误日志

# Agent Fork
POST   /api/v1/agents/:aid/fork                       # Fork Agent

# Agent 导入/导出
POST   /api/v1/workspaces/:wid/agents/import          # 导入 Agent 配置
GET    /api/v1/agents/:aid/export                     # 导出 Agent 配置

# Agent 模板市场
GET    /api/v1/templates                              # 获取模板列表
GET    /api/v1/templates/:tid                         # 获取模板详情
POST   /api/v1/templates/:tid/instantiate             # 从模板创建 Agent

# 系统级
GET    /api/v1/models                                 # 获取可用模型列表
GET    /api/v1/skills                                 # 获取可用技能列表
```

#### 请求/响应示例

**创建 Agent（从模板）：**

```typescript
// POST /api/v1/templates/:tid/instantiate
// Request
{
  "name": "代码助手",
  "icon_url": "https://cdn.codeyi.com/agent-icons/code-bot.png",
  "overrides": {
    "model": {
      "provider": "anthropic",
      "model_id": "claude-3-5-sonnet-20241022"
    },
    "persona_variables": {
      "coding_style": "简洁高效，注重可读性"
    },
    "skills": {
      "unit_testing": { "enabled": true }
    },
    "resources": {
      "cpu": "1vCPU",
      "memory": "2GB"
    }
  },
  "auto_deploy": true
}

// Response 201
{
  "id": "agent_code_001",
  "name": "代码助手",
  "workspace_id": "ws_abc123",
  "agent_type": "template_based",
  "template_id": "tpl_fullstack_dev",
  "status": "starting",
  "config": {
    "persona": "你是 代码助手，一个经验丰富的全栈开发者...",
    "model_provider": "anthropic",
    "model_id": "claude-3-5-sonnet-20241022",
    "model_display_name": "Claude 3.5 Sonnet",
    "permission_level": "medium",
    "cpu_limit": "1vCPU",
    "memory_limit": "2GB"
  },
  "skills": [
    { "skill_id": "code_generation", "enabled": true },
    { "skill_id": "code_refactoring", "enabled": true },
    { "skill_id": "bug_fix", "enabled": true },
    { "skill_id": "code_review", "enabled": true },
    { "skill_id": "unit_testing", "enabled": true }
  ],
  "created_by": "user_chenmh",
  "created_at": "2026-04-20T10:00:00Z"
}
```

**获取 Agent 列表（仪表板）：**

```typescript
// GET /api/v1/workspaces/:wid/agents?status=online,busy,stopped,error
// Response 200
{
  "agents": [
    {
      "id": "agent_code_001",
      "name": "代码助手",
      "icon_url": "https://cdn.codeyi.com/agent-icons/code-bot.png",
      "status": "online",
      "model_display_name": "Claude 3.5 Sonnet",
      "skills": ["代码生成", "重构", "Code Review", "测试"],
      "tasks_this_week": 23,
      "success_rate": 0.97,
      "avg_task_duration_seconds": 252,
      "last_active_at": "2026-04-20T09:58:00Z"
    },
    {
      "id": "agent_test_001",
      "name": "测试 Agent",
      "icon_url": "https://cdn.codeyi.com/agent-icons/test-bot.png",
      "status": "online",
      "model_display_name": "GPT-4 Turbo",
      "skills": ["单元测试", "集成测试", "E2E"],
      "tasks_this_week": 18,
      "success_rate": 0.94,
      "avg_task_duration_seconds": 408,
      "last_active_at": "2026-04-20T09:50:00Z"
    },
    {
      "id": "agent_product_001",
      "name": "产品助手",
      "icon_url": "https://cdn.codeyi.com/agent-icons/product-bot.png",
      "status": "busy",
      "model_display_name": "Claude Opus",
      "skills": ["需求分析", "PRD 撰写", "用户故事"],
      "tasks_this_week": 8,
      "success_rate": 1.00,
      "avg_task_duration_seconds": 720,
      "current_task": {
        "id": "task_xyz",
        "title": "撰写 Module 5 PRD"
      },
      "last_active_at": "2026-04-20T10:00:00Z"
    },
    {
      "id": "agent_data_001",
      "name": "数据分析 Agent",
      "icon_url": "https://cdn.codeyi.com/agent-icons/data-bot.png",
      "status": "online",
      "model_display_name": "Gemini 1.5 Pro",
      "skills": ["数据清洗", "可视化", "报表生成"],
      "tasks_this_week": 12,
      "success_rate": 0.95,
      "avg_task_duration_seconds": 210,
      "last_active_at": "2026-04-20T09:45:00Z"
    }
  ],
  "total": 4,
  "status_summary": {
    "online": 3,
    "busy": 1,
    "stopped": 0,
    "error": 0
  }
}
```

**Fork Agent：**

```typescript
// POST /api/v1/agents/:aid/fork
// Request
{
  "name": "代码助手-项目B",
  "memory_copy_strategy": "full",
  "config_overrides": {
    "model": {
      "provider": "openai",
      "model_id": "gpt-4-turbo"
    }
  },
  "auto_deploy": true
}

// Response 201
{
  "id": "agent_code_002",
  "name": "代码助手-项目B",
  "agent_type": "forked",
  "forked_from": "agent_code_001",
  "status": "starting",
  "fork_details": {
    "memory_copy_strategy": "full",
    "source_config_snapshot": { ... },
    "config_changes": {
      "model_provider": "anthropic → openai",
      "model_id": "claude-3-5-sonnet → gpt-4-turbo"
    }
  },
  "created_at": "2026-04-20T10:05:00Z"
}
```

**获取 Agent 性能指标：**

```typescript
// GET /api/v1/agents/:aid/metrics?period=weekly&range=30d
// Response 200
{
  "agent_id": "agent_code_001",
  "metrics": [
    {
      "period_start": "2026-04-14T00:00:00Z",
      "period_end": "2026-04-20T23:59:59Z",
      "period_type": "weekly",
      "tasks_total": 23,
      "tasks_completed": 22,
      "tasks_failed": 1,
      "success_rate": 0.9565,
      "avg_task_duration_seconds": 252,
      "p95_task_duration_seconds": 480,
      "avg_cpu_percent": 48.5,
      "avg_memory_mb": 1280,
      "llm_api_calls": 156,
      "llm_input_tokens": 2450000,
      "llm_output_tokens": 380000,
      "estimated_cost_usd": 12.50,
      "error_count": 1,
      "restart_count": 0
    },
    {
      "period_start": "2026-04-07T00:00:00Z",
      "period_end": "2026-04-13T23:59:59Z",
      "period_type": "weekly",
      "tasks_total": 19,
      "tasks_completed": 19,
      "tasks_failed": 0,
      "success_rate": 1.0,
      "avg_task_duration_seconds": 238,
      "p95_task_duration_seconds": 420,
      "avg_cpu_percent": 42.3,
      "avg_memory_mb": 1180,
      "llm_api_calls": 132,
      "llm_input_tokens": 2100000,
      "llm_output_tokens": 320000,
      "estimated_cost_usd": 10.80,
      "error_count": 0,
      "restart_count": 0
    }
  ]
}
```

### 10.3 WebSocket 事件

```typescript
// 客户端 → 服务端
interface WsClientEvents {
  'agents:subscribe': { workspace_id: string };         // 订阅 Agent 列表更新
  'agents:unsubscribe': { workspace_id: string };
  'agent:subscribe': { agent_id: string };              // 订阅单个 Agent 详情更新
  'agent:unsubscribe': { agent_id: string };
}

// 服务端 → 客户端
interface WsServerEvents {
  // Agent 列表更新
  'agent:created': { agent: AgentSummary };
  'agent:destroyed': { agent_id: string };
  
  // Agent 状态变更
  'agent:status_changed': {
    agent_id: string;
    old_status: AgentStatus;
    new_status: AgentStatus;
    details?: {
      error_type?: string;
      error_message?: string;
      current_task_id?: string;
      current_task_title?: string;
    };
  };
  
  // Agent 配置变更
  'agent:config_updated': {
    agent_id: string;
    change_type: string;
    change_summary: string;
  };
  
  // 实时资源使用
  'agent:resource_update': {
    agent_id: string;
    cpu_percent: number;
    memory_mb: number;
    timestamp: string;
  };
  
  // 任务进度
  'agent:task_progress': {
    agent_id: string;
    task_id: string;
    task_title: string;
    progress: number;
  };
  
  // 任务完成
  'agent:task_completed': {
    agent_id: string;
    task_id: string;
    success: boolean;
    duration_seconds: number;
  };
  
  // 错误告警
  'agent:error': {
    agent_id: string;
    error_type: string;
    error_message: string;
    timestamp: string;
  };
}
```

### 10.4 Docker 容器管理

#### Container Manager 架构

```
┌──────────────────────────────────────────────────────────────────┐
│                    Container Manager                              │
│                                                                  │
│  API Layer (内部 gRPC / HTTP)                                    │
│    ├── CreateContainer(agent_id, config)                         │
│    ├── StartContainer(agent_id)                                  │
│    ├── StopContainer(agent_id, grace_period)                     │
│    ├── RestartContainer(agent_id)                                │
│    ├── DestroyContainer(agent_id)                                │
│    ├── GetContainerStatus(agent_id)                              │
│    ├── GetContainerLogs(agent_id, since, tail)                   │
│    └── GetContainerStats(agent_id)                               │
│                                                                  │
│  Container Lifecycle                                             │
│    ├── 创建容器                                                  │
│    │   1. 拉取基础镜像 (codeyi/agent-runtime:latest)             │
│    │   2. 生成 docker-compose.yml                                │
│    │   3. 注入配置（环境变量 + 挂载 Volume）                     │
│    │   4. 设置资源限制 (cgroup: cpu, memory)                     │
│    │   5. 配置网络（容器间隔离，宿主网络桥接）                    │
│    │   6. 设置重启策略 (on-failure:3)                            │
│    │   7. docker create + docker start                           │
│    │                                                             │
│    ├── 健康检查                                                  │
│    │   - HTTP 健康检查端点：GET /health                          │
│    │   - 间隔：10s，超时：5s，重试：3 次                         │
│    │   - 检查项：进程存活 + LLM API 可达 + 内存充足              │
│    │                                                             │
│    └── 资源监控                                                  │
│        - docker stats 采集 (每 10s)                              │
│        - CPU、内存、网络 I/O、磁盘 I/O                           │
│        - 超出阈值告警 (CPU > 90%, MEM > 85%)                    │
│                                                                  │
│  容器配置模板:                                                   │
│    image: codeyi/agent-runtime:latest                            │
│    environment:                                                  │
│      - AGENT_ID=${agent_id}                                      │
│      - WORKSPACE_ID=${workspace_id}                              │
│      - MODEL_PROVIDER=${model_provider}                          │
│      - MODEL_ID=${model_id}                                      │
│      - API_KEY=${api_key}  # 从 Secrets Manager 注入             │
│      - PERSONA=${persona}  # 或通过 Volume 挂载                  │
│      - BACKEND_URL=${backend_api_url}                            │
│    resources:                                                    │
│      limits:                                                     │
│        cpus: "${cpu_limit}"                                      │
│        memory: "${memory_limit}"                                 │
│    volumes:                                                      │
│      - agent_${agent_id}_data:/app/data    # 持久化数据          │
│      - agent_${agent_id}_memory:/app/memory # Memory 存储        │
│    restart: on-failure:3                                         │
│    healthcheck:                                                  │
│      test: ["CMD", "curl", "-f", "http://localhost:8080/health"] │
│      interval: 10s                                               │
│      timeout: 5s                                                 │
│      retries: 3                                                  │
└──────────────────────────────────────────────────────────────────┘
```

#### Agent 基础镜像

```dockerfile
# codeyi/agent-runtime:latest
FROM node:20-slim

# 安装基础工具
RUN apt-get update && apt-get install -y \
    git curl python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 安装 Agent 运行时框架
COPY agent-runtime/ /app/
WORKDIR /app
RUN npm ci --production

# 健康检查端点
EXPOSE 8080

# 启动命令
CMD ["node", "agent-main.js"]
```

### 10.5 健康监控架构

```
┌──────────────────────┐       heartbeat (30s)       ┌──────────────────────┐
│  Agent 容器           │ ─────────────────────────── │  Health Monitor      │
│                      │                             │  (宿主进程)          │
│  agent-main.js       │       health report         │                      │
│  ├── 定时心跳        │ ─────────────────────────── │  1. 接收心跳         │
│  ├── 状态上报        │                             │  2. 检查容器健康     │
│  ├── 资源自检        │       resource stats         │  3. 采集资源数据     │
│  └── 错误上报        │ ─────────────────────────── │  4. 更新 Redis       │
│                      │                             │  5. 更新 PostgreSQL  │
└──────────────────────┘                             │  6. 推送 WebSocket   │
                                                     └──────────┬───────────┘
                                                                │
                                                      ┌─────────┴──────────┐
                                                      │  Timeout Detector  │
                                                      │  (定时任务, 60s)   │
                                                      │                    │
                                                      │  遍历所有 online/  │
                                                      │  busy 的 Agent     │
                                                      │  最后心跳 > 90s    │
                                                      │  → 标记 error      │
                                                      │  → 触发自动恢复    │
                                                      │  → 通知管理员      │
                                                      └────────────────────┘

心跳消息格式:
{
  "agent_id": "agent_code_001",
  "status": "online",
  "current_task_id": null,
  "resource_usage": {
    "cpu_percent": 48.5,
    "memory_mb": 1280,
    "memory_limit_mb": 2048
  },
  "llm_stats": {
    "api_calls_since_last": 3,
    "tokens_since_last": 15000
  },
  "uptime_seconds": 86400,
  "timestamp": "2026-04-20T09:59:30Z"
}

Redis 状态缓存:
  Key: agent:{agent_id}:status
  Value: {
    "status": "online",
    "cpu_percent": 48.5,
    "memory_mb": 1280,
    "current_task_id": null,
    "last_heartbeat": "2026-04-20T09:59:30Z",
    "uptime_seconds": 86400
  }
  TTL: 无（由 Timeout Detector 管理）
```

### 10.6 模型热切换架构

```
管理员修改模型配置
  │
  ├── 1. API: PATCH /agents/:aid/config
  │     body: { model_provider: "openai", model_id: "gpt-4-turbo" }
  │
  ├── 2. 后端处理
  │     ├── 验证新模型 API Key 可用
  │     ├── 更新 agent_configs 表
  │     ├── 记录 agent_config_history
  │     ├── 递增 config_version
  │     └── 通知 Container Manager
  │
  ├── 3. Container Manager
  │     ├── 发送配置更新指令到容器（HTTP POST /config/reload）
  │     ├── 不需要重建容器
  │     └── 不需要重启进程
  │
  ├── 4. Agent 容器内部
  │     ├── 接收 /config/reload
  │     ├── 更新内存中的模型配置
  │     ├── 下一次 LLM API 调用使用新模型
  │     └── 返回 reload 结果
  │
  └── 5. 前端更新
        ├── WebSocket: agent:config_updated
        └── Agent 卡片上的模型名称更新

时间线（正常情况）：
  T+0s:   管理员点击保存
  T+0.5s: 后端验证 + 数据库更新
  T+1s:   容器配置重载
  T+1.5s: 前端 UI 更新
  总计: < 2 秒
```

### 10.7 前端架构

```
pages/
  agents/
    index.tsx              # Agent 仪表板（卡片网格 + 模板市场入口）
    create/
      index.tsx            # 创建向导
      template.tsx         # 从模板创建
      custom.tsx           # 自定义创建
    [agentId]/
      index.tsx            # Agent 详情页
      config.tsx           # 配置编辑
      metrics.tsx          # 性能指标
      activities.tsx       # 活动日志
    import.tsx             # 导入配置页面
    templates/
      index.tsx            # 模板市场浏览
      [templateId].tsx     # 模板详情

components/
  agents/
    dashboard/
      AgentCard.tsx             # Agent 仪表板卡片
      AgentCardGrid.tsx         # 卡片网格
      AgentStatusBadge.tsx      # 状态指示器
      AgentSkillTags.tsx        # 技能标签组
      AgentStatsBar.tsx         # 统计信息条
      DashboardFilters.tsx      # 搜索/筛选/排序
      
    create/
      CreateWizard.tsx          # 创建向导容器
      TemplateSelector.tsx      # 模板选择步骤
      ModelSelector.tsx         # 模型选择器
      PersonaEditor.tsx         # Persona 编辑器（Markdown）
      SkillPicker.tsx           # 技能选择器（开关列表）
      PermissionSelector.tsx    # 权限等级选择
      ResourceConfig.tsx        # 资源配额配置
      DeployPreview.tsx         # 部署前预览
      
    detail/
      AgentDetailHeader.tsx     # 详情页头部（名称+状态+操作）
      AgentConfigPanel.tsx      # 配置面板
      AgentMetricsChart.tsx     # 性能指标图表
      AgentActivityTimeline.tsx # 活动时间线
      AgentResourceGauge.tsx    # 资源使用仪表盘
      AgentErrorLog.tsx         # 错误日志列表
      
    templates/
      TemplateCard.tsx          # 模板卡片
      TemplateGrid.tsx          # 模板网格
      TemplateDetail.tsx        # 模板详情
      TemplatePreview.tsx       # 模板效果预览
      
    fork/
      ForkDialog.tsx            # Fork 对话框
      MemoryStrategySelector.tsx # Memory 复制策略选择
      ForkPreview.tsx           # Fork 预览
      
    import-export/
      ImportDialog.tsx          # 导入对话框
      ConfigFileUploader.tsx    # 配置文件上传器
      ImportPreview.tsx         # 导入预览
      ExportButton.tsx          # 导出按钮
```

**关键组件设计：**

**AgentCard（仪表板卡片）：**

```tsx
// components/agents/dashboard/AgentCard.tsx
interface AgentCardProps {
  agent: AgentSummary;
  onClick: (agent: AgentSummary) => void;
}

export function AgentCard({ agent, onClick }: AgentCardProps) {
  return (
    <div className="rounded-xl border bg-white p-5 hover:shadow-lg transition-shadow cursor-pointer"
         onClick={() => onClick(agent)}>
      {/* 头部: 图标 + 名称 + 状态 */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-3">
          <AgentIcon src={agent.icon_url} size={40} />
          <div>
            <h3 className="font-semibold text-gray-900">{agent.name}</h3>
            <p className="text-sm text-gray-500">{agent.model_display_name}</p>
          </div>
        </div>
        <AgentStatusBadge status={agent.status} />
      </div>
      
      {/* 技能标签 */}
      <div className="mt-3 flex flex-wrap gap-1.5">
        {agent.skills.map(skill => (
          <span key={skill} className="px-2 py-0.5 text-xs rounded-full bg-blue-50 text-blue-700">
            {skill}
          </span>
        ))}
      </div>
      
      {/* 统计信息 */}
      <div className="mt-4 grid grid-cols-3 gap-2 text-center">
        <div>
          <p className="text-lg font-semibold text-gray-900">{agent.tasks_this_week}</p>
          <p className="text-xs text-gray-500">本周任务</p>
        </div>
        <div>
          <p className="text-lg font-semibold text-green-600">
            {(agent.success_rate * 100).toFixed(0)}%
          </p>
          <p className="text-xs text-gray-500">成功率</p>
        </div>
        <div>
          <p className="text-lg font-semibold text-gray-900">
            {formatDuration(agent.avg_task_duration_seconds)}
          </p>
          <p className="text-xs text-gray-500">平均时长</p>
        </div>
      </div>
      
      {/* 忙碌时显示当前任务 */}
      {agent.status === 'busy' && agent.current_task && (
        <div className="mt-3 px-3 py-2 bg-yellow-50 rounded-lg text-sm text-yellow-800">
          正在执行: {agent.current_task.title}
        </div>
      )}
    </div>
  );
}
```

### 10.8 性能目标

| 指标 | 目标 |
|------|------|
| Agent 仪表板加载（10 个 Agent） | < 300ms |
| Agent 卡片渲染（含实时状态） | < 100ms |
| Agent 创建（从模板 → 上线） | < 30s |
| Agent 创建（自定义 → 上线） | < 45s |
| 模型热切换生效时间 | < 2s |
| Agent 状态变更推送延迟 | < 500ms |
| 容器启动时间（镜像已缓存） | < 10s |
| 容器启动时间（首次拉取镜像） | < 60s |
| 心跳上报延迟 | < 1s |
| 健康检查响应时间 | < 500ms |
| Fork Agent（含 Memory 复制） | < 60s |
| 配置导入验证 | < 5s |
| 性能指标查询（30 天） | < 500ms |
| WebSocket 连接数（Agent 频道） | > 1,000 |
| 资源监控数据采集频率 | 10s |

---

## 11. 模块集成

### 11.1 与 Module 1 (Chat 对话) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| Agent 身份识别 | Agent → Chat | Agent 在 Chat 中发送消息时携带 Agent 身份标识（名称、模型、角色） |
| Agent 消息格式 | Agent → Chat | Agent 消息带有特殊标记（如 Agent 图标前缀），区别于人类消息 |
| @Agent 交互 | Chat → Agent | 人类在 Chat 中 @Agent 名称时，消息路由到对应 Agent 的任务队列 |
| Agent 通知 | Agent → Chat | Agent 状态变更、任务完成、错误告警等通知推送到相关 Chat 频道 |
| Agent 上报 | Agent → Chat | Agent 遇到需要人类决策的问题时，通过 Chat 发送上报消息 |

```yaml
# Agent → Chat 通知示例
event: agent.status_changed
payload:
  agent_id: "agent_code_001"
  agent_name: "代码助手"
  old_status: "online"
  new_status: "error"
  error_type: "api_key_invalid"
  channel_id: "ch_team_abc123"
  message: "⚠️ 代码助手 (Agent) 状态异常: API Key 无效。请管理员检查配置。"
```

### 11.2 与 Module 2 (Tasks 任务) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| Agent 可分配性 | Agent → Tasks | 只有 status='online' 的 Agent 才能被分配任务 |
| 任务执行 | Tasks → Agent | 任务分配给 Agent 后，Agent 自动开始执行（status → busy） |
| 进度上报 | Agent → Tasks | Agent 执行中定期上报进度到任务系统 |
| 结果提交 | Agent → Tasks | Agent 完成任务后提交结果（代码、文档、报告等） |
| 性能统计 | Tasks → Agent | 任务完成后更新 Agent 的统计指标（成功率、平均时长） |
| 任务中断 | Agent → Tasks | Agent 异常（error/stopped）时，正在执行的任务标记为 interrupted |

**数据流：**

```
Module 2 (Tasks)                           Module 5 (Agent)
────────────────                         ────────────────────
task.assign(agent_code_001)    ────→     检查 Agent status = 'online' ✓
                                          更新 Agent status → 'busy'
                                          Agent 容器开始执行任务
                                          
                                ←────     agent.task_progress (50%)
                                          更新任务进度
                                          
                                ←────     agent.task_completed (success)
                                          更新任务状态 → completed
                                          更新 Agent 统计指标
                                          更新 Agent status → 'online'

task.assign(agent_data_001)    ────→     检查 Agent status = 'error' ✗
                                          返回错误: "Agent 当前不可用"
```

### 11.3 与 Module 3 (Projects 项目) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| 项目 Agent 成员 | Agent → Projects | Agent 可以作为项目成员参与项目（通过 Module 4 团队关联） |
| 代码提交 | Agent → Projects | 执行者 Agent 可以向项目仓库提交代码和创建 PR |
| PR Review | Agent → Projects | 审核者 Agent 可以自动 Review PR |
| Sprint 管理 | Agent → Projects | 协调者 Agent 可以创建 Sprint 和管理任务 |
| 项目报告 | Agent → Projects | 观察者 Agent 可以生成项目进度报告 |

### 11.4 与 Module 4 (Team 团队) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| Agent 市场浏览 | Agent → Team | Module 4 的"添加 Agent 到团队"操作会嵌入 Module 5 的 Agent 列表浏览器 |
| Agent 数据供给 | Agent → Team | team_members 表通过 member_id 关联 agents 表获取 Agent 的名称、模型、技能等数据 |
| Agent 状态同步 | Agent → Team | Agent 状态变更（online/busy/error 等）同步到 Module 4 的 agent_team_status 表 |
| Agent 生命周期 | Agent → Team | Agent 被销毁时自动从所有团队中移除 |
| Agent 健康监控 | Agent → Team | Agent 的健康指标（心跳、错误率）实时同步到团队视图中的 Agent 卡片 |
| 角色权限 | Team → Agent | Agent 在团队中的角色（执行者/审核者/协调者/观察者）决定其在 Module 1-3 中的操作权限 |

```yaml
# Module 5 → Module 4 状态同步事件
event: agent.status_changed
payload:
  agent_id: "agent_code_001"
  old_status: "online"
  new_status: "busy"
  details:
    task_id: "task_xyz"
    task_title: "实现用户认证模块"

→ Module 4 处理：
  1. 查找所有包含 agent_code_001 的 team_members 记录
  2. 更新对应的 agent_team_status 表
  3. 更新 Redis agent_status:{agent_code_001}
  4. 推送 WebSocket: team:agent_status_changed（到每个相关团队）
  5. 前端成员卡片状态指示器实时变色（绿→黄）
```

### 11.5 与 Module 6 (Toolbox 工具箱) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| 工具调用 | Agent → Toolbox | Agent 执行任务时可以调用 Toolbox 中的工具（代码分析器、测试运行器等） |
| 工具权限 | Toolbox → Agent | Agent 可用的工具由其权限等级和技能配置决定 |
| 工具使用统计 | Toolbox → Agent | Agent 调用工具的频率和结果纳入性能统计 |

### 11.6 与 Module 7 (Admin 管理后台) 集成

| 集成点 | 方向 | 说明 |
|--------|------|------|
| Agent 全局管理 | Agent → Admin | Admin 后台展示所有 Workspace 的 Agent 总览 |
| 资源配额管理 | Admin → Agent | Admin 可以设置 Workspace 级的 Agent 数量上限和资源配额 |
| API Key 管理 | Admin → Agent | Admin 管理各 LLM 提供商的 API Key（共享 Key 或 per-Workspace Key） |
| 成本监控 | Agent → Admin | Agent 的 LLM API 调用成本汇总到 Admin 后台 |
| 审计日志 | Agent → Admin | Agent 的所有操作记录纳入全局审计日志 |

### 11.7 集成数据流全景

```
Chat (M1)          Tasks (M2)        Projects (M3)      Team (M4)          Agent (M5)         Toolbox (M6)
  │                  │                  │                   │                  │                  │
  │ @Agent 消息      │                  │                   │                  │                  │
  ├─────────────────────────────────────────────────────────────────────→    │                  │
  │                  │                  │                   │                  │ 路由到 Agent     │
  │                  │                  │                   │                  │                  │
  │                  │ 分配任务给Agent  │                   │                  │                  │
  │                  ├─────────────────────────────────→    │ 检查状态         │                  │
  │                  │                  │                   ├──────────────→  │                  │
  │                  │                  │                   │ ←─────────────  │ online ✓         │
  │                  │                  │                   │                  │ → busy            │
  │                  │                  │                   │ 状态同步         │                  │
  │                  │                  │                   │ ←─────────────  │                  │
  │                  │                  │                   │                  │                  │
  │                  │                  │                   │                  │ 调用工具          │
  │                  │                  │                   │                  ├──────────────→  │
  │                  │                  │                   │                  │ ←─────────────  │
  │                  │                  │                   │                  │                  │
  │ Agent 通知       │                  │                   │                  │                  │
  │ ←──────────────────────────────────────────────────────────────────────  │ 任务完成通知     │
  │                  │ 任务结果提交     │                   │                  │                  │
  │                  │ ←──────────────────────────────────────────────────  │                  │
  │                  │                  │ 代码提交/PR       │                  │                  │
  │                  │                  │ ←────────────────────────────────  │                  │
  │                  │                  │                   │                  │                  │
  │                  │                  │                   │ Agent 销毁       │                  │
  │                  │                  │                   │ ←─────────────  │                  │
  │                  │                  │                   │ 从团队移除       │                  │
```

---

## 12. 测试用例

### 12.1 Agent 仪表板

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-AG-01 | 仪表板加载 | 打开 Agent 管理页面 | 卡片网格正确展示所有 Agent，含名称/模型/技能/任务数/成功率/平均时长 |
| TC-AG-02 | 空状态 | 无任何 Agent 时打开页面 | 显示空状态引导："创建你的第一个 Agent" + 模板市场入口 |
| TC-AG-03 | 状态实时更新 | Agent 状态从 online 变为 busy | 卡片状态指示器在 < 1s 内从绿变为黄，并显示当前任务名称 |
| TC-AG-04 | 搜索 Agent | 输入 Agent 名称关键词 | 实时过滤显示匹配的 Agent 卡片 |
| TC-AG-05 | 按模型筛选 | 选择"Claude 3.5 Sonnet" | 只显示使用该模型的 Agent |
| TC-AG-06 | 按状态筛选 | 选择"异常" | 只显示 status=error 的 Agent |
| TC-AG-07 | 卡片点击 | 点击 Agent 卡片 | 跳转到 Agent 详情页 |
| TC-AG-08 | 响应式布局 | 缩小浏览器窗口 | 卡片从 4 列变为 2 列再变为 1 列 |

### 12.2 创建 Agent

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-CR-01 | 模板创建（默认配置） | 选择"全栈开发者"模板 → 命名 → 部署 | Agent 创建成功，配置从模板填充，状态变为 starting → online |
| TC-CR-02 | 模板创建（修改配置） | 选择模板 → 修改模型为 GPT-4 → 禁用一个技能 → 部署 | Agent 创建成功，使用修改后的配置 |
| TC-CR-03 | 自定义创建 | 手动填写所有配置 → 部署 | Agent 创建成功，使用手动配置 |
| TC-CR-04 | 名称重复 | 创建时使用已存在的 Agent 名称 | 提示"Agent 名称已存在" |
| TC-CR-05 | API Key 无效 | 使用无效的 API Key 创建 | 部署失败，提示"API Key 验证失败" |
| TC-CR-06 | 部署超时 | 容器启动超过 120 秒 | 状态变为 error，错误类型 'start_timeout'，通知管理员 |
| TC-CR-07 | 资源不足 | 宿主 VM 资源不足时创建 | 提示"资源不足，请调整配额或等待其他 Agent 释放资源" |
| TC-CR-08 | 创建后取消 | 创建进行中点击取消 | 停止创建流程，回到仪表板 |

### 12.3 Agent 配置

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-CF-01 | 修改 Persona | 编辑系统 Prompt 并保存 | Persona 更新成功，persona_version 递增，变更记录写入历史 |
| TC-CF-02 | 切换模型 | 从 Claude 3.5 Sonnet 切换到 GPT-4 Turbo | 模型切换成功，下次 API 调用使用新模型，无需重启容器 |
| TC-CF-03 | 启用技能 | 启用一个之前禁用的技能 | 技能立即生效，技能列表和卡片标签更新 |
| TC-CF-04 | 禁用技能 | 禁用一个已启用的技能 | 技能立即禁用，Agent 不再使用该技能 |
| TC-CF-05 | 修改权限等级 | 从"中"改为"高" | 权限更新成功，Agent 在各模块的操作权限相应调整 |
| TC-CF-06 | 配置版本历史 | 查看配置变更历史 | 按时间倒序展示所有变更记录，含变更类型、旧值、新值 |
| TC-CF-07 | 并发修改 | 两个管理员同时修改同一 Agent 配置 | 后提交的一方收到冲突提示，需要刷新后重新编辑 |

### 12.4 Agent 状态监控

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-SM-01 | 在线状态 | 查看正常运行的 Agent | 状态显示 online（绿色），心跳正常 |
| TC-SM-02 | 忙碌状态 | Agent 接收任务后 | 状态变为 busy（黄色），显示当前任务信息 |
| TC-SM-03 | 错误状态 | Agent 容器崩溃 | 状态变为 error（红色），显示错误类型和消息 |
| TC-SM-04 | 心跳超时 | 模拟 Agent 停止发送心跳 90 秒 | 状态从 online 变为 error，错误类型 'heartbeat_timeout' |
| TC-SM-05 | 资源监控 | 查看 Agent 详情页 | 实时 CPU/内存使用率图表正确更新（10s 间隔） |
| TC-SM-06 | 性能指标 | 查看过去 30 天的周报 | 按周展示任务数、成功率、平均时长、API 调用量 |
| TC-SM-07 | 活动日志 | 查看最近活动 | 时间线展示最近 50 条操作记录 |
| TC-SM-08 | 错误告警 | Agent 状态变为 error | 管理员收到 Chat 消息通知 |

### 12.5 Agent 生命周期

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-LC-01 | 部署 Agent | 点击部署 | 状态: draft → starting → online，容器创建并通过健康检查 |
| TC-LC-02 | 停止 Agent | 点击停止 | 状态: online → stopped，容器停止但不删除 |
| TC-LC-03 | 启动已停止 Agent | 点击启动 | 状态: stopped → starting → online，容器恢复运行 |
| TC-LC-04 | 重启 Agent | 点击重启 | 状态: online → starting → online，容器重建 |
| TC-LC-05 | 销毁 Agent | 点击销毁 → 二次确认 | 状态: → destroying → destroyed，容器删除，配置归档 |
| TC-LC-06 | 销毁有任务的 Agent | Agent 正在执行任务时销毁 | 提示"Agent 正在执行任务"，可选择等待或强制销毁 |
| TC-LC-07 | 自动恢复（容器崩溃） | 容器异常退出 | 自动重启（最多 3 次），3 次失败后转为 error |
| TC-LC-08 | 自动恢复（OOM） | 容器内存不足被 Kill | 自动增加 20% 内存后重启 |
| TC-LC-09 | 配置热更新 | 修改 Persona 并保存 | 状态: online → updating → online，无需重建容器 |
| TC-LC-10 | 生命周期事件日志 | 查看生命周期记录 | 所有状态转换按时间记录，含触发者和原因 |

### 12.6 模板市场

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-TM-01 | 浏览模板 | 打开模板市场 | 展示所有可用模板，含名称/描述/推荐模型/技能标签 |
| TC-TM-02 | 模板详情 | 点击模板卡片 | 展示完整说明、Persona 预览、技能列表、推荐资源 |
| TC-TM-03 | 从模板创建 | 选择模板 → 点击"使用此模板" | 跳转到创建向导，自动填充模板配置 |
| TC-TM-04 | 按分类筛选 | 选择"开发"分类 | 只显示开发类模板 |
| TC-TM-05 | 模板使用计数 | 使用模板创建 Agent 后 | 模板的 use_count 递增 |
| TC-TM-06 | 5 个预设模板 | 检查预设模板列表 | 全栈开发者、UI 设计师、代码审查员、技术写作者、安全审计员均存在 |

### 12.7 Fork Agent

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-FK-01 | 全量 Fork | Fork Agent + 全量复制 Memory | 新 Agent 创建成功，继承源 Agent 所有配置和 Memory |
| TC-FK-02 | 无 Memory Fork | Fork Agent + 不复制 Memory | 新 Agent 创建成功，继承配置但 Memory 为空 |
| TC-FK-03 | Fork 后修改 | Fork 后修改新 Agent 的模型 | 新 Agent 模型变更，源 Agent 不受影响 |
| TC-FK-04 | Fork 谱系 | 查看 Fork 历史 | 显示完整的 Fork 关系链 |
| TC-FK-05 | Fork 独立性 | 修改源 Agent 配置 | 新 Agent 不受影响 |

### 12.8 导入/导出配置

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-IE-01 | 导出 JSON | 点击导出按钮 | 下载 JSON 配置文件，包含完整 Agent 配置 |
| TC-IE-02 | 导出 YAML | 选择 YAML 格式导出 | 下载 YAML 配置文件 |
| TC-IE-03 | 导入有效配置 | 上传有效的 JSON 配置文件 | 预览解析结果，确认后创建 Agent |
| TC-IE-04 | 导入无效格式 | 上传格式错误的文件 | 提示"配置格式无效"并展示错误详情 |
| TC-IE-05 | 导入后修改 | 导入配置后修改名称 | 修改生效，使用新名称创建 Agent |

### 12.9 权限测试

| 编号 | 场景 | 操作 | 预期结果 |
|------|------|------|---------|
| TC-PM-01 | 管理员创建 Agent | Workspace 管理员创建 Agent | 创建成功 |
| TC-PM-02 | 普通成员创建 Agent | 非管理员尝试创建 | 操作被拒绝，返回 403 |
| TC-PM-03 | 管理员销毁 Agent | 管理员销毁 Agent | 销毁成功 |
| TC-PM-04 | 普通成员销毁 Agent | 非管理员尝试销毁 | 操作被拒绝，返回 403 |
| TC-PM-05 | 管理员修改配置 | 管理员修改 Agent 配置 | 修改成功 |
| TC-PM-06 | 普通成员查看 Agent | 普通成员打开 Agent 详情 | 可查看但不能编辑 |

### 12.10 性能测试

| 指标 | 测试方法 | 目标 |
|------|---------|------|
| 仪表板加载 | API 响应时间 + Lighthouse | < 300ms (API) + FCP < 1s |
| Agent 创建端到端 | 从点击部署到 online | 模板 < 30s，自定义 < 45s |
| 模型热切换 | 切换到新配置生效 | < 2s |
| 状态更新延迟 | Agent 状态变更 → 前端更新 | < 500ms |
| 容器启动 | 镜像已缓存时 | < 10s |
| Fork Agent | 含全量 Memory 复制 | < 60s |
| 并发创建 | 同时创建 5 个 Agent | 全部成功，总时间 < 90s |
| 心跳吞吐 | 10 个 Agent 同时心跳 | 无丢失，延迟 < 1s |
| 指标查询 | 30 天周报 | < 500ms |
| WebSocket 广播 | 状态变更通知到 50 个客户端 | < 200ms |

---

## 13. 成功指标

### 13.1 核心指标

| 指标 | MVP (2 月后) | 成熟期 (10 月后) | 说明 |
|------|-------------|-----------------|------|
| 活跃 Agent 数 | 20 | 500 | status=online/busy 的 Agent 数 |
| 日均 Agent 创建数 | 1 | 10 | 每天新创建的 Agent 数量 |
| 模板使用率 | > 60% | > 50% | 从模板创建的 Agent / 总创建数 |
| Agent 平均在线率 | > 90% | > 99% | Agent online 时间 / 总时间 |
| Agent 平均成功率 | > 85% | > 95% | 任务成功数 / 总任务数 |

### 13.2 模板市场指标

| 指标 | MVP | 成熟期 | 说明 |
|------|-----|--------|------|
| 官方模板数 | 5 | 15 | 官方预设模板数量 |
| 模板使用总次数 | 30 | 1000 | 累计从模板创建 Agent 的次数 |
| 最热门模板使用次数 | 10 | 300 | 使用次数最多的模板 |
| 模板到创建转化率 | > 30% | > 40% | 查看模板详情后创建 Agent 的比例 |
| 创建时间（模板路径） | < 30s | < 20s | 从选模板到 Agent 上线 |

### 13.3 生命周期管理指标

| 指标 | MVP | 成熟期 | 说明 |
|------|-----|--------|------|
| Agent 异常恢复时间（自动） | < 3 min | < 1 min | 自动恢复从 error 到 online 的时间 |
| Agent 异常恢复时间（人工） | < 30 min | < 10 min | 人工介入从 error 到 online 的时间 |
| 自动恢复成功率 | > 70% | > 90% | 自动恢复尝试的成功率 |
| 配置热更新成功率 | > 95% | > 99% | 不重启容器的配置更新成功率 |
| Fork 使用频率 | 2/周 | 20/周 | 每周 Fork 操作次数 |

### 13.4 运行时性能指标

| 指标 | MVP | 成熟期 | 说明 |
|------|-----|--------|------|
| 容器启动时间 P95 | < 30s | < 15s | 从 starting 到 online |
| 心跳延迟 P99 | < 2s | < 1s | 心跳上报到服务端接收 |
| 状态同步延迟 P99 | < 1s | < 500ms | 状态变更到前端显示 |
| 每 VM 承载 Agent 数 | 4 | 8 | 单台宿主 VM 运行的 Agent 容器数 |
| 资源利用率 | > 50% | > 70% | 宿主 VM 的平均资源利用率 |

### 13.5 体验指标

| 指标 | 目标 | 说明 |
|------|------|------|
| 仪表板加载时间 P99 | < 500ms | 含卡片渲染和状态加载 |
| 创建向导完成率 | > 80% | 进入创建向导后成功创建 Agent 的比例 |
| 管理员首次创建 Agent 时间 | < 2 min | 新用户首次成功创建 Agent 的时间 |
| Agent 详情页停留时间 | > 1 min | 说明用户在使用监控功能 |
| 仪表板回访频率 | 3+ 次/天 | 管理员每天打开仪表板的次数 |

---

## 14. 风险与缓解

### 14.1 技术风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **容器逃逸** — Agent 容器突破隔离，访问宿主机或其他容器的数据 | 低 | 高 | 使用 rootless Docker 模式运行容器。禁用 privileged 模式。限制 Linux capabilities（drop ALL, add 必要的）。使用 seccomp 和 AppArmor profile。容器网络隔离（每个 Agent 独立网络命名空间）。定期更新 Docker Engine 修复已知漏洞 |
| **资源耗尽** — 单个 Agent 容器占用过多 CPU/内存，影响宿主机和其他 Agent | 中 | 中 | Docker cgroup 硬限制（`--memory` + `--cpus`）。OOM Kill 后自动重启并通知。资源使用率超 85% 时告警。宿主机保留 20% 资源余量（不分配给容器）。异常 Agent 自动降级（降低资源配额） |
| **LLM API Key 泄露** — Agent 容器内的 API Key 被恶意代码读取或日志记录 | 低 | 高 | API Key 通过 Secrets Manager 注入，不写入容器镜像或配置文件。容器内通过环境变量访问，日志采集自动脱敏 API Key。API Key 定期轮换。每个 Agent 可使用独立的 API Key（限制爆炸半径） |
| **Docker 镜像供应链** — Agent 基础镜像被注入恶意代码 | 低 | 高 | 使用私有镜像仓库（Artifact Registry）。基础镜像由 CI/CD 流水线构建并签名。启用 Docker Content Trust。定期扫描镜像漏洞（Trivy/Grype） |
| **模型热切换失败** — 切换模型后新模型不可用，Agent 无法正常工作 | 中 | 中 | 切换前验证新模型 API Key 和可用性。切换失败自动回滚到旧模型。回滚事件通知管理员。保留旧模型配置 60 秒后再清除（快速回滚窗口） |
| **心跳风暴** — 大量 Agent 同时发送心跳造成服务端压力 | 低 | 低 | 心跳间隔加入随机偏移（30s ± 5s），避免同步心跳。心跳接收使用 Redis Pipeline 批量处理。心跳数据轻量化（< 500 bytes） |
| **Fork Memory 复制延迟** — 大量 Memory 数据复制导致 Fork 耗时过长 | 中 | 低 | 异步复制：先创建 Agent 并上线（空 Memory），后台异步复制 Memory。Memory 压缩后复制。大 Memory 的 Fork 使用 Copy-on-Write 机制（P2） |

### 14.2 产品风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **Agent 配置复杂度** — 用户不知道如何写好的 Persona Prompt、不知道该选什么模型 | 高 | 中 | 模板市场降低门槛——用户不需要自己写 Prompt。"一步到位预置"概念——模板已包含最佳实践配置。创建向导每步有详细说明和推荐。提供"测试 Persona"功能（P1）——发送测试消息预览 Agent 回复 |
| **模板市场内容贫乏** — 初期只有 5 个模板，覆盖场景有限 | 中 | 中 | MVP 优先覆盖最高频场景（全栈开发、Code Review、测试、文档、安全）。基于用户反馈快速补充新模板。P2 开放社区模板投稿。允许用户"导出已有 Agent 配置为模板"自用 |
| **成本管控困难** — 用户创建过多 Agent，LLM API 成本和 VM 成本失控 | 中 | 中 | Workspace 级 Agent 数量上限（默认 10 个）。API 调用量仪表板和成本估算。每个 Agent 的资源配额上限。Admin 后台可设置成本告警阈值。按 Agent 的实际使用量计费建议 |
| **Agent 状态误判** — 心跳超时被误判为 error，但 Agent 实际在正常运行 | 中 | 低 | 90 秒超时（3 个心跳周期）已留足余量。误判后自动重启，如果重启后立即恢复则不通知用户。状态页面显示"最后心跳时间"让用户自行判断。P2 支持自定义心跳超时阈值 |
| **Fork 语义混淆** — 用户不理解 Fork 和"创建副本"的区别，期望 Fork 后两个 Agent 保持同步 | 中 | 低 | Fork 对话框明确说明"Fork 创建完全独立的副本，修改互不影响"。Fork 成功后的提示消息强调独立性。提供"Fork 谱系"视图但不提供"同步"功能 |

### 14.3 安全风险

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|---------|
| **Agent 越权操作** — Agent 利用 Prompt Injection 或其他手段绕过权限限制 | 中 | 高 | 权限检查在 API 层（服务端），不依赖 Agent 自觉遵守。所有 Agent 的 API 调用都经过 Permission Engine 中间件。Agent 容器只能访问被授权的 API 端点。所有操作写入审计日志。异常操作频率检测（连续权限拒绝 → 告警） |
| **恶意 Agent 配置** — 用户导入包含恶意 Persona Prompt 的配置文件 | 低 | 中 | 导入配置时扫描 Persona 中的可疑内容（如：读取环境变量、执行系统命令的指令）。导入预览时高亮潜在风险内容。Agent 容器的权限限制确保即使 Prompt 包含恶意指令，系统级防护也能阻止 |
| **Agent 数据泄露** — Agent 在执行任务时将敏感数据发送到外部 | 低 | 高 | Agent 容器的网络出口只允许访问白名单域名（LLM API 端点 + CODE-YI 后端 API）。禁止容器直接访问互联网。所有外部 API 调用通过代理层（可审计）。Agent 发送的消息不包含其他 Agent 的 API Key 或内部配置 |

---

## 15. 排期建议

### 15.1 为什么是 5 周？

Module 5（Agent 管理）P0 范围的工期估算为 ~5 周（1 前端 + 1 后端），原因如下：

1. **Agent 运行时改造是最大的技术投入**：从现有的独立 VM 模式迁移到 Docker 容器化模式，需要实现 Container Manager、健康监控、自动恢复等完整的容器编排能力。这不是简单的 CRUD，而是系统级的架构改造
2. **生命周期状态机复杂**：Agent 有 9 种状态和 15+ 种状态转换，每种转换都需要正确处理数据一致性、容器操作、WebSocket 通知。这比 Module 2 的任务状态机更复杂
3. **模板引擎需要完整实现**：模板定义规范、模板实例化流程、变量插值、配置验证——这是一个独立的子系统
4. **Model-Agnostic 适配层**：需要实现多个 LLM 提供商的统一适配（API Key 管理、模型切换、错误处理），虽然可以先实现 2-3 个提供商，但适配层架构需要一次性设计好
5. **与已有模块的集成工作**：Module 5 是 Module 4 的前置依赖——团队成员管理中的"Agent 数据"和"Agent 状态"都来自 Module 5。需要确保 API 接口对齐

### 15.2 Sprint 规划（P0 范围约 5 周）

#### Sprint 1: 数据模型与 Agent CRUD（第 1 周）

**做什么：** 搭建 Agent 管理模块的数据基础和核心 CRUD API。

**后端（1 人周）：**
- 数据库 Schema 创建（agents, agent_configs, agent_skills, agent_templates, agent_lifecycle_events, agent_config_history）
- Agent CRUD API（创建/读取/更新/删除——暂不含部署）
- Agent Config API（读取/更新配置、技能管理）
- 模板表种子数据（5 个官方预设模板）
- Template API（列表/详情/实例化）
- 配置版本历史记录

**前端（1 人周）：**
- Agent 仪表板页面框架
- Agent 卡片组件（AgentCard，展示名称/模型/技能/统计/状态）
- 仪表板卡片网格（AgentCardGrid）
- 搜索/筛选/排序组件
- 模板市场浏览组件（TemplateCard, TemplateGrid）
- 模板详情页

**难点：** 模板数据结构设计（支持变量插值和多种 Persona 配置选项）。确保 Agent 的 CRUD 接口设计与 Module 4 的成员管理 API 对齐。

#### Sprint 2: 创建向导与 Docker 运行时（第 2 周）

**做什么：** 实现 Agent 创建向导的完整流程和 Docker 容器化运行时。

**后端（1 人周）：**
- Container Manager 核心实现（创建/启动/停止/重启/销毁容器）
- Agent 基础镜像构建（Dockerfile + CI/CD 流水线）
- Agent 部署 API（deploy/start/stop/restart/destroy）
- 容器健康检查机制
- Agent 状态机实现（状态转换逻辑 + 数据库更新）
- 部署记录表（agent_deployments）

**前端（1 人周）：**
- 创建向导组件（CreateWizard，Step by Step）
- 模板选择步骤（TemplateSelector）
- 模型选择器（ModelSelector，含模型说明）
- Persona 编辑器（PersonaEditor，Markdown 格式）
- 技能选择器（SkillPicker，开关列表）
- 权限/资源配置步骤
- 命名和部署预览

**难点：** Docker 容器化运行时的整体架构是本模块最大的技术挑战。需要处理容器创建、配置注入、健康检查、资源限制、网络隔离等多个方面。Agent 基础镜像的设计需要平衡通用性和轻量性。

#### Sprint 3: 状态监控与 WebSocket（第 3 周）

**做什么：** 实现 Agent 实时状态监控和 WebSocket 推送。

**后端（1 人周）：**
- Health Monitor（心跳接收 + 超时检测 + 自动恢复）
- 资源监控数据采集（Docker stats → Redis → PostgreSQL）
- Agent Metrics 聚合 Worker（hourly/daily/weekly）
- WebSocket Agent 频道（agents:subscribe / agent:status_changed / agent:resource_update）
- 错误告警通知（Chat 消息推送）
- 生命周期事件记录（agent_lifecycle_events）

**前端（1 人周）：**
- Agent 详情页（AgentDetailHeader + 状态/配置/指标/活动 Tab）
- 实时状态指示器（WebSocket 消费 + 状态变色）
- 资源使用仪表盘（CPU/内存实时图表）
- 性能指标图表（任务数/成功率/时长趋势图）
- 活动时间线（AgentActivityTimeline）
- 错误日志列表（AgentErrorLog）

**难点：** Health Monitor 的超时检测和自动恢复策略需要精心设计，避免误判和恢复风暴。资源监控数据的采集频率（10s）和存储策略（聚合降采样）需要平衡实时性和存储成本。

#### Sprint 4: 模型热切换与配置编辑（第 4 周）

**做什么：** 实现 Model-Agnostic 架构的模型热切换、配置在线编辑。

**后端（1 人周）：**
- LLM Adapter 层实现（Anthropic + OpenAI + Google 三个适配器）
- 模型热切换 API（验证 → 更新配置 → 通知容器 → 无需重启）
- 配置热更新机制（容器 /config/reload 端点）
- API Key 安全管理（Secrets Manager 集成）
- 模型列表 API（可用模型及其特性）
- LLM Token 计数和成本估算

**前端（1 人周）：**
- Agent 配置编辑页面（AgentConfigPanel）
- 模型切换交互（下拉选择 + 确认 + 实时生效反馈）
- Persona 编辑器优化（语法高亮 + 变量提示 + 版本历史查看）
- 技能管理交互（启用/禁用 + 即时反馈）
- 配置变更历史（ConfigHistory 组件）
- Agent 生命周期操作按钮（停止/启动/重启/销毁 + 确认对话框）

**难点：** Model-Agnostic 适配层需要统一不同 LLM 提供商的 API 差异（请求格式、响应格式、错误处理、流式输出）。模型热切换需要确保切换过程中不丢失正在进行的请求。API Key 的安全存储和注入机制。

#### Sprint 5: 集成联调与优化（第 5 周）

**做什么：** 与 Module 4 集成联调，全流程测试和优化。

**后端（1 人周）：**
- Module 4 集成：Agent 数据供给 API（团队成员列表中的 Agent 信息）
- Module 4 集成：Agent 状态同步事件（status_changed → team:agent_status_changed）
- Module 4 集成：Agent 销毁时自动从团队移除
- Module 2 集成：任务分配时检查 Agent 状态
- Module 2 集成：任务完成后更新 Agent 统计
- Agent 仪表板统计缓存更新（tasks_this_week, success_rate, avg_duration）
- 全流程联调 + Bug 修复

**前端（1 人周）：**
- 模板市场在仪表板底部的嵌入布局
- 前端权限感知（管理员 vs 普通成员的操作按钮显隐）
- 全流程联调：创建 → 配置 → 部署 → 监控 → 停止 → 重启 → 销毁
- 空状态和错误状态设计
- 加载状态和骨架屏
- 性能优化（卡片列表虚拟滚动、WebSocket 节流）
- Bug 修复

**难点：** 跨模块集成需要和 Module 4 / Module 2 团队协调 API 对齐。Agent 状态同步链路（Module 5 容器 → Health Monitor → Redis → WebSocket → Module 4 前端）的端到端延迟优化。统计缓存的一致性保证。

### 15.3 P1 功能排期（约 2 周，P0 完成后）

#### Sprint 6: Fork Agent + 导入/导出（第 6 周）

**后端（1 人周）：**
- Fork API 实现（配置复制 + Memory 复制策略）
- Fork 记录表（agent_forks）
- Memory 复制 Worker（异步复制，支持全量/精选/不复制）
- 配置导出 API（JSON/YAML 格式）
- 配置导入 API（上传 → 验证 → 预览 → 创建）
- 批量导入支持

**前端（1 人周）：**
- Fork 对话框（ForkDialog + Memory 策略选择）
- Fork 预览和确认
- 导出按钮和格式选择
- 导入对话框（文件上传 + 格式验证 + 预览）
- Fork 谱系视图

#### Sprint 7: Persona 测试 + 高级监控（第 7 周）

**后端（0.5 人周）：**
- Persona 测试 API（发送测试消息，返回 Agent 回复预览）
- Agent 性能趋势 API（支持对比不同时间段）

**前端（0.5 人周）：**
- Persona 测试面板（输入测试消息 → 查看预期回复）
- 增强的性能图表（对比视图、Token 消耗明细）

### 15.4 里程碑

| 里程碑 | 时间 | 关键能力 | 对应 Sprint |
|--------|------|---------|------------|
| **M1: Agent CRUD + Templates** | Week 1 | Agent 数据模型 + CRUD API + 模板市场浏览 + 仪表板卡片 | Sprint 1 |
| **M2: Create + Deploy** | Week 2 | 创建向导 + Docker 容器化部署 + 生命周期状态机 | Sprint 2 |
| **M3: Monitor + WebSocket** | Week 3 | 实时状态监控 + 健康检查 + 自动恢复 + WebSocket 推送 | Sprint 3 |
| **M4: Config + Model Switch** | Week 4 | 配置在线编辑 + 模型热切换 + LLM 适配层 | Sprint 4 |
| **M5: Integration** | Week 5 | Module 4/2 集成 + 全流程联调 + 优化 | Sprint 5 |
| **M6: Fork + Import/Export** | Week 6 | Fork Agent + 配置导入导出 | Sprint 6 |
| **M7: Advanced** | Week 7 | Persona 测试 + 高级监控 | Sprint 7 |

### 15.5 团队配置

| 角色 | 人数 | 职责 |
|------|------|------|
| 前端工程师 | 1 | 仪表板 UI + 创建向导 + 模板市场 + 配置编辑器 + 监控图表 + Fork/导入导出 UI |
| 后端工程师 | 1 | Agent Service + Container Manager + Health Monitor + LLM Adapter + Metrics Aggregator + 跨模块集成 |

**注意：** 后端工作量是所有模块中最大的（与 Stephanie 的工时评估一致），因为 Agent 运行时改造（Docker 容器化 + Container Manager + 健康监控 + 自动恢复）是一个全新的基础设施层，需要从零构建。这是 Module 5 的核心技术投入，也是 CODE-YI 平台的核心差异化能力。

### 15.6 依赖关系

```
Module 5 的外部依赖：
  Workspace 基础设施 ──→ Module 5 依赖 Workspace 的 GCE VM 资源
  Docker Engine       ──→ Module 5 依赖宿主 VM 上的 Docker Engine
  Secrets Manager     ──→ Module 5 依赖密钥管理服务存储 API Key
  Redis / PostgreSQL  ──→ Module 5 依赖已有的数据基础设施

Module 5 输出（被其他模块依赖）：
  ├── agents 表 + Agent CRUD API → Module 4 使用（团队成员管理中的 Agent 数据源）
  ├── Agent 状态 API → Module 4 使用（agent_team_status 同步）
  ├── Agent 可分配性 → Module 2 使用（任务分配时检查 Agent 在线状态）
  ├── Agent 技能数据 → Module 2 使用（智能匹配 Agent 能力和任务需求）
  └── Agent 性能指标 → Module 7 使用（Admin 后台全局监控）

模块间时序依赖：
  Module 5 (Agent 管理) ←→ Module 4 (Team 团队) 互相依赖
  
  解决方案：
  - Sprint 1-3: Module 5 独立开发，提供 Agent CRUD + 状态 API
  - Sprint 3:   Module 4 开始集成 Module 5 的 API（Agent 作为团队成员）
  - Sprint 5:   双向集成联调（Module 5 ↔ Module 4）
  
  如果 Module 4 未就绪：Module 5 的核心功能不依赖 Module 4，可独立运行
  如果 Module 5 未就绪：Module 4 使用 Mock Agent 数据开发（Sprint 1-2）
```

### 15.7 关键技术决策清单

| 决策 | 选项 | 推荐 | 理由 |
|------|------|------|------|
| Agent 运行时 | VM / Docker / 进程 | **Docker 容器** | 平衡隔离性和成本（降 60-70%） |
| 容器编排 | Kubernetes / Docker Compose / 自研 | **Docker API + 自研 Manager** | MVP 阶段不需要 K8s 的复杂度 |
| LLM 适配层 | 直接调 API / OpenRouter / 自研 | **自研 Adapter + OpenRouter 兜底** | 核心模型自研适配（控制延迟），长尾模型走 OpenRouter |
| Agent 基础镜像 | 每个模板一个镜像 / 统一镜像 | **统一镜像 + 运行时配置注入** | 减少镜像管理复杂度，配置注入更灵活 |
| Memory 存储 | 容器 Volume / 对象存储 / 数据库 | **容器 Volume + 定期备份到对象存储** | Volume 提供低延迟读写，备份提供持久化和 Fork 支持 |
| 心跳协议 | HTTP / WebSocket / gRPC | **HTTP（POST /heartbeat）** | 简单可靠，心跳频率低（30s），不需要长连接 |

---
