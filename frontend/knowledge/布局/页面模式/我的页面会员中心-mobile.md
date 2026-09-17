---
title: 我的页面（会员中心）
platform: uniapp
compatibility: uniapp-only
domain: 布局
source: template/yibaimei/pages/user/user.vue
tags: [个人中心, 会员中心, 我的, 用户中心, 头部, 宫格, 列表入口]
---

> ⚠️ 本知识基于 **uni-app 单文件组件**（`<view>`/`<text>` + upx 单位）。
> 普通 H5 Vue 项目可借鉴排版思路，但标签结构与单位**不能直接复用**。

# 我的页面 · 通用版

## 页面定位

「我的页面」是用户中心 / 会员中心的入口，承载：
- 用户头像 / 昵称
- 订单状态聚合入口（待付款 / 待发货 / 待收货 / 售后）
- 工具宫格（地址 / 收藏 / 客服 / 设置）
- 营销入口（推广海报 / 收益明细）

## 推荐结构

```
┌──────────────────────────────┐
│  顶部用户卡片（渐变背景）      │ ← 120~220upx
├──────────────────────────────┤
│  订单状态四宫格               │ ← 高度 180upx
├──────────────────────────────┤
│  工具入口四宫格               │ ← 高度 180upx
├──────────────────────────────┤
│  推广营销入口卡片              │
├──────────────────────────────┤
│  列表入口                     │  ← 间距 22upx
└──────────────────────────────┘
```

## 关键样式 token

| 元素 | 推荐值 |
| --- | --- |
| 页面背景 | `rgba(247, 247, 247, 1)` |
| 卡片背景 | `#FFFFFF` |
| 卡片圆角 | `14upx` |
| 卡片间距 | `20upx ~ 22upx` |
| 主文字 | `#333333` |
| 次文字 | `#999999` |
| 强调色 | `rgba(255, 84, 110, 1)` |

## 顶部用户卡片

```html
<view class="user-header">
  <view class="user-img" :style="{backgroundImage:'url('+avatar+')'}"></view>
  <view class="user-info">
    <view class="user-name">昵称</view>
    <view class="user-level">VIP 会员</view>
  </view>
  <view class="user-action">设置</view>
</view>
```

```scss
.user-header {
  display: flex;
  align-items: center;
  padding: 40upx 30upx;
  background: linear-gradient(90deg, #FF8DA8, #FF546E);

  .user-img {
    width: 110upx; height: 110upx;
    border-radius: 50%;
    background-size: cover;
    margin-right: 24upx;
  }
  .user-name {
    font-size: 32upx;
    color: #fff;
    font-weight: bold;
  }
  .user-level {
    font-size: 22upx;
    color: rgba(255,255,255,.8);
    margin-top: 8upx;
  }
  .user-action {
    margin-left: auto;
    color: #fff;
    font-size: 26upx;
  }
}
```

## 订单四宫格

```html
<view class="order-area">
  <view class="order-title">
    <text>我的订单</text>
    <text class="more">查看全部 ›</text>
  </view>
  <view class="order-grid">
    <view class="grid-item" v-for="o in 4" :key="o">
      <image class="grid-icon" :src="icons[o-1]" />
      <view class="grid-text">待付款</view>
    </view>
  </view>
</view>
```

```scss
.order-grid {
  display: flex;
  justify-content: space-around;
  padding: 30upx 0;
  .grid-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    .grid-icon { width: 50upx; height: 50upx; }
    .grid-text {
      font-size: 24upx;
      color: #666;
      margin-top: 14upx;
    }
  }
}
```

## 工具入口（推广 / 收益 / 地址 / 设置）

```html
<view class="tools-area">
  <view class="tools-grid">
    <view class="grid-item" v-for="t in 8" :key="t">
      <image :src="icons[t-1]" class="grid-icon" />
      <view class="grid-text">地址管理</view>
    </view>
  </view>
</view>
```

## 列表入口

```scss
.list-cell {
  display: flex;
  align-items: center;
  height: 100upx;
  padding: 0 30upx;
  background: #fff;
  border-bottom: 1upx solid #F0F0F0;
  font-size: 28upx;
  color: #333;

  .cell-icon { width: 36upx; height: 36upx; margin-right: 20upx; }
  .cell-arrow {
    margin-left: auto;
    width: 14upx; height: 14upx;
    border: 2upx solid #999;
    border-width: 2upx 2upx 0 0;
    transform: rotate(45deg);
  }
}
```

## 实践提示

1. 用户卡片建议加「渐变背景」+「VIP 标签」提升品质感。
2. 四宫格图标建议 50upx × 50upp，文字 24uprpx，主色 `#666`。
3. 列表 cell 高度 100uprpx，文字 28uprpx，搭配右箭头。
4. 营销卡片（如推广海报）建议用「左侧主图 + 右侧标题 + 立即查看」三段式。
5. 普通 H5 移植时将 `upx` 改为 `rem`，标签可保留 `<div>`。