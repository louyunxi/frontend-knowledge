---
title: "SVG 描边弧扫 Loading（Material 经典转圈）"
description: "单个 SVG 圆 + stroke-dasharray/dashoffset 动画 + 双层错峰旋转；纯 CSS、无 JS、最经典的 indeterminate loading"
domain: 动效
type: pattern
source_scope: "uiverse.io by barisdogansutcu；本质上就是 Material UI CircularProgress indeterminate 动画"
observed_platforms:
  - web
  - mobile
  - desktop
confidence: high
tags:
  - loading
  - css-animation
  - svg
  - stroke-dasharray
  - 描边
  - 弧扫
  - 转圈
  - 经典
  - 无依赖
keywords:
  - "SVG描边弧扫"
  - "Material spinner"
  - "圆环描边loading"
  - "stroke-dash loading"
  - "圆形进度loading"
  - "indeterminate spinner"
  - "转圈loading"
---

# SVG 描边弧扫 Loading（动效-loading-SVG描边弧扫）

## 概述

Web 上**最经典的"无限不确定状态" loading**：一个 SVG 圆环转圈，同时弧线段在圆周上**画出来 → 拖长 → 收回消失 → 起点接续再画**，周而复始。

这就是 Material UI `CircularProgress`（indeterminate 态）、iOS loading、Ant Design Spin、绝大多数后台系统的默认 loading 动画的同一份源码。**纯 SVG + 纯 CSS，无 JS、无图片、无依赖**，浏览器原生支持。

视觉特征：
- 整圈**缓慢匀速**顺时针旋转（2s/圈，线性，给人"稳定"的感受）
- 一段**圆头弧线**沿圆周方向扫过，先从 0 长大、再缩短到 0，最后归位再次起点（1.5s，非线性，ease-in-out）
- 双层动画**时长错开**（2s vs 1.5s）+ **速度错开**（匀速 vs 缓动）= 永远不会出现"机械重复"感

适用范围：**几乎所有通用 loading 场景**。这就是大多数产品第一选择。

## 适用场景

### ✅ 适合
- **默认 loading**：后台管理系统、报表、运营平台——任何不知道选什么时的兜底选
- 表单等待：生成报表、导出、提交
- 路由切换：组件级 lazy 的 fallback
- WebView/H5 嵌入页：UniApp、混合应用中
- 强复古/极简风设计：单圆环转圈最不抢戏
- 暗色/浅色通用：因为只有 stroke 一根线，配色靠 `currentColor`

### ❌ 不适合
- 需要表达"具体进度"（如上传 67%）→ 改 [`SVG描边进度环`](#q5-需要进度的版本怎么改)（保留 `stroke-dasharray` 但用 JS 控制）
- 表达**轻快/活泼/儿童** 场景 → 改 [`8点轨道脉冲`](./动效-loading-8点轨道脉冲.md) 或彩色变化型
- 营销活动页首屏 → 改品牌动效（如春节、618 等）
- 像素级微动效（≤14px）→ SVG 在小尺寸下抗锯齿反而不如纯 CSS

## 视觉与原理速览

```
           ╱───────╲         ← 转 2s/圈 顺时针匀速
         ╱           ╲
        │      ╱╲      │     ← 弧线段随描边动画扫过
        │     ╱  ╲     │       · 0%  : 仅 1 像素
        │      ╲╱      │       · 50% : ~90 像素长
         ╲           ╱       · 100%: 完全消失（offset 推到下一圈）
           ╲───────╱

双层动画（时长/曲线都错开）：
  - 外层 SVG 整体旋转: 2s linear  infinite
  - 内层 circle 描边动画: 1.5s ease-in-out infinite
```

## 核心原理

| 维度 | 设计要点 |
|-----|---------|
| **SVG 圆本身** | 单个 `<circle>`，`r=20`、`cx=50`、`cy=50`，viewBox=`25 25 50 50` 让 stroke 不被裁切 |
| **无填充** | `fill: none`，否则 stroke-dasharray 不会起作用 |
| **stroke 描边** | `stroke-width: 2`、`stroke-linecap: round`（圆头让弧线两端看起来光滑，不是"刺头"） |
| **核心技巧** | `stroke-dasharray: 1, 200` —— 把整个圆周想象成"虚线"，**一段 1 单位的实线 + 一段 200 单位的空白**，循环。圆周长 ≈ 2π·20 ≈ 125.66，所以 200 比周长大 → 只会看到一段实线 + 一长段不可见的空白 |
| **错位移动** | `stroke-dashoffset` 偏移虚线起点，**不断减小**让"那段实线"沿圆周滑动 |
| **`dash4` keyframe** | 在 1.5s 内：dash `1, 200 → 90, 200`（拉长弧线到 ~70% 周长），offset `0 → -35 → -125`（推到下一轮） |
| **`rotate4` keyframe** | 整圈 2s 匀速旋转，与弧线动画**两个不同周期**（2 与 1.5 互质），永远不会严格同步 → 没有机械重复感 |
| **颜色** | `stroke: hsl(214, 97%, 59%)` —— 这是清爽蓝；通常改 `currentColor` 跟随主题 |
| **响应式尺寸** | 用 `em` 单位 `width: 3.25em` —— 跟随父级文字大小自动缩放 |

## 最小可运行骨架

直接复制可跑（HTML + 纯 CSS，**无需**React/Vue 包装）：

```html
<svg class="spinner" viewBox="25 25 50 50" aria-label="加载中" role="status">
  <circle r="20" cy="50" cx="50" />
</svg>

<style>
  .spinner {
    width: 3.25em;
    transform-origin: center;
    animation: spinner-rotate 2s linear infinite;
  }

  .spinner circle {
    fill: none;
    stroke: currentColor;                          /* 跟随主题色 */
    stroke-width: 2;
    stroke-linecap: round;
    stroke-dasharray: 1, 200;
    stroke-dashoffset: 0;
    animation: spinner-dash 1.5s ease-in-out infinite;
  }

  @keyframes spinner-rotate {
    100% { transform: rotate(360deg); }
  }

  @keyframes spinner-dash {
    0%   { stroke-dasharray: 1, 200;   stroke-dashoffset: 0;        }
    50%  { stroke-dasharray: 90, 200;  stroke-dashoffset: -35px;    }
    100% { stroke-dashoffset: -125px; }
  }

  /* 无障碍：尊重 prefers-reduced-motion */
  @media (prefers-reduced-motion: reduce) {
    .spinner,
    .spinner circle { animation: none; }
    .spinner circle { stroke-dasharray: 60, 200; } /* 静止态：保留一段弧 */
  }
</style>
```

> 关键命名：keyframes 已重命名为 `spinner-rotate` / `spinner-dash`，避免与 uiverse 默认的 `rotate4` / `dash4`（通用、易冲突）同名。

## 进阶用法

### 1. 主题色与尺寸：跟随父级 / CSS 变量

```css
/* 默认走 currentColor，父级 color 决定颜色 */
.spinner.primary { color: #4f9bff; }
.spinner.danger  { color: #ef4444; }
.spinner.muted   { color: #9ca3af; }

/* 尺寸按 em 缩放 */
.spinner.tiny   { font-size: 12px; }   /* 约 39×39px */
.spinner.normal { font-size: 16px; }   /* 约 52×52px */
.spinner.large  { font-size: 24px; }   /* 约 78×78px */
```

```html
<span style="color:#4f9bff; font-size:20px">
  <svg class="spinner" viewBox="25 25 50 50"><circle r="20" cy="50" cx="50" /></svg>
</span>
```

### 2. 居中全屏 loading

```html
<div class="page-loading">
  <svg class="spinner" viewBox="25 25 50 50">
    <circle r="20" cy="50" cx="50" />
  </svg>
  <p class="page-loading__text">正在加载…</p>
</div>
<style>
  .page-loading {
    position: fixed; inset: 0;
    display: flex; flex-direction: column; align-items: center; justify-content: center;
    gap: 16px; color: #4f9bff; font-size: 18px;
    background: rgba(255,255,255,.85); backdrop-filter: blur(2px);
  }
</style>
```

### 3. 按钮内 inline loading

```html
<button class="btn" disabled>
  <svg class="spinner" viewBox="25 25 50 50" aria-hidden="true">
    <circle r="20" cy="50" cx="50" />
  </svg>
  提交中…
</button>
<style>
  .btn { display: inline-flex; align-items: center; gap: 6px; }
  .btn .spinner { width: 1em; height: 1em; }   /* 跟随文字大小 */
  .btn[disabled] { opacity: .7; cursor: not-allowed; }
</style>
```

> 注意：按钮内使用时务必加 `aria-hidden="true"`，避免重复朗读"加载中"。

### 4. React / Vue 组件包

```tsx
// React
export function Spinner({ size = 16, color }: { size?: number; color?: string }) {
  return (
    <svg
      className="spinner"
      width={size} height={size}
      viewBox="25 25 50 50"
      role="status" aria-label="加载中"
      style={color ? { color } : undefined}
    >
      <circle r="20" cy="50" cx="50" />
    </svg>
  );
}
```

```vue
<!-- Vue 3 -->
<template>
  <svg class="spinner" :width="size" :height="size" viewBox="25 25 50 50"
       :style="{ color }" role="status" aria-label="加载中">
    <circle r="20" cy="50" cx="50" />
  </svg>
</template>

<script setup lang="ts">
defineProps<{ size?: number; color?: string }>();
withDefaults(defineProps<{ size?: number; color?: string }>(), {
  size: 16,
  color: '#183153',
});
</script>
```

### 5. 配合 token 系统换主题

用 [`设计主题/UniApp移动端Token系统.md`](../../设计主题/UniApp移动端Token系统.md) 中的 `--color-primary`，自动跟随：

```css
.spinner {
  stroke: var(--color-primary, currentColor);   /* 直接给 circle */
}
.spinner circle { stroke: var(--color-primary, currentColor); }
```

## 注意事项 / 边界

### ⚠️ 不能省略的坑

1. **viewBox 设置错了 stroke 被裁切**：原方案 `viewBox="25 25 50 50"` 把 50×50 的坐标系向内偏移 25 单位，**留出 25 单位的空白边**给 stroke。如果你写 `viewBox="0 0 50 50"` —— stroke 会被视口边缘切掉一半！任何带描边的 spinner 都要注意这个坑。
2. **stroke-dasharray 总和必须 ≥ 圆周长**：圆周长 = 2π·r ≈ 125.66（r=20 时）。数组中"空白长度"如果小于周长，会出现"两段弧同时可见"。推荐给"空白"留 ≥ 200 的值。
3. **`fill: none` 必加**：不写 fill 默认 `black` —— 你将看到一个黑色实心圆，描边动画**完全失效**。
4. **`stroke-linecap: round` 影响视觉**：用 `butt`（默认）时，弧线两端是平的，会有"砍头"感；圆头视觉柔和一倍。
5. **不要在外层容器用 transform 旋转**：会与内层 SVG `transform-origin: center` 冲突。父级要旋转请直接改 SVG 自己的动画，不要叠加。
6. **IE11 不支持 `currentColor` 传给 SVG**（部分版本）：如需兼容 IE，方案改为 `stroke: #color-primary` 直接写死。
7. **`prefers-reduced-motion` 必须兜底**：必须有一段静态弧线（推荐 `stroke-dasharray: 60, 200`），否则用户看到一个"消失的空圆"，体验更差。
8. **多个 spinner 并存动画不必冲突**——每实例独立动画，无需 debounce/throttle。

### 🎯 选型决策（与同类对比）

| 需求 | 推荐 |
|-----|------|
| 后台/工具类产品的**默认 loading** | ✅ **SVG 描边弧扫（本条）**——经典、克制、永不出错 |
| 营销/活动/儿童风格 | 改 [`8点轨道脉冲`](./动效-loading-8点轨道脉冲.md) 或色彩更跳的 spinner |
| 表单提交等待 | 推荐本条（按钮内） |
| 数据**准确进度** | 改 SVG 进度环（保留 stroke-dasharray，offset 跟数据走） |
| 首屏 FCP 占位 | 见 [`首屏白屏-loading同源占位`](./动效-首屏白屏-loading同源占位.md) |
| 像素级微动效 | 改 4 点 / 6 点纯 CSS |
| 大屏/数据可视化周边 | 推荐本条 |

## 常见问题

### Q1: 为什么 SVG 整体要再转一圈？仅靠 stroke-dashoffset 不够吗？

不够。`stroke-dashoffset` 只是让"那段实线"在圆周上滑动，但**如果圆本身不转**，你会看到"弧线在固定位置上拉长-缩短"。整圈旋转让"弧"出现在圆周所有位置，**视觉上形成"扫过的弧线在空间任意角度"** 的丰富感。

更进一步：旋转 2s 与 dash 1.5s **互质**，任何时刻视觉相位都不同 → 永不死板重复。

### Q2: 如何改成"反向"（逆时针）？

任选其一：

```css
/* 方案 1：反向旋转 */
@keyframes spinner-rotate { 100% { transform: rotate(-360deg); } }

/* 方案 2：弧线反向移动 */
@keyframes spinner-dash {
  0%   { stroke-dashoffset: 0; }
  100% { stroke-dashoffset: 125px; }   /* 从 +0 加到 +125 */
}
```

### Q3: 怎么调"快慢"？

旋转速度改 `animation-duration`（2s），弧线速度改 1.5s。**保留 2:1.5 ≈ 4:3 的比例**能让节奏不变；想快就统一缩短（如都 1s）。

### Q4: 怎么变成"双圈反向"或"环 + 点" 组合？

保留本条作为外圈，再叠一个 `transform: scale(0.7) rotate(-360deg)` 的内圈（更细 stroke 或反过来），就是 Material Design 真正的 indeterminate 风格。详见 [`../../动效/动效缓动与设计哲学.md`](../../动效/动效缓动与设计哲学.md)。

### Q5: 需要进度的版本怎么改？

把 `stroke-dasharray` 改为 `[进度, 周长]`，offset 改为 0，用 JS 计算：

```css
.progress circle {
  stroke-dasharray: var(--progress) 200;  /* JS 注入 --progress: 0~125 */
  stroke-dashoffset: 0;
  animation: none;
}
```

```js
el.style.setProperty('--progress', String(progress * 125.66));
```

> 这是 SVG 进度环的标准做法；本条 loading 用 `animation` 自动跑、不需要 JS 算值。

### Q6: 像素尺寸如何选？

| 场景 | 推荐尺寸 |
|-----|---------|
| 按钮内 | 14~16px |
| 卡片中央 | 32~48px |
| 全屏 | 64~96px |
| 不要超过 200px | 否则圆周变长，需要重新调 `stroke-dasharray` |

## 性能优化要点

1. **GPU 友好**：`transform: rotate` 走合成层，主线程无 layout/paint；同时整个动画**不动 DOM**（CSS 仅改 `stroke-dasharray` 和 `stroke-dashoffset`），整段都在主线程**paint** 层处理——是 CPU 友好动画。
2. **小尺寸不必加 `will-change`**：浏览器自动把 SVG 当作 raster；超过 100px 时可考虑加 `will-change: transform`。
3. **避免在 spinner 内嵌大段 SVG**：viewBox 缩放重计算 + paint，慢。
4. **多个 spinner 并存不卡**：每个独立动画，浏览器调度。
5. **可关掉 GPU 动画的坑**：`transform: rotate` 在 `transform-origin` 上有时不精准；可考虑用 `@keyframes` 中直接 `transform: rotate(...) translateZ(0)`，但**收益小、必要时才加**。

## 可访问性

- 容器加 `role="status"` + `aria-label="加载中"`，让屏幕阅读器正确识别。
- 按钮内使用时给 SVG 加 `aria-hidden="true"`，按钮文字"提交中"已经表达状态，避免重复朗读。
- `prefers-reduced-motion: reduce` 下使用静态 `stroke-dasharray: 60, 200` 兜底。
- 颜色对比度：原色 `hsl(214, 97%, 59%)` 在白底对比度约 3.5:1，对"非文字"的指示线**够用**（WCAG 1.4.11 对图形 UI 组件要求 ≥3:1）。

## 相关模式

- [`动效-loading-8点轨道脉冲`](./动效-loading-8点轨道脉冲.md) —— 兄弟样式（脉冲类），用于需要"活泼/轻快" 的 loading；与本条"克制/经典"互补
- [`动效-首屏白屏-loading同源占位`](./动效-首屏白屏-loading同源占位.md) —— 首屏 FCP 占位，**与本条组合**：首屏同源占位 → 进入应用后异步等待用本条
- [`../../动效/动效缓动与设计哲学.md`](../../动效/动效缓动与设计哲学.md) —— 缓动曲线参考（ease-in-out 是描边类首选）
- [`../../动效/动效设计原则.md`](../../动效/动效设计原则.md) —— 克制原则（同一时刻不要叠多个 spinner）
- [`../../设计主题/UniApp移动端Token系统.md`](../../设计主题/UniApp移动端Token系统.md) —— 用 token 替换硬编码色

## 参考资料

- 原始模板：uiverse.io `circle-loader` by `barisdogansutcu`
- 原理原型：Google Material Design — [Circular progress](https://m3.material.io/components/progress-indicators/circular-indicators) indeterminate 态
- stroke-dasharray / dashoffset：MDN - [stroke-dasharray](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-dasharray) / [stroke-dashoffset](https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-dashoffset)
- prefers-reduced-motion：MDN - [@media (prefers-reduced-motion)](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-reduced-motion)

---

## 元信息

| 属性 | 值 |
|-----|---|
| 复杂度 | ⭐ (1/5 星) |
| 适用框架 | 任意 Web / UniApp H5 / 嵌入页 / React / Vue |
| 蒸馏来源 | uiverse.io circle-loader（Material CircularProgress indeterminate 经典复刻） |
| 标签 | loading, css-animation, svg, stroke-dasharray, 描边, 弧扫, 转圈, 经典, 无依赖 |
| 创建日期 | 2026-09-16 |
| 技术栈 | 任意 Web / H5 |
