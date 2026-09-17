# 可变字体与OpenType特性

## 概述

可变字体（Variable Fonts）和OpenType特性是现代排版的高级能力，可以用更少的文件实现更丰富的字体效果。

## 来源

- Skill: `better-typography`
- 来源文件: `variable-fonts-and-opentype.md`
- 蒸馏类型: best
- 蒸馏时间: 2026-09-15

## 静态字体 vs 可变字体

```
静态字体：
- 每个字重/样式需要一个独立文件
- Regular、Medium、Bold = 3个文件

可变字体：
- 一个文件包含整个范围
- 任意值都有效，如 font-weight: 589
- 多字重、多样式场景下文件更小
```

### 选择原则

```text
何时用静态字体：
- 只需要 1-2 个字重
- 追求最小文件体积
- 不需要细粒度控制

何时用可变字体：
- 需要多个字重（4+）
- 需要光学尺寸（Optical Size）
- 有自定义轴（Custom Axes）需求
```

## 字体轴（Axes）

字体轴是控制可变字体的四字母标签：

| 轴 | 标签 | 控制内容 |
|---|------|---------|
| Weight | `wght` | 笔画粗细（类似 font-weight） |
| Optical Size | `opsz` | 根据显示尺寸调整细节和间距 |
| Width | `wdth` | 字形宽度 |
| Slant | `slnt` | 倾斜角度 |
| Custom | 如 `GRAD` | 自定义轴（字体特有） |

### 常用示例

```css
/* 常用轴使用属性 */
.heading {
  font-weight: 650;           /* wght 轴 */
  font-optical-sizing: auto;  /* opsz 轴 */
}

/* 自定义轴需要用原始标签 */
.grade-text {
  font-variation-settings: "GRAD" 80;  /* Roboto Flex 独有 */
}
```

### 属性优先原则

```css
/* ✅ 好：用属性控制常用轴 */
.heading {
  font-weight: 650;
  font-optical-sizing: auto;
}

/* ❌ 差：用原始标签控制常用轴 */
.heading {
  font-variation-settings: "wght" 650;  /* 回退时失效 */
}

/* ✅ 好：自定义轴用原始标签 */
.logo {
  font-variation-settings: "GRAD" 80;  /* 无对应属性 */
}
```

## OpenType 特性

OpenType是现代字体的标准特性，在静态和可变字体上都可用：

| 标签 | 特性 | 用途 |
|------|------|------|
| `tnum` | 等宽数字 | 价格、计时器、表格 |
| `zero` | 斜杠零 | 区分 0 和 O |
| `liga` | 连字 | 如 "fi" 合并 |
| `ss01`-`ss20` | 风格集 | 字体特有变体 |
| `cv01`-`cv99` | 字符变体 | 字体特有变体 |

### 属性优先原则

```css
/* ✅ 好：用属性控制常用特性 */
.price {
  font-variant-numeric: tabular-nums;      /* 等宽数字 */
}

.id-code {
  font-variant-numeric: slashed-zero;     /* 斜杠零 */
}

/* ✅ 好：特有特性用原始标签 */
.logo {
  font-feature-settings: "ss01" 1;       /* Inter 开放数字 */
}
```

## 等宽数字（Tabular Numbers）

### 重要性

```text
问题：
数字默认宽度不同（1 比 0 窄）
计时器：1:23 → 1:59（布局跳动）
价格：¥128 → ¥999（对不齐）

解决：
font-variant-numeric: tabular-nums
```

### 使用场景

```css
/* 价格显示 */
.price {
  font-variant-numeric: tabular-nums;
}

/* 计时器 */
.timer {
  font-variant-numeric: tabular-nums;
  font-variant-numeric: slashed-zero;  /* 可叠加 */
}

/* 表格数据 */
.table-cell {
  font-variant-numeric: tabular-nums;
  font-variant-numeric: lining-nums;  /* 齐线数字 vs 旧体数字 */
}
```

### Tailwind

```css
.tabular-nums {
  font-variant-numeric: tabular-nums;
}
```

```tsx
<span className="tabular-nums">¥1,234.56</span>
```

## 小型大写字母

```css
/* 真实小型大写（从大写字母缩小） */
.abbr {
  font-variant-caps: small-caps;
}

/* 全小型大写（所有字母都是大写形状） */
.code-label {
  font-variant-caps: all-small-caps;
}
```

## 上标与下标

```css
/* 上标：x² */
.sup {
  font-variant-position: super;
}

/* 下标：H₂O */
.sub {
  font-variant-position: sub;
}
```

## 字体合成控制

### 禁用合成

```css
/* 禁用所有合成（谨慎使用） */
.brand-wordmark {
  font-synthesis: none;
}
```

### 重要提示

```text
⚠️ 禁用 font-synthesis 前必须验证：
- 回退字体的显示效果
- 所有需要的粗体、斜体、小型大写形态
- 确保回退时各形态仍有区分度

验证流程：
1. 临时移除目标字体
2. 检查回退字体的显示
3. 确认各形态（Regular/Bold/Italic）都可用
4. 再设置 font-synthesis: none
```

## 字距调整（Kerning）

```css
/* 自动字距（默认开启） */
.kerned {
  font-kerning: auto;  /* 默认值 */
}

/* 禁用字距调整 */
.no-kern {
  font-kerning: none;
}
```

```text
说明：
- Kerning 调整特定字母对（如 AV、W o）
- 内置于字体，自动应用
- 关闭需谨慎，通常用于装饰性文字
```

## 字母间距（Letter-spacing）

```css
/* 标题：收紧 */
.heading {
  letter-spacing: -0.02em;
}

/* 全大写标签：放宽 */
.uppercase-label {
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

/* 正文：通常不需要调整 */
.body {
  letter-spacing: normal;  /* 默认值 */
}
```

## 文字剪切（text-box）

剪切字体预留的上下空间，用于按钮、徽章等紧凑场景：

```css
/* 剪切上下两边 */
.badge {
  text-box-trim: trim-both;
  text-box-edge: cap alphabetic;
}

/* 只剪切上方 */
.heading {
  text-box-trim: trim-start;
  text-box-edge: cap;
}

/* 只剪切下方 */
.label {
  text-box-trim: trim-end;
  text-box-edge: alphabetic;
}
```

```text
Edge 选项：
- cap：剪切到 cap height（上方）
- alphabetic：剪切到基线（下方）
- text：保留字体自身的文本边缘（含下延）
```

### 浏览器支持

```text
支持：Chromium 133+、Safari 18.2+
不支持：Firefox
处理：作为渐进增强，兼容浏览器保留默认行高
```

## 反模式

- ❌ 用 `font-variation-settings: "wght" 650` 控制常用轴
- ❌ 不验证就禁用 `font-synthesis`
- ❌ 在价格/计时器上不用等宽数字
- ❌ 所有元素都调整字距（通常不需要）
- ❌ 过度使用连字（liga）影响可读性

## 关键词

| 关键词 | 同义词 | 语义变体 |
|--------|--------|---------|
| 可变字体 | variable font, VF | "单文件多字重"、"动态字体" |
| OpenType | OT | "字体特性"、"字体内置功能" |
| 等宽数字 | tabular-nums, tnum | "数字对齐"、"数字不跳动" |
| 字重 | font-weight, wght | "粗细"、"字重" |
| 光学尺寸 | optical sizing, opsz | "字号适应性" |
| 字体合成 | font-synthesis | "字体生成"、"粗体合成" |
| 小型大写 | small-caps | "SC" |
| 上标 | superscript, super | "上角标"、"幂" |
| 下标 | subscript, sub | "下角标"、"化学式" |
| 字距调整 | kerning | "AV调整"、"字母间距微调" |
| 字母间距 | letter-spacing | "字间距" |

## 语义标签

`typography` `variable-fonts` `opentype` `font-feature` `tabular-nums` `web-fonts` `css`

## 相关知识

- 设计原则-排版规范
- 设计原则-移动端排版规范
- CSS排版速查表
