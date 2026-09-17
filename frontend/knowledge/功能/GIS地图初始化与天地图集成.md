---
title: "ArcGIS 地图初始化与天地图卫星底图集成"
description: "使用 ArcGIS JS API 集成天地图卫星底图，包括地图初始化、多种图层配置、事件绑定和区域轮廓"
tags: ["arcgis", "天地图", "GIS", "map", "地图", "vue", "tile-layer"]
complexity: ⭐⭐⭐
domain: feature
---

# ArcGIS 地图初始化与天地图卫星底图集成

## 概述

本知识介绍如何使用 ArcGIS JS API 初始化地图，并集成天地图（Tianditu）卫星底图。

适用于需要展示地图、且对底图质量有要求的 Web GIS 应用。

---

## 适用场景

### ✅ 适合

- Web GIS 应用开发
- 需要卫星底图的地图展示
- 多图层叠加（底图 + 标注 + 业务数据）
- 区域轮廓高亮
- 地图交互功能（点击、缩放、拖拽）

### ❌ 不适合

- 轻量级地图需求（考虑 Leaflet）
- 不需要天地图的项目
- 纯 2D 简单展示（考虑静态地图）

---

## 前置条件

### 1. 依赖安装

```bash
# ArcGIS JS API 通过动态导入，不需要 npm 安装
# 需要配置动态导入模块的加载器
```

### 2. 天地图 Token

```javascript
// 需要申请天地图开发者 token
// 申请地址: https://console.tianditu.gov.cn/

const TIANDITU_KEY = '你的天地图Token';
```

### 3. 基础样式

```css
/* 地图容器必须设置明确尺寸 */
.map-container {
  width: 100%;
  height: 100%;
}

.map-container .esriSimpleSliderTL {
  /* 隐藏默认缩放按钮位置调整 */
  top: unset;
  left: unset;
  right: 10px;
  bottom: 10px;
}
```

---

## 核心实现

### 1. 地图组件基础结构

```vue
<template>
  <div class="base-map">
    <div ref="gisMap" class="map-content" />
  </div>
</template>

<script setup>
import { ref, onMounted } from "vue";

const gisMap = ref(null);
const map = ref(null);

const props = defineProps({
  minZoom: {
    type: Number,
    default: 8
  },
  maxZoom: {
    type: Number,
    default: 18
  }
});

onMounted(async () => {
  await initMapFn();
});

async function initMapFn() {
  // 动态导入 ArcGIS 模块
  const [Map] = await importArcgisModules(["esri/map"]);

  // 初始化地图
  map.value = new Map(gisMap.value, {
    extent: gisExtent, // 初始范围
    logo: false,       // 隐藏 ArcGIS logo
    slider: false,     // 隐藏缩放滑块
    optimizePanAnimation: true,
    force3DTransforms: false,
    maxZoom: props.maxZoom,
    minZoom: props.minZoom,
    isScrollWheel: true,
    isPinchZoom: true,
  });

  // 挂载底图
  await mountedBaseLayerFn();

  // 绑定事件
  bindMapEvent();
}
</script>

<style scoped>
.base-map {
  width: 100%;
  height: 100%;
}
.map-content {
  height: 100%;
}
</style>
```

### 2. 天地图卫星底图

```javascript
// generateTDLayers.js

// 天地图影像底图（卫星图）
export async function tDImageLayer() {
  return await createWebTileLayer(
    // 天地图 WMTS URL 模板
    `https://{subDomain}.tianditu.gov.cn/img_c/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=img&STYLE=default&TILEMATRIXSET=c&FORMAT=tiles&TILECOL={col}&TILEROW={row}&TILEMATRIX={level}&tk=${TIANDITU_KEY}`,
    {
      dpi: 90.71428571427429,
      rows: 256,
      cols: 256,
      compressionQuality: 0,
      origin: {
        x: -180,
        y: 90,
      },
      spatialReference: {
        wkid: 4326,  // WGS84 坐标系
      },
      lods: getTDTLods(), // LOD 级别配置
    },
    {
      id: "tDImageLayer",
      subDomains: ["t0", "t1", "t2", "t3", "t4", "t5", "t6", "t7"],
    }
  );
}
```

### 3. 天地图道路标注图层

```javascript
// 天地图道路标注（叠加在卫星图上）
export async function tDImageCiaLayer() {
  return await createWebTileLayer(
    `https://{subDomain}.tianditu.gov.cn/cia_c/wmts?SERVICE=WMTS&REQUEST=GetTile&VERSION=1.0.0&LAYER=cia&STYLE=default&TILEMATRIXSET=c&FORMAT=tiles&TILECOL={col}&TILEROW={row}&TILEMATRIX={level}&tk=${TIANDITU_KEY}`,
    {
      dpi: 90.71428571427429,
      rows: 256,
      cols: 256,
      compressionQuality: 0,
      origin: {
        x: -180,
        y: 90,
      },
      spatialReference: {
        wkid: 4326,
      },
      lods: getTDTLods(),
    },
    {
      id: "tDImageCiaLayer",
      subDomains: ["t0", "t1", "t2", "t3", "t4", "t5", "t6", "t7"],
    }
  );
}
```

### 4. 挂载底图图层

```javascript
const mapLayer = reactive({
  tDImageBaseLayer: null,  // 天地图底图
  addressLayer: null,      // 道路标注
});

async function mountedBaseLayerFn() {
  // 挂载天地图卫星底图
  mapLayer.tDImageBaseLayer = await tDImageLayer();
  map.value.addLayer(mapLayer.tDImageBaseLayer);

  // 挂载道路标注图层（可选）
  mapLayer.addressLayer = await tDImageCiaLayer();
  map.value.addLayer(mapLayer.addressLayer);
}
```

---

## LOD 级别配置

### 标准 LOD 配置

```javascript
// 天地图 LOD 级别（0-19级）
const lods = [
  { level: 0, resolution: 156543.033928, scale: 591657527.591555 },
  { level: 1, resolution: 78271.5169639999, scale: 295828763.795777 },
  { level: 2, resolution: 0.3515625, scale: 147748796.52937502 },
  { level: 3, resolution: 0.17578125, scale: 73874398.264687508 },
  { level: 4, resolution: 0.087890625, scale: 36937199.132343754 },
  { level: 5, resolution: 0.0439453125, scale: 18468599.566171877 },
  { level: 6, resolution: 0.02197265625, scale: 9234299.7830859385 },
  { level: 7, resolution: 0.010986328125, scale: 4617149.8915429693 },
  { level: 8, resolution: 0.0054931640625, scale: 2308574.9457714846 },
  { level: 9, resolution: 0.00274658203125, scale: 1154287.4728857423 },
  { level: 10, resolution: 0.001373291015625, scale: 577143.73644287116 },
  { level: 11, resolution: 0.0006866455078125, scale: 288571.86822143558 },
  { level: 12, resolution: 0.00034332275390625, scale: 144285.93411071779 },
  { level: 13, resolution: 0.000171661376953125, scale: 72142.967055358895 },
  { level: 14, resolution: 8.58306884765625e-5, scale: 36071.483527679447 },
  { level: 15, resolution: 4.291534423828125e-5, scale: 18035.741763839724 },
  { level: 16, resolution: 2.1457672119140625e-5, scale: 9017.8708819198619 },
  { level: 17, resolution: 1.0728836059570313e-5, scale: 4508.9354409599309 },
  { level: 18, resolution: 5.3644180297851563e-6, scale: 2254.4677204799655 },
  { level: 19, resolution: 2.68220901489257815e-6, scale: 1127.23386023998275 },
];
```

---

## 事件绑定

### 地图交互事件

```javascript
function bindMapEvent() {
  // 地图点击事件
  dojo.connect(map, "onClick", async event => {
    $emit("click-map", event);
  });

  // 地图加载完成
  dojo.connect(map, "onLoad", event => {
    $emit("map-load", event);
  });

  // 鼠标滚轮事件
  dojo.connect(map, "onMouseWheel", event => {
    $emit("map-mouse-wheel", event);
  });
}
```

### 事件锁机制

```javascript
const mapLock = ref(false);

function handleMapClick(event) {
  // 锁事件，防止重复触发
  if (mapLock.value) {
    mapLock.value = false;
    return;
  }
  $emit("click-map", event);
}
```

---

## 天地图图层类型

### 1. 影像底图 (img)

```javascript
// 卫星影像图
`https://{subDomain}.tianditu.gov.cn/img_c/wmts?...`
```

### 2. 矢量底图 (vec)

```javascript
// 矢量电子地图（非卫星）
export async function tDImageVecLayer() {
  return await createWebTileLayer(
    `https://{subDomain}.tianditu.gov.cn/vec_c/wmts?...`,
    { ... }
  );
}
```

### 3. 标注图层 (cia/cva)

```javascript
// 影像标注（道路、地名）
// cia: 叠加在影像图上
// cva: 叠加在矢量图上
```

### 图层组合

```
卫星底图模式:
├── tDImageLayer (img_c) - 卫星影像
└── tDImageCiaLayer (cia_c) - 道路标注

矢量底图模式:
├── tDImageVecLayer (vec_c) - 矢量地图
└── tDAnnotationVecLayer (cva_c) - 矢量标注
```

---

## 常见问题

### 1. 地图显示空白

```
可能原因:
❌ 天地图 Token 无效或过期
❌ 网络请求被拦截
❌ 地图容器尺寸为 0

排查步骤:
1. 检查浏览器 Network 面板是否有天地图请求
2. 检查 Token 是否正确
3. 检查地图容器是否有明确尺寸
```

### 2. 缩放级别受限

```
可能原因:
❌ LOD 配置不完整
❌ minZoom/maxZoom 设置不当

解决方案:
确保 lods 配置包含 0-19 级
检查 props.minZoom 和 props.maxZoom
```

### 3. 图层叠加顺序

```
问题:
天地图标注跑到业务数据下面

原因:
addLayer 顺序问题

解决:
先添加底图，再添加业务图层
或者使用 map.reorderLayer() 调整顺序
```

### 4. 坐标系问题

```
问题:
数据位置偏移

原因:
spatialReference.wkid 设置不一致

解决:
天地图使用 WGS84 (wkid: 4326)
确保业务数据坐标系一致
```

---

## 注意事项

### 性能优化

```
⚠️ 重要:
1. 使用 CDN 加载 ArcGIS 模块（按需加载）
2. 地图容器必须设置明确尺寸
3. 避免同时显示过多图层
4. 使用 will-change 提示浏览器
```

### 响应式处理

```css
/* 地图容器需要响应式 */
.map-container {
  width: 100%;
  height: 100%;
  min-height: 400px; /* 最小高度 */
}
```

### 移动端适配

```javascript
// 启用移动端手势
map = new Map(container, {
  isScrollWheel: true,
  isPinchZoom: true,  // 双指缩放
});
```

---

## 相关模式

- [图片懒加载] - 类似按需加载模式
- [响应式栅格] - 响应式布局
