---
title: Drawer 抽屉组件
platform: uniapp
compatibility: uniapp-only
domain: 功能
source: components/drawer / markdowns/drawer.md
tags: [抽屉, transform, transition, slot, fixed]
---

# Drawer 抽屉组件

> ⚠️ 本知识仅适用于 **uni-app 自定义组件**。核心是 `transform: translateX` + `transition` 实现的滑入/滑出抽屉。原生 Vue 也可直接使用（仅替换标签）。

## 实现原理

1. 根节点 `position: fixed; left: 0; top: 0; height: 100%`，宽度 `600upx`
2. 默认（`direction='left'`）时 `transform: translateX(760upx)` 完全隐藏于右侧
3. 父级传入 `show=true` 时叠加 `.show` 类，改为 `translateX(150upx)`（露出 150upx 把手）
4. `direction='right'` 时方向镜像，从左侧滑入
5. 通过 `<slot />` 暴露自定义内容区
6. 底部固定两个 `<button>` 触发 `@cancel` / `@ensure`

## Props

| Prop | 类型 | 默认 | 说明 |
| ---- | ---- | ---- | ---- |
| `show` | Boolean | `false` | 是否显示抽屉 |
| `direction` | String | `'left'` | `left`（右往左滑出）/ `right`（左往右滑出） |

## Events

| 事件 | 说明 |
| ---- | ---- |
| `@cancel` | 点击"取消"按钮 |
| `@ensure` | 点击"确定"按钮 |

## 关键代码

```html
<template>
  <view :class="['side-nav', { left: direction === 'left', right: direction === 'right', show: show }]">
    <view class="item">
      <view class="body">
        <slot />
      </view>
    </view>
    <view class="item">
      <view class="flex-box action-area">
        <view class="item-2"><button type="warn" @tap="cancel">取消</button></view>
        <view class="item-2"><button type="primary" @tap="ensure">确定</button></view>
      </view>
    </view>
  </view>
</template>
```

```css
.side-nav {
  position: fixed;
  z-index: 99;
  left: 0;
  top: 0;
  height: 100%;
  width: 600upx;
  background-color: #fff;
  transition: 0.5s;
  display: flex;
  flex-direction: column;
  box-shadow: 0 0 5px #888888;

  &.left {
    transform: translateX(760upx);
    &.show { transform: translateX(150upx); }
  }
  &.right {
    transform: translateX(-760upx);
    &.show { transform: translateX(0); }
  }

  .body {
    height: 100%;
    overflow-y: auto;
  }
}

/* H5 端避开顶部导航条 */
.side-nav { padding-top: 44px; box-sizing: border-box; }
/* #ifdef H5 */
/* #endif */
```

## 设计要点

| 要点 | 取值 | 说明 |
| ---- | ---- | ---- |
| 抽屉宽度 | 600upx | 约等于 75% 屏宽 |
| 默认露出把手 | 150upx | 方便用户后续拖拽 |
| 动画时长 | 0.5s | 既平滑又不让用户等待 |
| 阴影 | 0 0 5px #888 | 视觉层级分明 |
| 底部按钮区固定 | flex: 1 0 auto | 永远在底部 |

## 适用场景

- 筛选条件面板
- 商品分类侧边栏
- 个人中心抽屉式入口
- 多步骤表单引导

## 平台兼容性

- H5：✅ `padding-top: 44px` 解决 webview 顶栏
- 小程序：✅
- App：✅ nvue 下 transform 不支持，可改用 `<animation>` API

## 进阶

- 加入 `@touchmove` 实现**手势拖拽**
- 用 `<scroll-view>` 替换 `.body`，提升长列表性能
- 改为右滑关闭手势（参考 iOS 抽屉交互）