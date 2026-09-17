---
title: "ECharts 2D 单层简单饼图（无渐变 + 百分比 radius）"
description: "2 个 pie series 简化版环饼图，无 LinearGradient，使用 color 数组 + 百分比 radius，无 setPieRadius"
tags: ["echarts", "2d", "pie", "单层", "简单饼图", "百分比radius", "color-array"]
echarts_version: "5.6.0"
echarts_gl_version: null
complexity: ⭐
domain: feature
source_scope: "assetManage/BusinessDistribution"
---

# ECharts 2D - 单层简单饼图

## 概述

**单层简单饼图**是最简单的双层环形态：2 个 `pie` series，`radius` 用百分比（如 `['90%', '100%']`），无 LinearGradient 渐变、无 `setPieRadius` 动态计算、无 `borderRadius`。每个扇区用单一颜色填充。

**适用场景**：
- 简洁风格的占比展示
- 不需要强烈视觉冲击的场景
- 颜色已通过 `color: colorList` 数组定义好
- 容器尺寸不需要精确控制

**关键特征**：
- ✅ 2 个 `pie` series
- ✅ **radius 用百分比**（如 `['90%', '100%']`），无需 setPieRadius
- ✅ **没有 LinearGradient**，用 `color: colorList` 字符串数组
- ✅ **没有 borderRadius**（扇形无圆角）
- ✅ **没有 padAngle**（扇形之间无缝）
- ❌ 没有动态半径计算

---

## 核心配置

### 标准模板

```js
const colorList = ['#00F0FF', '#ECC612', '#8A61FE', '#78EC5E'];

const dataList = [
  { name: '类别A', value: 35 },
  { name: '类别B', value: 25 },
  { name: '类别C', value: 20 },
  { name: '类别D', value: 20 },
];

const option = {
  color: colorList,                  // 直接用字符串数组（不是 gradient 对象）
  tooltip: {
    trigger: 'item',
    position: 'inside',
  },
  series: [
    // 外环：细、亮
    {
      name: 'outsidePie',
      type: 'pie',
      radius: ['90%', '100%'],         // 10% 厚度
      minAngle: 5,
      label: { show: false, position: 'inside' },
      data: dataList,
      emphasis: { label: { show: false }, itemStyle: { color: 'inherit' }, scale: false },
      labelLine: { show: false },
    },
    // 内环：粗、半透明
    {
      name: 'insidePie',
      type: 'pie',
      radius: ['80%', '95%'],          // 15% 厚度
      minAngle: 5,
      data: dataList,
      itemStyle: { opacity: 0.7 },     // 内环半透明
      label: { show: false, position: 'inside' },
      emphasis: { label: { show: false }, scale: false },
      labelLine: { show: false },
    },
  ],
};
```

---

## 关键参数说明

| 参数 | 必填 | 说明 |
|------|------|------|
| `color: colorList` | ✅ | 直接传字符串颜色数组，**不是 LinearGradient 对象** |
| `radius` 百分比 | ✅ | `['90%', '100%']` 这种，根据容器自适应 |
| `minAngle: 5` | ✅ | 最小扇形角度 |
| 内环 `opacity: 0.7` | ✅ | 内环降低透明度形成层次 |
| `emphasis.scale: false` | ✅ | 关闭高亮放大 |

---

## 引用源文件

| 业务模块 | 源文件 |
|---------|--------|
| 资产管理 - 业态分布 | [BusinessDistribution/index.vue](file:///D:/external-projects/digital-supply-front-end/apps/pc-data-vision/src/views/assetManage/newModules/BusinessDistribution/index.vue) |

---

## 注意事项

> ⚠️ **字体颜色只是默认值**：颜色值仅为项目示例。

1. **没有 setPieRadius**：因为 radius 是百分比，自动根据容器计算，不需要动态调整。
2. **没有 borderRadius**：扇形保持原始形状（直角），区别于 [ECharts-2D-双层环饼图.md](file:///e:/AI/front-knowledge/.trae/skills/frontend-knowledge/knowledge/功能/ECharts/ECharts-2D-双层环饼图.md)。
3. **没有 padAngle**：扇形之间无缝（连成一片），区别于渐变版。
4. **color 字段**：传字符串数组即可，不需要 `colorStops`/`global` 等渐变配置。

---

## 变体提示

- **需要 LinearGradient 渐变**，参见 [ECharts-2D-双层环饼图.md](file:///e:/AI/front-knowledge/.trae/skills/frontend-knowledge/knowledge/功能/ECharts/ECharts-2D-双层环饼图.md)。
- **需要 3 层环**，参见 [ECharts-2D-三层环饼图.md](file:///e:/AI/front-knowledge/.trae/skills/frontend-knowledge/knowledge/功能/ECharts/ECharts-2D-三层环饼图.md)。