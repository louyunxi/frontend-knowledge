---
title: 商品详情页
platform: uniapp
compatibility: uniapp-only
domain: 布局
source: template/yibaimei/pages/goodsDetail/goodsDetail.vue
tags: [商品详情, 轮播, 价格, 规格, 评价, 底部操作栏]
---

> ⚠️ 本知识基于 **uni-app 单文件组件**（`<view>`/`<text>` + upx 单位）。
> 普通 H5 Vue 项目可借鉴排版思路，但标签结构与单位**不能直接复用**。

# 商品详情页 · 通用版

## 页面定位

「商品详情页」展示单个商品的完整信息：
- 顶部 Banner（多图轮播）
- 价格 + 标题 + 卖点
- 已选规格
- 评价预览
- 商品详情（图文）
- 底部固定操作栏

## 推荐结构

```
┌──────────────────────────────┐
│  Banner 轮播                  │  ← 750×750upx（1:1）
├──────────────────────────────┤
│  价格 + 标题                   │
│   - 大字价格 + 销量           │
│   - 卖点标签                  │
├──────────────────────────────┤
│  已选规格                     │
├──────────────────────────────┤
│  评价预览                     │
├──────────────────────────────┤
│  商品详情（图文）              │
└──────────────────────────────┘
[底部 fixed 操作栏]
```

## 关键样式 token

| 元素 | 推荐值 |
| --- | --- |
| Banner | 1:1 正方形 / 视口宽 |
| 主价格 | `#FF546E`，40~44upx 加粗 |
| 副价格 / 划线价 | `#999`，text-decoration: line-through |
| 卡片背景 | `#FFFFFF` |
| 卡片间距 | `20upx` |
| 卡片圆角 | `14upx` |

## Banner 轮播

```html
<swiper class="banner" :indicator-dots="true" :autoplay="false" indicator-color="rgba(255,255,255,.5)" indicator-active-color="#FF546E">
  <swiper-item v-for="(b,i) in banners" :key="i">
    <image :src="b" class="banner-img" mode="aspectFill" />
  </swiper-item>
</swiper>
```

```scss
.banner {
  width: 100%;
  height: 750upx;
  background: #F7F7F7;
  .banner-img { width: 100%; height: 100%; }
}
```

## 价格 + 标题

```html
<view class="price-area">
  <view class="now-price">
    <text class="symbol">¥</text>
    <text class="num">134</text>
  </view>
  <view class="origin-price">¥268</view>
  <view class="sales">已售 1.2w+</view>
</view>

<view class="title-area">
  <view class="title">商品名称商品名称商品名称商品名称商品名称商品名称商品名称</view>
  <view class="badges">
    <text class="badge">满减</text>
    <text class="badge">包邮</text>
    <text class="badge">正品</text>
  </view>
</view>
```

```scss
.price-area {
  display: flex;
  align-items: baseline;
  padding: 24upx 30upx 16upx;
  background: #fff;

  .now-price {
    color: #FF546E;
    .symbol { font-size: 26upx; }
    .num { font-size: 48upx; font-weight: bold; margin-left: 4upx; }
  }
  .origin-price {
    margin-left: 16upx;
    color: #999;
    font-size: 24upx;
    text-decoration: line-through;
  }
  .sales {
    margin-left: auto;
    font-size: 22upx;
    color: #999;
  }
}

.title-area {
  padding: 0 30upx 30upx;
  background: #fff;
  border-bottom: 1upx solid #F0F0F0;

  .title {
    font-size: 30upx;
    color: #333;
    line-height: 1.4;
    font-weight: 500;
  }
  .badges {
    margin-top: 16upx;
    .badge {
      display: inline-block;
      font-size: 20upx;
      color: #FF546E;
      border: 1upx solid #FF546E;
      border-radius: 4upx;
      padding: 2upx 8upx;
      margin-right: 10upx;
    }
  }
}
```

## 已选规格

```html
<view class="sku-row">
  <text class="label">已选</text>
  <text class="value">1瓶装/清新茉莉花香</text>
  <text class="arrow">›</text>
</view>
```

```scss
.sku-row {
  display: flex;
  align-items: center;
  height: 90upx;
  padding: 0 30upx;
  background: #fff;
  font-size: 26upx;

  .label { color: #999; width: 100upx; }
  .value { flex: 1; color: #333; }
  .arrow {
    color: #999;
    font-size: 28upx;
    margin-left: auto;
  }
}
```

## 评价预览

```html
<view class="comment-area">
  <view class="c-header">
    <text class="c-title">用户评价 (1.2w+)</text>
    <text class="c-more">查看全部 ›</text>
  </view>
  <view class="c-user">
    <image class="avatar" :src="avatar" />
    <text class="u-name">用户昵称</text>
    <view class="stars">★★★★★</view>
  </view>
  <view class="c-content">商品评价内容商品评价内容商品评价内容</view>
</view>
```

## 底部操作栏

```html
<view class="footer">
  <view class="action-icon">
    <image :src="iconKefu" />
    <text>客服</text>
  </view>
  <view class="action-icon">
    <image :src="iconCart" />
    <text>购物车</text>
  </view>
  <view class="action-btn cart-btn">加入购物车</view>
  <view class="action-btn buy-btn">立即购买</view>
</view>
```

```scss
.footer {
  position: fixed;
  left: 0; bottom: 0;
  width: 100%;
  height: 100upx;
  display: flex;
  background: #fff;
  border-top: 1upx solid #F0F0F0;

  .action-icon {
    width: 100upx;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    font-size: 20upx;
    color: #666;
    image { width: 40upx; height: 40upx; }
  }
  .action-btn {
    flex: 1;
    line-height: 100upx;
    text-align: center;
    color: #fff;
    font-size: 28upx;
    font-weight: bold;
    &.cart-btn { background: linear-gradient(90deg, #FFB173, #FF8A48); }
    &.buy-btn  { background: linear-gradient(90deg, #FF8DA8, #FF546E); }
  }
}
```

## 实践提示

1. Banner 1:1 是电商主流；视频 + 图片混排时切换为 16:9。
2. 主价格 `48upx` 加粗 + 红色，搭配划线价形成强对比。
3. 卖点 badge 用主色边框 + 主色文字，padding 2upx 8upx。
4. 底部操作栏按钮建议双按钮：「加入购物车（橙）+ 立即购买（红）」。
5. 普通 H5 移植时 `upx` 改 `rem`，`swiper` 可改 swiper.js / antd-mobile。