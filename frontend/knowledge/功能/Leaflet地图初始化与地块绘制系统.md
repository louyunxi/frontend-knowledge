---
title: "Leaflet 地图初始化与地块绘制系统"
description: "Leaflet 地图初始化、高德坐标系底图配置、区域影像服务集成，以及基于 Leaflet-Geoman 的地块绘制、编辑、面积计算功能"
tags: ["leaflet", "地图", "高德", "地块绘制", "GIS", "Geoman", "面积计算"]
complexity: ⭐⭐⭐
domain: feature
---

# Leaflet 地图初始化与地块绘制系统

## 概述

本知识介绍基于 Leaflet 的地图初始化和地块绘制系统的完整实现方案，包括：

- 多图层底图配置（天地图边界线、谷歌卫星图、高德2D地图）
- 区域影像服务集成
- 基于 Leaflet-Geoman 的地块绘制、编辑功能
- 动态点间距计算与面积计算
- 地块轮廓校验

---

## 一、地图初始化

### 1. 地图图层配置

```javascript
// mapTools.js
async configMapLayer(type) {
  // 边界线 > 谷歌卫星图 > 高德2D地图
  var boundLine = L.tileLayer.chinaProvider('TianDiTu.Realm.Map', {
    id: 'layer_line',
    zIndex: 5,
    maxZoom: 22,
    minZoom: 1,
  });

  var satelliteMap = L.tileLayer.chinaProvider('Google.Satellite.Map', {
    id: 'layer_google',
    zIndex: 3,
    maxZoom: 22,
  });

  var gaode2d = L.tileLayer.chinaProvider('GaoDe.Normal.Map', {
    id: 'layer_gaodeLabel',
    zIndex: 1,
    maxZoom: 22,
  });

  var layers = [boundLine, satelliteMap, gaode2d];

  // 可选：添加高德标注图层
  if (type === 'showaddress') {
    let gaoDeAnnotion = L.tileLayer.chinaProvider('GaoDe.Satellite.Annotion', {
      id: 'layer_gaodeAnnotion',
      zIndex: 5,
    });
    layers.push(gaoDeAnnotion);
  }

  return layers;
}
```

### 2. 初始化地图实例

```javascript
initMap(options) {
  return new Promise(async resolve => {
    var layers = await this.configMapLayer(options.source);

    var defaultOptions = {
      center: [39.90923, 116.397428],  // 默认中心点
      zoom: 8,
      zoomSnap: 0.1,
      layers: layers,
      zoomControl: false,           // 隐藏缩放控件
      attributionControl: false,   // 隐藏版权信息
      dragging: true,
      touchZoom: !options.onlyView,
      scrollWheelZoom: !options.onlyView,
      doubleClickZoom: !options.onlyView,
      boxZoom: false,
      keyboard: false,
      maxZoom: 21,
      minZoom: 1,
      preferCanvas: true,          // 使用 Canvas 渲染
    };

    var map = L.map(options.elId, defaultOptions);

    // 绑定事件
    map.on('click', (e) => {
      options.mapClick && options.mapClick(e.latlng);
    });

    map.on('zoomend', (e) => {
      options.mapZoomChange && options.mapZoomChange(e.target._zoom);
    });

    resolve({ map, layers });
  });
}
```

### 3. 区域影像服务集成

```javascript
async getAreaTileLayerFn(areaTileServe) {
  let token = await this.getAreaToken(areaTileServe['serverUrl']);

  return new Promise(resolve => {
    if (window.getAreaTileLayer) {
      return resolve(getAreaTileLayer(areaTileServe['serverUrl'], token));
    }
    // 动态加载脚本
    $.getScript('./src/js/map/areaTileLayer.js', () => {
      resolve(getAreaTileLayer(areaTileServe['serverUrl'], token));
    });
  });
}

// 配置中集成区域影像
if (this.hasAreaTileServer) {
  let jyLayer = await this.getAreaTileLayerFn(this.areaTileServe);
  if (jyLayer) {
    layers.splice(1, 0, jyLayer);  // 插入到卫星图位置
  }
}
```

---

## 二、地块绘制系统

### 1. 绘制核心配置

```javascript
var geomanDraw = {
  map: null,
  theCollection: null,          // 绘制图层集合
  defaultColor: '#E49357',
  default_opts: {
    allowSelfIntersection: false,   // 禁止自相交
    templineStyle: {
      color: '#E49357',
      weight: 2,
    },
    hintlineStyle: {
      color: '#E49357',
      dashArray: [5, 5],
      weight: 2,
    },
    pathOptions: {
      color: '#E49357',
      fillColor: '#E49357',
      weight: 2,
      fillOpacity: 0.5,
    },
    markerStyle: {
      icon: L.divIcon({ className: 'zyj-div-icon' }),
    },
    cursorMarker: false,
    snapMiddle: true,          // 重叠部分去除
    finishOn: 'dblclick',      // 双击结束绘制
    finishOnDoubleClick: true,
    requireSnapToFinish: true,
  },

  // 初始化绘制层
  initCollectLayer: function () {
    var geoJsonData = {
      type: 'FeatureCollection',
      features: [],
    };

    this.theCollection = L.geoJson(geoJsonData, {
      id: 'layer_geojson',
      style: () => ({
        color: this.defaultColor,
        weight: 2,
        fillColor: this.defaultColor,
        fillOpacity: 0.5,
      }),
    });

    this.theCollection.addTo(this.map);

    // 监听拖拽事件
    this.theCollection.on('pm:markerdragend', (e) => {
      const features = this.theCollection.toGeoJSON();
      drawPoints = L.GeoJSON.coordsToLatLngs(
        features.features[0].geometry.coordinates[0]
      ).map(p => [p.lat, p.lng]);
    });
  },

  // 初始化绘制工具
  initGeomanDraw: function () {
    this.map.pm.setLang('zh');  // 设置中文

    // 添加控件
    this.map.pm.addControls({
      position: 'bottomleft',
      drawPolygon: true,
      editPolygon: true,
      drawMarker: false,
      drawCircleMarker: false,
      drawPolyline: false,
      drawRectangle: false,
      drawCircle: false,
      dragMode: false,
      removalMode: true,       // 允许删除
      cutPolygon: false,
    });
  },
};
```

### 2. 绘制事件处理

```javascript
// 绘制开始
map.on('pm:drawstart', (e) => {
  isDrawing = true;

  e.workingLayer.on('pm:vertexadded', (evt) => {
    // 更新标注点
    drawPoints = e.workingLayer.getLatLngs().map(p => [p.lat, p.lng]);
    geomanDraw.drawedPot = evt.sourceTarget._latlngs.length;
  });
});

// 绘制完成
map.on('pm:create', (e) => {
  var latlngs = e.layer._latlngs[0];
  var path = latlngs.map(item => [item.lat, item.lng]);

  var newPolygon = L.polygon(path, {
    color: geomanDraw.defaultColor,
    weight: 2,
    fillColor: geomanDraw.defaultColor,
    fillOpacity: 0.5,
  });

  // 清除其他图层，保留底图
  map.eachLayer((layer) => {
    if (!layer.options.id || layer.options.id.indexOf('layer_') === -1) {
      map.removeLayer(layer);
    }
  });

  // 添加新多边形
  geomanDraw.theCollection.clearLayers().addLayer(newPolygon).pm.enable({
    preventMarkerRemoval: true,
  });

  // 渲染面积和距离
  renderAreaAndDistance(drawPoints, map);
});

// 绘制结束
map.on('pm:drawend', () => {
  isDrawing = false;
});
```

---

## 三、动态计算功能

### 1. 面积计算

```javascript
getPolygonAreaFn(path) {
  return new Promise(async resolve => {
    var hasturf = await this.turfAreaLoaded();
    if (!hasturf) {
      resolve(0);
      return;
    }

    var polygon = turf.polygon([path]);
    var area = turf.area(polygon);
    resolve(area);
  });
}

// turf 动态加载
turfAreaLoaded() {
  return new Promise(async resolve => {
    await this.loadSource(
      () => !(window.turf && window.turf.area),
      () => {
        var hm = document.createElement('script');
        hm.src = 'https://cdn.example.com/turf/turf-area.min.js';
        document.body.appendChild(hm);
      }
    );
    resolve(true);
  });
}
```

### 2. 绘制点间距动态计算

```javascript
map.on('mousemove', (e) => {
  if (isDrawing) {
    const { latlng } = e;

    // 实时更新绘制预览线
    drawPoints = [
      ...geomanDraw.map.pm.Draw.Polygon._layer.getLatLngs().map(p => [p.lat, p.lng]),
      [latlng.lat, latlng.lng],
    ];

    // 动态计算间距（可选：显示实时距离）
    if (drawPoints.length >= 2) {
      const lastPoint = drawPoints[drawPoints.length - 2];
      const distance = this.calculateDistance(lastPoint, [latlng.lat, latlng.lng]);
      console.log('当前点间距:', distance, '米');
    }
  }
});

// 计算两点间距离（米）
calculateDistance(point1, point2) {
  var latlng1 = L.latLng(point1[0], point1[1]);
  var latlng2 = L.latLng(point2[0], point2[1]);
  return latlng1.distanceTo(latlng2);
}
```

### 3. 中心点和缩放级别计算

```javascript
getPolygonCenterZoom(allpointer) {
  var bigpolygon = L.polygon(allpointer, {}).getBounds();
  var allzoom = this.map.getBoundsZoom(bigpolygon);
  var allcenter = bigpolygon.getCenter();
  return [allzoom, allcenter];
}

// 显示单个多边形并居中
showOnePolygon(path, color) {
  if (!(path && path.length > 1)) return;

  this.addPolygon(path, color);
  var [zoom, center] = this.getPolygonCenterZoom(path);

  this.map.setView(
    { lat: center.lat, lng: center.lng },
    zoom - 0.6
  );
}
```

---

## 四、地块轮廓校验

### 1. 去除重复点

```javascript
function _pointHander(points) {
  let temp = {},
    len = points.length - 1;

  return points.filter((p, i) => {
    if (i === len) return true;

    let latlng = String(p[0]) + String(p[1]);

    if (Reflect.has(temp, latlng)) {
      return false;
    } else {
      Reflect.set(temp, latlng, true);
      return true;
    }
  });
}
```

### 2. 自相交校验

```javascript
function showViewMap(needSave) {
  if (needSave) {
    // 获取 GeoJSON
    var curGeojson = geomanDraw.theCollection.toGeoJSON();
    var newGeometry = [];

    curGeojson.features[0].geometry.coordinates[0].forEach((item) => {
      var point = [item[1], item[0]];  // 坐标转换
      newGeometry.push(point);
    });

    newGeometry = _pointHander(newGeometry);

    // 校验是否自相交
    try {
      var polygon = turf.polygon([newGeometry]);
      var kinks = turf.kinks(polygon);

      if (Boolean(kinks.features.length)) {
        layer.msg('不允许绘制交叉形状的地块轮廓');
        return false;
      }
    } catch (error) {
      layer.msg('绘制的图形异常请重新绘制');
      redraw();
      return false;
    }

    // 计算中心点和缩放级别
    var poly = L.polygon(newGeometry, {});
    var polyBounds = poly.getBounds();
    var zoom = geomanDraw.map.getBoundsZoom(polyBounds);
    var latlng = geomanDraw.theCollection.getBounds().getCenter();

    areadata = {
      path: newGeometry,
      center: [latlng.lat, latlng.lng],
      zoom: zoom - 1,
    };
  }

  return true;
}
```

---

## 五、撤销逻辑优化

```javascript
// 自定义撤销行为
L.PM.watchBtnStatus = (s) => {
  if (!s) {
    // 当前已经撤销到0个点，此时还要多点一次撤销才可恢复
    if (geomanDraw.drawedPot === 0 && geomanDraw.needMoreUndo) {
      geomanDraw.map.pm.enableDraw('Polygon', geomanDraw.default_opts);
      return;
    }
    geomanDraw.theCollection.pm.disable();
  }
};

// 撤销监听
L.PM.vertexRemove = (l) => {
  if (geomanDraw.drawedPot === 0 && l === 0) {
    geomanDraw.needMoreUndo = false;
  }
  geomanDraw.drawedPot = l;
};
```

---

## 六、批量地块渲染

```javascript
function drawAllPolygon(map) {
  // 获取所有地块数据
  getPost(urlLandGroupMapList, params, token, (res) => {
    geomanDraw.drawnPolygons = [];

    res.obj.forEach((landData) => {
      if (!landData.path) return;

      var polygon = L.polygon(JSON.parse(landData.path), {
        color: '#FFFFFF',
        fillColor: '#FFFFFF',
        fillOpacity: 0.3,
        weight: 1,
      });

      geomanDraw.drawnPolygons.push(polygon);

      // 添加面积标注
      const areaLabelMarker = getAreaLabelMarker(
        JSON.parse(landData.path),
        { landName: landData.landName }
      );
      if (areaLabelMarker) {
        geomanDraw.drawnLandAreaLabelMarker.push(areaLabelMarker);
      }
    });

    // 合并成组一次性添加
    geomanDraw.polygonAllLayer = L.layerGroup(geomanDraw.drawnPolygons);
    geomanDraw.polygonAllLayer.addTo(map);

    geomanDraw.areaLabelAllLayer = L.layerGroup(geomanDraw.drawnLandAreaLabelMarker);
    geomanDraw.areaLabelAllLayer.addTo(map);
  });
}
```

---

## 七、常见问题

### 1. 绘制点过密

```
问题：用户快速点击产生密集点

解决：设置最小点间距
在 mousemove 事件中判断距离
小于阈值则不添加点
```

### 2. 自相交图形

```
问题：用户绘制了交叉形状

解决：使用 turf.kinks() 检测
检测到则提示用户重新绘制
```

### 3. 地图偏移

```
问题：坐标显示不正确

原因：高德坐标系 vs WGS84

解决：
coord(type, coord) 方法进行转换
type: 1 = GCJ02 转 WGS84
type: 2 = WGS84 转 GCJ02
```

### 4. 区域影像服务失效

```
问题：区域影像不显示

排查：
1. 检查 Token 是否有效
2. 检查服务 URL 是否正确
3. 检查 CORS 配置
```

---

## 八、依赖资源

```javascript
// Leaflet 核心
 leaflet.js
 leaflet.css

// Leaflet 中文提供
 leaflet.ChineseTmsProviders.js

// turf.js 面积计算
 turf.min.js

// Leaflet-Geoman 绘制
 leaflet-geoman.css
 leaflet-geoman.js
```

---

## 相关模式

- [ArcGIS 地图初始化与天地图集成] - ArcGIS 版本实现
- [ArcGIS 图形渲染与符号系统] - 要素渲染方法
- [ArcGIS 数据查询与服务交互] - 服务查询方法
