---
title: "ECharts 图表自动循环聚焦 tooltip（饼/柱/线通用 + hover 暂停）"
description: "基于 dispatchAction 的 ECharts 图表自动循环高亮 + showTip 模式，setInterval 周期（1.5s）循环聚焦每个数据项，鼠标进入图表时停止循环、downplay 当前高亮、hideTip，鼠标离开时无缝续循环。适用于饼图、柱状图、折线图三种图表类型"
tags: ["echarts", "dispatchAction", "highlight", "downplay", "showTip", "hideTip", "自动循环", "tooltip", "hover暂停", "饼图", "柱状图", "折线图", "showcase-dashboard"]
complexity: ⭐⭐⭐
domain: feature
source_scope: "showcase-dashboard - DroneSurveillance (Module02/05/06)"
---

# ECharts 图表自动循环聚焦 tooltip（饼/柱/线通用 + hover 暂停）

## 概述

**ECharts 自动循环聚焦 tooltip**是 DroneSurveillance 项目里 3 个核心图表（Module02 饼图、Module05 柱图、Module06 线图）共享的"自动演示模式"。通过 `dispatchAction` + `setInterval` 实现**逐项聚焦**（先高亮 + showTip），鼠标进入图表时**立即停止循环**，鼠标离开时**无缝续循环**。

**适用场景**：
- 大屏展示场景下需要"自动 demo 演示"的图表
- 用户不操作时希望图表"自己动起来"的场景
- 任何饼/柱/线/雷达/散点图的通用自动循环高亮

**关键特征**（与同类区分）：
- ✅ **三图通用**：同一套 dispatchAction 循环逻辑，适配 pie/bar/line
- ✅ **dispatchAction 四件套**：`highlight` / `downplay` / `showTip` / `hideTip`
- ✅ **setInterval 周期**：默认 1500ms（1.5s），速度适中
- ✅ **hover 暂停/续循环**：isHovering 标志位控制，鼠标离开无缝续
- ✅ **饼图有 downplay，线图无 downplay**：线图无 downplay 必要（无视觉残留）
- ✅ **position callback 防溢出**：tooltip 超出图表区时自动调整位置
- ❌ 不是 ECharts 内置的 `autoPlay`/`tooltip.triggerOn` 配置（ECharts 不支持）
- ❌ 不是用 `setOption` 改 `tooltip.show`（性能差）

---

## 核心配置

### 1. 通用脚本框架（适用饼/柱/线）

```ts
<script setup>
import * as echarts from 'echarts';
import { ref, onMounted, onUnmounted, watch } from 'vue';

const chartRef = ref(null);
let chartInstance = null;

// 三个核心状态
let highlightTimer = null;
let currentHighlightIndex = 0;
let isHovering = false;

// 启动循环
function startHighlight() {
  if (isHovering || !chartInstance) return;
  const dataLength = getData().length;  // 或 getData().data.length
  if (dataLength === 0) return;

  let lastHighlightIndex = -1;

  highlightTimer = setInterval(() => {
    if (isHovering) return;

    // 1. 先取消上一次的高亮（饼图/柱图需要，线图可省略）
    if (lastHighlightIndex >= 0) {
      chartInstance.dispatchAction({
        type: 'downplay',
        seriesIndex: 0,
        dataIndex: lastHighlightIndex,
      });
    }

    // 2. 高亮当前 item
    chartInstance.dispatchAction({
      type: 'highlight',
      seriesIndex: 0,
      dataIndex: currentHighlightIndex,
    });

    // 3. 显示 tooltip（含 position 防溢出）
    chartInstance.dispatchAction({
      type: 'showTip',
      seriesIndex: 0,
      dataIndex: currentHighlightIndex,
      position: (point, params, dom, rect, size) => {
        // 防溢出逻辑：见下方各图变体
        return [point[0], point[1]];
      },
    });

    lastHighlightIndex = currentHighlightIndex;
    currentHighlightIndex = (currentHighlightIndex + 1) % dataLength;  // 循环
  }, 1500);
}

function stopHighlight() {
  if (highlightTimer) {
    clearInterval(highlightTimer);
    highlightTimer = null;
  }
}

// hover 暂停
function onChartMouseOver() {
  isHovering = true;
  stopHighlight();
  chartInstance?.dispatchAction({ type: 'downplay' });  // 清除当前高亮
  // 线图需要额外 hideTip，饼图/柱图不需要
}

// hover 离开 → 无缝续循环
function onChartMouseOut() {
  isHovering = false;
  startHighlight();
}

onMounted(() => {
  chartInstance = echarts.init(chartRef.value);
  updateChart();
  startHighlight();
  window.addEventListener('resize', () => chartInstance?.resize());
});

watch(regionAdcode, () => {
  currentHighlightIndex = 0;
  updateChart();
});

onUnmounted(() => {
  stopHighlight();
  chartInstance?.dispose();
});
</script>

<template>
  <div
    class="work-chart"
    ref="chartRef"
    @mouseover="onChartMouseOver"
    @mouseout="onChartMouseOut"
  />
</template>
```

### 2. 饼图变体（Module02）

```js
function updateChart() {
  const data = getData();  // [{ value, name, color }]
  const option = {
    backgroundColor: 'transparent',
    tooltip: {
      trigger: 'item',
      backgroundColor: 'rgba(0, 30, 20, 0.9)',
      borderColor: 'rgba(0, 212, 170, 0.3)',
      textStyle: { color: '#e2e8f0', fontSize: 12 },
      formatter: (params) => `${params.name}: ${params.value}%`,
    },
    legend: {
      right: 20,
      top: 'center',
      orient: 'vertical',
      textStyle: { color: '#e2e2e2', fontSize: 12 },
      itemGap: 15,
      icon: 'circle',
    },
    series: [{
      type: 'pie',
      center: ['35%', '50%'],   // 偏左，给图例让位
      radius: ['60%', '85%'],   // 环饼
      itemGap: 2,
      label: { show: false },
      labelLine: { show: false },
      data: data.map(d => ({
        value: d.value,
        name: d.name,
        itemStyle: { color: d.color },
      })),
    }],
  };
  chartInstance.setOption(option);
}

// 饼图专用 showTip position（扇形内的相对位置）
chartInstance.dispatchAction({
  type: 'showTip',
  seriesIndex: 0,
  position: (point, params, dom, rect, size) => {
    // 居中显示在扇形上方
    return [point[0] + size.contentSize[0]/2 - 20, point[1] - size.contentSize[1]];
  },
  dataIndex: currentHighlightIndex,
});
```

### 3. 柱图变体（Module05）

```js
function updateChart() {
  const { xAxis, data } = getData();
  const maxVal = Math.max(...data);
  const niceMax = Math.ceil(maxVal / 50) * 50;
  const interval = Math.ceil(niceMax / 4 / 50) * 50;

  const option = {
    backgroundColor: 'transparent',
    tooltip: {
      trigger: 'item',
      backgroundColor: 'rgba(0, 30, 20, 0.9)',
      borderColor: 'rgba(0, 212, 170, 0.3)',
      textStyle: { color: '#e2e8f0', fontSize: 12 },
      formatter: (params) => `${params.name}: ${params.value}台`,
    },
    grid: { left: 40, right: 10, bottom: 20, top: 20 },
    xAxis: {
      type: 'category',
      data: xAxis,
      axisTick: { show: false },
      axisLine: { lineStyle: { color: 'rgba(255,255,255,0.2)' } },
      axisLabel: { color: '#dedede', fontSize: 12, interval: 0 },
    },
    yAxis: {
      type: 'value',
      max: niceMax,
      interval: interval,
      splitLine: {
        lineStyle: { type: 'dashed', color: 'rgba(255,255,255,0.12)' },
      },
      axisLine: { show: false },
      axisLabel: { color: '#dedede', fontSize: 12 },
    },
    series: [{
      type: 'bar',
      barWidth: '25%',
      data,
      itemStyle: {
        color: '#34a8eb',
        borderRadius: [8, 8, 0, 0],   // 顶部圆角
      },
      label: {
        show: true,
        color: '#ffffff',
        fontSize: 12,
        fontWeight: 600,
        position: 'outside',         // 数值在柱顶
        formatter: '{c}',
      },
    }],
  };
  chartInstance.setOption(option, true);
}

// 柱图专用 showTip position（柱条正上方）
chartInstance.dispatchAction({
  type: 'showTip',
  seriesIndex: 0,
  dataIndex: currentHighlightIndex,
  position: (_pt, _params, _dom, rect, size) => {
    if (!rect) return [0, 0];
    const tooltipWidth = size.contentSize[0];
    const tooltipHeight = size.contentSize[1];
    const chartWidth = size.viewSize[0];

    // 居中在柱条上方
    let left = rect.x + rect.width / 2 - tooltipWidth / 2;
    const top = rect.y - tooltipHeight - 8;

    // 防溢出：左侧贴边、右侧贴边
    if (left < 0) {
      left = 8;
    } else if (left + tooltipWidth > chartWidth) {
      left = chartWidth - tooltipWidth - 8;
    }

    return [left, top];
  },
});
```

### 4. 线图变体（Module06）

```js
function updateChart() {
  const data = getData();  // 近 7 天数值数组
  const minVal = Math.floor(Math.min(...data) / 1000) * 1000;
  const maxVal = Math.ceil(Math.max(...data) / 1000) * 1000;

  const option = {
    backgroundColor: 'transparent',
    tooltip: {
      trigger: 'axis',                                  // ← 轴触发（不是 item）
      backgroundColor: 'rgba(0, 30, 20, 0.9)',
      borderColor: 'rgba(0, 212, 170, 0.3)',
      textStyle: { color: '#e2e8f0', fontSize: 12 },
      formatter: (params) => {
        const date = params[0].axisValue;
        const value = params[0].data;
        return `${date}<br/>活跃设备: ${value}台`;
      },
    },
    grid: { left: 50, right: 10, bottom: 20, top: 20 },
    xAxis: {
      type: 'category',
      data: xData,  // 7 天日期数组
      axisTick: { show: false },
      axisLine: { lineStyle: { color: 'rgba(255,255,255,0.2)' } },
      axisLabel: { color: '#dedede', fontSize: 12 },
    },
    yAxis: {
      type: 'value',
      min: minVal,
      max: maxVal + 1000,
      interval: Math.ceil((maxVal - minVal) / 5 / 1000) * 1000 || 1000,
      splitLine: {
        lineStyle: { type: 'dashed', color: 'rgba(255,255,255,0.12)' },
      },
      axisLine: { show: false },
      axisLabel: { color: '#dedede', fontSize: 12 },
    },
    series: [{
      type: 'line',
      data,
      smooth: true,
      symbol: 'none',                                   // 关键：无圆点（高亮时才显示）
      lineStyle: {
        color: '#2dcb55',
        width: 4,
      },
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
          { offset: 0, color: 'rgba(45, 203, 85, 0.25)' },
          { offset: 1, color: 'rgba(45, 203, 85, 0.03)' },
        ]),
      },
    }],
  };
  chartInstance.setOption(option, true);
}

// 线图简化版（不需要 downplay、无残留）
highlightTimer = setInterval(() => {
  if (isHovering) return;

  chartInstance.dispatchAction({
    type: 'showTip',
    seriesIndex: 0,
    dataIndex: currentHighlightIndex,
  });
  chartInstance.dispatchAction({
    type: 'highlight',                                 // 显示当前点 symbol
    seriesIndex: 0,
    dataIndex: currentHighlightIndex,
  });

  currentHighlightIndex = (currentHighlightIndex + 1) % dataLength;
}, 1500);

// 线图 hover 时必须 hideTip（饼图/柱图不需要）
function onChartMouseOver() {
  isHovering = true;
  stopHighlight();
  chartInstance?.dispatchAction({ type: 'hideTip' });   // ← 线图专属
  chartInstance?.dispatchAction({ type: 'downplay' });
}
```

---

## 关键参数说明

### dispatchAction 4 件套

| type | 作用 | 适用图表 |
|------|------|---------|
| `highlight` | 高亮当前 dataIndex | 所有图 |
| `downplay` | 取消上一次高亮 | 饼图、柱图；**线图可选**（无残留） |
| `showTip` | 显示 tooltip | 所有图 |
| `hideTip` | 隐藏 tooltip | **线图专属**（轴触发 tooltip 会停留） |

### 三种图表差异

| 维度 | 饼图（Module02） | 柱图（Module05） | 线图（Module06） |
|------|----------------|----------------|-----------------|
| series type | `pie` | `bar` | `line` |
| tooltip trigger | `'item'` | `'item'` | `'axis'` |
| downplay | ✅ 必要 | ✅ 必要 | ⚪ 可选 |
| hideTip on hover | ❌ 不需要 | ❌ 不需要 | ✅ 必要 |
| position 计算 | 扇形中心 | 柱条正上方 | ECharts 默认 |
| 数据长度 | 4（饼图扇区） | 5（Top 5） | 7（近 7 天） |

### 周期与时长

| 参数 | 默认 | 说明 |
|------|------|------|
| `setInterval` 周期 | `1500ms` | 1.5 秒一个 item 切换 |
| `position callback` | 必填 | 防止 tooltip 溢出图表区 |
| `lastHighlightIndex` | `-1` | 初始值，标识"无" |

---

## 引用源文件

| 业务模块 | 源文件 |
|---------|--------|
| 无人机监管 - 作业类型分布（饼图） | [Module02.vue](file:///D:/external-projects/showcase-dashboard/src/views/DroneSurveillance/components/Module02.vue) |
| 无人机监管 - Top 5 排行（柱图） | [Module05.vue](file:///D:/external-projects/showcase-dashboard/src/views/DroneSurveillance/components/Module05.vue) |
| 无人机监管 - 近 7 日趋势（线图） | [Module06.vue](file:///D:/external-projects/showcase-dashboard/src/views/DroneSurveillance/components/Module06.vue) |

---

## 注意事项

> ⚠️ **颜色只是默认值**：`#2dcb55`、`#34a8eb`、`#f58015`、`#a652c8` 是 DroneSurveillance 默认色，根据业务调整。

1. **必须用 isHovering 标志位**：仅靠 `mouseover`/`mouseout` 事件不够，**setInterval 内部要二次检查**（避免最后一次循环已经把定时器销毁）。
2. **线图必须 hideTip**：线图 `tooltip.trigger: 'axis'` 会"吸附"在当前数据点，hover 时如果不调用 `hideTip`，tooltip 会和用户鼠标 tooltip 重叠。
3. **饼图/柱图不需要 hideTip**：它们 hover 时鼠标会自动 tooltip，原 tooltip 被覆盖，没问题。
4. **必须 downplay 上一次**：不 downplay 直接 highlight 新 item，**多个高亮会重叠**，视觉混乱。
5. **position callback 防溢出**：柱图尤其必要，最右侧柱条的 tooltip 会溢出图表右侧。
6. **数据切换重置 currentHighlightIndex**：adcode 变化时必须重置为 0，否则从中间开始。
7. **destroy 时必须 dispose**：不清除 chartInstance 会内存泄漏，事件监听不释放。
8. **周期不宜太短**：1500ms 是经验值，太短（如 500ms）会让用户觉得"数字在跳"，太长（如 5000ms）显得不"实时"。

---

## 变体提示

- **如果数据条数变化（如分页）**：`watch(dataLength, ...)` 触发重置 `currentHighlightIndex = 0`，避免越界。
- **如果想随机切换而不是顺序**：`currentHighlightIndex = Math.floor(Math.random() * dataLength)`。
- **如果想要"停留 X 秒再切下一个"**：把 `setInterval` 改为 `setTimeout` 嵌套 + 延时：
  ```js
  function loop() {
    doHighlight();
    setTimeout(loop, 1500);
  }
  ```
- **如果是雷达图/散点图**：dispatchAction 完全一致，仅 series.type 改为 `radar`/`scatter`。
- **如果数据点超 20 个**：建议只循环前 10 个重点，避免用户疲劳。
- **如果想加上"飞线/迁移"动画**：dispatchAction + `series: { type: 'lines', effect: { show: true, period: 4 } }`。
- **如果想关掉 hover 暂停**（强制自动播放）：把 `onChartMouseOver` 设为 `() => {}`。
- **如果是多 series（如双柱）**：dispatchAction 加 `seriesIndex: 1`，但循环逻辑需要扩展。
- **如果想 tooltip 跟随鼠标位置**：在 `showTip` 的 `position` callback 里返回鼠标坐标（`event.offsetX/Y`）。
- **如果想加速/减速**：把 1500 改为 800（加速）或 3000（减速），根据场景调整。