# Frontend Knowledge Skill — Agent Context

> 本文件是 `frontend` Skill 的 AI 上下文约束。AI 在使用本 Skill 时必须遵守本文档的所有约束。

---

## 核心约束：禁止向其他 Skill 蒸馏知识

> **本 Skill 是且仅是 `frontend` 这个 Skill 的内容维护工具。**
>
> 所有知识蒸馏操作（`/frontend:distill`）**必须且只能**保存到本 Skill 的 `knowledge/` 目录（即 `frontend/knowledge/[对应域]/`）。
>
> 严禁将任何前端技术知识蒸馏到其他 Skill、其他目录或 `frontend/knowledge/` 以外的任何位置。
>
> 违反此约束会导致：知识分散、无法通过 `/frontend` 检索、索引体系失效、知识库维护混乱。

---

## 命令系统

### /frontend — 唯一主命令（双分支）

一个命令，两个分支，输入自动识别：

```
/frontend <需求描述>   → 需求描述分支：搜索知识库，召回知识点，编排 Agent 实施提示词
/frontend <页面路径>   → 页面路径分支：读取页面，分析上下文，生成改造提示词
```

#### 分支识别

- 输入是已存在的本地文件/目录路径 → **页面路径分支**
- 输入是自然语言描述、关键词、技术名词 → **需求描述分支**
- 同时含路径和需求时 → **优先页面路径分支**

#### 需求描述分支（/frontend <需求>）

适用：搜索某个效果怎么实现、按最佳实践实现新功能、优化交互/动效/布局/主题。

召回架构：L1 精确匹配 → L2 语义匹配 → L3 扩展匹配 → L4 组合匹配 → L5 场景推荐。

输出：召回方案列表 + 知识摘要 + Agent 实施提示词（可直接复制使用）。**默认 auto-execute**，输出 prompt 后立即进入实施；危险命令必须二次确认。

#### 页面路径分支（/frontend <页面路径>）

适用：已有页面需要补齐布局/排版/视觉；需要保留业务逻辑做改造。

必须先读取：页面入口、直接引用的组件/样式/类型/Hooks/工具、项目依赖、设计规范、公共页面容器。

输出：页面分析报告 + Agent 实施提示词（可直接复制使用）。**默认 auto-execute**，输出 prompt 后立即进入实施；危险命令必须二次确认。

详见 `commands/frontend.md`。

### /frontend:distill — 知识蒸馏

```
/frontend:distill [源路径] --type [类型] --domain [域] [--platform 平台] [--name 名称]
```

| --type | 用途 |
|--------|------|
| `pattern` | 从代码提取可复用技术模式 |
| `best` | 提炼最佳实践 |
| `pitfall` | 记录踩坑和解决方案 |
| `page-layout` | 蒸馏页面布局模式（强制 --domain 布局 --platform web\|mobile\|responsive） |

> ⚠️ **路径硬约束**：所有落盘只能写入 `frontend/knowledge/[对应域]/`。

详见 `commands/distill.md`。

### /frontend:list — 知识列表

```
/frontend:list [--domain 域] [--all] [--stats]
```

所有统计数字必须由执行时扫盘 `knowledge/` 实时生成，禁止硬编码。

详见 `commands/list.md`。

---

## 自动触发模式

本 Skill 默认开启自动触发。当用户输入符合下列场景时，无需显式调用 `/frontend` 也会激活：

| 类型 | 触发条件 | 行为 |
|------|---------|------|
| **类型 A** | 含 6 大知识域关键词（动画、布局、组件、动效、设计等） | 走需求描述分支 |
| **类型 B** | 含页面路径引用（src/、pages/、components/、.tsx、.vue 等） | 走页面路径分支 |

**6 大域触发词**（真相源：`knowledge/索引/L2-关键词索引.md`）：

- **动效**：动画、动效、过渡、转场、入场、出场、loading、骨架屏、gsap、framer-motion
- **布局**：布局、栅格、响应式、适配、居中、侧边栏、sticky、瀑布流、grid、flex
- **功能**：表单、input、虚拟列表、拖拽、无限滚动、筛选、搜索、列表、分页
- **项目规范**：命名规范、目录结构、git 规范、typescript 规范、代码审查
- **设计主题**：主题切换、暗色模式、配色、字体、间距、圆角、阴影
- **技术选型**：状态管理、请求库、动画库、UI 组件库、构建工具

---

## 知识域分类

| 域 | 内容 | 示例 |
|---|------|------|
| **动效** | 动画、过渡、转场、GSAP、ScrollTrigger | GSAP 页面过渡、骨架屏、stagger 入场 |
| **布局** | 响应式、栅格、定位、页面模式 | CSS Grid、Sticky 侧边栏、瀑布流 |
| **功能** | 组件、交互、状态、列表、表单 | 虚拟列表、表单验证、拖拽排序 |
| **项目规范** | 命名、结构、Git、代码规范 | 组件命名、提交规范、ESLint |
| **设计主题** | 色彩、字体、主题、间距 | 设计令牌、暗色模式、60-30-10 配色 |
| **技术选型** | 库对比、架构、方案选择 | Redux vs Zustand、GSAP vs Framer |

---

## 禁止行为

- 不修改页面代码或样式（除非显式开启 auto-execute 或未加 `--dry-run` / `--confirm` 关闭执行）
- 默认 auto-execute：生成 Agent 实施提示词后立即进入实施，但**危险命令拦截清单**（见 `commands/frontend.md`）必须二次确认
- 不把知识检索结果原样堆入提示词
- 不编造项目组件、设计规则或知识文件
- 不以"现代化"为理由引入渐变、玻璃拟态、过度圆角或无目的动画
- 不创建全新页面组件（auto-execute 只改造、改写现有代码，不主动新建文件，除非明确需求要求）
- 不根据文件名直接推断完整页面类型（必须读文件后判断）

---

## 维护位置约束（重要）

> **本 Skill 物理上只有一份文件。** 任何时候、任何场景下，AI 与开发者在**创建、编辑、删除 Skill 内文件时，永远只能操作 `frontend/` 下的文件，不要把 `.trae/skills/frontend/` 当作"独立副本"来处理。**

### 物理真相

```
E:\AI\front-knowledge\frontend\              ← 唯一真相源（Git tracked，开发者编辑唯一入口）
└── SKILL.md / agent.md / commands / knowledge / templates / verification / ...

E:\AI\front-knowledge\.trae\skills\frontend\   ← Junction（Windows 目录联接）
    ↓ mklink /J
E:\AI\front-knowledge\frontend\              ← 物理上指向同一个目录
```

`mklink /J` 是 NTFS 目录联接（reparse point），对所有上层软件（IDE、文件系统 API、Git、PowerShell、其它工具）完全透明：

- 两边看到的目录列表**完全一致**
- 通过任一路径改文件，物理上就是同一个 inode / 同一份字节
- 不存在"复制 vs 链接"漂移的可能
- `.trae/` 已在 `.gitignore` 中，Junction 永远不会被提交

### AI 行为约束

| 场景 | AI 应该写到的路径 | 反例（**禁止**） |
|------|------------------|------------------|
| 修改 `agent.md` | `frontend/agent.md` | ~~写 `.trae/skills/frontend/agent.md` 然后期望它"独立保存"~~ |
| 新增知识文件 | `frontend/knowledge/[域]/xxx.md` | ~~写 `.trae/skills/frontend/knowledge/...`~~ |
| 新增命令 | `frontend/commands/xxx.md` | ~~`.trae/skills/frontend/commands/...`~~ |
| 修改脚本 | 直接改 `frontend/` 下 `SKILL.md` / `agent.md` / `commands/*` | ~~"在 .trae 里同步" 之类操作~~ |

### 三条铁律

1. **永远编辑 `frontend/` 下的文件**——junction 让 IDE 自动同步，不需要再走 sync / copy / patch 一类步骤。
2. **不要执行任何向 `.trae/skills/frontend/` "复制 / 同步 / patch" 的操作**——`sync.ps1` 已删除；`Copy-Item` 会创建真副本，立即引入 drift。要给另一台机器装这份 Skill，仍用 `.\install.ps1 -Tool trae -Scope project -ProjectPath .`（自动 mklink /J）。
3. **如果发现 `.trae/skills/frontend/` 不再是 Junction 而变成了真实目录**（比如 IDE 自动恢复过、或被误操作删了联接），立即报告用户、停止写入，先调用 `.\install.ps1 -Tool trae -Scope project -ProjectPath . -Uninstall` 后再 `install.ps1` 重建 Junction，**而不是去两边各自编辑**。

### 用户级提示（在 SKILL.md 维护策略章节也有相同说明）

- ✅ 编辑 / 新增 / 删除 → 只动 `frontend/`
- ✅ 提交：`git add frontend/ && git commit && git push`
- ✅ 给其他 IDE 装：`.\install.ps1 -Tool trae -Scope project -ProjectPath .`
- ❌ 严禁把 `.trae/skills/frontend/` 当作独立副本
- ❌ 严禁 `sync.ps1` / `Copy-Item` / 手工 patch 之类以"同步两边"为目的的操作

---

## 路径约束说明（运行时）

本 Skill 通过 **Junction 联接** 安装到 IDE 的 `frontend/` 加载目录，物理上只有源码 `frontend/` 这一份。AI 在执行蒸馏命令时应使用相对路径 `knowledge/[域]/`，由 skill 自身和 IDE 工作目录解析为绝对路径，**不需要也不应**在源码内出现绝对路径占位符。
