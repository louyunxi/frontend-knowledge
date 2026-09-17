---
title: Loading 加载动画合集 (23种 CSS Loader)
platform: uniapp
compatibility: uniapp-only
domain: 动效
source: components/loading / markdowns/loading.md
tags: [loading, 加载, CSS动画, loader]
---

# Loading 加载动画合集（23 种 CSS Loader）

> ⚠️ 本知识仅适用于 **uni-app 自定义组件**。所有 23 种 loader 都是纯 CSS 实现，未依赖第三方 JS 库，因此可直接被 webview / 小程序 / nvue 渲染。原生 Vue / React 工程可直接复用 SCSS，但需注意 `upx` 单位替换。

## 实现原理

1. 在 `loading.vue` 模板中放置 23 个独立的 `<view>` 节点，每个对应一种 loader
2. 在 `<style>` 中通过 `@import './loading1' ~ './loading23.scss'` 引入每种 loader 的独立样式文件
3. 每个 loader 内部用 `@keyframes` 实现 spin / bounce / ring 等动效

## 样式架构

```
components/loading/
├─ loading.vue       # 模板入口，import 所有 loader 样式
├─ loading1.css      # lds-circle
├─ loading2.css      # lds-dual-ring
├─ loading3.css      # lds-facebook（3 段跳动）
├─ loading4.css      # lds-heart
├─ loading5.css      # lds-ring（4 圆旋转）
├─ loading6.css      # lds-roller（8 圆）
├─ loading7.css      # lds-default（12 点）
├─ loading8.css      # lds-ellipsis（5 点）
├─ loading9.css      # lds-grid（3×3）
├─ loading10.css     # lds-hourglass（沙漏）
├─ loading11.css     # lds-ripple（双圈涟漪）
├─ loading12.css     # lds-spinner（12 旋转）
├─ loading13.css
├─ loading14.css     # double-bounce
├─ loading15.css     # rect-bar（5 条柱）
├─ loading16.css     # cube（双立方体）
├─ loading17.css
├─ loading18.css     # dot 双点
├─ loading19.css     # 三段 bounce
├─ loading20.css     # sk-circle（12 圆弧）
├─ loading21.css     # sk-cube-grid（3×3 立方）
├─ loading22.css     # sk-folding-cube（4 折叠立方）
└─ loading23.scss    # loader-wrapper（3 旋转轮）
```

## 使用方式

```html
<template>
  <view>
    <!-- 选择其中任意一种即可 -->
    <loading />
  </view>
</template>
```

> 当前模板一次性展示所有 23 种，生产使用时建议**只保留 1 种**，避免性能浪费。

## 设计要点

| Loader 系列 | 适合场景 | 风格 |
| ---- | ---- | ---- |
| lds-circle / dual-ring / ring | 通用，加载内容不确定 | 圆形旋转 |
| lds-facebook / bounce / dot | 列表下拉刷新、轻量加载 | 跳点 |
| lds-hourglass | 等待时间长 | 拟物沙漏 |
| lds-ellipsis | 文字末尾"加载中..." | 三/五点 |
| sk-cube-grid / sk-folding-cube | 启动页、过场 | 立方体 |
| loader-wrapper (23) | 多任务并行加载 | 三轮旋转 |

## 平台兼容性

- H5：✅
- 小程序：✅ CSS 动画支持，但部分复杂 keyframes（如 box-shadow 链式动画）在某些低端机有性能损耗
- App：✅ nvue 不支持 CSS `@import`，需要把 loader 样式 inline 到 `<style>` 中

## 优化建议

1. **生产裁剪**：仅保留 1-2 种 loader，避免 23 个动画同时跑
2. **按需加载**：将单 loader 拆成独立组件，按需 import
3. **可访问性**：增加 `aria-label="加载中"` 与 `role="status"`
4. **降级**：在 `prefers-reduced-motion: reduce` 下用静态占位替代动画