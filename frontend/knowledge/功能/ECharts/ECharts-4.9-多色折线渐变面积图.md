# ECharts-4.9-多色折线渐变面积图

## 模板名称
ECharts 4.9 · 多色平滑折线 + 渐变面积 + 图例 + 配套 tooltip

## 库名与版本
- **echarts**: `4.9.0`
- 初始化方式：`this.$echarts.init(el)`

## 应用场景
大屏卡片，**多组时间序列数据并列**显示（如多个月份 / 多类指标的趋势对比）。每条线：
- 单独一种主色（`lineColor`）
- 线下面积从主色 40% 透明度渐变到 0% 透明度（自然下沉到背景）
- 圆点 marker (`symbol: 'circle'`)
- 平滑曲线 (`smooth: true`)
- 图例同步显示 series 名和颜色

## 标签
```yaml
tags:
  - echarts
  - echarts-4.9
  - 折线图
  - 多色折线
  - 平滑曲线
  - 渐变面积
  - linearGradient
  - smooth
  - legend
  - 颜色模板
  - vue2
```

## 来源
- source_scope: ["BKMB120", "BKMB127"]
- source_project: frp_gov_web (D:\sn-project\frp_gov_web)
- source_path: src/components/GovScreen/GSTemp/src/BKMB120.vue

## 关键代码骨架

### template
```vue
<GSPlate v-bind="$attrs">
  <div class="module-wrap full-box">
    <div class="echart-container" ref="EContainer"></div>
  </div>
</GSPlate>
```

### script（颜色模板表 + lineOption + 多 series 生成）
```js
import { debounce } from "@/utils/utils";

// ========= 颜色模板表：每条 series 三个色 =========
const colorList = [
  {
    lineColor: "#00F6FF",
    lineInitiateColor: "rgba(0,246,255,0.4)",
    lineStopColor: "rgba(0,246,255,0)"
  },
  {
    lineColor: "#F5B03D",
    lineInitiateColor: "rgba(245,176,61,0.4)",
    lineStopColor: "rgba(245,176,61,0)"
  },
  {
    lineColor: "#62C37C",
    lineInitiateColor: "rgba(98,195,124,0.4)",
    lineStopColor: "rgba(98,195,124,0)"
  },
  {
    lineColor: "#911EEC",
    lineInitiateColor: "rgba(145,30,236,0.4)",
    lineStopColor: "rgba(145,30,236,0)"
  }
];

// ========= 底部常驻 option =========
const lineOption = {
  title: {
    show: false,
    text: "暂无数据",
    textStyle: { fontSize: 16, color: "#6DC1CB" },
    left: "center", top: "center"
  },
  legend: {
    show: true,
    width: "80%",
    top: 6, right: 10,
    textStyle: {
      fontSize: 12, lineHeight: 12,
      padding: [0, 0, -5, 0],
      color: "#FFFFFF7F",
      fontWeight: 800,
      fontFamily: "Microsoft YaHei"
    },
    icon: "circle",
    itemHeight: 6, itemWidth: 10
  },
  grid: { show: true, borderColor: "#072D4A", top: 38, right: 30, bottom: 35, left: 60 },
  tooltip: {
    show: true,
    trigger: "axis",
    backgroundColor: "#042940",
    padding: [13, 14, 13, 11],
    textStyle: { fontSize: 12, color: "#9ED2D8" },
    formatter: params => {
      let relVal = params[0].name;
      for (let i = 0, l = params.length; i < l; i++) {
        const value = params[i].data.isHas ? params[i].value : "--";
        relVal = relVal + "<br/>" + params[i].seriesName + "：" + value + params[i].data.unit;
      }
      return relVal;
    }
  },
  xAxis: {
    data: [],
    boundaryGap: false,                      // 折线图必须为 false
    axisLabel: {
      padding: [5, 5, 0, 0],
      hideOverlap: true, interval: 0, inside: false,
      textStyle: {
        fontSize: 12,
        color: "rgba(255, 255, 255, 0.5)",
        fontWeight: 800,
        fontFamily: "Microsoft YaHei"
      },
      align: "center"
    },
    axisTick: { show: false },
    axisLine: { show: true, lineStyle: { color: "rgba(109, 193, 203, 0.2)" } },
    z: 10                                    // grid 上层，避免被线遮
  },
  yAxis: {},
  series: []
};

export default {
  name: "BKMB120",
  props: { plateVO: { type: Object, default: () => ({}) } },
  computed: {
    eContainerRef() { return this.$refs.EContainer; }
  },
  data() { return { chartInstance: null }; },
  methods: {
    initModule() {
      this.chartInstance = this._initEcharts(this.eContainerRef, lineOption);
      this.refreshChart();
      window.addEventListener("resize", this.resizeChart, false);
      this.$once("hook:beforeDestroy", () => {
        window.removeEventListener("resize", this.resizeChart, false);
      });
    },
    _initEcharts(el, option) {
      const chart = this.$echarts.init(el);
      chart.setOption(option);
      return chart;
    },
    resizeChart() { debounce(() => this.chartInstance.resize(), 200)(); },
    refreshChart() {
      const { plateMetricGroupList } = this.plateVO;
      const unit = plateMetricGroupList[0].metricGroupUnit;
      const groupOneInfo = plateMetricGroupList[0]?.plateMetricList.length
        ? plateMetricGroupList[0].plateMetricList
        : [];
      const xAxisDate = groupOneInfo.map(item => item.metricName);

      // ========== 多 series 生成（核心） ==========
      const list = plateMetricGroupList.slice(0, 4).map((item, index) => ({
        name: item.metricGroupName,
        data: item.plateMetricList.length
          ? item.plateMetricList.map(t => ({
              unit: t.metricUnit ? t.metricUnit : "",
              isHas: t.metricValue ? true : false,
              value: Number(t.metricValue) ? t.metricValue : 0
            }))
          : [],
        itemStyle: { borderColor: colorList[index].lineColor },
        symbol: "circle",
        symbolSize: 2,
        color: colorList[index].lineColor,
        type: "line",
        smooth: true,
        areaStyle: {
          color: {
            type: "linear",
            x: 0, y: 0, x2: 0, y2: 1,        // 上→下 渐变
            colorStops: [
              { offset: 0, color: colorList[index].lineInitiateColor }, // 0%: 40% 主色
              { offset: 1, color: colorList[index].lineStopColor }     // 100%: 0% 主色
            ],
            global: false
          }
        },
        lineStyle: { color: colorList[index].lineColor }
      }));

      this.chartInstance.setOption({
        xAxis: {
          data: xAxisDate,
          show: groupOneInfo.length,             // 空数据时隐藏 X 轴
          axisLabel: {
            textStyle: { color: "#7B8F9D", fontSize: 12 },
            align: "center",
            interval: xAxisDate.length > 12 ? 2 : 0   // >12 项隔 2 个显示
          }
        },
        title: { show: groupOneInfo.length === 0, text: "暂无数据" },
        yAxis: {
          show: groupOneInfo.length,
          name: unit ? `单位：${unit}` : "",
          nameTextStyle: {
            fontSize: 12, color: "rgba(255, 255, 255, 0.5)",
            fontWeight: 800, fontFamily: "Microsoft YaHei",
            padding: [3, 0, 0, 4]
          },
          axisLine: { show: false, lineStyle: { color: "#0D394A" } },
          axisTick: { show: false },
          splitLine: { show: true, lineStyle: { color: "rgba(109,193,203,0.2)" } },
          axisLabel: {
            textStyle: {
              fontSize: 12, color: "#FFFFFF7F",
              fontWeight: 800, fontFamily: "Microsoft YaHei"
            }
          }
        },
        legend: { show: groupOneInfo.length },
        series: list
      });
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
.module-wrap {
  .echart-container { width: 100%; height: 100%; }
}
```

## 关键设计点

### 1. 颜色模板表（colorList）
每条线三个颜色：
- `lineColor`：实线 + 图例圆点 + 外圈边框
- `lineInitiateColor`：areaStyle 顶部（不透明度 0.4）
- `lineStopColor`：areaStyle 底部（不透明度 0）

放在模块顶部 const，按 series 索引取，便于主题迁移。

### 2. areaStyle 渐变方向
`x:0, y:0, x2:0, y2:1` 表示"上→下"，顶部高亮（40% alpha），底部完全透明，自然下沉。

### 3. tooltip 数据失守降级
```js
const value = params[i].data.isHas ? params[i].value : "--";
```
如果某 series 在该 x 点无值（`metricValue` 为 0/空），tooltip 显示 `"--"` 而不是 `0`，避免误导。

### 4. X / Y 轴 / Legend / Title 联动显隐
```js
title:  { show: groupOneInfo.length === 0, text: "暂无数据" },
xAxis:  { show: groupOneInfo.length, ... },
yAxis:  { show: groupOneInfo.length, ... },
legend: { show: groupOneInfo.length }
```
- 当主分组无数据：保留 title "暂无数据" 在图表中心 + 其余 axis/legend/series 全隐藏
- 当主分组有数据：axis 与 legend 全部出现

### 5. smooth: true
曲线平滑开启，适合展示"趋势"而非精确读数。

### 6. symbolSize: 2 + itemStyle.borderColor
极小的圆点 marker（2px）+ 同色边框，避免在密集数据点上挡住趋势线。

### 7. z: 10 (xAxis)
把 xAxis 提升 z 层级，让 dataZoom / 网格线不会盖住 X 轴文本。

## 与已有知识库的差异
- 现有知识库没有"多色折线渐变面积图"模板
- 与柱状图模板（BKMB118）形成对应：柱图展示离散分组对比 / 折线图展示连续时间趋势

## 变体
- **想堆叠面积**：把每条 series `stack: 'total'`，并在 option 中加 `stack: '总量'`
- **想改成柱状+折线混合**：保留 1 个 `type: 'bar'` + 多 `type: 'line'`
- **数据极少时关 areaStyle**：`areaStyle: undefined` 即退化为纯折线
- **数据极密时开 dataZoom**：参考柱状图模板加 `dataZoom: { type: 'slider', zoomLock: true }`
