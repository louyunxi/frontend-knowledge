---
name: "frontend"
description: "Frontend knowledge base skill. Installs the frontend technical knowledge system for TRAE, Claude Code, and DeepSeek Harness. Auto-triggers when building UI pages, adding animations, implementing layouts, creating components, handling interactions, or refactoring pages. Use /frontend <query> or /frontend <file-path>; /frontend:distill to extract knowledge; /frontend:list to browse the knowledge base."
---

# Frontend Knowledge Skill

A cross-platform frontend technical knowledge base. Install the `frontend/` subdirectory to activate.

## Quick Start

### Install

```bash
# Run from this repository root:
./install.ps1 -Tool all -Scope project -ProjectPath "C:\path\to\this\project"
```

Or manually copy the `frontend/` subdirectory to your project's skill directory:

| Tool | Project-level path |
|------|-------------------|
| TRAE | `<project>/.trae/skills/frontend/` |
| Claude Code | `<project>/.claude/skills/frontend/` |
| DeepSeek Harness | `<project>/.dsh/skills/frontend/` |

### Use

```
/frontend 实现一个带入场动画的筛选表格
/frontend src/pages/ParcelManagement/index.tsx
/frontend:distill src/components/Modal.tsx --type pattern --domain 动效
/frontend:list --domain 动效
```

## Six Domains

- **动效** (Animation): GSAP, transitions, loading, scroll effects
- **布局** (Layout): Responsive grids, sticky, waterfall, masonry
- **功能** (Components): Forms, virtual lists, drag-drop, search
- **项目规范** (Norms): Naming, structure, Git conventions
- **设计主题** (Theming): Colors, typography, dark mode, design tokens
- **技术选型** (Tech): Library comparisons, architecture decisions

## Auto-Trigger

This skill auto-activates when your message contains frontend intent:
- "做动画", "实现列表", "加暗色模式" → triggers `/frontend <需求>`
- `src/pages/*.tsx`, `components/*.vue` → triggers `/frontend <路径>`

See `frontend/SKILL.md` for full documentation.
