---
title: 纯 CSS 打字机效果
platform: uniapp
compatibility: uniapp-only
domain: 动效
source: components/typewriter / markdowns/typewriter.md
tags: [动画, CSS, 文本, typeit, 单标签]
---

# 纯 CSS 打字机效果

> ⚠️ 本知识仅适用于 **uni-app 自定义组件 / 单文件组件** 场景。原生 Vue / React 工程可借鉴 CSS 思路，但标签需替换为 div / span；uniapp 使用的是 `view` + `upx` 单位。

## 实现原理

用 CSS `@keyframes` + `animation: typing steps()` 让文字容器从 `width: 0` 逐步扩展到 `width: 100%`，再用一个独立的 `border-right` 光标做闪烁（`blink-caret`）。整个组件**不需要 JS**，是纯样式。

## 关键代码

```html
<template>
  <view class="typewriter">
    <view class="text">The cat and the hat.</view>
  </view>
</template>
```

```css
.typewriter {
  width: 390upx;
  margin: auto;
}

.typewriter .text {
  font-size: 40upx;
  overflow: hidden;
  border-right: 2upx solid orange;
  white-space: nowrap;
  margin: 0 auto;
  letter-spacing: 2;
  /* steps(40, end) 模拟"打字机一格一格打"的视觉 */
  animation:
    typing 3.5s steps(40, end),
    blink-caret .75s step-end infinite;
}

@keyframes typing {
  from { width: 0; }
  to   { width: 100%; }
}

@keyframes blink-caret {
  from, to { border-color: transparent; }
  50%      { border-color: orange; }
}
```

## 设计要点

| 要点 | 取值 | 说明 |
| ---- | ---- | ---- |
| 字体尺寸 | `40upx` | uniapp 标准写法，自动按屏宽缩放 |
| 容器宽度 | `390upx` | 决定打字动画总时长除数 |
| 动画步数 | `steps(40, end)` | 与容器宽度/字号近似匹配，看起来"逐字" |
| 光标闪烁 | `.75s step-end infinite` | 关键帧过渡用 step-end 避免渐变 |
| `white-space: nowrap` | 必填 | 否则宽到 100% 时不会逐字展开 |

## 适用场景

- 营销页首屏 Slogan
- 启动页 / Loading 文字提示
- 数据大屏的"实时播报"标题

## 平台兼容性

- H5：✅ 原生 CSS，完美支持
- 小程序：✅ CSS 动画支持，但 `upx` 在 webview 中渲染与小程序 rpx 表现略有差异
- App：✅ nvue 需注意部分 CSS 动画属性可能不被支持，建议用 view + vue 动画兜底