---
title: "12 条径向淡变 Loading（Apple-flavor 拖尾 spinner）"
description: "12 根条形元素径向环形排布，纯 opacity 1→0.25 + 负延迟；纯 CSS、零 JS、零图片"
domain: 动效
type: pattern
source_scope: "uiverse.io by david-mohseni；与 SpinKit fading-circle / Activity Indicator 风格同源"
observed_platforms:
  - web
  - mobile
  - desktop
confidence: high
tags:
  - loading
  - css-animation
  - radial
  - opacity-fade
  - 12条
  - 径向
  - 拖尾
  - 渐变
  - 无依赖
keywords:
  - "12条径向淡变"
  - "12 bar spinner"
  - "fading circle"
  - "Activity indicator"
  - "12条loading"
  - "径向spinner"
  - "拖尾spinner"
  - "Apple loading"
---

# 12 条径向淡变 Loading（动效-loading-12条径向淡变）

## 概述

12 根**条状**元素径向环形排布，**纯 opacity 1→0.25** 的渐变动画 + 逐根 0.1s 延迟差，形成一圈"亮带头 + 渐暗拖尾"的旋转光带——**iOS / Apple Activity Indicator 经典视觉**。

和 [`8 点轨道脉冲`](./动效-loading-8点轨道脉冲.md) 同属"n 元素径向排布"家族，但有两个显著差异：
1. 用"条"（pill 状）而非"点"（圆点），更接近 Apple 风格的"花瓣感"
2. 动画仅改 `opacity`（1→0.25），**不动 `transform: scale`**，因此性能更稳定、走 GPU 合成层
3. 每根条**静止占位**（rotate 后不动），所以**比 8 点轨道脉冲更"稳定"、更不易引起眩晕**

适用：
- iOS / Apple 设计语言的产品
- 需要"高级感/克制感"的工具型产品
- 任何想与"圆圈转圈"（Material） 形成差异化、又比"8 点脉冲"更克制的场景

## 适用场景

### ✅ 适合
- iOS 风格 / 极简质感 产品
- 表单提交后等待、生成 PDF、导出报表
- 后台管理工具的兜底 loading（想要"不像 Material"那个圈时）
- 移动端 H5 / 嵌入页：纯 CSS 在 webview 里渲染最干净
- 暗色 / 浅色通用：背景走 `rgb(128,128,128)` + 渐变 opacity，可主题化

### ❌ 不适合
- 需要"活泼/儿童/营销活动" 场景 → 用 [`8点轨道脉冲`](./动效-loading-8点轨道脉冲.md) 或彩色变种
- 不知道选什么时的第一选 → 用 [`SVG描边弧扫`](./动效-loading-SVG描边弧扫.md) （更通用）
- 需要表达准确进度 → 改 SVG 进度环
- 首屏 FCP 占位 → 用 [`首屏白屏-loading同源占位`](./动效-首屏白屏-loading同源占位.md)
- 像素级微动效（≤14px）→ 12 根条小到糊，建议换 8 点

## 视觉与原理速览

```
        ▌‾‾  bar1   (rotate 0°    , delay 0   ) ← 最亮 1.00
      ▐▌     bar2   (rotate 30°   , delay -1.1)
    ▐▌       bar3   (rotate 60°   , delay -1.0)
   ▌         bar4   (rotate 90°   , delay -0.9)
   ▌         bar5   (rotate 120°  , delay -0.8)
    ▐▌       bar6   (rotate 150°  , delay -0.7)
      ▐▌     bar7   (rotate 180°  , delay -0.6)
        ▌__  bar8   (rotate 210°  , delay -0.5)
                  ... 一直到 bar12 (rotate 330°, delay -0.1)

视觉：12 根条状元素像钟表一样围成一圈
     其中一根（最新）最亮（opacity=1）
     其它条按延迟从新到旧，opacity 依次递减到 0.25
     形成"光带从最亮处往最暗处旋转的拖尾"
```

## 核心原理

| 维度 | 设计要点 |
|-----|---------|
| **容器几何** | 54×54 正方形，`border-radius: 10px` 给容器加点圆角让整体更"温柔" |
| **条形大小** | `width: 8% / height: 24%` —— 8% 宽让条形像"细针", 24% 高让条形有"粒度感" |
| **条形形状** | `border-radius: 50px` 给条形圆角，配合 8% 宽的比例 → pill/胶囊 形 |
| **共享定位** | 所有条 `position: absolute; left: 50%; top: 30%; opacity: 0` —— 都从同一点发射出去 |
| **径向分发** | 每条 `transform: rotate(N×30deg) translate(0, -130%)` —— 旋转 30° 增量 + 沿旋转后的 y 轴向上推 130%（推送出原始位置） |
| **为何 -130%** | bar 自己高度 24%，-130% 乘自身高度 = 移动到容器边外面再收回一点，让 12 条外端对齐成完美正圆 |
| **阴影细节** | `box-shadow: 0 0 3px rgba(0,0,0,0.2)` —— 一抹极淡的阴影让条带从纯色背景里"挑出来" |
| **核心动画** | 单 keyframe `fade458`：`opacity: 1 → 0.25`, 1s linear infinite —— **只动 opacity，不动 transform** |
| **相位错开** | 12 根条 delay 依次为 0、-1.1s、-1s、-0.9s、…、-0.1s —— 注意第 2 根是 -1.1s 而不是 -0.9s，这是设计上的关键 |
| **错相位解析** | 周期 1s，12 根条想"等距错开"应是 1/12 ≈ 0.083s 增量。但实际是 0.1s 增量，所以**相邻位置视觉差 0.1s 而非 1/12**。原作者用 -1.1 这种"先往后跳一步" 是为了**让两端的亮度梯度"看上去更平稳"** |
| **颜色** | `rgb(128, 128, 128)` 中性灰 —— 强调"形状+动画"而非颜色；要主题色覆盖时改用 `currentColor` |

## 最小可运行骨架

直接复制可跑（HTML + 纯 CSS，无需 React/Vue 包装）：

```html
<div class="bar-loader" role="status" aria-label="加载中">
  <div class="bar"></div>
  <div class="bar"></div>
  <div class="bar"></div>
  <div class="bar"></div>
  <div class="bar"></div>
  <div class="bar"></div>
  <div class="bar"></div>
  <div class="bar"></div>
  <div class="bar"></div>
  <div class="bar"></div>
  <div class="bar"></div>
  <div class="bar"></div>
</div>

<style>
  .bar-loader {
    --uib-size: 54px;
    position: relative;
    width: var(--uib-size);
    height: var(--uib-size);
  }

  .bar-loader .bar {
    width: 8%;
    height: 24%;
    background: currentColor;                /* 默认跟随父级 color */
    color: rgb(128, 128, 128);               /* 默认中性灰 */
    position: absolute;
    left: 50%;
    top: 30%;
    opacity: 0;
    border-radius: 50px;
    box-shadow: 0 0 3px rgba(0, 0, 0, 0.2);
    transform: rotate(0deg) translate(0, -130%);
    animation: bar-loader-fade 1s linear infinite;
  }

  /* 12 根条 + 30° 增量 + 逐根 0.1s 延迟错相位 */
  .bar-loader .bar:nth-child(1)  { transform: rotate(  0deg) translate(0, -130%); animation-delay: 0s; }
  .bar-loader .bar:nth-child(2)  { transform: rotate( 30deg) translate(0, -130%); animation-delay: -1.1s; }
  .bar-loader .bar:nth-child(3)  { transform: rotate( 60deg) translate(0, -130%); animation-delay: -1s; }
  .bar-loader .bar:nth-child(4)  { transform: rotate( 90deg) translate(0, -130%); animation-delay: -0.9s; }
  .bar-loader .bar:nth-child(5)  { transform: rotate(120deg) translate(0, -130%); animation-delay: -0.8s; }
  .bar-loader .bar:nth-child(6)  { transform: rotate(150deg) translate(0, -130%); animation-delay: -0.7s; }
  .bar-loader .bar:nth-child(7)  { transform: rotate(180deg) translate(0, -130%); animation-delay: -0.6s; }
  .bar-loader .bar:nth-child(8)  { transform: rotate(210deg) translate(0, -130%); animation-delay: -0.5s; }
  .bar-loader .bar:nth-child(9)  { transform: rotate(240deg) translate(0, -130%); animation-delay: -0.4s; }
  .bar-loader .bar:nth-child(10) { transform: rotate(270deg) translate(0, -130%); animation-delay: -0.3s; }
  .bar-loader .bar:nth-child(11) { transform: rotate(300deg) translate(0, -130%); animation-delay: -0.2s; }
  .bar-loader .bar:nth-child(12) { transform: rotate(330deg) translate(0, -130%); animation-delay: -0.1s; }

  @keyframes bar-loader-fade {
    from { opacity: 1; }
    to   { opacity: 0.25; }
  }

  /* 无障碍：尊重 prefers-reduced-motion */
  @media (prefers-reduced-motion: reduce) {
    .bar-loader .bar { animation: none; opacity: 0.6; }
  }
</style>
```

> 关键命名：keyframes 已重命名为 `bar-loader-fade`，避免与 uiverse 默认的 `fade458`（通用、易冲突）同名。

## 进阶用法

### 1. 主题色 / 尺寸：用 `currentColor` + CSS 变量

```css
/* 默认走 currentColor */
.bar-loader { color: rgb(128, 128, 128); }
.bar-loader.primary { color: #4f9bff; }
.bar-loader.danger  { color: #ef4444; }
.bar-loader.muted   { color: rgba(255, 255, 255, .55); } /* 暗背景上 */

/* 尺寸按 CSS 变量缩放 */
.bar-loader.s { --uib-size: 28px; }
.bar-loader.m { --uib-size: 54px; }
.bar-loader.l { --uib-size: 96px; }
```

### 2. 居中全屏 loading

```html
<div class="page-loading">
  <div class="bar-loader" role="status" aria-label="加载中">
    <div class="bar"></div> ... ×12 ...
  </div>
  <p>正在加载…</p>
</div>
<style>
  .page-loading {
    position: fixed; inset: 0;
    display: flex; flex-direction: column; align-items: center; justify-content: center;
    gap: 16px; color: #4f9bff;
    background: rgba(255, 255, 255, .85); backdrop-filter: blur(2px);
  }
</style>
```

### 3. 按钮内 inline loading

```html
<button class="btn" disabled>
  <span class="bar-loader" aria-hidden="true">
    <span class="bar"></span> ... ×12 ...
  </span>
  提交中…
</button>
<style>
  .btn { display: inline-flex; align-items: center; gap: 6px; }
  .btn .bar-loader { --uib-size: 14px; color: currentColor; }
  .btn[disabled] { opacity: .7; cursor: not-allowed; }
</style>
```

> 注意：按钮内务必给 spinner 容器加 `aria-hidden="true"`，避免重复朗读"加载中"。

### 4. React / Vue 组件包

```tsx
// React
export function BarSpinner({
  size = 54,
  color = 'rgb(128, 128, 128)',
}: { size?: number; color?: string }) {
  return (
    <div
      className="bar-loader"
      role="status" aria-label="加载中"
      style={{ width: size, height: size, color }}
    >
      {Array.from({ length: 12 }).map((_, i) => (
        <div key={i} className="bar" />
      ))}
    </div>
  );
}
```

```vue
<!-- Vue 3 -->
<template>
  <div class="bar-loader" :style="{ width: size + 'px', height: size + 'px', color }"
       role="status" aria-label="加载中">
    <div v-for="i in 12" :key="i" class="bar" />
  </div>
</template>

<script setup lang="ts">
withDefaults(defineProps<{ size?: number; color?: string }>(), {
  size: 54,
  color: 'rgb(128, 128, 128)',
});
</script>
```

### 5. 配合 token 系统换主题

```css
.bar-loader {
  color: var(--color-primary, currentColor);
}
```

### 6. 派生变体：6 根 / 16 根 / 24 根

```css
/* 8 根：把 12 根 vs 6 根的视觉解读为"圆点稀疏度" */
.bar-loader.six .bar { /* 保留所有样式，仅 nth-child 用到 6 即可 */ }
```

```html
<div class="bar-loader six">
  <div class="bar"></div> ... ×6 ...   <!-- 但记得 bar 用 nth-child 1~6 并旋转 60° 增量 -->
</div>
```

```css
/* 6 根版：旋转 60° 增量 + 延迟 1/6s 错相位 */
.bar-loader.six .bar:nth-child(1) { transform: rotate(  0deg) translate(0, -130%); animation-delay: 0s; }
.bar-loader.six .bar:nth-child(2) { transform: rotate( 60deg) translate(0, -130%); animation-delay: -0.166s; }
/* ... 6 根类推 ... */
```

> 详细派生规则见 [`../../动效/动效设计原则.md`](../../动效/动效设计原则.md)。

## 注意事项 / 边界

### ⚠️ 不能省略的坑

1. **`opacity: 0` 必须**：基础 `opacity: 0` 让未加载的初始态"不可见"，再靠 keyframe 把它点亮。如果省略基础 opacity:0，第一帧所有条都会亮起 → 视觉上是"突然消失再一条条出现"，非常破。

2. **`translate(0, -130%)` 中的 -130% 是相对 bar 自己高度的**：不是相对容器！如果改成 px 单位，缩放容器就会变形。推荐永远用百分比。

3. **`transform: rotate(...) translate(...)` 顺序不要反**：`rotate` 在前 `translate` 在后（也就是原方案）。如果反过来 `translate(0, -130%) rotate(...)`，所有条会先上推再绕原点转 —— 视觉效果是 12 条堆在一起再旋转，**完全错乱**。

4. **延迟的 0.1s 增量 + 第 2 根 -1.1s**：这是原作者特意设计。如果追求"完美等距 1/12"，应改成 -0.083s 增量、第 2 根 -1.083s。但实际 0.1s 看起来更"自然带拖尾感"。

5. **`box-shadow: 0 0 3px rgba(0,0,0,0.2)` 不要滥用**：在暗背景下，黑色阴影会让条带显得"脏"。建议主题色覆盖方案里同步改 shadow 颜色：
   ```css
   .bar-loader.primary .bar {
     box-shadow: 0 0 3px rgba(79, 155, 255, 0.4);
   }
   ```

6. **`prefers-reduced-motion` 必须兜底**：减动效偏好的用户必须看到静态态（推荐 `opacity: 0.6` 平均点亮）。否则看到一个"完全空白圈"，比静态更不安。

7. **外层容器不要加 transform 缩放**：会破坏 bar 径向圆阵。建议改 `--uib-size` 数值。

8. **不要把 12 根条放进雪碧图或单 SVG**：用 DOM 12 个 div 性能已经够（合成层 + opacity）、且可读性最高。别过度工程化。

### 🎯 选型决策

| 需求 | 推荐 loading |
|-----|--------------|
| iOS / Apple 风格 / 高端感 | ✅ **12 条径向淡变（本条）** |
| 通用兜底（不知道选什么）| [`SVG描边弧扫`](./动效-loading-SVG描边弧扫.md) |
| 活泼/儿童/营销 | [`8点轨道脉冲`](./动效-loading-8点轨道脉冲.md) |
| 表单提交按钮内 | 本条 或 SVG描边弧扫都可 |
| 数据准确进度 | SVG 进度环 |
| 首屏 FCP 占位 | [`首屏白屏-loading同源占位`](./动效-首屏白屏-loading同源占位.md) |
| 暗背景 + 暗主题 | 本条 + 改 `currentColor: rgba(255,255,255,.55)` |

## 常见问题

### Q1: 为什么不改成 `8 根 / 16 根` 看起来更顺滑？

视觉密度问题：
- **6 根**：太空，"圆点感" 弱
- **8 根**：恰好（[`8点轨道脉冲`](./动效-loading-8点轨道脉冲.md) 取的就是 8）
- **12 根**：密集、精致、Apple 钟表指针的味道（**本条**选择）
- **24 根**：视觉过载，更像"齿轮"

12 是**视觉细腻度和"不显得拥挤"的甜点**。

### Q2: 想让"光带"更明显（更窄的渐变）怎么改？

把 `0.25` 改到更小（如 `0.1`），让暗端更暗：

```css
@keyframes bar-loader-fade {
  from { opacity: 1; }
  to   { opacity: 0.1; }   /* 拖尾更细、更闪烁 */
}
```

或者在 delay 上"集中"（如延迟错开从 0.1 改成 0.15s），让相邻两根条差距更明显，"光带"看起来更短。

### Q3: 想"反向"（拖尾逆时针）怎么改？

把 delay 顺序倒过来：

```css
.bar-loader .bar:nth-child(1)  { ... animation-delay: -0.0s; }   /* 原 0 */
.bar-loader .bar:nth-child(2)  { ... animation-delay: -0.2s; }   /* 原 -1.1 */
.bar-loader .bar:nth-child(3)  { ... animation-delay: -0.3s; }   /* 原 -1.0 */
/* ... 12 根类推 ... */
```

或者只旋转方向保留延迟不变，把 `rotate(N deg)` 改成 `rotate(-N deg)`（逆时针），12 根位置绕到左边但旋转也是逆时针。

### Q4: 怎么改成"颜色渐变"（每根不同色）？

把第 N 根 bar 加 `background: hsl(N*30, 70%, 60%)`：12 根正好色相转一圈（每 30° 一个色相）。但要注意**与品牌色冲突**时反而显得花哨。

### Q5: 为什么 `border-radius: 50px` 而不是 `9999px`？

`50px` 是绝对值，`9999px` 是无限大圆角。在 8%×24% 尺寸下，50px 已经足够让两端变全圆。改 9999px 在某些浏览器会有像素抖动。但这是细节，可读性比"绝对正确"更重要。

### Q6: 怎么把它做成"进度环"（要 67% 准确进度）？

本条**不行**——12 根条是"装饰性动画"。要进度看 [`SVG描边弧扫`](./动效-loading-SVG描边弧扫.md) 的 Q&A，里面有 SVG 进度环的 JS 注入方案。

## 性能优化要点

1. **GPU 友好**：动画属性仅 `opacity`，**主线程无 paint / layout**（opacity 在 GPU 合成层）。
2. **`will-change: opacity`**：12 个 div 各自动画不互相干扰，浏览器自动调度；不必显式声明 will-change。
3. **避免外层 transform**：外层 transform 会与 bar 的 transform 复合错乱。改尺寸用 width/height。
4. **多个 spinner 并存**：每实例独立动画，无 debounce/throttle 必要。
5. **与 SVG 描边区别**：本条 DOM 节点多（12 个）但每个节点复杂度低；SVG 单节点但 stroke-dashoffset 是 paint 层属性。**大多数场景**本条更快，**特别复杂页面里** SVG 描边更稳定。

## 可访问性

- 容器加 `role="status"` + `aria-label="加载中"` 让屏幕阅读器正确识别。
- `prefers-reduced-motion: reduce` 下用静态 `opacity: 0.6` 兜底。
- 颜色对比度：默认 `rgb(128, 128, 128)` 在白底上对比度约 4.5:1，对"非文字"图形 UI **够用**（WCAG 1.4.11 ≥ 3:1）。暗背景下建议用 `rgba(255,255,255,.75)`。
- 按钮内使用务必加 `aria-hidden="true"`，避免重复朗读。

## 相关模式

- [`动效-loading-8点轨道脉冲`](./动效-loading-8点轨道脉冲.md) —— 同家族（n 元素径向 + 负延迟），但用"圆点 scale+pulse"；视觉更活泼
- [`动效-loading-SVG描边弧扫`](./动效-loading-SVG描边弧扫.md) —— 单 SVG + stroke-dashoffset，通用兜底
- [`动效-首屏白屏-loading同源占位`](./动效-首屏白屏-loading同源占位.md) —— 首屏 FCP 占位，**与本条组合**：首屏同源占位 → 进入应用后异步等待用本条
- [`../../动效/动效缓动与设计哲学.md`](../../动效/动效缓动与设计哲学.md) —— 缓动曲线参考（本条用 `linear`，因为错相位本身已提供节奏感，无须缓动）
- [`../../动效/动效设计原则.md`](../../动效/动效设计原则.md) —— 克制原则（同一时刻不要叠多个 spinner）
- [`../../设计主题/UniApp移动端Token系统.md`](../../设计主题/UniApp移动端Token系统.md) —— 用 token 替换硬编码色

## 参考资料

- 原始模板：uiverse.io `bar-loader` by `david-mohseni`
- 原理原型：SpinKit - [Fading Circle](https://tobiasahlin.com/spinkit/) / iOS UIActivityIndicatorView / Android ProgressBar (`circle` style)
- opacity 动画 性能：MDN - [opacity](https://developer.mozilla.org/en-US/docs/Web/CSS/opacity)（gpu-optimized）
- prefers-reduced-motion：MDN - [@media (prefers-reduced-motion)](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-reduced-motion)

---

## 元信息

| 属性 | 值 |
|-----|---|
| 复杂度 | ⭐ (1/5 星) |
| 适用框架 | 任意 Web / UniApp H5 / 嵌入页 / React / Vue |
| 蒸馏来源 | uiverse.io bar-loader (david-mohseni)；SpinKit fading-circle 同源 |
| 标签 | loading, css-animation, radial, opacity-fade, 12条, 径向, 拖尾, 渐变, 无依赖 |
| 创建日期 | 2026-09-16 |
| 技术栈 | 任意 Web / H5 |
