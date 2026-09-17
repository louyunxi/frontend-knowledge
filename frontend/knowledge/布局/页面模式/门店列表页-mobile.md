---
title: 门店列表页
platform: uniapp
compatibility: uniapp-only
domain: 布局
source: template/yibaimei/pages/store/store.vue
tags: [门店列表, 附近门店, 卡片, 地址, 电话, 列表]
---

> ⚠️ 本知识基于 **uni-app 单文件组件**（`<view>`/`<text>` + upx 单位）。
> 普通 H5 Vue 项目可借鉴排版思路，但标签结构与单位**不能直接复用**。

# 门店列表页 · 通用版

## 页面定位

「门店列表页」展示附近的门店 / 店铺 / 网点：
- 顶部位置筛选（默认定位）
- 门店列表卡片：图片 + 名称 + 评分 + 地址 + 距离 + 电话

## 推荐结构

```
┌──────────────────────────────┐
│  顶部位置筛选                  │
├──────────────────────────────┤
│  门店卡片（多张）              │
│   - 缩略图 + 名称 + 评分       │
│   - 地址 + 距离 + 电话         │
└──────────────────────────────┘
```

## 门店卡片

```html
<view class="store-card" v-for="(s,i) in list" :key="i">
  <image :src="s.img" class="s-img" mode="aspectFill" />
  <view class="s-info">
    <view class="s-name">{{s.name}}</view>
    <view class="s-rating">
      <text class="stars">★★★★★</text>
      <text class="score">{{s.score}}</text>
      <text class="sales">月售 {{s.sales}}</text>
    </view>
    <view class="s-address">
      <image class="addr-icon" :src="iconLocation" />
      <text>{{s.address}}</text>
    </view>
    <view class="s-actions">
      <view class="distance">距离 1.2km</view>
      <image class="phone-icon" :src="iconPhone" @tap="call(s.tel)" />
    </view>
  </view>
</view>
```

```scss
.store-card {
  display: flex;
  background: #fff;
  border-radius: 14upx;
  padding: 24upx;
  margin: 22upx;
  box-sizing: border-box;

  .s-img {
    width: 180upx;
    height: 180upx;
    border-radius: 8upx;
    margin-right: 24upx;
    flex-shrink: 0;
  }

  .s-info {
    flex: 1;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    min-width: 0;
  }

  .s-name {
    font-size: 28upx;
    font-weight: bold;
    color: #333;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .s-rating {
    margin-top: 10upx;
    font-size: 22upx;
    color: #666;
    .stars { color: #FFB400; margin-right: 10upx; }
    .score { color: #FF546E; font-weight: bold; }
    .sales { margin-left: 16upx; color: #999; }
  }

  .s-address {
    display: flex;
    align-items: center;
    margin-top: 14upx;
    font-size: 22upx;
    color: #999;
    .addr-icon {
      width: 24upx; height: 24upx;
      margin-right: 8upx;
      flex-shrink: 0;
    }
    text {
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
  }

  .s-actions {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-top: 14upx;

    .distance {
      font-size: 22upx;
      color: #FF546E;
    }
    .phone-icon {
      width: 44upx; height: 44upx;
    }
  }
}
```

## 顶部位置筛选

```html
<view class="location-bar">
  <image class="loc-icon" :src="iconLocation" />
  <text class="loc-text">定位中...</text>
  <text class="loc-arrow">▾</text>
</view>
```

```scss
.location-bar {
  display: flex;
  align-items: center;
  padding: 20upx 30upx;
  background: #fff;
  border-bottom: 1upx solid #F0F0F0;

  .loc-icon { width: 32upx; height: 32upx; margin-right: 12upx; }
  .loc-text { font-size: 26upx; color: #333; flex: 1; }
  .loc-arrow { font-size: 22upx; color: #999; }
}
```

## 实践提示

1. 门店卡片用「缩略图 + 右侧信息」双列布局，缩略图固定 180upx × 180upx。
2. 评分 + 销量 + 距离放一行，关键信息（评分）用主色突出。
3. 电话图标放右侧，点击触发 `uni.makePhoneCall`。
4. 地址用「图标 + 文本」组合，超出单行省略。
5. 普通 H5 移植时去掉定位相关 API，保留 UI 结构即可。