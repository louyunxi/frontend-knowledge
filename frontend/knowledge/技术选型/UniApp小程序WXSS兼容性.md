---
title: "UniApp 小程序 WXSS 兼容性"
description: "UniApp 开发小程序时的 WXSS 限制与兼容性处理：伪元素、属性选择器、:deep()、custom-class 覆盖方案"
tags: ["uniapp", "小程序", "wxss", "兼容性", "compatibility", "技术选型"]
complexity: ⭐⭐
domain: tech
---

# UniApp 小程序 WXSS 兼容性

## 概述

UniApp 在编译到微信小程序时，样式语言从 CSS 变为 WXSS，存在多项限制。了解这些限制并采用正确的兼容性方案，是确保跨端一致性的关键。

## 来源

- Skill: `uniapp`
- 来源文件: `SKILL.md` Part 9 小程序兼容性
- 蒸馏类型: best
- 蒸馏时间: 2026-09-15

## WXSS 限制速查表

| CSS 特性 | WXSS 支持 | 替代方案 |
|---------|---------|---------|
| `:deep()` | ❌ | `::v-deep` 或 `::shadow` |
| `[attr*="val"]` | ❌ | 改用 class 选择器 |
| `::before / ::after` | ❌（部分） | 使用 view 组件替代 |
| 复杂属性选择器 | ❌ | 改用 class |
| 外部字体 | ⚠️ 限制 | 使用 iconfont 或 base64 |
| CSS 变量 | ⚠️ 基础支持 | 避免深层嵌套 |
| `calc()` | ✅ 支持 | 直接使用 |
| `flex` | ✅ 支持 | — |
| `position: sticky` | ⚠️ 部分支持 | — |
| `backdrop-filter` | ❌ | 使用图片模拟 |
| `transition` | ✅ 支持 | — |
| `transform` | ✅ 支持 | — |

## 关键限制详解

### 1. 伪元素（::before / ::after）

```scss
// ❌ 错误：WXSS 中伪元素支持不稳定
.card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 4rpx;
  background: var(--color-primary);
}

// ✅ 正确：使用 view 组件替代
```

```vue
<template>
  <view class="card">
    <!-- 用 view 模拟伪元素 -->
    <view class="card__top-line"></view>
    <view class="card__content">内容</view>
  </view>
</template>

<style>
.card {
  position: relative;

  &__top-line {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 4rpx;
    background: var(--color-primary);
  }

  &__content {
    position: relative;
    z-index: 1;
  }
}
</style>
```

### 2. 属性选择器

```scss
// ❌ 错误：WXSS 不支持属性选择器变体
[type*=val] { }      /* 不支持 */
[type^=val] { }      /* 不支持 */
[type$=val] { }      /* 不支持 */

// ✅ 正确：使用 class 选择器
.input--error { }
.input--disabled { }
```

### 3. 深度选择器

```scss
// Vue SFC 中处理子组件样式

// ❌ App 端/H5
.parent :deep(.child) {
  color: red;
}

// ✅ 小程序端 - 三种兼容写法
.parent ::v-deep .child {
  color: red;
}

// 或使用 >>>（部分编译器支持）
.parent >>> .child {
  color: red;
}

// 或使用 /deep/（已废弃，仅旧编译器支持）
.parent /deep/ .child {
  color: red;
}
```

### 4. wot-design-uni 组件样式覆盖

```vue
<!-- 正确方式：使用 custom-class 属性 -->
<template>
  <wd-button
    custom-class="my-custom-button"
    type="primary"
    @click="handleClick"
  >
    提交
  </wd-button>
</template>

<style>
/* 在页面或全局样式中覆盖 */
.my-custom-button {
  border-radius: 36rpx;
  font-size: 28rpx;
}
</style>
```

### 5. 外部字体引入

```scss
// ❌ 错误：微信小程序外部字体支持极其有限
@font-face {
  font-family: 'CustomFont';
  src: url('https://example.com/font.woff2');
}

// ✅ 正确：使用 iconfont
/* 方案1: base64 内嵌（小字体）*/
@font-face {
  font-family: 'IconFont';
  src: url('data:font/woff2;base64,...');
}

// 方案2: iconfont 方式
/* 在 iconfont.cn 生成后下载，按文档引入 */
@import url('iconfont.ttf');
```

### 6. backdrop-filter 模拟

```scss
// ❌ 错误：小程序不支持 backdrop-filter
.modal-overlay {
  backdrop-filter: blur(10px);
}

// ✅ 正确：使用图片或纯色遮罩
.modal-overlay {
  background: rgba(0, 0, 0, 0.5);
  /* 或使用半透明渐变背景图 */
  background: linear-gradient(
    to bottom,
    rgba(0, 0, 0, 0.3) 0%,
    rgba(0, 0, 0, 0.6) 100%
  );
}
```

## 跨平台代码组织策略

### 策略一：平台条件编译

```scss
/* #ifdef MP-WEIXIN */
// 微信小程序专用样式
.mp-only-style {
  /* ... */
}
/* #endif */

/* #ifdef H5 */
// H5 专用样式
.h5-only-style {
  backdrop-filter: blur(10px);
}
/* #endif */

/* #ifdef APP-PLUS */
// App 端专用样式
.app-only-style {
  /* ... */
}
/* #endif */
```

### 策略二：样式分离文件

```
src/styles/
├── common.scss         # 所有平台通用样式
├── mp-weixin.scss      # 微信小程序专用
├── h5.scss             # H5 专用
└── app.scss            # App 专用
```

### 策略三：避免平台差异的写法

```scss
// 最佳实践：优先使用 WXSS 支持的特性
// 这样所有平台都能正常工作

// ✅ 安全写法：所有平台都支持
.card {
  display: flex;
  flex-direction: column;
  padding: 32rpx;
  background: var(--color-bg-card);
  border-radius: 16rpx;
  box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.08);
}

// ❌ 危险写法：依赖小程序不支持的特性
.danger-card {
  /* 小程序不支持 backdrop-filter */
  backdrop-filter: blur(10px);

  /* 小程序不支持复杂属性选择器 */
  [data-theme='dark'] & {
    background: #1a1a1a;
  }
}
```

## UnoCSS 兼容性

```js
// uno.config.ts - 排除不兼容的规则
export default defineConfig({
  rules: [
    // 排除伪元素相关
    ['before:', () => ({})],
    ['after:', () => ({})],

    // 排除 backdrop-filter
    ['backdrop-blur:', () => ({})],
  ],

  // 或使用 safelist 白名单
  safelist: [
    'backdrop-blur-sm',
    'backdrop-blur-lg',
  ],
})
```

## 兼容性检查清单

```markdown
发布前检查：
□ 是否使用了 ::before / ::after？ → 改为 view 组件
□ 是否使用了属性选择器 [attr*=]？ → 改为 class
□ 是否使用了 :deep()？ → 改为 ::v-deep
□ 是否使用了 backdrop-filter？ → 改为图片模拟
□ 是否引用了外部字体？ → 改为 iconfont 或 base64
□ wot-design-uni 组件是否用了 custom-class 覆盖？
□ 是否有平台条件编译处理差异样式？
□ 暗黑模式是否在 WXSS 环境下正常工作？
```

## 反模式

- ❌ 依赖伪元素做 UI 效果 → 小程序不支持
- ❌ 在组件内直接改 wot-design-uni 源码样式 → 升级会被覆盖
- ❌ 混用平台条件编译和普通样式 → 维护困难
- ❌ 引用网络字体文件 → 微信小程序域名白名单限制

## 关键词

| 关键词 | 同义词 | 语义变体 |
|--------|--------|---------|
| WXSS | 微信样式表 | "WXSS语法" |
| 小程序兼容 | mini-program compat | "微信兼容", "跨端兼容" |
| 伪元素 | pseudo-element | "::before", "::after" |
| 深度选择器 | deep selector | ":deep()", "::v-deep" |
| custom-class | 定制类名 | "样式覆盖", "组件样式" |
| 条件编译 | conditional compile | "#ifdef", "平台判断" |
| backdrop-filter | 背景滤镜 | "模糊背景" |

## 语义标签

`uniapp` `wxss` `mini-program` `compatibility` `cross-platform` `vue` `css`

## 相关知识

- UniApp CSS 分层策略
- UniApp 移动端 Token 系统
- UniApp 反模式清单
- 设计原则-移动端阴影与质感
