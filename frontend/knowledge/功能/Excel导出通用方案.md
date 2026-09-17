---
title: "Excel 导出通用方案"
description: "基于 XMLHttpRequest + Blob 的通用文件下载方案，支持大文件、分页导出"
tags: ["excel", "导出", "下载", "blob", "xhr"]
complexity: ⭐⭐
domain: feature
---

# Excel 导出通用方案

## 概述

本知识介绍一种通用的文件导出方案，适用于：

- Excel 导出
- CSV 导出
- 大文件下载
- 分页数据导出

核心特点：支持大文件、兼容 IE 浏览器、自动命名。

---

## 核心实现

### 1. 通用文件下载函数

```javascript
/**
 * @description 通用文件下载函数
 * @param {string} ajaxUrl 请求接口
 * @param {object} data JSON传参
 * @param {string} filename 保存的文件名（不含扩展名）
 * @param {string} [tips] 数据size为0时的toast语句
 */
function d2file(ajaxUrl, data, filename, tips) {
  var xhr;

  // 兼容IE浏览器
  if (window.XMLHttpRequest) {
    xhr = new XMLHttpRequest();
  } else {
    xhr = new ActiveXObject('Microsoft.XMLHTTP');
  }

  xhr.open('POST', ajaxUrl, true);

  // 设置请求头
  xhr.setRequestHeader('Content-type', 'application/json');
  xhr.setRequestHeader('accessToken', localStorage.getItem('ACCESSTOKEN'));

  // 关键：指定返回数据类型为二进制
  xhr.responseType = 'blob';

  xhr.onload = function () {
    if (this.status === 200 && this.readyState == 4) {
      var blob = this.response;

      // 检查文件大小
      if (blob.size > 0) {
        // IE浏览器特殊处理
        if (window.navigator.msSaveOrOpenBlob) {
          navigator.msSaveBlob(blob, filename + '.xls');
        } else {
          // 现代浏览器
          var reader = new FileReader();
          // 转换为base64，可以直接放入a标签href
          reader.readAsDataURL(blob);
          reader.onload = function (e) {
            // 转换完成，创建一个a标签用于下载
            var a = document.createElement('a');
            a.download = filename + '.xls';
            a.href = e.target.result;
            $('body').append(a);
            a.click();
            // 修复firefox中无法触发click
            $(a).remove();
          };
        }
      } else {
        // 文件为空时的处理
        if (tips) {
          layer.msg(tips, { time: 2000, skin: 'msgCss' });
        } else {
          layer.msg('文件大小为0kb', { time: 2000, skin: 'msgCss' });
        }
        return false;
      }
    }
  };

  xhr.send(JSON.stringify(data));
}
```

---

## 使用方式

### 1. 基础使用

```javascript
var data = {
  companyId: 'xxx',
  farmId: 'yyy',
  pageNo: 1,
  pageSize: 10000,
};

var filename = '农事记录（' + dayactive + '）';

d2file(urlFarmworkExport, data, filename);
```

### 2. 带提示语

```javascript
d2file(
  urlFarmworkExport,
  data,
  filename,
  '没有可导出的数据'  // 自定义提示
);
```

### 3. 批量导出

```javascript
// 导出种植记录
exportExcelBatchPlan() {
  var data = {
    companyId: this.companyId,
    farmId: this.farmId,
    // ... 其他参数
  };
  d2file(urlPlanExport, data, '种植记录');
}

// 导出农事记录
exportExcelBatchFarmwork() {
  var data = {
    companyId: this.companyId,
    currentDate: this.dayactive,
    farmId: this.farmId,
    keywords: this.keywords,
    pageNo: 1,
    pageSize: 10000,
  };
  var filename = '全部订单（配送日期：' + dayactive + '）';
  d2file(urlOrderExport, data, filename);
}
```

---

## 分页导出策略

### 1. 分页获取数据

```javascript
async function exportLargeData(apiUrl, queryParams, filename) {
  const pageSize = 10000;
  let pageNo = 1;
  let allData = [];
  let hasMore = true;

  // 分页获取数据
  while (hasMore) {
    const result = await fetchData(apiUrl, {
      ...queryParams,
      pageNo,
      pageSize,
    });

    allData = allData.concat(result.data);
    hasMore = result.data.length === pageSize;
    pageNo++;
  }

  // 导出
  exportToExcel(allData, filename);
}
```

### 2. 服务端分页

```javascript
// 告诉服务端一次性导出所有数据
var data = {
  companyId: 'xxx',
  pageNo: 1,
  pageSize: 100000,  // 服务端最大支持数
};

d2file(urlExport, data, '导出文件名');
```

---

## Blob 下载原理

### 1. 为什么使用 Blob

```
传统方式：
1. 服务端返回文件流
2. 浏览器直接下载
3. 无法自定义文件名

Blob方式：
1. 服务端返回二进制数据
2. 客户端接收为 Blob 对象
3. 使用 FileReader 读取为 DataURL
4. 创建隐藏 <a> 标签触发下载
5. 可以自定义文件名
```

### 2. DataURL 格式

```
data:[<mediatype>][;base64],<data>

示例：
data:application/vnd.ms-excel;base64,ABCDEFGHIJKLMNOPQRSTUVWXYZ...
```

### 3. 下载流程图

```
┌─────────────────┐
│  发送 POST 请求   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  设置 responseType │ = 'blob'
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  接收二进制数据   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  FileReader      │ readAsDataURL
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  创建 <a> 标签   │
│  设置 href       │
│  设置 download   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  a.click()      │
│  触发下载        │
└─────────────────┘
```

---

## 常见问题

### 1. 文件名乱码

```
问题：下载的文件名乱码

原因：编码问题

解决：确保后端返回正确的编码
确保文件名不包含特殊字符
```

### 2. IE 浏览器兼容

```
问题：IE 浏览器无法下载

解决：使用 msSaveBlob 方法
if (window.navigator.msSaveOrOpenBlob) {
  navigator.msSaveBlob(blob, filename + '.xls');
}
```

### 3. 大文件下载失败

```
问题：大文件下载时超时或失败

解决：
1. 增加请求超时时间
2. 服务端开启分页
3. 使用流式下载
```

### 4. 文件损坏

```
问题：下载的 Excel 文件损坏

排查：
1. 检查 responseType 是否正确
2. 检查 Content-Type 是否匹配
3. 检查文件是否被压缩

解决：
xhr.responseType = 'blob';
xhr.setRequestHeader('Content-Type', 'application/json');
```

---

## 安全考虑

### 1. Token 认证

```javascript
xhr.setRequestHeader('accessToken', localStorage.getItem('ACCESSTOKEN'));
```

### 2. 请求参数加密

```javascript
var data = {
  companyId: encrypt(companyId),
  farmId: encrypt(farmId),
  // ...
};
```

### 3. 防止 XSS

```javascript
// 清理文件名
filename = filename.replace(/[<>:"/\\|?*]/g, '');
filename = filename.substring(0, 100);  // 限制长度
```

---

## 相关模式

- [Vue 批量操作组件] - 批量选择和导出结合
- [表单验证模式] - 导出前数据校验
