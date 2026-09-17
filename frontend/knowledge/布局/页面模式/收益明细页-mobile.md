---
title: 收益明细页（佣金明细）
platform: uniapp
compatibility: uniapp-only
domain: 布局
source: template/yibaimei/pages/myCommission/myCommission.vue
tags: [收益明细, 佣金明细, 我的佣金, 流水, tab切换, 列表]
---

> ⚠️ 本知识基于 **uni-app 单文件组件**（`<view>`/`<text>` + upx 单位）。
> 普通 H5 Vue 项目可借鉴排版思路，但标签结构与单位**不能直接复用**。

# 收益明细页 · 通用版

## 页面定位

「收益明细页」用于展示用户在平台产生的所有收益 / 佣金 / 奖励流水。
通常配套：
- 顶部「总收益」「可提现」「已提现」三联卡片
- Tab 切换（全部 / 收入 / 支出）
- 流水列表（图标 + 标题 + 时间 + 金额）

## 推荐结构

```
┌──────────────────────────────┐
│  顶部三联统计卡               │  ← 渐变背景，220upx
├──────────────────────────────┤
│  Tab 切换                     │  ← 88upx 高
├──────────────────────────────┤
│  流水列表                     │  ← cell 高 110upx
│   - 图标 + 标题 + 时间         │
│   - 右侧金额（绿/红）          │
└──────────────────────────────┘
```

## 关键样式 token

| 元素 | 推荐值 |
| --- | --- |
| 顶部背景渐变 | `linear-gradient(90deg, #FF8DA8, #FF546E)` |
| 主文字 | `#FFFFFF`（顶部）/ `#333`（列表） |
| 收入金额 | `#FF546E` 或 `#34B834` |
| 支出金额 | `#999` |
| 列表 cell 高度 | `110upx` |
| Tab 高度 | `88upx` |

## 顶部三联卡

```html
<view class="header">
  <view class="item">
    <view class="num">¥1234.56</view>
    <view class="label">累计收益</view>
  </view>
  <view class="item">
    <view class="num">¥888.00</view>
    <view class="label">可提现</view>
  </view>
  <view class="item">
    <view class="num">¥346.56</view>
    <view class="label">已提现</view>
  </view>
</view>
```

```scss
.header {
  display: flex;
  padding: 50upx 30upx;
  background: linear-gradient(90deg, #FF8DA8, #FF546E);

  .item {
    flex: 1;
    text-align: center;
    color: #fff;

    .num {
      font-size: 40upx;
      font-weight: bold;
    }
    .label {
      font-size: 24upx;
      opacity: .85;
      margin-top: 10upx;
    }
  }
}
```

## Tab 切换

```html
<view class="tab-area flex-box">
  <view :class="['item',{active:tabIndex===0}]" @tap="tabChange(0)">全部</view>
  <view :class="['item',{active:tabIndex===1}]" @tap="tabChange(1)">收入</view>
  <view :class="['item',{active:tabIndex===2}]" @tap="tabChange(2)">支出</view>
</view>
```

```scss
.tab-area {
  background: #fff;
  border-bottom: 1upx solid #F0F0F0;
  .item {
    flex: 1;
    text-align: center;
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
        bottom: 10upx;
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

## 流水列表 cell

```html
<view class="list">
  <view class="cell" v-for="(item,i) in list" :key="i">
    <image class="cell-icon" :src="item.icon" />
    <view class="cell-info">
      <view class="cell-title">{{item.title}}</view>
      <view class="cell-time">{{item.time}}</view>
    </view>
    <view :class="['cell-amount', item.type]">
      {{item.type === 'income' ? '+' : '-'}}{{item.amount}}
    </view>
  </view>
</view>
```

```scss
.cell {
  display: flex;
  align-items: center;
  padding: 20upx 30upx;
  background: #fff;
  border-bottom: 1upx solid #F7F7F7;

  .cell-icon {
    width: 80upx; height: 80upx;
    border-radius: 50%;
    margin-right: 20upx;
  }
  .cell-info {
    flex: 1;
    .cell-title { font-size: 28upx; color: #333; }
    .cell-time  { font-size: 22upx; color: #999; margin-top: 8upx; }
  }
  .cell-amount {
    font-size: 30upx;
    font-weight: bold;
    &.income { color: #FF546E; }
    &.expense { color: #999; }
  }
}
```

## 实践提示

1. 顶部三联卡的关键是「数字 + 标签」双行结构，数字 `40upx` 加粗。
2. Tab 选中态用「底部色条 + 加粗」组合，比单纯换色识别度高。
3. 列表 cell 中图标用 80upx 圆形更显「交易感」。
4. 收入 / 支出用两种颜色区分，正负号加在金额前。
5. 空状态建议统一空插画 + 「暂无收益记录」+ 「去分享赚钱」按钮。