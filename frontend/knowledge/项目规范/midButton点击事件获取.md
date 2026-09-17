---
title: midButton 触发的点击事件
platform: uniapp
compatibility: uniapp-only
domain: 项目规范
source: 综合实践
tags: [midButton, tabBar, onTabItemTap, App.vue, 常见问题]
---

> ⚠️ 本知识仅适用于 **uni-app 自定义组件 / uni-app App 端** 场景。
> midButton 是 App / H5 端专有特性，**不能**在小程序端复用。

# 获取 midButton 触发的点击事件

## 背景

`pages.json` 的 `tabBar.midButton` 是悬浮在 tabBar 中间的特殊按钮。
uni-app **没有**单独的 `@click` 事件，需要借助 `App.vue` 的全局生命周期 `onTabItemTap` 或自行监听 `plus.nativeObj` 区域。

## 方案一：onTabItemTap（推荐）

```js
// App.vue
export default {
  onLaunch() {},
  onTabItemTap(e) {
    // e.index: tabBar 项索引
    // e.text:   按钮文字
    // e.pagePath: 所属页面路径
    if (e.index === 0 && e.text === '发布') {
      uni.navigateTo({ url: '/pages/publish/publish' })
    }
  }
}
```

> midButton 不属于「tabBar 项」，**默认不会**触发 `onTabItemTap`。
> 需要在 `midButton` 实际跳转的占位页里使用方案二。

## 方案二：占位页 + navigator（推荐）

将 midButton 实际跳转的占位页留空，在该页的 `onLoad` 中真正执行跳转：

```js
// pages/midplaceholder/midplaceholder.vue
export default {
  onLoad() {
    uni.redirectTo({ url: '/pages/publish/publish' })
  }
}
```

```json
{
  "tabBar": {
    "midButton": {
      "pagePath": "pages/midplaceholder/midplaceholder",
      "text": "发布",
      "iconPath": "static/tabbar/add.png"
    }
  }
}
```

## 方案三：自定义原生 View（App 端）

通过 `plus.nativeObj.View` 覆盖在 midButton 位置，监听 click：

```js
// 仅 Android 可直接监听，iOS 需特殊处理
const view = new plus.nativeObj.View('midBtnView', {
  bottom: '10px',
  left: '50%',
  width: '60px',
  height: '60px',
  marginLeft: '-30px'
})
view.drawText('+', { color: '#fff', size: 32 })
view.addEventListener('click', (e) => {
  uni.navigateTo({ url: '/pages/publish/publish' })
})
view.show()
```

## 实践提示

1. midButton **仅 App / H5** 端支持，小程序自动忽略。
2. midButton 跳转必须填 `pagePath`，但实际可以快速重定向。
3. iOS 端 midButton 上的自定义事件需要绕开 `tabBar`，建议用占位页方案。
4. 自定义悬浮按钮可改用「自由拖动按钮」组件（见 `wiki/功能/自由拖动按钮.md`），更灵活。