---
title: "Leaflet 区域轮廓厚度+走线+背景+呼吸发光 四层组合特效"
description: "基于 Leaflet 自定义 pane 的 4 层叠加区域轮廓效果，包含厚度偏移（12 层）、走线动画（dashFlow）、背景静态实线、呼吸发光（breathingPulse），通过 document.head 注入 CSS keyframes 实现"
tags: ["leaflet", "地图特效", "区域轮廓", "厚度层", "走线动画", "呼吸发光", "drop-shadow", "turf.js", "pane", "showcase-dashboard"]
complexity: ⭐⭐⭐⭐
domain: feature
source_scope: "showcase-dashboard - ThreeAssetsSupervisionMobile"
---

# Leaflet 区域轮廓厚度+走线+背景+呼吸发光 四层组合特效

## 概述

**Leaflet 区域轮廓四层特效**是 ThreeAssetsSupervisionMobile 项目的标志性地图视觉方案。通过 4 个自定义 pane（zIndex 450/456/455/470）的层叠渲染，把一个区域轮廓变成**有厚度、有走线、有背景、有呼吸发光**的高级视觉。重点解决"普通地图轮廓太平、太静、太死板"的问题。

**适用场景**：
- 政务/资产监管大屏的省/市/区多边形高亮
- 任意需要"会动的、亮起来的、有厚度感"的区域轮廓
- Leaflet 已有区域但想升级视觉

**关键特征**（与同类区分）：
- ✅ **4 层叠加**：厚度偏移（12 层静态）+ 走线层 + 背景实线层 + 呼吸发光层
- ✅ **zIndex 精细分层**：450（厚度）/455（呼吸）/456（背景）/470（走线）
- ✅ **CSS 动画走 SVG path**：通过 `stroke-dasharray` + `stroke-dashoffset` 做走线
- ✅ **drop-shadow 多重叠加**做发光：`drop-shadow(0 0 4px currentColor) drop-shadow(0 0 8px currentColor)`
- ✅ **Turf.js union 合并**：多块多边形合并成单轮廓
- ✅ **样式注入 head**：避免污染组件 scope
- ❌ 不是 GeoJSON 原生动画（用 CSS keyframes 跑）
- ❌ 厚度层是**静态偏移**，不是真 3D 透视

---

## 核心配置

### 1. 完整调用代码（MapView.vue）

```ts
import { createThicknessOutlineLayer } from '@/utils/map/leaflet';

// 创建 4 层特效（一次调用，内部叠加）
const thicknessLayers = await createThicknessOutlineLayer(map, {
  themeColor: '#00d4aa',   // 主色（科技感青绿）
  layerCount: 3,            // 厚度层数（默认 12，演示用 3）
  offsetStep: 0.03,         // 每层偏移量（经纬度，约 3km）
  opacityStart: 0.6,        // 外层透明度（淡）
  opacityEnd: 0.1,          // 内层透明度（浓）
  weightStart: 2.5,         // 外层线宽（细）
  weightEnd: 1,             // 内层线宽（粗）
  animDuration: 2.5,        // 走线时长（秒，可选）
});
```

### 2. 4 层 pane zIndex 分布

```
zIndex 470  runningLinePane    ← 最上层：走线动画层（亮色 + dashFlow + 双重 drop-shadow）
zIndex 456  backgroundPane     ← 上层：背景静态实线层（暗化辅助色，weight:4）
zIndex 455  breathingPane      ← 中层：呼吸发光层（提亮色 + breathingPulse + 三重 drop-shadow）
zIndex 450  thicknessOutlinePane ← 底层：12 层厚度偏移轮廓（向左下递增偏移）
```

> **为什么顺序是 470 > 456 > 455 > 450？** 走线最亮要在最上，背景静态线作为"底色"压住呼吸层，厚度偏移在最下做"地基"。

### 3. createThicknessOutlineLayer（厚度层 - 12 层偏移）

```ts
export async function createThicknessOutlineLayer(
  map: Map,
  options: {
    themeColor?: string;
    layerCount?: number;
    offsetStep?: number;
    opacityStart?: number;
    opacityEnd?: number;
    weightStart?: number;
    weightEnd?: number;
  } = {},
) {
  const {
    themeColor = '#00d4aa',
    layerCount = 12,
    offsetStep = 0.005,
    opacityStart = 0.5,
    opacityEnd = 0.05,
    weightStart = 0.8,
    weightEnd = 2,
  } = options;

  // 1. 用 Turf.js 合并所有多边形为单个 Feature
  const features = areaNextData.features.filter(f => f.geometry);
  let unionedFeature: any = null;
  for (const feat of features) {
    if (!unionedFeature) {
      unionedFeature = feat;
    } else {
      const result = union(featureCollection([unionedFeature, feat]));
      if (result) unionedFeature = result;
    }
  }

  // 2. 创建 pane
  map.createPane('thicknessOutlinePane');
  map.getPane('thicknessOutlinePane').style.zIndex = '450';

  // 3. 循环创建 12 层（关键渐变公式）
  const baseColor = hexToRgb(themeColor);
  const layers: GeoJSON[] = [];

  for (let i = 0; i < layerCount; i++) {
    const ratio = i / (layerCount - 1);
    const offsetX = -(i + 1) * offsetStep;  // 向左
    const offsetY = -(i + 1) * offsetStep;  // 向下

    // 颜色亮度：内层亮(1.0)，外层暗(0.6)
    const brightness = 1 - (1 - ratio) * 0.4;
    const r = Math.round(Math.min(255, baseColor.r * brightness));
    const g = Math.round(Math.min(255, baseColor.g * brightness));
    const b = Math.round(Math.min(255, baseColor.b * brightness));

    // 透明度：外层低（淡），内层高（浓）
    const opacity = opacityStart + (opacityEnd - opacityStart) * ratio;

    // 线宽：外层细，内层粗
    const weight = weightStart + (weightEnd - weightStart) * ratio;

    const gradientColor = `rgb(${r}, ${g}, ${b})`;
    const offsetGeometry = offsetGeoJSON(unionedFeature, offsetX, offsetY);

    if (offsetGeometry) {
      const layer = geoJSON(offsetGeometry, {
        pane: 'thicknessOutlinePane',
        style: () => ({
          weight,
          color: gradientColor,
          fill: false,
          opacity,
          lineCap: 'round',
          lineJoin: 'round',
        }),
      });
      layer.addTo(map);
      layers.push(layer);
    }
  }

  // 4. 最后叠加走线层（内部会再调 2 个辅助函数）
  createRunningLineLayer(map, unionedFeature, themeColor);

  return layers;
}
```

### 4. createRunningLineLayer（走线层 - dashFlow + 双重发光）

```ts
function createRunningLineLayer(map: Map, feature: any, themeColor: string) {
  if (!feature) return;

  // 创建 pane
  map.createPane('runningLinePane');
  map.getPane('runningLinePane').style.zIndex = '470';  // 最上层

  const brightColor = getSimilarBrightnessColor(themeColor, 0);

  // 注入走线动画样式（关键）
  const lineStyleId = 'running-line-style';
  if (!document.getElementById(lineStyleId)) {
    const styleEl = document.createElement('style');
    styleEl.id = lineStyleId;
    styleEl.textContent = `
      @keyframes dashFlow {
        to { stroke-dashoffset: -80; }
      }
      .running-line-path {
        stroke-dasharray: 40 40;
        animation: dashFlow 3s linear infinite;
        filter: drop-shadow(0 0 4px currentColor) drop-shadow(0 0 8px currentColor);
      }
    `;
    document.head.appendChild(styleEl);
  }

  const layer = geoJSON(feature, {
    pane: 'runningLinePane',
    style: () => ({
      weight: 3,
      color: brightColor,
      fill: false,
      opacity: 1,
      lineCap: 'round',
      lineJoin: 'round',
    }),
  });
  layer.addTo(map);

  // 关键：等 DOM 渲染完成后再加 class（否则 Leaflet 内部 path 还没生成）
  setTimeout(() => {
    const pathEls = map.getPane('runningLinePane')?.querySelectorAll('path');
    pathEls?.forEach((path) => {
      path.classList.add('running-line-path');
    });
  }, 100);

  // 内部再调 2 个辅助层
  createBackgroundOutlineLayer(map, feature, themeColor);
  createBreathingOutlineLayer(map, feature, themeColor);

  return layer;
}
```

### 5. createBackgroundOutlineLayer（背景实线层 - 静态）

```ts
function createBackgroundOutlineLayer(map: Map, feature: any, themeColor: string) {
  if (!feature) return;

  map.createPane('backgroundPane');
  map.getPane('backgroundPane').style.zIndex = '456';  // 走线层之下

  // 辅助色（HSL 色相偏移 -25，更暗更冷）
  const assistColor = getSimilarBrightnessColor(themeColor, -25);

  const layer = geoJSON(feature, {
    pane: 'backgroundPane',
    style: () => ({
      weight: 4,            // 比走线层粗（4 vs 3），作为底色
      color: assistColor,    // 暗化辅助色
      fill: false,
      opacity: 1,
      lineCap: 'round',
      lineJoin: 'round',
    }),
  });
  layer.addTo(map);
  return layer;
}
```

### 6. createBreathingOutlineLayer（呼吸发光层 - breathingPulse + 三重发光）

```ts
function createBreathingOutlineLayer(map: Map, feature: any, themeColor: string) {
  if (!feature) return;

  map.createPane('breathingPane');
  map.getPane('breathingPane').style.zIndex = '455';

  // 提亮主题色 +80
  const baseColor = hexToRgb(themeColor);
  const brightColor = `rgb(${Math.min(255, baseColor.r + 80)}, ${Math.min(255, baseColor.g + 80)}, ${Math.min(255, baseColor.b + 80)})`;

  // 注入呼吸动画样式
  const breathStyleId = 'breathing-line-style';
  if (!document.getElementById(breathStyleId)) {
    const styleEl = document.createElement('style');
    styleEl.id = breathStyleId;
    styleEl.textContent = `
      @keyframes breathingPulse {
        0%, 100% {
          opacity: 0.2;
          filter: drop-shadow(0 0 3px ${brightColor}) drop-shadow(0 0 6px ${brightColor});
        }
        50% {
          opacity: 0.8;
          filter: drop-shadow(0 0 6px ${brightColor}) drop-shadow(0 0 9px ${brightColor}) drop-shadow(0 0 18px ${brightColor});
        }
      }
      .breathing-line-path {
        animation: breathingPulse 4s ease-in-out infinite;
      }
    `;
    document.head.appendChild(styleEl);
  }

  const layer = geoJSON(feature, {
    pane: 'breathingPane',
    style: () => ({
      weight: 2,
      color: brightColor,
      fill: false,
      opacity: 0.6,
      lineCap: 'round',
      lineJoin: 'round',
    }),
  });
  layer.addTo(map);

  // 等 DOM 渲染完成后再加 class
  setTimeout(() => {
    const pathEls = map.getPane('breathingPane')?.querySelectorAll('path');
    pathEls?.forEach((path) => {
      path.classList.add('breathing-line-path');
    });
  }, 100);

  return layer;
}
```

---

## 关键参数说明

| 函数 | 参数 | 默认 | 说明 |
|------|------|------|------|
| `createThicknessOutlineLayer` | `themeColor` | `#00d4aa` | 厚度层 + 走线层主色 |
| `createThicknessOutlineLayer` | `layerCount` | `12` | 厚度层数（推荐 8~15） |
| `createThicknessOutlineLayer` | `offsetStep` | `0.005` | 每层偏移量（经纬度，约 0.5km） |
| `createThicknessOutlineLayer` | `opacityStart` | `0.5` | 外层透明度（淡） |
| `createThicknessOutlineLayer` | `opacityEnd` | `0.05` | 内层透明度（浓） |
| `createThicknessOutlineLayer` | `weightStart` | `0.8` | 外层线宽（细） |
| `createThicknessOutlineLayer` | `weightEnd` | `2` | 内层线宽（粗） |
| `dashFlow` keyframe | `stroke-dashoffset` | `-80` | 走线循环位移 |
| `breathingPulse` keyframe | `duration` | `4s` | 呼吸周期 |
| `breathingPulse` keyframe | `easing` | `ease-in-out` | 呼吸缓动（自然呼吸） |

### 4 层 zIndex 设计

| zIndex | pane 名 | 角色 | 视觉权重 |
|--------|---------|------|---------|
| **470** | `runningLinePane` | 走线动画 | ⭐⭐⭐⭐（最亮、最显眼） |
| **456** | `backgroundPane` | 背景静态实线 | ⭐⭐（作为底色衬托） |
| **455** | `breathingPane` | 呼吸发光 | ⭐⭐⭐（动态但不抢眼） |
| **450** | `thicknessOutlinePane` | 12 层厚度偏移 | ⭐（地基，远处看） |

### 关键 CSS 动画对比

| 动画 | 应用层 | 实现原理 | 视觉效果 |
|------|--------|----------|---------|
| `dashFlow` | 走线层 | `stroke-dasharray: 40 40` + `stroke-dashoffset` 动画 | 虚线沿线"流动" |
| `breathingPulse` | 呼吸层 | `opacity` + `filter: drop-shadow()` 三重叠加 | 整体"呼吸"明暗 |

---

## 引用源文件

| 业务模块 | 源文件 |
|---------|--------|
| 资产监管移动端 - 地图轮廓特效 | [MapView.vue](file:///D:/external-projects/showcase-dashboard/src/views/ThreeAssetsSupervisionMobile/components/MapView.vue) |
| Leaflet 工具函数（含 4 层特效实现） | [leaflet.ts](file:///D:/external-projects/showcase-dashboard/src/utils/map/leaflet.ts) |

---

## 注意事项

> ⚠️ **style id 唯一性**：必须用 `if (!document.getElementById(lineStyleId))` 守卫，否则多次调用会重复注入 `<style>` 标签。

1. **必须用 Turf.js union 合并**：多个 PolygonFeature 不合并，走线/呼吸会按每块分别动，视觉割裂。
2. **必须 setTimeout 100ms 后再加 class**：Leaflet `layer.addTo(map)` 是同步的，但 `<path>` 元素的实际渲染是异步的，立即 `querySelectorAll('path')` 拿不到。
3. **drop-shadow 比 box-shadow 更适合 SVG**：SVG 的 `stroke` 是路径，`box-shadow` 只能描外接矩形；`drop-shadow` 跟随路径边缘发光。
4. **zIndex 450 < 455 < 456 < 470**：保持此顺序，任何顺序错乱都会导致某层被遮挡。
5. **themeColor 与 pane 颜色一致**：4 层都围绕同一个主色调，但走线层用 `getSimilarBrightnessColor(0)` 微调，呼吸层用 `+80` 提亮，背景层用 `-25` 暗化，形成层次感。
6. **暗化用 HSL 而不是 RGB**：`getSimilarBrightnessColor` 走 HSL 色相偏移而非简单减 RGB，避免色相偏移（如绿色变蓝色）。
7. **性能开销**：12 层 × 4 个 geoJSON layer ≈ 48 个 SVG path + 2 个 CSS 动画（走线 1 + 呼吸 1），主流浏览器 60fps OK。

---

## 变体提示

- **如果不需要走线效果**：注释掉 `createRunningLineLayer(map, unionedFeature, themeColor);` 那一行，厚度层 + 背景层 + 呼吸层就够了。
- **如果想要 3D 厚度（透视）**：用 `offsetStep: 0.05` 加大偏移，并配合 `map.setView()` 微调视角，但 Leaflet 原生不支持真 3D 投影。
- **如果是单块多边形**：可以跳过 Turf.js union，直接传 feature。
- **如果要更换动画颜色**：把 `themeColor` 改为 `#34a8eb`（蓝）、`#2dcb55`（绿）、`#f97316`（橙）等，整体色调会跟随。
- **如果要走更慢的线**：把 `dashFlow` 的 `3s` 改为 `6s` 或更长。
- **如果想呼吸更慢**：把 `breathingPulse` 的 `4s` 改为 `6s` 或更长，更沉稳。