---
title: 订单列表页
platform: uniapp
compatibility: uniapp-only
domain: 布局
source: template/yibaimei/pages/orderList/orderList.vue
tags: [订单列表, tab, 状态, 订单卡片, 列表]
---

> ⚠️ 本知识基于 **uni-app 单文件组件**（`<view>`/`<text>` + upx 单位）。
> 普通 H5 Vue 项目可借鉴排版思路，但标签结构与单位**不能直接复用**。

# 订单列表页 · 通用版

## 页面定位

「订单列表页」展示用户全部订单，按状态分类。
顶部 Tab 切换：全部 / 待付款 / 待发货 / 待收货 / 售后。
每个订单卡片包含：商家信息、商品缩略图、合计、操作按钮。

## 推荐结构

```
┌──────────────────────────────┐
│  Tab 状态切换                  │  ← 88upx
├──────────────────────────────┤
│  订单卡片                      │
│   - 商家名 + 状态标签           │
│   - 商品缩略图 + 标题 + 价格    │
│   - 合计 + 操作按钮             │
└──────────────────────────────┘
```

## Tab 切换（横向滑动）

```html
<scroll-view scroll-x class="tab-scroll">
  <view :class="['tab-item',{active:tabIndex===i}]" v-for="(t,i) in tabs" :key="i"
        @tap="tabChange(i)">
    {{t.label}}
  </view>
</scroll-view>
```

```scss
.tab-scroll {
  white-space: nowrap;
  background: #fff;
  border-bottom: 1upx solid #F0F0F0;

  .tab-item {
    display: inline-block;
    padding: 0 30upx;
    line-height: 88upx;
    font-size: 28upx;
    color: #666;
    position: relative;

    &.active {
      color: #FF546E;
      font-weight: bold;
      &:after {
        content: '';
        position: absolute;
        left: 50%;
        bottom: 12upx;
        transform: translateX(-50%);
        width: 40upx;
        height: 4upx;
        background: #FF546E;
        border-radius: 2upx;
      }
    }
  }
}
```

## 订单卡片

```html
<view class="order-card" v-for="(o,i) in list" :key="i">
  <view class="card-header">
    <view class="shop-name">店铺名</view>
    <view class="status">{{o.statusLabel }}</view>
  </view>
  <view class="card-body">
    <image :src="o.img" class="g-img" mode="aspectFill" />
    <view class="g-info">
      <view class="g-title">{{o.title}}</view>
      <view class="g-sku">{{o.sku}}</view>
    </view>
    <view class="g-price-area">
      <view class="g-price">¥{{o.price}}</view>
      <view class="g-qty">x{{o.qty}}</view>
    </view>
  </view>
  <view class="card-total">共{{o.qty}}件，合计：<text class="money">¥{{o.total}}</text></view>
  <view class="card-actions">
    <view class="btn btn-line">取消订单</view>
    <view class="btn btn-primary">去支付</view>
  </view>
</view>
```

## 卡片样式

```scss
.order-card {
  background: #fff;
  border-radius: 14upx;
  margin: 22upx 22upx 0;
  padding: 24upx;
  box-sizing: border-box;

  .card-header {
    display: flex;
    align-items: center;
    padding-bottom: 20upx;
    border-bottom: 1upx solid #F7F7F7;
    .shop-name { font-size: 28upx; font-weight: bold; color: #333; }
    .status {
      margin-left: auto;
      font-size: 24upx;
      color: #FF546E;
    }
  }

  .card-body {
    display: flex;
    padding: 24upx 0;
    .g-img {
      width: 160upx; height: 160upx;
      border-radius: 8upx;
      margin-right: 20upx;
    }
    .g-info {
      flex: 1;
      .g-title {
        font-size: 26upx;
        color: #333;
        line-height: 1.4;
      }
      .g-sku {
        font-size: 22upx;
        color: #999;
        margin-top: 10upx;
      }
    }
    .g-price-area {
      text-align: right;
      .g-price { font-size: 26upx; color: #333; }
      .g-qty { font-size: 22upx; color: #999; margin-top: 10upx; }
    }
  }

  .card-total {
    text-align: right;
    font-size: 26upx;
    color: #666;
    padding: 16upx 0;
    border-top: 1upx dashed #F0F0F0;
    .money { color: #FF546E; font-weight: bold; }
  }

  .card-actions {
    display: flex;
    justify-content: flex-end;
    padding-top: 10upx;
    .btn {
      margin-left: 20upx;
      min-width: 140upx;
      line-height: 56upx;
      text-align: center;
      font-size: 24upx;
      border-radius: 28upx;
      border: 1upx solid #ccc;
      &.btn-line { color: #666; }
      &.btn-primary {
        color: #FF546E;
        border-color: #FF546E;
      }
    }
  }
}
```

## 实践提示

1. Tab 横向滑动用 `scroll-view` + `white-space: nowrap`，至少 5 个 tab 才考虑滑动。
2. 状态标签（如「待付款」）右对齐，主色 `#FF546E`，22~24uprpx。
3. 商品缩略图 160upx × 160upx，固定大小保证视觉对齐。
4. 底部操作按钮至少两个：「次要操作（线框）+ 主要操作（实心）」。
5. 卡片外边距 `22uprpx`，圆角 `14uprpx`，与「我的页面」保持一致。