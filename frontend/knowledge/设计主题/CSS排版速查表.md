# CSS 排版速查表

## 概述

排版CSS声明的快速参考，包含Tailwind 4对照。适用于需要快速查找排版属性语法的场景。

## 来源

- Skill: `better-typography`
- 来源文件: `css-cheat-sheet.md`
- 蒸馏类型: best
- 蒸馏时间: 2026-09-15

## 字体属性

| 声明 | 作用 | Tailwind |
|------|------|----------|
| `font-family: sans-serif` | 无衬线字体族 | `font-sans` |
| `font-family: serif` | 衬线字体族 | `font-serif` |
| `font-family: monospace` | 等宽字体族 | `font-mono` |
| `font-size` | 字号（从字号比例） | `text-*` |
| `font-weight` | 字重（1-1000） | `font-*` |
| `font-style: italic` | 斜体 | `italic` |
| `-webkit-font-smoothing` + `-moz-osx-font-smoothing` | macOS字体平滑 | `antialiased` |
| `font-synthesis: none` | 禁用合成（需验证） | `[font-synthesis:none]` |
| `font-feature-settings` | 切换OpenType特性 | `[font-feature-settings:"ss01"]` |
| `font-variation-settings` | 调整可变字体轴 | `[font-variation-settings:"GRAD"_80]` |
| `font-optical-sizing` | 按字号调整细节 | `[font-optical-sizing:auto]` |
| `font-variant-caps` | 真实小型大写 | `[font-variant-caps:small-caps]` |
| `font-variant-position` | 上标/下标 | `[font-variant-position:super]` |
| `font-variant-numeric: tabular-nums` | 等宽数字 | `tabular-nums` |
| `font-variant-numeric: slashed-zero` | 斜杠零 | `slashed-zero` |

## 间距与布局

| 声明 | 作用 | Tailwind |
|------|------|----------|
| `letter-spacing` | 字母间距 | `tracking-*` |
| `line-height` | 行高 | `leading-*` |
| `font-kerning` | 字距调整开关 | `[font-kerning:none]` |
| `text-box-trim` | 剪切上下空间 | `[text-box-trim:trim-both]` |
| `max-width`（文本列） | 限制行长约60-75字符 | `max-w-xl` / `max-w-2xl` / `max-w-[65ch]` |
| `text-align` | 对齐方式 | `text-start` / `text-center` |

## 换行与溢出

| 声明 | 作用 | Tailwind |
|------|------|----------|
| `text-wrap: balance` | 均匀分布标题行 | `text-balance` |
| `text-wrap: pretty` | 避免孤行 | `text-pretty` |
| `text-overflow: ellipsis` | 省略号截断 | `truncate` |
| `line-clamp` | 限制行数 | `line-clamp-*` |
| `overflow-wrap: break-word` | 长字符串换行 | `break-words` |
| `white-space: nowrap` | 禁止换行 | `whitespace-nowrap` |
| `text-transform` | 大小写转换 | `uppercase` / `capitalize` |

## 装饰与交互

| 声明 | 作用 | Tailwind |
|------|------|----------|
| `text-decoration-line: underline` | 下划线 | `underline` |
| `text-decoration-color` | 下划线颜色 | `decoration-*` |
| `text-decoration-thickness` | 下划线粗细 | `decoration-1` / `decoration-2` |
| `text-underline-offset` | 下划线偏移 | `underline-offset-*` |
| `text-underline-position: from-font` | 从字体读取位置 | `[text-underline-position:from-font]` |
| `text-decoration-style` | 下划线样式 | `decoration-dotted` / `decoration-wavy` |
| `text-decoration-thickness: from-font` | 从字体读取粗细 | `decoration-from-font` |
| `text-decoration-skip-ink` | 跳过下延字母 | `[text-decoration-skip-ink:auto]` |
| `caret-color` | 光标颜色 | `caret-*` |
| `user-select: none` | 禁用选择（谨慎） | `select-none` |
| `text-shadow` | 文字阴影 | `text-shadow-*` |
| `-webkit-text-stroke` | 文字描边 | `[-webkit-text-stroke:1px_black]` |
| `background-clip: text` | 背景裁剪到文字 | `bg-clip-text` |
| `initial-letter` | 首字下沉 | `[initial-letter:3]` |

## 快速参考

### 字体平滑（根元素一次）

```css
html {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
```

```tsx
<html lang="en">
  <body class="font-sans antialiased">
    {children}
  </body>
</html>
```

### 等宽数字

```css
.price {
  font-variant-numeric: tabular-nums;
}
```

### 标题换行

```css
.heading {
  text-wrap: balance;
}
```

### 描述防孤行

```css
.description {
  text-wrap: pretty;
}
```

### 下划线优化

```css
a {
  text-underline-position: from-font;
  text-decoration-thickness: from-font;
  text-decoration-skip-ink: auto;
}
```

### 省略号截断

```css
/* 单行截断 */
.single-line {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

/* 多行截断 */
.multi-line {
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 3;
  overflow: hidden;
}
```

### 首字下沉

```css
.drop-cap::first-letter {
  font-size: 3em;
  float: left;
  line-height: 0.8;
  margin-right: 0.1em;
}

/* 现代方式（支持有限） */
.modern-drop-cap {
  initial-letter: 3;
}
```

## Tailwind 类名速查

```text
字号: text-xs | text-sm | text-base | text-lg | text-xl | text-2xl | ...
字重: font-light | font-normal | font-medium | font-semibold | font-bold
行高: leading-none | leading-tight | leading-snug | leading-normal | leading-relaxed
字间距: tracking-tighter | tracking-tight | tracking-normal | tracking-wide | tracking-wider
```

## 浏览器支持说明

```text
✅ 广泛支持：
- font-variant-numeric
- text-overflow: ellipsis
- letter-spacing / line-height
- text-transform

⚠️ 需注意：
- text-wrap: balance/pretty（现代浏览器）
- text-box-trim（Chromium 133+、Safari 18.2+）
- initial-letter（无 Firefox 支持）

❌ 谨慎使用：
- font-synthesis（需验证）
- -webkit-text-stroke（需前缀）
```

## 关键词

| 关键词 | 同义词 | 语义变体 |
|--------|--------|---------|
| CSS排版 | typography CSS | "排版属性"、"字体CSS" |
| Tailwind排版 | tailwind排版类 | "tailwind字体" |
| 字体属性 | font properties | "font-*" |
| 等宽数字 | tabular numbers | "tabular-nums" |
| 换行 | text-wrap | "自动换行"、"文本换行" |
| 截断 | truncate, ellipsis | "省略号"、"超长截断" |

## 语义标签

`css` `typography` `tailwind` `cheatsheet` `reference` `quick-lookup`

## 相关知识

- 设计原则-排版规范
- 可变字体与OpenType特性
- 文本换行与截断
