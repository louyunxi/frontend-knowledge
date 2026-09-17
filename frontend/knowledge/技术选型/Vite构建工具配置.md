---
title: Vite 8 构建工具配置（vue3-h5-template）
platform: h5
compatibility: vue3-only
domain: 技术选型
source: vue3-h5-template-master/vite.config.ts + postcss.config.js + build/cdn.ts
tags: [Vite, 构建工具, 构建配置, H5, 自动导入]
---

# Vite 8 构建工具配置（vue3-h5-template）

> 适用场景：基于 Vite 8 构建的**纯 H5** Vue3 移动端项目。
> 本文档提炼 vue3-h5-template 项目的 Vite 配置，包含所有插件用途、调用时机和注意事项。

## 一、整体配置骨架

```ts
// vite.config.ts
import path from 'node:path'
import process from 'node:process'
import { fileURLToPath, URL } from 'node:url'
import vue from '@vitejs/plugin-vue'
import vueJsx from '@vitejs/plugin-vue-jsx'
import AutoImport from 'unplugin-auto-import/vite'
import { VantResolver } from 'unplugin-vue-components/resolvers'
import Components from 'unplugin-vue-components/vite'
import { defineConfig, loadEnv } from 'vite'
import { compression } from 'vite-plugin-compression2'
import { mockDevServerPlugin } from 'vite-plugin-mock-dev-server'
import { createSvgIconsPlugin } from 'vite-plugin-svg-icons-ng'
import { enableCDN } from './build/cdn'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  return {
    base: env.VITE_PUBLIC_PATH || '/',
    plugins: [
      vue(),
      vueJsx(),
      mockDevServerPlugin(),
      AutoImport({ ... }),
      Components({ resolvers: [VantResolver()] }),
      createSvgIconsPlugin({ ... }),
      compression(),
      enableCDN(env.VITE_CDN_DEPS),
    ],
    resolve: {
      alias: { '@': fileURLToPath(new URL('./src', import.meta.url)) },
    },
    server: {
      host: true,
      proxy: { '^/dev-api': { target: '' } },
    },
    build: {
      rolldownOptions: {
        output: {
          chunkFileNames: 'static/js/[name]-[hash].js',
          entryFileNames: 'static/js/[name]-[hash].js',
          assetFileNames: 'static/[ext]/[name]-[hash].[ext]',
        },
      },
    },
  }
})
```

要点：
- `loadEnv(mode, root, '')`：第三个参数空字符串表示加载所有不以 `VITE_` 为前缀的环境变量（用于 `VITE_PUBLIC_PATH` 注入）。
- `base`：产物部署路径，与 `VITE_PUBLIC_PATH` 联动（GitHub Pages 部署时改为 `/vue3-h5-template/`）。
- `host: true`：开发服务器监听 0.0.0.0，方便手机扫码调试。

## 二、9 个核心插件详解

### 2.1 `@vitejs/plugin-vue` — Vue SFC 支持

```ts
vue()
```

- 必须：解析 `.vue` 单文件组件。
- 内部调用 `@vue/compiler-sfc` 把 `<template>` `<script>` `<style>` 拆开。

### 2.2 `@vitejs/plugin-vue-jsx` — JSX 支持

```ts
vueJsx()
```

- 允许 `.tsx` 文件中写 Vue JSX 语法。
- 注意：**模板与 JSX 不能混用**于同一组件。

### 2.3 `mockDevServerPlugin()` — Mock 服务

```ts
mockDevServerPlugin()
```

- 拦截 `/dev-api` 前缀请求，由 `mock/list.mock.ts` 提供响应。
- **必须在 `server.proxy['^/dev-api'].target: ''`** 配合（空 target 让 mock 接管）。
- 详见 wiki/功能/网络层方案.md 或单独的 Mock 指南。

### 2.4 `unplugin-auto-import` — API 自动按需导入

```ts
AutoImport({
  imports: ['vue', 'vue-router', 'pinia', '@vueuse/core'],
  dts: 'src/typings/auto-imports.d.ts',
})
```

效果：

```vue
<script setup lang="ts">
// 不需要 import
const route = useRoute()
const router = useRouter()
const store = useStore()
const { isDark } = useDarkModeStore()

// 自动可用：ref, computed, watch, onMounted, nextTick...
</script>
```

生成的 `.d.ts` 必须加入 git，提供 TS 类型提示。

### 2.5 `unplugin-vue-components` — 组件自动按需导入

```ts
Components({
  dts: 'src/typings/components.d.ts',
  resolvers: [VantResolver()],
})
```

效果：

```vue
<template>
  <!-- 不需要 import { Button } from 'vant' -->
  <van-button type="primary">提交</van-button>
</template>
```

**VantResolver**：自动识别 `<van-xxx>` 前缀组件，按需打包。

### 2.6 `createSvgIconsPlugin` — SVG 雪碧图

```ts
createSvgIconsPlugin({
  iconDirs: [path.resolve(process.cwd(), 'src/icons/svg')],
  symbolId: 'icon-[dir]-[name]',
})
```

效果：

```vue
<!-- 使用本地 SVG -->
<svg-icon name="github" />

<!-- 实际引用的是 -->
<svg><use xlink:href="#icon-svg-github" /></svg>
```

优势：所有 SVG 合并到单个 `<symbol>` 标签，减少请求数。

### 2.7 `compression()` — gzip 压缩

```ts
import { compression } from 'vite-plugin-compression2'
compression()
```

构建时产出 `.gz` 文件，配合 nginx `gzip_static on;` 直接发送预压缩文件，**省 CPU**。

### 2.8 `enableCDN(env.VITE_CDN_DEPS)` — CDN 依赖

```ts
// build/cdn.ts
import { cdn } from 'vite-plugin-cdn2'
import { unpkg } from 'vite-plugin-cdn2/resolver/unpkg'

export function enableCDN(isEnabled: string) {
  if (isEnabled === 'true') {
    return cdn({
      resolve: unpkg(),
      modules: ['vue', 'vue-demi', 'pinia', 'axios', 'vant', 'vue-router'],
    })
  }
}
```

- 仅生产环境生效（`VITE_CDN_DEPS=true`）。
- 适用于**已部署公网、可访问 unpkg**的场景。
- 内网环境必须关闭，否则白屏。

### 2.9 `mockDevServerPlugin()` 必看说明

```ts
server: {
  proxy: {
    '^/dev-api': {
      target: '',  // 空 target
    },
  },
},
```

- **空 target** 是关键：mock 插件只会拦截代理路径前缀的请求。
- 一旦填写真实后端地址，请求会被转发到真实服务，mock 失效。

## 三、PostCSS 配置（Tailwind v4 + vmin 适配）

```js
// postcss.config.js
export default {
  plugins: {
    '@tailwindcss/postcss': {},
    'postcss-rem-to-pixel': {
      rootValue: 16,
      propList: ['*'],
    },
    'cnjm-postcss-px-to-viewport': {
      viewportWidth: 375,    // 设计稿宽度
      unitPrecision: 2,
      viewportUnit: 'vmin',
      fontViewportUnit: 'vmin',
      unitToConvert: 'px',
      mediaQuery: true,      // Tailwind v4 把所有 CSS 包裹在 @layer 中
    },
  },
}
```

### 三个插件的执行顺序与作用

| 顺序 | 插件 | 作用 |
|---|---|---|
| 1 | `@tailwindcss/postcss` | Tailwind v4 编译（生成 @layer 包裹的工具类） |
| 2 | `postcss-rem-to-pixel` | 把 Tailwind 默认生成的 `rem` 转回 `px` |
| 3 | `cnjm-postcss-px-to-viewport` | 把所有 `px` 转 `vmin`（移动端视口单位） |

### 为什么需要 rem → px → vmin？

Tailwind v4 默认输出 `1rem = 16px`，浏览器缩放会跟随系统设置，**不适合移动端精确适配**。
链路：Tailwind 输出 rem → rem 转回 px → px 转 vmin → 适配不同屏幕。

### vmin vs vw/vh

| 单位 | 含义 | 横屏表现 | 推荐 |
|---|---|---|---|
| `vw` | 视口宽度 | 大 | ❌ 横屏时元素过大 |
| `vh` | 视口高度 | 小 | ❌ 横屏时元素过小 |
| `vmin` | vw 与 vh 的较小值 | 始终等于较短边 | ✅ 横竖屏一致 |

### 为什么 viewportWidth 是 375？

- iPhone X 设计稿宽度通常为 375pt。
- 所有 `px` 值按 375 设计稿换算为 vmin。
- 不同设计稿需调整此值。

### 为什么需要 `mediaQuery: true`？

Tailwind v4 把所有规则包裹在 `@layer` 中，导致传统 `mediaQuery: false` 无法命中 `@media` 查询内的 px，必须开启。

## 四、TypeScript / 构建相关

```ts
// main.ts 入口
import 'normalize.css/normalize.css'
import './styles/index.less'
import './styles/tailwind.css'
import 'virtual:svg-icons/register'
```

**`virtual:svg-icons/register`** 是 Vite 提供的虚拟模块，把所有 SVG 雪碧图注册到 `document.body` 末尾，`<use>` 标签才能引用到。

## 五、构建产物命名规则

```ts
build: {
  rolldownOptions: {
    output: {
      chunkFileNames: 'static/js/[name]-[hash].js',
      entryFileNames: 'static/js/[name]-[hash].js',
      assetFileNames: 'static/[ext]/[name]-[hash].[ext]',
    },
  },
},
```

产出结构：

```
dist/
├── index.html
└── static/
    ├── js/
    │   ├── index-abc123.js
    │   ├── vendor-def456.js
    │   └── layout-ghi789.js
    ├── css/
    │   └── index-abc123.css
    └── img/
        └── logo_melomini-xyz789.png
```

要点：
- `[name]` 是 chunk 名。
- `[hash]` 是内容 hash，长文件名 + 文件指纹 → 永久缓存。
- 与 `vite-plugin-compression2` 配合后会有 `.gz` 文件。

## 六、环境变量加载机制

```ts
const env = loadEnv(mode, process.cwd(), '')
```

Vite 会自动加载：

- `.env` 所有环境共享
- `.env.development`（mode = development）
- `.env.production`（mode = production）
- `.env.local` 本地覆盖（不入 git）

前缀：
- `VITE_*`：暴露到客户端，通过 `import.meta.env.VITE_XXX` 访问。
- 非 `VITE_*`：仅服务端（如 `vite.config.ts`）可用。

## 七、常见踩坑

1. **`vite-plugin-svg-icons-ng` 不会自动压缩 SVG**：用 `svgo` 手动优化后再放入 `src/icons/svg/`。
2. **`@iconify/vue` 默认按需加载图标**：会发请求；内网环境务必安装离线包（`@iconify-icons/fa6-solid`）。
3. **Tailwind v4 与 v3 不兼容**：不要混用 v3 配置（`tailwind.config.js`）。
4. **Vant 按需引入必须在 `<van-config-provider>` 内使用**：否则主题不生效。
5. **`vue-tsc` 比 `tsc` 慢**：CI 中可加 `--noEmit` 跳过产物输出。