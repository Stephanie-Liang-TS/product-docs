# COCO Workspace — 产品需求文档（单一真相来源）

> 文档版本：基于原型 `/workspace/prototypes/coco-workspace.html` 提取  
> 最后更新：2026-04-21  
> 范围：前端原型的全量功能、数据结构、视觉规范

---

## 1. 概述

### 1.1 产品定位

COCO Workspace 是一个 **Human × Agent 协作平台（HxA Collaborative Platform）**，将人类员工与 AI Agent 放入同一个工作环境。用户既可以通过对话与 Agent 协作完成任务，也可以像管理人类员工一样管理、购买、配置 AI Agent。

页面标题：`COCO Workspace — HxA Collaborative Platform`  
副标题：`Human x Agent Collaborative Platform`  
启动标语（Splash）：`AI-Powered Platform`

### 1.2 目标用户

- **团队负责人 / 产品经理**：任务协调、项目跟踪、数据看板
- **工程师（代码开发模式）**：代码审查、CI/CD、API 文档、GitHub 集成
- **运营 / 内容团队（日常办公模式）**：社媒内容、客户管理、周报、邮件
- **IT 管理员**：Agent 管理、席位管理、使用量统计

### 1.3 核心功能概要

| 模块 | 核心价值 |
|------|---------|
| 对话（Chat） | 统一通讯中心，人类+AI 混合群聊，支持三种 Agent 响应模式 |
| 任务（Tasks） | 看板+列表，支持 AI 执行任务、GitHub Issue 同步 |
| 项目（Projects） | 项目管理，含里程碑、GitHub 仓库接入、归档 |
| 通讯录（Team） | 人类员工+数字员工统一管理，组织架构图 |
| Agent 管理 | 已购 Agent KPI、Agent 市场购买、配置 |
| 技能（Skills） | 已安装技能管理、SkillHub 市场、MCP Server |
| 工具箱（Toolbox） | 第三方工具连接管理（开发/办公两套） |
| 管理后台（Admin） | 使用统计、模型分布、席位管理、活动时间线 |
| 设置（Settings） | 通用/通知/安全/集成四个配置分区 |

---

## 2. 入口与模式选择

### 2.1 Splash 页面

Splash 页面在用户进入应用时全屏展示，完成模式选择后淡出进入工作区。

**HTML 结构**  
`<div id="splash">` — `position: fixed; inset: 0; z-index: 1000`

**内容元素**

| 元素 | 内容 | 样式 |
|------|------|------|
| Logo 图片 | `coco-logo.png` | 72×72px，`border-radius: 16px`，`filter: brightness(0)` |
| 标签文字 | `AI-Powered Platform` | `font-family: IBM Plex Mono`，11px，`letter-spacing: 0.14em`，颜色 `var(--accent)` |
| 主标题 | `COCO Workspace` | `font-size: clamp(42px, 7vw, 80px)`，`font-weight: 900`，`letter-spacing: -0.03em` |
| "Workspace" 文字 | 渐变色高亮 | `background: linear-gradient(135deg, var(--accent), var(--accent-light))`，`-webkit-background-clip: text` |
| 副标题 | `Human x Agent Collaborative Platform` | `font-family: IBM Plex Mono`，`clamp(13px, 1.8vw, 16px)`，颜色 `var(--text-muted)` |

### 2.2 模式选择按钮

```
代码开发   日常办公
```

两个按钮并排，`gap: 16px`，无 border-radius（`border-radius: 0`，方形设计语言）。

| 按钮 | 类名 | 默认样式 | Hover 样式 |
|------|------|---------|-----------|
| 代码开发 | `.mode-btn-code` | 黑底白字 `#000000` | 变为 `var(--accent)` 紫色底 |
| 日常办公 | `.mode-btn-office` | 透明底，边框 `var(--border-light)` | 边框和文字变为 `var(--accent)` |

**按钮通用样式**：`padding: 14px 36px`，`font-size: 12px`，`font-weight: 500`，`font-family: IBM Plex Mono`，`letter-spacing: 0.1em`，`text-transform: uppercase`

**交互**：点击后调用 `enterWorkspace(mode)`，splash 执行 `opacity: 0; transform: scale(1.05)` 消失动画，400ms 后工作区渐入。

### 2.3 粒子背景

`<canvas id="particleCanvas">` — `position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; z-index: 0; pointer-events: none`

**粒子参数**

- 数量：80 个
- 大小：`Math.random() * 2.5 + 0.5`（0.5 ~ 3px）
- 速度：`(Math.random() - 0.5) * 0.4`（极慢漂移）
- 透明度：`Math.random() * 0.3 + 0.05`
- 色相：`Math.random() * 40 + 270`（紫-粉色域，hsl）
- 粒子颜色：`hsla(hue, 60%, 60%, opacity)`

**连线**：两粒子距离 < 120px 时绘制连接线，`rgba(211, 87, 254, opacity * (1 - dist/120))`，`lineWidth: 0.5`

**鼠标交互**：粒子与鼠标距离 < 150px 时，沿鼠标方向向外偏移，`force = (150 - dist) / 150 * 0.02`

---

## 3. 全局布局

工作区容器：`<div id="workspace">` — `position: fixed; inset: 0; z-index: 500; display: flex`

初始状态 `opacity: 0; pointer-events: none`，进入后加 `.active` 类（`opacity: 1`）。

### 3.1 侧边栏

`<aside class="sidebar">` — `width: 190px; height: 100vh; background: var(--bg-card); border-right: 1px solid var(--border-light)`

**折叠状态**：添加 `.collapsed` 类后 `width: 68px`，品牌名和 nav 标签淡出（`opacity: 0`）

**侧边栏头部**

```
[C]  COCO
```

- Logo：36×36px，`border-radius: 10px`，`background: linear-gradient(135deg, var(--accent), var(--accent-light))`，白色字母 "C"，`font-weight: 900`
- 品牌名：`font-family: IBM Plex Mono`，`font-weight: 600`，14px，`letter-spacing: 0.1em`

**导航结构**

```
[工作区组]
💬  对话
✅  任务
📁  项目
---分隔线---
[团队组]
👥  通讯录
---分隔线---
[AI & 工具组]
🤖  Agent管理
🧩  技能
🧰  工具箱
---分隔线---
[系统组]
📊  管理后台
⚙️  设置
```

**导航项样式**

| 状态 | 样式 |
|------|------|
| 默认 | `color: var(--text-body)`，无背景 |
| Hover | `background: rgba(211,87,254,0.06)`，`color: var(--accent)` |
| Active | `background: var(--accent-bg)`，`color: var(--accent)`，`font-weight: 600`，左侧 3px 紫色竖线 |

**导航标签**：`font-family: IBM Plex Mono`，12px，`letter-spacing: 0.04em`

**折叠按钮**：底部 `◀` / `▶`，32×32px，`border-radius: 8px`，hover 变紫

### 3.2 顶栏（Topbar）

`height: 64px; padding: 0 24px; background: var(--bg-card); border-bottom: 1px solid var(--border-light)`

从左到右依次：

| 元素 | 说明 |
|------|------|
| 模块名 | `font-family: IBM Plex Mono`，14px，`letter-spacing: 0.06em`，随模块切换更新 |
| 模式切换器 | "代码开发" / "日常办公" 分段控件，`background: rgba(0,0,0,0.04)`，`padding: 4px`，`border-radius: 10px` |
| 积分区块 | 💎 + 数字 + "积分 / +100/天"，渐变背景，点击打开 Agent 市场 |
| CMD+K 按钮 | "搜索命令 ⌘K"，方形边框，`font-family: IBM Plex Mono` |
| 用户头像 | 34×34px 圆形，`background: linear-gradient(135deg, #f093fb, #f5576c)`，字母 "S"，hover 放大 1.1x |

**积分区块详细样式**：`background: linear-gradient(135deg, rgba(211,87,254,0.06), rgba(150,187,255,0.06))`，`padding: 5px 12px`，`border-radius: 10px`，积分数字颜色 `var(--accent)`，"+100/天" 颜色 `var(--success)`

**模式切换器 Active 状态**：`background: var(--bg-card)`，`box-shadow: 0 2px 8px rgba(0,0,0,0.06)`，`border-radius: 8px`

### 3.3 内容区

`flex: 1; overflow-y: auto; overflow-x: hidden`

模块视图：`display: none`，激活后加 `.active` 类变为 `display: block`，同时触发入场动画：

```css
@keyframes moduleEnter {
  from { opacity: 0; transform: translateY(12px); }
  to   { opacity: 1; transform: translateY(0); }
}
```

子元素错开动画（stagger）：前5个子元素分别延迟 0.05s、0.1s、0.15s、0.2s、0.25s。

**滚动条**：宽度 6px，轨道透明，滑块 `rgba(0,0,0,0.12)`，hover `rgba(0,0,0,0.2)`，`border-radius: 3px`

---

## 4. 模块详细说明

### 4.1 对话（Chat）

#### 布局

三栏结构，高度 `calc(100vh - 64px - 56px)`（减去顶栏和 onboarding 重置按钮区域，实际为 topbar 高度）：

```
[会话列表 260px] | [divider] | [消息区 flex:1 min-width:420px] | [divider] | [信息面板 280px]
```

三栏之间有可拖拽分隔线（`.panel-divider`），宽度 5px，拖动时高亮为 3px 紫色竖线。水平方向也有可拖拽分隔线（`.panel-divider-h`）分隔消息区和输入区。

#### 会话列表（左栏）

**Tabs**：全部 / DM / 群聊，下划线激活式。激活色 `var(--accent)`，`border-bottom: 2px solid var(--accent)`

**搜索框**：`padding: 8px 12px`，`border-radius: 8px`，`background: rgba(255,255,255,0.6)`，placeholder "搜索对话..."

**会话项**（`.conv-item`）

| 字段 | 样式 |
|------|------|
| 头像 | 40×40px，`border-radius: 10px`，渐变背景 |
| 名称 | 13.5px，`font-weight: 600` |
| 类型标签 | 9.5px，Agent=紫色，群聊=蓝色，Connector=青色 |
| 时间 | 11px，`color: var(--text-muted)` |
| 预览文字 | 12.5px，单行截断 |
| 未读角标 | 右下角，`background: var(--accent)`，最小宽 18px，白色数字 |

激活状态：`background: var(--accent-bg)`

**会话数据结构**

```javascript
const conversationsData = [
  {
    id: 'coco-agent',          // 唯一标识
    name: 'COCO Agent',        // 显示名称
    avatar: '🐙',              // 头像（emoji 或首字母）
    color: 'linear-gradient(135deg,#d357fe,#96bbff)',  // 头像背景
    tag: 'Agent',              // null / 'Agent' / 'Connector' / '群聊'
    type: 'dm',                // 'dm' | 'group'
    time: '刚刚',              // 最新消息时间
    preview: '欢迎来到 COCO Workspace！',  // 最新消息预览
    unread: 1,                 // 未读数
    model: 'Auto'              // AI 模型，null 表示非 Agent
  }
]
```

**完整会话列表（9 条）**

| ID | 名称 | 类型 | 标签 | 未读 | 模型 |
|----|------|------|------|------|------|
| coco-agent | COCO Agent | dm | Agent | 1 | Auto |
| code-assistant | 代码助手 | dm | Agent | 3 | Claude Sonnet |
| product-dev | 产品开发群 | group | 群聊 | 2 | — |
| li-siqi | 李思琪 | dm | — | 0 | — |
| test-agent | 测试 Agent | dm | Agent | 0 | Claude Sonnet |
| general | General | group | 群聊 | 0 | — |
| engineering | Engineering | group | 群聊 | 0 | — |
| design | Design | group | 群聊 | 0 | — |
| bot-arena | Bot-Arena | group | 群聊 | 0 | — |

#### 消息区（中栏）

**聊天头部**（`.chat-header`）

- 头像（从会话数据取）+ 状态绿点（8×8px，`background: var(--success)`）
- 会话名称：15px，`font-weight: 700`
- 模型标签：`font-family: IBM Plex Mono`，`background: rgba(211,87,254,0.08)`，`color: var(--accent)`
- 右侧：菜单按钮（⋮）+ 信息面板切换按钮（☰）

DM 对话时隐藏信息面板切换按钮。

**消息气泡**（`.chat-msg`）

- 左对齐，`max-width: 85%`
- 普通消息：`background: var(--bg-card)`，`border: 1px solid var(--border-light)`，`border-radius: 14px`，`padding: 12px 16px`
- Agent 消息：`background: linear-gradient(135deg, rgba(211,87,254,0.06), rgba(150,187,255,0.06))`，`border-color: rgba(211,87,254,0.12)`
- 消息名称行：12px，`font-weight: 700`，Agent 显示 "名称 · 模型名"
- 消息文字：14px，`line-height: 1.6`
- 时间：11px，`color: var(--text-muted)`

**代码块**（`.chat-code-block`）

- `background: #1e1e2e`，`border-radius: 10px`，`padding: 14px 16px`
- `font-family: IBM Plex Mono`，12.5px，`line-height: 1.7`
- 基础颜色 `#cdd6f4`

代码高亮 Token 颜色（Catppuccin 风格）：

| Token 类 | 颜色 |
|---------|------|
| `.code-comment` | `#6c7086`（灰） |
| `.code-keyword` | `#cba6f7`（紫） |
| `.code-string` | `#a6e3a1`（绿） |
| `.code-type` | `#89b4fa`（蓝） |
| `.code-field` | `#f9e2af`（黄） |
| `.code-method` | `#89dceb`（青） |
| `.code-punct` | `#bac2de`（浅灰） |
| `.code-label` | `#fab387`（橙） |

**@提及**（`.chat-mention`）：`color: var(--accent)`，`background: rgba(211,87,254,0.1)`，`padding: 1px 5px`，`border-radius: 4px`，`font-weight: 600`

**文件附件标签**（`.chat-file-tag`）：`background: rgba(211,87,254,0.08)`，`color: var(--accent)`，11.5px，有关闭按钮

**打字指示器**：三个 8×8px 圆点，上下弹跳动画，延迟分别为 0、0.15s、0.3s，文字显示 "代码助手 正在输入..."

**发送逻辑**：Enter 发送（Shift+Enter 换行），发送后 500ms 显示打字动画，1500~2500ms 后 AI 随机回复 8 条预设回复之一。

**AI 预设回复**：
1. 收到！我来处理这个问题。
2. 好的，已经记录下来了。需要我帮忙分析一下吗？
3. 明白了！我马上开始执行。
4. 这是个好主意！让我查看一下相关数据。
5. 已经在处理了，预计很快就能完成。
6. 了解，我会把这个添加到任务看板中。
7. 这个需求很合理，让我评估一下工作量。
8. 好的，已经通知相关团队成员了。

#### 信息面板（右栏）

宽度 280px，折叠后 `width: 0; opacity: 0`，过渡动画 0.3s。

**面板内容区块**

1. **群聊名称 + 描述**：名称 14px `font-weight: 600`，描述 12.5px `color: var(--text-muted)`
2. **Agent 设置**：每个 Agent 独立行，包含头像+名称+三按钮模式选择（自动回复/仅@/静默），按钮组共享同一 `agent-mode-btns`，选中变为 `background: var(--accent)` 白字
3. **置顶消息**：带作者名，消息文字 2 行截断，`background: rgba(211,87,254,0.04)`
4. **成员列表**：30×30px 方形头像（`border-radius: 8px`），名称 13px，Agent 标签紫色

**channelInfoData 结构**

```javascript
{
  'product-dev': {
    title: '群聊信息',
    groupName: '产品开发群',
    description: 'COCO Workspace 产品线核心开发群，包含前后端、设计和 AI Agent。',
    agentMode: '自动回复',   // 频道默认模式
    agentModes: {},          // 每个 Agent 独立模式，运行时初始化
    pinned: [
      { author: '张伟', text: '前端组件库已更新到 v3.2...' }
    ],
    members: [
      { name: '张伟', avatar: '伟', color: '#0984e3', isAgent: false },
      { name: '代码助手', avatar: '🤖', color: '#d357fe', isAgent: true }
    ]
  }
}
```

**已配置 channelInfoData 的频道**：`coco-agent`、`product-dev`、`general`、`engineering`

#### 输入框区域

**分类 Chips**（`.chat-category-chips`）

横向可滚动，`gap: 8px`，隐藏滚动条。Chip 样式：`padding: 6px 14px`，`border-radius: 20px`，激活后 `background: var(--accent)` 白字，同时在输入框内显示对应标签。

**Prompt 模板区**（`.chat-prompt-templates`）

3 列网格，`max-height: 200px`，可滚动，点击模板后填入输入框并隐藏模板区。模板卡片：`border-radius: 10px`，`-webkit-line-clamp: 3` 三行截断，hover 变紫色边框。

**输入框主体**（`.chat-input-wrap`）

- 外层：`border: 1.5px solid var(--border-light)`，`border-radius: 14px`，`min-height: 56px`
- Focus：`border-color: var(--accent)`，`box-shadow: 0 0 0 3px rgba(211,87,254,0.1)`
- 内部：标签区（已选分类标签）+ textarea（`min-height: 24px; max-height: 120px`，自动扩展）

**顶部操作行**（`.chat-input-top-actions`）：`@` 按钮（点击在输入框末尾插入 `@`）+ `📎` 附件按钮

**底部工具栏**（`.chat-input-toolbar`）

左侧：

| 按钮 | 说明 |
|------|------|
| Ask ▾ | 模式选择下拉（Ask / Plan / Craft） |
| ⚡ Auto ▾ | 模型选择下拉 |
| 🛠 Skills | 技能选择下拉 |

右侧：↑ 发送按钮，36×36px，`background: var(--accent)`，`border-radius: 10px`

**Ask/Plan/Craft 模式详情**

| 模式 | 图标 | 副标题 | 说明 | 工具权限 |
|------|------|--------|------|---------|
| Craft | 📦 | 你说，我做 | 立即执行任务——读写文件、运行命令、生成内容、直接交付结果 | 文件及系统操作 · 任务管理 · 网络搜索 |
| Plan | 📋 | 先思考，再执行 | 先分析需求、拆解步骤、制定方案，你确认后再动手 | 文件读取 |
| Ask | 💬 | 只聊，不动手 | 只回答问题、读文件、分析信息，不修改任何文件，不执行命令 | 文件读取 |

**Auto 模型列表**

```javascript
const modelList = [
  { icon: '⚡', name: 'Auto', checked: true },
  { icon: '🔷', name: 'Claude Sonnet 4', checked: false },
  { icon: '🔷', name: 'Claude Opus 4', checked: false },
  { icon: '🟢', name: 'GPT-4o', checked: false },
  { icon: '🔵', name: 'DeepSeek-V3', checked: false },
  { icon: '🟣', name: 'Kimi-K2', checked: false },
]
```

**Skills 下拉**（固定列表，不动态加载）：腾讯ima / 多模态内容生成 / skill-creator / Browser Automation / playwright-cli / find-skills

**工具栏下拉通用样式**：`position: absolute; bottom: 100%; left: 0; margin-bottom: 6px`，`border-radius: 12px`，`box-shadow: var(--shadow-modal)`，`padding: 6px`，`min-width: 220px`，`z-index: 200`，`animation: fadeInUp 0.2s`

---

### 4.2 任务（Tasks）

#### 工具栏

```
[⊞ 看板] [☰ 列表]   全部 | 我负责的 | Agent 执行 | 高优先级 | 本周到期   [项目筛选下拉]   [⬇ 导入外部项目]   [+ 新建任务]
```

**视图切换**：`.tasks-view-toggle`，`background: rgba(0,0,0,0.04)`，`border-radius: 10px`，`padding: 3px`，激活项有白色背景和阴影

**筛选 Chips**（`.tasks-filter-chip`）：`border-radius: 20px`，激活后 `background: var(--accent)` 白字

**项目筛选**（`<select>`）：`border-radius: 10px`，`border: 1.5px solid var(--border-light)`

**导入按钮**：`border: 1.5px dashed var(--border-light)`，hover 变紫虚线

#### 看板视图

三列：待办（灰点）/ 进行中（紫点）/ 已完成（青点），`min-width: 280px; max-width: 360px`，`background: rgba(255,255,255,0.4)`

**列头**：标题+彩色圆点+数量角标

**卡片**（`.kanban-card`）

| 字段 | 样式 |
|------|------|
| 项目标签 | 11px，`color: var(--accent)`，GitHub 项目显示 🐱 前缀 |
| 任务标题 | 14px，`font-weight: 600` |
| 指派人头像 | 28×28px，`border-radius: 50%` |
| 指派人名称 | 12px，Agent 旁有紫色 "AI" 角标 |
| 优先级角标 | 高=红、中=黄、低=绿 |
| 截止日期 | 11px，过期变红加粗 |

**拖拽交互**：`draggable="true"`，拖动时 `opacity: 0.5; transform: rotate(2deg) scale(1.02)`，目标列高亮 `background: rgba(211,87,254,0.04)`

#### 列表视图

按状态分组展示，每组有组头（彩色圆点+状态名+数量）。行项：`padding: 12px 16px`，`border-radius: 12px`，显示头像+标题+AI 标签+项目标签+优先级+截止日期。

#### 新建任务 Modal

**表单字段**

| 字段 | 控件 | 选项 |
|------|------|------|
| 任务标题 | input | — |
| 指派给 | select | Stephanie / Alex / Maya / COCO Agent (AI) / Code Bot (AI) / Design AI (AI) |
| 优先级 | select | 低 / 中（默认）/ 高 |
| 所属项目 | select | COCO Workspace V2 / 智能客服系统 / 数据分析看板 / GitHub: coco-app |

创建后新任务状态为 `todo`，模式 field 不设置（不受模式过滤）。

**人员头像映射**

```javascript
const avatarMap = {
  'Stephanie': { avatar: 'S', color: '#f093fb' },
  'Alex':      { avatar: 'A', color: '#00cec9' },
  'Maya':      { avatar: 'M', color: '#fd79a8' },
  'COCO Agent':{ avatar: '🐙', color: '#d357fe' },
  'Code Bot':  { avatar: '⚡', color: '#fdcb6e' },
  'Design AI': { avatar: '🎨', color: '#e17055' }
}
```

#### 导入外部项目 Modal

6 种导入来源（2×3 网格）：

| 来源 | 状态 | 图标背景 | 已有项目 |
|------|------|---------|---------|
| GitHub | 已连接 | `rgba(36,41,46,0.08)` | coco-app / coco-server / coco-docs |
| Jira | 可用 | `rgba(0,82,204,0.08)` | COCO-Board / COCO-Sprint |
| Linear | 可用 | `rgba(86,71,245,0.08)` | Workspace v2 / Backend |
| Asana | 可用 | `rgba(243,121,32,0.08)` | 产品路线图 / Q2 计划 |
| Notion | 已连接 | `rgba(0,0,0,0.04)` | 需求池 / 迭代计划 |
| ClickUp | 可用 | `rgba(123,104,238,0.08)` | — |

选择来源后显示项目下拉选择，点击"导入项目"后 Toast 提示进度。

#### 任务数据结构

```javascript
{
  id: 1,                    // 唯一 ID，新建时从 taskIdCounter(100) 自增
  title: '实现用户登录流程',
  assignee: 'Alex',
  priority: 'high',         // 'high' | 'medium' | 'low'
  status: 'progress',       // 'todo' | 'progress' | 'done'
  avatar: 'A',
  color: '#00cec9',
  isAgent: false,           // 是否 AI 执行
  projectId: 1,             // 关联项目 ID（number | 'gh' | 'social' | 'crm' 等）
  dueDate: '2026-04-25',    // 可选，YYYY-MM-DD
  mode: 'code',             // 'code' | 'office'，控制显示模式
  source: 'github',         // 可选，'github' 表示 GitHub 导入
  repo: 'coco-app',         // GitHub 仓库名，source='github' 时存在
  issueNum: 42              // Issue/PR 编号，source='github' 时存在
}
```

**项目名映射表**：`projectNameMap`

```javascript
{
  1: 'COCO Workspace V2',
  2: '智能客服系统',
  3: '数据分析看板',
  gh: 'GitHub: coco-app',
  social: '社媒运营',
  crm: '客户管理',
  content: '内容营销',
  campaign: '市场活动'
}
```

---

### 4.3 项目（Projects）

#### 项目列表

**响应式网格**：`grid-template-columns: repeat(auto-fill, minmax(340px, 1fr))`，`gap: 20px`

**项目卡片**（`.project-card`）

| 元素 | 说明 |
|------|------|
| GitHub 徽章 | 仅 GitHub 项目显示，含仓库名、⭐星数、🐛 open issues、🔀 PR 数 |
| 项目名 | 18px，`font-weight: 700` |
| 状态角标 | 进行中=青色 / 规划中=紫色 / 审核中=黄色 |
| 描述 | 13px，`color: var(--text-muted)` |
| 进度条 | 6px 高，`border-radius: 3px`，`background: linear-gradient(90deg, var(--accent), var(--accent-light))`，进入页面时动画从 0 到实际值 |
| 团队头像组 | 叠层显示，每个偏移 -8px，`border: 2px solid var(--bg-card)` |
| 进度百分比 | `font-weight: 700`，`color: var(--accent)` |
| 底部 | 激活状态指示点（绿/灰）+ 归档/恢复按钮 |

**归档项目**：`opacity: 0.55; filter: grayscale(0.4)`，在独立"已归档项目"区域折叠展示，点击标题可展开/收起。

**项目详情页**

点击卡片后切换到详情视图（`project-detail.active`），显示返回按钮。

布局：上方项目信息卡（名称、描述、进度、团队），下方两列（里程碑 + 最近活动），GitHub 项目额外显示关联 Issues/PRs 列表。

**里程碑**（`.milestone-item`）：24px 圆形勾选框，完成后 `background: var(--success)`，标题加删除线。

**最近活动**（`.timeline-item`）：32×32px 圆形图标 + 标题 + 时间，项目之间有竖线连接。

#### 新建项目 Modal

两个 Tab：**接入 GitHub 仓库** / **手动创建**

**GitHub Tab**：从列表选择已有仓库（4 条 mock 数据）或手动输入仓库 URL，提交按钮文字 "接入仓库"

**GitHub 仓库数据**：
```javascript
[
  { name: 'coco-app', fullName: 'coco-team/coco-app', desc: 'COCO 主应用前端', stars: 128, issues: 12, connected: true },
  { name: 'coco-server', fullName: 'coco-team/coco-server', desc: 'COCO 后端服务', stars: 86, issues: 5, connected: true },
  { name: 'coco-docs', fullName: 'coco-team/coco-docs', desc: '文档站点', stars: 34, issues: 2, connected: false },
  { name: 'coco-sdk', fullName: 'coco-team/coco-sdk', desc: 'SDK 工具包', stars: 52, issues: 8, connected: false }
]
```

**手动创建 Tab**：项目名称 / 项目描述 / 状态（规划中/进行中/审核中），提交按钮文字 "创建项目"

#### 项目数据结构

```javascript
{
  id: 1,                       // number | string（'gh-coco-app'/'social'/'crm' 等）
  name: 'COCO Workspace V2',
  status: 'active',            // 'active' | 'planning' | 'review'
  progress: 68,                // 0-100
  isActive: true,              // false 则在任务筛选中隐藏
  archived: false,             // true 则移入归档区
  mode: 'code',                // 'code' | 'office'，控制显示模式
  description: '...',
  source: 'github',            // 可选，GitHub 项目
  repo: 'coco-team/coco-app',  // 可选
  stats: { stars: 128, issues: 12, prs: 3 },  // 可选，GitHub 统计
  team: [
    { name: 'Stephanie', avatar: 'S', color: '#f093fb', isAgent: false }
  ],
  milestones: [
    { text: '需求分析与原型设计', done: true }
  ],
  activity: [
    { icon: '🔧', text: 'Alex 合并了 PR #128', time: '2小时前' }
  ]
}
```

---

### 4.4 通讯录（Team）

#### 三个 Tab

**数字员工** / **人类员工** / **组织结构**，分段控件样式，切换时隐藏其他 tab 容器

#### 数字员工 Tab

**过滤条件**：全部 / Worker / Connector / 云端 / 本地

**数字员工卡片**（`.digital-card`）

```
[状态点（右上角）]
[大图标 52×52]
[名称（font-weight: 800）]
[描述（font-size: 12px）]
[能力 Chips（标签列表）]
[模型（★ 模型名，颜色 #6c5ce7）]
[类型徽章 + 部署徽章 + 其他徽章]
[SLA · Owner]
```

**徽章类型**

| 徽章类 | 背景 | 颜色 | 含义 |
|--------|------|------|------|
| `.worker` | `rgba(108,92,231,0.1)` | `#6c5ce7` | Worker 类型 |
| `.cloud` | `rgba(108,92,231,0.1)` | `#6c5ce7` | 云端部署 |
| `.local` | `rgba(0,184,148,0.1)` | `#00b894` | 本地部署 |
| `.connector` | `rgba(253,203,110,0.1)` | `#f39c12` | Connector 类型 |
| `.buy` | `rgba(0,0,0,0.05)` | `var(--text-muted)` | 可购买 |
| `.openclaw` | `rgba(0,184,148,0.1)` | `#00b894` | OpenClaw 平台 |

**6 名数字员工数据**

| 名称 | 类型 | 部署 | 模型 | 状态 |
|------|------|------|------|------|
| 代码助手 | worker | cloud | Claude Sonnet | online |
| 测试 Agent | worker | cloud | GPT-4 Turbo | online |
| 数据分析师 | worker | cloud | Gemini 1.5 Pro | online |
| 本地推理 Agent | worker | local | Llama 3.1 70B | online |
| Lark 连接器 | connector | cloud | — | online |
| Slack 连接器 | connector | cloud | — | idle |

#### 人类员工 Tab

**人类员工卡片**（`.human-card`）

```
[👤 icon 64×64]
[名称 font-weight: 800]
[邮箱]
[角色徽章（admin/designer/backend/frontend）]
[负责内容]
```

**4 名人类员工数据**

| 姓名 | 邮箱 | 角色 | 负责 | 部门 |
|------|------|------|------|------|
| 陈明辉 | chen@coco.xyz | 管理员 | 系统配置、权限管理 | 产品部 |
| 李思琪 | lisa@coco.xyz | 设计师 | UI/UX 设计 | 产品部 |
| 张伟 | zhangwei@coco.xyz | 后端开发 | API、数据库、基础设施 | 工程部 |
| 王小红 | wang@coco.xyz | 前端开发 | React 组件、前端架构 | 工程部 |

#### 组织架构 Tab

树形结构，公司名 + 总人数（10人：4人类 + 6数字员工），`border-left: 2px solid var(--border-light)` 树线

**三个部门**：产品部 / 工程部 / 数字员工

成员图标：👤 人类（圆形，`background: rgba(108,92,231,0.1)`）/ 🤖 Agent（`background: rgba(108,92,231,0.15)`）/ 🔗 Connector（`background: rgba(253,203,110,0.15)`）

#### 操作

- "创建数字员工"按钮 → 打开 `newProjectModal`（临时用，待完善）
- "邀请成员"按钮 → 打开邀请 Modal，填写邮箱和角色（成员/管理员/观察者）

---

### 4.5 Agent 管理

#### 本周使用概览横幅

```
📊 本周使用概览
[47 任务执行]  [680 消耗积分]  [96.2% 平均准确率]  [99.8% 在线率]
```

固定数值，颜色依次：紫色 / `#6c5ce7` / `#00b894` / `#fdcb6e`

#### 已购 Agent 列表

每张卡片（`.agent-card`）：

```
[大头像 48px] [名称 + 状态角标] [角色描述]
[框架徽章] [订阅计划]
[📊 本周使用]
[本周任务 | 消耗积分 | 准确率 | 响应]
[简介描述]
[配置按钮] [移除按钮（红色边框）]
```

KPI 3×1 网格（实际 4 个 KPI），每个 KPI：`font-size: 20px; font-weight: 800` 数值 + 11px 标签。

**4 名已购 Agent 数据**

| Agent | 框架 | 计划 | 本周任务 | 积分 | 准确率 | 响应时间 |
|-------|------|------|---------|------|--------|---------|
| COCO Agent | COCO | Pro · $29/月 | 18 | 210 | 96.5% | 120ms |
| 代码助手 | Zylos | Pro · $29/月 | 15 | 260 | 94.2% | 85ms |
| 测试 Agent | Zylos | Pro · $29/月 | 8 | 120 | 91.8% | 200ms |
| 数据分析师 | OpenClaw | Pro · $19/月 | 6 | 90 | 98.1% | 150ms |

**配置 Modal 字段**：Agent 名称 / 角色描述 / 响应模式（自动响应/确认后响应/仅通知）/ 最大并发任务数（1/3/5/10/无限制）/ 启用自动操作（toggle）/ 允许外部 API 访问（toggle）/ 发送操作通知（toggle）

#### Agent 市场

浮层 Modal（`.chat-modal-overlay`），包含：

**已有 Agent 区域**："已有 Agent"标题（按订阅框架分组显示实例），每个框架下列出其 Agent 实例，状态可为"已在群中"（绿）/"加入群聊"（紫）

**发现新 Agent 区域**：未订阅框架的卡片，状态为"订阅"

**顶部积分显示**：💎 数字 积分，点击进入积分详情

**搜索框**：实时过滤 Agent 名称和描述

#### 三大 Agent 框架

```javascript
const allAgents = [
  {
    id: 'coco', name: 'COCO Agent', emoji: '🐙',
    color: 'linear-gradient(135deg,#d357fe,#96bbff)',
    desc: '工作区内置协作 Agent，任务协调、消息汇总、会议纪要',
    tag: '内置',
    features: ['智能任务分配与跟踪','多群消息自动汇总','会议纪要生成','跨团队工作流协调'],
    pricing: [
      { plan: 'Free', price: '$0', period: '/月', credits: 0,
        features: ['基础任务协调','每日 50 条消息','单群支持'] },
      { plan: 'Pro', price: '$29', period: '/月', credits: 290,
        features: ['无限消息','多群汇总','优先响应','自定义指令'], recommended: true },
      { plan: 'Enterprise', price: '$99', period: '/月', credits: 990,
        features: ['自定义训练','API 接入','SSO 集成','专属客户经理'] }
    ]
  },
  {
    id: 'zylos', name: 'Zylos', emoji: '⚡',
    color: 'linear-gradient(135deg,#6c5ce7,#a29bfe)',
    desc: '全能 AI 伙伴 — 编程、自动化、浏览器操作、定时任务、数据分析',
    tag: '热门',
    pricing: [
      { plan: 'Air', price: '$9.9', period: '/月', credits: 100, ... },
      { plan: 'Pro', price: '$29', period: '/月', credits: 290, ..., recommended: true },
      { plan: 'Enterprise', price: '联系销售', isEnterprise: true }
    ]
  },
  {
    id: 'openclaw', name: 'OpenClaw', emoji: '🦀',
    color: 'linear-gradient(135deg,#00b894,#55efc4)',
    tag: '开源',
    pricing: [
      { plan: 'Community', price: '$0', ... },
      { plan: 'Pro', price: '$19', period: '/月', credits: 190, ..., recommended: true },
      { plan: 'Team', price: '$49', credits: 490 }
    ]
  }
]
```

#### 积分系统

- 初始积分：`userCredits = 2580`
- 10 积分 = $0.1
- Pro 及以上方案每月返还等额积分
- 充值选项：500积分/$5 / 2000积分/$18(省10%) / 5000积分/$40(省20%)
- 可抵扣订阅费用（有开关，默认开启）
- 积分详情：本月获得 +580 / 本月消耗 -320 / 订阅返积分 +290

#### 可购买 Agent 列表（8 个空白/预制实例）

| 名称 | 框架 | 价格 | 描述 |
|------|------|------|------|
| Zylos 空白实例 | Zylos | $29/月 | 自由配置技能、工具和工作流 |
| OpenClaw 空白实例 | OpenClaw | $19/月 | 自由搭建 MCP 技能和 API 集成 |
| Hermes 空白实例 | Hermes | $24/月 | 自由配置通信、调度和自动化 |
| Zylos 运维助手 | Zylos | $29/月 | 部署监控、日志分析、告警处理 |
| Skill Builder | OpenClaw | $19/月 | Skill 构建、MCP 协议、API 集成 |
| Skill Hub | OpenClaw | $19/月 | 技能搜索、安装、编排 |
| Security Bot | Zylos | $29/月 | 实时安全监控和漏洞扫描 |
| Hermes 通知中心 | Hermes | $24/月 | 多渠道消息分发、通知编排、告警路由 |

---

### 4.6 技能（Skills）

#### 已安装技能区

**标题**："已安装 · N"（N 实时更新）+ "显示更多"/"收起"按钮（超过 4 个时显示）

**技能卡片**（`.skill-card`）

```
[图标 44×44px border-radius:12px] [名称 + 可选徽章（套件/MCP）] [描述文字（2行截断）] [开关 toggle]
```

**徽章类型**

| 徽章 | 样式 |
|------|------|
| 套件（`.skill-badge.suite`） | `background: rgba(108,92,231,0.12)`，`color: #6c5ce7` |
| MCP（`.skill-badge.mcp`） | `background: rgba(0,184,148,0.12)`，`color: #00b894` |

**代码开发模式已安装技能（6 个）**

| 名称 | 描述 | 徽章 | 默认启用 |
|------|------|------|---------|
| agent-browser | 基于 Vercel agent-browser CLI 的浏览器自动化插件，首次使用时自动安装 | 套件 | 是 |
| playwright-cli | Automates browser interactions for web testing, form filling, screenshots, and data extraction | 套件 | 是 |
| find-skills | 帮助发现和安装 AI Agent 技能，支持从 Vercel Skills 和 ClawHub 两个技能仓库搜索和安装 | — | 是 |
| code-review | 代码审查助手，自动分析 PR 并提供改进建议 | — | 是 |
| doc-writer | 自动生成 API 文档、README 和技术文档 | — | 是 |
| git-assistant | Git 工作流自动化，智能 commit message、分支管理、冲突解决 | — | 是 |

**日常办公模式已安装技能（6 个）**

| 名称 | 描述 | 徽章 | 默认启用 |
|------|------|------|---------|
| 腾讯ima | ima笔记与知识库管理（读取、写入、检索、上传文件） | — | 否 |
| 日程助手 | 智能日程管理、会议安排、时间冲突检测和提醒 | — | 是 |
| 邮件摘要 | 自动汇总邮件要点、提取待办事项、智能分类 | — | 是 |
| 会议纪要 | 会议录音转写、自动生成会议纪要和行动项 | 套件 | 是 |
| 翻译助手 | 多语言互译，支持专业术语和语境理解 | — | 是 |
| 文档排版 | 文档格式化、模板应用、PDF 导出 | — | 是 |

#### 技能市场

**三个 Tab**：推荐 / SkillHub / 套件

**分类筛选 Chips**（9 个）：全部 / 开发工具 / 投资理财 / 内容创作 / 数据分析 / 效率工具 / 办公协同 / 商业运营 / 知识与学习

**搜索框**：实时过滤已安装和市场技能（名称+描述）

**MCP 服务器按钮**：右上角，点击 showToast（placeholder）

市场卡片样式与已安装相同，点击触发 "安装 XXX 中..." Toast（placeholder）。

**代码开发模式 - 推荐 Tab（6 个）**：cnb.cool / TAPD / 品牌设计风格专家 / 数据分析大师 / SEO 优化器 / NeoData金融搜索

**日常办公模式 - 推荐 Tab（6 个）**：腾讯文档 / 腾讯会议 / 学习路径规划 / 智能客服 / 报告生成器 / 费用报销

---

### 4.7 工具箱（Toolbox）

#### 视图切换

顶部右侧：**代码开发** / **日常办公**（`.tasks-view-toggle`），切换后重新渲染工具列表。

#### 工具卡片（`.tool-card`）

```
[图标 44×44px border-radius:12px] [名称+描述+连接状态] [开关 toggle]
```

状态点：6×6px 圆形，connected=`var(--success)` 绿，disconnected=`var(--text-muted)` 灰

toggle 开关切换后 showToast "XXX 已连接/已断开"

#### 代码开发工具集

**已安装（6 个）**：GitHub（已连）/ Figma（已连）/ Vercel（已连）/ Jira（未连）/ Notion（已连）/ Sentry（已连）

**浏览市场（4 个）**：Linear / Datadog / AWS / GitLab

#### 日常办公工具集

**已安装（4 个）**：Slack（已连）/ Email（已连）/ Lark（已连）/ Google Calendar（已连）

**浏览市场（6 个）**：Telegram / Discord / Zoom / WeChat Work / Outlook / Google Drive

---

### 4.8 管理后台（Admin）

#### 统计卡片（4 个）

`grid-template-columns: repeat(auto-fill, minmax(200px, 1fr))`

| 指标 | 数值 | 后缀 |
|------|------|------|
| 活跃用户 | 24 | — |
| Agent 任务 | 1,287 | — |
| 消息总数 | 8,432 | — |
| 平均响应 | 120 | ms |

数值进入视图时有计数动画（ease out cubic，1200ms）。

#### 周使用量图表

7 根柱子，标签 周一~周日，数据 65/80/55/90/75/40/30，最大值 90（100% 高度），`height: 180px`。

柱子：`background: linear-gradient(180deg, var(--accent), var(--accent-light))`，`border-radius: 6px 6px 0 0`，进入视图后动画展开（延迟 200ms）。

#### 模型使用分布表

| 模型 | 调用次数 | Token 消耗 | 成本 |
|------|---------|-----------|------|
| Claude Sonnet | 89 | 1.2M | $52 |
| GPT-4 Turbo | 45 | 0.8M | $38 |
| Gemini 1.5 Pro | 22 | 0.5M | $18 |
| Llama 3 (本地) | 38 | 0.6M | $0 |

表头：`font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em`，底部 2px 实线分隔

#### 席位管理表

操作列："管理"按钮 + "删除"按钮（管理员不显示删除），删除 hover 变红。

| 成员 | 角色 | 状态 | 最后活跃 |
|------|------|------|---------|
| Stephanie | 管理员 | 在线 | 刚刚 |
| Alex | 成员 | 在线 | 5分钟前 |
| Maya | 成员 | 忙碌 | 15分钟前 |
| Liam | 成员 | 离线 | 昨天 |
| COCO Agent | AI Agent | 在线 | 持续在线 |
| Code Bot | AI Agent | 在线 | 持续在线 |

#### 活动时间线

5 条记录：部署完成 / 代码审查通过 / 周报生成 / 新成员加入 / 设计更新

时间线节点：32×32px 圆形，`background: var(--accent-bg)`；节点间竖线：`left: 15px`，`width: 2px`，`background: var(--border-light)`

---

### 4.9 设置（Settings）

**最大宽度**：`max-width: 700px`，四个 glass-card 区块垂直排列，`gap: 24px`。

每个区块：`padding: 24px`，标题 16px `font-weight: 700`，下方 `border-bottom: 1px solid var(--border-light)`

**设置行**：左侧标签+描述，右侧控件，`justify-content: space-between`，行间 `border-top: 1px solid var(--border-light)`

#### 通用设置（3 行）

| 设置项 | 控件 | 默认值 | 特性 |
|--------|------|--------|------|
| 工作区名称 | input `width: 240px` | COCO Team | 实时同步侧边栏品牌名 |
| 语言 | select `width: 180px` | 简体中文 | 选项：简体中文/English/日本語 |
| 深色模式 | toggle switch | 关 | — |

#### 通知设置（3 行）

| 设置项 | 控件 | 默认值 |
|--------|------|--------|
| 桌面通知 | toggle | 开 |
| 邮件通知 | toggle | 关 |
| Agent 操作通知 | toggle | 开 |

#### 安全设置（2 行）

| 设置项 | 控件 | 默认值 | 选项 |
|--------|------|--------|------|
| 两步验证 | toggle | 关 | — |
| 会话超时 | select `width: 180px` | 1 小时 | 30分钟/1小时/4小时/从不 |

#### 集成设置（3 行）

| 设置项 | 控件 | 描述 |
|--------|------|------|
| GitHub 连接 | btn-sm btn-secondary "配置" | 同步代码仓库和 PR |
| Slack 集成 | btn-sm btn-secondary "配置" | 消息同步到 Slack 频道 |
| Webhook URL | input `width: 280px` placeholder `https://your-server.com/webhook` | 接收事件推送 |

**保存按钮**：右下角，`btn btn-primary "保存更改"`，点击后同步侧边栏名称并 showToast "所有设置已保存"

---

## 5. Onboarding 引导流程

在 COCO Agent 的 DM 频道内，以聊天气泡形式依次展示引导步骤，每步有用户回复气泡和 COCO Agent 气泡交替出现。

可通过"↻ 重新体验引导"按钮（右下角，绝对定位）重置。

### 步骤 0：欢迎 + 工作区命名

**COCO Agent 消息**：
> 你好！欢迎来到 **COCO Workspace** 🎉  
> 我是 COCO Agent，你的工作区助手。让我帮你完成初始设置 — 只需要几步。  
> 首先，给你的工作区起个名字吧：

**嵌入式卡片**：
- 文本输入框（默认值 "COCO Team"）
- 工作区类型选择（3 个选项）：
  - 👥 团队（默认选中，accent 边框）
  - 👤 个人
  - 🚀 创业公司
- "继续"按钮

用户点击继续后，在输入框上方显示用户回复气泡（"工作区名称：XXX"），实时更新侧边栏品牌名。

### 步骤 1：Agent 选择路径

**COCO Agent 消息**：
> 好的！**XXX** 工作区已创建 ✅  
> 接下来，让我们为工作区添加 AI Agent。  
> 你目前的情况是？

**两个选项卡片**：

**选项 A：接入已有 Agent**
> 🔗 接入已有 Agent  
> 我已经有 Zylos、OpenClaw 等服务，想接入到工作区

点击后 → 显示 Agent 选择列表（从 `allAgents` 中排除 coco，Zylos/OpenClaw/Hermes 等），选择后进入连接表单：
- 服务地址（Endpoint URL）
- API Key / Token（type="password"）
- 协议类型：MCP（默认）/ REST API / WebSocket
- "验证并接入"按钮

**选项 B：订阅新服务**
> 🛒 订阅新服务  
> 我还没有 Agent，想看看有什么可以用的

点击后 → 显示全量 Agent 列表（可多选，已订阅的不可取消），显示价格。选择后点击"继续"：
- 若有付费 Agent → 弹出付款 Modal（见下方）
- 全部免费 → 直接进入步骤 2

**付款 Modal 字段**：
- 订阅明细列表（Agent 名+方案+价格）
- 订阅费用合计
- 积分抵扣开关（默认开）+ 余额显示
- 积分抵扣行（显示抵扣数量和金额）
- 应付金额（实时更新）
- 支付方式选择（Stripe/微信/支付宝，单选）
- "确认支付"按钮
- 注意文字："订阅后可随时取消 · 按月计费 · 随时退订"

### 步骤 2：建立群聊

**COCO Agent 消息**：
> Agent 已添加 ✅  
> 现在来创建你的第一个群聊，邀请团队成员和 AI Agent 一起协作：

**嵌入式建群卡片**：
- 群聊名称输入框（默认值 "产品开发群"）
- 可见性选择：🌐 公开群 / 🔒 私有群（默认公开）
- 邀请成员区：邮箱输入框 + "+ 邀请"按钮（Enter 也可触发），已邀请成员以 chip 形式展示（可删除），邮件校验（含 @）
- 添加 Agent 区：已订阅的 Agent 以可选 chip 显示（默认全选），"+ 更多"按钮打开 Agent 市场
- "创建群聊并完成设置"按钮

### 步骤 3：完成

**COCO Agent 消息**：
> 🎉 **设置完成！**你的工作区已准备就绪。
>
> ✅ 工作区已创建  
> ✅ AI Agent 已加入  
> ✅ 「XXX」群聊已建立  
> ✅ 团队成员已邀请
>
> 你可以直接在下方输入框开始对话，或者通过左侧边栏探索更多功能。有什么需要随时 @我！

**两个按钮**：
- "开始对话"→ 切换到产品开发群频道
- "探索 Agent"→ 切换到工具箱模块

---

## 6. 全局功能

### 6.1 CMD+K 命令面板

**触发方式**：点击顶栏按钮或 `Ctrl/Cmd + K`

**样式**：居中，顶部 15vh 处，`max-width: 600px`，`border-radius: 24px`，backdrop blur 8px，`rgba(0,0,0,0.3)` 遮罩

**输入框**：🔍 图标 + input，16px，无边框，`background: transparent`

**结果列表**：`max-height: 360px`，可滚动，分组标题 "命令"（11px 大写），每项 `padding: 12px 16px`，`border-radius: 10px`，32×32px 图标区

**Footer**：`↑↓ 导航` + `Enter 选择` + `Esc 关闭`（kbd 样式）

**命令列表（12 条）**

| 图标 | 标签 | 操作 |
|------|------|------|
| 💬 | 打开对话 | 切换到 chat 模块 |
| ✅ | 打开任务 | 切换到 tasks 模块 |
| 📁 | 打开项目 | 切换到 projects 模块 |
| 👥 | 打开通讯录 | 切换到 team 模块 |
| 🤖 | Agent 管理 | 切换到 agents 模块 |
| 🧩 | 打开技能 | 切换到 skills 模块 |
| 🧰 | 打开工具箱 | 切换到 toolbox 模块 |
| 📊 | 管理后台 | 切换到 admin 模块 |
| ⚙️ | 打开设置 | 切换到 settings 模块 |
| ➕ | 新建任务 | 切换到 tasks + 打开 taskModal |
| 🔄 | 切换模式 | 切换 code/office 模式 |
| 👤 | 邀请成员 | 切换到 team + 打开 inviteModal |

**关闭**：点击遮罩/Esc/再次按 Cmd+K

### 6.2 Toast 通知

`position: fixed; bottom: 32px; left: 50%`，默认 `transform: translateX(-50%) translateY(80px)`（隐藏），展示时 `translateY(0)`

**样式**：`background: var(--text-heading)（黑色）`，白字，`padding: 14px 28px`，`border-radius: 12px`，14px `font-weight: 600`，`box-shadow: 0 8px 32px rgba(0,0,0,0.2)`，`z-index: 9999`，`pointer-events: none`

**时长**：2500ms 后自动消失（clearTimeout 防止重叠）

**过渡**：`var(--transition-silky)` = `0.5s cubic-bezier(0.22, 1, 0.36, 1)`

### 6.3 面板拖拽

**垂直分隔线**（对话模块左右栏）：

- 左侧分隔线（#dividerLeft）控制会话列表宽度，范围 0~400px
- 右侧分隔线（#dividerRight）控制信息面板宽度，范围 0~420px
- 宽度 < 60px 时：`opacity: 0; overflow: hidden; padding: 0`（完全收起）

**水平分隔线**（#dividerBottom）：控制消息区与输入区的高度比，消息区高度范围 100px ~ (可用高度 - 80px)

**样式**：平时透明 1px 竖线，hover/dragging 时变为 3px 紫线，拖动时 `cursor: col-resize`，禁用 `user-select`

### 6.4 弹性物理动画

全局实现的弹簧阻尼动画（Spring 类，`stiffness: 180, damping: 12`）：
- **按下**：按钮/卡片缩放到 0.95
- **松开**：弹回 1.0
- **悬浮卡片**：translateY 到 -4px，阴影增强（弹性过渡）

### 6.5 自定义光标

隐藏系统光标，实现三层光标：
- **圆环**（`.custom-cursor`）：20px，`border: 2px solid #d357fe`，弹簧跟随（`stiffness: 0.12, damping: 0.75`）
  - Hover 可交互元素时：放大到 40px，`background: rgba(211,87,254,0.1)`，边框变 `#96bbff`
  - 点击时：缩小到 16px，`background: rgba(211,87,254,0.3)`
- **中心点**（`.cursor-dot`）：6px，`background: #d357fe`，快速跟随（0.35 线性插值）
- **光晕**（`.cursor-glow`）：120px 径向渐变，极慢跟随（0.06 插值）
- **轨迹粒子**（8 个）：每 30ms 生成一个，快速衰减（×0.9/帧）

---

## 7. 数据模型

### 7.1 会话（conversationsData）

见 4.1 节

### 7.2 频道消息（channelMessages）

```javascript
{
  'channel-id': [
    {
      name: '张伟',             // 发送者名称
      avatar: '伟',            // 头像（emoji 或首字母）
      color: 'linear-gradient(...)' ,  // 头像背景
      text: 'HTML 内容字符串', // 支持 @mention、code-block、file-tags 等 HTML
      time: '09:30',           // HH:MM 格式
      isAgent: false,          // 是否 Agent
      model: 'Claude Sonnet'   // 可选，Agent 使用的模型
    }
  ]
}
```

已预填消息的频道：`product-dev`、`code-assistant`、`li-siqi`、`test-agent`、`general`、`engineering`、`design`、`bot-arena`

### 7.3 任务（tasksData）

见 4.2 节

### 7.4 项目（projectsData）

见 4.3 节

### 7.5 Agent（agentsData + marketplaceAgents）

见 4.5 节

### 7.6 数字员工（digitalEmployees）

见 4.4 节

### 7.7 人类员工（humanEmployees）

见 4.4 节

### 7.8 组织架构（orgData）

```javascript
{
  name: 'COCO 团队',
  total: 10, humans: 4, digital: 6,
  departments: [
    { name: '产品部', icon: '📁', members: [...] },
    { name: '工程部', icon: '📁', members: [...] },
    { name: '数字员工', icon: '📁', members: [...] }
  ]
}
```

### 7.9 Admin 数据

- `adminStats`：4 条统计卡片
- `chartData`：7 天使用量
- `modelUsageData`：4 个模型的调用统计
- `seatData`：6 名席位成员
- `timelineData`：5 条活动记录

### 7.10 CMD+K 命令（cmdkCommands）

见 6.1 节

### 7.11 Agent 框架（allAgents + agentInstances）

见 4.5 节

### 7.12 工具集（toolsCategoryMap）

见 4.7 节

### 7.13 技能集（installedSkillsByMode + marketplaceSkillsByMode）

见 4.6 节

### 7.14 分类提示词（categoryData）

```javascript
{
  office: [
    { icon: '📄', name: '文档处理', prompts: [...3条...] },
    { icon: '📊', name: '数据分析及可视化', prompts: [...3条...] },
    { icon: '🔍', name: '深度研究', prompts: [...3条...] },
    { icon: '📋', name: '产品管理', prompts: [...3条...] },
    { icon: '🖥', name: '幻灯片', prompts: [...3条...] },
    { icon: '🎨', name: '设计', prompts: [...3条...] },
    { icon: '✉️', name: '邮件编辑', prompts: [...3条...] },
    { icon: '💰', name: '金融服务', prompts: [...3条...] },
  ],
  code: [
    { icon: '<>', name: '日常开发', prompts: [...3条...] },
    { icon: '🌐', name: '网站开发', prompts: [...3条...] },
    { icon: '🤖', name: 'Agent 应用', prompts: [...3条...] },
    { icon: '🔧', name: 'Skill 开发', prompts: [...3条...] },
    { icon: '⚙️', name: 'CI/CD', prompts: [...3条...] },
    { icon: '📝', name: '文档', prompts: [...3条...] },
  ]
}
```

---

## 8. 视觉规范

### 8.1 CSS 变量（颜色）

```css
:root {
  /* 背景 */
  --bg-main:         #f7faff;                     /* 页面底色（浅蓝白） */
  --bg-card:         #ffffff;                     /* 卡片/面板底色 */
  --bg-glass:        rgba(255,255,255,0.85);       /* 磨砂玻璃 */
  --bg-glass-strong: rgba(255,255,255,0.95);       /* 强磨砂玻璃 */

  /* 文字 */
  --text-heading:    #000000;                     /* 标题黑 */
  --text-body:       #343639;                     /* 正文深灰 */
  --text-muted:      #b6b6b6;                     /* 次要文字浅灰 */

  /* 主题色 */
  --accent:          #d357fe;                     /* 主紫色 */
  --accent-light:    #96bbff;                     /* 浅蓝紫 */
  --accent-bg:       rgba(211,87,254,0.08);        /* 紫色淡背景 */

  /* 状态色 */
  --success:         #00cec9;                     /* 青色/成功 */
  --warning:         #fdcb6e;                     /* 黄色/警告 */
  --danger:          #ff7675;                     /* 红色/危险 */

  /* 边框 */
  --border-glass:    rgba(0,0,0,0.08);             /* 玻璃边框 */
  --border-light:    rgba(0,0,0,0.08);             /* 轻边框（同值） */
}
```

### 8.2 CSS 变量（阴影）

```css
--shadow-card:  0 1px 3px rgba(0,0,0,0.04), 0 4px 16px rgba(0,0,0,0.04);
--shadow-modal: 0 8px 32px rgba(0,0,0,0.1);
--shadow-hover: 0 4px 20px rgba(0,0,0,0.08);
```

### 8.3 CSS 变量（圆角）

```css
--radius-card:  16px;   /* 卡片 */
--radius-btn:   12px;   /* 按钮（注意：核心按钮使用 border-radius:0）*/
--radius-modal: 24px;   /* 对话框 */
```

> 注意：Splash 模式选择按钮和主 `.btn` 类使用 `border-radius: 0`（方形设计语言），`--radius-btn` 主要用于工具栏等小按钮。

### 8.4 CSS 变量（过渡动画）

```css
--transition-fast:   0.2s cubic-bezier(0.4, 0, 0.2, 1);     /* 快速（按钮 hover） */
--transition-smooth: 0.3s cubic-bezier(0.4, 0, 0.2, 1);     /* 标准 */
--transition-silky:  0.5s cubic-bezier(0.22, 1, 0.36, 1);   /* 丝滑（侧边栏、Toast） */
--transition-splash: 0.8s cubic-bezier(0.22, 1, 0.36, 1);   /* Splash 淡出 */
```

### 8.5 字体

```css
--font-mono: 'IBM Plex Mono', 'JetBrains Mono', monospace;
--font-sans: 'Inter', system-ui, -apple-system, sans-serif;
```

- `font-sans`：正文、UI 标签
- `font-mono`：品牌名、模块标题、导航标签、按钮文字（模式选择、工具栏）、section-title、代码块

Google Fonts 引入：`IBM Plex Mono:wght@300;400;500` + `Inter:wght@300;400;500;600;700;800;900`

### 8.6 按钮系统

| 类型 | 背景 | 文字 | 边框 | Hover |
|------|------|------|------|-------|
| `.btn-primary` | `#000000` 黑 | 白 | `#000000` | 变 `var(--accent)` |
| `.btn-secondary` | 透明 | `var(--text-body)` | `var(--border-light)` | 边框和文字变 `var(--accent)` |
| `.btn-danger` | `var(--danger)` | 白 | — | — |
| `.btn-success` | `var(--success)` | 白 | — | — |
| `.btn-sm` | — | — | — | `padding: 6px 14px; font-size: 13px` |

所有按钮：`border-radius: 0`（方形），`font-family: IBM Plex Mono`，`font-size: 12px`，`font-weight: 500`，`letter-spacing: 0.08em`，`text-transform: uppercase`，点击 `transform: scale(0.95)`

### 8.7 徽章/角标系统

```css
/* 类型 */
.badge-agent:   background: rgba(211,87,254,0.1);  color: var(--accent);
.badge-human:   background: rgba(0,206,201,0.1);   color: var(--success);

/* 在线状态 */
.badge-online:  background: rgba(0,206,201,0.1);   color: #00a8a3;
.badge-busy:    background: rgba(253,203,110,0.15); color: #d4a017;
.badge-idle:    background: rgba(0,0,0,0.05);       color: var(--text-muted);
.badge-offline: background: rgba(0,0,0,0.04);       color: #aaa;

/* 优先级 */
.priority-high:   background: rgba(255,118,117,0.12); color: var(--danger);
.priority-medium: background: rgba(253,203,110,0.15); color: #d4a017;
.priority-low:    background: rgba(0,206,201,0.1);    color: var(--success);

/* 项目状态 */
.status-active:   background: rgba(0,206,201,0.1);   color: #00a8a3;
.status-planning: background: rgba(211,87,254,0.1);  color: var(--accent);
.status-review:   background: rgba(253,203,110,0.15);color: #d4a017;
```

徽章通用：`padding: 3px 10px`，`border-radius: 20px`，`font-size: 11px`，`font-weight: 600`

### 8.8 头像系统

```css
.avatar:    width: 32px; height: 32px; border-radius: 50%;  font-size: 12px;
.avatar-sm: width: 28px; height: 28px;                      font-size: 11px;
.avatar-lg: width: 48px; height: 48px;                      font-size: 18px;
.avatar-xl: width: 64px; height: 64px;                      font-size: 24px;
```

所有头像：`display: flex; align-items: center; justify-content: center; font-weight: 700; color: #fff; flex-shrink: 0`

### 8.9 Glass Card

```css
.glass-card {
  background: var(--bg-card);
  border: 1px solid var(--border-light);
  border-radius: var(--radius-card);  /* 16px */
  box-shadow: var(--shadow-card);
  padding: 24px;
  transition: all var(--transition-smooth);
  position: relative;
  overflow: hidden;
}
.glass-card:hover {
  box-shadow: var(--shadow-hover);
  transform: translateY(-2px);
  border-color: rgba(211,87,254,0.15);
}
```

### 8.10 表单元素

**Input/Select**：`border: 1.5px solid var(--border-light)`，`border-radius: 10px`，`padding: 10px 14px`，14px，focus 时 `border-color: var(--accent)` + `box-shadow: 0 0 0 3px rgba(211,87,254,0.1)`

**Toggle Switch**：44×24px，轨道 `border-radius: 12px`，默认灰色（#ddd），选中 `var(--accent)`，滑块 18×18px 白色，`box-shadow: 0 1px 4px rgba(0,0,0,0.15)`

**Modal 遮罩**：`background: rgba(0,0,0,0.3)`，`backdrop-filter: blur(4px)`，z-index 9000

**Section Title**（`.section-title`）：`font-family: IBM Plex Mono`，11px，`text-transform: uppercase`，`letter-spacing: 0.14em`，`color: var(--accent)`，左侧有 16px 水平线装饰（`::before` 伪元素）

---

## 9. 模式差异（代码开发 vs 日常办公）

切换模式时（`switchMode(mode)`）会影响以下模块的内容显示：

| 模块 | 代码开发模式 | 日常办公模式 |
|------|------------|------------|
| **对话 - 分类 Chips**（6个） | `<>` 日常开发 / 🌐 网站开发 / 🤖 Agent 应用 / 🔧 Skill 开发 / ⚙️ CI/CD / 📝 文档 | 📄 文档处理 / 📊 数据分析及可视化 / 🔍 深度研究 / 📋 产品管理 / 🖥 幻灯片 / 🎨 设计 / ✉️ 邮件编辑 / 💰 金融服务 |
| **任务** | 显示 mode='code' 的任务（含 GitHub 任务） | 显示 mode='office' 的任务 |
| **任务 - 项目筛选** | 仅显示代码模式项目 | 仅显示办公模式项目 |
| **项目列表** | COCO Workspace V2 / 智能客服系统 / 数据分析看板 / GitHub 仓库 / 归档项目 | 社媒运营 / 客户管理 / 内容营销 / 市场活动 |
| **技能 - 已安装** | 6 个开发技能（浏览器自动化、代码审查等） | 6 个办公技能（日程、邮件、会议纪要等） |
| **技能 - 市场** | 开发类：cnb.cool / TAPD / API Tester / CI/CD 等 | 办公类：腾讯文档 / 腾讯会议 / 合同审查等 |
| **工具箱** | 默认显示"代码开发"分类（GitHub/Figma/Vercel 等） | 默认显示"日常办公"分类（Slack/Email/Lark 等） |
| **Toast 提示** | "已切换到代码开发模式" | "已切换到日常办公模式" |

切换模式不影响：对话内容、通讯录、Agent 管理、管理后台、设置。

---

## 10. 待优化项

### 10.1 Toast Placeholder 功能

以下功能点击后仅显示 Toast，未实现实际逻辑：

| 位置 | 操作 | Toast 内容 |
|------|------|-----------|
| 技能模块 | 添加技能按钮 | "添加技能功能开发中" |
| 技能市场 | 点击任意市场技能 | "安装 XXX 中..." |
| 技能市场 | MCP 服务器按钮 | "MCP 服务器管理" |
| 管理后台 | 添加席位 | "添加席位功能开发中" |
| 管理后台 | 管理席位 | "管理 XXX 的席位" |
| 管理后台 | 删除席位 | "确认删除 XXX？" |
| 设置 - 集成 | GitHub 配置 | "GitHub 连接配置中..." |
| 设置 - 集成 | Slack 配置 | "Slack 集成配置中..." |
| Agent 模式菜单 | 召唤专家 | "召唤专家功能即将上线" |
| 模型选择 | 配置自定义模型 | "自定义模型配置即将上线" |
| Skills 下拉 | 导入技能 | "技能导入即将上线" |
| 积分面板 | 充值按钮 | "充值功能即将上线" |
| 通讯录 | 创建数字员工按钮 | 打开 newProjectModal（错误关联） |

### 10.2 未实现的交互

- **拖拽任务卡片**（看板列间）：HTML5 drag & drop 事件已绑定，逻辑完整，但目前仅更新数据状态不做持久化
- **工作区名称实时同步**：修改设置中的名称实时更新侧边栏，但刷新后会丢失
- **会话搜索**：仅在前端过滤已有数据，无后端
- **Agent 配置 Modal**：字段可编辑但保存仅 showToast，无持久化
- **邀请成员**：Modal 填写邮件后 showToast，无实际发送
- **GitHub 连接/Slack 集成**：设置页配置按钮为 placeholder
- **任务拖拽**：实现了基础 drag & drop，但列间状态更新后未刷新列计数（实际已通过 `renderTasks()` 刷新）
- **通讯录 - 人类员工卡片点击**：无 profile modal 关联（数字员工卡片也无点击行为，仅显示信息）
- **Dark mode toggle**：设置中有开关但无实现
- **移动端响应式**：900px 以下断点仅折叠侧边栏和信息面板，未做完整移动适配

### 10.3 数据来源问题

- `channelMessages['coco-agent']` 为空数组，onboarding 开始时会清空并通过 `startOnboardingChat()` 填充，而 Splash 入场后会调用 `initAllModules()` → `startOnboardingChat()`，因此 COCO Agent 频道的内容完全由 onboarding 流程控制
- `teamData` 数组（8 个老成员）仍被 `showProfile()` 使用（通讯录-头像点击），但通讯录展示已迁移到 `digitalEmployees` + `humanEmployees` 新数据，两套数据并存
- `toggleSkill()` 函数引用了 `installedSkills`（未定义变量），实际已安装技能存在 `installedSkillsByMode[mode]` 中，是一个 Bug
