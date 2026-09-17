---
title: "ArcGIS 事件系统与地图交互"
description: "ArcGIS JS API 3.x 事件系统核心方法，包括事件绑定、解绑、事件锁机制"
tags: ["arcgis", "GIS", "event", "事件", "交互", "地图"]
complexity: ⭐
domain: feature
---

# ArcGIS 事件系统与地图交互

## 概述

本知识介绍 ArcGIS JS API 3.x 中事件系统的核心方法，包括地图事件绑定、事件锁机制、事件 Promise 化等。

适用于需要处理地图交互（点击、缩放、拖拽等）的场景。

---

## 事件绑定

### 1. 图层点击事件

```javascript
// event.js
export const addEventListenerClickToLayer = (layer, callback) => {
  dojo.connect(layer, "onClick", (...args) => {
    // 阻止事件冒泡
    args[0].stopPropagation();
    callback && typeof callback === "function" && callback(...args);
  });
};
```

**使用示例：**

```javascript
// 绑定图层点击事件
addEventListenerClickToLayer(layer, (event) => {
  console.log("点击位置:", event.mapPoint);
  console.log("点击的要素:", event.graphic);
});
```

### 2. 地图事件绑定

```javascript
export const onMapEvent = (map, eventName, callback) => {
  dojo.connect(map, eventName, (...args) => {
    callback && typeof callback === "function" && callback(...args);
  });
};
```

**使用示例：**

```javascript
// 绑定多个地图事件
onMapEvent(map, "onClick", handleMapClick);
onMapEvent(map, "onLoad", handleMapLoad);
onMapEvent(map, "onMouseWheel", handleMouseWheel);
```

### 3. 事件 Promise 化

```javascript
export const onMapEventPromise = (map, eventName) => {
  return new Promise(resolve => {
    dojo.connect(map, eventName, (...args) => {
      resolve(...args);
    });
  });
};
```

**使用示例：**

```javascript
// 等待地图加载完成
async function waitMapLoad(map) {
  const event = await onMapEventPromise(map, "onLoad");
  console.log("地图加载完成");
  return event;
}

// 在初始化中使用
onMounted(async () => {
  await waitMapLoad(map);
  // 地图加载完成后的操作
});
```

---

## 常用地图事件

### 1. 点击事件

```javascript
// 地图点击
onMapEvent(map, "onClick", (event) => {
  console.log("点击坐标:", event.mapPoint.x, event.mapPoint.y);
  console.log("点击的要素:", event.graphic);
});

// 图层点击
addEventListenerClickToLayer(layer, (event) => {
  console.log("图层点击:", event.graphic.attributes);
});
```

### 2. 加载事件

```javascript
// 地图加载完成
onMapEvent(map, "onLoad", (map) => {
  console.log("地图已加载");
  console.log("图层数量:", map.graphicsLayerIds.length);
});

// 地图加载错误
onMapEvent(map, "onError", (error) => {
  console.error("地图加载失败:", error);
});
```

### 3. 缩放事件

```javascript
// 缩放开始
onMapEvent(map, "onZoomStart", (factor, level) => {
  console.log("开始缩放:", factor, level);
});

// 缩放结束
onMapEvent(map, "onZoomEnd", (factor, level) => {
  console.log("缩放结束:", factor, level);
});
```

### 4. 拖拽事件

```javascript
// 拖拽开始
onMapEvent(map, "onPanStart", () => {
  console.log("开始拖拽");
});

// 拖拽结束
onMapEvent(map, "onPanEnd", () => {
  console.log("拖拽结束");
});
```

### 5. 鼠标事件

```javascript
// 鼠标滚轮
onMapEvent(map, "onMouseWheel", (event) => {
  console.log("滚轮滚动:", event);
});

// 鼠标移入
onMapEvent(map, "onMouseOver", (event) => {
  console.log("鼠标移入:", event.mapPoint);
});

// 鼠标移出
onMapEvent(map, "onMouseOut", (event) => {
  console.log("鼠标移出");
});
```

---

## 事件锁机制

### 1. 防抖锁

```javascript
const mapLock = ref(false);

function handleMapClick(event) {
  // 检查是否锁定
  if (mapLock.value) {
    mapLock.value = false;
    return;
  }

  // 处理点击
  processClick(event);
}
```

### 2. 蒙层点击锁

```javascript
// 蒙层绑定点击锁
function bindMaskOutlineLayerEvent() {
  dojo.connect(maskLayer, "onClick", () => {
    // 点击蒙层时锁定地图点击
    mapLock.value = true;
  });
}
```

**完整示例：**

```javascript
const mapLock = ref(false);

// 绑定地图点击
onMapEvent(map, "onClick", (event) => {
  if (mapLock.value) {
    mapLock.value = false;
    return;
  }
  $emit("click-map", event);
});

// 绑定蒙层
addMaskOutlineLayer();

function bindMaskOutlineLayerEvent() {
  dojo.connect(maskLayer, "onClick", () => {
    mapLock.value = true;
  });
}
```

---

## 事件管理

### 1. 事件监听封装

```javascript
import { onMapEvent, addEventListenerClickToLayer } from "@/assets/js/arcgis-api/event";

class MapEventManager {
  constructor(map) {
    this.map = map;
    this.handlers = [];
  }

  // 添加事件监听
  add(eventName, callback) {
    onMapEvent(this.map, eventName, callback);
    this.handlers.push({ eventName, callback });
  }

  // 移除所有事件
  removeAll() {
    this.handlers.forEach(({ eventName, callback }) => {
      // 注意：dojo.connect 返回的 handle 需要保存才能移除
    });
  }
}
```

### 2. 事件防抖

```javascript
import { onMapEvent } from "@/assets/js/arcgis-api/event";

function debounceEvent(map, eventName, callback, delay = 300) {
  let timer = null;

  onMapEvent(map, eventName, (...args) => {
    if (timer) clearTimeout(timer);
    timer = setTimeout(() => {
      callback(...args);
    }, delay);
  });
}

// 使用
debounceEvent(map, "onClick", handleClick, 500);
```

---

## 事件对象

### 1. 地图点击事件对象

```javascript
{
  // 坐标信息
  mapPoint: {
    x: 116.397,  // 经度
    y: 39.908,    // 纬度
    spatialReference: { wkid: 4326 }
  },

  // 屏幕坐标
  screenPoint: {
    x: 100,
    y: 200
  },

  // 点击的要素（如果有）
  graphic: {
    geometry: {...},
    attributes: {...},
    symbol: {...}
  },

  // 原生事件
  nativeEvent: {...}
}
```

### 2. 要素事件对象

```javascript
{
  // 要素信息
  graphic: {...},

  // 要素图形
  geometry: {
    type: "point",  // 或 "polygon", "polyline"
    rings: [...],   // 面要素坐标环
    x: 116.397,     // 点要素经度
    y: 39.908       // 点要素纬度
  },

  // 要素属性
  attributes: {
    id: 1,
    name: "地块A",
    area: 123.45
  }
}
```

---

## 常见问题

### 1. 事件重复绑定

```
问题：事件被多次绑定

原因：
- 在组件更新时重复绑定
- 没有在 unmount 时解绑

解决：
- 在 onMounted 绑定
- 在 onUnmounted 解绑
- 使用 handle 判断是否已绑定
```

### 2. 事件不触发

```
问题：点击图层没有反应

原因：
- 图层未添加到地图
- 事件绑定顺序错误
- 事件被阻止冒泡

解决：
1. 确保 layer.addTo(map) 已执行
2. 检查事件绑定在 addTo 之后
3. 检查 stopPropagation() 调用
```

### 3. 事件与蒙层冲突

```
问题：点击地图但被蒙层阻挡

原因：
- 蒙层在最上层
- 蒙层没有正确处理点击

解决：
使用事件锁机制
在蒙层点击时锁定地图事件
```

---

## 最佳实践

### 1. 统一事件管理

```javascript
// hooks/useMapEvents.js
import { onMapEvent, onMapEventPromise } from "@/assets/js/arcgis-api/event";

export function useMapEvents(map, emit) {
  // 统一绑定事件
  const bindEvents = () => {
    onMapEvent(map, "onClick", (event) => {
      emit("click-map", event);
    });

    onMapEvent(map, "onLoad", (event) => {
      emit("map-load", event);
    });

    onMapEvent(map, "onMouseWheel", (event) => {
      emit("map-mouse-wheel", event);
    });
  };

  return { bindEvents };
}
```

### 2. 事件 Promise 化

```javascript
// 等待地图就绪
async function waitMapReady(map) {
  if (map.loaded) {
    return map;
  }
  return await onMapEventPromise(map, "onLoad");
}

// 使用
const map = await waitMapReady(mapInstance);
console.log("地图已就绪");
```

---

## 相关模式

- [ArcGIS 地图初始化与天地图集成] - 基础地图配置
- [ArcGIS 图形渲染与符号系统] - 要素渲染
