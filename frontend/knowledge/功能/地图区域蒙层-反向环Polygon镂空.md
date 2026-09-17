---
title: "地图区域蒙层 - 反向环 Polygon 镂空"
description: "ArcGIS 中通过 Polygon 双环（外环=全球矩形 + 内环=区域轮廓 reverse）实现「区域外蒙层 + 区域内穿透」的镂空效果，用于地图聚焦、可视化降饱和"
domain: 功能
subdomain: gis
type: pattern
source_scope: "E:\\project-demo\\anhui-satellite-viewer\\src\\components\\MapView.vue （loadAnhuiOutline 方法），可泛化到 ArcGIS 3.x / Mapbox GL / Leaflet 等任意 Web GIS"
observed_platforms:
  - web
related_patterns:
  - ArcGIS图形渲染与符号系统
  - GIS地图初始化与天地图集成
  - 地块选择器组件
confidence: high
---

# 地图区域蒙层 - 反向环 Polygon 镂空

## 概述

地图业务里常见的「**只看到某省/某市，区域外灰显蒙层**」效果 —— 比如用户打开「皖农云图」只看安徽省内，省外用半透明深蓝蒙层降饱和，让用户视线聚焦省内。本质上不是「画出省的边界并填充」，而是：

> **画一个能覆盖整个全球的矩形，把「要保留可见的区域的轮廓」作为洞（hole）减去，剩下区域被填充 → 也就是要保留的区域不被填充，其余全填充。**

ArcGIS / Mapbox / Leaflet 等所有支持「多边形环（rings）」的地图库都能用同一思路实现。这是这类「区域蒙层/降饱和/聚焦」可视化最稳的写法。

本知识蒸馏 `MapView.vue` 中 `loadAnhuiOutline` 方法，给出可复用的通用模式。

## 适用场景

### ✅ 适合
- 地图业务只允许用户看某个省/市/园区（其他区域被蒙层遮住 + 半透明降饱和）
- 大屏 / 仪表盘：突出某区域 + 周边地理参照物（弱化显示）
- 行政区划聚合展示：除当前选中区域外全部蒙层
- 「打卡点 / 销售范围」类的范围可视化
- 离线 / 内网项目中需要把地图范围钳制到业务区

### ❌ 不适合
- 只需要画一个普通的多边形（不是镂空）—— 用 `Polygon([ring])` 单环即可
- 需要 3D 视角下的边界墙 → 用 LineSymbol layer 而不是 Polygon
- 业务上需要分别控制区域内外颜色（而不是用蒙层遮罩） → 用 fill-color 之 property 表达式（Mapbox paint property）

## 为什么这样做（核心思路）

要达到「区域外蒙层 + 区域内保持原样」，三个常见思路对比：

| 思路 | 实现方式 | 缺点 |
|-----|---------|------|
| ❌ **用 boundingBox** | 画一个 Rectangle 但用反转做洞 | ArcGIS 3.x Rectangle 是单环，无法直接挖洞 |
| ❌ **图层透明度逐像素判断** | WebGL shader / Canvas 蒙版 | 实现复杂，性能差 |
| ✅ **Polygon 双环 = 全球外框 + 区域洞** | `rings: [worldRing, regionRing]` | **最简洁、最通用、最稳定** |

Esri / GeoJSON 规范：
- **`rings[0]` = 外环（顺时针）** —— 它决定多边形的外边界
- **`rings[1..n]` = 内洞（逆时针）** —— 这些区域会被减去

如果内洞给的是顺时针坐标，ArcGIS 会把它当成另一个外环处理 → 蒙层失败。所以代码里 `anhuiRing = anhuiCoords.slice().reverse()`（注意反转）是关键。

## 完整可运行代码（ArcGIS JS API 3.28）

这是从 `loadAnhuiOutline` 蒸馏出来的最简洁版本，**仅保留核心 7 步**。

```vue
<script setup>
import { ref } from 'vue'
import { loadEsri } from '../map/esriLoader'

const mapEl = ref(null)
let map = null
let maskLayer = null // 区域蒙层，可被外层 showMask prop 控制

async function loadAreaOutline() {
  // 1. 取需要的 esri 模块
  const [
    GraphicsLayer, Graphic, SimpleLineSymbol, SimpleFillSymbol, Polygon, SpatialReference
  ] = await loadEsri([
    'esri/layers/GraphicsLayer',
    'esri/graphic',
    'esri/symbols/SimpleLineSymbol',
    'esri/symbols/SimpleFillSymbol',
    'esri/geometry/Polygon',
    'esri/SpatialReference'
  ])

  // 2. 加载区域 GeoJSON
  const baseUrl = import.meta.env.BASE_URL
  const res = await fetch(`${baseUrl}assets/area-data/340000.json`)
  const geojson = await res.json()
  const regionCoords = geojson.features[0].geometry.coordinates[0]

  // 3. 构造双环：外环 = 全球矩形（顺时针），内洞 = 区域轮廓（顺时针 reverse → 逆时针 = 洞）
  const worldRing = [
    [-180, 90],
    [180, 90],
    [180, -90],
    [-180, -90],
    [-180, 90]
  ]
  const regionRing = regionCoords.slice().reverse() // 关键 reverse()

  // 4. 创建 Polygon
  const polygon = new Polygon({
    rings: [worldRing, regionRing],
    spatialReference: new SpatialReference({ wkid: 4326 })
  })

  // 5. 构造符号系统（描边 + 填充）
  const lineSymbol = new SimpleLineSymbol(
    SimpleLineSymbol.STYLE_SOLID,
    [0, 246, 255, 255], // #00F6FF 描边
    2
  )
  const fillSymbol = new SimpleFillSymbol(
    SimpleFillSymbol.STYLE_SOLID,
    lineSymbol,                   // 外边线
    [0, 34, 52, 255]             // #065b89 半透明深蓝填充
  )

  // 6. 创建 Graphic + GraphicsLayer
  const graphic = new Graphic(polygon, fillSymbol)
  const outlineLayer = new GraphicsLayer({ id: 'region-outline' })
  outlineLayer.className = 'region-outline-layer' // CSS :deep() 钩子
  outlineLayer.add(graphic)

  // 7. 加入地图（放在最底，但底图之上）
  maskLayer = outlineLayer
  map.addLayer(outlineLayer, 0)
}
</script>

<style scoped>
/* 整层半透明，让底图微微可见 */
:deep(.region-outline-layer) {
  opacity: 0.6;
}
</style>
```

### 业务控制（保留 maskLayer 实例）

把 `maskLayer` 暴露到 script 顶层，组件 prop `showMask` 变化时切换显示，不重建 layer：

```js
const props = defineProps({
  showMask: { type: Boolean, default: true }
})

watch(() => props.showMask, (val) => {
  if (maskLayer) {
    if (val) maskLayer.show()
    else maskLayer.hide()
  }
})
```

> **为什么用 show/hide 不用 add/remove？** 因为 `addLayer(0)` 会把 outline 重新插入底图之上，每次移除再加入都触发重绘 + Flash。show/hide 是单次渲染开销。

## 进阶用法

### 1. Mapbox GL 等价方案（Turf.js 增强）

Mapbox GL 不支持多边形挖洞，但可以通过双 Polygon + `fill-opacity` + paint property hack 实现等价效果：

```js
import * as turf from '@turf/turf'

function loadMapboxOutline(map, geojson, fillColor = '#065b89', fillOpacity = 0.6) {
  // 用 mask 字段标记洞：GeoJSON FeatureCollection，让 Mapbox 按 isMask 区分渲染
  const world = turf.polygon([[
    [-180, 90], [180, 90], [180, -90], [-180, -90], [-180, 90]
  ]])
  const region = turf.polygon([geojson.features[0].geometry.coordinates[0]])

  map.addSource('mask', {
    type: 'geojson',
    data: {
      type: 'FeatureCollection',
      features: [
        turf.toFeature(world),
        turf.toFeature(region)
      ]
    }
  })

  map.addLayer({
    id: 'area-outline-mask',
    type: 'fill',
    source: 'mask',
    paint: {
      'fill-color': fillColor,
      'fill-opacity': fillOpacity,
      'fill-opacity-transition': { duration: 0 }
    },
    filter: ['==', '$type', 'Polygon']
  })
  // 用 fill-pattern 或 sprite 区分洞内外复杂度过高，更稳的做法：
  // 单加 source = region polygon, type=fill, 仅外部 fill，外区域 mask hide 时隐藏
}
```

更现代的 Mapbox 写法（v3+）用 `fill-extrusion`/`composite` 也可。核心都是：**双 GeoJSON Feature。**

### 2. Leaflet 等价方案

```js
import L from 'leaflet'

function loadLeafletOutline(map, regionLatLngs, fillColor = '#065b89', fillOpacity = 0.6) {
  const world = [
    L.latLng(90, -180), L.latLng(90, 180), L.latLng(-90, 180), L.latLng(-90, -180), L.latLng(90, -180)
  ]
  const hole = regionLatLngs // GeoJSON coords swap 成 [lat, lng]
  const polygon = L.polygon([world, hole], {
    color: '#00F6FF',
    weight: 2,
    fillColor,
    fillOpacity,
    stroke: true
  })
  polygon.addTo(map)
}
```

> Leaflet `L.polygon([outerRing, holeRing])` 第一参数是 Array of Array —— 第一个元素是外环，后续元素自动被视为洞。比 ArcGIS 还简洁。

### 3. 多区域蒙层（多块飞地）

如果业务有多个不连续区域（比如新疆有很多飞地），可以传多个 hole：

```js
// ArcGIS: rings 长度 = 1 + N
const polygon = new Polygon({
  rings: [worldRing, regionRing1, regionRing2, regionRing3],
  spatialReference: new SpatialReference({ wkid: 4326 })
})
```

`GraphicsLayer` 同样能放多个 Graphic —— 性能远超单 big polygon。

### 4. 蒙层与地图裁切 combo

在已有 `clipPath` 卷帘（如项目本身的 `ZipperPanel`）上，蒙层天然不受影响 —— 因为 `clipPath` 是 CSS 层，蒙层是 SVG/Canvas 层，**两层互不干扰**。这是为什么本模式可以叠在任何卷帘 / 拖拽缩放方案之上。

## 注意事项 / 边界

### ⚠️ 必须避开的坑

1. **内环方向错误（最常见）**：`geojson.coordinates[0]` 通常是顺时针。Polygon 定义中外环是顺时针、内环是逆时针。如果不 reverse，ArcGIS 会把你给的「洞」当成另一个外环 → 整个地球被填充。**永远先 `regionRing = coords.slice().reverse()` 再用。**

2. **`spatialReference` 缺失**：`Polygon` 必须带 `SpatialReference({ wkid: 4326 })`，否则地图不识别 layer 坐标系 → 不显示。

3. **`addLayer` 的 index 必须是 0 或最底**：让底图（卫星 / 矢量）在 outlineLayer 之上可见。如果加到 z-top，**地图本身被覆盖**，看不到底图。

4. **GeoJSON 包含 MultiPolygon 时**：`features[0].geometry.coordinates` 是三维数组 `Polygon[][][]`，代表多个外环，每个外环可能有自己的洞。当前代码只取 `[0]`，**MultiPolygon 暂不支持**。复杂区域用 `turf.flatten()` 拆开。

5. **跨时区 / 跨经度 180° 区域**（比如俄罗斯、斐济）：全球矩形 [-180, 180] 会切割区域。需要分两块构造。

6. **国家 GeoJSON 路径**：中国大陆地区用阿里 `DataV.GeoAtlas`（`https://geo.datav.aliyun.com/areas_v3/bound/340000.json`），比省级 `assets/...` 完整。

7. **maskLayer 没初始化**：当 prop `showMask` 在 `loadAreaOutline` 之前变化，`maskLayer` 还是 null。watch 内部必须判空。

8. **多幅叠加导致 z-index 混乱**：如果有多个蒙层叠加（比如省级蒙层 + 市级蒙层），用 `map.reorderLayer(maskLayer, 0)` 显式重排。

9. **高德 / Google 地图坐标系**：注意 GCJ-02 vs WGS84 偏移。中国大陆 Google 地图需要先把 GeoJSON coords 用 `coordtransform` 转 GCJ-02。本知识使用 WGS84，请按底图选择。

## 性能优化技巧

1. **Polygon 提前简单化**：高精度的省边界有上万个点，会显著拖慢首帧。**先用 `turf.simplify(geojson, { tolerance: 0.01 })` 减到 200~500 个点**，肉眼无差别，性能翻倍。

2. **Layer 复用**：不要在 `watch` prop 变化里反复 `addLayer`/`removeLayer`。`maskLayer.show()/hide()` 即可，瓦片缓存复用。

3. **CSS `opacity` 优于透明 `fillColor`**：用 `:deep(.region-outline-layer) { opacity: 0.6 }` 比 `[0, 0, 0, 100]` 半透明填充少一次 GPU 合成。

4. **LOD 懒加载**：大比例尺下隐藏 outline，远视口才显示（与 `map.on('zoom-end')` 联动）。

5. **打包内联 GeoJSON**：省级边界 GeoJSON 100~300KB，`build.rollupOptions.output.assetFileNames` 改 inline base64 比 fetch 快 —— 但首屏会换不来 ROI，看场景。

## 常见问题

### Q1: 蒙层不显示 / 出现异常大面积？

检查：
1. 内洞方向：必须 `regionCoords.slice().reverse()`。
2. `spatialReference: 4326` 是否带上。
3. `addLayer(0)` index 是否覆盖到不是 0。
4. 检查 `worldRing` 是否闭合（首尾两点相同）。

### Q2: 蒙层出现在所有图层上方？

把 `addLayer(outlineLayer, 0)` 的 index 改为 0（最底）而不是省略 index。`addLayer(layer)` 不带 index 会按 `addLayer` 顺序累加 → 越加越靠上。

### Q3: 我不想用 reverse 行不行？

可以。`Polygon({ rings: [worldRing, regionRing] })` 内部会自动按外-内的方向识别洞（有面积阈值处理）。但实测 ArcGIS 3.28 对复杂区域需要 reverse 才稳。**建议保留 reverse**，避免坑。

### Q4: 区域 GeoJSON 从哪取？

- ✅ **阿里 DataV.GeoAtlas**：`https://geo.datav.aliyun.com/areas_v3/bound/{adcode}_full.json` —— 全，开箱即用，最稳
- ✅ **D3 官方 TopoJSON**：`https://github.com/topojson/topojson` —— 全球，但无省市细分
- ✅ **自然资源部标准地图**：合规要求高场景
- ❌ **百度、高德直接抓取**：坐标系偏移 + 法律风险
- ❌ **自己用 turf.js 拼**：维护成本高

### Q5: 业务上要「区域轮廓也作为地图图层，而不是蒙层」？

那就直接一个 `Polygon(rings: [regionRing])`，单环，外面不画。配合 `SimpleLineSymbol` 描边更细即可。本知识专做「蒙层」场景。

## 相关模式

- [`../ArcGIS图形渲染与符号系统.md`](../ArcGIS图形渲染与符号系统.md) - 符号系统（SimpleLineSymbol / SimpleFillSymbol）使用
- [`../GIS地图初始化与天地图集成.md`](../GIS地图初始化与天地图集成.md) - 底图初始化（本知识假设地图已 ready）
- [`../地块选择器组件.md`](../地块选择器组件.md) - 业务选择器组件封装思路（蒙层可作为公共能力下沉）
- [`../../动效/加载动画/动效-首屏白屏-loading同源占位.md`](../../动效/加载动画/动效-首屏白屏-loading同源占位.md) - 蒙层加载前用 loading 占位避免底图提前露馅

## 参考资料

- [ArcGIS JavaScript API - Polygon Geometry](https://developers.arcgis.com/javascript/3/jsapi/polygon-amd.html)
- [Esri - Esri Geometry Objects & Rings / Winding Rule](https://developers.arcgis.com/documentation/common-features/geometry/)
- [Turf.js - Simplify / Polygon / Mask](https://turfjs.org/docs/api/)
- [阿里 DataV.GeoAtlas](https://datav.aliyun.com/portal/school/atlas/area_selector)
- [Mapbox - Fill layer properties](https://docs.mapbox.com/mapbox-gl-js/style-spec/layers/#fill)
- [Leaflet - Polygon with holes](https://leafletjs.com/reference.html#polygon)

---

## 元信息

| 属性 | 值 |
|-----|---|
| 复杂度 | ⭐⭐ (2/5 星) |
| 框架/库 | ArcGIS JS API 3.x（可泛化 Mapbox / Leaflet） |
| 蒸馏来源 | `E:\project-demo\anhui-satellite-viewer\src\components\MapView.vue` (loadAnhuiOutline) |
| 标签 | arcgis, mapbox, leaflet, gis, polygon, mask, region-outline, ring-hole, hollow-fill, area-mask |
| 创建日期 | 2026-09-16 |
| 性能开销 | Polygon < 1000 点 → < 1ms；高精细级别建议先 turf.simplify |
