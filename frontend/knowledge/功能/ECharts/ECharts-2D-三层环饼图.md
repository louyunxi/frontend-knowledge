---
title: "ECharts 2D 三层环饼图（外/中/内三层独立 series）"
description: "3 个 pie series 不同外内径叠加形成的三层同心圆环（97-100% / 85-95% / 72-85%），使用 LinearGradient 与空数据兜底"
tags: ["echarts", "2d", "pie", "三层环", "同心圆", "concentric", "ring-pie", "empty-data-fallback"]
echarts_version: "5.6.0"
echarts_gl_version: null
complexity: ⭐⭐
domain: feature
source_scope: "assetManage/IndHousing"
---

# ECharts 2D - 三层环饼图

## 概述

**三层环饼图**由 3 个 `pie` series 叠加而成，每个 series 有不同的 `radius` 范围（如外环 97-100%、中环 85-95%、内环 72-85%），形成三层独立可辨的同心圆环。每个 series 共享同一份 `data`。

**适用场景**：
- 大屏关键指标的多层级展示（核心数据 + 二级数据 + 辅助数据）
- 用三层厚度差异形成视觉层级（外环粗、中环细、内环细）
- 需要空数据兜底（数据为空时显示半透明占位环）

**关键特征**：
- ✅ **3 个 pie series**（不是 2 个）
- ✅ **radius 用百分比**（如 `['97%', '100%']`），根据容器自适应
- ✅ **共享同一份 data**（不分裂数据源）
- ✅ **空数据兜底**：`value: 1, name: 'empty', itemStyle: { color: 'rgba(27, 215, 240, 0.40)' }`
- ❌ **不依赖 setPieRadius**（用百分比自动适应容器）

---

## 核心配置

### 标准模板

```js
import * as echarts from 'echarts/core';

const data = [
  { name: '类别A', value: 35 },
  { name: '类别B', value: 25 },
  { name: '类别C', value: 20 },
  { name: '类别D', value: 20 },
];

// 空数据兜底
const validCount = data.filter(d => d.value > 0).length;
const chartData = validCount > 0 ? data : [{
  value: 1,
  name: 'empty',
  tooltip: { show: false },
  itemStyle: { color: 'rgba(27, 215, 240, 0.40)' },
}];

const option = {
  tooltip: { trigger: 'item', position: 'inside' },
  series: [
    // 外环：最细、最亮
    {
      name: 'outsidePie',
      type: 'pie',
      radius: ['97%', '100%'],
      data: chartData,
      avoidLabelOverlap: false,
      padAngle: validCount > 1 ? 2 : 0,
      minAngle: validCount > 1 ? 5 : 0,
      label: { show: false, position: 'inside' },
      emphasis: { label: { show: false }, itemStyle: { color: 'inherit' }, scale: false },
      labelLine: { show: false },
    },
    // 中环：粗、亮
    {
      name: 'middlePie',
      type: 'pie',
      radius: ['85%', '95%'],
      data: chartData,
      avoidLabelOverlap: false,
      padAngle: validCount > 1 ? 2 : 0,
      minAngle: validCount > 1 ? 5 : 0,
      label: { show: false, position: 'inside' },
      emphasis: { label: { show: false }, itemStyle: { color: 'inherit' }, scale: false },
      labelLine: { show: false },
    },
    // 内环：粗、半透明
    {
      name: 'innerPie',
      type: 'pie',
      radius: ['72%', '85%'],
      data: chartData,
      itemStyle: { opacity: 0.8 },     // 内环半透明，与中环形成层次
      padAngle: validCount > 1 ? 2 : 0,
      minAngle: validCount > 1 ? 5 : 0,
      label: { show: false, position: 'inside' },
      emphasis: { label: { show: false }, itemStyle: { color: 'inherit' }, scale: false },
      labelLine: { show: false },
    },
  ],
};
```

---

## 关键参数说明

| 参数 | 必填 | 说明 |
|------|------|------|
| `radius` | ✅ | 三层用百分比，外环最细（`['97%', '100%']`，3% 厚度），中环 + 内环各 10-13% 厚度 |
| `data` | ✅ | 三层共享一份 data，避免数据漂移 |
| `avoidLabelOverlap: false` | ✅ | 关闭标签避让，避免多层环的 label 互相挤压 |
| `emphasis.itemStyle.color: 'inherit'` | ✅ | 高亮时颜色保持不变（不变成默认蓝） |
| `emphasis.scale: false` | ✅ | 关闭高亮放大，避免三层环错位 |
| 内环 `opacity: 0.8` | ✅ | 内环降低透明度，与中环形成层次感 |

---

## 引用源文件

| 业务模块 | 源文件 |
|---------|--------|
| 资产管理 - 工业用地 | [IndHousing/index.vue](file:///D:/external-projects/digital-supply-front-end/apps/pc-data-vision/src/views/assetManage/newModules/IndHousing/index.vue) |

---

## 注意事项

> ⚠️ **字体颜色只是默认值**：颜色值（`rgba(27, 215, 240, 0.40)` 等）仅为项目默认主题色示例。

1. **三层共享同一份 data**：避免每层数据不一致导致视觉错位。
2. **百分比 radius 比数值 radius 更适合此类**：因为容器尺寸不确定（如响应式布局），百分比自动适应。
3. **空数据兜底**：必须处理 `data.length === 0` 的情况，否则三层环会消失（无视觉效果）。
4. **minAngle 处理**：仅 1 个数据时设 `0`，避免只有 5 度时其他空间显得空旷。
5. **内环 opacity 影响叠加效果**：内环 `opacity: 0.8` 会让下方背景透出，需测试整体视觉效果。

---

## 变体提示

- **2 个 series 的双层环**，参见 [ECharts-2D-双层环饼图.md](file:///e:/AI/front-knowledge/.trae/skills/frontend-knowledge/knowledge/功能/ECharts/ECharts-2D-双层环饼图.md)。
- **3 个 series 但用半透明叠加 + scaleSize 强调**（不是同心环），参见 [ECharts-2D-三层光环透明叠加饼图.md](file:///e:/AI/front-knowledge/.trae/skills/frontend-knowledge/knowledge/功能/ECharts/ECharts-2D-三层光环透明叠加饼图.md)。
- **单层简单饼图**（无渐变），参见 [ECharts-2D-单层简单饼图.md](file:///e:/AI/front-knowledge/.trae/skills/frontend-knowledge/knowledge/功能/ECharts/ECharts-2D-单层简单饼图.md)。