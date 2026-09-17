---
title: "UniApp 移动端反模式清单"
description: "UniApp 开发中的 10 条常见反模式及正确做法"
tags: ["uniapp", "反模式", "移动端", "best-practice", "项目规范"]
complexity: ⭐
domain: standard
---

# UniApp 移动端反模式清单

## 概述

UniApp 移动端开发中有 10 条高频反模式，涵盖颜色、层级、布局、图标、字体等方面。这些问题在小程序和 App 端都会造成体验或兼容性问题。

## 来源

- Skill: `uniapp`
- 来源文件: `SKILL.md` Part 10 反模式
- 蒸馏类型: best
- 蒸馏时间: 2026-09-15

## 10 条反模式

### 1. 硬编码颜色值

```scss
// ❌ 错误：直接写十六进制颜色
.text { color: #333333; }
.bg { background: #ffffff; }
.border { border: 1px solid #e5e5e5; }

// ✅ 正确：使用 CSS 变量
.text { color: var(--color-text-primary); }
.bg { background: var(--color-bg-base); }
.border { border: 1px solid var(--color-border); }
```

**原因**: 硬编码颜色无法响应暗黑模式，且不便于主题切换。

---

### 2. 使用魔法 z-index 值

```scss
// ❌ 错误：随机写 z-index
.dropdown { z-index: 999; }
.modal { z-index: 9999; }
.toast { z-index: 99999; }
.popup { z-index: 12345; }

// ✅ 正确：使用语义化 z-index token
.dropdown { z-index: var(--z-dropdown); }    // 100
.modal { z-index: var(--z-modal); }         // 500
.toast { z-index: var(--z-toast); }         // 600
.popup { z-index: var(--z-popup); }         // 400
```

**原因**: 魔法数值不可维护，容易产生层级冲突。统一使用语义化 z-index 层级系统。

---

### 3. 使用 100vh 固定高度

```vue
<!-- ❌ 错误：100vh 在移动端有问题 -->
<template>
  <view class="page" style="height: 100vh;">
    <view class="content">内容</view>
  </view>
</template>

<!-- ✅ 正确：使用 min-height + 内容撑开 -->
<template>
  <view class="page">
    <view class="content">内容</view>
  </view>
</template>

<style>
.page {
  min-height: 100vh;
  /* 或使用 CSS 变量 */
  min-height: var(--vh);
  background: var(--color-bg-base);
}

.content {
  padding: var(--space-4);
}
</style>
```

```js
// 处理 100vh 在 iOS 移动浏览器的兼容问题
// main.js
document.documentElement.style.setProperty('--vh', `${window.innerHeight * 0.01}px`)
```

**原因**: 移动端 100vh 包含地址栏高度，视觉上会溢出。使用 `min-height` 或 JS 计算的 CSS 变量更可靠。

---

### 4. 使用 AI 生成的渐变色

```scss
// ❌ 错误：AI 生成的随机渐变
.hero {
  background: linear-gradient(
    135deg,
    rgba(255, 127, 80, 0.8) 0%,
    rgba(100, 200, 255, 0.6) 50%,
    rgba(200, 150, 255, 0.4) 100%
  );
}

// ✅ 正确：使用品牌主色 + 透明度变化
.hero {
  background: var(--color-primary);

  &::after {
    content: '';
    position: absolute;
    inset: 0;
    background: linear-gradient(
      to bottom,
      transparent 0%,
      rgba(0, 0, 0, 0.1) 100%
    );
  }
}
```

**原因**: AI 生成的渐变往往是随机配色，缺乏品牌一致性，且可能在不同设备上显示异常。

---

### 5. 使用 Emoji 作为图标

```vue
<!-- ❌ 错误：Emoji 兼容性差 -->
<view class="icon">📱</view>
<view class="icon">⭐</view>
<view class="icon">✅</view>
<view class="icon">🔥</view>

<!-- ✅ 正确：使用图标组件 -->
<view class="icon">
  <u-icon name="phone" />
</view>
<view class="icon">
  <u-icon name="star" />
</view>

<!-- 或使用 iconfont -->
<view class="icon iconfont icon-star" />
```

**原因**:
- Emoji 跨平台显示不一致（不同系统渲染差异大）
- Emoji 无法统一调整颜色、大小
- 语义化不如具名图标清晰

---

### 6. 混用 px 和 rpx

```scss
// ❌ 错误：混用单位
.card {
  padding: 16px;       // px 单位
  margin: 32rpx;       // rpx 单位
  font-size: 28rpx;
}

// ✅ 正确：统一使用 rpx（移动端推荐）
.card {
  padding: 24rpx;
  margin: 32rpx;
  font-size: 28rpx;
}

// ✅ 或统一使用 rem（配合根字体）
.card {
  padding: 0.32rem;
  margin: 0.42rem;
  font-size: 0.37rem;
}
```

**原因**: 混用 px 和 rpx 导致不同设备的视觉不一致。移动端统一使用 rpx 确保等比缩放。

---

### 7. 过度嵌套的 BEM 命名

```scss
// ❌ 错误：过度嵌套的 BEM（超过 3 层）
.profile-card__header__avatar__badge { }
.profile-card__header__avatar__name__text { }

// ✅ 正确：保持扁平结构，最多 2 层
.profile-card__avatar { }
.profile-card__avatar-badge { }
.profile-card__name-text { }
```

**原因**: 过度嵌套的 BEM 命名过长、不易维护，且在移动端编译性能更差。

---

### 8. 在 CSS 中使用 DOM API

```scss
// ❌ 错误：CSS 中使用 JavaScript 能力
.page {
  height: calc(100vh - env(safe-area-inset-bottom));
  /* 这个在部分小程序不支持 */
}

// ✅ 正确：安全区域使用 safe-area 属性 + 垫片
.page {
  padding-bottom: constant(safe-area-inset-bottom);
  padding-bottom: env(safe-area-inset-bottom);
}
```

**原因**: WXSS/CSS 中某些 CSS 环境变量和函数在小程序中不被支持。

---

### 9. 忽视暗黑模式

```vue
<!-- ❌ 错误：只写亮色样式 -->
<template>
  <view class="card">
    <text>卡片内容</text>
  </view>
</template>

<style>
.card {
  background: #ffffff;
  color: #333333;
  border: 1px solid #e5e5e5;
}
</style>

<!-- ✅ 正确：使用 CSS 变量 + 暗黑覆盖 -->
<style>
.card {
  background: var(--color-bg-base);
  color: var(--color-text-primary);
  border: 1px solid var(--color-border);
}

/* 暗黑模式由全局 theme.scss 处理 */
</style>
```

**原因**: 暗黑模式是移动端标配，不支持暗色的应用在夜间使用体验极差，且用户可能直接卸载。

---

### 10. 组件内硬编码间距

```vue
<!-- ❌ 错误：每个组件独立写间距 -->
<template>
  <view class="card" style="padding: 24rpx;">
    <text class="name">张三</text>
  </view>
</template>

<!-- ✅ 正确：使用统一的间距 token -->
<style lang="scss">
.card {
  padding: var(--space-4);  // 32rpx = 16px

  .name {
    margin-top: var(--space-2);  // 16rpx = 8px
  }
}
</style>
```

**原因**: 硬编码间距导致视觉不统一，维护成本高。统一使用间距 token 系统确保一致性。

## 反模式速查表

| # | 反模式 | 问题 | 正确做法 |
|---|--------|------|---------|
| 1 | 硬编码颜色 | 无暗黑模式 | `var(--color-*)` |
| 2 | 魔法 z-index | 层级冲突 | 语义化 z-index token |
| 3 | 100vh 固定高度 | iOS 地址栏溢出 | `min-height` 或 JS 计算 |
| 4 | AI 渐变色 | 品牌不一致 | 品牌主色 + 透明度 |
| 5 | Emoji 图标 | 跨平台差异 | 图标组件 / iconfont |
| 6 | 混用 px/rpx | 缩放不一致 | 统一 rpx |
| 7 | 过度 BEM 嵌套 | 命名过长 | 最多 2 层 |
| 8 | CSS DOM API | 小程序不兼容 | CSS 原生方案 |
| 9 | 无暗黑模式 | 夜间体验差 | CSS 变量 + 主题覆盖 |
| 10 | 硬编码间距 | 不一致 | 统一间距 token |

## 关键词

| 关键词 | 同义词 | 语义变体 |
|--------|--------|---------|
| 反模式 | antipattern, anti-pattern | "错误做法", "反面教材" |
| 硬编码 | hardcode | "写死", "固定值" |
| 魔法数字 | magic number | "魔法值", "随机数" |
| 100vh | 100%高度 | "全屏高度" |

## 语义标签

`uniapp` `mobile-ui` `antipattern` `dark-mode` `css-variables` `z-index` `compatibility`

## 相关知识

- UniApp CSS 分层策略
- UniApp 移动端 Token 系统
- UniApp 小程序 WXSS 兼容性
- 设计原则-移动端阴影与质感
