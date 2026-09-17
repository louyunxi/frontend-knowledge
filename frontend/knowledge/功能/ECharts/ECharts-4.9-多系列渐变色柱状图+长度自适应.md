# ECharts-4.9-多系列渐变色柱状图+长度自适应

## 模板名称
ECharts 4.9 · 多系列垂直渐变柱状图 + 数据长度自适应（短轴直显 / 中轴旋转 / 长轴 dataZoom）

## 库名与版本
- **echarts**: `4.9.0`（注意：非 5.x，API 细节不同）
- 模板来源项目 frp_gov_web 全局锁版本
- 初始化方式：`this.$echarts.init(el)`（Vue prototype 注入的 ECharts，4.x 全局 API）

## 应用场景
大屏卡片，**多组数据并列显示**，每组是 1 条 series（如多个产品线、各月产量等）。柱体垂直渐变，颜色按 series 索引取配色表。
当 X 轴数据超过 12 项时自动启用 `dataZoom` 滑块（只允许平移、不可缩放）以节省横向空间；6~12 项时 X 轴标签旋转 45°；< 6 项直接平铺。

## 标签
```yaml
tags:
  - echarts
  - echarts-4.9
  - 柱状图
  - 垂直渐变
  - linearGradient
  - 多系列
  - dataZoom-自适应
  - 长度自适应
  - 标签旋转
  - barMinHeight
  - tooltip-custom
  - vue2
```

## 来源
- source_scope: ["BKMB118"]
- source_project: frp_gov_web (D:\sn-project\frp_gov_web)
- source_path: src/components/GovScreen/GSTemp/src/BKMB118.vue

## 关键代码骨架

### template
```vue
<GSPlate v-bind="$attrs">
  <div class="module-wrap">
    <div class="echart-container" ref="EContainer"></div>
  </div>
</GSPlate>
```

### script（核心：底部常驻 option + 顶部 refreshChart 合并 option）
```js
import { debounce } from "@/utils/utils";

// ========= 底部常驻 option（结构/样式，不含数据） =========
const barOption = {
  tooltip: {
    show: true,
    trigger: "axis",
    confine: true,
    axisPointer: { type: "none" },
    backgroundColor: "#043250",
    padding: [13, 14, 13, 11],
    textStyle: { fontSize: 12, color: "#9ED2D8" },
    formatter: params => {
      let str = `${params[0]?.name}<br/>`;
      params.forEach(ele => {
        str += `${ele.data.title ? ele.data.title + "：" : ""}${
          ele.value || ""
        }${ele.data.unit || ""}<br/>`;
      });
      return str;
    }
  },
  legend: {
    show: true,
    type: "plain",
    icon: "circle",
    itemWidth: 6,
    x: "center",
    padding: [18, 0, 0, 0],
    textStyle: { color: "#9DD1D7" }
  },
  grid: { top: 50, right: 30, bottom: 35, left: 60 },
  xAxis: {
    type: "category",
    axisTick: { show: false },
    axisLabel: {
      padding: [5, 5, 0, 0],
      hideOverlap: true,
      interval: 0,
      color: "#9DD1D7",
      formatter: params => params.slice(0, 8)   // 单类名最多 8 字节
    },
    axisLine: { lineStyle: { show: false } }
  },
  yAxis: {
    splitNumber: 3,
    nameTextStyle: { align: "right", color: "#9DD1D7" },
    nameGap: 20,
    axisLine: { show: false },
    axisTick: { show: false },
    splitLine: { show: true, lineStyle: { color: "rgba(50, 206, 187, 0.15)" } },
    axisLabel: { color: "#9DD1D7" }
  }
};

export default {
  name: "BKMB118",
  props: { plateVO: { type: Object, default: () => ({}) } },
  computed: {
    eContainerRef() { return this.$refs.EContainer; }
  },
  data() { return { chartInstance: null }; },
  methods: {
    async initModule() {
      this.chartInstance = this._initEcharts(this.eContainerRef, barOption);
      this.refreshChart(this.chartInstance);
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
    refreshChart(chartInstance) {
      const { plateMetricGroupList } = this.plateVO;
      // 4 套系列配色
      const colors = [
        ["#3A83F2", "#4ADEFF"],
        ["#F29D3A", "#FFED4A"],
        ["#22CC8F", "#6CFBC7"],
        ["#911EEC", "#B57AFF"]
      ];
      const groupList =
        plateMetricGroupList
          ?.filter(ele => ele.plateMetricList && ele.plateMetricList.length)
          .slice(0, 4) || [];
      const maxLength = groupList[0]?.plateMetricList?.length || 0;

      const chartOpts = {
        xAxis: [{
          data: groupList[0]?.plateMetricList.map(item => this.truncateTo8Bytes(item.metricName)),
          axisLabel: {
            margin: maxLength > 6 ? 6 : 12,
            rotate: maxLength > 6 ? 45 : 0
          }
        }],
        yAxis: [{
          name: groupList[0]?.metricGroupUnit
            ? "单位：" + groupList[0].metricGroupUnit
            : ""
        }],
        grid: { bottom: maxLength > 12 ? "60" : maxLength > 6 ? "50" : "35" },
        series: groupList.map((ele, index) => ({
          barMinHeight: 3,                   // 0 值时仍然显示一条细线
          barWidth: "20%",                   // 窄柱
          type: "bar",
          barGap: 0.2,                       // 系列内柱距 20%
          name: ele.metricGroupName,
          color: {
            type: "linear",
            x: 0, y: 0, x2: 0, y2: 1,       // 下→上 渐变
            colorStops: [
              { offset: 0, color: colors[index][0] },
              { offset: 1, color: colors[index][1] }
            ]
          },
          data: ele.plateMetricList.map(item => ({
            title: ele.metricGroupName || "",
            value: item.metricValue || 0,
            unit: item.metricUnit || "",
            name: item.metricName || ""
          }))
        })),
        dataZoom: maxLength > 12 ? {
          show: true,
          type: "slider",
          showDetail: false,
          moveHandleSize: 0,
          height: 8,
          start: 0,
          end: (12 / maxLength) * 100,       // 默认展示前 12 个
          xAxisIndex: [0],
          zoomLock: true,                    // 禁用缩放，只允许平移
          bottom: 5
        } : { show: false }
      };
      chartInstance.setOption(chartOpts);
      chartInstance.resize();
    },
    resizeChart() {
      debounce(() => this.chartInstance.resize(), 200)();
    },
    truncateTo8Bytes(s) {                  // 截取前 8 字节（汉字占 2 字节）
      let out = "", bytes = 0;
      for (const ch of s) {
        const len = ch.charCodeAt(0) > 255 ? 2 : 1;
        if (bytes + len > 8) break;
        out += ch; bytes += len;
      }
      return out;
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
  width: 100%; height: 100%;
  display: flex; flex-direction: column;
  box-sizing: border-box;
  overflow: hidden; position: relative;
  .echart-container { flex: 1; height: 100%; }
}
```

## 关键设计点

### 1. 颜色按 series 索引取
模板自维护一份 `colors` 矩阵（一组两项：深→浅），`series.map((ele, index) => ({ color: { ...colors[index] } }))`。颜色是**对象形式**而非字符串，对象内是 `LinearGradient`，API 4.9 / 5.x 都支持。

### 2. 数据长度三档自适应
模板亮点是 `maxLength` 决定 3 件事：
| 数据长度 | grid.bottom | x 标签旋转 | dataZoom |
|----------|-------------|-----------|----------|
| ≤ 6      | 35          | 0         | 关       |
| 6 < n ≤ 12| 50         | 45°       | 关       |
| > 12     | 60          | 45°       | 开，end = 12/n × 100 |

`zoomLock: true` 关键：只允许用户横向平移，不会把柱体拉变形。

### 3. barMinHeight
`barMinHeight: 3` 让 0 值仍可见一条细线，避免柱图"消失"误导。

### 4. tooltip 自定义
`params[0].name` 作 X 标签，副以 `params.data.title`（series 名） + `params.value`（数值） + `params.data.unit`（单位）。这是 ECharts 4/5 都支持的"数组返回字符串"格式。

### 5. label 8 字节截断
```js
truncateTo8Bytes(s) // 按汉字 2 字节、ASCII 1 字节截
```
X 类名过长时只保留 8 字节，配合 `rotate: 45` 防止重叠。再叠加 echarts 的 `formatter` 再硬截一次（`slice(0, 8)`），双保险。

### 6. resize 防抖
200ms debounce 防止拖动窗口、组件重排时频繁 resize。`hook:beforeDestroy` 钩子释放事件监听，避免内存泄漏。

## 与已有知识库的差异
- 现有 `ECharts-2D-垂直渐变柱状图.md` 用的是 echarts **5.6.0**，且为**单系列**
- 本模板为 **4.9.x** + **多系列** + **dataZoom 自适应**，独立保留

## 适配建议
- ECharts 升级到 5.x：`$echarts.init` 用法不变；`barGap` 仍支持；`dataZoom.zoomLock` 不变
- 改变颜色：替换顶部 `colors` 矩阵
- 改变分组上限：修改 `.slice(0, 4)` 与 `colors` 长度同步
- 数据更密时把 `> 12` 阈值调整为 `> 10`，让 dataZoom 早介入
