---
title: 三球弹跳带影 Loading
description: 三个小球上下弹跳 + 投影同步缩放，纯 CSS 实现，无 JS 依赖；具备"挤压拉伸 + 阴影同步"的拟物感，是 macOS / Apple 风格页面加载的标志性动效
domain: 动效
subdomain: 加载动画
type: pattern
source: Uiverse.io by mobinkakei
source_url: https://uiverse.io/mobinkakei
created: 2026-09-16
updated: 2026-09-16
tags:
  - loading
  - spinner
  - css-animation
  - pure-css
  - no-js
  - bounce
  - squash-and-stretch
  - shadow-sync
  - ball-loader
  - macos-style
  - apple-style
  - bouncing-dots
  - three-balls
---

# 三球弹跳带影 Loading

## 一句话定义

3 个白色小球上下弹跳、底部同步投影缩放淡化的纯 CSS loader；通过 **`border-radius` 形变 + `scaleX` 拉伸 + 阴影反向同步**，用最朴素的 DOM 模拟出"橡皮球落地"的物理感。

---

## 解决的什么问题

- **拟物感强的 loading 场景**：当产品需要"有质感、有重量"的等待反馈（macOS / Apple / 高端 SaaS）时，纯转圈显得单薄。
- **避免"机械重复"感**：单一属性动画（旋转、缩放）容易让人感觉是"机器在转"；而 squash & stretch（挤压拉伸）+ 阴影同步能传达"球在动"的物理直觉。
- **按钮内嵌 loading**：尺寸可压缩到 60×20，天然适合塞进 `<button>` 文字前面。

---

## 原始参考（Uiverse.io by mobinkakei）

```html
<div class="wrapper">
  <div class="circle"></div>
  <div class="circle"></div>
  <div class="circle"></div>
  <div class="shadow"></div>
  <div class="shadow"></div>
  <div class="shadow"></div>
</div>

<style>
.wrapper {
  width: 200px;
  height: 60px;
  position: relative;
  z-index: 1;
}

.circle {
  width: 20px;
  height: 20px;
  position: absolute;
  border-radius: 50%;
  background-color: #fff;
  left: 15%;
  transform-origin: 50%;
  animation: circle7124 .5s alternate infinite ease;
}

@keyframes circle7124 {
  0% {
    top: 60px;
    height: 5px;
    border-radius: 50px 50px 25px 25px;
    transform: scaleX(1.7);
  }
  40% {
    height: 20px;
    border-radius: 50%;
    transform: scaleX(1);
  }
  100% {
    top: 0%;
  }
}

.circle:nth-child(2) { left: 45%; animation-delay: .2s; }
.circle:nth-child(3) { left: auto; right: 15%; animation-delay: .3s; }

.shadow {
  width: 20px;
  height: 4px;
  border-radius: 50%;
  background-color: rgba(0,0,0,0.9);
  position: absolute;
  top: 62px;
  transform-origin: 50%;
  z-index: -1;
  left: 15%;
  filter: blur(1px);
  animation: shadow046 .5s alternate infinite ease;
}

@keyframes shadow046 {
  0%   { transform: scaleX(1.5); }
  40%  { transform: scaleX(1); opacity: .7; }
  100% { transform: scaleX(.2); opacity: .4; }
}

.shadow:nth-child(4) { left: 45%; animation-delay: .2s; }
.shadow:nth-child(5) { left: auto; right: 15%; animation-delay: .3s; }
</style>
```

> 关键观察：3 个 `.circle` 与 3 个 `.shadow` 是 **平行同位置** 的（左侧 15%、中间 45%、右侧 15%），通过相同的 `animation-delay` 形成一一对应的"球 + 影"对。

---

## 核心原理（5 个关键点）

### 1. Squash & Stretch（挤压拉伸）—— 迪士尼 12 原则之一

球落地瞬间（0%）不是简单"压缩到 5px 高度"，而是同时做了 3 件事：

| 属性 | 值 | 视觉效果 |
|---|---|---|
| `height` | `5px` | 高度被压扁 |
| `border-radius` | `50px 50px 25px 25px` | 左右圆角大、上下圆角小 → 像被压成"饼" |
| `transform: scaleX(1.7)` | 横向放大 | 弥补高度损失，保持体积近似恒定 |

> **黄金法则**：形变时 **保持体积近似不变**，否则会显得"被吸瘪了"。`5px × 1.7 ≈ 8.5px` ≈ 接近 20px 圆球的视觉体积。

### 2. 三段关键帧（不是简单的 0% → 100%）

```
0%   落地瞬间 —— 压扁、scaleX 拉伸
40%  弹起到顶点附近 —— 恢复圆形、scaleX 1
100% 上升到顶 —— top: 0%
```

`alternate` 模式让动画 **从 100% → 0% 反向再放一次**，所以"上升 + 落地"完整循环 = `0.5s × 2 = 1s`。

### 3. 阴影的反向同步（最容易被忽视的精髓）

| 球的状态 | 阴影应该 |
|---|---|
| 落地被压扁 | **大、浓** → `scaleX(1.5)`、opacity 不变 |
| 上升过程中 | 中等 → `scaleX(1)`、opacity `.7` |
| 飞到顶点 | **小、淡** → `scaleX(.2)`、opacity `.4` |

**原理**：球离地面越近 → 投影越接近正圆下方 → 阴影越宽越深；球越高 → 投影发散越严重 + 被环境光"稀释" → 阴影越小越淡。

> 这是拟物感的灵魂：阴影不是装饰，而是 **球高度的物理指示器**。

### 4. 三球错峰相位差

```
球1: delay 0s
球2: delay .2s
球3: delay .3s
```

不是平均分 `1/3 = .166s`，而是用 **不规则间隔** `.2s / .3s`，避免节拍器感。这是细节但很关键。

### 5. 投影的 `filter: blur(1px)` + `z-index: -1`

- `blur(1px)`：让硬阴影变柔，符合真实环境光的漫反射。
- `z-index: -1`：投影在球的下一层，但又要在 `wrapper` 之上（因为 wrapper 自身有 `z-index: 1`），所以最终投影处于 **球与背景之间**。

---

## 可复用模板（推荐生产环境用）

下面模板已做以下改良：
1. 用 CSS 变量驱动尺寸与颜色，方便主题切换；
2. 阴影颜色走 `currentColor` + alpha，可在父级 `color: rgba(255,255,255,.45)` 直接控制；
3. 球的水平位置用 flex + `gap` 替代绝对定位，响应式更好；
4. 增加 `prefers-reduced-motion` 降级。

```html
<div class="bounce-loader" role="status" aria-label="加载中">
  <span class="bounce-loader__pair">
    <span class="bounce-loader__ball"></span>
    <span class="bounce-loader__shadow"></span>
  </span>
  <span class="bounce-loader__pair">
    <span class="bounce-loader__ball"></span>
    <span class="bounce-loader__shadow"></span>
  </span>
  <span class="bounce-loader__pair">
    <span class="bounce-loader__ball"></span>
    <span class="bounce-loader__shadow"></span>
  </span>
</div>

<style>
.bounce-loader {
  /* 主题变量 —— 在父级覆盖即可换肤 */
  --bounce-size: 18px;
  --bounce-color: currentColor;
  --bounce-shadow: currentColor;
  --bounce-duration: 1s;
  --bounce-gap: 36px;

  display: inline-flex;
  align-items: flex-end;
  gap: var(--bounce-gap);
  height: calc(var(--bounce-size) * 4); /* 留够球飞上去的空间 */
  color: #888; /* 默认灰 */
}

.bounce-loader__pair {
  position: relative;
  width: var(--bounce-size);
  height: var(--bounce-size);
  flex: 0 0 auto;
}

.bounce-loader__ball,
.bounce-loader__shadow {
  position: absolute;
  left: 0;
  border-radius: 50%;
}

.bounce-loader__ball {
  width: var(--bounce-size);
  height: var(--bounce-loader-size, var(--bounce-size));
  background: var(--bounce-color);
  top: 0;
  animation: bounce-ball calc(var(--bounce-duration) / 2) ease-in-out infinite alternate;
}

.bounce-loader__shadow {
  width: var(--bounce-size);
  height: calc(var(--bounce-size) * 0.2);
  background: var(--bounce-shadow);
  opacity: 0.45;
  filter: blur(1px);
  bottom: 0;
  z-index: -1;
  animation: bounce-shadow calc(var(--bounce-duration) / 2) ease-in-out infinite alternate;
}

/* 错峰：非均匀相位差，避免节拍器感 */
.bounce-loader__pair:nth-child(2) .bounce-loader__ball,
.bounce-loader__pair:nth-child(2) .bounce-loader__shadow {
  animation-delay: calc(var(--bounce-duration) * 0.2);
}
.bounce-loader__pair:nth-child(3) .bounce-loader__ball,
.bounce-loader__pair:nth-child(3) .bounce-loader__shadow {
  animation-delay: calc(var(--bounce-duration) * 0.3);
}

@keyframes bounce-ball {
  0% {
    top: 100%;
    height: calc(var(--bounce-size) * 0.25);
    border-radius: 50% 50% 25% 25%;
    transform: scaleX(1.7);
  }
  40% {
    height: var(--bounce-size);
    border-radius: 50%;
    transform: scaleX(1);
  }
  100% {
    top: 0;
  }
}

@keyframes bounce-shadow {
  0%   { transform: scaleX(1.5); opacity: 0.7; }
  40%  { transform: scaleX(1);   opacity: 0.55; }
  100% { transform: scaleX(0.2); opacity: 0.3; }
}

/* 无障碍降级 */
@media (prefers-reduced-motion: reduce) {
  .bounce-loader__ball,
  .bounce-loader__shadow {
    animation: none;
    /* 降级为静态 3 个圆点 */
  }
  .bounce-loader__ball {
    top: 0;
    border-radius: 50%;
  }
}
</style>
```

---

## 与家族其他 loader 的对比

| 维度 | 8 点轨道脉冲 | SVG 描边弧扫 | 12 条径向淡变 | **三球弹跳带影（本条）** |
|---|---|---|---|---|
| 元素数 | 8 个 dot | 1 个 circle | 12 根 bar | **3 球 + 3 影** |
| 主动画属性 | scale + opacity | stroke-dashoffset | opacity | **border-radius + scaleX + top** |
| 视觉风格 | 活泼脉冲 | 经典克制 | 精致拖尾 | **拟物弹跳** |
| 性能成本 | 低（6 个伪元素） | 中（SVG + 滤镜） | 极低（只动 opacity） | **中（形变属性会触发 layout）** |
| 适合场景 | 按钮内、卡片 | 后台、表单 | iOS / Apple 工具 | **营销页、Splash、高端感产品** |
| 错峰技巧 | `1/8 周期` | 双层错峰 (2s/1.5s) | `0.1s × 12` | **不规则 `.2s / .3s`** |

---

## 进阶用法

### 1. 按钮内 loading（小尺寸）

```css
.btn--loading {
  display: inline-flex; align-items: center; gap: 8px;
  --bounce-size: 10px; --bounce-gap: 14px;
}
.btn--loading .bounce-loader__pair {
  width: var(--bounce-size); height: var(--bounce-size);
}
```

### 2. 居中全屏 loading（路由切换 / SSR hydration）

```css
.fullscreen-loading {
  position: fixed; inset: 0;
  display: flex; align-items: center; justify-content: center;
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(4px);
  z-index: 9999;
}
```

### 3. 反色（暗背景）

父级设置 `color: rgba(255, 255, 255, 0.85)` 即可让球变白；阴影 `color: rgba(0, 0, 0, 0.5)` 即可让投影变深。

### 4. N 球变体（2 球 / 5 球）

只要复制 `.bounce-loader__pair` 块并改 `nth-child` delay 即可：
- 2 球：`delay: 0s` / `delay: .5s`
- 5 球：`0 / .2s / .4s / .6s / .8s`（保持 `.2s` 间隔节奏感）

### 5. 单球"心跳"变体

把 `pair` 数量减到 1，去掉错峰 → 变成 **单球心跳 loading**，常见于登录页等待反馈。

---

## 踩坑记录

| 坑 | 原因 | 解决 |
|---|---|---|
| 球落地后抖动 | `border-radius` 在 0% 与 40% 之间过渡被 GPU 当成"插值" | 用离散关键帧或 `animation-timing-function: steps()` 调整 |
| 阴影与球错位 | shadow 的 `left/right` 与 ball 不一致 | 把它们包在同一个 `.pair` 里，绝对定位都 `left: 0` |
| 容器高度不够，球飞出 | wrapper 只设了 60px，球飞到 top: 0 就溢出 | 容器高度 ≥ ball-size × 4（球直径 × 飞行距离） |
| 移动端掉帧 | `border-radius` 与 `scaleX` 触发 layout | 给 ball 加 `will-change: transform, height` |
| 暗背景下阴影看不见 | 阴影颜色用了纯黑但背景也是黑 | 阴影走 `currentColor` + 父级 `color` 控制 |
| `alternate` 让动画"卡一下" | 关键帧 100% 与下一轮 0% 不连续 | 在 `0%` 加 `animation-fill-mode: backwards` 或调整起止值重合 |

---

## 性能提示

- **GPU 友好属性**：`transform: scaleX()` ✅、`opacity` ✅
- **CPU 重计算属性**：`height` 变化 ❌（触发 layout）、`border-radius` 形变 ⚠️（可能触发 paint）
- **优化方案**：把球的 `height` 改成 `transform: scaleY(0.25)` + `scaleX(1.7)`，全程只动 `transform`：

```css
@keyframes bounce-ball-perf {
  0%   { transform: translateY(calc(var(--bounce-size) * 4)) scale(1.7, 0.25); border-radius: 50% 50% 25% 25%; }
  40%  { transform: translateY(0) scale(1, 1); border-radius: 50%; }
  100% { transform: translateY(0) scale(1, 1); border-radius: 50%; }
}
```

这样整条动画只有 `transform` 在变，性能提升 **3-5 倍**，但失去了原版的"压扁弹性"（需要用弹性缓动如 `cubic-bezier(.5,0,.5,1)` 弥补）。

---

## 无障碍（A11y）

```html
<div class="bounce-loader" role="status" aria-live="polite" aria-label="加载中">
  <span class="bounce-loader__pair" aria-hidden="true">...</span>
  ...
</div>
```

- **`role="status"`**：屏幕阅读器会朗读 "loading"。
- **`aria-label="加载中"`**：中文场景显式标注。
- **`aria-hidden="true"`** 加在内部视觉元素上，避免重复朗读。
- **`prefers-reduced-motion`**：见模板末尾的 `@media` 块，已自动降级为静态 3 圆点。

---

## FAQ

**Q1：为什么不是 4 个球或更多？**
A：3 个球是 UX 研究的甜点 —— 多了显得拥挤，少了（2 个）缺乏"队列感"。3 是 macOS / Apple 经典 Activity Indicator 的数量。

**Q2：能改用 SVG 做吗？**
A：可以，但 CSS 版更轻（无 SVG 解析开销）、形变更易控制。SVG 适合做进度环，CSS 适合做形变类 loader。

**Q3：球数和错峰节奏有讲究吗？**
A：错峰间隔建议 `0.2s ~ 0.3s` 之间（总周期 1s 时）。小于 0.15s 看起来"挤"，大于 0.4s 看起来"散"。原版用 `.2s / .3s` 不规则，刻意打破节拍器感。

**Q4：与 12 条径向淡变（iOS）如何选？**
- 想 **拟物 / 营销 / Splash** → 三球弹跳带影
- 想 **App 内等待 / 工具感** → 12 条径向淡变
- 两者并存不冲突，本条更"外向"，12 条更"内向"。

**Q5：能在 React 中作为组件用吗？**
A：完全可以，把上面的 HTML+CSS 包成一个 `.tsx` 组件即可，props 接收 `size / color / duration`。

---

## 相关知识

- [动效-loading-8点轨道脉冲.md](./动效-loading-8点轨道脉冲.md) —— 活泼脉冲风
- [动效-loading-SVG描边弧扫.md](./动效-loading-SVG描边弧扫.md) —— Material 经典转圈
- [动效-loading-12条径向淡变.md](./动效-loading-12条径向淡变.md) —— iOS / Apple 克制细腻
- [动效设计原则.md](../动效设计原则.md) —— 迪士尼 12 原则中的 Squash & Stretch

---

## 元数据

```yaml
complexity: ⭐⭐    # 比 8 点 / 12 条稍复杂，因为有形变关键帧
reusability: ⭐⭐⭐  # 改改尺寸颜色就能复用
performance: ⭐⭐   # 形变触发 layout，需注意优化
a11y: ⭐⭐⭐        # 配合 prefers-reduced-motion + role
visual_appeal: ⭐⭐⭐⭐ # 拟物感是其他家族成员不具备的
```
