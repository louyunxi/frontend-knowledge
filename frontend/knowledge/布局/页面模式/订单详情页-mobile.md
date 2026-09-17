---
title: 订单详情页
platform: uniapp
compatibility: uniapp-only
domain: 布局
source: template/yibaimei/pages/orderDetail/orderDetail.vue
tags: [订单详情, 进度, 时间线, 收货, 操作按钮, 信息块]
---

> ⚠️ 本知识基于 **uni-app 单文件组件**（`<view>`/`<text>` + upx 单位）。
> 普通 H5 Vue 项目可借鉴排版思路，但标签结构与单位**不能直接复用**。

# 订单详情页 · 通用版

## 页面定位

「订单详情页」展示单一订单的完整信息：
- 顶部状态条（待付款 / 待发货 / 待收货 / 已完成）
- 收货地址
- 商品明细
- 费用明细（商品 / 运费 / 优惠）
- 订单信息（编号 / 下单时间 / 支付方式）

## 推荐结构

```
┌──────────────────────────────┐
│  顶部状态条（渐变背景）         │  ← 160upx
├──────────────────────────────┤
│  收货地址卡（白色圆角）         │
├──────────────────────────────┤
│  商品卡                       │
├──────────────────────────────┤
│  费用明细卡                   │
├──────────────────────────────┤
│  订单信息卡                   │
└──────────────────────────────┘
```

## 顶部状态条

```html
<view class="status-bar">
  <view class="status-title">待发货</view>
  <view class="status-desc">商家正在备货中，请耐心等待</view>
</view>
```

```scss
.status-bar {
  height: 160upx;
  background: linear-gradient(135deg, #FF8DA8, #FF546E);
  display: flex;
  flex-direction: column;
  justify-content: center;
  padding: 0 30upx;

  .status-title {
    font-size: 36upx;
    color: #fff;
    font-weight: bold;
  }
  .status-desc {
    font-size: 24upx;
    color: rgba(255,255,255,.85);
    margin-top: 10upx;
  }
}
```

## 收货地址卡

```html
<view class="card address-card">
  <image class="icon-location" :src="iconLocation" />
  <view class="info">
    <view class="name-line">
      <text class="name">张三</text>
      <text class="tel">135****6559</text>
    </view>
    <view class="address">浙江省杭州市拱墅区北城天地9幢</view>
  </view>
</view>
```

```scss
.address-card {
  display: flex;
  align-items: center;
  padding: 30upx;
  background: #fff;
  border-radius: 14upx;
  margin: -40upx 22upx 22upx;
  position: relative;
  z-index: 2;

  &:after {
    content: '';
    position: absolute;
    right: 30upx;
    top: 50%;
    transform: rotate(45deg) translateY(-50%);
    width: 14upx; height: 14upx;
    border: 2upx solid #999;
    border-width: 2upx 2upx 0 0;
  }

  .icon-location { width: 40upx; height: 46upx; margin-right: 20upx; }
  .name-line .name { font-size: 28upx; font-weight: bold; color: #333; }
  .name-line .tel  { margin-left: 16upx; font-size: 26upx; color: #666; }
  .address {
    font-size: 24upx;
    color: #666;
    margin-top: 10upx;
  }
}
```

> 利用 `margin-top: -40upx` 让地址卡上提，与状态条视觉融合。

## 商品明细卡

```html
<view class="card">
  <view class="shop-name">店铺名</view>
  <view class="goods-row" v-for="(g,i) in goods" :key="i">
    <image :src="g.img" class="g-img" mode="aspectFill" />
    <view class="g-info">
      <view class="g-title">{{g.title}}</view>
      <view class="g-sku">{{g.sku}}</view>
    </view>
    <view class="g-price-area">
      <view class="g-price">¥{{g.price}}</view>
      <view class="g-qty">x{{g.qty}}</view>
    </view>
  </view>
</view>
```

## 费用明细卡

```html
<view class="card">
  <view class="fee-row">
    <text>商品金额</text><text>¥268.00</text>
  </view>
  <view class="fee-row">
    <text>运费</text><text>+¥0.00</text>
  </view>
  <view class="fee-row">
    <text>优惠</text><text class="discount">-¥20.00</text>
  </view>
  <view class="fee-row total">
    <text>实付</text><text class="money">¥248.00</text>
  </view>
</view>
```

```scss
.fee-row {
  display: flex;
  justify-content: space-between;
  padding: 14upx 0;
  font-size: 26upx;
  color: #666;

  &.total {
    border-top: 1upx solid #F0F0F0;
    padding-top: 20upx;
    margin-top: 10upx;
    color: #333;
    .money { color: #FF546E; font-weight: bold; font-size: 30upx; }
  }
  .discount { color: #FF546E; }
}
```

## 订单信息卡

```html
<view class="card">
  <view class="info-row">
    <text>订单编号</text>
    <view class="value">
      <text>202409161200123456</text>
      <text class="copy">复制</text>
    </view>
  </view>
  <view class="info-row">
    <text>下单时间</text><text>2024-09-16 12:00:12</text>
  </view>
  <view class="info-row">
    <text>支付方式</text><text>微信支付</text>
  </view>
</view>
```

## 卡片统一样式

```scss
.card {
  background: #fff;
  border-radius: 14upx;
  margin: 22upx;
  padding: 24upx;
  box-sizing: border-box;
}
```

## 实践提示

1. 顶部状态条用「渐变背景 + 大字号状态词」，凸显当前进度。
2. 收货卡用 `margin-top: -40upx` 与状态条衔接，形成「卡片压在背景上」的效果。
3. 费用明细中「实付」加粗 + 主色 + 顶部虚线分割，视觉重点突出。
4. 订单编号右侧加「复制」按钮，点击复制到剪贴板。
5. 底部固定操作栏参考 `订单确认页` 的 footer 设计。