---
title: "ArcGIS 数据查询与服务交互"
description: "ArcGIS JS API 3.x 数据查询核心方法，包括 QueryTask、服务查询、空间查询"
tags: ["arcgis", "GIS", "query", "QueryTask", "空间查询"]
complexity: ⭐⭐
domain: feature
---

# ArcGIS 数据查询与服务交互

## 概述

本知识介绍 ArcGIS JS API 3.x 中数据查询的核心方法，包括 QueryTask 查询、空间查询、属性查询等。

适用于需要从 ArcGIS 服务获取地理数据、展示业务要素等场景。

---

## 查询基础

### 1. 创建查询对象

```javascript
// query.js
import importArcgisModules from "@/assets/js/gis/importArcgisModules";

export async function createQuery(queryOptions) {
  const [Query] = await importArcgisModules(["esri/tasks/query"]);
  const query = new Query();

  for (let [key, value] of Object.entries(queryOptions)) {
    query[key] = value;
  }

  return query;
}

// 使用示例
const query = await createQuery({
  where: "1=1",
  returnGeometry: true,
  outFields: ["*"],
});
```

### 2. QueryTask 查询

```javascript
export async function doQueryTaskByService(service, queryOptions) {
  const [QueryTask] = await importArcgisModules(["esri/tasks/QueryTask"]);

  const task = new QueryTask(service);
  const query = await createQuery(queryOptions);

  return await new Promise((resolve, reject) => {
    task.execute(query, resolve, reject);
  });
}
```

**使用示例：**

```javascript
// 查询某个区域内的所有要素
const result = await doQueryTaskByService(
  `${serviceUrl}/0?token=${gisToken}`,
  {
    where: "area_level = 2",
    returnGeometry: true,
    outFields: ["*"],
  }
);

// result = { features: [...], geometryType: "...", ... }
```

---

## 空间查询

### 1. 基础空间查询

```javascript
export const serverQuery = async (layerUrl, whereFn) => {
  var [QueryTask, Query, SpatialReference] = await importArcgisModules([
    "esri/tasks/QueryTask",
    "esri/tasks/query",
    "esri/SpatialReference"
  ]);

  return new Promise(resolve => {
    var queryTask = new QueryTask(layerUrl);
    var query = new Query();

    query.outFields = ["*"];
    if (whereFn) query.where = whereFn();

    if (!query.where) {
      resolve([false, []]);
      return;
    }

    // 设置坐标系
    query.outSpatialReference = new SpatialReference({ wkid: 4326 });

    // 空间关系：与几何相交
    query.spatialRelationship = Query.SPATIAL_REL_INTERSECTS;

    // 返回几何
    query.returnGeometry = true;
    query.returnDistinctValues = false;
    query.relationParam = false;

    try {
      queryTask.execute(query, queryResult => {
        if (!queryResult.features || queryResult.features.length === 0) {
          resolve([false, []]);
          return;
        }
        resolve([true, queryResult.features]);
      });
    } catch (e) {
      resolve([false, []]);
    }
  });
};
```

**使用示例：**

```javascript
// 条件查询
const [success, features] = await serverQuery(
  "http://example.com/arcgis/rest/service/land/MapServer/0",
  () => "type = '耕田'"
);

if (success) {
  console.log(features);  // 返回的要素数组
}
```

### 2. 点查询（点击查询）

```javascript
export const queryOnePointer = async function (evt, layerUrl, opts = {}) {
  const [QueryTask, query] = await importArcgisModules([
    "esri/tasks/QueryTask",
    "esri/tasks/query"
  ]);

  let queryObj = new query();
  queryObj.returnGeometry = true;
  queryObj.outFields = ["*"];
  queryObj.geometry = evt.mapPoint;  // 点击的坐标点
  queryObj = Object.assign(queryObj, opts);

  const queryTask = new QueryTask(layerUrl);

  return await new Promise(resolve => {
    queryTask.execute(
      queryObj,
      fset => {
        if (
          fset &&
          fset.features &&
          fset.features.length > 0 &&
          fset.features[0].attributes
        ) {
          resolve([true, fset]);
        } else {
          resolve([false, null]);
        }
      },
      err => {
        console.log(err);
        resolve([false, null]);
      }
    );
  });
};
```

**使用示例：**

```javascript
// 地图点击事件
map.on("click", async (evt) => {
  const [success, featureSet] = await queryOnePointer(
    evt,
    "http://example.com/arcgis/rest/service/land/MapServer/0"
  );

  if (success) {
    const feature = featureSet.features[0];
    console.log(feature.attributes);
  }
});
```

---

## Ajax 查询

### 1. 直接 Ajax 查询

```javascript
export const queryByAjax = async (layerUrl, where, paramsFn) => {
  var [Polygon] = await importArcgisModules(["esri/geometry/Polygon"]);

  return new Promise(resolve => {
    var params = {
      where: "1=1",
      text: "",
      objectIds: "",
      time: "",
      geometry: "",
      geometryType: "esriGeometryEnvelope",
      inSR: "",
      spatialRel: "esriSpatialRelIntersects",
      outFields: "*",
      returnGeometry: true,
      returnIdsOnly: false,
      returnCountOnly: false,
      f: "pjson"
    };

    // 支持函数或字符串
    if (where && typeof where === "function") params.where = where();
    if (where && typeof where === "string") params.where = where;

    // 自定义参数
    if (paramsFn && typeof paramsFn === "function") {
      params = paramsFn(params);
    }

    var req = createXMLHTTPRequest();
    if (!req) return resolve([false, {}]);

    req.open("POST", layerUrl, true);
    req.setRequestHeader(
      "Content-Type",
      "application/x-www-form-urlencoded;charset=utf-8"
    );
    req.send(param(params));

    req.onreadystatechange = function () {
      if (req.readyState === 4) {
        if (req.status === 200 && req.responseText) {
          var res = JSON.parse(req.responseText);
          if (!!res.features && res.features.length) {
            var features = res.features.map(feature => {
              if (feature.geometry && feature.geometry.rings) {
                feature.geometry = new Polygon({
                  rings: feature.geometry.rings,
                  spatialReference: { wkid: 4326 }
                });
              }
              return feature;
            });
            return resolve([true, features, res]);
          }
          return resolve([true, [], res]);
        } else {
          return resolve([false, [], res]);
        }
      }
    };
  });
};

// 辅助方法：参数序列化
function param(data) {
  let url = "";
  for (const k in data) {
    const value = data[k] != undefined ? data[k] : "";
    url += `&${k}=${encodeURIComponent(value)}`;
  }
  return url ? url.substring(1) : "";
}

// 辅助方法：创建 XMLHttpRequest
function createXMLHTTPRequest() {
  var xmlHttpRequest;
  if (window.XMLHttpRequest) {
    xmlHttpRequest = new XMLHttpRequest();
    if (xmlHttpRequest.overrideMimeType) {
      xmlHttpRequest.overrideMimeType("text/xml");
    }
  } else if (window.ActiveXObject) {
    var activexName = ["MSXML2.XMLHTTP", "Microsoft.XMLHTTP"];
    for (var i = 0; i < activexName.length; i++) {
      try {
        xmlHttpRequest = new ActiveXObject(activexName[i]);
        if (xmlHttpRequest) break;
      } catch (e) {
        console.error(e);
      }
    }
  }
  return xmlHttpRequest;
}
```

**使用示例：**

```javascript
// 简单查询
const [success, features] = await queryByAjax(
  layerUrl,
  "area_level = 1"
);

// 自定义查询参数
const [success, features, rawResponse] = await queryByAjax(
  layerUrl,
  null,
  (params) => ({
    ...params,
    where: "type IN ('A', 'B')",
    outFields: "id,name,area",
    returnGeometry: true,
  })
);
```

---

## Query 参数配置

### 常用参数

```javascript
const queryOptions = {
  // 1. 属性条件
  where: "area > 100",           // SQL WHERE 条件
  text: "keyword",               // 模糊搜索

  // 2. 空间过滤
  geometry: mapPoint,            // 几何对象
  spatialRelationship: Query.SPATIAL_REL_INTERSECTS,  // 空间关系

  // 3. 返回控制
  returnGeometry: true,         // 是否返回几何
  outFields: ["*"],             // 返回字段
  outSpatialReference: { wkid: 4326 },  // 输出坐标系

  // 4. 分页
  num: 100,                     // 返回数量
  start: 0,                     // 起始位置

  // 5. 去重和排序
  returnDistinctValues: false,
  orderByFields: ["area DESC"],
};
```

### 空间关系类型

```javascript
// 空间关系
Query.SPATIAL_REL_INTERSECTS   // 相交
Query.SPATIAL_REL_CONTAINS     // 包含
Query.SPATIAL_REL_WITHIN       // 被包含
Query.SPATIAL_REL_CROSSES      // 穿越
Query.SPATIAL_REL_TOUCHES      // 接触
Query.SPATIAL_REL_OVERLAPS     // 叠加
```

---

## 常见问题

### 1. Token 认证

```
问题：服务需要 Token 认证

解决方案：
const serviceWithToken = `${serviceUrl}/0?token=${gisToken}`;
const result = await doQueryTaskByService(serviceWithToken, queryOptions);
```

### 2. 坐标系问题

```
问题：查询结果位置偏移

原因：
- 服务坐标系与地图坐标系不一致
- WGS84 (4326) vs Web Mercator (3857)

解决：
// 设置输出坐标系
query.outSpatialReference = new SpatialReference({ wkid: 4326 });
```

### 3. CORS 跨域

```
问题：跨域请求失败

原因：
- ArcGIS 服务未配置 CORS
- 使用 XMLHttpRequest

解决：
1. 配置 ArcGIS Server CORS
2. 或使用 ArcGIS 代理
3. 或使用 esriRequest
```

### 4. 查询性能

```
问题：查询大量数据很慢

解决方案：
1. 添加空间过滤条件
2. 限制返回字段（outFields）
3. 使用分页（num, start）
4. 使用服务端的缓存切片
```

---

## 最佳实践

### 1. 统一错误处理

```javascript
async function safeQuery(service, options) {
  try {
    const result = await doQueryTaskByService(service, options);
    return {
      success: true,
      data: result.features || [],
    };
  } catch (error) {
    console.error("Query failed:", error);
    return {
      success: false,
      error: error.message,
    };
  }
}
```

### 2. 批量查询

```javascript
async function batchQuery(queries) {
  const results = await Promise.all(
    queries.map(({ service, options }) =>
      doQueryTaskByService(service, options)
    )
  );
  return results.flatMap(r => r.features || []);
}
```

### 3. 查询缓存

```javascript
const cache = new Map();

async function cachedQuery(key, service, options) {
  if (cache.has(key)) {
    return cache.get(key);
  }

  const result = await doQueryTaskByService(service, options);
  cache.set(key, result);

  // 限制缓存大小
  if (cache.size > 50) {
    const firstKey = cache.keys().next().value;
    cache.delete(firstKey);
  }

  return result;
}
```

---

## 相关模式

- [ArcGIS 图形渲染与符号系统] - 渲染查询结果
- [ArcGIS 地图初始化与天地图集成] - 基础地图配置
