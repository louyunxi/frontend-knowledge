# ECharts-4.9-3D饼图卡片（顶部主指标 + 3D饼图子组件）

## 模板名称
ECharts 4.9 · 3D 饼图卡片（顶部 label/value/unit 主指标 + 下方立体饼图）

## 库名与版本
- **echarts**: `4.9.0`
- **依赖子组件**: `@/components/echarts/Pie3D01`（项目内部基于 echarts-graph + echarts-liquidfill 封装的 3D 饼图）
  - 不需要本模板手动 `init`，传 `option-data` 即可

## 应用场景
大屏卡片，需要"一个总数 + 几个占比分布"的场景。比 2D 饼图更有视觉冲击力，常用于：
- 资源类型 / 资产类型分布
- 行业 / 领域占比
- 主体 / 类型构成

布局固定为：上面一行主指标文字 (label / value / unit)，下面整块 3D 饼图。

## 标签
```yaml
tags:
  - echarts
  - echarts-4.9
  - 3D饼图
  - Pie3D01
  - 主指标头部
  - 占比可视化
  - 立体饼图
  - 组合指标+饼图
  - vue2
```

## 来源
- source_scope: ["BKMB104"]
- source_project: frp_gov_web (D:\sn-project\frp_gov_web)
- source_path: src/components/GovScreen/GSTemp/src/BKMB104.vue

## 关键代码骨架

### template
```vue
<GSPlate v-bind="$attrs">
  <div class="box-content full-box">
    <!-- 顶部主指标：label / value / unit -->
    <div class="content-des">
      <p class="content-des__label">{{ title }}</p>
      <p class="content-des__value">{{ totalCount }}</p>
      <p class="content-des__unit">{{ unit }}</p>
    </div>
    <!-- 下方饼图（占满剩余高度，从 top: 33px 起） -->
    <div class="box-content__chart full-box" v-if="hasData && optionData.length">
      <Pie3D01 :option-data="optionData" />
    </div>
  </div>
</GSPlate>
```

### script
```js
import Pie3D01 from "@/components/echarts/Pie3D01";

export default {
  name: "BKMB104",
  components: { Pie3D01 },
  props: { plateVO: { type: Object, default: () => ({}) } },
  data() {
    return {
      totalCount: null,   // 主指标 - 数值
      optionData: [],     // 饼图 - 切片数据
      hasData: false,     // 是否有数据，决定渲染
      title: "",          // 主指标 - 标签
      unit: ""            // 主指标 - 单位
    };
  },
  methods: {
    async initModule() {
      try {
        const { plateMetricGroupList } = this.plateVO;

        // 主指标 = 第一个分组的总值
        this.totalCount = plateMetricGroupList[0]?.metricGroupValue;

        const plateMetricList = plateMetricGroupList[0]?.plateMetricList || [];

        this.title = plateMetricGroupList[0]?.metricGroupName || "";
        this.unit = plateMetricGroupList[0]?.metricGroupUnit || "";

        // 饼图数据 = 第一个分组下的所有指标项（name / value / unit）
        const data = plateMetricList.map(item => ({
          name: item.metricName,
          value: Number(item.metricValue),
          unit: item.metricUnit || ""
        }));

        this.$set(this, "optionData", data);
        this.hasData = true;
      } catch (e) {
        console.log(e);
      }
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
  &__chart {
    position: absolute;
    top: 33px;       // 顶部主指标行高度约 33px，下方饼图紧接其下
  }
}
.content-des {
  display: flex;
  justify-content: center;
  align-items: flex-end;
  margin-top: 20px;
  &__label { font-size: 16px; color: #9dd1d7; margin-right: 20px; }
  &__value { font-size: 30px; color: #efde46; font-weight: bold; }
  &__unit  { font-size: 14px; color: #efde46; }
}
```

## 关键设计点

### 1. 数据结构两段式
- 主指标 = `plateMetricGroupList[0].metricGroupValue`（整个分组的总值）
- 饼图数据 = `plateMetricGroupList[0].plateMetricList[]`（分组下所有明细）

这种"上层 summary + 下层 detail"是该项目 BKMB 模板里常见模式：①一个总览数字 ②一个分布图。

### 2. Pie3D01 子组件
不直接调用 `this.$echarts.init()`，而是封装在 `Pie3D01` 里：
```vue
<Pie3D01 :option-data="optionData" />
```
约定接口：`option-data` 是 `[{ name, value, unit }, ...]` 数组。3D 渲染、颜色、悬浮动效全部由 `Pie3D01` 内部处理。
**优势**：项目不同卡片复用同一个 3D 饼图实现，避免重复 init；视觉一致。

### 3. `$set` 触发响应式
```js
this.$set(this, "optionData", data);
```
因为 `optionData` 在 `data()` 中已声明，用 `this.optionData = data` 直接赋值也能触发响应式，但 `this.$set` 更显式地表达"这是首次填充"。Vue 2 推荐用法。

### 4. 渲染保护
```vue
v-if="hasData && optionData.length"
```
空数据时不渲染 Pie3D01，避免空饼图异常。

### 5. 高度布局
- 顶部主指标行：margin-top: 20px + 字体高度 ≈ 33px
- 下方饼图：`position: absolute; top: 33px; height: 100%` 占剩余空间

这样主指标始终悬浮在卡片顶部，下方饼图伸缩自如。

### 6. 颜色与单位从原始数据派生
饼图每条数据都附加 `unit` 字段（虽然 Pie3D01 当前不一定显示）。可在它的子组件里扩展悬浮窗显示 `${name}: ${value} ${unit}`。

## 与已有知识库的差异
- 现有 `ECharts-2D-三层环饼图.md` / `ECharts-2D-双层环饼图.md` 等均为 2D、多层嵌套环
- 本模板为 **3D 立体饼图**，通过 `Pie3D01` 子组件实现，是项目独有技术选型
- 也区别于 `ECharts-4.9-2D饼图+图例数据列表.md`（后者是 2D + 配套文字列表）

## 变体
- **纯数据展示**：去掉 `.content-des`，让 `Pie3D01` 占满整个卡片
- **多个分组切换**：把 `plateMetricGroupList[0]` 换成 `selectedGroup`，加顶部分组 tab
- **改 2D 普通饼图**：把 `<Pie3D01>` 换成 echarts `series: [{ type: 'pie' }]`

## 适配建议
- 子组件 `Pie3D01` 必须存在于 `@/components/echarts/Pie3D01`；若缺失需先实现或寻找替代品
- 主指标的 `value / unit` 颜色（默认金黄 `#efde46`）可按品牌替换
- 字号体系被硬编码（16 / 30 / 14），如要全卡片统一，需引入 CSS 变量
