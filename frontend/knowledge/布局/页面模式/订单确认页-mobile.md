---
title: 订单确认页
platform: uniapp
compatibility: uniapp-only
domain: 布局
source: template/yibaimei/pages/orderConfirm/orderConfirm.vue
tags: [订单确认, 收货地址, 商品, 支付方式, 提交按钮]
---

> ⚠️ 本知识基于 **uni-app 单文件组件**（`<view>`/`<text>` + upx 单位）。
> 普通 H5 Vue 项目可借鉴排版思路，但标签结构与单位**不能直接复用**。

# 订单确认页 · 通用版

## 页面定位

「订单确认页」是用户结算前的最后一站：
- 选择收货地址
- 确认商品与数量
- 选择支付方式
- 提交订单

## 推荐结构

```
┌──────────────────────────────┐
│  收货地址卡                   │
├──────────────────────────────┤
│  商品明细卡                   │
│   - 缩略图 + 标题 + 规格       │
│   - 邮费 / 合计               │
├──────────────────────────────┤
│  支付方式卡                   │
└──────────────────────────────┘
[底部 fixed 操作栏]
```

## 关键样式 token

| 元素 | 推荐值 |
| --- | --- |
| 页面背景 | `rgba(247, 247, 247, 1)` |
| 卡片圆角 | `14upx` |
| 卡片间距 | `20upx` |
| 内容内边距 | `40upx 20upx` |
| 主色 | `rgba(255, 84, 110, 1)` |
| 字号档位 | `24 / 26 / 28 / 30upx` |

## 收货地址卡

```html
<view class="address-area">
  <view class="item icon-area">
    <image :src="iconLocation" class="icon-location" />
  </view>
  <view class="item">
    <view v-if="isHaveAddress">
      <view class="real-name">姓名<text class="tel">135****6559</text></view>
      <view class="address-info">浙江省杭州市拱墅区北城天地9幢</view>
    </view>
    <view v-else>
      <view class="address-tip">请填写收货地址</view>
    </view>
  </view>
</view>
```

```scss
.address-area {
  display: flex;
  align-items: center;
  background: #fff;
  min-height: 134upx;
  border-radius: 14upx;
  padding: 24upx;

  .item:nth-of-type(1) {
    flex: 0 0 76upx;
  }
  .item:nth-of-type(2) {
    flex: 1;
    padding-left: 16upx;
    position: relative;

    &:after {
      content: '';
      position: absolute;
      right: 50upx;
      top: 50%;
      transform: rotate(45deg) translateY(-50%);
      width: 15upx; height: 15upx;
      border: 4upx solid #666;
      border-width: 4upx 4upx 0 0;
    }
  }

  .address-tip {
    font-size: 28upx;
    color: #FF546E;
  }
  .real-name {
    font-size: 28upx;
    font-weight: bold;
    color: #333;
    .tel {
      margin-left: 10upx;
      font-size: 26upx;
      font-weight: 500;
      color: #666;
    }
  }
  .address-info {
    font-size: 26upx;
    color: #333;
    margin-top: 10upx;
  }
}
```

## 商品明细卡

```html
<view class="goods-area">
  <view class="goods-row">
    <view class="item img-area">
      <view class="goods-img" :style="{backgroundImage:'url('+img+')'}"></view>
    </view>
    <view class="item info-area">
      <view class="goods-name">商品名称商品名称商品名称商品名称商品名称商品名称</view>
      <view class="sku-row">
        <text class="m-item">1瓶装/清新茉莉花香</text>
        <text class="m-item">x2</text>
      </view>
      <view class="goods-price">¥134</view>
    </view>
  </view>
  <view class="postage">邮费：0.00元</view>
  <view class="total-area">
    <text class="num">共2件</text>，小计：<text class="money">¥268</text>
  </view>
</view>
```

```scss
.goods-area {
  background: #fff;
  border-radius: 14upx;
  margin: 20upx 0;
  padding: 40upx 20upx;

  .goods-row {
    display: flex;
    .img-area {
      .goods-img {
        width: 160upx; height: 160upx;
        background-size: cover;
        border-radius: 4upx;
      }
    }
    .info-area {
      flex: 1;
      padding-left: 16upx;
      padding-top: 12upx;
    }
  }

  .goods-name {
    font-size: 26upx;
    font-weight: bold;
    color: #333;
    width: 490upx;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .sku-row {
    display: flex;
    margin: 16upx 0;
    font-size: 22upx;
    color: #666;
    .m-item:first-child { flex: 1; }
    .m-item:last-child  { flex: 0 0 100upx; text-align: right; }
  }

  .goods-price {
    font-size: 24upx;
    color: #333;
  }

  .postage {
    margin: 50upx 0 30upx;
    font-size: 26upx;
    color: #333;
  }

  .total-area {
    font-size: 26upx;
    color: #333;
    .num { color: #999; font-size: 22upx; }
    .money { color: #FF546E; font-weight: bold; }
  }
}
```

## 支付方式卡

```html
<view class="pay-type-area">
  <view class="item icon-area">
    <image :src="iconWechat" class="icon-wechat" />
  </view>
  <view class="item">微信支付</view>
  <view class="item radio-area">
    <radio checked="true" color="#FF546E" />
  </view>
</view>
```

```scss
.pay-type-area {
  display: flex;
  align-items: center;
  height: 120upx;
  background: #fff;
  border-radius: 14upx;
  padding: 0 24upx;

  .item:nth-of-type(1) { flex: 0 0 60upx; }
  .item:nth-of-type(2) {
    flex: 1;
    padding-left: 16upx;
    font-size: 24upx;
    color: #333;
  }
  .item:nth-of-type(3) { flex: 0 0 40upx; }
}
```

## 底部固定操作栏

```html
<view class="footer">
  <view class="item total-area">
    <text class="num">共2件</text>，小计：<text class="money">¥268</text>
  </view>
  <view class="item">
    <button class="send-order-btn" @tap="send">提交订单</button>
  </view>
</view>
```

```scss
.footer {
  position: fixed;
  left: 0; bottom: 0;
  width: 100%;
  display: flex;
  background: #fff;
  border-top: 1upx solid #F7F7F7;
  padding: 15upx 36upx 15upx 42upx;
  align-items: center;
  box-sizing: border-box;

  .item:first-child { flex: 1; }
  .item:last-child  { flex: 0 0 196upx; }

  .send-order-btn {
    line-height: 70upx;
    background: #FF546E;
    border-radius: 35upx;
    padding: 0;
    font-size: 28upx;
    font-weight: bold;
    color: #fff;
  }
}
```

## 实践提示

1. 页面背景浅灰，卡片纯白是「电商确认页」经典配色。
2. 卡片内边距 `40upx 20upx` 偏大，让信息有「呼吸感」。
3. 提交订单按钮采用胶囊形（`border-radius: 35upx`）+ 主色背景。
4. 商品标题 `white-space: nowrap` 单行截断，避免高度抖动。
5. 支付方式 radio 用主色 `#FF546E` 强化品牌色。