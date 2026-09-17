# ECharts-4.9-2D饼图+图例数据列表

## 模板名称
ECharts 4.9 · 2D 饼图卡片（左饼 + 右多色图例数据列表）

## 库名与版本
- **echarts**: `4.9.0`
- **依赖子组件**:
  - `@/components/echarts/echartsPie`（饼图封装，接收 `echartData: { statusNone, unit, data, color }`，slots: title / num）
  - `@/components/jy/pieText`（图例列表项，props: isLineFeed / bgColor / unit / index / textData）

## 应用场景
大屏卡片，需要"中心饼图 + 多个图例数据行"的复合展示。
- 左侧饼图（占 45% 宽度）：echartsPie，子组件内完成初始化 + label + tooltip
- 右侧图例数据列表：6 个明细项，按 `name / value / unit` + 配套色块显示
- 顶部主指标：通过 `echartsPie` 的 `slot="title"` 与 `slot="num"` 注入

## 标签
```yaml
tags:
  - echarts
  - echarts-4.9
  - 2D饼图
  - 饼图+图例
  - echartsPie
  - pieText
  - 多色图例
  - 复合布局
  - slot注入
  - slot-title
  - slot-num
  - 占比可视化
  - vue2
```

## 来源
- source_scope: ["BKMB108"]
- source_project: frp_gov_web (D:\sn-project\frp_gov_web)
- source_path: src/components/GovScreen/GSTemp/src/BKMB108.vue

## 关键代码骨架

### template
```vue
<GSPlate v-bind="$attrs">
  <div class="box-content full-box">
    <!-- 左侧饼图：通过 slot 注入 title/num -->
    <echarts-pie
      class="echarts-warp"
      ref="pieCategory"
      refName="pieCategory"
      :echartData="pieCategoryData"
    >
      <template slot="title">{{ title }}</template>
      <template slot="num">
        {{ categoryTotal }}<span class="unit">{{ pieCategoryData.unit }}</span>
      </template>
    </echarts-pie>

    <!-- 右侧图例数据列表 -->
    <div class="pie-text-list">
      <div
        v-for="(item, index) in pieCategoryData.data"
        :key="index"
        class="pie-text-item"
      >
        <pieText
          :isLineFeed="true"
          :bgColor="pieCategoryData.color"
          :unit="item.unit"
          :index="index"
          :textData="item"
        />
      </div>
    </div>
  </div>
</GSPlate>
```

### script
```js
import { mapGetters } from "vuex";
import echartsPie from "@/components/echarts/echartsPie";
import pieText from "@/components/jy/pieText";

export default {
  name: "BKMB108",
  components: { echartsPie, pieText },
  props: { plateVO: { type: Object, default: () => ({}) } },
  data() {
    return {
      categoryTotal: null,
      title: "",
      pieCategoryData: {
        statusNone: false,           // 子组件用来切换"暂无数据"占位
        unit: "家",
        data: [],
        color: [                     // 10 色调色板（按 index 取）
          "#3ce1a3", "#31abe4", "#ccc166", "#646cc8", "#c97f63",
          "#7a5fa8", "#85c963", "#d25e9d", "#997a0e", "#2732b2"
        ]
      }
    };
  },
  computed: { ...mapGetters("account", ["subjectAreaId"]) },

  methods: {
    initModule() {
      try {
        const { plateMetricGroupList } = this.plateVO;
        const plateMetricList = plateMetricGroupList[0]?.plateMetricList || [];

        // 主指标 = 总值 + 标签 + 单位
        this.categoryTotal = plateMetricGroupList[0].metricGroupValue || 0;
        this.title = plateMetricGroupList[0].metricGroupName;
        this.pieCategoryData.unit = plateMetricGroupList[0]?.metricGroupUnit || "";

        // 饼图 + 图例数据 = 明细数组
        this.pieCategoryData.data = plateMetricList
          .map(ele => ({
            name: ele.metricName,
            value: ele.metricValue,
            unit: ele.metricUnit
          }))
          ?.slice(0, 6);          // 列表最多 6 项
      } catch (e) {
        console.log(e);
      }
      this.$nextTick();
      this.$refs.pieCategory.initModule();   // 手动调用子组件初始化
    }
  },
  watch: {
    "$attrs.loading": {
      immediate: true,
      handler(newVal) {
        if (!newVal) this.$nextTick(() => this.initModule());
      }
    }
  }
};
```

### style
```scss
.box-content {
  position: relative;
  overflow: hidden;
  .echarts-warp {
    position: relative;
    z-index: 3;
    width: 45%;             // 左饼占 45% 宽度
    display: flex;
    align-items: center;
    flex-shrink: 0;
    height: 95%;
    ::v-deep {
      .square-container { transform: translateY(-50%); }
    }
  }
  .pie-text-list {
    position: absolute;
    width: 100%; height: 100%;
    top: 0; left: 0;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    .pie-text-item {
      &:nth-child(2n-1) {            // 奇数项（细分行）
        padding-left: 15px;
        width: 60%;
        ::v-deep .pie-text-wrapper { width: 50%; }
      }
      &:nth-child(2n) {              // 偶数项（粗体行）
        padding-right: 15px;
        width: 24%;
        ::v-deep .pie-text-wrapper { width: 100%; }
      }
    }
  }
}
```

## 关键设计点

### 1. 数据结构传递契约
**重要：传给 `echartsPie` 的 `echartData` 是一个对象**，包含：
```js
{
  statusNone: false,
  unit: "家",
  data: [{ name, value, unit }, ...],
  color: ["#3ce1a3", "#31abe4", ...]
}
```
- `data` 同时驱动饼图扇区 **和** 右侧图例列表（避免数据分散）
- `color` 同时被 pie / list 引用（保持色相一致）

### 2. slot 注入主指标
```vue
<template slot="title">{{ title }}</template>
<template slot="num">{{ categoryTotal }}<span class="unit">{{ pieCategoryData.unit }}</span></template>
```
子组件 `echartsPie` 在饼图中心镂空区放置这两个 slot，由父组件自由注入。

### 3. 调色板一次性放 10 色
调色板在 `data()` 中固定写死 10 项。`echartsPie` 内部按 series index 取色，超过 10 项会重复。`pieText` 通过 `bgColor` 拿到同一调色板按 `index` 取色，保证图例色块与饼图扇区完全对应。

### 4. 奇偶双列布局（pie-text-list）
- 奇数项（`:nth-child(2n-1)`）：占 60% 宽度、内部 wrapper 50%（左侧留白给饼图占位）
- 偶数项（`:nth-child(2n)`）：占 24% 宽度、全宽显示
- `position: absolute` + `flex-wrap: wrap`，让它覆盖在 `echarts-warp` 之上，但被 `z-index: 3` 区分层级
- 这一布局是项目特有"双侧错位"图例样式

### 5. 手动触发子组件初始化
```js
this.$refs.pieCategory.initModule();
```
`echartsPie` 子组件暴露 `initModule` 方法，但需要等父组件 `pieCategoryData` 准备好再调用。`this.$nextTick()` 保证子组件已挂载 + 数据已绑定。

### 6. 颜色随 index 走
`pieText` 接收 `bgColor` + `index`，按 `bgColor[index]` 取色。这种"父传色板 + 子按 index 取"的模式在大屏项目里非常常见。

## 与已有知识库的差异
- 现有知识库：纯 ECharts 图表，无"饼图 + 文字图例列表"复合组件
- 与 `ECharts-4.9-3D饼图卡片.md` 的核心区别：
  - 本模板用 **2D** 饼图（`echartsPie`） + **文字图例**（`pieText`）
  - 3D 模板用 **Pie3D01** 立体饼图，无独立图例
- 与 `卡片布局-顶部Hero块+横向分页图标指标卡.md` 的区别：那个是分页图标指标，不是带色块的图例

## 子组件契约（最小实现参考）
若项目里没有 `echartsPie` / `pieText`，落地最少需要：
```js
// echartsPie 接受 echartData，内部初始化饼图，渲染 slot
// pieText 接受 bgColor/unit/index/textData，渲染一行色块 + 名称 + 数字
```
具体样式按品牌系统调整。

## 适配建议
- 改主题色：替换 `pieCategoryData.color` 数组
- 改图例列数：修改 `.slice(0, 6)` 与 CSS `nth-child` 行高匹配
- 不想要错位效果：把 `.pie-text-list .pie-text-item:nth-child(2n-1)` 和 `:nth-child(2n)` 改为统一宽度
