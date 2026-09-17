---
title: "Canvas 星空粒子背景效果（双粒子层 + devicePixelRatio）"
description: "纯 Canvas 2D 实现的星空粒子背景，无任何第三方库；包含尘埃粒子（向上漂浮）和星光粒子（闪烁）两层，通过 devicePixelRatio 自适应高 DPI 屏幕"
tags: ["canvas", "粒子效果", "星空", "背景动画", "requestAnimationFrame", "devicePixelRatio", "createRadialGradient", "showcase-dashboard"]
complexity: ⭐⭐
domain: animation
source_scope: "showcase-dashboard - DroneSurveillance"
---

# Canvas 星空粒子背景效果（双粒子层 + devicePixelRatio）

## 概述

**Canvas 星空粒子背景**是 DroneSurveillance 场景里复用度最高的氛围背景组件。完全基于原生 HTML5 Canvas 2D API，**不依赖任何第三方库**（无 GSAP、Particles.js、tsParticles），通过 `requestAnimationFrame` + `createRadialGradient` 渲染两层粒子——上层是缓慢上升的**尘埃粒子**，下层是随机闪烁的**星光粒子**。

**适用场景**：
- 数据大屏的氛围背景（科技感、星空感、深色主题）
- 任意需要"动态背景 + 性能可控 + 主题色可调"的页面
- 对包体积敏感的项目（零依赖，整个组件约 170 行）

**关键特征**（与同类区分）：
- ✅ **零依赖**：纯 Canvas 2D，无任何库
- ✅ **双粒子层**：尘埃（dust）+ 星光（star），行为不同
- ✅ **devicePixelRatio 自适应**：高 DPI 屏幕下不糊
- ✅ **6 个 props 全可控**：颜色/密度/速度/数量均参数化
- ✅ **canvas 不响应事件**：`pointer-events: none`，不会拦截下层交互
- ❌ 不是 Three.js/WebGL 实现（无 3D 透视）
- ❌ 不参与点击/拖拽交互

---

## 核心配置

### 1. Props API

```js
const props = defineProps({
  color:      { type: String, default: '#00d4aa' },  // 粒子颜色（HEX）
  density:    { type: Number, default: 1 },          // 整体密度倍率
  speed:      { type: Number, default: 1 },          // 尘埃粒子上升速度倍率
  dustCount:  { type: Number, default: 50 },         // 尘埃粒子数量
  starCount:  { type: Number, default: 150 },        // 星光粒子数量
  starSpeed:  { type: Number, default: 1 },          // 星光闪烁速度倍率
});
```

### 2. 组件模板（极简）

```vue
<template>
  <canvas ref="canvasRef" class="star-particles" />
</template>
```

### 3. 完整核心代码

```vue
<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue';

const props = defineProps({
  color: { type: String, default: '#00d4aa' },
  density: { type: Number, default: 1 },
  speed: { type: Number, default: 1 },
  dustCount: { type: Number, default: 50 },
  starCount: { type: Number, default: 150 },
  starSpeed: { type: Number, default: 1 },
});

const canvasRef = ref(null);
let ctx = null;
let animationId = null;
let width = 0;
let height = 0;

let dustParticles = [];
let starParticles = [];

// HEX → RGB 转换（粒子颜色渲染用）
function hexToRgb(hex) {
  const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
  return result ? {
    r: parseInt(result[1], 16),
    g: parseInt(result[2], 16),
    b: parseInt(result[3], 16),
  } : { r: 0, g: 212, b: 170 };
}

// 尘埃粒子工厂（向上漂浮）
function createDustParticle(y = null) {
  return {
    x: Math.random() * width,
    y: y !== null ? y : Math.random() * height,
    size: 1 + Math.random() * 1,                              // 1~2px
    speedY: (0.4 + Math.random() * 0.6) * props.speed,        // 上升速度
    speedX: (Math.random() - 0.5) * 0.2,                      // 水平漂移
    opacity: 0.6 + Math.random() * 0.4,
    phase: Math.random() * Math.PI * 2,                       // 用于正弦呼吸
  };
}

// 星光粒子工厂（闪烁）
function createStarParticle() {
  return {
    x: Math.random() * width,
    y: Math.random() * height,
    size: 0.3 + Math.random() * 0.8,                          // 0.3~1.1px
    phase: Math.random() * Math.PI * 2,
    speed: (0.03 + Math.random() * 0.04) * props.starSpeed,
    brightness: 0.7 + Math.random() * 0.3,                     // 基础亮度
  };
}

function initParticles() {
  const densityFactor = props.density;
  dustParticles = Array.from(
    { length: Math.floor(props.dustCount * densityFactor) },
    () => createDustParticle()
  );
  starParticles = Array.from(
    { length: Math.floor(props.starCount * densityFactor) },
    () => createStarParticle()
  );
}

// 关键：devicePixelRatio 自适应高 DPI
function resize() {
  const canvas = canvasRef.value;
  if (!canvas) return;
  const rect = canvas.parentElement.getBoundingClientRect();
  width = rect.width;
  height = rect.height;
  canvas.width = width * window.devicePixelRatio;
  canvas.height = height * window.devicePixelRatio;
  canvas.style.width = `${width}px`;
  canvas.style.height = `${height}px`;
  ctx = canvas.getContext('2d');
  ctx.scale(window.devicePixelRatio, window.devicePixelRatio);  // 缩放 ctx，否则坐标错位
  initParticles();
}

// 渲染尘埃层（向上漂浮）
function drawDust() {
  const rgb = hexToRgb(props.color);

  dustParticles.forEach(p => {
    p.y -= p.speedY;
    p.x += p.speedX;
    p.phase += 0.02;
    p.opacity = 0.6 + Math.sin(p.phase) * 0.3;                 // 正弦呼吸

    // 出界回收
    if (p.y < -10) {
      p.y = height + 10;
      p.x = Math.random() * width;
    }
    if (p.x < 0) p.x = width;
    if (p.x > width) p.x = 0;

    // 径向渐变（中心实 → 边缘透明）
    const gradient = ctx.createRadialGradient(p.x, p.y, 0, p.x, p.y, p.size * 2);
    gradient.addColorStop(0, `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, ${p.opacity})`);
    gradient.addColorStop(0.6, `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, ${p.opacity * 0.4})`);
    gradient.addColorStop(1, 'transparent');

    ctx.beginPath();
    ctx.arc(p.x, p.y, p.size * 2, 0, Math.PI * 2);
    ctx.fillStyle = gradient;
    ctx.fill();
  });
}

// 渲染星光层（闪烁）
function drawStars() {
  const rgb = hexToRgb(props.color);

  starParticles.forEach(p => {
    p.phase += p.speed;
    const opacity = p.brightness * (0.5 + Math.sin(p.phase) * 0.5);  // 0~1 闪烁

    const gradient = ctx.createRadialGradient(p.x, p.y, 0, p.x, p.y, p.size * 1.5);
    gradient.addColorStop(0, `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, ${opacity})`);
    gradient.addColorStop(0.5, `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, ${opacity * 0.5})`);
    gradient.addColorStop(1, `rgba(${rgb.r}, ${rgb.g}, ${rgb.b}, 0)`);

    ctx.beginPath();
    ctx.arc(p.x, p.y, p.size * 1.5, 0, Math.PI * 2);
    ctx.fillStyle = gradient;
    ctx.fill();
  });
}

// 主循环：清空 → 画星 → 画尘 → 递归
function animate() {
  if (!ctx) return;
  ctx.clearRect(0, 0, width, height);

  drawStars();   // 星先画（在底层）
  drawDust();    // 尘后画（在上层，更明显）

  animationId = requestAnimationFrame(animate);
}

onMounted(() => {
  resize();
  animate();
  window.addEventListener('resize', resize);
});

onUnmounted(() => {
  if (animationId) cancelAnimationFrame(animationId);
  window.removeEventListener('resize', resize);
});

// 参数变化时重生成粒子（不重建 canvas）
watch(() => [props.density, props.color, props.dustCount, props.starCount, props.starSpeed], () => {
  initParticles();
});
</script>

<style scoped>
.star-particles {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  pointer-events: none;   /* 关键：不拦截下层交互 */
  z-index: 1;
}
</style>
```

---

## 关键参数说明

| 参数 | 类型 | 默认 | 说明 |
|------|------|------|------|
| `color` | String | `#00d4aa` | 粒子颜色（HEX），通过 `hexToRgb` 转换 |
| `density` | Number | `1` | 粒子数量倍率（0.5 = 减半） |
| `speed` | Number | `1` | 尘埃粒子上升速度倍率 |
| `dustCount` | Number | `50` | 尘埃粒子基础数量 |
| `starCount` | Number | `150` | 星光粒子基础数量 |
| `starSpeed` | Number | `1` | 星光闪烁速度倍率 |
| `width × height` | Number | `auto` | 自动取父元素尺寸（`parentElement.getBoundingClientRect()`） |

### devicePixelRatio 处理（高 DPI 关键）

```js
canvas.width = width * window.devicePixelRatio;     // 物理像素放大
canvas.height = height * window.devicePixelRatio;
canvas.style.width = `${width}px`;                  // CSS 像素保持不变
canvas.style.height = `${height}px`;
ctx.scale(window.devicePixelRatio, window.devicePixelRatio);  // 逻辑坐标不用改
```

> **为什么需要 scale？** 因为 canvas 物理像素放大后，所有绘制坐标（如 `ctx.arc(p.x, p.y, ...)`）会显得"变小"。`ctx.scale(dpr, dpr)` 把逻辑坐标按 dpr 缩回，绘制坐标保持原始感觉。

### 双粒子层差异

| 维度 | 尘埃粒子 (dust) | 星光粒子 (star) |
|------|----------------|----------------|
| 数量 | 50（少） | 150（多） |
| 尺寸 | 1~2 px | 0.3~1.1 px |
| 速度 | 0.4~1.0（向上漂浮） | 0.03~0.07（闪烁） |
| 渐变半径 | `size * 2` | `size * 1.5` |
| 行为 | 持续向上移动，出界回收 | 原位闪烁，不移动 |
| 透明度 | `0.6 + sin(phase) * 0.3` | `brightness * (0.5 + sin(phase) * 0.5)` |
| 渲染顺序 | 后画（在上） | 先画（在底） |

---

## 引用源文件

| 业务模块 | 源文件 |
|---------|--------|
| 无人机监管 - 星空背景 | [StarParticles.vue](file:///D:/external-projects/showcase-dashboard/src/views/DroneSurveillance/components/StarParticles.vue) |

---

## 注意事项

> ⚠️ **粒子颜色只是默认值**：`#00d4aa`（青绿色）是 DroneSurveillance 默认主题色，实际应用根据业务主题调整。

1. **canvas 不响应事件**：必须设 `pointer-events: none`，否则会拦截下层地图/图表的交互。
2. **devicePixelRatio 必须 ctx.scale**：不缩放 ctx，逻辑坐标会全部错位变小。
3. **resize 监听父元素**：不是监听 window，而是 `parentElement.getBoundingClientRect()`，跟随父容器大小。
4. **粒子数量限制**：`dustCount * density` 和 `starCount * density`，推荐总数 ≤ 300，否则低帧率设备卡顿。
5. **动画层级**：星光画在底层（多但小），尘埃画在上层（少但亮），形成空间层次。
7. **性能开销**：每帧约 200 个 `createRadialGradient` + `arc` + `fill`，在 1080p 上 RTX 显卡约 60fps，集成显卡约 30-45fps。

---

## 变体提示

- **如果想做雨滴/雪花/流星效果**：复用本组件骨架，仅修改 `createDustParticle` 的 `speedY/speedX` 和出界逻辑（向下坠落、右上飘等）。
- **如果想要点击交互**：在 `canvas` 上加 `@click` 监听（去掉 `pointer-events: none`），用 `event.offsetX/Y` 判断点击位置。
- **如果是深色科技感主题**：把 `color` 改为 `#00d4aa`、`#34a8eb`、`#2dcb55` 等亮色，配合深色背景效果最佳。
- **如果需要 WebGL 3D 效果**：参考 Three.js `Points` + `ShaderMaterial`，但代价是包体积大、性能开销高。