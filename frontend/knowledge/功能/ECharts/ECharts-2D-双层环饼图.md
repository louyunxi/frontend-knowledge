---
title: "ECharts 2D 双层环饼图（带 LinearGradient 与 setPieRadius）"
description: "2 层 ring pie 环形饼图，每个 series 配 LinearGradient 渐变，支持 setPieRadius 动态计算半径，是项目里使用频率最高的饼图形态"
tags: ["echarts", "2d", "pie", "环饼图", "双层环", "linear-gradient", "setPieRadius", "padAngle", "borderRadius"]
echarts_version: "5.6.0"
echarts_gl_version: null
complexity: ⭐⭐
domain: feature
source_scope: "pc-data-vision 多模块"
---

# ECharts 2D - 双层环饼图（LinearGradient + setPieRadius）

## 概述

**2D 双层环饼图**是该项目最常见的 ECharts 形态：2 个 `pie` series 嵌套成内/外两环，每个扇区用 `LinearGradient` 做颜色渐变，并通过 `setPieRadius()` 根据容器尺寸动态计算环半径与环间距。

**适用场景**：
- 多维度数据占比对比（外环 = 总览，内环 = 细节）
- 大屏展示（dark theme + 半透明 tooltip）
- 占比总和 = 100% 的数据（适合饼图 + 内层叠加）

**关键特征**（与同类区分）：
- ✅ 2 个 `pie` series（同 data），radius 用数值（如 `[80, 100]`）
- ✅ `padAngle + borderRadius` 形成扇形间缝隙
- ✅ `color` 为 `LinearGradient` 数组（不是普通颜色字符串）
- ✅ `setPieRadius()` 根据容器尺寸动态更新 radius
- ❌ 不是百分比 radius（如 `['90%', '100%']`）
- ❌ 没有 3D 效果（不需要 echarts-gl）

---

## 核心配置

### 1. 标准模板（推荐）

```js
import * as echarts from 'echarts/core';

const colors = [
  ['#1BD7F0', '#3039E9'],  // [起始色, 结束色]
  ['#ECC713', '#FB8C05'],
  ['#8B62FF', '#5B3AFE'],
];

const option = {
  tooltip: {
    trigger: 'item',
    position: 'inside',                  // 大屏必用：tooltip 显示在饼图内部
    borderWidth: 0,
    backgroundColor: 'rgba(0,0,0,.85)',
    textStyle: { color: '#FFF' },
  },
  series: [
    {
      type: 'pie',
      padAngle: 2,                        // 扇形间隔（角度）
      minAngle: 5,                        // 最小扇形角度（小于则合并）
      itemStyle: { borderRadius: [5, 5, 0, 0], opacity: 0.8 },
      radius: ['firstOutsideRadius', 'firstInsideRadius'],   // 占位，运行时计算
      label: { show: false, position: 'inside' },
      emphasis: {
        label: { show: false },
        itemStyle: { color: 'inherit' },
        scale: false,                     // 不放大
      },
      labelLine: { show: false },
      data: pieData,
    },
    {
      type: 'pie',
      padAngle: 2,
      minAngle: 5,
      itemStyle: { borderRadius: [0, 0, 5, 5] },
      radius: ['secondOutsideRadius', 'secondInsideRadius'],
      label: { show: false, position: 'inside' },
      emphasis: { label: { show: false }, scale: false },
      labelLine: { show: false },
      data: pieData,                       // 与外环同一份数据
    },
  ],
};
```

### 2. setPieRadius 动态计算（核心模式）

```js
function setPieRadius() {
  const { offsetHeight, offsetWidth } = echartsBoxRef.value;
  const height = Math.min(offsetHeight, offsetWidth);   // 取短边，避免溢出
  // 减号项 = (外边距) + (环间距) + (内边距)
  const firstOutsideRadius = height / 2 - 5 - 20 - 20;
  const firstInsideRadius  = height / 2 - 5 - 30 - 20;
  const secondOutsideRadius = height / 2 - 5 - 20 - 0.5 - 20;
  const secondInsideRadius  = height / 2 - 5 - 10 - 20;

  if (eCharts.value) {
    eCharts.value.setOption({
      series: [
        { radius: [firstOutsideRadius, firstInsideRadius] },
        { radius: [secondOutsideRadius, secondInsideRadius] },
      ],
    });
  }
}

window.addEventListener('resize', setPieRadius);
```

### 3. setPieData 应用 LinearGradient（核心模式）

```js
function setPieData() {
  const pieColors = [];
  const pieData = itemData.value.echartsData.filter((item, index) => {
    if (item.value !== 0) {
      pieColors.push(colors[index % colors.length]);
    }
    return item.value;       // 过滤掉 value=0 的扇形
  });

  eCharts.value.setOption({
    color: pieData.map((item, index) => ({
      type: 'linear', x: 0, y: 0, x2: 0, y2: 1,    // 垂直渐变
      colorStops: [
        { offset: 0, color: pieColors[index][0] },
        { offset: 1, color: pieColors[index][1] },
      ],
      global: false,
    })),
    series: [
      { padAngle: pieData.length === 1 ? 0 : 2, data: pieData },
      { padAngle: pieData.length === 1 ? 0 : 2, data: pieData },
    ],
  });
}
```

---

## 关键参数说明

| 参数 | 必填 | 说明 |
|------|------|------|
| `padAngle` | ✅ | 扇形间隔角度。`data.length === 1` 时设为 `0`（否则空隙难看） |
| `minAngle` | ✅ | 最小扇形角度，过小则合并到相邻扇形 |
| `borderRadius` | ✅ | 扇形圆角（外环用 `[5,5,0,0]`，内环用 `[0,0,5,5]`，形成对称圆角） |
| `opacity` | 外环 ✅ | 外环建议 `0.8` 形成叠加发光效果 |
| `position: 'inside'` | 大屏 ✅ | tooltip 显示在饼图内部，避免遮挡 |
| `labelLine.show: false` | ✅ | 关闭引导线，否则会有引导线伸出 |

---

## 引用源文件

| 业务模块 | 源文件 |
|---------|--------|
| 首页预警 | [module5.vue](file:///D:/external-projects/digital-supply-front-end/apps/pc-data-vision/src/views/home/components/module5.vue) |
| 首页资产 | [module7.vue](file:///D:/external-projects/digital-supply-front-end/apps/pc-data-vision/src/views/home/components/module7.vue) |
| 首页督办 | [module8.vue](file:///D:/external-projects/digital-supply-front-end/apps/pc-data-vision/src/views/home/components/module8.vue) |
| 公共组件 | [PieChartA.vue](file:///D:/external-projects/digital-supply-front-end/apps/pc-data-vision/src/components/ZaCharts/PieChartA.vue) |
| 农资资金 Module1 | [Module1.vue](file:///D:/external-projects/digital-supply-front-end/apps/pc-data-vision/src/views/AgriculturalFunds/components/Module1.vue) |
| 商贸流通 Module1 | [Module1.vue](file:///D:/external-projects/digital-supply-front-end/apps/pc-data-vision/src/views/tradeCirculation/components/Module1.vue) |
| 商贸流通 Module6 | [Module6.vue](file:///D:/external-projects/digital-supply-front-end/apps/pc-data-vision/src/views/tradeCirculation/components/Module6.vue) |

---

## 注意事项

> ⚠️ **字体颜色只是默认值**：本文档颜色值（`#1BD7F0`、`#ECC713` 等）是该项目 dark theme 默认值，实际应用需根据业务主题色调整。

1. **过滤 0 值**：`filter(item => item.value !== 0)`，否则空扇形会渲染圆环缺口。
2. **唯一数据时关闭 padAngle**：只有一个数据时设置 `padAngle: 0`，否则圆环有奇怪空隙。
3. **setPieRadius 必跑**：必须在 `onMounted` 后用 `nextTick` 等待 DOM 计算容器尺寸，再调用。
4. **数据更新 vs radius 更新分离**：radius 走 `setOption({ series: [{ radius: [...] }] })`；data 走 `setOption({ series: [{ data: [...] }] })`，可独立刷新。
5. **LinearGradient `global: false`**：必须设置 `false`，否则渐变按全局坐标系计算（多个扇形会渐变颜色错乱）。

---

## 变体提示

- **如果数据需要展示部分占比**，用 `data.filter(item => item.value > 0)` 并保留其他值用 `name: '其他'`。
- **如果是 3 个 series（更复杂的多层环）**，参见 [ECharts-2D-三层环饼图.md](file:///e:/AI/front-knowledge/.trae/skills/frontend-knowledge/knowledge/功能/ECharts/ECharts-2D-三层环饼图.md)。
- **如果是单层饼图**，参见 [ECharts-2D-单层简单饼图.md](file:///e:/AI/front-knowledge/.trae/skills/frontend-knowledge/knowledge/功能/ECharts/ECharts-2D-单层简单饼图.md)。