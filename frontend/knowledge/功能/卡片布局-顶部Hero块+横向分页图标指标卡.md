---
title: "卡片布局 - 顶部 Hero 块 + 横向分页图标指标卡"
description: "GSPlate 顶部左侧图标头 + 标题/数值/单位 + 底部 el-carousel 自动分页 + 每页 3-4 列等宽图标指标卡（图标 + 名称 + 数值 + 单位）"
tags: ["gs板-card", "layout", "卡片布局", "el-carousel", "hero块", "横向分页", "三列图标指标", "GSPlate", "vue2"]
complexity: ⭐⭐
domain: feature
source_scope: ["BKMB101", "BKMB105", "BKMB106"]
---

# 卡片布局 - 顶部 Hero 块 + 横向分页图标指标卡

## 概述

**Hero 头 + 横向分页图标指标卡**是政务大屏、IoT 看板等场景的高频展示卡片模板：

- **顶部 Hero 块**：左侧 icon + 标题 + 总量数值 + 单位（可选）
- **底部主体**：`el-carousel` 横向自动分页（每页 3-4 列），每列展示一个 `图标 + 名称 + 数值 + 单位` 的指标小块
- **数据充足时**自动轮播；不足 1 页时隐藏箭头
- **`arrTrans(n, list)`**：把扁平列表按 `n` 个一组切片成 `[ [item, item, item], [item, item, item] ]`，正好填满 carousel 每一页

**适用场景**：

- 资源/资产统计（耕地、林地、水力、气象 等分类统计）
- 指标总量+明细列表（顶部总量+底部每类的子指标）
- 大屏 dark theme、deep blue/cyan 配色
- 单卡片内容超过 6 条但每行只能展示 3-4 条时

**关键特征**：

- ✅ 顶部 hero 头（icon + 标题 + value + unit），可选点击跳转
- ✅ 主体 `el-carousel height="100%" / "145px"` 横向翻页
- ✅ 每页用 `arrTrans(n, list)` 等宽切片成行
- ✅ `indicator-position="none"` 隐藏默认指示器（箭头 hover 才显示）
- ✅ `arrow: 'hover' | 'never'`——分页足够多才显示箭头
- ✅ `loop: false / autoplay: false` 或 `loop: true / autoplay: true` 自由切换
- ✅ BEM 命名：`.col-info` / `.col-info__pic` / `.col-info__value`

---

## 核心结构示意

```
┌──────────────────────────── GSPlate ────────────────────────────┐
│ ┌─── Hero 头 ────────────────────────────────────────────────┐ │
│ │  [icon]   标题              数值  单位                      │ │
│ └────────────────────────────────────────────────────────────┘ │
│ ┌─── el-carousel（height=145px, indicator=none）─────────────┐ │
│ │  ┌── 1 页 ─────────────────────────────┐                  │ │
│ │  │   icon   icon   icon   icon         │                  │ │
│ │  │   名称   名称   名称   名称         │                  │ │
│ │  │   数值   数值   数值   数值         │                  │ │
│ │  └─────────────────────────────────────┘                  │ │
│ │  ┌── 2 页 ─────────────────────────────┐                  │ │
│ │  │           ......                    │                  │ │
│ │  └─────────────────────────────────────┘                  │ │
│ └────────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────┘
```

> 每列占 `width: 33.33%`（4 列则 `25%`），`display: flex; flex-direction: column; align-items: center;`。

---

## 完整代码

### template

```vue
<GSPlate v-bind="$attrs">
  <div class="box-content full-box">
    <!-- 顶部 Hero 块：icon + 标题 + 数值 + 单位 -->
    <div class="content-des" v-if="!loading">
      <img v-if="icon" :src="icon" class="des-icon" alt="" />
      <div class="des-text">
        <span class="label">{{ title }}</span>
        <span class="value">{{ total }}<i class="unit"> {{ unit }} </i></span>
      </div>
    </div>

    <!-- 主体：el-carousel 横向分页 + 等宽多列指标 -->
    <div class="box" v-if="dataList.length">
      <el-carousel
        height="145px"
        :interval="4000"
        indicator-position="none"
        :arrow="arrow"
      >
        <el-carousel-item
          v-for="(itemList, index) in dataList"
          :key="index"
          class="col-info-wrap"
        >
          <div class="col-info" v-for="(item, idx) in itemList" :key="idx">
            <img
              class="col-info__pic"
              :src="item.plateIconUrl"
              :alt="item.metricName"
              v-if="item.plateIconUrl"
            />
            <p class="col-info__label">{{ item.metricName }}</p>
            <p class="col-info__value">
              {{ (item.metricValue || "") + (item.metricUnit || "") }}
            </p>
          </div>
        </el-carousel-item>
      </el-carousel>
    </div>
  </div>
</GSPlate>
```

### script

```js
import { arrTrans } from "@/utils/utils";

export default {
  name: "CardHeroCarousel",
  props: {
    plateVO: { type: Object, default: () => ({}) }
  },
  data() {
    return {
      title: "",
      total: null,
      unit: null,
      icon: "",
      dataList: [],
      loading: true
    };
  },
  computed: {
    arrow() {
      return this.dataList.length > 1 ? "hover" : "never";
    }
  },
  methods: {
    initModule() {
      try {
        const { plateMetricGroupList } = this.plateVO;
        const group = plateMetricGroupList[0] || {};
        this.title = group.metricGroupName;
        this.total = group.metricGroupValue;
        this.unit = group.metricGroupUnit;
        this.icon = group.plateIconUrl;
        const arrLen = 3; // 每页 3 列；4 列改 4
        this.dataList = arrTrans(arrLen, group.plateMetricList || []);
      } catch (e) {
        console.log(e);
      }
    }
  },
  watch: {
    "$attrs.loading": {
      immediate: true,
      handler(v) {
        if (!v) this.$nextTick(() => this.initModule());
      }
    }
  }
};
```

### style（scoped lang="scss"）

```scss
.box-content {
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  justify-content: space-around;
  font-size: 14px;
  color: #fff;

  .content-des {
    display: flex;
    align-items: center;
    padding: 0 10px;
    .des-icon { width: 26px; height: 26px; margin-right: 8px; }
    .des-text {
      display: flex;
      align-items: baseline;
      gap: 8px;
      .label { color: #acc5e2; }
      .value {
        color: #efde46;
        font-weight: bold;
        font-size: 22px;
        i.unit { font-size: 12px; font-weight: normal; font-style: normal; }
      }
    }
  }
}

.col-info-wrap {
  display: flex;
  box-sizing: border-box;
  padding: 0 15px;
  justify-content: center;
}
.col-info {
  width: 33.33%;          // 4 列改 25%
  display: flex;
  flex-direction: column;
  align-items: center;
  &__pic {
    width: 89px;
    height: 89px;
    display: block;
    margin-bottom: 10px;
  }
  &__label {
    font-size: 12px;
    line-height: 22px;
    text-align: center;
    color: #fff;
  }
  &__value {
    text-align: center;
    font-weight: bold;
    font-size: 14px;
    line-height: 24px;
    color: #00f6ff;
  }
}
```

---

## `arrTrans(n, list)` 切片工具

```js
// utils/utils.js
export function arrTrans(num, arr) {
  if (!arr || !arr.length) return [];
  const newArr = [];
  for (let i = 0; i < arr.length; i += num) {
    newArr.push(arr.slice(i, i + num));
  }
  return newArr;
}

// 示例
arrTrans(3, [a, b, c, d, e, f, g]); // [[a,b,c],[d,e,f],[g]] —— 3 列 3 行
```

---

## 关键设计要点

### 1. 顶部 Hero 头 可跳转

```vue
<div class="content-des" @click="goDetail" style="cursor: pointer;">
```

```js
methods: {
  goDetail() {
    this.$router.push({ name: 'TargetPageName' });
  }
}
```

### 2. 箭头与默认指示器

| 选项          | 推荐      | 说明                              |
| ----------- | ------- | ------------------------------- |
| `indicator-position` | `"none"` | 业务卡片不需要 Element 默认 dot |
| `arrow`     | `"hover"` | 仅多页时 hover 显示左右箭头；`"always" / "never"` 按需 |
| `loop`      | `false` | 数据分页独立翻，看个人选项                          |
| `autoplay`  | `false` | 避免用户阅读时跳动                          |
| `interval`  | `4000`  | `autoplay: true` 时生效                  |

### 3. 数量不足 1 页

`arrow` 计算属性使 `dataList.length <= 1` 时不显示箭头——天然降级。

### 4. 适配 4 列 / 5 列

只需改两处：

```js
const arrLen = 4; // 每页 4 列
```

```scss
.col-info { width: 25%; }  // 5 列则 20%
```

### 5. 图标来源

优先使用每条指标的 `item.plateIconUrl`（业务数据自带），缺图时回退 `require("@/assets/...")` 占位。

---

## 变体

| 变体         | 差异                                            |
| ---------- | --------------------------------------------- |
| 顶部不显示图标   | 删 `.des-icon`，仅保留标题文本                              |
| 标题多行省略    | `:title="title"` + `text-overflow: ellipsis`     |
| 点击 hero 跳转 | @click + router.push                            |
| 单元底色       | `.col-info` 加 `background: rgba(255,255,255,.04)` 圆角卡片 |
| 数字递增       | 嵌入 `<count-to>` 替代 `{{ value }}`（见 count-to 主题）|

---

## 适用 vs 不适用

**适用**

- 单一类型指标分类统计
- 6-30 条数据（1-5 页）
- 强调视觉图标 + 文字标签 + 数值组合

**不适用**

- 多种异构数据混合（用 list 列表更合适）
- 数据少于 3 条（直接并排展示，无需 carousel）
- 每条数据需要详情面板（应改用 router-link 列表项）

---

## 源文件

- `D:\sn-project\frp_gov_web\src\components\GovScreen\GSTemp\src\BKMB101.vue`
- `D:\sn-project\frp_gov_web\src\components\GovScreen\GSTemp\src\BKMB105.vue`
- `D:\sn-project\frp_gov_web\src\components\GovScreen\GSTemp\src\BKMB106.vue`

`GSPlate` 是项目内的卡片外壳组件，负责标题栏 / 角标 / loading 状态接管（通过 `$attrs.loading`），所有 BKMB 组件统一使用。

---

*最后更新: 2026-09-16*
