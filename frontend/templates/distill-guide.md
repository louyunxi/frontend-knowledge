# 蒸馏辅助系统

## 目的

确保蒸馏的知识能够：
1. ✅ 放到正确的目录
2. ✅ 容易被关键词匹配到
3. ✅ 有准确的语义标签
4. ✅ 自动同步到索引

---

## 页面布局模式分支

当 `--type page-layout` 时，不使用下方以代码技术为中心的通用流程，改为执行 `commands/distill.md` 中的 page-layout 专用流程，并使用 `templates/page-layout-template.md`。

```text
page-layout
├── 强制 --domain 布局
├── 强制 --platform web | mobile | responsive
├── 从页面任务、区域、模块关系和状态协作提取模式
├── 区分同任务响应式变化与独立移动任务流
├── 保存到 knowledge/布局/页面模式/
└── 验证 `/frontend` 的需求描述分支与页面路径分支都可召回
```

Grid、Flex、Sticky、媒体查询等只作为实现线索。页面布局模式必须以用户任务和模块组合命名，并保留来源证据、泛化边界与置信度。

---

## 智能分析流程

```
蒸馏请求
    ↓
┌────────────────────────────┐
│ Step 1: 内容分析           │
│ - 分析代码或描述           │
│ - 提取技术栈              │
│ - 识别核心功能            │
└────────────┬───────────────┘
             ↓
┌────────────────────────────┐
│ Step 2: 目录推荐           │
│ - 推荐最佳保存目录         │
│ - 列出备选目录            │
│ - 解释推荐理由            │
└────────────┬───────────────┘
             ↓
┌────────────────────────────┐
│ Step 3: 关键词提取         │
│ - 提取精确关键词          │
│ - 生成同义词              │
│ - 生成语义变体            │
└────────────┬───────────────┘
             ↓
┌────────────────────────────┐
│ Step 4: 标签推荐           │
│ - 推荐技术栈标签           │
│ - 推荐功能标签            │
│ - 推荐场景标签            │
└────────────┬───────────────┘
             ↓
┌────────────────────────────┐
│ Step 5: 匹配测试           │
│ - 用提取的关键词测试匹配   │
│ - 验证是否能被搜到        │
│ - 优化关键词              │
└────────────────────────────┘
```

---

## Step 1: 内容分析

### 分析代码特征

```
代码特征 → 推荐域
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
包含 gsap/framer-motion/animation     → 动效
使用 transform/opacity transition     → 动效
包含 IntersectionObserver/Scroll     → 动效
使用 Grid/Flexbox/display            → 布局
包含 @media responsive              → 布局
使用 position: sticky/fixed          → 布局
包含 list/virtual/pagination         → 功能
使用 form/validation/rules           → 功能
包含 drag/sortable/dnd              → 功能
涉及 color/theme/dark/light          → 设计主题
使用 CSS variable/var()              → 设计主题
涉及 redux/zustand/context          → 功能
涉及 axios/fetch/data fetch         → 功能
包含 naming/path/structure          → 项目规范
涉及 git/commit/branch              → 项目规范
对比 state lib/routing lib          → 技术选型
```

### 识别核心功能

```javascript
分析步骤：
1. 扫描代码中的关键库（import）
2. 识别核心实现逻辑
3. 确定使用场景
4. 评估复杂度
```

---

## Step 2: 目录推荐

### 六大目录及子目录

```
knowledge/
│
├── 动效/
│   ├── 页面过渡/           ← 路由切换、页面切换
│   ├── 滚动动画/          ← 滚动触发、视差
│   ├── 入场动画/          ← 列表入场、淡入
│   ├── 加载动画/          ← 骨架屏、spinner
│   └── 交互反馈/          ← hover、点击、focus
│
├── 布局/
│   ├── 响应式/            ← 媒体查询、适配
│   ├── 栅格/              ← Grid、Flexbox
│   ├── 定位/              ← sticky、fixed、absolute
│   ├── 特殊/              ← 瀑布流、圣杯
│   └── 对齐/              ← 居中、两端对齐
│
├── 功能/
│   ├── 列表/              ← 虚拟列表、分页、无限滚动
│   ├── 表单/              ← 验证、联动
│   ├── 拖拽/              ← 排序、拖放
│   ├── 状态/              ← 主题切换、全局状态
│   └── 交互/              ← 筛选、搜索
│
├── 项目规范/
│   ├── 命名/              ← 组件命名、文件命名
│   ├── 结构/              ← 目录结构
│   ├── Git/               ← 提交规范、分支策略
│   └── 代码/              ← ESLint、Prettier
│
├── 设计主题/
│   ├── 色彩/              ← 配色、变量
│   ├── 字体/              ← 字号、字重
│   ├── 间距/              ← 间距系统
│   └── 主题/              ← 暗色模式、主题切换
│
└── 技术选型/
    ├── 状态管理/          ← Redux、Zustand
    ├── 数据请求/          ← Axios、Fetch
    ├── 动画库/            ← GSAP、Framer
    └── UI组件/            ← 组件库对比
```

### 目录推荐示例

```
输入: "提取一个GSAP页面过渡组件"

AI 分析:
✅ 识别技术栈: GSAP
✅ 识别功能: 页面过渡/路由切换
✅ 推荐目录: 动效/页面过渡/
✅ 备选目录: 动效/交互反馈/
✅ 推荐理由: 核心功能是路由切换时的动画效果

输出:
保存路径: knowledge/动效/页面过渡/gsap页面过渡.md
```

---

## Step 3: 关键词提取

### 关键词层级

```
Layer 1: 精确关键词（100% 匹配）
├── 直接使用文件名/功能名
└── 示例: "gsap页面过渡", "虚拟列表"

Layer 2: 同义词（90% 匹配）
├── 技术栈别名
├── 功能别名
└── 示例: "页面切换" = "页面过渡"

Layer 3: 语义变体（80% 匹配）
├── 用户口语化表达
├── 场景描述
└── 示例: "换页" = "页面过渡"
```

### 关键词提取规则

```javascript
提取规则:

1. 从文件名提取
   "gsap-page-transition" → ["gsap", "页面过渡", "transition"]

2. 从代码提取
   import { gsap } from 'gsap' → ["gsap"]
   const virtualList = useVirtualizer() → ["虚拟列表", "virtual"]

3. 从描述提取
   "页面切换动画" → ["页面切换", "动画", "过渡"]

4. 生成同义词
   "页面过渡" → ["页面切换", "路由切换", "转场"]
   "虚拟列表" → ["virtual list", "大数据列表"]

5. 生成语义变体
   "页面过渡" → ["换页", "跳转动画", "SPA切换"]
   "骨架屏" → ["加载占位", "loading效果", "等待"]
```

### 关键词表结构

```markdown
| 关键词 | 同义词 | 语义变体 | 所属域 |
|--------|--------|---------|--------|
| gsap | greensock | "gsap动画" | 动效 |
| 页面过渡 | 页面切换, 转场 | "换页", "跳转" | 动效 |
| 虚拟列表 | virtual list | "大数据列表", "长列表" | 功能 |
```

---

## Step 4: 语义标签推荐

### 标签分类

```
技术栈标签:
├── react, vue, typescript, javascript
├── gsap, framer-motion, anime
├── tailwind, styled-components
└── dnd-kit, react-beautiful-dnd

功能标签:
├── animation, transition, motion
├── layout, responsive, grid, flex
├── list, virtual, pagination
├── form, validation, input
├── drag, drop, sortable
└── theme, dark, light

场景标签:
├── mobile, desktop
├── performance, optimization
├── a11y, accessibility
├── ssr, hydrate
└── animation, interaction
```

### 标签推荐算法

```javascript
推荐步骤:

1. 从代码扫描依赖
   import { gsap } from 'gsap' → ["gsap", "animation"]

2. 从功能识别场景
   使用虚拟列表 → ["list", "virtual", "performance"]

3. 从使用场景推断
   页面过渡 → ["page", "transition", "routing"]

4. 合并去重
   最终标签: ["gsap", "animation", "page", "transition", "react"]
```

---

## Step 5: 匹配测试

### 测试流程

```javascript
蒸馏后自动测试:

1. 使用提取的关键词搜索
   search("页面过渡") → 应找到 gsap页面过渡

2. 使用同义词搜索
   search("页面切换") → 应找到 gsap页面过渡

3. 使用语义变体搜索
   search("换页动画") → 应找到 gsap页面过渡

4. 使用场景搜索
   search("路由切换带动画") → 应找到 gsap页面过渡
```

### 测试报告

```markdown
## 匹配测试报告

### 测试结果

| 搜索词 | 匹配结果 | 匹配度 |
|--------|---------|--------|
| 页面过渡 | ✅ gsap页面过渡 | 100% |
| 页面切换 | ✅ gsap页面过渡 | 90% |
| 换页动画 | ✅ gsap页面过渡 | 80% |
| 路由切换 | ⚠️ 部分匹配 | 60% |

### 优化建议

⚠️ "路由切换" 匹配度较低
建议补充标签: "routing", "router"

✅ 所有核心关键词测试通过
```

---

## 同步机制

### 蒸馏后的自动同步

```javascript
同步步骤:

1. 保存知识文件
   → knowledge/动效/页面过渡/gsap页面过渡.md

2. 更新域索引
   → knowledge/动效/动效域索引.md
   添加: "- gsap页面过渡 - 页面过渡动画"

3. 同步关键词表
   → SKILL.md 关键词部分
   添加:
   | 页面过渡 | 页面切换, 转场 | 换页, 跳转 |

4. 同步语义标签
   → SKILL.md 语义标签部分
   添加: "页面过渡" → 动效域
```

### 同步验证

```markdown
## 同步验证

✅ 知识文件已保存
✅ 域索引已更新
✅ 关键词表已同步
✅ 语义标签已更新

验证搜索:
/frontend 页面过渡 → ✅ 找到
/frontend 页面切换 → ✅ 找到
```

---

## 最佳实践

### 1. 关键词要全面

```markdown
❌ 不好: ["页面过渡"]
✅ 更好: ["页面过渡", "页面切换", "转场", "GSAP", "transition"]
```

### 2. 标签要准确

```markdown
❌ 不好: ["animation"]
✅ 更好: ["gsap", "react", "page-transition", "routing"]
```

### 3. 目录要精确

```markdown
❌ 不好: knowledge/动效/
✅ 更好: knowledge/动效/页面过渡/
```

### 4. 描述要清晰

```markdown
❌ 不好: "页面过渡"
✅ 更好: "使用GSAP实现的高性能页面切换动画"
```

---

## 常见问题

### Q: 如何选择主关键词？

A: 选择最常用、最容易想到的词作为主关键词，其他作为同义词。

### Q: 标签越多越好吗？

A: 不是，标签要精准。5-8个标签比较合适。

### Q: 如何测试匹配效果？

A: 蒸馏后立即使用不同关键词测试搜索结果。

### Q: 同步失败怎么办？

A: 手动检查域索引和关键词表，确保格式正确。
