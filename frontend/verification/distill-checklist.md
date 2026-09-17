# /frontend:distill 蒸馏后核对清单

> **用途**：`/frontend:distill` 完成后必须按本清单逐项核对。任何一项未通过 → 不得报告"蒸馏成功"，必须补做或报告证据缺口。
> **执行时机**：每次 distill 命令落地后立即执行，独立于 `verification/knowledge-quality-checklist.md`（准入门槛）和 `verification/index-sync-checklist.md`（CI 期校验）。

---

## 1. 文件落盘核对

- [ ] 目标文件实际存在于磁盘（`ls knowledge/<域>/...` 或 `Get-Item` 验证）
- [ ] 文件命名遵循 `{域}-{主题}-{修饰}.md`（page-layout 例外，见 §5）
- [ ] 文件已写入 frontmatter：`title`、`description`、`domain`、`type`、`source_scope`、`observed_platforms`、`confidence`
- [ ] 文件路径与 `--domain` 一致（`--domain 动效` 必须落到 `knowledge/动效/...`）
- [ ] 若 `--type page-layout`，必须使用 `templates/page-layout-template.md`，不得使用通用模板
- [ ] 父目录已创建；子目录结构与域索引声明的 `目录结构` 段对齐

## 2. 域索引同步核对

- [ ] 对应域索引 `目录结构` 段已追加新文件条目
- [ ] 新文件条目包含：文件名、一句话用途
- [ ] `常见场景速查` 表若适用已追加对应行
- [ ] 域索引 `最后更新` 日期已刷新
- [ ] 若 `--type page-layout`，必须额外在 布局域索引「已登记页面模式」段登记
- [ ] 域索引的 `目录结构` 段不允许遗留占位/虚构条目

## 3. 多层检索索引同步核对

- [ ] L1-精确索引追加一行：名称、文件名、域、精确关键词数组、复杂度
- [ ] L2-关键词索引追加条目：关键词、同义词、语义变体、对应知识
- [ ] L3-标签索引追加标签（如 `gsap`、`gis`、`arcgis`、`leaflet`、`excel-export`、`uniapp` 等）
- [ ] L4-场景索引追加场景行（仅当知识服务具体场景时）
- [ ] 若 `--type page-layout`，必须额外追加 L1/L2 的 `page-layout-pattern` 类型条目，且 32 条上限尚未触达
- [ ] 四层索引中的 `relative_path` 与磁盘一致，路径从 `knowledge/` 起算
- [ ] 四层索引中的 `knowledge_id`、`display_name` 不重复

## 4. 关键词与召回核对

- [ ] 关键词包含：技术栈名（gsap/leaflet/arcgis/react/vue）、功能短语、语义变体、口语表达
- [ ] 关键词与 L2-关键词索引不冲突（不重复登记同义词组）
- [ ] 执行 `/frontend <主关键词>` 自检索（需求描述分支）必须命中
- [ ] 执行 `/frontend <页面任务表达>` 模拟查询（页面路径分支）必须召回该知识
- [ ] 不得在 L1/L2 中手工创建未蒸馏的"占位关键词"

## 5. page-layout 特殊核对

- [ ] `--domain` 强制为 `布局`；若提供其他值必须拒绝并提示
- [ ] `--platform` 必填且取值为 `web` / `mobile` / `responsive` 之一
- [ ] 文件命名遵循 `[页面任务]-[平台].md`（不使用 `{域}-{主题}-{修饰}.md`）
- [ ] 文件路径落到 `knowledge/布局/页面模式/`
- [ ] 已写入：`page_evidence`、`layout_regions`、`responsive_rules`、`source_files`
- [ ] `confidence` 必须是 `high`/`medium`/`low`；单样本不得标 `high`
- [ ] 已显式记录 `source_scope` 与 `observed_platforms`
- [ ] 已执行匹配测试：用页面任务口语表达检索，确认召回

## 6. 阻断条件

出现以下任一情况 → 默认不报告蒸馏成功，必须补做或显式记录证据缺口：

- 目标文件未实际写入
- 至少一个索引层未同步
- 关键词无法让 `/frontend` 的任一分支召回
- page-layout 缺少 `--platform` 或 `--domain ≠ 布局`
- 知识文件与现有文件同名但未走合并流程
- 知识文件内容主体来自推测而非代码事实
- 知识文件触发 `.env*` / 密钥 / 凭据检测

---

*最后更新: 2026-09*