---
title: Vue3 H5 移动端项目模板 - 技术选型总览
platform: h5
compatibility: vue3-only
domain: 技术选型
source: vue3-h5-template-master/package.json + vite.config.ts + tsconfig.json
tags: [技术选型, Vue3, Vite, H5, 移动端, 基础模板]
---

# Vue3 H5 移动端项目模板 — 技术选型总览

> 适用场景：**纯 H5 移动端**（仅运行在浏览器环境，不包含小程序/App 端）。
> 项目原型：[yulimchen/vue3-h5-template](https://github.com/yulimchen/vue3-h5-template)
> 基于 Vue 3.5 + Vite 8 + TypeScript 5.6 的开箱即用移动端模板。

## 一、技术栈全景图

```
┌──────────────────────────────────────────────────────────────────┐
│                  Vue3 H5 移动端项目技术栈                          │
├──────────────────────────────────────────────────────────────────┤
│  视图层      Vue 3.5 + Vant 4                                   │
│  路由        Vue Router 4 (Hash 模式)                            │
│  状态管理    Pinia 2 + Setup Store                               │
│  工具集      @vueuse/core 14                                     │
│  网络        Axios 1 + NProgress + Mock                          │
│  样式方案    Tailwindcss v4 + Less + vmin 视口适配                │
│  图标方案    Iconify 4 (在线+离线) + 本地 SVG Sprite              │
│  工具方法    clsx + tailwind-merge (cn 合并类名)                  │
│  构建工具    Vite 8 + Rolldown                                   │
│  类型系统    TypeScript 5.6 + vue-tsc                            │
│  代码规范    ESLint 9 (@antfu config) + Commitlint              │
│  工程化      Husky 9 + lint-staged + standard-version           │
│  部署        GitHub Pages (workflow) / 自建 Nginx                │
│  调试        eruda (移动端调试面板)                               │
└──────────────────────────────────────────────────────────────────┘
```

## 二、核心库完整清单

### 2.1 运行时依赖（dependencies）

| 库 | 版本 | 用途 | 备注 |
|---|---|---|---|
| `vue` | ^3.5.24 | 视图框架 | 使用 `<script setup>` + `defineOptions` 宏 |
| `vue-router` | ^4.6.3 | 路由 | 哈希模式 `createWebHashHistory()` |
| `pinia` | ^2.3.1 | 状态管理 | Setup Store 写法 + `storeToRefs` |
| `@vueuse/core` | ^14.2.1 | 组合式工具集 | 使用 `useTitle` 设置页面标题 |
| `vant` | ^4.9.21 | 移动端 UI 组件库 | 按需引入 (VantResolver) |
| `axios` | ^1.13.2 | HTTP 客户端 | 封装为 `http` 工具，统一拦截器 |
| `clsx` | ^2.1.1 | 条件类名拼接 | 与 tailwind-merge 配合 |
| `tailwind-merge` | ^2.6.0 | Tailwind 类名合并去重 | 提供 `cn()` 工具函数 |
| `nprogress` | ^0.2.0 | 顶部加载进度条 | 在 axios 拦截器中调用 |
| `normalize.css` | ^8.0.1 | 浏览器样式重置 | 在 main.ts 中导入 |

### 2.2 开发依赖（devDependencies）

| 库 | 版本 | 用途 | 备注 |
|---|---|---|---|
| `vite` | ^8.0.13 | 构建工具 | 使用 Rolldown 输出 |
| `@vitejs/plugin-vue` | ^6.0.7 | Vue SFC 支持 | .vue 文件编译 |
| `@vitejs/plugin-vue-jsx` | ^5.1.5 | JSX 支持 | .tsx 文件编译 |
| `typescript` | ~5.6.3 | 类型系统 | strict 模式开启 |
| `vue-tsc` | ^2.2.12 | 类型检查 | build 前类型校验 |
| `@vue/tsconfig` | ^0.5.1 | Vue TS 配置继承 | 基础配置预设 |
| `tailwindcss` | ^4.0.0 | 原子化 CSS | v4 新语法 |
| `@tailwindcss/postcss` | ^4.0.0 | PostCSS 适配器 | v4 必需 |
| `postcss` | ^8.5.6 | CSS 后处理 | 必备底层 |
| `postcss-rem-to-pixel` | ^4.1.2 | rem 转 px | Tailwind v4 默认 rem，需转换 |
| `cnjm-postcss-px-to-viewport` | ^1.0.1 | px 转 vmin | 移动端视口适配核心 |
| `less` | ^4.4.2 | Less 编译器 | 用于 scoped 样式 |
| `unplugin-auto-import` | ^21.0.0 | API 自动按需导入 | Vue/Router/Pinia 自动可用 |
| `unplugin-vue-components` | ^32.0.0 | 组件自动按需导入 | 自动注册 Vant + 自定义组件 |
| `@iconify/vue` | ^4.3.0 | 图标组件 | 200,000+ 图标库 |
| `@iconify-icons/fa6-solid` | ^1.2.13 | FontAwesome 离线图标包 | 内网环境备选 |
| `vite-plugin-svg-icons-ng` | ^1.9.1 | SVG 雪碧图 | 把 src/icons/svg 编译为 symbol |
| `vite-plugin-mock-dev-server` | ^2.2.1 | Mock 服务 | dev server 拦截 /dev-api |
| `vite-plugin-cdn2` | ^1.1.0 | 生产环境 CDN 加载 | unpkg CDN |
| `vite-plugin-compression2` | ^2.5.3 | gzip 压缩 | 减小产物体积 |
| `mockjs` | ^1.1.0 | 假数据生成 | 与 vite-plugin-mock 搭配 |
| `@antfu/eslint-config` | ^7.2.0 | ESLint 预设 | 业界知名严格规则集 |
| `eslint` | ^9.39.1 | 代码检查 | flat config 模式 |
| `husky` | ^9.1.7 | Git hooks | pre-commit + commit-msg |
| `commitlint` | ^19.8.1 | 提交信息规范 | Angular 规范 |
| `@commitlint/config-conventional` | ^19.8.1 | commitlint 规则 | 配套规则集 |
| `standard-version` | ^9.5.0 | 自动版本管理 | 自动生成 CHANGELOG |
| `npm-run-all` | ^4.1.5 | 串并执行 npm scripts | 用于 build 串联 type-check |

## 三、运行环境要求

```json
"engines": {
  "node": ">= 20",
  "pnpm": ">= 9"
}
```

`.nvmrc` 锁定 Node 版本：`v18.18.2`（兼容旧版）。

## 四、npm scripts

| 命令 | 作用 |
|---|---|
| `pnpm dev` | 启动 Vite 开发服务器 |
| `pnpm build` | 串行执行 `build-only` → `type-check`（产出可用产物） |
| `pnpm build-only` | 仅执行 `vite build`（跳过类型检查，速度快） |
| `pnpm preview` | 预览 dist 产物 |
| `pnpm type-check` | `vue-tsc --noEmit` 类型检查 |
| `pnpm lint` | `eslint .` 检查 |
| `pnpm lint:fix` | `eslint . --fix` 自动修复 |
| `pnpm release` | `standard-version` 自动生成 tag/CHANGELOG |
| `pnpm prepare` | 自动安装 husky |

## 五、技术选型核心权衡

| 维度 | 本项目选择 | 替代方案 | 选择理由 |
|---|---|---|---|
| 构建工具 | Vite 8 (Rolldown) | Webpack 5 | 启动毫秒级，HMR 快 |
| 视图框架 | Vue 3.5 | React 18 | 中文社区更活跃，移动端库生态好 |
| 路由模式 | Hash | History | H5 静态部署友好，无需服务端配置 |
| 状态管理 | Pinia 2 | Vuex 4 | 官方推荐，类型推断友好 |
| UI 库 | Vant 4 | NutUI / Cube-UI | 移动端场景覆盖最完整 |
| 样式方案 | Tailwind v4 + Less | 纯 CSS / SCSS | 原子化 + 灵活定制 |
| 图标方案 | Iconify + 本地 SVG | iconfont / 雪碧图 | 跨源、跨框架 |
| 视口单位 | vmin | rem / vw | vmin 同时兼顾横竖屏 |
| 适配策略 | postcss 转 vmin | flexible.js 动态算 rem | 静态方案，构建期完成 |
| 模拟数据 | vite-plugin-mock-dev-server | json-server / mockjs | 集成度高，无需额外进程 |
| 包管理 | pnpm 9 | npm / yarn | 节省磁盘空间、依赖更严谨 |

## 六、与 uni-app 模板的关键区别

| 维度 | vue3-h5-template | uniapp-plugin-collections |
|---|---|---|
| 目标环境 | **纯 H5（浏览器）** | H5 + 小程序 + App |
| 路由 | Vue Router 4 | uni-app 自带路由 |
| UI 库 | Vant 4 | uView / 自定义组件 |
| 适配单位 | px → vmin | rpx / upx |
| 状态管理 | Pinia | Pinia / Vuex |
| API 命名 | 标准 ES2015+ | 必须 `uni.*` / `plus.*` |
| 跨端条件编译 | 不需要 | `/* #ifdef H5 */` |

## 七、可选扩展（未在依赖中）

如果需要，按需安装：

- **i18n**：用 [vue-i18n](https://vue-i18n.intlify.dev/)；项目官方有 [i18n 分支](https://github.com/yulimchen/vue3-h5-template/tree/i18n)。
- **富文本**：[wangEditor](https://www.wangeditor.com/) 或 [Tiptap](https://tiptap.dev/)。
- **图表**：[echarts-for-vue](https://github.com/ecomfe/vue-echarts) 或 [Chart.js](https://www.chartjs.org/)。
- **二维码**：[qrcode](https://github.com/soldair/node-qrcode) 或 [vue-qrcode](https://github.com/fengxinming/vue-qrcode)。
- **Lottie**：[vue3-lottie](https://github.com/megasanjay/vue3-lottie)（轻量级动画）。

## 八、关键注意点

1. **不能直接套用 uni-app 组件库**：本模板为浏览器环境，组件依赖 `window`/`document`/`localStorage`，在微信小程序/App 中会报错。
2. **Hash 路由 + 静态部署友好**：若要切到 History 模式，需要服务端配置 fallback。
3. **vmin 而非 vw/vh**：vmin 在横屏/竖屏切换时能保证元素大小一致；如使用 vw，横屏时元素会过大。
4. **Tailwind v4 改变了 `@apply` 语法**：很多旧教程不再适用。
5. **eruda 仅开发环境启用**：通过 `VITE_ENABLE_ERUDA` 控制，生产环境不会被打包。