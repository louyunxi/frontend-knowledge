---
title: "8 点轨道脉冲 Loading（纯 CSS、无依赖）"
description: "8 个圆点环形排布，纯 CSS 脉冲动画追逐传播，无 JS、无外部库，可作按钮/区块/全屏 loading"
domain: 动效
type: pattern
source_scope: "uiverse.io 风格 dot-spinner；可泛化到任何 Web / UniApp H5 / 嵌入页"
observed_platforms:
  - web
  - mobile
confidence: high
tags:
  - loading
  - css-animation
  - spinner
  - 脉冲
  - 圆环
  - 纯css
  - 无依赖
  - 8点
keywords:
  - "8点轨道脉冲"
  - "dot spinner"
  - "环形脉冲loading"
  - "ripple ring loader"
  - "纯css loading"
---

# 8 点轨道脉冲 Loading（动效-loading-8点轨道脉冲）

## 概述

最常见的纯 CSS loading 效果之一：**8 个圆点等距环形排布，每个点周期性放大/缩小+透明度变化，用负 `animation-delay` 让脉冲依次错开 1/8 个周期，从而在视觉上形成一圈追着跑、绕着圆环传播的"轨道脉冲波"**。

整套效果纯 CSS 完成，零运行时依赖、零 JS、零图片。可作为：
- 按钮内 loading（`width: 20px; --uib-size: 20px`）
- 卡片/区块 loading（`width: 2.8rem`）
- 全屏 loading（`width: 5rem`）

视觉风格克制、克制自洽，可换主题色，最适合需要"专业感"的后台/大屏/报表系统。

## 适用场景

### ✅ 适合
- 工具型产品：控制台、CI/CD、报表、dashboard
- 异步请求等待：按钮提交后 loading、列表加载更多
- 表单等待：导出/上传/生成 PDF 中
- 移动端 H5（webview）：UniApp H5、混合应用内嵌页
- 任何不想引入 spinner GIF 或额外资源的纯 CSS 场景

### ❌ 不适合
- 需要表达"具体进度"（如 36% / 上传中 200k/2M）→ 应换**进度条 loading**
- 异常/错误等待 → 应换**骨架屏 + 错误占位**
- 已是首屏 → 用 [`动效-首屏白屏-loading同源占位`](./动效-首屏白屏-loading同源占位.md) 思路（HTML 内联，与页面同源）

## 视觉与原理速览

```
       ●           ← pulse dot 1（默认位置 12 点钟方向）
   ●       ●       ← dots 8（左上）、2（右上）
               ●   ← dot 3（3 点钟方向）
   ●       ●       ← dots 7、4
       ●           ← dot 6（6 点钟方向）

脉冲：每个 dot 用 scale 0 → 1 → 0 + opacity 0.5 → 1 → 0.5
     + 负 delay 让一个 dot 先动，下一个晚 1/8 周期
视觉：脉冲像"水滴"沿圆环追逐传播一圈
```

## 核心原理

| 维度 | 设计要点 |
|-----|---------|
| 圆环分布 | 8 个 `dot-spinner__dot` 都是 `position: absolute; inset: 0`（占满 spinner 容器），靠 `transform: rotate(N*45deg)` 旋转到圆周上 |
| 实际点 | 通过 `::before` 伪元素绘制（`width: 20%; height: 20%; border-radius: 50%`），位于父容器左上，被旋转自动挪到圆周上 |
| 脉冲动画 | 单一 `@keyframes pulse0112`：scale `0 → 1 → 0`，opacity `0.5 → 1 → 0.5`，ease-in-out，无限循环 |
| **追逐相位** | 第 2~8 个 dot 的 `animation-delay` 设负值 `-0.875s, -0.75s, ..., -0.125s`（周期约 1s，差 1/8 周期） |
| 周期计算 | 动画时长 = `var(--uib-speed) * 1.111`（≈0.9s × 1.111 ≈ 1s），覆盖完整"放大 + 缩小"两段，让一个 pulse 完整传递一圈 |
| 视觉留白 | scale 0 时透明度 0.5 → 让"未亮起的点"也保留微弱轮廓，环上不会断档 |
| 颜色支持 | 用 CSS 自定义属性 `--uib-color` 与 `--uib-size` `--uib-speed`，便于主题切换/尺寸缩放 |
| 装饰 | `box-shadow: 0 0 20px rgba(色, .3)` 给每个点一圈轻发光（可关） |

## 最小可运行骨架

直接复制可跑（HTML + CSS，无需 React/Vue 包装）：

```html
<div class="dot-spinner" aria-label="加载中" role="status">
  <div class="dot-spinner__dot"></div>
  <div class="dot-spinner__dot"></div>
  <div class="dot-spinner__dot"></div>
  <div class="dot-spinner__dot"></div>
  <div class="dot-spinner__dot"></div>
  <div class="dot-spinner__dot"></div>
  <div class="dot-spinner__dot"></div>
  <div class="dot-spinner__dot"></div>
</div>

<style>
  .dot-spinner {
    --uib-size: 2.8rem;
    --uib-speed: .9s;
    --uib-color: #183153;
    position: relative;
    display: flex;
    align-items: center;
    justify-content: flex-start;
    height: var(--uib-size);
    width: var(--uib-size);
  }

  .dot-spinner__dot {
    position: absolute;
    top: 0; left: 0;
    display: flex;
    align-items: center;
    justify-content: flex-start;
    height: 100%;
    width: 100%;
  }

  .dot-spinner__dot::before {
    content: '';
    height: 20%;
    width: 20%;
    border-radius: 50%;
    background-color: var(--uib-color);
    transform: scale(0);
    opacity: 0.5;
    animation: dot-spinner-pulse calc(var(--uib-speed) * 1.111) ease-in-out infinite;
    box-shadow: 0 0 20px rgba(18, 31, 53, 0.3); /* 可去掉 */
  }

  /* 第 2~8 个 dot 各旋转 45° 增量，并相位错开 1/8 周期 */
  .dot-spinner__dot:nth-child(1) { transform: rotate(  0deg); }
  .dot-spinner__dot:nth-child(2) { transform: rotate( 45deg); }
  .dot-spinner__dot:nth-child(2)::before { animation-delay: calc(var(--uib-speed) * -0.875); }
  .dot-spinner__dot:nth-child(3) { transform: rotate( 90deg); }
  .dot-spinner__dot:nth-child(3)::before { animation-delay: calc(var(--uib-speed) * -0.750); }
  .dot-spinner__dot:nth-child(4) { transform: rotate(135deg); }
  .dot-spinner__dot:nth-child(4)::before { animation-delay: calc(var(--uib-speed) * -0.625); }
  .dot-spinner__dot:nth-child(5) { transform: rotate(180deg); }
  .dot-spinner__dot:nth-child(5)::before { animation-delay: calc(var(--uib-speed) * -0.500); }
  .dot-spinner__dot:nth-child(6) { transform: rotate(225deg); }
  .dot-spinner__dot:nth-child(6)::before { animation-delay: calc(var(--uib-speed) * -0.375); }
  .dot-spinner__dot:nth-child(7) { transform: rotate(270deg); }
  .dot-spinner__dot:nth-child(7)::before { animation-delay: calc(var(--uib-speed) * -0.250); }
  .dot-spinner__dot:nth-child(8) { transform: rotate(315deg); }
  .dot-spinner__dot:nth-child(8)::before { animation-delay: calc(var(--uib-speed) * -0.125); }

  @keyframes dot-spinner-pulse {
    0%, 100% { transform: scale(0); opacity: 0.5; }
    50%      { transform: scale(1); opacity: 1; }
  }

  /* 无障碍：尊重 prefers-reduced-motion */
  @media (prefers-reduced-motion: reduce) {
    .dot-spinner__dot::before { animation: none; opacity: 0.8; transform: scale(0.6); }
  }
</style>
```

> **关键命名**：keyframes 已重命名为 `dot-spinner-pulse`，避免与 uiverse 默认的 `pulse0112`（通用、易冲突）同名。

## 进阶用法

### 1. 主题色与尺寸：CSS 变量覆盖

无需改模板，直接覆盖 3 个变量即可：

```css
/* 浅色按钮内 */
.btn-loading.dot-spinner {
  --uib-size: 18px;
  --uib-speed: .7s;
  --uib-color: #fff;
}

/* dashboard 大屏 */
.dashboard-loading.dot-spinner {
  --uib-size: 5rem;
  --uib-speed: 1.2s;
  --uib-color: #4f9bff;
}
```

### 2. 灰底 loading（自带 box-shadow 关闭）

去掉 `::before` 的 `box-shadow` 即可获得无发光、纯点阵版本：

```css
.dot-spinner__dot::before {
  /* box-shadow: 0 0 20px rgba(...);  ← 注释或删除 */
}
```

### 3. 暗色背景配色

原色 `#183153`（深蓝）在浅色背景下对比度强。在暗色背景下建议改成浅色：

```css
.dot-spinner { --uib-color: #4f9bff; }     /* 主品牌蓝 */
.dot-spinner { --uib-color: rgba(255,255,255,.85); } /* 纯白点 */
```

### 4. 加提示文字

```html
<div class="loading-block">
  <div class="dot-spinner" aria-label="加载中"></div>
  <p class="loading-text">正在加载…</p>
</div>
<style>
  .loading-block {
    display: inline-flex; flex-direction: column; align-items: center; gap: 12px;
  }
  .loading-text { font-size: 14px; color: #6b7280; margin: 0; }
</style>
```

### 5. 按钮内 inline loading

```html
<button class="btn" disabled>
  <span class="dot-spinner dot-spinner--inline" aria-hidden="true"></span>
  提交中…
</button>
<style>
  .dot-spinner--inline { --uib-size: 14px; --uib-color: currentColor; vertical-align: -2px; }
  .btn[disabled] { opacity: .7; cursor: not-allowed; }
</style>
```

> 关键是 `--uib-color: currentColor`，自动继承按钮文字色。

### 6. 配合 Vue / React 组件包

```tsx
// React 组件（CSS Modules 或 styled-components 也行）
export function DotSpinner({ size = '2.8rem', color = '#183153', speed = '.9s' }: Props) {
  return (
    <div className="dot-spinner" role="status" aria-label="加载中"
         style={{ ['--uib-size' as any]: size, ['--uib-color' as any]: color, ['--uib-speed' as any]: speed }}>
      {Array.from({ length: 8 }).map((_, i) => (
        <div key={i} className="dot-spinner__dot" />
      ))}
    </div>
  );
}
```

```vue
<!-- Vue 3 -->
<template>
  <div class="dot-spinner" :style="cssVars" role="status" aria-label="加载中">
    <div v-for="i in 8" :key="i" class="dot-spinner__dot" />
  </div>
</template>

<script setup lang="ts">
defineProps<{ size?: string; color?: string; speed?: string }>();
const cssVars = computed(() => ({
  '--uib-size': props.size ?? '2.8rem',
  '--uib-color': props.color ?? '#183153',
  '--uib-speed': props.speed ?? '.9s',
}));
</script>
```

## 注意事项 / 边界

### ⚠️ 不能省略的坑

1. **8 个 dot 的相位错开量必须是 1/8 周期**：当前为 `-0.125` 的等差。如果改 dot 数量（如 6、12），delay 错开必须同步改成 `-1/n + k/n`（n = dot 数）。
2. **改 dot 数必须改 rotate 增量**：8 个 → 每 45° 旋转；12 个 → 每 30° 旋转；6 个 → 每 60° 旋转。
3. **scale 0 时 opacity 不要写 0**：否则脉冲断档（亮起的前一刻突然空缺）。原方案保持 0.5，让"未亮起的点"也保留微弱轮廓。
4. **`box-shadow` 不要叠多层**：每个 dot 都画 20px 阴影会让 GPU 开销上升，复杂页面里去掉以省渲染。
5. **`prefers-reduced-motion` 必须兜底**：系统级降低动效偏好的用户会看到完整减弱的版本。
6. **小尺寸（≤20px）**: 旋转+缩放可能因为子像素精度出现轻微抖，建议小尺寸下用 `will-change: transform` 提升渲染精度。
7. **边框裁切风险**：`.dot-spinner` 容器 `display: flex; align-items: center; justify-content: flex-start` 实际上对 absolute 子元素无影响，但建议保留以兼容部分变形场景；也可以简化为 `display: block`。
8. **不要外层加 transform/filter**：在外层用 `transform: scale()` 缩放 spinner 时会与内部的 `transform: rotate()` 叠加，结果是圆点飞出圆周。建议外层改用 `width/height` 调尺寸。

### 🎯 选型决策

| 需求 | 推荐 loading |
|-----|--------------|
| 后台/大屏/报表，**品牌克制感** | ✅ **8 点轨道脉冲（本条）** |
| 营销/活动页，**鲜艳活泼** | 三色风车 / 双环旋转 / 弹性方块 |
| 数据量大、加载久 | 骨架屏 + 进度条 |
| 首屏 FCP 占位 | 见 [`动效-首屏白屏-loading同源占位`](./动效-首屏白屏-loading同源占位.md) |
| 需要**准确进度**（导出/上传/算力） | NProgress / 进度条 |
| 像素级**微动效** | 用 4 点 / 6 点变体 |

## 常见问题

### Q1: 为什么用 `::before` 而不是直接画在 dot 上？

用 `::before` 伪元素的好处：
- 8 个 dot 本身只是定位用的"占位壳"，不需要自己的 width/height，但需要一个变换原点；
- `::before` 真正承载视觉点（20% 大小 + scale 动画）；
- 调整"点的大小"（占容器的比例）只动 `::before` 的 width/height，不影响旋转逻辑。

如果直接给 `.dot-spinner__dot` 设尺寸，会和 rotate 冲突，需要补偿旋转半径，麻烦得多。

### Q2: 改成 12 个点会更顺滑吗？

会（更接近"圆"），但每个点的"亮起时间窗"更短，且代码量翻倍。一般 8 个点是视觉细腻度和代码量的甜点。

### Q3: 怎么改成"反向"（脉冲反向传播）？

把第 2~8 个的 `animation-delay` 顺序反过来：第 2 个 `-0.125s`、第 3 个 `-0.25s`、... 第 8 个 `-0.875s`，脉冲就逆向跑。

### Q4: 卡片 loading 模式下会不会引发重排？

不会。动画只动 `transform: scale()` 与 `opacity`，主线程不触发 layout/paint。是 GPU 合成层（compositor）动画，性能优秀。

### Q5: 如何切换深/浅色主题？

最简单方案：用 `currentColor`：

```css
.dot-spinner { --uib-color: currentColor; }
```

父元素加 `color: white` / `color: #183153`，spinner 跟着变。`box-shadow` 改为 `currentColor` 半透明：

```css
.dot-spinner__dot::before { box-shadow: 0 0 20px currentColor; }
```

## 性能优化要点

1. **GPU 友好**：动画属性仅 `transform` + `opacity`，**走合成层**，主线程无 layout/paint。
2. **`will-change` 按需**：在小尺寸（≤24px）且对动画帧率敏感时给 `.dot-spinner` 加 `will-change: transform`。
3. **`content-visibility: auto`**：在长列表里隐藏远端 spinner 可跳过渲染。
4. **避免外层 transform**：外层用 `transform: scale()` 会破坏内部 rotate 的复合变换，建议用 width/height 调尺寸。
5. **多个 spinner 并存**：每个 spinner 各自独立动画，无需 debounce/throttle，浏览器自动调度。

## 可访问性

- 容器加 `role="status"` + `aria-label="加载中"` 让屏幕阅读器正确识别。
- `prefers-reduced-motion: reduce` 下用一份静态退化（不再循环）。
- 颜色对比度：原色 `#183153` 在白底 `#fff` 上对比度约 13:1，远超 WCAG AA。但暗色背景务必改用亮色变量。

## 相关模式

- [`动效-首屏白屏-loading同源占位`](./动效-首屏白屏-loading同源占位.md) —— SPA 首屏 loading 与本组件**配套**：首屏用同源占位，进入应用后异步等待用本组件。
- [`../../动效/动效缓动与设计哲学.md`](../../动效/动效缓动与设计哲学.md) —— 缓动曲线参考（当前 `ease-in-out` 是脉冲类首选）。
- [`../../动效/动效设计原则.md`](../../动效/动效设计原则.md) —— 动效克制原则（同一时刻不要叠多个 spinner）。
- [`../../设计主题/UniApp移动端Token系统.md`](../../设计主题/UniApp移动端Token系统.md) —— 用 token 系统替换硬编码色值，让 spinner 融入品牌。

## 参考资料

- 原始模板：uiverse.io `dot-spinner` by `Preethi`（公开 CSS loader 库）
- 浏览器对负 `animation-delay` 的支持：MDN - [animation-delay](https://developer.mozilla.org/en-US/docs/Web/CSS/animation-delay)
- prefers-reduced-motion 规范：MDN - [@media (prefers-reduced-motion)](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-reduced-motion)

---

## 元信息

| 属性 | 值 |
|-----|---|
| 复杂度 | ⭐ (1/5 星) |
| 适用框架 | 任意 Web / UniApp H5 / 嵌入页 |
| 蒸馏来源 | 公开 CSS loader 模式（uiverse.io dot-spinner） |
| 标签 | loading, css-animation, spinner, 脉冲, 圆环, 纯css, 无依赖, 8点 |
| 创建日期 | 2026-09-16 |
| 技术栈 | 任意 Web / H5 |
