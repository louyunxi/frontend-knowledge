---
title: "UniApp CSS分层策略"
description: "UniApp 移动端 CSS 架构规范：BEM + UnoCSS + SCSS 混合分层策略"
tags: ["uniapp", "css", "bem", "unocss", "scss", "项目规范"]
complexity: ⭐⭐
domain: standard
---

# UniApp CSS 分层策略

## 概述

UniApp 移动端 CSS 采用三层架构：**BEM 业务层 + UnoCSS 原子层 + SCSS 工具层**。三层各司其职，避免样式混乱。

## 来源

- Skill: `uniapp`
- 来源文件: `SKILL.md` Part 0 强制规则 & Part 3 CSS 使用边界
- 蒸馏类型: best
- 蒸馏时间: 2026-09-15

## 核心规则

### 三层架构

```
┌─────────────────────────────────────────────┐
│  SCSS 工具层 ─── 全局变量、mixin、函数         │
│  (变量/混合宏/占位符)                          │
├─────────────────────────────────────────────┤
│  BEM 业务层 ─── 组件样式、页面样式              │
│  (useXXX.scss / pageXXX.scss)                │
├─────────────────────────────────────────────┤
│  UnoCSS 原子层 ─── 简单样式、布局、间距        │
│  (≤3 个原子类时直接用 UnoCSS)                 │
└─────────────────────────────────────────────┘
```

### 层使用规则

```text
规则一：≤3 个原子类 → 用 UnoCSS
规则二：>3 个原子类 → 用 BEM
规则三：变量/mixin/嵌套 → 用 SCSS
```

### 判断标准

```text
场景A：单个 div，需要 2 个样式
  class="flex items-center gap-2"
  ✅ 符合 → UnoCSS 直接写

场景B：复杂组件，需要 5+ 个样式
  class="profile-card__header"
  ❌ 违反规则 → 改为 BEM

场景C：需要变量、嵌套、mixin
  → 统一在 SCSS 文件中管理
```

## 实施模板

### BEM 命名规范

```scss
// 块 Block
.profile-card { }

// 元素 Element（双下划线）
.profile-card__header { }
.profile-card__avatar { }
.profile-card__name { }
.profile-card__footer { }

// 修饰符 Modifier（双短横线）
.profile-card__btn--primary { }
.profile-card__btn--secondary { }
.profile-card__avatar--large { }

// 页面前缀（推荐）
// 块名 = page前缀 + 实体
.profile-card { }      // profile 页面 + card 实体
.mine-hero { }         // mine 页面 + hero 实体
.work-menu { }         // work 页面 + menu 实体
```

### Vue 单文件组件

```vue
<template>
  <!-- 原子类 ≤3 时直接用 UnoCSS -->
  <view class="profile-card p-4 rounded-lg">
    <view class="profile-card__header flex items-center gap-3">
      <image class="profile-card__avatar w-12 h-12 rounded-full" />
      <text class="profile-card__name font-medium">张三</text>
    </view>
    <view class="profile-card__footer mt-3 flex justify-between">
      <text class="profile-card__stats text-sm text-gray-500">128 粉丝</text>
      <button class="profile-card__btn--primary px-4 py-2 rounded-full">
        关注
      </button>
    </view>
  </view>
</template>

<style lang="scss">
// BEM 复杂样式放 SCSS 文件
// 路径: styles/bem/useProfileCard.scss
@import './bem/useProfileCard.scss';
</style>
```

```scss
// styles/bem/useProfileCard.scss

// BEM 块定义
.use-profile-card {
  background: var(--color-bg-secondary);
  border-radius: var(--radius-xl);

  &__header {
    padding: var(--space-4);
    border-bottom: 1px solid var(--color-border);
  }

  &__avatar {
    width: 96rpx;
    height: 96rpx;
    border-radius: 50%;
    object-fit: cover;

    &--large {
      width: 160rpx;
      height: 160rpx;
    }
  }

  &__name {
    font-size: var(--text-lg);
    font-weight: 600;
    color: var(--color-text-primary);
  }

  &__stats {
    font-size: var(--text-sm);
    color: var(--color-text-tertiary);
  }

  &__btn--primary {
    background: var(--color-primary);
    color: #fff;
    font-size: var(--text-sm);
    font-weight: 500;
    padding: var(--space-2) var(--space-4);
    border-radius: 999px;
  }

  &__footer {
    padding: var(--space-3) var(--space-4);
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
}
```

### SCSS 变量层

```scss
// src/styles/variables.scss

// 颜色变量（全局）
$color-primary: var(--color-primary);
$color-success: var(--color-success);

// 间距 token
$space-base: 8rpx;

// 混合宏
@mixin flex-center {
  display: flex;
  justify-content: center;
  align-items: center;
}

@mixin text-ellipsis {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

// 占位符
%card-base {
  background: var(--color-bg-secondary);
  border-radius: var(--radius-lg);
  padding: var(--space-4);
}
```

### UnoCSS shortcuts 配置

```js
// uno.config.ts
import { defineConfig, shortcuts } from 'unocss'

export default defineConfig({
  shortcuts: {
    // 布局
    'flex-center': 'flex justify-center items-center',
    'flex-between': 'flex justify-between items-center',
    'flex-col-center': 'flex flex-col justify-center items-center',

    // 卡片
    'card-base': 'bg-white rounded-xl p-4 shadow-sm',
    'card-section': 'px-4 py-3',

    // 文字
    'text-ellipsis': 'overflow-hidden text-ellipsis whitespace-nowrap',
    'text-balance': 'text-wrap pretty',

    // 按钮
    'btn-primary': 'px-4 py-2 rounded-full bg-primary text-white text-sm font-medium',
    'btn-ghost': 'px-4 py-2 rounded-full border border-gray-200 text-gray-700 text-sm',
  },

  rules: [
    // 自定义 rpx 规则（可选）
    [/^w-(\d+)rpx$/, ([, d]) => ({ width: `${d}rpx` })],
    [/^h-(\d+)rpx$/, ([, d]) => ({ height: `${d}rpx` })],
  ],
})
```

## 组件样式文件组织

```text
src/
├── styles/
│   ├── variables.scss        # SCSS 全局变量 + mixin
│   ├── theme.scss            # CSS 变量定义（暗黑模式）
│   ├── bem/                  # BEM 样式块
│   │   ├── useProfileCard.scss
│   │   ├── useMineHero.scss
│   │   └── useWorkMenu.scss
│   └── index.scss            # 全局样式入口
├── pages/
│   ├── profile/
│   │   ├── profile.vue       # 页面组件
│   │   └── profile.config.ts
│   └── mine/
│       └── mine.vue
└── uni.scss                  # UniApp 全局样式入口
```

## 暗黑模式支持

```scss
// 所有颜色使用 CSS 变量
.profile-card {
  background: var(--color-bg-secondary);
  color: var(--color-text-primary);

  &__avatar {
    border: 2px solid var(--color-border);
  }

  &__btn--primary {
    background: var(--color-primary);
    color: var(--color-white);
  }
}
```

```scss
// src/styles/theme.scss
// 暗色主题覆盖
[data-theme='dark'] {
  --color-bg-secondary: #1f1f1f;
  --color-text-primary: #ffffff;
  --color-text-tertiary: rgba(255, 255, 255, 0.45);
  --color-border: #303030;
  --color-primary: #4a9eff;
}
```

## 反模式

- ❌ 全部使用原子类（无 BEM）→ 维护困难
- ❌ 全部使用 BEM（无原子类）→ 冗长
- ❌ 硬编码颜色 `#ffffff`、`#333333` → 必须用 `var(--color-*)`
- ❌ 在模板中写大量内联 style → 破坏分层
- ❌ UnoCSS 和 BEM 混用造成覆盖冲突

## 关键词

| 关键词 | 同义词 | 语义变体 |
|--------|--------|---------|
| CSS分层 | 分层架构, 层叠策略 | "样式分层", "CSS结构" |
| BEM | Block Element Modifier | "块元素修饰符" |
| UnoCSS | 原子CSS, Uno原子 | "原子化CSS", "utility-first" |
| SCSS | sass, 嵌套CSS | "sass变量", "混合宏" |
| 原子类 | utility class | "工具类", "UnoCSS类" |
| BEM命名 | BEM规范 | "块名命名", "修饰符命名" |

## 语义标签

`css` `bem` `unocss` `scss` `uniapp` `dark-mode` `mobile-ui` `naming` `architecture`

## 相关知识

- UniApp 移动端 Token 系统
- UniApp 小程序 WXSS 兼容性
- UniApp 反模式清单
- 设计原则-移动端排版规范
- 8 点栅格系统
