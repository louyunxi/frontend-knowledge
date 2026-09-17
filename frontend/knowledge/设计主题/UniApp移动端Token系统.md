---
title: "UniApp 移动端 Token 系统"
description: "UniApp 移动端设计 Token 系统：颜色、背景、文字、边框、z-index、间距、圆角、阴影、字体、UnoCSS shortcuts"
tags: ["uniapp", "design-token", "css-variables", "token", "暗黑模式", "设计主题"]
complexity: ⭐⭐
domain: design
---

# UniApp 移动端 Token 系统

## 概述

UniApp 移动端 Token 系统是基于 CSS 变量的完整设计规范，覆盖颜色、间距、圆角、阴影、字体、z-index 等所有视觉维度。所有组件样式必须引用 token，禁止硬编码。

## 来源

- Skill: `uniapp`
- 来源文件: `SKILL.md` Part 7 主题变量系统
- 蒸馏类型: best
- 蒸馏时间: 2026-09-15

## 核心规则

```
一条铁律：所有视觉值必须来自 Token，禁止硬编码任何数值。
```

## Token 分类

```
Token 系统
├── 颜色 ──── 语义色（主色/成功/警告/错误/信息）
├── 背景 ──── 页面/卡片/浮层/遮罩背景
├── 文字 ──── 主要/次要/辅助/禁用/反白
├── 边框 ──── 分割线/卡片边框/输入框边框
├── z-index ── 层级系统（dropdown → navbar → fab）
├── 间距 ──── 基于 8rpx 的间距序列
├── 圆角 ──── 小/中/大/全圆角
├── 阴影 ──── 浅/中/深 阴影
└── 字体 ──── 字号/字重/行高
```

## 完整 Token 体系

### 1. 颜色（语义色）

```scss
// src/styles/theme.scss

:root {
  /* 主题色 - 建议品牌色 */
  --color-primary: #3b82f6;
  --color-primary-light: #60a5fa;
  --color-primary-dark: #2563eb;

  /* 功能色 */
  --color-success: #22c55e;
  --color-warning: #f59e0b;
  --color-error: #ef4444;
  --color-info: #3b82f6;

  /* 白色/黑色 */
  --color-white: #ffffff;
  --color-black: #000000;
}
```

### 2. 背景色

```scss
// src/styles/theme.scss

:root {
  /* 页面背景 */
  --color-bg-page: #f5f5f5;

  /* 卡片/容器背景 */
  --color-bg-card: #ffffff;
  --color-bg-secondary: #fafafa;

  /* 浮层背景 */
  --color-bg-overlay: rgba(0, 0, 0, 0.5);
  --color-bg-mask: rgba(0, 0, 0, 0.4);

  /* 输入框背景 */
  --color-bg-input: #f7f7f7;
}
```

### 3. 文字色

```scss
// src/styles/theme.scss

:root {
  /* 主要文字 - 正文内容 */
  --color-text-primary: #18181b;

  /* 次要文字 - 辅助说明 */
  --color-text-secondary: #52525b;

  /* 占位符/辅助文字 */
  --color-text-tertiary: #a1a1aa;

  /* 禁用文字 */
  --color-text-disabled: #d4d4d8;

  /* 反白文字（用于深色背景） */
  --color-text-inverse: #ffffff;
}
```

### 4. 边框色

```scss
// src/styles/theme.scss

:root {
  /* 主要边框 */
  --color-border: #e4e4e7;
  --color-border-light: #f4f4f5;

  /* 输入框边框 */
  --color-border-input: #d4d4d8;
  --color-border-input-focus: var(--color-primary);

  /* 分割线 */
  --color-divider: #f4f4f5;
}
```

### 5. Z-Index 层级系统（语义化）

```scss
// src/styles/theme.scss

:root {
  /* 静态定位 */
  --z-base: 0;

  /* 浮于内容之上 */
  --z-dropdown: 100;     /* 下拉菜单 */
  --z-sticky: 200;        /* 吸顶导航 */

  /* 遮罩层 */
  --z-overlay: 300;      /* 遮罩 */
  --z-popup: 400;         /* 气泡/弹出层 */

  /* 交互层 */
  --z-dialog: 500;        /* 弹窗/对话框 */
  --z-toast: 600;         /* Toast 消息 */
  --z-notification: 700;  /* 通知 */

  /* 导航层（最高） */
  --z-navbar: 800;        /* 顶部导航 */
  --z-tabbar: 900;       /* 底部 TabBar */
  --z-fab: 1000;          /* 浮动操作按钮 */
  --z-safety: 9999;       /* 安全区（极少数场景） */
}
```

### 6. 间距系统（基于 8rpx）

```scss
// src/styles/theme.scss

:root {
  /* 核心间距（使用最频繁） */
  --space-1: 8rpx;    /* 图标与文字间距 */
  --space-2: 16rpx;   /* 紧凑间距 */
  --space-3: 24rpx;   /* 标准间距 */
  --space-4: 32rpx;   /* 宽松间距 */
  --space-5: 40rpx;   /* 卡片内间距 */

  /* 扩展间距 */
  --space-6: 48rpx;
  --space-8: 64rpx;
  --space-10: 80rpx;

  /* 极小/极大 */
  --space-xs: 4rpx;
  --space-xl: 96rpx;
}
```

### 7. 圆角系统

```scss
// src/styles/theme.scss

:root {
  /* 圆角 token */
  --radius-xs: 4rpx;    /* 标签/徽章 */
  --radius-sm: 8rpx;   /* 按钮/输入框 */
  --radius-md: 12rpx;   /* 卡片 */
  --radius-lg: 16rpx;   /* 大卡片 */
  --radius-xl: 24rpx;   /* 模态框 */
  --radius-full: 9999rpx; /* 圆形/胶囊按钮 */
}
```

### 8. 阴影系统

```scss
// src/styles/theme.scss

:root {
  /* 浅阴影 - 卡片悬浮 */
  --shadow-sm: 0 1rpx 2rpx 0 rgba(0, 0, 0, 0.05);

  /* 中阴影 - 卡片默认 */
  --shadow-md: 0 2rpx 8rpx 0 rgba(0, 0, 0, 0.08);

  /* 深阴影 - 弹窗/浮层 */
  --shadow-lg: 0 8rpx 24rpx 0 rgba(0, 0, 0, 0.12);

  /* 无阴影 */
  --shadow-none: none;
}
```

### 9. 字体系统

```scss
// src/styles/theme.scss

:root {
  /* 字号 */
  --text-xs: 22rpx;    /* 辅助文字 */
  --text-sm: 24rpx;    /* 小正文 */
  --text-base: 28rpx;  /* 正文（基准） */
  --text-lg: 32rpx;    /* 大标题 */
  --text-xl: 36rpx;    /* 页面标题 */
  --text-2xl: 44rpx;   /* 大数字 */
  --text-3xl: 52rpx;   /* Hero 数字 */

  /* 字重 */
  --font-normal: 400;
  --font-medium: 500;
  --font-semibold: 600;
  --font-bold: 700;

  /* 行高 */
  --leading-tight: 1.2;
  --leading-normal: 1.5;
  --leading-relaxed: 1.75;
}
```

## 暗黑模式

```scss
// src/styles/theme.scss

[data-theme='dark'] {
  /* 暗黑主题颜色覆盖 */
  --color-primary: #60a5fa;
  --color-bg-page: #09090b;
  --color-bg-card: #18181b;
  --color-bg-secondary: #27272a;

  --color-text-primary: #fafafa;
  --color-text-secondary: #a1a1aa;
  --color-text-tertiary: #71717a;

  --color-border: #3f3f46;
  --color-border-light: #27272a;

  /* 暗黑阴影（更浅） */
  --shadow-sm: 0 1rpx 2rpx 0 rgba(0, 0, 0, 0.3);
  --shadow-md: 0 2rpx 8rpx 0 rgba(0, 0, 0, 0.4);
  --shadow-lg: 0 8rpx 24rpx 0 rgba(0, 0, 0, 0.5);
}
```

## UnoCSS Shortcuts（常用组合）

```js
// uno.config.ts
export default defineConfig({
  shortcuts: {
    // 布局
    'flex-center': 'flex justify-center items-center',
    'flex-between': 'flex justify-between items-center',
    'flex-col': 'flex flex-col',
    'gap-2': 'gap-2 gap-y-2',       // 8rpx
    'gap-3': 'gap-3 gap-y-3',       // 12rpx
    'gap-4': 'gap-4 gap-y-4',       // 16rpx

    // 文字
    'text-ellipsis': 'overflow-hidden text-ellipsis whitespace-nowrap',
    'text-balance': 'text-wrap pretty',

    // 圆角
    'rounded-full': 'rounded-full',
    'rounded-card': 'rounded-md',

    // 卡片
    'card': 'bg-[var(--color-bg-card)] rounded-md p-4',
    'card-section': 'px-4 py-3',

    // 按钮
    'btn-primary': 'px-4 py-2 rounded-full bg-[var(--color-primary)] text-white text-sm font-medium',
    'btn-ghost': 'px-4 py-2 rounded-full border border-[var(--color-border)] text-[var(--color-text-primary)] text-sm',
  },
})
```

## 使用示例

```vue
<template>
  <!-- 模板中使用 token -->
  <view class="user-card">
    <view class="user-card__avatar">
      <image src="avatar.jpg" />
    </view>
    <view class="user-card__info">
      <text class="user-card__name">张三</text>
      <text class="user-card__desc">产品设计师</text>
    </view>
    <view class="user-card__action">
      <button class="user-card__btn--follow">关注</button>
    </view>
  </view>
</template>

<style lang="scss">
.user-card {
  display: flex;
  align-items: center;
  padding: var(--space-4);
  background: var(--color-bg-card);
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-md);

  &__avatar {
    width: 96rpx;
    height: 96rpx;
    border-radius: 50%;
    overflow: hidden;

    image {
      width: 100%;
      height: 100%;
    }
  }

  &__info {
    flex: 1;
    margin-left: var(--space-3);
  }

  &__name {
    display: block;
    font-size: var(--text-lg);
    font-weight: var(--font-semibold);
    color: var(--color-text-primary);
    line-height: var(--leading-tight);
  }

  &__desc {
    display: block;
    margin-top: var(--space-1);
    font-size: var(--text-sm);
    color: var(--color-text-tertiary);
  }

  &__btn--follow {
    padding: var(--space-1) var(--space-3);
    font-size: var(--text-sm);
    font-weight: var(--font-medium);
    color: var(--color-white);
    background: var(--color-primary);
    border-radius: var(--radius-full);
    border: none;
    z-index: var(--z-dropdown);
  }
}
</style>
```

## 反模式

- ❌ 硬编码颜色 `#ffffff`、`#333333` → 必须用 `var(--color-*)`
- ❌ 魔法 z-index `z-index: 999` → 必须用语义化 token
- ❌ 混用 px 和 rpx → 统一使用 rpx
- ❌ 样式中使用中文注释 → 用英文或 SCSS 标准注释
- ❌ 为每个组件单独定义颜色 → 统一引用 token

## 关键词

| 关键词 | 同义词 | 语义变体 |
|--------|--------|---------|
| Token | 设计令牌, design token | "变量系统", "设计变量" |
| CSS变量 | CSS custom property | "CSS变量", "custom property" |
| 语义色 | semantic color | "语义化颜色" |
| z-index层级 | z层级 | "浮层层级", "堆叠顺序" |
| 暗黑模式 | dark mode | "夜间模式", "深色主题" |
| UnoCSS shortcuts | UnoCSS快捷方式 | "原子类组合" |

## 语义标签

`design-token` `css-variables` `uniapp` `dark-mode` `theme` `z-index` `spacing` `radius` `shadow` `typography` `shortcuts`

## 相关知识

- UniApp CSS 分层策略
- UniApp 反模式清单
- 设计原则-移动端阴影与质感
- 8 点栅格系统
- 设计原则-移动端排版规范
