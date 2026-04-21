# COCO Workspace 落地页 — 产品需求文档（SSOT）

> 基于原型文件 `workspace/prototypes/coco-workspace-v-light.html` 逆向提取。
> 本文档是重建该页面的唯一真实来源，无需查阅原始 HTML 即可完整还原页面。

---

## 1. 概述

### 页面目标

本页面是 COCO Workspace 产品的营销落地页（light 主题版本），用于对外展示产品价值、吸引目标用户申请早期访问资格（Early Access）。

### 目标用户

- 中小型团队的技术负责人、产品经理、工程师
- 关注 AI 赋能工作流的早期采用者
- 正在寻找「人 + AI 协同」统一工作台的团队决策者

### 核心价值主张

**"Your AI-powered workspace for everyday work. Chat, collaborate, and get things done — effortlessly."**

三个核心差异点：
1. **AI 原生**：AI 深度嵌入每一个工作流，而非外挂插件
2. **统一指挥中心**：团队聊天与 AI Agent 在同一界面协作，没有信息孤岛
3. **模式自适应**：工作界面随任务类型（代码 / 文档 / 专注）动态切换

---

## 2. 页面结构

页面共五个主要 Section，按滚动顺序排列：

| 顺序 | Section ID | 组件类名 | 高度策略 |
|------|-----------|---------|---------|
| 1 | `#hero` | `.hero` | `min-height: auto`，`padding-top: 140px` |
| 2 | `#workspace` | `.workspace` | `min-height: auto`，`padding: 100px 48px` |
| 3 | `#features` | `.features` | `min-height: 100vh`，`padding: 120px 48px` |
| 4 | `#modes` | `.modes` | `min-height: 100vh`，`padding: 120px 48px` |
| 5 | `#cta` | `.cta-section` | `min-height: 100vh`，`padding: 120px 48px` |

页面结构层次（z-index）：

- `z-index: 0` — WebGL Canvas（固定背景，全屏粒子场景）
- `z-index: 10` — 滚动内容层（`.scroll-content`）
- `z-index: 100` — 导航栏（`nav`，fixed）
- `z-index: 1000` — 加载屏（`#loading`，fixed，动画结束后隐藏）
- `z-index: 9998/9999` — 自定义光标（fixed，pointer-events: none）

---

### 2.1 Hero Section

**布局**：纵向居中排列，`flex-direction: column; align-items: center`

**子元素（由上至下）**：

1. **`.hero-label`** — 标签文字，初始 `opacity: 0; transform: translateY(20px)`，由 GSAP 驱动入场
2. **`h1.hero-title`** — 主标题，两行结构，每行用 `.line > .inner` 包裹，用于 clip 动画
3. **`p.hero-subtitle`** — 副标题，初始隐藏，入场动画
4. **`.hero-actions`** — 两个按钮，初始隐藏，入场动画
5. **`.ascii-hero-visual`** — 交互式可视区（GIF + ASCII Canvas 叠层）

**滚动指示器**：`.scroll-indicator`，右下角固定，内含动态扫线动画（`scroll-line-anim`，2s 无限循环），初始 `opacity: 0`

---

### 2.2 Workspace Preview Section

**布局**：纵向居中，内容居中对齐

**子元素**：

1. **`.workspace-header`** — 标签 + 标题 + 副标题，初始 `opacity: 0; transform: translateY(30px)`
2. **`.workspace-frame`** — 模拟 macOS 应用窗口，内含完整 Chat UI，初始 `opacity: 0; transform: translateY(30px)`

**工作区窗口（`.workspace-frame`）结构**：
- **`.workspace-toolbar`** — 顶部工具栏，含三色窗口按钮（红 `#ff5f57` / 黄 `#ffbd2e` / 绿 `#28c840`）+ 标题文字 `"COCO Workspace"`
- **`.workspace-body`** — 高度 480px（移动端 400px），横向分栏
  - **`.ws-sidebar`** — 宽 220px，频道列表（见 2.2.1）
  - **`.ws-chat`** — 弹性占满，消息区 + 输入区

---

#### 2.2.1 侧边栏频道列表（完整数据）

**Channels 分组**：

| 频道名 | 图标 | 状态 | 未读角标 |
|--------|------|------|---------|
| General | `#` | active（高亮） | `3` |
| Engineering | `#` | 默认 | — |
| Design | `#` | 默认 | — |
| Bot Arena | `#` | 默认 | `7` |

**Direct 分组**：

| 名称 | 图标 |
|------|------|
| COCO Agent | `@`（font-size: 12px） |

---

#### 2.2.2 Chat 消息数据（完整剧本）

消息由 JavaScript 动态注入，模拟真实对话：

| 序号 | 发送者 | 头像 | 颜色 | 时间 | 消息内容 | 类型 |
|------|--------|------|------|------|---------|------|
| 1 | Stephanie | `S` | `linear-gradient(135deg,#f093fb,#f5576c)` | 9:00 AM | "Good morning! Can we review the Q3 roadmap today?" | 人类 |
| 2 | COCO Agent | 🐙 | `linear-gradient(135deg,#d357fe,#96bbff)` | 9:01 AM | "Sure! I've pulled up the latest roadmap. 3 high-priority items need attention. Want me to summarize?" | AI |
| 3 | Stephanie | `S` | `linear-gradient(135deg,#f093fb,#f5576c)` | 9:02 AM | "Yes please, focus on the ones due this sprint." | 人类 |
| 4 | COCO Agent | 🐙 | `linear-gradient(135deg,#d357fe,#96bbff)` | 9:03 AM | "Sprint items:\n1. Payment integration — 80% done, needs testing\n2. Dashboard redesign — wireframes approved\n3. API v2 migration — blocked on auth review" | AI |
| 5 | Athan | `A` | `linear-gradient(135deg,#43e97b,#38f9d7)` | 9:05 AM | "Auth review is done, I'll push the approval now." | 人类 |
| 6 | COCO Agent | 🐙 | `linear-gradient(135deg,#d357fe,#96bbff)` | 9:06 AM | "Great! Unblocking API v2 migration now. Updated the task board — all 3 items are green." | AI |

**消息气泡样式差异**：
- 人类消息：`background: rgba(0,0,0,0.02); border: 1px solid var(--border)`
- AI 消息（`.ws-msg.agent .ws-msg-text`）：`background: linear-gradient(135deg, rgba(211,87,254,0.04), rgba(150,187,255,0.04)); border-color: rgba(211,87,254,0.1)`

**AI 标签（`.ai-tag`）**：`background: linear-gradient(135deg, var(--accent), #96bbff)`，白色文字，`font-size: 9px`，`padding: 1px 5px`

---

### 2.3 Core Features Section

**布局**：`justify-content: flex-end`（内容面板靠右），左侧放动画 Canvas

**左侧**（`.features-visual`）：
- 网络图谱 Canvas 动画，宽度 42%（最大 520px），高度 75vh
- 初始 `opacity: 0`，随滚动入场

**右侧**（`.features-panel`）：
- 初始 `opacity: 0; transform: translateX(40px)`
- 最大宽度 480px

**功能列表（完整数据）**：

| 序号 | 图标字符 | 标题 | 描述 |
|------|---------|------|------|
| 1 | `⬡` | Neural Code Engine | AI understands your entire codebase context, not just the current file. |
| 2 | `◈` | Document Intelligence | Generate, summarize, and transform documents with a single prompt. |
| 3 | `◎` | Real-time Collaboration | AI mediates team communication and resolves conflicts intelligently. |
| 4 | `⬗` | Adaptive Interface | The workspace morphs to your current task — coding, writing, or presenting. |

**Feature 卡片样式**：
- `background: rgba(255,255,255,0.7); backdrop-filter: blur(12px); border-radius: 8px`
- 悬停：`border-color: rgba(211,87,254,0.25); box-shadow: 0 4px 24px rgba(211,87,254,0.06)`

---

### 2.4 AI Modes Section

**布局**：`flex-direction: column; align-items: center; text-align: center`

**模式卡片网格**（`.modes-grid`）：
- `grid-template-columns: repeat(3, 1fr); gap: 2px; max-width: 900px`
- 移动端：`grid-template-columns: 1fr`（单列）

**三种 AI 模式（完整数据）**：

**Mode 01 — Code Mode**
- 编号：`01`
- 标题：`Code Mode`
- 描述：`Full IDE power with AI co-pilot. Autocomplete, refactor, explain — all native.`
- 图标：SVG 内联，终端矩形 + 折角箭头（polyline 颜色 `#d357fe`）+ 水平线

**Mode 02 — Office Mode**
- 编号：`02`
- 标题：`Office Mode`
- 描述：`Smart documents, spreadsheets, and presentations with AI-native editing.`
- 图标：SVG 内联，文档矩形 + 三条水平线（首行颜色 `#d357fe`）

**Mode 03 — Focus Mode**
- 编号：`03`
- 标题：`Focus Mode`
- 描述：`Distraction-free deep work with AI that only speaks when spoken to.`
- 图标：SVG 内联，同心圆（内圆颜色 `#d357fe`）+ 四方向刻度线

**模式卡片共有样式**：
- `padding: 40px 32px; background: rgba(255,255,255,0.6); backdrop-filter: blur(16px); border-radius: 8px`
- `::before` 伪元素：顶部高亮线，`height: 2px; background: linear-gradient(90deg, transparent, var(--accent), transparent); transform: scaleX(0)`，悬停时 `scaleX(1)`
- 悬停：`background: rgba(255,255,255,0.85); border-color: rgba(211,87,254,0.2); box-shadow: 0 8px 32px rgba(211,87,254,0.06)`

---

### 2.5 CTA Section

**布局**：居中，纵向排列

**子元素**（均在 `.cta-inner` 内，初始 `opacity: 0; transform: translateY(40px)`）：

1. **`.cta-pre`** — 引导文字
2. **`h2.cta-title`** — 主标题，含空心文字装饰
3. **`p.section-desc`** — 补充说明
4. **`.cta-actions`** — 两个行动按钮

---

## 3. 导航栏

**样式**：`position: fixed; top: 0; z-index: 100; padding: 28px 48px`（移动端 `20px 24px`）

### Logo

- HTML：`<img src="coco-logo.png" alt="COCO" class="nav-logo-img">`
- 图片高度：28px，`filter: brightness(0.15) saturate(2)`（深色处理）
- 字体回退（若图片缺失）：`font-family: var(--font-mono); font-size: 13px; letter-spacing: 0.12em`，accent 色方括号装饰

### 导航链接（`.nav-links`）

| 链接文字 | 目标锚点 / URL | 特殊样式 |
|---------|--------------|---------|
| Home | `#hero` | 默认 |
| Features | `#features` | 默认 |
| Modes | `#modes` | 默认 |
| Contact | `#cta` | 默认 |
| Workspace | `coco-workspace.html` | `.nav-workspace-link`：accent 色边框，`padding: 6px 14px; border-radius: 6px`，悬停背景 `rgba(211,87,254,0.08)` |

**移动端**：`display: none`（768px 以下导航链接完全隐藏）

**链接样式**：`font-family: var(--font-mono); font-size: 11px; letter-spacing: 0.14em; text-transform: uppercase; color: var(--muted)`，悬停变 `var(--text)`

### CTA 按钮（`.nav-cta`）

- 文字：`Get Early Access`
- 目标：`#cta`
- 样式：`background: #000000; color: #ffffff; border: 1px solid #000000; padding: 10px 22px; font-family: var(--font-mono); font-size: 11px; letter-spacing: 0.12em; text-transform: uppercase`
- 悬停：`background: var(--accent); border-color: var(--accent)`

---

## 4. 文案内容

### Hero Section

| 元素 | 文案 |
|------|------|
| 标签（`.hero-label`） | `— Introducing v2.0` |
| 主标题行 1 | `COCO` |
| 主标题行 2（渐变色） | `Workspace` |
| 副标题 | `Your AI-powered workspace for everyday work. Chat, collaborate, and get things done — effortlessly.` |
| 主按钮 | `Explore Workspace` |
| 次按钮 | `See Features` |

### Workspace Section

| 元素 | 文案 |
|------|------|
| 区块标签 | `Workspace` |
| 标题 | `Your AI-native command center` |
| 副标题 | `Chat with your team and AI agents in one unified workspace. Everything connected, nothing missed.` |
| 窗口标题栏 | `COCO Workspace` |
| 输入框占位符 | `Message #general...` |
| AI 打字提示 | `COCO Agent is typing...` |

### Core Features Section

| 元素 | 文案 |
|------|------|
| 区块标签 | `Core Features` |
| 标题 | `Everything you need in one place` |
| 副标题 | `COCO Workspace integrates AI deeply into every workflow — from intelligent code completion to smart document generation.` |

### AI Modes Section

| 元素 | 文案 |
|------|------|
| 区块标签 | `AI Modes` |
| 标题 | `One AI, infinite forms` |
| 副标题 | `Switch between modes instantly. The interface adapts, the AI evolves.` |

### CTA Section

| 元素 | 文案 |
|------|------|
| 引导标签（`.cta-pre`） | `— Join the waitlist` |
| 主标题 | `Let's build the future together`（"together" 为空心描边字） |
| 补充说明 | `Early access opens to selected teams this quarter. Be first to reshape how your team works.` |
| 主按钮 | `Request Early Access` |
| 次按钮 | `Learn More` |

### Footer

| 元素 | 内容 |
|------|------|
| Logo | `<img src="coco-logo.png"> Workspace` |
| 版权声明 | `© 2026 COCO AI. All rights reserved.` |

---

## 5. 视觉规范

### CSS 变量（`:root` 完整定义）

```css
:root {
  --bg:        #f7faff;          /* 页面底色：极淡蓝白 */
  --surface:   #ffffff;          /* 卡片/面板表面色 */
  --border:    rgba(0,0,0,0.08); /* 边框色：半透明黑 */
  --text:      #000000;          /* 主文字色 */
  --text-sec:  #343639;          /* 次级文字色：深灰 */
  --muted:     #b6b6b6;          /* 弱化文字：中灰 */
  --accent:    #d357fe;          /* 强调色：品牌紫 */
  --accent2:   #96bbff;          /* 辅助强调色：柔蓝 */
  --font-mono: 'IBM Plex Mono', 'JetBrains Mono', 'Fira Mono', 'Courier New', monospace;
  --font-sans: 'Inter', system-ui, -apple-system, sans-serif;
}
```

### 主色调

| 名称 | 色值 | 用途 |
|------|------|------|
| 品牌紫（Primary Accent） | `#d357fe` | 按钮、高亮、标签、边框强调、AI 相关元素 |
| 柔蓝（Secondary Accent） | `#96bbff` | 渐变搭档、灯光效果、辅助高亮 |
| 纯白 | `#ffffff` | 卡片表面、按钮文字 |
| 纯黑 | `#000000` | 主文字、主 CTA 按钮背景 |
| 背景蓝白 | `#f7faff` | 页面底色 |

### 字体规范

| 用途 | 字体族 | 规格 |
|------|--------|------|
| 等宽（Logo、导航、按钮、标签） | IBM Plex Mono | 300 / 400 / 500 |
| 无衬线（正文、描述、消息） | Inter | 300 / 400 / 500 / 600 / 700 |

### 字号体系

| 元素 | 字号 | 字重 | 其他 |
|------|------|------|------|
| Hero 主标题 | `clamp(52px, 7vw, 96px)` | 700 | `letter-spacing: -0.035em` |
| Section 标题 | `clamp(32px, 4vw, 52px)` | 600 | `letter-spacing: -0.02em` |
| CTA 标题 | `clamp(48px, 7vw, 100px)` | 600 | `letter-spacing: -0.03em` |
| Hero 副标题 | `17px` | 400 | `line-height: 1.65` |
| Section 副标题 | `15px` | 400 | `line-height: 1.7` |
| 导航链接 | `11px` | 400 | `letter-spacing: 0.14em; text-transform: uppercase` |
| Section 标签 | `10px` | 400 | `letter-spacing: 0.25em; text-transform: uppercase` |
| 功能卡片标题 | `14px` | 500 | — |
| 功能卡片描述 | `13px` | 400 | — |
| 消息文字 | `14px` | 400 | `line-height: 1.6` |

### 渐变色规范

| 用途 | 渐变值 |
|------|--------|
| Hero 主标题 accent 词 | `linear-gradient(135deg, #d357fe 0%, #96bbff 100%)` |
| AI 消息标签（`.ai-tag`） | `linear-gradient(135deg, #d357fe, #96bbff)` |
| Mode 卡片顶部高亮线 | `linear-gradient(90deg, transparent, #d357fe, transparent)` |
| 底部淡出（ASCII 视觉区） | `linear-gradient(180deg, rgba(255,255,255,0) 50%, rgba(247,250,255,0.4) 100%)` |

### 阴影规范

| 元素 | 阴影值 |
|------|--------|
| ASCII 视觉区 | `0 8px 40px rgba(211,87,254,0.08), 0 2px 12px rgba(0,0,0,0.04)` |
| 工作区窗口 | `0 1px 3px rgba(0,0,0,0.04), 0 8px 40px rgba(0,0,0,0.06)` |
| 功能卡片悬停 | `0 4px 24px rgba(211,87,254,0.06)` |
| Mode 卡片悬停 | `0 8px 32px rgba(211,87,254,0.06)` |

### CTA 标题空心字效果

```css
.cta-title em {
  font-style: normal;
  color: transparent;
  -webkit-text-stroke: 1.5px rgba(0,0,0,0.2);
}
```

---

## 6. 交互与动效

### 6.1 自定义光标

系统光标隐藏（`cursor: none`），由两个 fixed div 替代：

**主光标（`#cursor`）**：
- 尺寸：`12px × 12px`，圆形，`background: #000000`
- `mix-blend-mode: difference`（叠加模式，经过深色元素时反白）
- 过渡：`transform 0.08s, width/height 0.2s, background 0.2s`

**光标环（`#cursor-ring`）**：
- 尺寸：`40px × 40px`，圆形边框，`border: 1px solid rgba(211,87,254,0.5)`
- 过渡：`transform 0.18s, width/height 0.25s, border-color 0.2s`
- 跟随鼠标坐标（通过 JS 实时更新 `left/top`）

**状态变化**：

| 状态 | 触发条件 | 主光标 | 环 |
|------|---------|--------|-----|
| 默认 | — | 12px，黑色 | 40px，紫色半透明 |
| `cursor-hover` | `a, button` 的 mouseenter/mouseleave | 8px，`var(--accent)` | 60px，`rgba(211,87,254,0.6)` |
| `cursor-ascii` | ASCII Canvas 的 mouseenter/mouseleave | 6px，`var(--accent)` | 80px，`rgba(211,87,254,0.25); border-width: 1.5px` |

### 6.2 加载屏（`#loading`）

- 背景：纯白 `#ffffff`
- COCO Logo 图片（`loading-logo-img`，高度 60px）
- 进度条：200px 宽，2px 高，品牌紫填充，`transition: width 0.1s linear`
- 百分比文字：等宽字体
- 加载完成后：`gsap.to('#loading', { opacity: 0, duration: 0.8, ease: 'power2.inOut' })`，淡出后 `display: none`

### 6.3 Three.js 背景场景

WebGL Canvas（`#webgl`）固定铺满全屏，`z-index: 0`，`pointer-events: none`。

**渲染器配置**：
- `antialias: true; alpha: false`
- `powerPreference: 'high-performance'`
- `pixelRatio: Math.min(devicePixelRatio, 2)`
- `toneMapping: ACESFilmicToneMapping; toneMappingExposure: 1.6`
- 阴影：`PCFSoftShadowMap`

**相机**：`PerspectiveCamera(45°, aspect, 0.1, 100)`，初始位置 `(0, 0, 6)`

**环境贴图**：程序生成 256×128 渐变纹理（白色顶部 → 柔蓝底部），通过 PMREMGenerator 生成

**场景背景色**：`0xf7faff`（与页面 `--bg` 一致）

**灯光体系**：

| 灯光 | 类型 | 颜色 | 强度 | 位置 |
|------|------|------|------|------|
| Key Light（主光） | DirectionalLight | `0xffe8c0`（暖白） | 2.5（脉冲浮动） | `(4, 5, 4)` |
| Fill Light（补光） | DirectionalLight | `0x96bbff`（冷蓝） | 1.8（脉冲浮动） | `(-4, -2, 2)` |
| Accent 1（鼠标跟随） | PointLight | `0xd357fe`（品牌紫） | 8（随滚动强化） | 随鼠标位移 |
| Accent 2（鼠标跟随） | PointLight | `0x96bbff`（冷蓝） | 6（随滚动强化） | 随鼠标位移（反向） |
| Ambient | AmbientLight | `0xffffff` | 0.6 | — |

脉冲公式：`pulse = 1.0 + Math.sin(elapsed * 1.8) * 0.12`

**后处理**：EffectComposer → RenderPass → UnrealBloomPass（strength: 0.65, radius: 0.5, threshold: 0.75）→ OutputPass

---

#### 6.3.1 玻璃球（Glass Sphere）

- 几何体：`SphereGeometry(1.15, 128, 128)`
- 材质：`MeshPhysicalMaterial`
  - `transmission: 1.0`（全透明玻璃）
  - `ior: 1.52`，`thickness: 0.6`
  - `clearcoat: 1.0; clearcoatRoughness: 0.02`
  - `attenuationColor: 0xd0c0ff; attenuationDistance: 2.5`
  - `iridescence: 0.8; iridescenceIOR: 1.4; iridescenceThicknessRange: [100, 500]`
  - `dispersion: 0.03`
- 内层光晕球：`SphereGeometry(0.9, 64, 64)`，淡薰衣草色 `0xd8d0f0`，`opacity: 0.5; side: BackSide`
- 浮动动画：`floatY = Math.sin(elapsed * 0.55) * 0.08`
- 鼠标响应：旋转 easing（X 轴 0.03，Y 轴 0.03）；位移 easing 0.06
- 入场动画：`gsap.from(scale, { x:0, y:0, z:0, duration: 1.8, ease: 'elastic.out(1, 0.5)', delay: 0.4 })`

#### 6.3.2 金属碎片（Metallic Fragments）

- 数量：18 个
- 几何体类型：IcosahedronGeometry / OctahedronGeometry / TetrahedronGeometry（每 3 个循环）
- 尺寸：随机，约 0.16–0.28
- 材质：`MeshPhysicalMaterial`，`metalness: 0.85; roughness: 0.08; clearcoat: 1.0`，颜色 HSL 随机（H≈0.78，紫色系）
- 轨道参数：`orbitRadius: 1.6–2.4`，`orbitSpeed: ±0.12–0.30`，倾斜角随机
- 随滚动扩散：`r = orbitRadius * (1.0 + fragmentSpread * 0.6)`

#### 6.3.3 粒子场（Particle Field）

- 粒子数：1200
- 分布：x `(-8, 8)`，y `(-6, 6)`，z `(-6, -2)`
- 材质：`PointsMaterial`，颜色 `0xc0a0e8`（柔紫），`opacity: 0.45`，`size: 0.028`，`NormalBlending`
- 旋转：`y 轴 0.012 rad/s`，`x 轴 0.006 rad/s`
- 透明度脉冲：`0.4 + Math.sin(elapsed * 0.3) * 0.08`

### 6.4 GSAP ScrollTrigger 动画

**注册**：`gsap.registerPlugin(ScrollTrigger)`

**场景状态联动**（滚动驱动，`scrub: 1.5`）：

| 触发区间 | 效果 |
|---------|------|
| `#features` 进入视口 → 顶部 | 球体 X 从 `0 → -2.2`，Y 从 `0 → -0.3`，缩放 `1.0 → 0.75`，碎片扩散 `0 → 1.0` |
| `#modes` 进入视口 → 顶部 | 球体归位 X `→ 0`，Y `→ 0`，缩放 `→ 0.9` |
| `#cta` 进入视口 → 顶部 | 灯光强度 `1.0 → 2.5`，缩放 `0.9 → 0.85`，Y `0 → 0.2` |

**页面元素入场动画**（`once: true`，触发后不再重置）：

| 元素 | 触发点 | 动画参数 |
|------|--------|---------|
| `.hero-label` | `#hero top 80%` | `opacity: 1, y: 0, duration: 0.7, ease: power3.out, delay: 0.2` |
| `.hero-title .inner`（stagger） | `#hero top 80%` | `opacity: 1, y: 0, duration: 0.9, ease: power3.out, stagger: 0.1, delay: 0.4` |
| `.hero-subtitle` | `#hero top 80%` | `opacity: 1, y: 0, duration: 0.7, ease: power3.out, delay: 0.8` |
| `.hero-actions` | `#hero top 80%` | `opacity: 1, y: 0, duration: 0.7, ease: power3.out, delay: 1.0` |
| `.workspace-header` | `#workspace top 75%` | `opacity: 1, y: 0, duration: 0.8, ease: power3.out` |
| `.workspace-frame` | `#workspace top 70%` | `opacity: 1, y: 0, duration: 1.0, delay: 0.2, ease: power3.out`；同时触发聊天动画 |
| `.features-visual` | `#features top 80%` | `opacity: 1, duration: 1.2, ease: power2.out` |
| `.features-panel` | `#features top 70%` | `opacity: 1, x: 0, duration: 1.0, ease: power3.out` |
| `.modes-header` | `#modes top 70%` | `opacity: 1, y: 0, duration: 0.8, ease: power3.out` |
| `.modes-grid` | `#modes top 70%` | `opacity: 1, y: 0, duration: 0.8, delay: 0.2, ease: power3.out` |
| `.cta-inner` | `#cta top 70%` | `opacity: 1, y: 0, duration: 1.0, ease: power3.out` |

### 6.5 ASCII Canvas 交互

位于 Hero 区域，叠加在 GIF 图片之上（`z-index: 3`）。

**字符集**：`'01{}()<>/\\*#@.+=-|_~:;[]!?%&ABCDEF01{}'`

**渲染参数**：
- 字号：`16px IBM Plex Mono`
- 字符间距：`gap = 18px`
- 刷新节流：每 25ms 渲染一帧

**环境动效**：每个字符独立飘动（`driftAmp: 1.5–3.5px`，波形运动），随机偶发字符替换（概率 `0.001`）

**鼠标交互**：
- 影响半径：`RADIUS = 140px`
- 推开强度：`DODGE_STRENGTH = 35px`
- 推开算法：proximity² 计算强度，以鼠标为圆心将字符沿反向推开
- 光标进入区域时：显示 `cursor-ascii` 状态（80px 环，弱紫色）
- 强推开时字符替换概率：`0.05`（intensity > 0.3）

**字符颜色**：始终为深紫色 `rgba(185, 60–100, 230, alpha)`；推开距离越大，颜色越亮，透明度叠加 `+0.35`

### 6.6 聊天 Demo 打字效果

由 `window.startWorkspaceChat()` 函数驱动，在 `.workspace-frame` 进入视口时调用（`onEnter` 回调）。

**流程**：
- 消息逐条显示，每条间隔 `1000–1600ms` 随机
- AI 消息前显示打字指示器（`.ws-typing`），持续 `900–1500ms`
- 每条消息通过 `requestAnimationFrame` 触发 `visible` class，实现 `opacity + translateY` 入场（`0.4s ease`）
- 自动滚动到最新消息：`container.scrollTop = container.scrollHeight`

**打字指示器动画**：三个圆点 `.ws-typing-dot`，`animation: wsDotBounce 1.2s infinite`；延迟 `0/0.15/0.3s`

### 6.7 Features 网络图谱动画

Canvas `#features-canvas` 在 `.features-visual` 内。

**参数**：
- 节点数：35（其中 5 个为 Hub 节点）
- 连接阈值：130px
- Hub 节点：半径 4–6px，颜色 `rgba(211,87,254,0.7)`，带径向光晕
- 普通节点：半径 1.5–3.5px，颜色 `rgba(150,187,255,0.45)`
- 连线：Hub 连线颜色 `rgba(211,87,254)`；普通连线 `rgba(150,187,255)`
- 流动粒子：初始 12 个，持续补充，沿节点间连线移动，`rgba(211,87,254, sin透明度)`

### 6.8 滚动提示线动画（`.scroll-line::after`）

```css
animation: scroll-line-anim 2s ease-in-out infinite;
/* 0%: left -100% → 50%: left 0% → 100%: left 100% */
```

---

## 7. 响应式设计

**当前状态：部分适配**。仅有基础断点处理，无完整移动端设计。

**断点**：`max-width: 768px`

| 调整项 | 变化 |
|--------|------|
| 导航栏内边距 | `28px 48px → 20px 24px` |
| 导航链接 | `display: none`（完全隐藏） |
| Section 内边距 | `120px 48px → 100px 24px 60px` |
| Hero 主标题字号 | 保留 `48px`（clamp 下限） |
| ASCII 视觉区高度 | `420px → 280px` |
| Features：左侧视觉 | `display: none`（隐藏网络图） |
| Features：内容面板 | `transform: translateX(0)`（还原左移） |
| Modes 网格 | `repeat(3,1fr) → 1fr`（单列堆叠） |
| Workspace 侧边栏 | `display: none` |
| Workspace 消息区高度 | `480px → 400px` |
| Footer | `flex-direction: column; gap: 16px; text-align: center` |

**已知缺口**：
- 无平板（768–1024px）专用适配
- 移动端导航无汉堡菜单替代
- Hero actions 在极窄屏幕可能换行溢出

---

## 8. 外部依赖

| 库 | 版本 | 加载方式 | 用途 |
|----|------|---------|------|
| Three.js | `0.164.1` | ESM Import Map（jsDelivr CDN） | 3D 背景场景、粒子、玻璃球 |
| Three.js Addons | `0.164.1` | ESM Import（jsDelivr CDN） | EffectComposer, RenderPass, UnrealBloomPass, OutputPass |
| GSAP | `3.12.5` | `<script src>` UMD（jsDelivr CDN） | 入场动画、滚动驱动时间轴 |
| GSAP ScrollTrigger | `3.12.5` | `<script src>` UMD（jsDelivr CDN） | 滚动联动场景状态 |
| IBM Plex Mono | 300/400/500 | Google Fonts CDN | 等宽字体 |
| Inter | 300/400/500/600/700 | Google Fonts CDN | 无衬线正文字体 |

**Import Map 配置**（需浏览器原生支持）：
```json
{
  "imports": {
    "three": "https://cdn.jsdelivr.net/npm/three@0.164.1/build/three.module.js",
    "three/addons/": "https://cdn.jsdelivr.net/npm/three@0.164.1/examples/jsm/"
  }
}
```

**CDN URL**：
- GSAP: `https://cdn.jsdelivr.net/npm/gsap@3.12.5/dist/gsap.min.js`
- ScrollTrigger: `https://cdn.jsdelivr.net/npm/gsap@3.12.5/dist/ScrollTrigger.min.js`

**字体加载**：
```
https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@300;400;500&family=Inter:wght@300;400;500;600;700&display=swap
```

---

## 9. 待优化项与已知问题

### 功能缺口

| 类别 | 问题描述 |
|------|---------|
| **图片资源** | `coco-logo.png` 和 `nano-design-export.gif` 为本地引用，未内联，生产环境需确保路径正确或改用 CDN |
| **Aurora Canvas** | 代码中保留了 Aurora 光晕动画（约 80 行），但已被注释为 placeholder，未删除（用 `return;` 短路执行） |
| **Organic Mesh** | 代码中实现了完整的有机变形球体（GLSL shader），但 `organicMesh.visible = false` 硬编码隐藏 |
| **CTA 按钮功能** | "Request Early Access" 链接至 `mailto:hello@coco.ai`；"Learn More" 链接至 `#`（空锚点，无实际内容） |
| **Workspace 链接** | `coco-workspace.html` 为相对路径引用，需确保文件存在 |
| **输入框交互** | Chat 输入框设置为 `readonly`，发送按钮无实际功能，仅作展示 |

### 视觉/性能问题

| 类别 | 问题描述 |
|------|---------|
| **移动端导航** | 768px 以下隐藏导航链接后无替代菜单入口，仅保留 Logo 和 CTA 按钮 |
| **WebGL 性能** | 1200 粒子 + 18 金属碎片 + 后处理 Bloom，在低端设备可能有掉帧风险；`requestAnimationFrame` 未做帧率节流 |
| **ASCII 性能** | ASCII Canvas 无帧率节流（仅有 `time - lastTime < 25` 节流），高分辨率屏幕字符数量可达数千个 |
| **字体闪烁** | Google Fonts 异步加载，首屏可能出现字体替换闪烁（FOUT），无 font-display 策略 |
| **Scroll Indicator** | `.scroll-indicator` 初始 `opacity: 0`，但代码中未找到令其可见的 GSAP 动画 |
| **SEO** | 无 meta description、OG 标签、结构化数据 |
| **无障碍** | 自定义光标隐藏系统光标，对无法使用鼠标的用户不友好；无 ARIA 属性 |

### 设计待决策

| 类别 | 说明 |
|------|------|
| **有机变形球** | 已实现但关闭，是否在某个 Section 或交互状态下启用？ |
| **Aurora 光晕** | 已实现代码被废弃，是否彻底删除？ |
| **Workspace Section 功能性** | 侧边栏频道切换目前无 JS 逻辑（仅 CSS active 状态），是否需要实现切换动效？ |
| **Early Access 流程** | 当前仅跳转邮件，是否需要落地页表单？ |
