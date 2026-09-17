---
title: 支付结果页
platform: uniapp
compatibility: uniapp-only
domain: 布局
source: template/yibaimei/pages/paySuccess/paySuccess.vue
tags: [支付成功, 结果页, 成功反馈, 订单详情入口, 继续购物]
---

> ⚠️ 本知识基于 **uni-app 单文件组件**（`<view>`/`<text>` + upx 单位）。
> 普通 H5 Vue 项目可借鉴排版思路，但标签结构与单位**不能直接复用**。

# 支付结果页 · 通用版

## 页面定位

「支付结果页」展示支付完成后的反馈：
- 大图标（成功 ✓ / 失败 ✗）
- 文字说明
- 跳转入口：查看订单 / 返回首页 / 联系客服

## 推荐结构

```
┌──────────────────────────────┐
│  大图标 + 标题                │  ← 顶部 320upx
├──────────────────────────────┤
│  描述文字                     │
├──────────────────────────────┤
│  订单摘要（金额、编号、时间）    │
├──────────────────────────────┤
│  操作入口                     │
│   - 查看订单详情               │
│   - 返回首页                   │
└──────────────────────────────┘
```

## 顶部结果展示

```html
<view class="result-header">
  <view class="icon-box success">
    <image :src="iconSuccess" class="icon" />
  </view>
  <view class="title">支付成功</view>
  <view class="desc">感谢您的购买，期待下次再来</view>
</view>
```

```scss
.result-header {
  padding: 80upx 30upx 60upx;
  text-align: center;
  background: #fff;

  .icon-box {
    width: 140upx; height: 140upx;
    margin: 0 auto 30upx;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;

    &.success { background: linear-gradient(135deg, #67D49B, #34B834); }
    &.fail    { background: linear-gradient(135deg, #FFB173, #FF546E); }

    .icon {
      width: 70upx; height: 70upx;
    }
  }

  .title {
    font-size: 38upx;
    font-weight: bold;
    color: #333;
  }
  .desc {
    margin-top: 16upx;
    font-size: 24upx;
    color: #999;
  }
}
```

## 订单摘要卡

```html
<view class="summary-card">
  <view class="row">
    <text>订单金额</text>
    <text class="money">¥268.00</text>
  </view>
  <view class="row">
    <text>支付方式</text>
    <text>微信支付</text>
  </view>
  <view class="row">
    <text>支付时间</text>
    <text>2024-09-16 12:00:12</text>
  </view>
  <view class="row">
    <text>订单编号</text>
    <text>202409161200123456</text>
  </view>
</view>
```

```scss
.summary-card {
  background: #fff;
  border-radius: 14upx;
  margin: 22upx;
  padding: 30upx;

  .row {
    display: flex;
    justify-content: space-between;
    padding: 14upx 0;
    font-size: 26upx;
    color: #666;

    .money {
      color: #FF546E;
      font-weight: bold;
    }
  }
}
```

## 操作入口

```html
<view class="action-area">
  <button class="btn-line" @tap="backHome">返回首页</button>
  <button class="btn-primary" @tap="viewOrder">查看订单详情</button>
</view>
```

```scss
.action-area {
  padding: 40upx 30upx;

  button {
    height: 88upx;
    line-height: 88upx;
    border-radius: 44upx;
    font-size: 28upx;
    margin-bottom: 24upx;
  }
  .btn-line {
    background: #fff;
    color: #FF546E;
    border: 1upx solid #FF546E;
  }
  .btn-primary {
    background: linear-gradient(90deg, #FF8DA8, #FF546E);
    color: #fff;
  }
}
```

## 失败态改造

```html
<view class="icon-box fail">
  <image :src="iconFail" class="icon" />
</view>
<view class="title">支付失败</view>
<view class="desc">请检查支付方式后重试</view>
```

## 实践提示

1. 图标建议 140upx 圆形 + 渐变背景 + 70upx 居中图标。
2. 主标题 38uprpx 加粗 + 黑灰色；描述 24uprpx + 浅灰。
3. 订单摘要用「左标签 + 右数值」等宽对齐。
4. 两个按钮采用「线框（次要）+ 实心（主要）」组合，主按钮用渐变。
5. 失败态复用同一布局，仅替换 icon-box 类名与文字。