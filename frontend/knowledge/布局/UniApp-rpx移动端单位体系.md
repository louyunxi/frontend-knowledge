---
title: "UniApp rpx 移动端单位体系"
description: "UniApp 移动端 rpx 单位规范：750rpx 基准、偶数字号、4 倍数间距，与 rem/vh/vw 的对比与选择"
tags: ["uniapp", "rpx", "单位", "移动端", "布局", "spacing"]
complexity: ⭐
domain: layout
---

# UniApp rpx 移动端单位体系

## 概述

rpx（responsive pixel）是 UniApp 为移动端设计的响应式单位，以屏幕宽度为基准（750rpx = 屏幕宽度），确保在不同尺寸的移动设备上按比例缩放。UniApp 项目中所有尺寸统一使用 rpx，禁止混用 px/rem/vw。

## 来源

- Skill: `uniapp`
- 来源文件: `SKILL.md` Part 8 rpx 单位规范
- 蒸馏类型: best
- 蒸馏时间: 2026-09-15

## 核心规则

```
规则一：750rpx = 屏幕宽度（设计稿基准）
规则二：字号使用偶数字号
规则三：间距使用 4 的倍数（rpx）
规则四：禁止混用 px 和 rpx
```

## 单位对比

| 单位 | 基准 | 适用场景 | UniApp 推荐 |
|------|------|---------|------------|
| rpx | 屏幕宽度 750rpx | 移动端所有尺寸 | ✅ 全部使用 |
| px | 物理像素 | 不推荐 | ❌ 禁止 |
| rem | 根字体大小 | 响应式网页 | ⚠️ 可用但首选 rpx |
| vh/vw | 视口宽高 | Web 响应式 | ❌ 不推荐移动端 |
| % | 父元素 | 相对布局 | ⚠️ 特殊场景可用 |

## rpx 换算规则

### 基础换算

```
设计稿（750px 宽度） → rpx 值 = 设计稿像素值
设计稿（375px 宽度） → rpx 值 = 设计稿像素值 × 2
```

### 常见换算表

| 设计稿像素 | rpx 值 | 说明 |
|-----------|--------|------|
| 4px | 8rpx | 最小间距 |
| 8px | 16rpx | 紧密间距 |
| 12px | 24rpx | 标准间距 |
| 16px | 32rpx | 卡片内边距 |
| 20px | 40rpx | 中等间距 |
| 24px | 48rpx | 宽松间距 |
| 32px | 64rpx | 大间距 |
| 48px | 96rpx | 区块间距 |

### 字号换算（偶数字号）

```scss
// 设计稿字号 → rpx 字号（必须为偶数）
// 11px → ❌ → 22rpx → ✅ 偶数
// 13px → 26rpx → ✅ 偶数
// 14px → 28rpx → ✅ 偶数
// 15px → 30rpx → ❌ 奇数 → 28rpx 或 32rpx
// 16px → 32rpx → ✅ 偶数
// 18px → 36rpx → ✅ 偶数
// 20px → 40rpx → ✅ 偶数
// 24px → 48rpx → ✅ 偶数
```

**字号规范**:
```scss
// src/styles/theme.scss

:root {
  --text-xs: 22rpx;    /* 辅助文字 */
  --text-sm: 24rpx;    /* 小正文 */
  --text-base: 28rpx;  /* 正文（基准） */
  --text-lg: 32rpx;    /* 大标题 */
  --text-xl: 36rpx;    /* 页面标题 */
  --text-2xl: 44rpx;   /* 大数字 */
  --text-3xl: 52rpx;   /* Hero 数字 */
}
```

## 间距规范

### 4 倍数原则

```scss
// 所有间距必须是 4 的倍数（rpx）
:root {
  --space-xs: 4rpx;    /* 极小间距 */
  --space-1: 8rpx;     /* 最小间距 */
  --space-2: 16rpx;    /* 紧密间距 */
  --space-3: 24rpx;    /* 标准间距 */
  --space-4: 32rpx;    /* 宽松间距 */
  --space-5: 40rpx;    /* 卡片内间距 */
  --space-6: 48rpx;    /* 大间距 */
  --space-8: 64rpx;    /* 区块间距 */
  --space-10: 80rpx;   /* Section 间距 */
}
```

### 常用间距场景

```vue
<template>
  <view class="page">
    <!-- 页面内边距 -->
    <view class="page-content" style="padding: 0 32rpx;">
      <!-- 列表项间距 -->
      <view class="list-item" style="margin-bottom: 24rpx;"></view>
      <view class="list-item" style="margin-bottom: 24rpx;"></view>

      <!-- 卡片内边距 -->
      <view class="card" style="padding: 32rpx;">
        <view style="margin-bottom: 16rpx;">主信息</view>
        <view style="margin-bottom: 8rpx;">次信息</view>
      </view>

      <!-- 按钮间距 -->
      <view style="margin-top: 48rpx;">
        <button style="height: 88rpx; border-radius: 44rpx;">
          主按钮
        </button>
      </view>
    </view>
  </view>
</template>
```

## 边框和分割线

```scss
// 分隔线统一 1px（rpx 中为 2rpx）
.divider {
  height: 1px;           /* 实际 1px */
  background: var(--color-divider);
  margin: 24rpx 0;
}

// 边框同理
.card {
  border: 1px solid var(--color-border);  /* 1px 边框 */
  border-radius: var(--radius-md);
}
```

## 组件尺寸规范

### 头像

```scss
// 头像尺寸（偶数 rpx）
.avatar-xs { width: 56rpx;  height: 56rpx;  }   /* 28px */
.avatar-sm { width: 72rpx;  height: 72rpx;  }   /* 36px */
.avatar-md { width: 96rpx;  height: 96rpx;  }   /* 48px */
.avatar-lg { width: 128rpx; height: 128rpx; }   /* 64px */
.avatar-xl { width: 160rpx; height: 160rpx; }   /* 80px */
```

### 按钮高度

```scss
// 按钮高度（偶数 rpx）
.btn-sm { height: 56rpx;  font-size: 22rpx; }  /* 小按钮 */
.btn-md { height: 72rpx;  font-size: 28rpx; }  /* 标准按钮 */
.btn-lg { height: 88rpx;  font-size: 32rpx; }  /* 大按钮 */
.btn-block { height: 96rpx; font-size: 32rpx; } /* 通栏按钮 */
```

### 图标尺寸

```scss
// 图标尺寸（偶数 rpx）
.icon-xs { width: 32rpx;  height: 32rpx;  }  /* 16px */
.icon-sm { width: 40rpx;  height: 40rpx;  }  /* 20px */
.icon-md { width: 48rpx;  height: 48rpx;  }  /* 24px */
.icon-lg { width: 56rpx;  height: 56rpx;  }  /* 28px */
.icon-xl { width: 64rpx;  height: 64rpx;  }  /* 32px */
```

## 与 rem 的对比

### 何时用 rpx

```scss
// 移动端界面元素：间距、内边距、宽高
.card {
  padding: 32rpx;
  width: 702rpx;
  border-radius: 16rpx;
}
```

### 何时用 rem

```scss
// 仅当需要跟随系统字体大小（无障碍/老年模式）时
// rem 基于 html font-size，适合可访问性场景

html {
  font-size: calc(100vw / 7.5);  /* 100px = 750rpx 基准 */
}

/* rem 值 */
.text { font-size: 0.28rem; }   /* = 28px */
```

### 关键区别

```
rpx: 固定换算（750rpx = 屏幕宽度），自动缩放
rem: 跟随 html font-size，需要 JS 动态计算

UniApp 推荐:
→ 布局/间距/尺寸 → rpx
→ 字体大小（无障碍） → rem
→ 混合场景 → rpx + 字号使用 token
```

## 特殊场景

### 底部安全区

```vue
<!-- 底部 TabBar 需要适配安全区 -->
<view class="tabbar" style="padding-bottom: constant(safe-area-inset-bottom);">
  <!-- Tab 内容 -->
</view>
```

### 状态栏

```vue
<!-- 顶部导航需要适配状态栏 -->
<view class="navbar" style="padding-top: constant(safe-area-inset-top);">
  <!-- 导航内容 -->
</view>
```

### rpx 转 rem（字体无障碍）

```js
// 在可访问性场景下，需要将 rpx 字号转为 rem
// rpx_font_size / 100 = rem_font_size

// 例如：28rpx → 0.28rem
// 配合 html font-size 动态计算实现系统字体缩放
```

## 反模式

- ❌ 混用 px 和 rpx（`padding: 16px` 混 `margin: 32rpx`）
- ❌ 奇数字号（`font-size: 23rpx`）
- ❌ 非 4 倍数间距（`margin: 15rpx`）
- ❌ 用 px 做边框（`border: 1px solid` → 改为 `border: 2rpx solid`）
- ❌ 在循环列表中大量内联 rpx 样式

## 关键词

| 关键词 | 同义词 | 语义变体 |
|--------|--------|---------|
| rpx | responsive pixel | "响应式像素", "移动端单位" |
| 750rpx | 设计稿基准 | "屏幕宽度基准" |
| 偶数字号 | even font size | "偶数字体" |
| 4倍数 | 4x spacing | "4的倍数间距" |
| 间距规范 | spacing scale | "间距系统", "留白规范" |

## 语义标签

`uniapp` `rpx` `spacing` `typography` `mobile-ui` `layout` `responsive` `safe-area`

## 相关知识

- UniApp 移动端 Token 系统
- UniApp CSS 分层策略
- 8 点栅格系统
- 设计原则-移动端排版规范
