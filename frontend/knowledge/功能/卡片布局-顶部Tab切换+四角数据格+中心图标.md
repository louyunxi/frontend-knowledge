# 卡片布局-顶部Tab切换+四角数据格+中心图标

## 模板名称
顶部 Tab 切换 + 四角数据格 + 中心图标

## 应用场景
大屏中需要"按类型分组展示若干组数据"的卡片。每组数据包含一个"中心主体"和"四角各 1 个指标"。
- 同一卡片可在多个分组之间切换（Tab）
- 每组下：4 个独立单元（左上 / 右上 / 左下 / 右下），各显示 title + value + unit
- 中央叠加一个图标 img，作为视觉锚点

## 标签
```yaml
tags:
  - gs板-card
  - layout
  - 卡片布局
  - tab切换
  - 4宫格
  - 四角数据
  - 中心图标
  - line-active
  - 滑动指示线
  - GSPlate
  - vue2
```

## 来源
- source_scope: ["BKMB109"]
- source_project: frp_gov_web (D:\sn-project\frp_gov_web)
- source_path: src/components/GovScreen/GSTemp/src/BKMB109.vue

## 技术栈
- Vue 2.6.10
- Element UI 2.15.14
- 项目内部 `GSPlate` 组件（标题栏 + 加载态接管）

## 结构示意
```
GSPlate
├─ nav-container                # 顶部 tab（如分组 > 1 才显示）
│   └─ nav-wrap (flex, relative)
│       ├─ nav-item (v-for hjTitList)
│       │   ├─ span {{ item.metricGroupName }}
│       │   └─ click → switchItem(item, index)
│       └─ line-active (absolute, bottom -5px)  # 跟随选中项滑动的高亮线
└─ carousel-wrap (v-if centerObj && centerObj.topLeft)
    └─ carousel-wrap-content (height: 165px)
        ├─ top-img (flex 1, space-between)
        │   ├─ left  (.title + .num)  ← topLeft.metricName/Value/Unit
        │   └─ right (.title + .num)  ← topRight.metricName/Value/Unit
        ├─ bottom-img (flex 1)
        │   ├─ left  (.title + .num)  ← bottomLeft
        │   └─ right (.title + .num)  ← bottomRight
        └─ container (absolute, 全覆盖)
            ├─ center-img        # 中心底图 PNG
            └─ center-center-img # 中心 icon（v-if plateIconUrl）
```

## 完整代码

### template
```vue
<GSPlate v-bind="$attrs">
  <div class="nav-container" v-if="hjTitList.length > 1">
    <div class="nav-wrap" ref="navWrap">
      <div
        v-for="(item, index) in hjTitList"
        class="nav-item"
        :class="{ 'nav-item-avtive': currentDeviceId === item.id }"
        @click="switchItem(item, index)"
        :key="item.id"
      >
        <span>{{ item.metricGroupName }}</span>
      </div>
      <span class="line-active" ref="lineActive"></span>
    </div>
  </div>

  <div class="carousel-wrap" v-if="centerObj && centerObj.topLeft">
    <div class="carousel-wrap-content">
      <div class="top-img">
        <div class="left">
          <div class="title">{{ centerObj.topLeft.metricName || "" }}</div>
          <div class="num">
            <span>{{ centerObj.topLeft.metricValue || "" }}</span>{{ centerObj.topLeft.metricUnit || "" }}
          </div>
        </div>
        <div class="right">
          <div class="title">{{ centerObj.topRight.metricName || "" }}</div>
          <div class="num">
            <span>{{ centerObj.topRight.metricValue || "" }}</span>{{ centerObj.topRight.metricUnit || "" }}
          </div>
        </div>
      </div>
      <div class="bottom-img">
        <div class="left">
          <div class="title">{{ centerObj.bottomLeft.metricName || "" }}</div>
          <div class="num">
            <span>{{ centerObj.bottomLeft.metricValue || "" }}</span>{{ centerObj.bottomLeft.metricUnit || "" }}
          </div>
        </div>
        <div class="right">
          <div class="title">{{ centerObj.bottomRight.metricName || "" }}</div>
          <div class="num">
            <span>{{ centerObj.bottomRight.metricValue || "" }}</span>{{ centerObj.bottomRight.metricUnit || "" }}
          </div>
        </div>
      </div>
      <div class="container">
        <img class="center-img" src="@/assets/images/xxx/center-bg.png" alt="" />
        <img class="center-center-img" :src="centerObj.plateIconUrl" alt="picture" v-if="centerObj.plateIconUrl" />
      </div>
    </div>
  </div>
</GSPlate>
```

### script
```js
export default {
  name: "BKMB109",
  props: {
    plateVO: {
      type: Object,
      default() { return {}; }
    }
  },
  data() {
    return {
      currentDeviceId: 0,
      hjTitList: [],
      FLAG: { SHOW: true, HIDE: false }
    };
  },
  computed: {
    centerObj() {
      // 当前选中分组的四角数据对象
      return this.hjTitList.find(item => item.id === this.currentDeviceId);
    }
  },
  methods: {
    async initModule() {
      const { plateMetricGroupList } = this.plateVO;
      // 每组取前 4 个指标映射到四个角；最多保留 5 个分组
      this.hjTitList = plateMetricGroupList
        .map(ele => ({
          ...ele,
          topLeft:     ele.plateMetricList[0] || {},
          topRight:    ele.plateMetricList[1] || {},
          bottomLeft:  ele.plateMetricList[2] || {},
          bottomRight: ele.plateMetricList[3] || {}
        }))
        ?.slice(0, 5);
      this.currentDeviceId = plateMetricGroupList[0].id;
      this.$nextTick();
      this._initModuleStyle();
    },
    switchItem(e, index) {
      // Tab 点击：loading 闪一下 + 移动高亮线
      this.loading = this.FLAG.SHOW;
      this.currentDeviceId = e.id;
      this.list = [];
      this._changeModuleStyle({
        elNavItem: this.$refs.navWrap.children[index],
        elLine: this.$refs.lineActive,
        index
      });
      this.$nextTick();
      this.loading = this.FLAG.HIDE;
    },
    _initModuleStyle() {
      // 默认高亮线对齐第一个 item 中心
      if (this.$refs.navWrap && this.$refs.lineActive) {
        this.$refs.lineActive.style.left =
          (this.$refs.navWrap.children[0].offsetWidth -
            this.$refs.lineActive.offsetWidth) / 2 + "px";
      }
    },
    _changeModuleStyle({
      elLine,
      elNavItem,
      index = 0,
      transitionTime = 0.3
    } = {}) {
      // 0 项：line 归零；其他项：line 用 translateX 平移到 item 中心
      let distance;
      if (index === 0) {
        distance = 0;
      } else {
        distance = elNavItem.offsetLeft + elLine.offsetWidth / 6;
      }
      elLine.style.transform = `translateX(${distance}px)`;
      elLine.style.transition = `linear ${transitionTime}s`;
    }
  },
  watch: {
    "$attrs.loading": {
      immediate: true,
      handler(newVal) {
        if (!newVal) {
          this.$nextTick(() => { this.initModule(); });
        }
      }
    }
  }
};
```

### style (核心样式)
```scss
.nav-container {
  width: 100%;
  padding-top: 10px;
  height: 34px;
  display: flex;
  justify-content: center;
  box-sizing: border-box;
  .nav-wrap {
    display: flex;
    position: relative;
    .nav-item {
      cursor: pointer;
      height: 100%;
      display: flex;
      align-items: center;
      margin-left: 40px;
      &:nth-child(1) { margin-left: 0; }
      & > span {
        height: 16px;
        font-family: Microsoft YaHei;
        font-size: 16px;
        color: #85b5bd;     // 未选中：暗淡蓝灰
      }
      &:hover > span,
      &.nav-item-avtive > span {
        font-weight: bold;
        color: #00f6ff;     // 选中/悬停：青色 + 加粗
      }
    }
    .line-active {
      position: absolute;
      bottom: -5px;
      width: 30px;
      height: 3px;
      background: #00f6ff;
      border-radius: 2px;
    }
  }
}

.carousel-wrap {
  position: relative;
  margin-top: 10px;
  width: 100%;
  height: calc(100% - 40px);
  display: flex;
  align-items: center;
  .carousel-wrap-content {
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    position: relative;
    box-sizing: border-box;
    width: 100%;
    height: 165px;
    .top-img, .bottom-img {
      display: flex;
      justify-content: space-between;
      flex: 1;
      font-size: 15px;
      .title { color: #9dd1d7; }
      .num {
        color: #fff600;
        margin-top: 10px;
        font-size: 12px;
        span { font-size: 24px; }   // 数字部分放大
      }
      .left, .right {
        background-repeat: no-repeat;
        width: 123px;
        height: 80px;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        background-size: 100% 95%;
      }
      .left  { padding-left: 10px;  padding-right: 20px; }
      .right { padding-left: 40px; }
    }
    .top-img {
      .left  { background-image: url("~@/assets/images/.../top_left_bg.png");     background-position: top left; }
      .right { background-image: url("~@/assets/images/.../top_right_bg.png");    background-position: top right; }
    }
    .bottom-img {
      margin-top: 5px;
      .left  { background-image: url("~@/assets/images/.../bottom_left_bg.png");  background-position: bottom left; }
      .right { background-image: url("~@/assets/images/.../bottom_right_bg.png"); background-position: bottom right; }
    }
    .container {
      position: absolute; left: 0; top: 0;
      height: 100%; width: 100%;
      .center-img,
      .center-center-img {
        display: block;
        position: absolute;
        left: 50%; top: 50%;
        transform: translate(-50%, -51%);
      }
      .center-img        { width: 190px; }
      .center-center-img { width: 70px; height: 70px; }
    }
  }
}
```

## 关键设计点

### 1. 数据结构预扁平化
```js
this.hjTitList = plateMetricGroupList
  .map(ele => ({
    ...ele,
    topLeft:     ele.plateMetricList[0] || {},
    topRight:    ele.plateMetricList[1] || {},
    bottomLeft:  ele.plateMetricList[2] || {},
    bottomRight: ele.plateMetricList[3] || {}
  }))
  ?.slice(0, 5);
```
把后端嵌套结构 `plateMetricGroupList[i].plateMetricList[0..3]` 一次拍平为四角，模板渲染只需 `topLeft.metricName / .metricValue / .metricUnit`。`?.slice(0, 5)` 限制分组上限。

### 2. 滑动指示线（line-active）
核心思路是用 `transform: translateX()` 而不是改 `left`，性能更好；初始位置用 JS 直接算 `left`：
```js
elLine.style.left = (navItem.offsetWidth - lineActive.offsetWidth) / 2 + "px";
```
点击后再切到 `transform` 平移；用 `transition: linear 0.3s` 做缓动。

### 3. 中心图标叠放
`.container` 用 `position: absolute` 覆盖整层，把中心 bg 图和中心 icon 各绝对定位到中心（`translate(-50%, -51%)` 做微调）。四角卡片是普通流式布局，盖在容器下方，由 z-index 自然层叠。

### 4. 加载态接入
通过监听 `$attrs.loading` 触发 `initModule()`，保证 GSPlate 接管 loading 时机一致。
```js
"$attrs.loading": {
  immediate: true,
  handler(newVal) {
    if (!newVal) this.$nextTick(() => this.initModule());
  }
}
```

### 5. 隐藏式降级
- `nav-container v-if="hjTitList.length > 1"` —— 只有 1 组时直接省掉 Tab
- `carousel-wrap v-if="centerObj && centerObj.topLeft"` —— 缺数据时不渲染四角网格
- `center-center-img v-if="centerObj.plateIconUrl"` —— 图标 URL 缺失时仅保留底图

## 变体
- **Tab 数量更多时**：可改造为 `el-tabs` 或横向滚动
- **无中心图标时**：可删 `.container` 整段，四角等距分布
- **数字要动画递增**：把 `.num span` 换成 `<count-to>`（参考 "顶部数字递增+4列图标数据网格" 模板）

## 适配建议
- 替换 4 张四角 PNG（`top_left_bg / top_right_bg / bottom_left_bg / bottom_right_bg`）+ 中心 PNG（`center-bg.png`）即可在主题间迁移
- 如要 2K 适配，可在最外层包一个 `@media screen and (max-width: 1680px) { .carousel-wrap-content { height: 150px } }`
