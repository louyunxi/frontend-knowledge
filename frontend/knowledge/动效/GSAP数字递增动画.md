---
title: "GSAP 数字循环递增动画（setInterval 周期触发动画）"
description: "基于 GSAP gsap.to 的数字递增动画，使用 power2.out 缓动，setInterval 周期（6s）触发动画重跑，3 个独立数字同时动画，搭配 DIN 字体和大字号显示"
tags: ["gsap", "gsap.to", "数字递增", "tween", "onUpdate", "power2.out", "setInterval", "DIN字体", "showcase-dashboard"]
complexity: ⭐⭐
domain: animation
source_scope: "showcase-dashboard - ThreeAssetsSupervision"
---

# GSAP 数字循环递增动画（setInterval 周期触发动画）

## 概述

**GSAP 数字循环递增动画**是 ThreeAssetsSupervision 项目里"三资总览"模块的核心视觉：3 个核心数字（资金总额/资产总额/资源总面积）从 0 滚动到目标值，配 6 秒周期自动重跑，营造"实时数据不断刷新"的氛围。底层使用 **GSAP 的 `gsap.to` 配合 `onUpdate` 回调**。

**适用场景**：
- 大屏里需要"数据持续动态变化"的统计数字
- 任何"目标值会变，需要平滑过渡"的数字显示
- 多个数字需要同步动画的展示

**关键特征**（与同类区分）：
- ✅ **使用 GSAP**（非纯 JS requestAnimationFrame）
- ✅ **`gsap.to(obj, {...})` + `onUpdate` 回调模式**：让 GSAP 驱动数字变化
- ✅ **`power2.out` 缓动**：数字开始快、接近目标值慢，最自然的减速感
- ✅ **`setInterval` 周期重跑**：6 秒一次，**回 0 后再次递增到目标值**
- ✅ **3 个数字同步动画**：同时开始、同时结束
- ✅ **DIN 字体 + 大字号**：26px、`#65e4fd` 亮色，符合大屏科技感
- ❌ 不是 `requestAnimationFrame` 自实现
- ❌ 不是简单的 `count-to` 库

---

## 核心配置

### 1. 依赖引入

```ts
import gsap from 'gsap';
```

> 该项目用的是 **GSAP v3**（免费版，**不需要 Club GreenSock 付费插件**）。

### 2. 完整脚本（核心逻辑）

```ts
<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue';
import gsap from 'gsap';

const props = defineProps({
  fundTotal:    { type: Number, default: 0 },  // 资金总额（亿元）
  assetTotal:   { type: Number, default: 0 },  // 资产总额（亿元）
  areaTotal:    { type: Number, default: 0 },  // 资源总面积（万亩）
});

// 三个显示用的 ref（GSAP 会持续更新它们）
const displayFundTotal = ref(0);
const displayAssetTotal = ref(0);
const displayAreaTotal = ref(0);

// 核心：GSAP 数字递增函数
function animateNumber(targetRef, targetValue) {
  targetRef.value = 0;                    // 关键：每次从 0 开始
  const obj = { value: 0 };                // GSAP 需要可变对象（不能直接 tween ref）
  gsap.to(obj, {
    value: targetValue,                    // 目标值
    duration: 1.5,                         // 动画时长（秒）
    ease: 'power2.out',                    // 缓动函数（开始快、结束慢）
    onUpdate: () => {
      targetRef.value = obj.value;         // 每帧把 GSAP 内部值同步到 ref
    },
  });
}

// 批量启动 3 个数字动画
function runAnimation() {
  animateNumber(displayFundTotal, props.fundTotal);
  animateNumber(displayAssetTotal, props.assetTotal);
  animateNumber(displayAreaTotal, props.areaTotal);
}

let animationInterval = null;

onMounted(() => {
  runAnimation();                                    // 首次执行
  animationInterval = setInterval(runAnimation, 6000); // 6 秒周期重跑
});

onUnmounted(() => {
  if (animationInterval) clearInterval(animationInterval);
});

// 数据源变化时立即触发该数字动画（不等周期）
watch(() => props.fundTotal, (newVal) => animateNumber(displayFundTotal, newVal));
watch(() => props.assetTotal, (newVal) => animateNumber(displayAssetTotal, newVal));
watch(() => props.areaTotal, (newVal) => animateNumber(displayAreaTotal, newVal));
</script>
```

### 3. 模板（数字展示）

```vue
<template>
  <div class="stat-card">
    <div class="stat-content">
      <div class="stat-label">资金总额</div>
      <div class="stat-value">
        <span class="value-number">{{ formatNumber(displayFundTotal) }}</span>
        <span class="value-unit pl-[5px]">亿元</span>
      </div>
      <div class="stat-trend up">
        <span class="trend-icon">↑</span>
        <span>{{ fundTotalGrowth }}%</span>
        同比
      </div>
    </div>
  </div>
</template>
```

### 4. 数字格式化（保留 2 位小数 + 千分位）

```js
function formatNumber(value) {
  return Number(value).toLocaleString('zh-CN', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
}
// 286.52 → "286.52"
// 8932.1 → "8,932.10"
// 14580.23 → "14,580.23"
```

### 5. 样式（DIN + 大字号 + 青色）

```scss
.stat-value {
  display: flex;
  align-items: baseline;
  gap: 3px;

  .value-number {
    font-size: 26px;                            // 大字号（关键）
    font-weight: 700;
    color: #65e4fd;                            // 亮青色（关键）
    font-family: 'DIN', 'Roboto', sans-serif;  // DIN 等宽数字字体（关键）
    line-height: 1.4;
    letter-spacing: -0.5px;
  }
}

.value-unit {
  font-size: 11px;
  color: #64748b;                               // 单位灰色（弱化）
  font-weight: 500;
}

.stat-trend {
  display: flex;
  align-items: center;
  gap: 2px;
  font-size: 12px;
  font-weight: 500;

  &.up   { color: #10b981; }   // 绿色：↑
  &.down { color: #ef4444; }   // 红色：↓
}
```

---

## 关键参数说明

| 参数 | 类型 | 默认 | 说明 |
|------|------|------|------|
| `targetValue` | Number | - | 动画终点（ref 持续更新到的值） |
| `duration` | Number | `1.5` | 动画时长（秒），1~2s 视觉最舒服 |
| `ease` | String | `'power2.out'` | 缓动函数（开始快、结束慢，最自然） |
| `6000ms` | Number | - | `setInterval` 周期（6s），重跑动画形成"实时数据"感 |

### 为什么必须用可变对象 + onUpdate？

```ts
const obj = { value: 0 };                       // ① 必须用可变对象
gsap.to(obj, {                                  // ② GSAP tween 这个对象
  value: targetValue,
  onUpdate: () => {
    targetRef.value = obj.value;                // ③ 每帧把变化同步到 Vue ref
  },
});
```

> **为什么不能直接 `gsap.to(targetRef, ...)`？** Vue 的 `ref` 是只读的代理对象（Proxy），GSAP 无法直接修改它的 `.value`。通过中转变量 `obj` 把值"复制"过去。

### power2.out 缓动效果对比

| 缓动 | 视觉 | 适用 |
|------|------|------|
| `'none'` | 线性匀速 | ❌ 太机械、不像"数字滚动" |
| `'power1.out'` | 轻微减速 | ✅ 通用 |
| `'power2.out'` | 中等减速 | ✅ **本项目使用，最自然** |
| `'power3.out'` | 强烈减速 | 适合"减速到精确值" |
| `'back.out'` | 带回弹 | ❌ 数字不适合（会冲过目标值） |
| `'elastic.out'` | 弹性 | ❌ 数字太花哨 |

### setInterval 周期重跑模式

```ts
runAnimation();                                     // 首次
animationInterval = setInterval(runAnimation, 6000); // 周期
```

> **为什么周期重跑？** 因为每次都从 0 开始（`targetRef.value = 0`），6 秒后又从 0 跑到新目标值，营造"数据持续刷新"的视觉。如果是单次动画，停下来后显得静态。

---

## 引用源文件

| 业务模块 | 源文件 |
|---------|--------|
| 资产监管 - 三资总览 | [AssetOverview.vue](file:///D:/external-projects/showcase-dashboard/src/views/ThreeAssetsSupervision/components/left/AssetOverview.vue) |

---

## 注意事项

> ⚠️ **DIN 字体可能未安装**：项目使用 `font-family: 'DIN', 'Roboto', sans-serif`，如果电脑没装 DIN 会 fallback 到 Roboto，影响视觉一致性。

1. **GSAP 必须用可变对象**：直接 `gsap.to(ref, ...)` 会失效，必须用 `{ value: 0 }` 中转。
2. **每次从 0 开始**：`targetRef.value = 0` 必须放在 `gsap.to` 之前，否则会从当前值开始递增。
3. **onUpdate 同步 ref**：GSAP tween 的是 `obj`，不是 `targetRef`，必须 onUpdate 主动同步。
4. **避免内存泄漏**：`onUnmounted` 必须 `clearInterval`，否则组件销毁后动画继续。
5. **周期不宜过短**：6s 是经验值，太短（如 1s）会让用户觉得"数字一直在跳"；太长（如 30s）显得不"实时"。
6. **watch 触发的优先级**：prop 变化时立即触发该数字动画（不等周期），提升数据更新的即时感。
7. **DIN 字体替代方案**：用 `font-feature-settings: 'tnum'`（tabular-nums）开启等宽数字，配合系统字体也能达到 DIN 效果。

---

## 变体提示

- **如果不要周期重跑（只想动画一次）**：去掉 `setInterval`，保留 `onMounted` 的 `runAnimation()`。
- **如果想要反向（从目标值减到 0）**：用 `gsap.from(obj, { value: 0, ...})` 而不是 `gsap.to`。
- **如果数字要带千分位**：用 `value.toLocaleString('zh-CN')`，但要先 `Math.round` 否则显示 `1,245.60` 等。
- **如果是整数（如人口数）**：把 `minimumFractionDigits: 0, maximumFractionDigits: 0`。
- **如果想要"快速闪一下到目标值"**：`duration: 0.3, ease: 'power3.out'`，适合"数据切换"的场景。
- **如果想要数字滚动带"翻牌"效果**：用 `gsap.fromTo(obj, { value: 0 }, { value: target, snap: { value: 1 } })`，snap 让数字始终是整数。
- **如果想避免 GSAP 依赖（包体积）**：用 `requestAnimationFrame` 自实现：
  ```js
  function animateNumber(targetRef, targetValue, duration = 1500) {
    const start = performance.now();
    const tick = (now) => {
      const t = Math.min((now - start) / duration, 1);
      const eased = 1 - Math.pow(1 - t, 3);  // easeOutCubic
      targetRef.value = targetValue * eased;
      if (t < 1) requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  }
  ```
- **如果需要滚动到指定值（不是从 0）**：用 `gsap.fromTo(obj, { value: targetRef.value }, { value: target, ...})`。