---
title: "ECharts 2D 垂直渐变柱状图（LinearGradient top-to-bottom）"
description: "单一 bar series 用 LinearGradient 从上到下渐变，可选 label 显示顶部数值"
tags: ["echarts", "2d", "bar", "柱状图", "垂直", "线性渐变", "linear-gradient", "label-top"]
echarts_version: "5.6.0"
echarts_gl_version: null
complexity: ⭐
domain: feature
source_scope: "BarBoxA, BarBoxB, OtherBusinesses, moduleDialog1"
---

# ECharts 2D - 垂直渐变柱状图

## 概述

**垂直渐变柱状图**是单 series `bar` 类型，`itemStyle.color` 用 `LinearGradient` 从顶部到底部渐变（如 `#00D1FF` → `#00A3FF`）。可选择性显示顶部 `label` 数值。

**适用场景**：
- 单一指标柱状对比（如营收、产量）
- 大屏 dark theme 场景（暗底 + 亮色渐变柱）
- 需要顶部数值标签（`label.position: 'top'`）

**关键特征**：
- ✅ 单 `bar` series（多数据点）
- ✅ `itemStyle.color` 为 LinearGradient 对象（垂直方向）
- ✅ 可选 `label.position: 'top'` 显示柱顶数值
- ✅ `emphasis.itemStyle.shadowBlur: 0` 关闭高亮阴影（避免视觉噪音）

---

## 核心配置

### 1. 基础渐变柱（无 label）

```js
import * as echarts from 'echarts/core';

const option = {
  ...defaultOption(),
  series: [{
    name: '营收',
    type: 'bar',
    data: [28.6, 38.86, 34.06, 124],
    itemStyle: {
      color: {
        type: 'linear',
        x: 0, y: 0, x2: 0, y2: 1,         // 垂直渐变（y2=1 从顶到底）
        colorStops: [
          { offset: 1, color: '#00A3FF' },  // 底部
          { offset: 0, color: '#00D1FF' },  // 顶部
        ],
      },
      shadowColor: 'transparent',          // 关闭阴影
    },
    barCategoryGap: 12,                    // 类目间柱间距
    emphasis: {
      itemStyle: {
        shadowBlur: 0,
        shadowColor: 'transparent',
        borderWidth: 0,
        opacity: 1,
      },
    },
  }],
};
```

### 2. 带顶部 label 的渐变柱

```js
const option = {
  series: [{
    name: '营收',
    type: 'bar',
    label: { show: true, position: 'top', textStyle: { color: '#fff' } },
    data: [],
    itemStyle: {
      color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
        { offset: 1, color: '#00A3FF' },
        { offset: 0, color: '#00D1FF' },
      ]),
    },
    barWidth: '20%',                       // 柱宽
    barGap: '30%',                         // 柱间隙
    emphasis: {
      itemStyle: {
        shadowBlur: 0,
        shadowColor: 'transparent',
        borderWidth: 0,
        opacity: 1,
      },
    },
  }],
};
```

---

## 关键参数说明

| 参数 | 必填 | 说明 |
|------|------|------|
| `itemStyle.color` | ✅ | 必须是 `LinearGradient` 对象，**不是字符串** |
| `LinearGradient(x,y,x2,y2)` | ✅ | 垂直渐变设 `y2=1`，水平渐变设 `x2=1` |
| `colorStops` | ✅ | `offset` 从 0 到 1，控制颜色位置 |
| `label.position: 'top'` | 可选 | 显示柱顶数值（适合数值对比） |
| `barWidth: '20%'` | 可选 | 柱宽占类目宽度的百分比 |
| `barGap: '30%'` | 可选 | 不同 series 间柱间距（单 series 无效） |
| `emphasis.shadowBlur: 0` | ✅ | 关闭高亮阴影（dark theme 下视觉干净） |

---

## 引用源文件

| 业务模块 | 源文件 |
|---------|--------|
| 公共组件 | [BarBoxA.vue](file:///D:/external-projects/digital-supply-front-end/apps/pc-data-vision/src/components/ZaCharts/BarBoxA.vue) |
| 公共组件 | [BarBoxB.vue](file:///D:/external-projects/digital-supply-front-end/apps/pc-data-vision/src/components/ZaCharts/BarBoxB.vue) |
| 资产管理 - 其他业务 | [OtherBusinesses/index.vue](file:///D:/external-projects/digital-supply-front-end/apps/pc-data-vision/src/views/assetManage/newModules/OtherBusinesses/index.vue) |
| 商贸流通弹窗 | [moduleDialog1.vue](file:///D:/external-projects/digital-supply-front-end/apps/pc-data-vision/src/views/tradeCirculation/components/dialogItem/moduleDialog1.vue) |

---

## 注意事项

> ⚠️ **字体颜色只是默认值**：颜色值仅为项目示例，需根据业务主题调整。

1. **LinearGradient 方向**：
   - 垂直渐变：`y2: 1`（从上到下）
   - 水平渐变：`x2: 1`（从左到右）
2. **阴影关闭**：dark theme 下默认阴影是黑色，会显得很脏，必须关闭（`shadowBlur: 0`、`shadowColor: 'transparent'`）。
3. **barGap 单 series 无效**：`barGap` 仅在多 series 时生效。
4. **如果使用 `new echarts.graphic.LinearGradient`**：注意这是 ECharts 的 LinearGradient 类，**和上面 `type: 'linear'` 对象写法等价**，项目里两种都有。
5. **如果需要横向柱**：交换 `xAxis/yAxis` 的 `type: 'value'/'category'`，并把 `xAxis` 放底部。

---

## 变体提示

- **多 series 单色柱**（不同颜色，无渐变），参见 [ECharts-2D-垂直单色多系列柱状图.md](file:///e:/AI/front-knowledge/.trae/skills/frontend-knowledge/knowledge/功能/ECharts/ECharts-2D-垂直单色多系列柱状图.md)。
- **横向柱 + pictorialBar 叠加发光**，参见 [ECharts-2D-横向渐变柱pictorialBar叠加.md](file:///e:/AI/front-knowledge/.trae/skills/frontend-knowledge/knowledge/功能/ECharts/ECharts-2D-横向渐变柱pictorialBar叠加.md)。
- **横向柱 + image:// 符号**，参见 [ECharts-2D-横向渐变柱image符号.md](file:///e:/AI/front-knowledge/.trae/skills/frontend-knowledge/knowledge/功能/ECharts/ECharts-2D-横向渐变柱image符号.md)。