---
title: 营销主页（商城首页）
platform: uniapp
compatibility: uniapp-only
domain: 布局
source: template/yibaimei/pages/index/index.vue
tags: [首页, 商城, 营销, 轮播, 金刚区, 商品流, 秒杀]
---

> ⚠️ 本知识基于 **uni-app 单文件组件**（`<view>`/`<text>` + upx 单位）。
> 普通 H5 Vue 项目可借鉴排版思路，但标签结构与单位**不能直接复用**。

# 营销主页 · 通用版

## 页面定位

「营销主页」是用户进入应用的第一屏，承载：
- 顶部搜索栏
- Banner 轮播图
- 金刚区（4×2 入口宫格）
- 营销板块（秒杀 / 拼团 / 活动）
- 商品瀑布流

## 推荐结构

```
┌──────────────────────────────┐
│  顶部搜索栏（fixed）           │
├──────────────────────────────┤
│  Banner 轮播（180~240upx）    │
├──────────────────────────────┤
│  金刚区（4×2 八宫格）          │
├──────────────────────────────┤
│  秒杀板块                     │
├──────────────────────────────┤
│  推荐商品流                   │
└──────────────────────────────┘
```

## 顶部搜索栏

```scss
.search-bar {
  position: sticky;
  top: 0;
  z-index: 99;
  height: 88upx;
  display: flex;
  align-items: center;
  padding: 0 22upx;
  background: linear-gradient(90deg, #FF8DA8, #FF546E);

  .search-input {
    flex: 1;
    height: 60upx;
    background: #fff;
    border-radius: 30upx;
    padding: 0 24upx;
    font-size: 26upx;
    color: #333;
  }
}
```

## Banner 轮播

```html
<swiper class="banner" :indicator-dots="true" :autoplay="true" :interval="3000">
  <swiper-item v-for="(b,i) in banners" :key="i">
    <image :src="b.img" class="banner-img" />
  </swiper-item>
</swiper>
```

```scss
.banner {
  width: 100%;
  height: 240upx;
  .banner-img { width: 100%; height: 100%; }
}
```

## 金刚区（4×2）

```html
<view class="kingkong">
  <view class="grid-item" v-for="(k,i) in 8" :key="i">
    <image :src="icons[i]" class="icon" />
    <view class="label">分类</view>
  </view>
</view>
```

```scss
.kingkong {
  display: flex;
  flex-wrap: wrap;
  background: #fff;
  padding: 30upx 0;

  .grid-item {
    width: 25%;
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 16upx 0;
    .icon { width: 64upx; height: 64upx; }
    .label {
      font-size: 24upx;
      color: #666;
      margin-top: 14upx;
    }
  }
}
```

## 秒杀板块

```html
<view class="seckill-area">
  <view class="seckill-header">
    <view class="title">限时秒杀</view>
    <view class="timer">
      <text class="t-num">02</text>:
      <text class="t-num">34</text>:
      <text class="t-num">56</text>
    </view>
  </view>
  <scroll-view scroll-x class="seckill-scroll">
    <view class="seckill-item" v-for="(s,i) in 5" :key="i">
      <image :src="imgs[i]" class="s-img" />
      <view class="s-price">¥99</view>
      <view class="s-origin">¥199</view>
    </view>
  </scroll-view>
</view>
```

```scss
.seckill-scroll {
  white-space: nowrap;
  .seckill-item {
    display: inline-block;
    width: 180upx;
    margin-right: 16upx;
    text-align: center;
    .s-img { width: 180upx; height: 180upx; }
    .s-price { color: #FF546E; font-weight: bold; }
    .s-origin { color: #999; text-decoration: line-through; font-size: 22upx; }
  }
}
```

## 推荐商品流（双列瀑布流）

```scss
.goods-list {
  display: flex;
  flex-wrap: wrap;
  padding: 22upx;
  background: #F7F7F7;
  .goods-card {
    width: calc(50% - 11upx);
    margin-bottom: 22upx;
    background: #fff;
    border-radius: 14upx;
    overflow: hidden;

    &:nth-child(odd) { margin-right: 11upx; }
    &:nth-child(even) { margin-left: 11upx; }

    .g-img { width: 100%; height: 320upx; }
    .g-info { padding: 16upx; }
    .g-title {
      font-size: 26upx;
      color: #333;
      line-height: 1.4;
      overflow: hidden;
      text-overflow: ellipsis;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
    }
    .g-price {
      color: #FF546E;
      font-weight: bold;
      font-size: 32upx;
      margin-top: 10upx;
    }
  }
}
```

## 实践提示

1. 顶部固定搜索栏 + 渐变背景，避免滚动时被内容遮挡。
2. Banner 高度建议 `240upx`，过大会喧宾夺主。
3. 金刚区图标 64upx × 64upp，文字 24uprpx 灰，padding 16uprpx。
4. 秒杀建议 `scroll-view` 横向滚动，每 item 宽度 180upx。
5. 商品流双列等宽 `calc(50% - 11upx)`，奇偶 `margin` 控制间距。