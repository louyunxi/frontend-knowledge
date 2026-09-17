---
title: "ECharts 2D 三层光环透明叠加饼图（opacity 叠加 + scaleSize 强调）"
description: "3 个 pie series 用 opacity 透明度叠加形成光晕效果 + emphasis.scaleSize 放大选中扇形，强调交互"
tags: ["echarts", "2d", "pie", "光晕", "opacity", "scaleSize", "三层叠加", "透明叠加", "emphasis"]
echarts_version: "5.6.0"
echarts_gl_version: null
complexity: ⭐⭐⭐
domain: feature
source_scope: "assetManage/MarketOperations/dialogTab1"
---

# ECharts 2D - 三层光环透明叠加饼图

## 概述

**三层光环透明叠加饼图**是 3 个 `pie` series 通过不同 `opacity` 透明度叠加出"光晕"质感，外圈大且低透明、中圈略小、内圈透明但 `emphasis.scaleSize` 用于交互强调。视觉上像发光环，区别于传统三层环的"同心圆"形态。

**适用场景**：
- 需要光晕发光质感的饼图（暗黑科技风）
- 需要 hover 强调放大的交互（`scaleSize: 22`）
- 数据较多（每个扇形 hover 时突出显示）

**关键特征**：
- ✅ 3 个 series，**不是同心环**（radius 范围不同，但内圈 0-85%）
- ✅ 内圈完全透明（`opacity: 0`），仅用于承载 hover 交互
- ✅ `emphasis.scaleSize: 22` 控制扇形 hover 放大距离
- ✅ 共享同一份 data

---

## 核心配置

### 标准模板

```js
const colors = ['#00F0FF', '#ECC612', '#8A61FE', '#78EC5E', '#6F83A8', '#E64919', '#00FFAA'];

const option = {
  color: colors,
  tooltip: {
    trigger: 'item',
    position: 'inside',
    formatter: (params) => `${params.marker} <span>${params.name}：${params.value}</span>万元`,
  },
  series: [
    // 底层环：大半径 + 低透明（光晕底层）
    {
      name: 'bottomPie',
      type: 'pie',
      radius: [0, '85%'],
      data: chartData,
      minAngle: 5,
      itemStyle: { opacity: 0.3 },      // 低透明，形成底层光晕
      label: { show: false },
      labelLine: { show: false },
    },
    // 中层环：中等半径 + 完全不透明（实色环）
    {
      name: 'middlePie',
      type: 'pie',
      radius: [0, '72%'],                // 比底层小，覆盖内部
      data: chartData,
      minAngle: 5,
      label: { show: false },
      labelLine: { show: false },
    },
    // 顶层环：完全透明 + 强调放大（hover 交互载体）
    {
      name: 'topPie',
      type: 'pie',
      radius: [0, '85%'],
      data: chartData,
      minAngle: 5,
      itemStyle: { opacity: 0 },         // 完全透明，不可见
      label: { show: false },
      labelLine: { show: false },
      emphasis: {
        label: { show: false },
        itemStyle: {
          color: 'inherit',              // 保持原色
          opacity: 0.3,                  // hover 时显示半透明光晕
        },
        scale: true,
        scaleSize: 22,                   // hover 放大距离（关键参数）
      },
    },
  ],
};
```

---

## 关键参数说明

| 参数 | 必填 | 说明 |
|------|------|------|
| `radius: [0, '85%']` | ✅ | 用 `[0, 'xx%']` 而非 `['85%', '100%']`，从圆心开始的实心环 |
| `itemStyle.opacity` | ✅ | 底层 `0.3` 形成光晕、中层 `1` 实色、顶层 `0` 透明 |
| `emphasis.scaleSize` | 关键 | 控制扇形 hover 放大半径，**典型值 22**（约 22 像素） |
| `emphasis.itemStyle.color: 'inherit'` | ✅ | hover 保持原色，不变蓝 |
| `minAngle: 5` | ✅ | 保证小扇形仍能渲染 |

---

## 引用源文件

| 业务模块 | 源文件 |
|---------|--------|
| 资产管理 - 市场运营 | [MarketOperations/dialogTab1.vue](file:///D:/external-projects/digital-supply-front-end/apps/pc-data-vision/src/views/assetManage/newModules/MarketOperations/dialogTab1.vue) |

---

## 注意事项

> ⚠️ **字体颜色只是默认值**：颜色值仅为项目示例，需根据主题调整。

1. **三层环的 opacity 关系**：底层 `0.3`（光晕） → 中层 `1`（实色） → 顶层 `0`（透明 + 交互）。
2. **顶层不渲染但保留交互**：内圈完全透明是设计意图——只有 hover 时才显示 `opacity: 0.3` 的放大扇形。
3. **scaleSize 数值调整**：值越大 hover 扇形放大越多。建议 15-30 之间调整。
4. **radius 从 0 开始**：用 `[0, '85%']` 而非 `['85%', '100%']`，因为需要从圆心绘制的实心环。
5. **避免数据 > 7 个**：扇形太多时 opacity 叠加效果会混乱，建议限制在 5-7 个数据点。

---

## 变体提示

- **3 个 series 同心环**（不是透明叠加），参见 [ECharts-2D-三层环饼图.md](file:///e:/AI/front-knowledge/.trae/skills/frontend-knowledge/knowledge/功能/ECharts/ECharts-2D-三层环饼图.md)。
- **传统 2 层环 + 渐变**，参见 [ECharts-2D-双层环饼图.md](file:///e:/AI/front-knowledge/.trae/skills/frontend-knowledge/knowledge/功能/ECharts/ECharts-2D-双层环饼图.md)。