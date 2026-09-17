---
title: "ArcGIS 几何计算与坐标处理"
description: "ArcGIS JS API 3.x 几何计算核心方法，包括面积计算、范围获取、坐标转换"
tags: ["arcgis", "GIS", "geometry", "面积", "坐标", "计算"]
complexity: ⭐⭐
domain: feature
---

# ArcGIS 几何计算与坐标处理

## 概述

本知识介绍 ArcGIS JS API 3.x 中几何计算的核心方法，包括面积计算、范围计算、坐标转换等。

适用于需要计算地理数据面积、获取要素范围、进行坐标转换等场景。

---

## 点 (Point) 创建

### 1. 创建点坐标

```javascript
// geometry.js
import importArcgisModules from "@/assets/js/gis/importArcgisModules";

export const Point = async (latlng = [0, 0], wkid = 4326) => {
  var [Point, SpatialReference] = await importArcgisModules([
    "esri/geometry/Point",
    "esri/SpatialReference",
  ]);
  return new Point(latlng, new SpatialReference({ wkid }));
};
```

**使用示例：**

```javascript
// 创建 WGS84 坐标点
const point = await Point([116.397, 39.908], 4326);

// 创建墨卡托坐标点
const pointMercator = await Point([12950000, 4850000], 3857);
```

---

## 面积计算

### 1. 计算多个多边形面积

```javascript
/**
 * @description 计算图形面积 默认返回亩
 * @param polygons Polygon[] 图形类列表
 * @param areaUnit 面积单位
 *   - MU（亩）
 *   - ACRES（英亩）
 *   - SQUARE_METERS（平方米）
 *   - SQUARE_DECIMETERS（平方分米）
 */
export async function getPolygonsArea(polygons, areaUnit = "MU") {
  const [geodesicUtils, Units] = await importArcgisModules([
    "esri/geometry/geodesicUtils",
    "esri/units"
  ]);

  const IS_TO_MU = areaUnit === "MU";

  return geodesicUtils
      .geodesicAreas(polygons, Units[IS_TO_MU ? "SQUARE_METERS" : areaUnit])
      .map(Math.abs)
      .map(area => area2Mu(area, IS_TO_MU ? 3 : 1));
}
```

**使用示例：**

```javascript
// 计算面积并转换为亩
const areas = await getPolygonsArea(polygons, "MU");

// 计算面积并转换为平方米
const areasInSquareMeters = await getPolygonsArea(polygons, "SQUARE_METERS");

console.log(areas); // [123.45, 67.89] (亩)
```

### 2. 面积单位转换

```javascript
/**
 * @description 面积统一转成亩
 * @param {number} value - 面积
 * @param {number} [unitCode=1]
 *   - 1: 值不改动
 *   - 2: 分
 *   - 3: 平方米
 * @returns {number}
 */
export function area2Mu(value, unitCode) {
  switch (unitCode) {
    case 3:
      return maxDecimalPlaces(value * 0.0015);  // 平方米转亩
    case 2:
      return maxDecimalPlaces(value * 0.1);     // 分转亩
    case 1:
    default:
      return maxDecimalPlaces(value);            // 已经是亩
  }
}
```

### 3. 浮点数精度处理

```javascript
/**
 * @description 最大保留的位数
 * @param {number | string} value
 * @param {number} [places=2] - 精确浮点位
 */
export function maxDecimalPlaces(value = 0, places = 2) {
  if (Number.isNaN(value) || value === undefined || value === null)
    return value;

  if (!Number.isInteger(value)) {
    value = String(value);
    if (value.split(".")[1].length > places) {
      value = Math.round(value * Math.pow(10, places)) / Math.pow(10, places);
    }
  }

  return parseFloat(value);
}
```

**使用示例：**

```javascript
// 保留2位小数
maxDecimalPlaces(123.456789); // 123.46
maxDecimalPlaces(123); // 123

// 保留4位小数
maxDecimalPlaces(123.123456789, 4); // 123.1235
```

---

## 范围计算

### 1. 根据多个要素获取视口范围

```javascript
/**
 * @description 获取多个图形数据的视口位置
 * @param features Graphic[] 图形数组
 * @param [factor=2] 多图形视口缩放大小
 * @returns Promise<Extent>
 */
export async function getExtentByFeatures(features, factor = 2) {
  const [Polygon, SpatialReference] = await importArcgisModules([
    "esri/geometry/Polygon",
    "esri/SpatialReference"
  ]);

  let polygon = new Polygon(new SpatialReference({ wkid: 4326 }));

  // 合并所有要素的几何
  features
      .map(feature => feature.geometry.rings)
      .forEach(rings => {
        rings.forEach(ring => {
          polygon.addRing(ring);
        });
      });

  // 获取范围并扩展
  const extent = polygon.getExtent().expand(factor);

  // 销毁临时对象
  polygon = null;

  return extent;
}
```

**使用示例：**

```javascript
// 查询要素
const result = await doQueryTaskByService(service, {
  where: "area_level = 1",
  returnGeometry: true,
});

// 获取适合显示的范围
const extent = await getExtentByFeatures(result.features, 1.5);

// 缩放地图到该范围
map.setExtent(extent);
```

### 2. 范围扩展因子

```
factor 参数说明：
- factor = 1: 紧密贴合
- factor = 1.5: 略微扩展
- factor = 2: 标准扩展（推荐）
- factor = 3: 大幅扩展，显示更多周边
```

---

## 坐标系

### 1. 常用坐标系

```javascript
// WGS84 (GPS 标准)
wkid: 4326

// Web Mercator (在线地图常用)
wkid: 3857

// GCJ-02 (中国坐标，需要偏移)
wkid: 4326 + 偏移

// CGCS2000 (中国大地坐标系)
wkid: 4490
```

### 2. 坐标转换

```javascript
// WGS84 转 GCJ-02 (GPS 转中国坐标)
import { wgs84togcj02 } from "@/utils/coord-transform";

const [lng84, lat84] = [116.397, 39.908];
const [lng02, lat02] = wgs84togcj02(lng84, lat84);
```

---

## 常见问题

### 1. 面积计算不准确

```
问题：计算面积与实际不符

原因：
- 使用平面坐标系计算
- 坐标系单位不正确

解决：
使用 geodesicUtils.geodesicAreas() 进行测地线计算
确保使用 WGS84 (4326) 坐标系
```

### 2. 浮点数精度问题

```
问题：面积出现 123.4567890123

解决：
使用 maxDecimalPlaces() 限制小数位数

maxDecimalPlaces(123.4567890123, 2); // 123.46
```

### 3. 范围扩展过大/过小

```
问题：地图显示范围不合适

解决：
- 地图太紧：增加 factor
- 地图太空：减小 factor

// 推荐起始值
const extent = await getExtentByFeatures(features, 2);

// 微调
const extent = await getExtentByFeatures(features, 1.5);
```

---

## 最佳实践

### 1. 面积计算封装

```javascript
async function calculateLandArea(features) {
  const [Polygon] = await importArcgisModules(["esri/geometry/Polygon"]);

  const polygons = features.map(f => f.geometry);
  const areas = await getPolygonsArea(polygons, "MU");

  return {
    total: areas.reduce((a, b) => a + b, 0),
    areas: areas,
    unit: "亩",
  };
}
```

### 2. 视口适配封装

```javascript
async function fitMapToFeatures(map, features, padding = 20) {
  if (!features || features.length === 0) return;

  const extent = await getExtentByFeatures(features, 2);
  map.setExtent(extent, true);
}
```

### 3. 坐标验证

```javascript
function isValidCoordinate(lng, lat) {
  return (
    typeof lng === "number" &&
    typeof lat === "number" &&
    lng >= -180 && lng <= 180 &&
    lat >= -90 && lat <= 90
  );
}
```

---

## 相关模式

- [ArcGIS 数据查询与服务交互] - 查询几何数据
- [ArcGIS 图形渲染与符号系统] - 渲染几何图形
