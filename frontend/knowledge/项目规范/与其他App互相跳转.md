---
title: uni-app 与其他 App 互相跳转
platform: uniapp
compatibility: uniapp-only
domain: 项目规范
source: 综合实践
tags: [scheme, plus.runtime, 跳转外部App, scheme跳转, 常见问题]
---

> ⚠️ 本知识仅适用于 **uni-app 自定义组件 / uni-app App 端** 场景。
> H5 / 小程序跨 App 跳转有平台限制，**不能**完全复用本方案。

# uni-app 与其他 App 互相跳转

## 一、uni-app 跳转到外部 App

### App 端：plus.runtime.openURL

```js
// 跳转到指定 scheme
plus.runtime.openURL('taobao://item.htm?id=123', (err) => {
  uni.showToast({ title: '未安装淘宝' })
})

// 跳转到应用市场详情页
plus.runtime.openURL(
  'market://details?id=com.tencent.mm',
  (err) => { uni.showToast({ title: '未找到应用市场' }) }
)
```

### App 端：plus.runtime.launchApplication（仅 Android）

```js
const main = plus.android.runtimeMainActivity()
const Intent = plus.android.importClass('android.content.Intent')
const intent = new Intent(Intent.ACTION_VIEW,
  plus.android.invoke('android.net.Uri', 'parse', 'weixin://'))
main.startActivity(intent)
```

### H5 端：location.href

```js
window.location.href = 'taobao://item.htm?id=123'
```

## 二、其他 App 跳转到 uni-app

### 1. 配置 URL Scheme

在 `manifest.json` 中声明（仅 App 端）：

```json
{
  "app-plus": {
    "distribute": {
      "android": {
        "schemes": "myuniapp"
      },
      "ios": {
        "urltypes": "myuniapp"
      }
    }
  }
}
```

### 2. 监听启动参数

```js
// main.js 或 App.vue
const args = plus.runtime.arguments
if (args) {
  // args 为 scheme:myuniapp?from=other&uid=xxx 解析后的参数
  const params = parseQuery(args.split('?')[1])
  uni.navigateTo({ url: `/pages/detail/detail?id=${params.id}` })
}
```

### 3. 监听「被第三方调起」

`App.vue` 的 `onShow` 生命周期可获取启动参数：

```js
onShow(options) {
  // options.query 是从其他 App 带入的 query
  console.log(options.query)
}
```

## 三、小程序互相跳转

微信小程序 → 公众号 / 其他小程序：

```js
uni.navigateToMiniProgram({
  appId: 'wxOtherAppid',
  path: 'pages/index/index',
  extraData: { foo: 'bar' }
})
```

## 实践提示

1. iOS 9+ 必须配置 `LSApplicationQueriesSchemes` 才能检测是否安装了目标 App。
2. 跳转到外部 App 后再回到当前 App，会触发 `App.vue` 的 `onShow`。
3. 小程序跳转其他小程序前需在「微信公众平台 → 关联小程序」中添加目标。
4. 测试 scheme 时建议用 `adb shell am start -a android.intent.action.VIEW -d "myuniapp://xxx"` 调试。