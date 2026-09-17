---
title: "ArcGIS 图形渲染与符号系统"
description: "ArcGIS JS API 3.x 图形渲染核心方法，包括点、线、面符号创建和图形渲染"
tags: ["arcgis", "GIS", "symbol", "graphic", "渲染", "marker"]
complexity: ⭐⭐
domain: feature
---

# ArcGIS 图形渲染与符号系统

## 概述

本知识介绍 ArcGIS JS API 3.x 中图形渲染的核心方法，包括符号（Symbol）创建和图形（Graphic）渲染。

适用于需要在地图上展示点标记、文字标注、区域填充等可视化需求。

---

## 符号类型

### 1. 点标记符号 (PictureMarkerSymbol)

```javascript
// symbol.js
import importArcgisModules from "@/assets/js/gis/importArcgisModules";

export const pictureMarkerSymbol = async (option, returnOption = true) => {
  var [PictureMarkerSymbol] = await importArcgisModules([
    "esri/symbols/PictureMarkerSymbol",
  ]);
  const defaultOption = {
    url: "",        // 图片地址
    width: 20,      // 宽度
    height: 20,     // 高度
    xoffset: 0,     // X轴偏移
    yoffset: 0,     // Y轴偏移
  };
  option = Object.assign(defaultOption, option);
  return returnOption ? option : new PictureMarkerSymbol(option);
};
```

**使用示例：**

```javascript
// 创建点标记图形
const symbol = await pictureMarkerSymbol({
  url: "/marker.png",
  width: 32,
  height: 32,
  xoffset: 0,
  yoffset: 16,  // 使标记底部对齐坐标点
});
```

### 2. 文字符号 (TextSymbol)

```javascript
export const textSymbol = async (option = {}, returnOption = true) => {
  var [TextSymbol] = await importArcgisModules(["esri/symbols/TextSymbol"]);
  var defaultOption = {
    type: "text",
    horizontalAlignment: "center",
    text: "",
    color: [157, 209, 215],  // RGB 数组
    xoffset: "0px",
    yoffset: "0px",
    font: {
      size: "12px",
      weight: "normal",
    },
    center: [0, 0],
  };
  option = Object.assign(defaultOption, option);
  return returnOption ? option : new TextSymbol(option);
};
```

**使用示例：**

```javascript
const symbol = await textSymbol({
  text: "标注文字",
  color: [255, 0, 0],
  fontsize: "14px",
  font: {
    size: "14px",
    weight: "bold",
  },
  xoffset: "10px",
  yoffset: "-10px",
});
```

### 3. 面填充符号 (SimpleFillSymbol)

```javascript
export const polygonSymbol = async (
  areaColor = [203, 38, 52, 0.4],     // 填充色 (RGBA)
  borderColor = [203, 38, 52, 0.8],   // 边框色 (RGBA)
  borderWidth = 2                       // 边框宽度
) => {
  var [SimpleFillSymbol, SimpleLineSymbol] = await importArcgisModules([
    "esri/symbols/SimpleFillSymbol",
    "esri/symbols/SimpleLineSymbol",
  ]);
  return new SimpleFillSymbol(
    SimpleFillSymbol.STYLE_SOLID,
    new SimpleLineSymbol(
      SimpleLineSymbol.STYLE_SOLID,
      new dojo.Color(borderColor),
      borderWidth
    ),
    new dojo.Color([...areaColor, 1])
  );
};
```

**使用示例：**

```javascript
const symbol = await polygonSymbol(
  [255, 0, 0, 0.3],   // 半透明红色填充
  [255, 0, 0, 1],     // 红色边框
  2                     // 2px 边框
);
```

---

## 图形创建

### 1. 点图形 (Point Graphic)

```javascript
// graphic.js
import importArcgisModules from "@/assets/js/gis/importArcgisModules";
import { Point } from "@/assets/js/arcgis-api/geometry";

export const pictureMarkerSymbolGraphic = async (
  {
    url = "",
    center = [0, 0],      // [lng, lat]
    width = 20,
    height = 20,
    xoffset = 0,
    yoffset = 0,
    wkid = 4326,           // 坐标系
  } = {},
  attributes = {}           // 业务属性
) => {
  var [Graphic] = await importArcgisModules(["esri/graphic"]);
  var symbol = await pictureMarkerSymbol({
    url,
    width,
    height,
    xoffset,
    yoffset,
  }, false);
  var geometry = await Point(center, wkid);
  return new Graphic(geometry, symbol, attributes);
};
```

### 2. 文字图形 (Text Graphic)

```javascript
export const textSymbolGraphic = async (
  {
    text = "",
    center = [0, 0],
    color = [157, 209, 215],
    fontsize = "12px",
    weight = "normal",
    xoffset = "",
    yoffset = "",
  } = {},
  attributes = {}
) => {
  var [Graphic] = await importArcgisModules(["esri/graphic"]);
  return new Graphic({
    geometry: {
      type: "point",
      x: center[0],
      y: center[1],
      z: 0,
    },
    symbol: textSymbol({
      text: text,
      color: color,
      xoffset: xoffset + "px",
      yoffset: yoffset + "px",
      font: {
        size: fontsize,
        weight: weight,
      },
      center: center,
    }),
    attributes,
  });
};
```

### 3. 面图形 (Polygon Graphic)

```javascript
import importArcgisModules from "@/assets/js/gis/importArcgisModules";
import { polygonSymbol } from "@/assets/js/arcgis-api/symbol";

export const renderPolygonGraphic = async (
  areaColor,
  borderColor,
  borderWidth,
  Rings,         // 面坐标环
  attributes = {}
) => {
  var [Graphic, Polygon, SpatialReference] = await importArcgisModules([
    "esri/graphic",
    "esri/geometry/Polygon",
    "esri/SpatialReference",
  ]);
  const symbol = await polygonSymbol(areaColor, borderColor, borderWidth);
  var polygon = new Polygon(new SpatialReference({ wkid: 4326 }));
  for (var j = 0, len = Rings.length; j < len; j++) {
    polygon.addRing(Rings[j]);
  }
  return new Graphic(polygon, symbol, attributes);
};
```

---

## 批量渲染

### 1. 批量渲染多边形

```javascript
// graphic.js
export const renderAllPolygonGraphic = async (
  features,
  symbolHandler,  // (feature) => [areaColor, borderColor, borderWidth]
  layer
) => {
  if (features.length === 0) return;
  let graphics = [];
  for (let i = 0; i < features.length; i++) {
    let [areaColor, borderColor, borderWidth] = symbolHandler(features[i]);
    let rings = JSON.parse(JSON.stringify(features[i].geometry.rings));
    let graphic = await renderPolygonGraphic(
      areaColor,
      borderColor,
      borderWidth,
      rings,
      features[i].attributes || {}
    );
    graphics.push(graphic);
    layer && layer.add(graphic);
  }
  return graphics;
};
```

**使用示例：**

```javascript
const symbolHandler = (feature) => {
  // 根据属性返回不同样式
  if (feature.attributes.type === "耕田") {
    return ["255,0,0,0.3", "255,0,0,1", 2];
  }
  return ["0,255,0,0.3", "0,255,0,1", 2];
};

await renderAllPolygonGraphic(features, symbolHandler, layer);
```

### 2. 合并渲染（同色合并）

```javascript
export const renderAllPolygonGraphicWithMerge = async (
  features,
  symbolHandler,
  layer
) => {
  if (features.length === 0) return;
  let graphicAll = {};
  let graphics = [];

  // 1. 按样式合并
  for (let i = 0; i < features.length; i++) {
    var [areaColor, borderColor, borderWidth] = symbolHandler(features[i]);
    var key = (areaColor + borderColor + borderWidth).split(",").join("");
    var rings = JSON.parse(JSON.stringify(features[i].geometry.rings));

    if (!graphicAll[key]) {
      graphicAll[key] = {
        areacolor: areaColor,
        bordercolor: borderColor,
        borderwidth: borderWidth,
        rings: rings,
      };
    } else {
      graphicAll[key].rings = graphicAll[key].rings.concat(rings);
    }
  }

  // 2. 渲染合并后
  var featureTemps = Object.values(graphicAll);
  for (var j = 0; j < featureTemps.length; j++) {
    let { areacolor, bordercolor, borderwidth, rings } = featureTemps[j];
    let graphic = await renderPolygonGraphic(
      areacolor,
      bordercolor,
      borderwidth,
      rings
    );
    graphics.push(graphic);
    layer && layer.add(graphic);
  }
};
```

---

## 图层渲染

### 1. 渲染到图层

```javascript
// layer.js
import importArcgisModules from "@/assets/js/gis/importArcgisModules";

export async function renderGraphicsLayerByGraphics(
    graphicsLayer,
    graphics,        // Graphic[] 或包含 geometry 的对象
    fillColor,       // "255,255,255,1"
    outlineColor,    // "0,246,255,1"
    width = 1.5
) {
  const [Graphic] = await importArcgisModules(["esri/graphic"]);
  const fillSymbol = await renderSimpleFillSymbol(fillColor, outlineColor, width);

  const graList = graphics.map(graphic => {
    return new Graphic(graphic.geometry, fillSymbol, graphic.attributes);
  });

  graList.forEach(gra => {
    graphicsLayer.add(gra);
  });
}
```

### 2. 蒙层效果

```javascript
// 镂空蒙层
export async function renderGraphicsMaskLayerByFeatures(
    graphicsLayer,
    features
) {
  const [Graphic, Polygon, SimpleFillSymbol, SimpleLineSymbol, Color] =
      await importArcgisModules([
        "esri/graphic",
        "esri/geometry/Polygon",
        "esri/symbols/SimpleFillSymbol",
        "esri/symbols/SimpleLineSymbol",
        "esri/Color"
      ]);

  // 黑色蒙层面（覆盖全球）
  const MASK_COORDINATES = [
    [-180, 90],
    [180, 90],
    [180, -90],
    [-180, -90]
  ];

  const fillSymbol = new SimpleFillSymbol({
    style: "esriSFSSolid",
    color: new Color([0, 0, 0, 0.6]),  // 半透明黑色
    outline: new SimpleLineSymbol({
      style: "esriSLSSolid",
      color: new Color([0, 246, 255, 0]),
      width: 1
    })
  });

  const polygon = new Polygon(MASK_COORDINATES);
  features.forEach(({ geometry }) => {
    geometry.rings.forEach(ring => {
      polygon.addRing(ring);  // 镂空处理
    });
  });

  graphicsLayer.add(new Graphic(polygon, fillSymbol));
}
```

---

## 常见问题

### 1. 颜色格式

```
⚠️ 重要：ArcGIS 使用 RGB 数组，不是 RGBA 字符串

❌ 错误：
color: "rgba(255, 0, 0, 0.5)"
color: "#FF0000"

✅ 正确：
color: [255, 0, 0, 0.5]  // RGBA 数组
color: "255,0,0,0.5"      // 字符串格式（用于某些方法）
```

### 2. 坐标偏移

```
问题：标记图标和实际位置有偏差

原因：默认图标中心对齐坐标点

解决：使用 yoffset 偏移
通常设为 height / 2，使底部对齐
```

### 3. 大量图形性能

```
问题：渲染 1000+ 图形时卡顿

解决方案：
1. 使用合并渲染（renderAllPolygonGraphicWithMerge）
2. 使用要素服务（FeatureLayer）替代 GraphicsLayer
3. 使用聚合（Clustering）
4. 使用切片缓存
```

---

## 使用场景

```
1. 地图标注
   → pictureMarkerSymbolGraphic + textSymbolGraphic

2. 区域高亮
   → renderPolygonGraphic + 条件渲染

3. 数据可视化
   → renderAllPolygonGraphicWithMerge + 分类样式

4. 蒙层效果
   → renderGraphicsMaskLayerByFeatures
```

---

## 相关模式

- [ArcGIS 地图初始化与天地图集成] - 基础地图配置
- [ArcGIS 数据查询] - 服务查询方法
