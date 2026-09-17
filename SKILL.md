---
name: "frontend"
description: "Frontend knowledge base skill. Installs the frontend technical knowledge system for TRAE, Claude Code, and DeepSeek Harness. Auto-triggers when building UI pages, adding animations, implementing layouts, creating components, handling interactions, or refactoring pages. Use /frontend <query> or /frontend <file-path>; /frontend:distill to extract knowledge; /frontend:list to browse the knowledge base."
---

# Frontend Knowledge Skill

A cross-platform frontend technical knowledge base that installs and works identically in **TRAE**, **Claude Code**, and **DeepSeek Harness**.

---

## Installation / 安装

### Option 1: PowerShell (Recommended / 推荐)

```powershell
# TRAE (用户级)
.\install.ps1 -Tool trae -Scope user

# Claude Code (用户级)
.\install.ps1 -Tool claude -Scope user

# DeepSeek Harness (用户级)
.\install.ps1 -Tool dsh -Scope user

# All tools (用户级)
.\install.ps1 -Tool all -Scope user

# Project-level installation (指定项目)
.\install.ps1 -Tool all -Scope project -ProjectPath "C:\path\to\project"
```

### Option 2: Claude Code Project-Level

For Claude Code, copy this file to your project root as `CLAUDE.md`:

```
Copy: SKILL.md → CLAUDE.md (in your project root)
```

Claude Code will auto-discover `CLAUDE.md` as a project-level skill.

### Option 3: Manual Installation

| Tool | Path | Command |
|------|------|---------|
| **TRAE** (user) | `~/.trae/skills/frontend/` | Copy `frontend/` directory |
| **TRAE** (project) | `<project>/.trae/skills/frontend/` | Copy `frontend/` directory |
| **Claude Code** (user) | `~/.claude/skills/frontend/` | Copy `frontend/` directory |
| **Claude Code** (project) | `<project>/.claude/skills/frontend/` | Copy `frontend/` directory |
| **DeepSeek Harness** (user) | `~/.dsh/skills/frontend/` | Copy `frontend/` directory |
| **DeepSeek Harness** (project) | `<project>/.dsh/skills/frontend/` | Copy `frontend/` directory |

---

## Commands

### /frontend — Main command

Search the knowledge base and generate agent prompts. Two modes, auto-detected:

```
/frontend <需求描述>   # 需求描述分支：搜索知识 → 编排提示词
/frontend <页面路径>   # 页面路径分支：分析页面 → 生成改造方案
```

**Examples:**

```
/frontend 实现一个带入场动画的筛选表格
/frontend 优化卡片列表的过渡动画
/frontend 给登录页加上暗色模式
/frontend src/pages/ParcelManagement/index.tsx
```

### /frontend:distill — Knowledge extraction

Extract technical patterns from code into the knowledge base:

```
/frontend:distill src/components/Modal.tsx --type pattern --domain 动效
/frontend:distill --type best --domain 功能 --name "虚拟列表最佳实践"
/frontend:distill --type pitfall --domain 动效 --name "动画卡顿"
/frontend:distill src/pages/Orders --type page-layout --domain 布局 --platform web --name "订单筛选表格"
```

### /frontend:list — Browse knowledge

```
/frontend:list                       # 列出所有域
/frontend:list --domain 动效          # 列出动效域
/frontend:list --stats               # 显示统计信息
```

---

## Six Knowledge Domains

| Domain | Content | Example |
|--------|---------|---------|
| **动效** (Animation) | Animations, transitions, GSAP, ScrollTrigger | GSAP page transitions, loading skeletons |
| **布局** (Layout) | Responsive grids, sticky sidebars, waterfall | CSS Grid, Flexbox, responsive breakpoints |
| **功能** (Components) | Forms, virtual lists, drag-and-drop, search | Virtual list, form validation |
| **项目规范** (Norms) | Naming conventions, project structure, Git | Component naming, commit style |
| **设计主题** (Theming) | Color tokens, typography, dark mode | Design token system, 60-30-10 rule |
| **技术选型** (Tech Choices) | Library comparisons, architecture decisions | Redux vs Zustand, Vite vs Webpack |

---

## Auto-Trigger

This skill auto-activates when your input contains frontend-relevant keywords:

- **Type A** (需求描述): "做动画", "实现列表", "加暗色模式" → triggers `/frontend <需求>`
- **Type B** (页面路径): `src/pages/*.tsx`, `components/*.vue` → triggers `/frontend <路径>`

Disable auto-trigger in your tool's preferences or add `skill.frontend.auto-trigger: false` to your project config.

---

## Skill Structure

```
frontend/                     # ← Install this directory
├── SKILL.md                # Main entry + all command docs
├── agent.md                # Agent context constraints
├── commands/               # Command reference
│   ├── frontend.md
│   ├── distill.md
│   └── list.md
├── templates/              # Output templates
├── verification/           # Quality checklists
└── knowledge/             # Six-domain knowledge base + L1-L5 index
```

---

## Cross-Tool Compatibility

| Feature | TRAE | Claude Code | DeepSeek Harness |
|---------|------|-------------|------------------|
| Auto-trigger | ✅ | ✅ | ✅ |
| `/frontend` command | ✅ | ✅ | ✅ |
| `/frontend:distill` | ✅ | ✅ | ✅ |
| `/frontend:list` | ✅ | ✅ | ✅ |
| Project-level | ✅ | ✅ (CLAUDE.md) | ✅ |
| User-level | ✅ | ✅ | ✅ |

---

For detailed documentation, see `README.md` (English) or `README-zh.md` (中文).
For the full skill content and knowledge base, see the `frontend/` directory.
