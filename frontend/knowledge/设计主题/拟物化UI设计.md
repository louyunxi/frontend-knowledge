# 拟物化UI设计

## 概述

拟物化（Skeuomorphism）是通过视觉属性（渐变、阴影、纹理）模拟真实物体质感的界面设计风格。与扁平化相对，各有适用场景。

## 来源

- Skill: `skeuomorphic-ui`
- 来源文件: `skeuomorphic-ui/SKILL.md`
- 蒸馏类型: best
- 蒸馏时间: 2026-09-15

## 表面配方

拟物化界面的核心是表面（Surface）的视觉处理。

### 三层叠加

```text
每个表面由三层组成：
┌─────────────────────────┐
│  高光 (Highlight)        │  ← 顶部，模拟光源反射
│ ─────────────────────────│
│  主体 (Body)             │  ← 中间，基础颜色/渐变
│ ─────────────────────────│
│  阴影 (Shadow)           │  ← 底部，模拟物体投射
└─────────────────────────┘
```

### 基础表面配方

```css
/* 最基础的表面 */
.surface {
  background: #f5f5f5;        /* 主体 */
  border: 1px solid rgba(0,0,0,0.1);  /* 边框 */
  box-shadow: 0 1px 2px rgba(0,0,0,0.1); /* 阴影 */
}
```

### 渐变配方

```css
/* 顶部光源渐变（最常用） */
.gradient-top-light {
  background: linear-gradient(
    180deg,
    rgba(255,255,255,0.15) 0%,
    rgba(255,255,255,0) 100%
  );
}

/* 底部光源渐变 */
.gradient-bottom-light {
  background: linear-gradient(
    0deg,
    rgba(0,0,0,0.1) 0%,
    rgba(0,0,0,0) 50%
  );
}

/* 金属质感 */
.metallic {
  background: linear-gradient(
    135deg,
    #e8e8e8 0%,
    #d0d0d0 25%,
    #e8e8e8 50%,
    #d0d0d0 75%,
    #e8e8e8 100%
  );
}
```

### 边框配方

```css
/* 内凹边框 */
.border-inset {
  border: 1px solid rgba(0,0,0,0.2);
  box-shadow: inset 0 1px 0 rgba(255,255,255,0.5);
}

/* 外凸边框 */
.border-raised {
  border: 1px solid rgba(255,255,255,0.8);
  box-shadow: 
    0 1px 0 rgba(0,0,0,0.1),
    inset 0 1px 0 rgba(255,255,255,0.8);
}

/* 双层边框 */
.border-double {
  border: 1px solid rgba(0,0,0,0.3);
  box-shadow:
    inset 0 1px 0 rgba(255,255,255,0.5),
    0 0 0 1px rgba(255,255,255,0.8);
}
```

## 抬起表面 (Raised Surface)

元素从背景"抬起"，模拟凸起效果。

### 特征

```text
抬起表面的特征：
- 顶部高光（上边缘白色）
- 底部阴影（向下的投影）
- 边框：上浅下深
```

### CSS 实现

```css
.raised {
  background: #e8e8e8;
  border-top: 1px solid rgba(255,255,255,0.7);
  border-left: 1px solid rgba(255,255,255,0.5);
  border-right: 1px solid rgba(0,0,0,0.1);
  border-bottom: 1px solid rgba(0,0,0,0.2);
  box-shadow: 0 2px 4px rgba(0,0,0,0.15);
}
```

### 层级梯度

```css
/* 层级1：轻度抬起 */
.level-1 {
  box-shadow: 0 1px 2px rgba(0,0,0,0.1);
}

/* 层级2：中度抬起 */
.level-2 {
  box-shadow: 
    0 2px 4px rgba(0,0,0,0.1),
    0 4px 8px rgba(0,0,0,0.05);
}

/* 层级3：高度抬起 */
.level-3 {
  box-shadow: 
    0 4px 8px rgba(0,0,0,0.1),
    0 8px 16px rgba(0,0,0,0.1);
}
```

## 按下表面 (Pressed Surface)

元素被"按下"，模拟凹陷效果。

### 特征

```text
按下表面的特征：
- 顶部阴影（上边缘深色）
- 底部高光（下边缘白色）
- 边框：上深下浅（与抬起相反）
```

### CSS 实现

```css
.pressed {
  background: #d8d8d8;
  border-top: 1px solid rgba(0,0,0,0.2);
  border-left: 1px solid rgba(0,0,0,0.1);
  border-right: 1px solid rgba(255,255,255,0.3);
  border-bottom: 1px solid rgba(255,255,255,0.5);
  box-shadow: inset 0 2px 4px rgba(0,0,0,0.15);
}
```

### 按钮按下态

```css
.button {
  background: linear-gradient(180deg, #f0f0f0 0%, #d0d0d0 100%);
  border: 1px solid rgba(0,0,0,0.2);
  box-shadow: 
    0 1px 0 rgba(255,255,255,0.8) inset,
    0 2px 4px rgba(0,0,0,0.1);
}

.button:active {
  background: linear-gradient(180deg, #d0d0d0 0%, #c0c0c0 100%);
  box-shadow: inset 0 2px 4px rgba(0,0,0,0.2);
}
```

## 浮雕效果 (Embossed Effect)

用阴影创造文字或图标的立体感。

### 凸起文字

```css
.emboss-text {
  color: transparent;
  text-shadow: 
    0 1px 0 rgba(255,255,255,0.8),
    0 -1px 0 rgba(0,0,0,0.3);
  background: linear-gradient(180deg, #666 0%, #333 100%);
  -webkit-background-clip: text;
  background-clip: text;
}
```

### 凹陷文字

```css
.engraved-text {
  color: transparent;
  text-shadow: 
    0 -1px 0 rgba(255,255,255,0.5),
    0 1px 0 rgba(0,0,0,0.3);
  background: linear-gradient(180deg, #999 0%, #ccc 100%);
  -webkit-background-clip: text;
  background-clip: text;
}
```

### 图标浮雕

```css
.icon-embossed {
  filter: drop-shadow(0 1px 0 rgba(255,255,255,0.8))
          drop-shadow(0 -1px 0 rgba(0,0,0,0.3));
}
```

## 微纹理 (Micro Texture)

在纯色背景上添加细微纹理，增加质感。

###噪点纹理

```css
.texture-noise::before {
  content: '';
  position: absolute;
  inset: 0;
  background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='noise'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.65' numOctaves='3' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23noise)'/%3E%3C/svg%3E");
  opacity: 0.03;
  pointer-events: none;
}
```

### 纸张纹理

```css
.texture-paper {
  background: 
    linear-gradient(90deg, transparent 0%, rgba(0,0,0,0.02) 50%, transparent 100%),
    #faf9f7;
}
```

## 品味规则

### 克制原则

```text
⚠️ 拟物化的陷阱：
- 每个元素都想做质感
- 过度使用渐变和阴影
- 纹理过于明显

✅ 正确做法：
- 选择性使用：按钮、表单、卡片
- 轻量质感：细微渐变 + 柔和阴影
- 统一层次：同类型元素相同质感
```

### 使用场景判断

```text
适合拟物化的场景：
- 需要明确可点击性的界面
- 工具类/效率类应用
- 游戏界面
- 品牌需要真实感的场景

不适合拟物化的场景：
- 内容为主的阅读型界面
- 需要高密度信息的仪表盘
- 极简风格产品
- 需要快速迭代的MVP
```

### 与扁平化结合

```text
现代UI趋势：扁平化 + 微妙拟物

方法：
1. 扁平色块作为主体
2. 用极轻阴影表示层级
3. 按钮保留微妙渐变
4. 卡片用轻阴影而非厚重边框
```

```css
/* 现代轻拟物按钮 */
.modern-button {
  background: #2563eb;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(37,99,235,0.3);
  transition: all 0.2s ease;
}

.modern-button:hover {
  background: #1d4ed8;
  box-shadow: 0 4px 8px rgba(37,99,235,0.4);
}
```

## 组件示例

### 按钮

```css
/* 默认态 */
.btn {
  background: linear-gradient(180deg, #ffffff 0%, #e8e8e8 100%);
  border: 1px solid rgba(0,0,0,0.15);
  border-radius: 4px;
  box-shadow: 
    0 1px 0 rgba(255,255,255,0.8) inset,
    0 1px 2px rgba(0,0,0,0.1);
}

/* 悬停态 */
.btn:hover {
  background: linear-gradient(180deg, #ffffff 0%, #f0f0f0 100%);
}

/* 按下态 */
.btn:active {
  background: linear-gradient(180deg, #e0e0e0 0%, #d8d8d8 100%);
  box-shadow: inset 0 2px 4px rgba(0,0,0,0.15);
}
```

### 输入框

```css
.input {
  background: #ffffff;
  border: 1px solid rgba(0,0,0,0.2);
  border-radius: 4px;
  box-shadow: inset 0 1px 3px rgba(0,0,0,0.1);
}

.input:focus {
  border-color: rgba(37,99,235,0.5);
  box-shadow: 
    inset 0 1px 3px rgba(0,0,0,0.1),
    0 0 0 3px rgba(37,99,235,0.1);
}
```

### 卡片

```css
.card {
  background: #ffffff;
  border: 1px solid rgba(0,0,0,0.08);
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.08);
}

.card-elevated {
  box-shadow: 
    0 1px 3px rgba(0,0,0,0.08),
    0 4px 12px rgba(0,0,0,0.05);
}
```

## 反模式

- ❌ 每个元素都加厚重渐变
- ❌ 用纯黑阴影 `#000`
- ❌ 纹理过于明显喧宾夺主
- ❌ 悬停/按下态没有视觉变化
- ❌ 扁平界面强行加质感
- ❌ 不同元素用不一致的质感层级

## 关键词

| 关键词 | 同义词 | 语义变体 |
|--------|--------|---------|
| 拟物化 | skeuomorphic | "质感设计"、"仿真" |
| 表面 | surface | "界面层" |
| 抬起 | raised | "凸起"、"浮出" |
| 按下 | pressed | "凹陷"、"按入" |
| 浮雕 | embossed | "凹凸文字"、"立体字" |
| 渐变 | gradient | "色彩渐变" |
| 高光 | highlight | "光泽"、"亮点" |
| 纹理 | texture | "质感"、"噪点" |

## 语义标签

`design` `skeuomorphic` `gradient` `shadow` `texture` `depth` `ui-design`

## 相关知识

- 设计原则-移动端阴影与质感
- 设计原则-色彩与视觉
- 设计原则-排版规范
