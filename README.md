# Frontend Knowledge Skill

A cross-platform frontend technical knowledge base that installs and works identically in **TRAE**, **Claude Code**, and **DeepSeek Harness**.

Contains 6 knowledge domains (animation, layout, components, norms, theming, tech decisions) with 50+ curated patterns and a 5-layer retrieval index.

---

## Features

- **Knowledge Base**: 6 domains with 50+ patterns covering UI development, animations, layouts, component patterns, design tokens, and tech decisions
- **5-Layer Retrieval**: L1 exact match → L2 semantic → L3 tag → L4 cross-domain → L5 scene recommendation
- **Dual Command**: `/frontend <需求>` for search, `/frontend <路径>` for page analysis
- **Knowledge Extraction**: `/frontend:distill` to extract code patterns into the knowledge base
- **Auto-Trigger**: Automatically activates when you mention frontend intent
- **Cross-Platform**: Same skill, three tools

---

## Installation

### Windows (PowerShell)

```powershell
# User-level (所有工具)
.\install.ps1 -Tool all -Scope user

# 单个工具
.\install.ps1 -Tool trae -Scope user        # TRAE
.\install.ps1 -Tool claude -Scope user     # Claude Code
.\install.ps1 -Tool dsh -Scope user        # DeepSeek Harness

# Project-level (项目级安装)
.\install.ps1 -Tool all -Scope project -ProjectPath "C:\path\to\project"
```

### macOS / Linux (Bash)

```bash
# 待实现 (TBD)
# chmod +x install.sh && ./install.sh -t all -s user
```

### Manual Installation

| Tool | User-level path | Project-level path |
|------|-----------------|-------------------|
| **TRAE** | `~/.trae/skills/frontend/` | `<project>/.trae/skills/frontend/` |
| **Claude Code** | `~/.claude/skills/frontend/` | `<project>/.claude/skills/frontend/` |
| **DeepSeek Harness** | `~/.dsh/skills/frontend/` | `<project>/.dsh/skills/frontend/` |

For Claude Code project-level, also copy `SKILL.md` (root) → `CLAUDE.md` in your project root.

---

## Commands

### /frontend — Main command (dual-mode)

**Mode 1: Query by description** — search knowledge and generate implementation prompts:

```bash
/frontend 实现一个带入场动画的筛选表格
/frontend 虚拟列表怎么实现
/frontend 暗色模式怎么做
```

**Mode 2: Analyze by file path** — read a page, match knowledge, generate refactoring prompts:

```bash
/frontend src/pages/ParcelManagement/index.tsx
/frontend src/pages/CustomerList/index.tsx
```

### /frontend:distill — Extract knowledge

```bash
/frontend:distill src/components/VirtualList.tsx --type pattern --domain 功能
/frontend:distill --type best --domain 动效 --name "GSAP性能优化"
/frontend:distill --type pitfall --domain 动效 --name "动画卡顿问题"
/frontend:distill src/pages/Orders --type page-layout --domain 布局 --platform web
```

### /frontend:list — Browse knowledge

```bash
/frontend:list                      # All domains overview
/frontend:list --domain 动效        # Animation domain
/frontend:list --stats             # Statistics
```

---

## Knowledge Domains

| Domain | 域 | Content | Examples |
|--------|---|---------|---------|
| **Animation** | 动效 | Animations, transitions, GSAP, ScrollTrigger | GSAP page transitions, staggered entrance, loading skeletons |
| **Layout** | 布局 | Responsive grids, sticky, positioning | CSS Grid, Flexbox, responsive breakpoints, sticky sidebar |
| **Components** | 功能 | Forms, lists, drag-and-drop, search | Virtual list, form validation, infinite scroll, drag sort |
| **Norms** | 项目规范 | Naming, structure, Git conventions | Component naming, directory structure, commit style |
| **Theming** | 设计主题 | Colors, typography, dark mode | Design token system, 60-30-10 color rule, dark mode |
| **Tech** | 技术选型 | Library comparisons, architecture decisions | Redux vs Zustand, Vite vs Webpack, GSAP vs Framer |

---

## Auto-Trigger

The skill auto-activates when your input matches frontend intent:

| Type | Input | Action |
|------|-------|--------|
| **Type A** | Intent: "做动画", "实现列表", "加暗色模式" | Triggers `/frontend <需求>` |
| **Type B** | File path: `src/pages/*.tsx`, `components/*.vue` | Triggers `/frontend <路径>` |

Disable: Set `skill.frontend.auto-trigger: false` in your project config.

---

## Uninstall

```powershell
# 卸载 (remove from specific tool)
.\install.ps1 -Tool trae -Scope user -Uninstall
.\install.ps1 -Tool claude -Scope user -Uninstall
.\install.ps1 -Tool dsh -Scope user -Uninstall
```

---

## Directory Structure

```
frontend-knowledge/              # GitHub repo root
├── SKILL.md                  # Claude Code project-level entry (copy to CLAUDE.md)
├── CLAUDE.md                 # Same as SKILL.md (Claude Code compatibility)
├── README.md                  # This file
├── README-zh.md              # 中文说明
├── install.ps1              # Cross-tool installer (PowerShell)
├── install.sh               # Cross-tool installer (Bash, TBD)
│
├── frontend/                  # Skill content (install this)
│   ├── SKILL.md            # Main entry + all command docs
│   ├── agent.md            # Agent context constraints
│   ├── commands/           # Command reference
│   ├── templates/          # Output templates
│   ├── verification/        # Quality checklists
│   └── knowledge/           # 6-domain knowledge base + L1-L5 index
│
└── .claude-plugin/         # Claude Code plugin metadata
    └── manifest.json
```

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 2.0 | 2026-09-17 | Cross-tool compatible (TRAE + Claude Code + DeepSeek Harness); merged `/frontend:knowledge` + `/frontend:analyze` → `/frontend`; 5-layer retrieval (L1-L5); page-layout distill type |
| 1.0 | earlier | Initial frontend-patterns + frontend-distill |

---

*For Chinese documentation, see [README-zh.md](README-zh.md).*
