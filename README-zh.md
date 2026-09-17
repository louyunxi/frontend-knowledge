# Frontend Knowledge Skill

跨平台前端技术经验知识库，**同时安装到 TRAE、Claude Code 和 DeepSeek Harness** 三个工具。

包含 6 大知识域（动效、布局、功能、项目规范、设计主题、技术选型），50+ 精选模式，五层召回索引。

---

## 功能特性

- **知识库**：6 大知识域，50+ 模式，覆盖 UI 开发、动画、布局、组件模式、设计令牌、技术选型
- **五层召回**：L1 精确匹配 → L2 语义匹配 → L3 标签匹配 → L4 跨域组合 → L5 场景推荐
- **双分支命令**：`/frontend <需求>` 搜索知识，`/frontend <路径>` 分析页面
- **知识蒸馏**：`/frontend:distill` 从代码中提取技术模式入库
- **自动触发**：输入前端意图时自动激活
- **跨工具兼容**：同一套 Skill 内容，安装到三种工具

---

## 安装

### Windows (PowerShell)

```powershell
# 用户级（所有工具）
.\install.ps1 -Tool all -Scope user

# 单个工具
.\install.ps1 -Tool trae -Scope user        # TRAE
.\install.ps1 -Tool claude -Scope user     # Claude Code
.\install.ps1 -Tool dsh -Scope user        # DeepSeek Harness

# 项目级（指定项目目录）
.\install.ps1 -Tool all -Scope project -ProjectPath "E:\AI\my-project"
```

### macOS / Linux (Bash)

```bash
# 待实现 (TBD)
# chmod +x install.sh && ./install.sh -t all -s user
```

### 手动安装

| 工具 | 用户级路径 | 项目级路径 |
|------|-----------|-----------|
| **TRAE** | `~/.trae/skills/frontend/` | `<项目>/.trae/skills/frontend/` |
| **Claude Code** | `~/.claude/skills/frontend/` | `<项目>/.claude/skills/frontend/` |
| **DeepSeek Harness** | `~/.dsh/skills/frontend/` | `<项目>/.dsh/skills/frontend/` |

Claude Code 项目级安装还需将根目录 `SKILL.md` 复制为项目根目录的 `CLAUDE.md`。

---

## 命令

### /frontend — 主命令（双分支）

**分支一：需求描述** — 搜索知识库，生成实现提示词：

```bash
/frontend 实现一个带入场动画的筛选表格
/frontend 虚拟列表怎么实现
/frontend 暗色模式怎么做
```

**分支二：页面路径** — 读取页面文件，分析上下文，生成改造提示词：

```bash
/frontend src/pages/ParcelManagement/index.tsx
/frontend src/pages/CustomerList/index.tsx
```

### /frontend:distill — 知识蒸馏

```bash
/frontend:distill src/components/VirtualList.tsx --type pattern --domain 功能
/frontend:distill --type best --domain 动效 --name "GSAP性能优化"
/frontend:distill --type pitfall --domain 动效 --name "动画卡顿问题"
/frontend:distill src/pages/Orders --type page-layout --domain 布局 --platform web
```

### /frontend:list — 浏览知识

```bash
/frontend:list                      # 列出所有域
/frontend:list --domain 动效        # 列出动效域
/frontend:list --stats             # 显示统计信息
```

---

## 六 大知识域

| 域 | Content | 示例 |
|---|---------|------|
| **动效** | 动画、过渡、GSAP、ScrollTrigger | GSAP 页面过渡、入场动画、骨架屏 |
| **布局** | 响应式栅格、吸顶、定位 | CSS Grid、Flexbox、响应式断点、Sticky 侧边栏 |
| **功能** | 表单、列表、拖拽、搜索 | 虚拟列表、表单验证、无限滚动、拖拽排序 |
| **项目规范** | 命名、结构、Git 规范 | 组件命名、目录结构、提交规范 |
| **设计主题** | 色彩、字体、暗色模式 | 设计令牌系统、60-30-10 配色、暗色模式 |
| **技术选型** | 库对比、架构决策 | Redux vs Zustand、Vite vs Webpack、GSAP vs Framer |

---

## 自动触发

Skill 会根据输入自动激活：

| 类型 | 输入 | 行为 |
|------|------|------|
| **类型 A** | 意图词："做动画"、"实现列表"、"加暗色模式" | 触发 `/frontend <需求>` |
| **类型 B** | 文件路径：`src/pages/*.tsx`、`components/*.vue` | 触发 `/frontend <路径>` |

关闭自动触发：在工具偏好设置中关闭，或在项目配置中加入 `skill.frontend.auto-trigger: false`。

---

## 卸载

```powershell
.\install.ps1 -Tool trae -Scope user -Uninstall
.\install.ps1 -Tool claude -Scope user -Uninstall
.\install.ps1 -Tool dsh -Scope user -Uninstall
```

---

## 目录结构

```
frontend-knowledge/              # GitHub 仓库根
├── SKILL.md                  # Claude Code 项目级入口（复制为 CLAUDE.md 使用）
├── CLAUDE.md                 # 同上（Claude Code 兼容性备用）
├── README.md                  # 英文安装说明
├── README-zh.md              # 本文件
├── install.ps1              # 跨工具安装脚本（PowerShell）
├── install.sh               # 跨工具安装脚本（Bash，待实现）
│
├── frontend/                  # Skill 内容目录（安装此目录）
│   ├── SKILL.md            # 主入口 + 全部命令文档
│   ├── agent.md            # Agent 上下文约束
│   ├── commands/           # 命令详解
│   ├── templates/          # 输出模板
│   ├── verification/       # 质量验证清单
│   └── knowledge/          # 六域知识库 + L1-L5 索引
│
└── .claude-plugin/         # Claude Code 插件元数据
    └── manifest.json
```

---

## 更新日志

| 版本 | 日期 | 变更 |
|------|------|------|
| 2.0 | 2026-09-17 | 跨工具兼容（TRAE + Claude Code + DeepSeek Harness）；合并 `/frontend:knowledge` + `/frontend:analyze` → `/frontend`；五层召回架构（L1-L5）；page-layout 蒸馏类型 |
| 1.0 | 更早 | 初始 frontend-patterns + frontend-distill |

---

*English documentation: [README.md](README.md)*
