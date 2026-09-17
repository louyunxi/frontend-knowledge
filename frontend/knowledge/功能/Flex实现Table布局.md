---
title: Flex 实现 Table 布局 (mTable)
platform: uniapp
compatibility: uniapp-only
domain: 功能
source: components/mTable / markdowns/table.md
tags: [table, flex, 表格, upx, 二等分, 三等分]
---

# Flex 实现 Table 布局 (mTable)

> ⚠️ 本知识仅适用于 **uni-app 自定义组件**。**重要**：uniapp 不允许命名为 `table` 的组件（保留关键字），本组件命名为 `mTable`。原生 Vue / React 可直接使用此模式。

## 实现原理

uniapp 中没有原生 `<table>` 标签，需要用 flex 模拟：

1. **表头 / 行** 都是一个 `display: flex; flex-wrap: wrap;` 容器
2. **列** 通过 `flex: 0 0 50%`（二等分）或 `flex: 0 0 33.3333%`（三等分）控制宽度
3. **边框** 通过 `border: 1upx solid` + `border-width: 1upx 1upx 0 0` 组合，再用父级 `border-bottom` 闭合
4. **多行合并**：列内再嵌套一层 `.table-flex` + `display: flex`

## 关键代码

```html
<template>
  <!-- 普通表格 -->
  <view class="genaral-area">
    <view class="flex-box tc thead">
      <view class="item-2">功率范围(瓦)</view>
      <view class="item-2">分钟</view>
    </view>
    <view class="flex-box table tc">
      <view class="item-2">1-100</view>
      <view class="item-2">每元240分钟</view>
    </view>
  </view>

  <!-- 多行合并表格 -->
  <view class="advance-area">
    <view class="flex-box tc thead">
      <view class="item-3">功率范围</view>
      <view class="item-3">金额</view>
      <view class="item-3">分钟</view>
    </view>
    <view class="flex-box table tc">
      <view class="item-3">1-100</view>
      <view class="item-3">
        <view class="table-flex">
          <view class="item">1</view>
          <view class="item">2</view>
        </view>
      </view>
    </view>
  </view>
</template>
```

```scss
$color: #e0e0e0;

.flex-box { display: flex; flex-wrap: wrap; }
.flex-box > .item-2 { flex: 0 0 50%; }
.flex-box > .item-3 { flex: 0 0 33.3333%; }

.item-2, .item-3 {
  font-size: 26upx;
  border: 1upx solid $color;
  border-width: 1upx 1upx 0 0;
  padding: 16upx 0;
  box-sizing: border-box;
  text-align: center;

  &:first-child { border-left-width: 1upx; }
  &:last-child  { border-right-width: 1upx; }
}

.table:last-child { border-bottom: 1upx solid $color; }

.table-flex {
  flex: 1;
  .item {
    border-bottom: 1upx solid $color;
    padding: 10upx 0;
    box-sizing: border-box;
    &:last-child { border-width: 0; }
  }
}
```

## 设计要点

| 要点 | 说明 |
| ---- | ---- |
| 命名 `mTable` 而非 `table` | uniapp 保留关键字 |
| `.thead` 加 `font-weight: bold` | 视觉层级 |
| 边框分拆 | `border-width` 分边叠加，比直接 `border: 1upx` 更可控 |
| `.table-flex` 内嵌 | 实现"行内多行"效果 |

## 适用场景

- 价格表、规格表
- 收益明细表格
- 订单信息汇总

## 平台兼容性

- H5 / 小程序 / App：✅

## 进阶

- 大表格数据用 `v-for` + `<scroll-view scroll-x>` 横向滚动
- 加 `colspan` 效果：在嵌套层中用 `flex: 2` 控制宽度比例
- 加点击排序：在 `<view>` 上 `@tap` 切换 `flex-direction: column-reverse`