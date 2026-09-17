---
title: 推广海报页
platform: uniapp
compatibility: uniapp-only
domain: 布局
source: template/yibaimei/pages/invite/invite.vue
tags: [推广海报, 邀请, 二维码, 分享, 海报, 营销]
---

> ⚠️ 本知识基于 **uni-app 单文件组件**（`<view>`/`<text>` + upx 单位）。
> 普通 H5 Vue 项目可借鉴排版思路，但标签结构与单位**不能直接复用**。

# 推广海报页 · 通用版

## 页面定位

「推广海报页」用于邀请 / 拉新场景：
- 海报主图（含用户头像 / 二维码）
- 推广文案
- 保存 / 分享按钮

## 推荐结构

```
┌──────────────────────────────┐
│  海报预览（居中卡片）           │
│   - 主图 + 用户信息            │
│   - 二维码                    │
│   - 推广文案                  │
├──────────────────────────────┤
│  保存 / 分享按钮               │
└──────────────────────────────┘
```

## 海报卡片

```html
<view class="poster-card">
  <view class="poster-top" :style="{backgroundImage:'url('+posterBg+')'}">
    <view class="user-info">
      <image class="avatar" :src="avatar" />
      <view class="info">
        <view class="name">昵称</view>
        <view class="desc">邀请你一起加入</view>
      </view>
    </view>
    <view class="poster-title">专属福利等你来拿</view>
  </view>
  <view class="poster-bottom">
    <view class="qr-area">
      <image :src="qrUrl" class="qr-img" />
      <view class="qr-tip">长按识别二维码</view>
    </view>
  </view>
</view>
```

```scss
.poster-card {
  margin: 40upx 50upx;
  border-radius: 16upx;
  overflow: hidden;
  background: #fff;
  box-shadow: 0 6upx 20upx rgba(0,0,0,.06);

  .poster-top {
    height: 540upx;
    background-size: cover;
    background-position: center;
    padding: 40upx;
    box-sizing: border-box;
    color: #fff;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    position: relative;
  }

  .user-info {
    display: flex;
    align-items: center;

    .avatar {
      width: 80upx; height: 80upx;
      border-radius: 50%;
      border: 2upx solid #fff;
      margin-right: 20upx;
    }
    .name { font-size: 28upx; font-weight: bold; }
    .desc { font-size: 22upx; opacity: .85; margin-top: 6upx; }
  }

  .poster-title {
    font-size: 42upx;
    font-weight: bold;
    text-shadow: 0 2upx 4upx rgba(0,0,0,.3);
  }

  .poster-bottom {
    background: #fff;
    padding: 30upx;
    display: flex;
    align-items: center;
  }

  .qr-area {
    flex: 1;
    text-align: center;
    .qr-img {
      width: 200upx; height: 200upx;
      margin-bottom: 16upx;
    }
    .qr-tip {
      font-size: 22upx;
      color: #999;
    }
  }
}
```

## 底部按钮

```html
<view class="bottom-bar">
  <button class="btn-line" @tap="save">保存到相册</button>
  <button class="btn-primary" open-type="share">立即分享</button>
</view>
```

```scss
.bottom-bar {
  position: fixed;
  left: 0; bottom: 0;
  width: 100%;
  display: flex;
  padding: 20upx 30upx;
  background: #fff;
  border-top: 1upx solid #F0F0F0;
  box-sizing: border-box;

  button {
    flex: 1;
    height: 80upx;
    line-height: 80upx;
    border-radius: 40upx;
    font-size: 28upx;
    margin: 0 10upx;
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

## 推广说明文案

```html
<view class="rules-card">
  <view class="r-title">活动规则</view>
  <view class="r-desc">1. 邀请好友注册即可获得奖励</view>
  <view class="r-desc">2. 好友完成首单后您将获得额外奖励</view>
  <view class="r-desc">3. 奖励实时到账，可在收益明细查看</view>
</view>
```

```scss
.rules-card {
  background: #fff;
  border-radius: 14upx;
  margin: 22upx;
  padding: 30upx;

  .r-title {
    font-size: 28upx;
    font-weight: bold;
    color: #333;
    margin-bottom: 20upx;
  }
  .r-desc {
    font-size: 24upx;
    color: #666;
    line-height: 1.8;
  }
}
```

## 实践提示

1. 海报主图建议 540upx 高，1:1 或 3:4 比例适配屏幕。
2. 二维码 + 「长按识别」是核心交互，二维码建议 200upx 居中。
3. 推广标题用大字号 + 阴影，避免被主图背景吞没。
4. 「保存到相册」复用「长按保存图片」组件。
5. 「立即分享」用微信小程序 `open-type="share"`，触发右上角分享。