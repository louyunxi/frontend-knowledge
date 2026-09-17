---
title: radio 与 switch 组件大小调整
platform: uniapp
compatibility: uniapp-only
domain: 项目规范
source: markdowns/radioSize.md
tags: [radio, switch, transform, scale, 控件尺寸, 常见问题]
---

> ⚠️ 本知识仅适用于 **uni-app 自定义组件 / 单文件组件** 场景。
> H5 普通 Vue 项目可直接用 CSS `width` / `height`，**不能**复用本方案。

# uni-app 中 radio / switch 控件大小调整

## 背景

`<radio>` 与 `<switch>` 是 uni-app 内置表单组件（编译时映射到微信小程序的同名原生组件或 H5 input）。
两者**不支持** `width` / `height` 属性，因此无法通过常规属性 / 常规样式设置控件尺寸。

## 推荐方案：transform: scale

通过 `transform: scale()` 等比例缩放控件，不破坏内部布局结构。

```html
<radio style="transform: scale(0.7)" />
<switch style="transform: scale(0.7, 0.7)" />
```

参数说明：

| 参数    | 含义                        |
| ------- | --------------------------- |
| scale(x) | 整体缩放，x 与 y 使用同一比例 |
| scale(x, y) | x 与 y 分别缩放，单独调整水平 / 垂直 |

> 微信小程序原生组件同样支持 CSS transform，因此 `scale` 是跨端通用方案。

## 反例（不生效）

```html
<!-- 编译会警告 width/height 不支持，且无效果 -->
<radio width="40rpx" height="40rpx" />
<switch style="width: 40px; height: 20px;" />
```

## 实践提示

1. 使用 `rpx` 单位结合 scale 可保持等比缩放。
2. 缩放后如位置偏移，可用 `margin` 或外层 `view` 的 padding 微调。
3. 在表单组中可统一包一层容器并设置 `transform-origin` 保证视觉对齐。
4. 真机测试 transform 在低端安卓机偶有兼容问题，关键场景需在多机型回归。