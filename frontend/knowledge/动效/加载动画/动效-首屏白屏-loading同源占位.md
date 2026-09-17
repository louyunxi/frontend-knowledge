---
title: "首屏白屏优化 - Loading 同源占位"
description: "SPA 首屏加载时，index.html 直接渲染与页面同源的 loading 占位，避免白屏与切换闪烁"
domain: 动效
type: best
source_scope: "D:\\anhui-agri\\anhui-agri-data-app\\apps\\app-farming-model\\index.html（Vue 3 + Vite SPA），可泛化到任意 Web SPA / MPA 首屏"
observed_platforms:
  - web
  - mobile
confidence: high
---

# 首屏白屏优化 - Loading 同源占位

## 概述

SPA 应用首屏常见痛点：用户打开页面 → HTML 已到达浏览器但 JS bundle 还在下载/解析/执行 → 用户看到几秒甚至十几秒的纯白屏 → Vue/React 挂载后才出现真实内容。`index.html` 即便只显示一个转圈 loading，也能显著降低等待焦虑，但要避免 **"loading 视觉"与"页面真实内容"突然切换造成的闪一下**。

本知识蒸馏 `app-farming-model` 项目 `index.html` 的最佳实践：**让首屏 loading 节点在浏览器解析 HTML 时即已存在，CSS 全部内联不依赖任何外部资源，loading 视觉与后续页面背景、配色保持同源；JS 完成后用淡出过渡再移除节点，避免跳变。**

## 适用场景

### ✅ 适合
- Vue / React / Solid 等 SPA 框架的 Web 应用
- UniApp H5 端、APP 内嵌 H5 页面
- 后台管理系统、报表系统、GIS 大屏等 JS bundle 较大的项目
- 首屏 FCP / LCP 较差的白屏问题

### ❌ 不适合
- 已启用 SSR / SSG / Next.js / Nuxt 的项目（首屏 HTML 已含内容，只需骨架屏或水合加载）
- 纯静态站点（HTML 已是完整页面）
- 单文件 < 50KB 的轻量 H5（白屏时间可忽略）

## 为什么这样做

| 维度 | 不做（本方案之外） | 做（本方案） |
|----|--------------------|--------------|
| 浏览器看到的内容 | 纯白屏（body 默认底色） | 与页面同源的 loading 视觉 |
| FCP 时刻 | 加载完成时直接跳到内容 | 加载完成时从 loading 平滑过渡到内容 |
| 错误反馈 | 白屏无任何线索 | loading 暗示「正在加载」 |
| 闪一下 | 较常见（loading 与内容切换突兀） | 通过过渡动画消除 |

## 核心原则

1. **CSS 必须内联**：`loading` 样式写在 `<head>` 内联 `<style>` 里，绝不依赖外部 CSS（外部 CSS 没加载之前一切都白屏）。
2. **loading 节点放在 `<body>` 顶部**：紧随 `<body>` 之后，浏览器解析到此节点即开始渲染。
3. **同源视觉**：loading 背景色、主题色与 SPA 页面真实背景一致，避免色彩跳变。
4. **关闭条件由 SPA 框架通知**：Vue `app.mount()` 完成 / React 根组件 `useEffect` 完成后调用 `__hideAppLoading()`。
5. **淡出后移除**：先 `opacity: 0` + `pointer-events: none`，再用 `setTimeout` 从 DOM 移除节点（避免 transition 动画被中断）。
6. **`prefers-reduced-motion`**：尊重用户的减少动效偏好，无动效模式下直接移除。
7. **z-index 必须最高**：使用 `position: fixed; inset: 0; z-index: 9999`（或更高），避免被弹窗、路由切换层覆盖。

## 快速使用

### 最小可运行骨架（Vue 3 + Vite）

这是蒸馏来源 `app-farming-model/index.html` 的完整模板化版本，可直接套用到任何 Vue 项目：

```html
<!DOCTYPE html>
<html lang="zh">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>你的应用名称</title>
    <style>
      html, body { margin: 0; padding: 0; width: 100%; height: 100%; }

      /* 真实页面背景：必须与 #app 后续背景保持一致 */
      #app { width: 100%; height: 100%; background: #0b1220; }

      /* 首屏 loading —— 与 #app 背景同源 */
      #app-loading {
        position: fixed; inset: 0; z-index: 9999;
        display: flex; align-items: center; justify-content: center;
        background: #0b1220;
        transition: opacity 0.3s ease;
      }
      #app-loading.hide { opacity: 0; pointer-events: none; }

      /* loading 内容 */
      #app-loading .spinner {
        width: 48px; height: 48px;
        border: 3px solid rgba(255, 255, 255, 0.15);
        border-top-color: #4f9bff;
        border-radius: 50%;
        animation: spin 0.9s linear infinite;
      }
      @keyframes spin { to { transform: rotate(360deg); } }

      @media (prefers-reduced-motion: reduce) {
        #app-loading .spinner { animation: none; }
        #app-loading { transition: none; }
      }
    </style>
  </head>
  <body>
    <!-- ① loading 节点紧随 <body>，不依赖任何 JS 即可渲染 -->
    <div id="app-loading" aria-label="加载中" role="status">
      <div class="spinner"></div>
    </div>

    <!-- ② 真实应用根 -->
    <div id="app"></div>

    <!-- ③ 主入口脚本 -->
    <script type="module" src="/src/main.ts"></script>

    <!-- ④ 暴露给框架调用，框架挂载完成后调用此方法移除 loading -->
    <script>
      window.__hideAppLoading = function () {
        var el = document.getElementById('app-loading');
        if (!el) return;
        el.classList.add('hide');
        setTimeout(function () {
          el.parentNode && el.parentNode.removeChild(el);
        }, 350); // 与 transition 时长匹配
      };
    </script>
  </body>
</html>
```

```ts
// src/main.ts —— Vue 3 入口
import { createApp } from 'vue';
import App from './App.vue';

createApp(App).mount('#app');

// 通知移除首屏 loading
window.__hideAppLoading?.();
```

### React 18（createRoot）

```html
<!-- 与上述 HTML 结构完全一致，仅 #app-loading 容器保持不变 -->
<div id="app-loading" aria-label="加载中" role="status">
  <div class="spinner"></div>
</div>
<div id="root"></div>
<script type="module" src="/src/main.tsx"></script>
<script>
  window.__hideAppLoading = function () {
    var el = document.getElementById('app-loading');
    if (!el) return;
    el.classList.add('hide');
    setTimeout(function () { el.remove(); }, 350);
  };
</script>
```

```tsx
// src/main.tsx
import { createRoot } from 'react-dom/client';
import App from './App';

createRoot(document.getElementById('root')!).render(<App />);

window.__hideAppLoading?.();
```

### 原生 / jQuery SPA

```js
// 简单粗暴：DOMContentLoaded 时移除
document.addEventListener('DOMContentLoaded', () => {
  window.__hideAppLoading?.();
});

// 远程接口全部完成
window.addEventListener('load', () => {
  // 兜底：即使框架未通知，到 load 事件也强制移除
  setTimeout(() => window.__hideAppLoading?.(), 300);
});
```

## 进阶用法

### 1. 品牌定制 Loading（替换为 Logo + 文字）

更适合需要展示品牌调性的后台/大屏应用：

```html
<div id="app-loading" role="status" aria-label="应用加载中">
  <div class="brand">
    <img src="data:image/svg+xml;base64,..." alt="" aria-hidden="true" />
    <h1>耕云农业大模型</h1>
    <p>正在加载…</p>
    <div class="progress"></div>
  </div>
</div>
```

> Logo 推荐用 **base64 / data URI 内联**，避免外链图片未到达时空一段；或使用纯 CSS / SVG 实现的 logo。

### 2. 骨架屏作为 Loading（结构同源）

如果首屏能预判出页面布局（仪表盘、列表），可在 `#app-loading` 内嵌入骨架屏，让 loading 与最终页面结构几乎一致，做到「**真页面就位时只换数据不换骨架**」：

```html
<div id="app-loading">
  <div class="skeleton">
    <div class="sk-header"></div>
    <div class="sk-row"></div>
    <div class="sk-row"></div>
    <div class="sk-chart"></div>
  </div>
</div>
```

骨架屏结构应与首屏实际布局一一对应（header / 列表行 / 图表区），推荐使用 `<div>` + `linear-gradient` 的「流光」动画即可。

### 3. 进度条式（NProgress 思路）

适合需要传达「加载进度」的应用（不展示准确百分比，只表达"在动"）：

```html
<div id="app-loading">
  <div class="bar"><div class="bar-inner"></div></div>
</div>
<style>
  #app-loading .bar { width: 200px; height: 3px; background: rgba(255,255,255,.1); border-radius: 999px; overflow: hidden; }
  #app-loading .bar-inner { height: 100%; width: 30%; background: #4f9bff; animation: progress 1.2s ease-in-out infinite; }
  @keyframes progress { 0% { transform: translateX(-100%); } 100% { transform: translateX(330%); } }
</style>
```

### 4. 与异步数据加载并行（推荐大型 SPA）

某些 SPA 即使框架挂载完成，首屏数据仍未返回（如仪表盘接口耗时数秒）。此时首屏 loading 应**延后到首屏数据加载完成**：

```ts
// main.ts
import { createApp } from 'vue';
import { createPinia } from 'pinia';
import App from './App.vue';
import { useDashboardStore } from '@/stores/dashboard';

const app = createApp(App);
app.use(createPinia());
app.mount('#app');

// 等待首屏关键数据
const store = useDashboardStore();
await store.loadInitialData();

window.__hideAppLoading?.();
```

### 5. SSR / SSG 兼容

若项目同时支持 SSR（如 Nuxt / Next），需要在 SSR HTML 输出中也包含 `#app-loading`，并在水合完成后移除。Nuxt 示例：

```ts
// plugins/loading.client.ts
export default defineNuxtPlugin((nuxtApp) => {
  nuxtApp.hook('app:mounted', () => {
    window.__hideAppLoading?.();
  });
});
```

水合结束后通过 `app:mounted` hook 调用 `__hideAppLoading`。

## 注意事项 / 边界

### ⚠️ 不能省略的坑

1. **`<script type="module">` 默认 defer**：`type="module"` 的脚本本就等 DOM 解析完毕后执行，所以把 `__hideAppLoading` 暴露放在主入口之后是安全的。但若用 `<script src="...">` 非 module，需把它放在 `<body>` 末尾或加 `defer`。
2. **z-index 过低被覆盖**：若项目里有全屏 Modal / Drawer / 路由切换遮罩层（z-index ≥ 9999），需要在 loading 移除后再让它们出现，或给 loading 用更高 z-index（99999 + !important）。
3. **`pointer-events: none` 必须加上**：淡出过程中如果允许点击，可能误触底层空白 DOM。
4. **移动端 100vh 问题**：iOS Safari 底部地址栏收起/展开会改变 `100vh` 实际可用高度。如使用 `100vh` 做 loading 高度，推荐改为 `100dvh` 或 `height: 100%; min-height: -webkit-fill-available;`。
5. **JS 加载失败 = loading 永久存在**：当主 bundle 404 / 解析失败时，loading 永远不消失，必须在 `<script>` 末尾追加：
   ```html
   <script>
     // 兜底：5 秒还没被移除，强制移除（避免 JS 失败导致 loading 卡死）
     setTimeout(function () { window.__hideAppLoading?.(); }, 5000);
   </script>
   ```
6. **不要在加载 `<body>` 前阻塞 JS**：把 `<script src="/main.js">` 放在 loading 节点之后是允许的，但若 `<script>` 里有同步阻塞逻辑，仍可能延后 loading 渲染。推荐 `<script type="module">` 加在 `<body>` 末尾。
7. **`prefers-reduced-motion` 无障碍**：必须遵守。在 `prefers-reduced-motion: reduce` 下，应当直接移除 loading（不走淡出）。
8. **SEO 影响**：搜索引擎爬虫看到的是 loading DOM 而不是真实内容。若 SEO 重要，应同时提供 SSR / SSG 静态快照。

### 🔍 性能指标说明

- **FCP (First Contentful Paint)**：本方案把 FCP 从"白屏"推进到"loading 节点"，LCP 仍需框架挂载后内容出现。
- **LCP (Largest Contentful Paint)**：需要进一步做代码分割、preload、preconnect 等优化。本知识只解决"看到 loading"。
- **CLS (Cumulative Layout Shift)**：loading 节点的尺寸 = 后续页面尺寸（`100%`），可保持 CLS ≈ 0。

## 常见问题

### Q1: Loading 长时间不消失？

检查：
1. `main.ts` / `main.tsx` 是否调用了 `window.__hideAppLoading?.()`。
2. 浏览器 Network 中主 bundle 是否下载成功。
3. 框架是否报错导致未走到挂载后代码。
4. 加上文末兜底 `setTimeout`。

### Q2: 还是会闪一下？

确保：
1. `#app-loading` 的背景色 与 `#app` 真实背景色完全一致（包括渐变）。
2. 用淡出 + setTimeout 删除节点，不要直接 `el.remove()`。
3. 不要把 loading 节点放在 `#app` 内部（会被框架替换）。

### Q3: 与骨架屏冲突？

首屏 loading 用 `#app-loading`（fixed），**组件级骨架屏**用组件内部 `.skeleton`。两者层叠互不干扰，组件级骨架屏在数据加载期间替代真实组件。

### Q4: 多页应用 / 多入口怎么复用？

每个入口（如 `login.html`、`dashboard.html`）各自一份 `#app-loading`，但建议把通用样式抽取到一个 inline helper：

```html
<!-- partials/loading.html -->
<style><%= include loading.css %></style>
<div id="app-loading">...</div>
<script>window.__hideAppLoading = ...</script>
```

### Q5: iOS Safari 上的特殊性？

`100vh` 会受地址栏影响。改用 `100%`（继承 html/body）或 `100dvh`（dynamic viewport height）。同时给 `body` 加 `-webkit-overflow-scrolling: touch`。

## 性能优化技巧

1. **CSS 内联到 `<head>`**：本方案核心就是 CSS 内联，避免外部 CSS 阻塞 loading 渲染。
2. **`will-change: opacity`**：给 `#app-loading` 加 `will-change: opacity` 提示浏览器 GPU 提升淡出性能。
3. **`content-visibility: auto`**：对内部的 spinner / skeleton 节点标注，让非可视区域跳过渲染。
4. **spinner 优先用纯 CSS**：避免引入 GIF / 视频；纯 CSS spinner ≈ 0 KB。
5. **延迟非关键节点**：logo 改为 base64 SVG inline，不要用 `<img src>` 外链。

## 相关模式

- [`../../动效/gsap页面过渡.md`](../../动效/gsap页面过渡.md) - 路由切换动画
- [`../../动效/动效缓动与设计哲学.md`](../../动效/动效缓动与设计哲学.md) - 缓动曲线选择（淡出过渡参考）
- [`../../设计主题/UniApp移动端Token系统.md`](../../设计主题/UniApp移动端Token系统.md) - 设计 Token 复用，使 loading 与页面配色同源
- [`../../项目规范/界面文案写作原则.md`](../../项目规范/界面文案写作原则.md) - "正在加载..." 文案统一规范

## 参考资料

- [Web Vitals - Optimize FCP & LCP](https://web.dev/vitals/)
- [MDN - prefers-reduced-motion](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-reduced-motion)
- [Vite - 静态资源内联](https://cn.vitejs.dev/guide/assets.html)
- [Nuxt - app:mounted hook](https://nuxt.com/docs/api/advanced/hooks)

---

## 元信息

| 属性 | 值 |
|-----|---|
| 复杂度 | ⭐ (1/5 星) |
| 适用框架 | Vue / React / 任意 SPA |
| 蒸馏来源 | `D:\anhui-agri\anhui-agri-data-app\apps\app-farming-model\index.html` |
| 标签 | loading, first-screen, fcp, spa, vite, vue, react, perf |
| 创建日期 | 2026-09-16 |
| 技术栈 | 任意 Web SPA |
