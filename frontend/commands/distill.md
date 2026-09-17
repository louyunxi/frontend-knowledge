# /frontend:distill 命令

从代码或项目中提取和蒸馏技术经验，创建可复用的知识条目。**内置智能分析，确保知识放到正确的位置并被容易匹配。**

> ⚠️ **路径硬约束**：`/frontend:distill` 所有落盘操作**只能且必须**写入当前 skill 的 `knowledge/` 目录，即：
>
> `frontend/knowledge/[对应域]/`
>
> 严禁写入任何其他 Skill 目录、其他项目目录或 `frontend/knowledge/` 以外的任何路径。违反此约束时，蒸馏流程必须停止并报告阻断项，不得创建任何文件。

## 命令格式

```
/frontend:distill [源路径] --type [类型] --domain [域] [--platform 平台] [--name 名称]
```

## 核心特性

```
✅ 智能分析 - 自动分析代码特征，推荐最佳目录
✅ 关键词提取 - 自动提取关键词、同义词、语义变体
✅ 标签推荐 - 自动推荐技术栈、功能、场景标签
✅ 匹配测试 - 蒸馏后自动测试搜索匹配效果
✅ 同步验证 - 确保索引和关键词表正确更新
```

## 参数说明

| 参数 | 必填 | 说明 | 可选值 |
|-----|------|------|--------|
| `源路径` | 条件 | 代码文件、页面入口或目录路径；`page-layout` 时必填 | 文件路径、目录路径 |
| `--type` | 是 | 蒸馏类型 | `pattern`、`best`、`pitfall`、`page-layout` |
| `--domain` | 是 | 知识域；`page-layout` 时必须为 `布局` | `动效`、`布局`、`功能`、`项目规范`、`设计主题`、`技术选型` |
| `--platform` | 条件 | 页面布局的目标平台；仅用于且必用于 `page-layout` | `web`、`mobile`、`responsive` |
| `--name` | 否 | 模式名称 | 自定义名称（默认从页面任务和结构推断） |

## 命名规范

**唯一规范**：`{域}-{主题}-{修饰}.md` 三段式，使用半角 `-` 连接。`page-layout` 例外，使用 `[页面任务]-[平台].md`（详见下方"page-layout 例外"）。

```text
{域}
├── 动效
├── 布局
├── 功能
├── 项目规范
├── 设计主题
└── 技术选型

{主题}    - 名词或技术栈名：gsap、leaflet、arcgis、表格、表单、token、栅格...
{修饰}    - 限定词或场景词：移动端、入门、对比、风格、卡片、字段、笔记...

正例
├── 动效-gsap-页面过渡.md
├── 动效-动效设计-原则.md
├── 布局-响应式-栅格.md
├── 设计主题-移动端-60-30-10配色.md
├── 设计主题-UniApp-Token系统.md
├── 功能-Leaflet-地图初始化与地块绘制.md
└── 技术选型-UniApp-小程序WXSS兼容性.md

反例（禁止落盘）
├── Modal.md              单段名，无域无主题
├── 规则.md               单段名，无主题
├── my_note.md            含下划线/英文缩写命名
└── 动效/页面过渡.md      目录结构与文件名混淆
```

**强制约束**：

- 文件名三段必须齐全；少于 3 段或多于 4 段必须走合并或重命名流程
- 段名只允许使用 `-`（半角连字符）、中文字符、小写英文；不允许下划线、空格、特殊字符
- 命名一致性必须由 `verification/distill-checklist.md` §3 与 `verification/index-sync-checklist.md` §4 把关
- 既有 `knowledge/<域>/*.md` 中不符合新规范的文件，**不强制重命名**（避免破坏 L1/L2/L3/L4 现有引用），但下次任何编辑该文件时必须顺手改名为新规范

### page-layout 例外

`--type page-layout` 必须采用 `[页面任务]-[平台].md`：

```text
正例
├── 订单筛选表格-web.md
├── 移动端待办列表-mobile.md
└── 响应式客户列表与详情-responsive.md

保存目录固定为 knowledge/布局/页面模式/
平台后缀固定 ∈ web | mobile | responsive
```

`page-layout` 例外的设计理由：页面布局名须以"页面任务"为主体，平台作为稳定后缀以便跨端模式对照识别；不允许把"布局"写进文件名，因为父目录 `布局/` 已经表达域语义。

## 蒸馏类型

### 1. pattern - 提取技术模式

```
用途：从代码中提取可复用的技术模式

适用场景：
├── 发现好的代码实现需要复用
├── 项目中有可复用的组件或 Hook
├── 需要标准化某个技术的实现方式
└── 提取最佳实践的代码实现

示例：
/frontend:distill src/components/VirtualList.tsx --type pattern --domain 功能
/frontend:distill src/hooks/useScrollAnimation.ts --type pattern --domain 动效
```

### 2. best - 提炼最佳实践

```
用途：总结某个技术的最佳实践和经验

适用场景：
├── 总结某个技术的实现经验
├── 记录某个场景的最佳解决方案
├── 需要整理技术调研的结论
└── 需要标准化团队的开发方式

示例：
/frontend:distill --type best --domain 动效 --name "GSAP性能优化"
/frontend:distill --type best --domain 布局 --name "响应式最佳实践"
```

### 3. pitfall - 记录踩坑

```
用途：记录开发中遇到的问题和解决方案

适用场景：
├── 解决了一个技术难题
├── 遇到并解决了某个 bug
├── 发现某个技术的坑
└── 需要记录经验教训

示例：
/frontend:distill --type pitfall --domain 动效 --name "动画卡顿问题"
/frontend:distill --type pitfall --domain 功能 --name "虚拟列表性能问题"
```

### 4. page-layout - 蒸馏页面布局模式

```
用途：从真实页面及其项目上下文中提取可复用的页面任务、结构、模块关系、状态协作和跨端转换规则

适用场景：
├── 蒸馏 Dashboard、筛选表格、主从详情、GIS 工作台等页面模式
├── 总结同一任务在桌面、平板和移动端的结构变化
├── 提取移动端独立任务流，而不是简单压缩桌面布局
└── 为 `/frontend` 的"页面路径"分支提供可按页面任务召回的布局知识

示例：
/frontend:distill src/pages/Orders --type page-layout --domain 布局 --platform web --name "订单筛选表格"
/frontend:distill src/pages/mobile/TaskList --type page-layout --domain 布局 --platform mobile --name "移动端待办列表"
/frontend:distill src/pages/CustomerList --type page-layout --domain 布局 --platform responsive --name "响应式客户列表与详情"
```

#### 参数约束

```text
--type page-layout
├── 源路径必须存在且能够确认页面入口
├── --domain 必须为 布局
├── --platform 必须为 web、mobile 或 responsive
├── 不得只读取单个样式文件或只根据截图推断
└── 缺少必要参数时停止蒸馏并报告缺失项，不创建知识文件

其他 --type
└── 不接受 --platform；若提供则停止并提示该参数只属于 page-layout
```

#### 平台语义

| 值 | 蒸馏目标 | 必须覆盖 |
|---|---|---|
| `web` | 桌面 Web 页面模式 | 页面任务、桌面骨架、模块关系、状态、密度、滚动与导航 |
| `mobile` | 移动端页面或独立任务流 | 信息优先级、单手操作、触摸目标、安全区域、软键盘、返回与滚动 |
| `responsive` | 同一核心任务的跨断点模式 | 桌面、平板、移动骨架及显式结构转换规则 |

`responsive` 只适用于核心任务、主要对象和成功结果保持一致的页面。若移动端的任务、操作顺序或信息优先级明显改变，应停止合并蒸馏，建议分别生成 `web` 与 `mobile` 两条关联模式。

`responsive` 的桌面、平板和移动骨架必须分别有运行证据、测试证据或明确设计规范。仅有静态代码证据时，相关结论必须标为 `inferred` 且置信度只能为 `low`；无法确认移动任务一致性、关键交互、状态保持、焦点或滚动归属时，不得保存为 `responsive`，应改为单端模式或报告证据缺口。

## page-layout 专用蒸馏流程

### 1. 读取范围

以源路径确认页面入口，并读取：

```text
必须读取
├── 页面入口及直接引用的本地组件
├── 页面样式、类型、Hooks、状态和数据请求封装
├── 路由配置与页面外层容器
├── design.md / DESIGN.md、Design Token 和主题配置
└── 项目 UI 组件库与公共页面容器

必须搜索，找到后读取
└── 与当前页面任务相同或相近的同类页面

按证据需要读取
├── 响应式断点和设备判断逻辑
├── 权限、URL 状态和导航约束
├── 覆盖层、抽屉、弹窗与焦点管理
└── 测试、Story、设计说明或真实运行截图
```

只读取与页面模式判断直接相关的依赖，避免递归扫描整个项目。同类页面不存在时记录单样本并降低置信度，不自动阻断。无法确认入口、主要任务、主要模块或关键状态时，停止蒸馏并输出证据缺口。

#### 安全读取与脱敏

```text
禁止读取或摘录
├── .env*、密钥、证书和凭据文件
├── Token、API Key、Cookie 和 Authorization Header
├── 完整接口响应、真实用户数据和个人数据
└── 与布局模式无关的内部权限细节

保存前必须处理
├── 内部域名、服务地址、租户、账号和业务 ID 泛化或脱敏
├── 来源证据只保留仓库相对路径、符号名和布局相关摘要
└── 检测到疑似凭据时停止保存并报告安全阻断项
```

不得把敏感值复制到知识正文、frontmatter、索引或匹配测试中。

### 2. 建立页面事实模型

```yaml
page_evidence:
  identity:
    name: ""
    route: ""
    page_type: ""
    business_domain: ""
  intent:
    primary_task: ""
    secondary_tasks: []
    success_outcome: ""
  platform:
    requested: "web | mobile | responsive"
    observed_viewports: []
    task_consistency: "same | changed | unknown"
  modules: []
  relations: []
  states: []
  navigation: []
  layout_regions: []
  responsive_rules: []
  source_files: []
```

每个结论必须关联源文件、组件、样式规则或项目规范。不得把推测写成已确认事实。

### 3. 提取页面模式

按以下顺序抽象：

```text
页面主要任务
→ 页面类型与关键对象
→ 页面骨架和区域层级
→ 模块之间的触发与同步关系
→ 加载、空、错误、权限和选择状态
→ 导航、覆盖层、焦点和滚动归属
→ 平台约束与结构转换
→ 适用条件、不适用条件和替代模式
```

页面模式优先使用任务命名，例如“筛选表格 + 详情抽屉”，不能只命名为“Grid 布局”或“Flex 页面”。Grid、Flex、Sticky 等作为实现线索记录，不作为页面模式主体。

### 4. 置信度与泛化边界

```text
high
├── 至少两个独立项目或多个同类页面提供一致证据
└── 关键任务、模块关系和转换规则均被验证

medium
├── 同一项目中有多个样本，或单样本同时有设计规范与测试证据
└── 可复用边界清晰

low
├── 仅有单项目单页面样本
├── 关键平台状态未运行验证
└── 主要依赖推断
```

单样本默认不得标记为 `high`。来源限定、项目特有约束和未验证结论必须显式保留。

### 5. 应用模板

`page-layout` 必须使用 `templates/page-layout-template.md`。不得使用通用技术模式模板代替。

### 6. 保存与同步

```text
输入
├── --type           page-layout
├── --domain         布局           ← 与目标目录首段 knowledge/布局/ 一致
├── --platform       web | mobile | responsive   ← 作为文件后缀
└── --name           页面任务名

目标
├── 保存目录: knowledge/布局/页面模式/    ← 首段必须与 --domain 完全一致
├── 文件命名: [页面任务]-[平台].md       ← 平台直接来自 --platform
└── 平台后缀: web | mobile | responsive
```

**完整示例**：

```text
命令:
/frontend:distill src/pages/Orders --type page-layout \
    --domain 布局 --platform web --name "订单筛选表格"

结果:
├── 保存到:        knowledge/布局/页面模式/订单筛选表格-web.md
├── 相对路径:      布局/页面模式/订单筛选表格-web.md
├── relative_path: 布局/页面模式/订单筛选表格-web.md
└── 索引项:        布局域索引 → 页面模式分类 → 订单筛选表格-web
```

> ⚠️ **domain-目录一致性硬规则**：
> -1. `--domain` 值必须与目标路径的第一段（`knowledge/<域>/`）完全一致，
>     例如 `--domain 布局` 必须落到 `knowledge/布局/...`；
> -2. `--type page-layout` 强制 `--domain 布局` 且强制落盘到 `knowledge/布局/页面模式/`；
> -3. 其它 `--type` 必须落到对应 `--domain` 域根或该域下显式声明的子目录，禁止跨域落盘；
> -4. `--platform` 只能为 `web`/`mobile`/`responsive`，且必须作为文件后缀体现；
> -5. 违反以上任一条规则时，`distill-checklist.md` §6 触发阻断，禁止落盘。

**首次保存自动建目录**：`knowledge/布局/页面模式/` 目录在首次保存 page-layout
时自动创建；若目录已存在则跳过创建步骤。

同步规则：

1. 规范化名称后检查目标路径及索引中是否已有同名或同任务模式；
2. 若存在，默认停止并输出来源、平台、模块关系和泛化边界差异，要求明确选择合并、更新或使用限定词另存；
3. 合并或更新时保留原有来源范围，重新计算置信度和泛化边界；
4. 先生成并验证知识文件，再更新布局域索引和四层检索索引；任一同步失败时不得报告成功；
5. 四层索引项必须包含稳定的 `knowledge_id`、`display_name`、`relative_path`、`knowledge_type` 和 `target_platform`；
6. `relative_path` 使用从 `knowledge/` 开始的规范化相对路径，召回时先验证实体存在；
7. 关键词必须包含页面任务、页面类型、模块组合、平台和常见口语表达；
8. 不得在索引中预先声明尚未创建的页面模式；
9. 匹配测试必须验证 `/frontend` 的两个分支都能按页面任务召回该知识。

## 智能蒸馏流程

```
┌────────────────────────────┐
│ Step 1: 内容分析          │
│                              │
│ ✅ 分析代码特征             │
│ ✅ 识别技术栈              │
│ ✅ 提取核心功能            │
│ ✅ 评估复杂度              │
└────────────┬───────────────┘
             ↓
┌────────────────────────────┐
│ Step 2: 目录推荐            │ ← 🆕 智能推荐
│                              │
│ ✅ 推荐最佳保存目录          │
│ ✅ 列出备选目录            │
│ ✅ 解释推荐理由            │
│ ✅ 确认保存位置            │
└────────────┬───────────────┘
             ↓
┌────────────────────────────┐
│ Step 3: 关键词提取         │ ← 🆕 智能提取
│                              │
│ ✅ 提取精确关键词           │
│ ✅ 生成同义词              │
│ ✅ 生成语义变体            │
│ ✅ 验证关键词有效性        │
└────────────┬───────────────┘
             ↓
┌────────────────────────────┐
│ Step 4: 标签推荐            │ ← 🆕 智能推荐
│                              │
│ ✅ 推荐技术栈标签           │
│ ✅ 推荐功能标签            │
│ ✅ 推荐场景标签            │
│ ✅ 合并去重              │
└────────────┬───────────────┘
             ↓
┌────────────────────────────┐
│ Step 5: 应用模板            │
│                              │
│ pattern → distill-guide.md（pattern 章节）  │
│ best → distill-guide.md（best 章节）       │
│ pitfall → distill-guide.md（pitfall 章节） │
│ page-layout → page-layout-template.md（独立流程）│
└────────────┬───────────────┘
             ↓
┌────────────────────────────┐
│ Step 6: 验证               │
│                              │
│ ✅ 代码完整性              │
│ ✅ 步骤清晰度             │
│ ✅ 依赖明确性             │
│ ✅ 示例可运行             │
└────────────┬───────────────┘
             ↓
┌────────────────────────────┐
│ Step 7: 匹配测试           │ ← 🆕 智能测试
│                              │
│ ✅ 用关键词搜索测试        │
│ ✅ 用同义词测试            │
│ ✅ 用语义变体测试          │
│ ✅ 优化关键词              │
└────────────┬───────────────┘
             ↓
┌────────────────────────────┐
│ Step 8: 保存与同步          │
│                              │
│ ✅ 保存到 knowledge/[域]/    │
│ ✅ 更新域索引              │
│ ✅ 同步关键词表            │
│ ✅ 更新语义标签            │
└────────────────────────────┘
```

## Step 2: 目录推荐详解

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
│   ├── 定位/              ← sticky、fixed
│   ├── 特殊/              ← 瀑布流、圣杯
│   └── 对齐/              ← 居中、两端对齐
│
├── 功能/
│   ├── 列表/              ← 虚拟列表、分页
│   ├── 表单/              ← 验证、联动
│   ├── 拖拽/              ← 排序、拖放
│   ├── 状态/              ← 主题、全局状态
│   └── 交互/              ← 筛选、搜索
│
├── 项目规范/
│   ├── 命名/              ← 组件、文件命名
│   ├── 结构/              ← 目录结构
│   ├── Git/               ← 提交、分支
│   └── 代码/              ← ESLint、Prettier
│
├── 设计主题/
│   ├── 色彩/              ← 配色、变量
│   ├── 字体/              ← 字号、字重
│   ├── 间距/              ← 间距系统
│   └── 主题/              ← 暗色、主题切换
│
└── 技术选型/
    ├── 状态管理/          ← Redux、Zustand
    ├── 数据请求/          ← Axios、Fetch
    ├── 动画库/            ← GSAP、Framer
    └── UI组件/            ← 组件库对比
```

### 目录推荐算法

```javascript
代码特征 → 推荐目录
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
包含 gsap/framer-motion         → 动效/页面过渡
使用 transform/opacity          → 动效/交互反馈
使用 IntersectionObserver       → 动效/滚动动画
使用 Grid/Flexbox              → 布局/栅格
包含 @media responsive          → 布局/响应式
使用 position: sticky          → 布局/定位
使用虚拟列表库                 → 功能/列表
使用表单验证库                 → 功能/表单
使用拖拽库                    → 功能/拖拽
涉及 color/theme               → 设计主题/主题
涉及 CSS variable              → 设计主题/色彩
对比多个技术方案               → 技术选型/
```

### 目录推荐示例

```
输入: /frontend:distill src/components/PageTransition.tsx --type pattern

AI 分析:
✅ 识别: GSAP 页面过渡组件
✅ 代码特征: import { gsap }, 路由切换
✅ 推荐目录: 动效/页面过渡/
✅ 备选: 动效/交互反馈/
✅ 推荐理由: 核心功能是路由切换时的动画效果

确认保存到: knowledge/动效/页面过渡/gsap页面过渡.md
```

## Step 3: 关键词提取详解

### 关键词层级

```
Layer 1: 精确关键词 (100% 匹配)
├── 直接使用文件名/功能名
└── 示例: "gsap页面过渡", "虚拟列表"

Layer 2: 同义词 (90% 匹配)
├── 技术栈别名
├── 功能别名
└── 示例: "页面切换" = "页面过渡"

Layer 3: 语义变体 (80% 匹配)
├── 用户口语化表达
├── 场景描述
└── 示例: "换页" = "页面过渡"
```

### 关键词提取规则

```javascript
提取步骤:

1. 从文件名提取
   "gsap-page-transition" → ["gsap", "页面过渡", "transition"]

2. 从代码提取依赖
   import { gsap } from 'gsap' → ["gsap"]
   import { useVirtualizer } → ["虚拟列表", "virtual"]

3. 从描述提取
   "页面切换动画" → ["页面切换", "动画", "过渡"]

4. 生成同义词
   "页面过渡" → ["页面切换", "路由切换", "转场"]
   "虚拟列表" → ["virtual list", "大数据列表"]

5. 生成语义变体
   "页面过渡" → ["换页", "跳转动画", "SPA切换"]
   "骨架屏" → ["加载占位", "loading效果", "等待"]
```

### 关键词提取示例

```
输入: /frontend:distill src/components/PageTransition.tsx --type pattern

AI 提取:
✅ 精确关键词: ["页面过渡", "gsap", "transition"]
✅ 同义词: ["页面切换", "转场", "路由切换"]
✅ 语义变体: ["换页", "跳转动画", "SPA切换"]

关键词表将更新为:
| 关键词 | 同义词 | 语义变体 |
|--------|--------|---------|
| 页面过渡 | 页面切换, 转场, 路由切换 | 换页, 跳转 |
```

## Step 4: 标签推荐详解

### 标签分类

```
技术栈标签:
├── react, vue, typescript, javascript
├── gsap, framer-motion, anime.js
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
   import { useNavigate } from 'react-router' → ["react", "routing"]

2. 从功能识别场景
   页面过渡 → ["page", "transition", "routing"]

3. 从使用场景推断
   SPA 应用 → ["spa", "web"]

4. 合并去重
   最终标签: ["gsap", "react", "animation", "page-transition", "routing", "spa"]
```

### 标签推荐示例

```
输入: /frontend:distill src/components/PageTransition.tsx --type pattern

AI 推荐:
✅ 技术栈标签: ["react", "gsap", "typescript"]
✅ 功能标签: ["animation", "transition", "page"]
✅ 场景标签: ["spa", "routing"]

Frontmatter 将更新为:
tags: ["react", "gsap", "animation", "transition", "page", "routing", "spa"]
```

## Step 7: 匹配测试详解

### 测试流程

```javascript
蒸馏后自动测试:

1. 使用精确关键词搜索
   search("页面过渡") → 应找到 gsap页面过渡 ✅

2. 使用同义词搜索
   search("页面切换") → 应找到 gsap页面过渡 ✅

3. 使用语义变体搜索
   search("换页动画") → 应找到 gsap页面过渡 ✅

4. 使用场景搜索
   search("路由切换带动画") → 应找到 gsap页面过渡 ⚠️
```

### 测试报告格式

```markdown
## 匹配测试报告

### 测试结果

| 搜索词 | 匹配结果 | 匹配度 | 状态 |
|--------|---------|--------|------|
| 页面过渡 | gsap页面过渡 | 100% | ✅ |
| 页面切换 | gsap页面过渡 | 90% | ✅ |
| 转场 | gsap页面过渡 | 85% | ✅ |
| 换页 | gsap页面过渡 | 80% | ✅ |
| 路由切换 | gsap页面过渡 | 60% | ⚠️ |

### 优化建议

⚠️ "路由切换" 匹配度较低
建议补充:
- 添加同义词: "路由切换" → "路由"
- 添加标签: "router", "navigate"

✅ 所有核心关键词测试通过
```

## 输出格式

```markdown
## 蒸馏报告

**类型**: pattern
**名称**: GSAP页面过渡
**目录**: knowledge/动效/页面过渡/

---

### 1. 内容分析

✅ 技术栈: React + GSAP
✅ 核心功能: 页面过渡动画
✅ 使用场景: SPA路由切换

### 2. 目录推荐

✅ 推荐目录: 动效/页面过渡/
✅ 推荐理由: 核心功能是路由切换时的动画效果

### 3. 关键词提取

✅ 精确关键词: ["页面过渡", "gsap", "transition"]
✅ 同义词: ["页面切换", "转场", "路由切换"]
✅ 语义变体: ["换页", "跳转动画", "SPA切换"]

### 4. 标签推荐

✅ 技术栈: ["react", "gsap", "typescript"]
✅ 功能: ["animation", "transition", "page"]
✅ 场景: ["spa", "routing"]

### 5. 验证结果

✅ 代码完整性: 通过
✅ 步骤清晰度: 通过
✅ 依赖明确性: 通过
✅ 示例可运行: 通过

### 6. 匹配测试

| 搜索词 | 匹配度 | 状态 |
|--------|--------|------|
| 页面过渡 | 100% | ✅ |
| 页面切换 | 90% | ✅ |

### 7. 保存结果

✅ 保存到: knowledge/动效/页面过渡/gsap页面过渡.md
✅ 更新索引: knowledge/动效/动效域索引.md
✅ 同步关键词表: SKILL.md
```

## 使用示例

### 示例 1: 从代码提取模式

```markdown
用户: /frontend:distill src/components/PageTransition.tsx --type pattern

AI:
正在分析代码...

✅ 识别技术栈: React + GSAP
✅ 识别功能: 页面过渡动画

推荐保存目录:
✅ 动效/页面过渡/ (推荐)
⚡ 动效/交互反馈/ (备选)

确认保存到: knowledge/动效/页面过渡/gsap页面过渡.md

正在提取关键词...

提取关键词:
✅ 精确: ["页面过渡", "gsap", "transition"]
✅ 同义词: ["页面切换", "转场", "路由切换"]
✅ 语义变体: ["换页", "跳转", "SPA切换"]

正在推荐标签...

推荐标签:
✅ 技术栈: ["react", "gsap", "typescript"]
✅ 功能: ["animation", "transition"]
✅ 场景: ["spa", "routing"]

正在应用模板...
正在验证...
正在匹配测试...

匹配测试:
✅ "页面过渡" → 找到 (100%)
✅ "页面切换" → 找到 (90%)
✅ "换页" → 找到 (80%)

正在保存和同步...
✅ 保存到: knowledge/动效/页面过渡/gsap页面过渡.md
✅ 更新索引
✅ 同步关键词表
✅ 更新标签
```

### 示例 2: 记录踩坑

```markdown
用户: /frontend:distill --type pitfall --domain 动效 --name "动画卡顿"

AI:
正在分析踩坑...

请提供以下信息：

**问题现象**: [用户填写: 动画在移动端卡顿]
**问题原因**: [用户填写: 动画了layout属性]
**解决方案**: [用户填写: 改用transform]
**预防措施**: [用户填写: 检查动画属性]

推荐保存目录:
✅ 动效/交互反馈/ (推荐)
⚡ 动效/滚动动画/ (备选)

提取关键词:
✅ 精确: ["动画卡顿", "性能问题"]
✅ 同义词: ["卡顿", "slow", "流畅"]
✅ 语义变体: ["不流畅", "帧率低"]

推荐标签:
✅ 功能: ["animation", "performance"]
✅ 场景: ["mobile", "performance"]

✅ 保存到: knowledge/动效/交互反馈/动画卡顿.md
✅ 同步完成
```

## 相关命令

- `/frontend` - 主命令（需求描述 / 页面路径）
- `/frontend:list` - 列出知识
- `/frontend:verify` - 验证知识
