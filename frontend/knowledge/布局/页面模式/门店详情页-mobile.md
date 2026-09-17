---
title: 门店详情页
platform: uniapp
compatibility: uniapp-only
domain: 布局
source: template/yibaimei/pages/storeInfo/storeInfo.vue
tags: [门店详情, 头部信息, Tab, 图片网格, 联系商家]
---

> ⚠️ 本知识基于 **uni-app 单文件组件**（`<view>`/`<text>` + upx 单位）。
> 普通 H5 Vue 项目可借鉴排版思路，但标签结构与单位**不能直接复用**。

# 门店详情页 · 通用版

## 页面定位

「门店详情页」展示单个门店的完整信息：
- 头部：图片 + 名称 + 地址 + 电话
- Tab 切换：企业介绍 / 企业环境 / 员工风采
- 内容区：图片网格或图文介绍

## 推荐结构

```
┌──────────────────────────────┐
│  头部信息卡                    │
│   - 图片 + 名称               │
│   - 地址 + 电话               │
├──────────────────────────────┤
│  Tab 切换（三等分）             │
├──────────────────────────────┤
│  内容区（图片网格 / 文字）      │
└──────────────────────────────┘
```

## 头部信息卡

```html
<view class="header">
  <view class="store-img-area">
    <view class="store-img" :style="{backgroundImage:'url('+img+')'}"></view>
    <text>店铺名称</text>
  </view>
  <view class="group">浙江省杭州市萧山区市心北路1888号A座</view>
  <view class="group" @tap="tel">0571-88998888</view>
</view>
```

```scss
.header {
  padding: 40upx 22upx 20upx;
  background: #fff;
  margin-bottom: 20upx;

  .store-img-area {
    margin-bottom: 38upx;
    border-radius: 6upx;
    display: flex;
    align-items: center;

    .store-img {
      display: inline-block;
      width: 120upx;
      height: 120upx;
      background-size: cover;
      vertical-align: middle;
      margin-right: 20upx;
      border-radius: 8upx;
    }

    text {
      font-size: 38upx;
      font-weight: bold;
      color: #333;
    }
  }

  .group {
    font-size: 24upx;
    font-weight: 500;
    color: #333;
    margin-bottom: 20upx;
    line-height: 1.5;
  }
}
```

## Tab 切换（三等分）

```html
<view class="tab-area flex-box tc">
  <view :class="['item-3',{active:tabIndex===0}]" @tap="tabChange(0)">企业介绍</view>
  <view :class="['item-3',{active:tabIndex===1}]" @tap="tabChange(1)">企业环境</view>
  <view :class="['item-3',{active:tabIndex===2}]" @tap="tabChange(2)">员工风采</view>
</view>
```

```scss
.tab-area {
  background: #fff;

  .item-3 {
    position: relative;
    line-height: 120upx;
    font-size: 28upx;
    font-weight: 500;
    color: #666;
    text-align: center;

    &:after {
      content: '';
      position: absolute;
      left: 50%;
      bottom: 10upx;
      transform: translateX(-50%);
      width: 59upx;
      height: 4upx;
      background: #FF546E;
      border-radius: 2upx;
      visibility: hidden;
    }

    &.active {
      color: #FF546E;

      &:after {
        visibility: visible;
      }
    }
  }
}
```

## 图片网格（双列等宽）

```html
<view class="grid-list">
  <view class="item-2" v-for="(g,i) in 4" :key="i">
    <view class="img-show" :style="{backgroundImage:'url('+imgs[i]+')'}"></view>
  </view>
</view>
```

```scss
.grid-list {
  display: flex;
  flex-wrap: wrap;
  padding: 0 22upx 22upx;
  background: #fff;

  .item-2 {
    margin-top: 22upx;
    box-sizing: border-box;
    height: 230upx;
    width: 50%;

    &:nth-of-type(odd) { padding-right: 11upx; }
    &:nth-of-type(even) { padding-left: 11upx; }

    .img-show {
      background: #fff;
      border-radius: 10px;
      height: 100%;
      background-size: cover;
    }
  }
}
```

## 实践提示

1. 头部用「圆角图 + 名称」+ 「地址 + 电话」分段，清晰区分。
2. Tab 用三等分 + 选中色条，色条宽度 59upx 偏长于订单 Tab。
3. 图片网格用 flex 50% + `padding` 间距，奇偶错位（11upx + 11upx = 22upx）。
4. 电话点击触发 `uni.makePhoneCall({ phoneNumber })`。
5. 网格底部预留 `22upx` padding，避免贴底。