---
title: "GSAP + useGSAP + Lenis 集成实践"
description: "React 项目中 GSAP + useGSAP hook + Lenis 平滑滚动与 ScrollTrigger 集成的最佳实践"
source_skill: "awwwards-animations"
source_files: ["SKILL.md", "references/gsap-react.md", "references/lenis-react.md"]
distill_type: "best"
distill_date: "2026-09-15"
tags: ["gsap", "useGSAP", "lenis", "react", "scrolltrigger", "集成"]
complexity: "⭐⭐⭐"
---

# GSAP + useGSAP + Lenis 集成实践

## 概述

| 属性 | 值 |
|-----|---|
| 源 | awwwards-animations/gsap-react.md + lenis-react.md |
| 适用 | React (含 Next.js) 项目的高级动画系统 |
| 关键原则 | **必须集成 Lenis 和 ScrollTrigger**，否则滚动动画全部错位 |

---

## 一、基础环境配置

### 1. GSAP 配置文件（项目级单例）

```tsx
// lib/gsap.ts
'use client' // Next.js App Router 必须

import gsap from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'
import { useGSAP } from '@gsap/react'

// 全局注册一次
gsap.registerPlugin(ScrollTrigger, useGSAP)

export { gsap, ScrollTrigger, useGSAP }
```

### 2. 安装依赖

```bash
npm install gsap @gsap/react lenis
```

| 库 | 版本 | 作用 |
|---|------|------|
| `gsap` | 3.14.1+ | 核心动画引擎 |
| `@gsap/react` | 最新 | React hook (useGSAP) |
| `lenis` | 1.3.17+ | 平滑滚动（含 React 组件） |

### 3. 必需的全局 CSS

```css
/* app/globals.css */
html.lenis,
html.lenis body {
  height: auto;
}

.lenis.lenis-smooth {
  scroll-behavior: auto !important;
}

.lenis.lenis-stopped {
  overflow: hidden;
}

.lenis.lenis-scrolling iframe {
  pointer-events: none;
}
```

---

## 二、Lenis 平滑滚动集成

### 1. SmoothScroll 组件（完整集成版）

```tsx
// components/SmoothScroll.tsx
'use client'

import { ReactLenis, useLenis } from 'lenis/react'
import { useEffect } from 'react'
import { gsap, ScrollTrigger } from '@/lib/gsap'

function LenisGSAPConnector() {
  const lenis = useLenis()

  useEffect(() => {
    if (!lenis) return

    // ⭐ 关键：让 ScrollTrigger 监听 Lenis 的滚动
    lenis.on('scroll', ScrollTrigger.update)

    // ⭐ 关键：用 GSAP ticker 驱动 Lenis RAF
    const update = (time: number) => lenis.raf(time * 1000)

    gsap.ticker.add(update)
    gsap.ticker.lagSmoothing(0)

    return () => {
      gsap.ticker.remove(update)
      lenis.off('scroll', ScrollTrigger.update)
    }
  }, [lenis])

  return null
}

export function SmoothScroll({ children }: { children: React.ReactNode }) {
  return (
    <ReactLenis
      root
      options={{
        lerp: 0.1,
        duration: 1.2,
        smoothWheel: true,
        wheelMultiplier: 1,
        touchMultiplier: 2,
        syncTouch: false,
      }}
    >
      <LenisGSAPConnector />
      {children}
    </ReactLenis>
  )
}
```

### 2. 在 Layout 中全局包裹

```tsx
// app/layout.tsx
import { SmoothScroll } from '@/components/SmoothScroll'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <SmoothScroll>{children}</SmoothScroll>
      </body>
    </html>
  )
}
```

### 3. Lenis 配置预设

```tsx
// 高端质感（Studio Freight 风格）
const premiumOptions = {
  lerp: 0.075,
  duration: 1.5,
  smoothWheel: true,
  wheelMultiplier: 0.8,
}

// 灵敏反馈
const snappyOptions = {
  lerp: 0.15,
  duration: 0.8,
  smoothWheel: true,
  wheelMultiplier: 1.2,
}

// 移动端友好
const mobileOptions = {
  lerp: 0.1,
  duration: 1.2,
  touchMultiplier: 1.5,
  syncTouch: true,
  syncTouchLerp: 0.075,
}
```

### 4. 路径变化时重置滚动（Next.js 关键）

```tsx
'use client'
import { useLenis } from 'lenis/react'
import { usePathname } from 'next/navigation'
import { useEffect } from 'react'

export function ScrollReset() {
  const lenis = useLenis()
  const pathname = usePathname()

  useEffect(() => {
    lenis?.scrollTo(0, { immediate: true })
  }, [pathname, lenis])

  return null
}
```

---

## 三、useGSAP 基础模式

### 1. 作用域（scope）模式

```tsx
'use client'
import { useRef } from 'react'
import { gsap, useGSAP } from '@/lib/gsap'

export function AnimatedBox() {
  const containerRef = useRef<HTMLDivElement>(null)

  useGSAP(
    () => {
      gsap.to('.box', { x: 360, rotation: 360, duration: 1 })
    },
    { scope: containerRef } // ⭐ 限定选择器只在 containerRef 内查找
  )

  return (
    <div ref={containerRef}>
      <div className="box">Animated</div>
    </div>
  )
}
```

### 2. 依赖驱动更新

```tsx
function AnimatedCounter({ count }: { count: number }) {
  const containerRef = useRef<HTMLDivElement>(null)

  useGSAP(
    () => {
      gsap.from('.counter', {
        textContent: 0,
        duration: 1,
        snap: { textContent: 1 },
      })
    },
    {
      scope: containerRef,
      dependencies: [count],  // count 变化时重跑
      revertOnUpdate: true,  // 重跑前先清理
    }
  )

  return (
    <div ref={containerRef}>
      <span className="counter">{count}</span>
    </div>
  )
}
```

### 3. 清理函数

```tsx
useGSAP(() => {
  const animation = gsap.to('.box', { x: 100 })

  return () => {
    // useGSAP 会自动 revert GSAP 创建的所有对象
    // 这里只放额外的手动清理逻辑
    console.log('Component unmounting')
  }
}, { scope: containerRef })
```

---

## 四、ScrollTrigger 核心模式

### 1. 基础滚动触发

```tsx
function ScrollSection() {
  const containerRef = useRef<HTMLDivElement>(null)

  useGSAP(() => {
    gsap.from('.content', {
      opacity: 0,
      y: 50,
      duration: 1,
      scrollTrigger: {
        trigger: '.content',
        start: 'top 80%',
        end: 'top 30%',
        toggleActions: 'play none none reverse',
        // markers: true, // 仅开发环境调试
      },
    })
  }, { scope: containerRef })

  return (
    <div ref={containerRef}>
      <div className="content">Scroll to reveal</div>
    </div>
  )
}
```

### 2. Scrub 跟随滚动

```tsx
function ScrubSection() {
  const containerRef = useRef<HTMLDivElement>(null)

  useGSAP(() => {
    gsap.to('.progress', {
      scaleX: 1,
      ease: 'none',
      scrollTrigger: {
        trigger: containerRef.current,
        start: 'top top',
        end: 'bottom bottom',
        scrub: 0.3, // 0.3 秒的平滑追赶
      },
    })
  }, { scope: containerRef })

  return (
    <div ref={containerRef} className="h-[300vh]">
      <div className="progress fixed top-0 left-0 h-1 w-full bg-blue-500 origin-left scale-x-0" />
    </div>
  )
}
```

### 3. Pin 钉住 + 滚动动画

```tsx
function PinnedSection() {
  const containerRef = useRef<HTMLDivElement>(null)

  useGSAP(() => {
    gsap.to('.pinned-content', {
      y: 200,
      opacity: 0.5,
      scrollTrigger: {
        trigger: containerRef.current,
        start: 'top top',
        end: '+=1000',   // 钉住 1000px 滚动距离
        pin: true,
        scrub: true,
        anticipatePin: 1, // 防止钉住瞬间跳动
      },
    })
  }, { scope: containerRef })

  return (
    <div ref={containerRef} className="h-screen">
      <div className="pinned-content">Pinned content</div>
    </div>
  )
}
```

### 4. 横向滚动

```tsx
function HorizontalScroll() {
  const containerRef = useRef<HTMLDivElement>(null)
  const wrapperRef = useRef<HTMLDivElement>(null)

  useGSAP(() => {
    const sections = gsap.utils.toArray<HTMLElement>('.panel')

    gsap.to(sections, {
      xPercent: -100 * (sections.length - 1),
      ease: 'none',
      scrollTrigger: {
        trigger: wrapperRef.current,
        pin: true,
        scrub: 1,
        snap: 1 / (sections.length - 1), // 每段对齐
        end: () => '+=' + wrapperRef.current!.offsetWidth,
      },
    })
  }, { scope: containerRef })

  return (
    <div ref={containerRef}>
      <div ref={wrapperRef} className="flex w-[400vw]">
        {[1, 2, 3, 4].map(i => (
          <div key={i} className="panel w-screen h-screen flex-shrink-0">
            Panel {i}
          </div>
        ))}
      </div>
    </div>
  )
}
```

### 5. 批量动画（grid）

```tsx
function BatchGrid() {
  const containerRef = useRef<HTMLDivElement>(null)

  useGSAP(() => {
    // ⭐ 比逐个创建 ScrollTrigger 更高效
    ScrollTrigger.batch('.grid-item', {
      onEnter: (elements) => {
        gsap.from(elements, {
          opacity: 0,
          y: 60,
          stagger: 0.1,
          duration: 0.6,
          ease: 'power3.out',
        })
      },
      start: 'top 85%',
    })
  }, { scope: containerRef })

  return (
    <div ref={containerRef} className="grid grid-cols-4 gap-4">
      {Array.from({ length: 16 }).map((_, i) => (
        <div key={i} className="grid-item aspect-square bg-gray-800" />
      ))}
    </div>
  )
}
```

---

## 五、contextSafe 模式（事件触发的动画）

### 1. 基础点击动画

```tsx
function ClickAnimation() {
  const containerRef = useRef<HTMLDivElement>(null)

  // ⭐ contextSafe 让事件回调里的 GSAP 自动跟随组件卸载清理
  const { contextSafe } = useGSAP({ scope: containerRef })

  const handleClick = contextSafe(() => {
    gsap.to('.box', {
      rotation: '+=360',
      duration: 0.5,
      ease: 'power2.out',
    })
  })

  return (
    <div ref={containerRef}>
      <button onClick={handleClick}>Rotate</button>
      <div className="box">Click to spin</div>
    </div>
  )
}
```

### 2. Hover 动画

```tsx
function HoverCard() {
  const containerRef = useRef<HTMLDivElement>(null)
  const { contextSafe } = useGSAP({ scope: containerRef })

  const onEnter = contextSafe(() => {
    gsap.to('.card-content', { y: -10, duration: 0.3 })
  })
  const onLeave = contextSafe(() => {
    gsap.to('.card-content', { y: 0, duration: 0.3 })
  })

  return (
    <div ref={containerRef} onMouseEnter={onEnter} onMouseLeave={onLeave}>
      <div className="card-content">Hover me</div>
    </div>
  )
}
```

---

## 六、高级文字动画

### 1. 字符级揭示（需 Club GSAP SplitText）

```tsx
import { SplitText } from 'gsap/SplitText'
gsap.registerPlugin(SplitText)

function TextReveal() {
  const textRef = useRef<HTMLHeadingElement>(null)
  const splitRef = useRef<SplitText | null>(null)

  useGSAP(() => {
    splitRef.current = new SplitText(textRef.current, {
      type: 'chars, words, lines',
      linesClass: 'overflow-hidden',
    })

    gsap.from(splitRef.current.chars, {
      opacity: 0,
      y: 100,
      rotateX: -90,
      stagger: 0.02,
      duration: 0.8,
      ease: 'back.out(1.7)',
      scrollTrigger: {
        trigger: textRef.current,
        start: 'top 80%',
      },
    })

    return () => splitRef.current?.revert()
  })

  return <h1 ref={textRef}>Animated Headline</h1>
}
```

### 2. 行级遮罩揭示

```tsx
function LineMaskReveal({ text }: { text: string }) {
  const containerRef = useRef<HTMLDivElement>(null)

  useGSAP(() => {
    gsap.from('.line-inner', {
      yPercent: 100,
      duration: 0.8,
      ease: 'power4.out',
      stagger: 0.1,
      scrollTrigger: {
        trigger: containerRef.current,
        start: 'top 80%',
      },
    })
  }, { scope: containerRef })

  return (
    <div ref={containerRef}>
      {text.split('\n').map((line, i) => (
        <div key={i} className="overflow-hidden">
          <div className="line-inner">{line}</div>
        </div>
      ))}
    </div>
  )
}
```

---

## 七、SVG 动画

### 1. DrawSVG（路径绘制）

```tsx
import { DrawSVGPlugin } from 'gsap/DrawSVGPlugin'
gsap.registerPlugin(DrawSVGPlugin)

function DrawSVG() {
  const svgRef = useRef<SVGSVGElement>(null)

  useGSAP(() => {
    gsap.from('.draw-path', {
      drawSVG: '0%',
      duration: 2,
      ease: 'power2.inOut',
      stagger: 0.2,
      scrollTrigger: {
        trigger: svgRef.current,
        start: 'top 70%',
      },
    })
  })

  return (
    <svg ref={svgRef} viewBox="0 0 100 100">
      <path className="draw-path" d="M10,50 Q50,10 90,50" fill="none" stroke="white" />
    </svg>
  )
}
```

### 2. MorphSVG（形状变形）

```tsx
import { MorphSVGPlugin } from 'gsap/MorphSVGPlugin'
gsap.registerPlugin(MorphSVGPlugin)

function MorphShape() {
  const shapeRef = useRef<SVGPathElement>(null)
  const { contextSafe } = useGSAP()

  const morph = contextSafe(() => {
    gsap.to(shapeRef.current, {
      morphSVG: '#target-shape',
      duration: 1,
      ease: 'power2.inOut',
    })
  })

  return (
    <svg viewBox="0 0 100 100">
      <path ref={shapeRef} id="start-shape" d="M50,10 L90,90 L10,90 Z" />
      <path id="target-shape" d="M50,10 A40,40 0 1,1 50,90 A40,40 0 1,1 50,10" style={{ visibility: 'hidden' }} />
      <button onClick={morph}>Morph</button>
    </svg>
  )
}
```

---

## 八、Lenis useLenis 进阶用法

### 1. 滚动进度条

```tsx
function ScrollProgress() {
  const [progress, setProgress] = useState(0)

  useLenis(({ scroll, limit }) => {
    setProgress(scroll / limit)
  })

  return (
    <div
      className="fixed top-0 left-0 h-1 bg-blue-500 z-50"
      style={{ width: `${progress * 100}%` }}
    />
  )
}
```

### 2. 滚动到指定元素

```tsx
function ScrollToSection() {
  const lenis = useLenis()

  const scrollToSection = (id: string) => {
    const element = document.getElementById(id)
    if (element && lenis) {
      lenis.scrollTo(element, {
        offset: -100,
        duration: 1.5,
        easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
      })
    }
  }

  return (
    <nav>
      <button onClick={() => scrollToSection('about')}>About</button>
      <button onClick={() => scrollToSection('work')}>Work</button>
      <button onClick={() => scrollToSection('contact')}>Contact</button>
    </nav>
  )
}
```

### 3. Modal 打开时停止滚动

```tsx
function Modal({ isOpen, onClose, children }) {
  const lenis = useLenis()

  useEffect(() => {
    if (isOpen) {
      lenis?.stop()
    } else {
      lenis?.start()
    }
  }, [isOpen, lenis])

  if (!isOpen) return null
  return <div className="fixed inset-0 z-50">{children}</div>
}
```

### 4. 速度驱动的倾斜效果

```tsx
function VelocitySkew() {
  const textRef = useRef<HTMLHeadingElement>(null)

  useLenis(({ velocity }) => {
    gsap.to(textRef.current, {
      skewY: velocity * 0.05,
      duration: 0.3,
      ease: 'power2.out',
    })
  })

  return <h1 ref={textRef}>Velocity Skew Text</h1>
}
```

---

## 九、滚动方向感知 Header

```tsx
function DirectionAwareHeader() {
  const [isVisible, setIsVisible] = useState(true)

  useLenis(({ direction }) => {
    setIsVisible(direction <= 0) // 上滑显示
  })

  return (
    <header
      className={`fixed top-0 transition-transform duration-300 ${
        isVisible ? 'translate-y-0' : '-translate-y-full'
      }`}
    >
      Header
    </header>
  )
}
```

---

## 十、关键陷阱与修复

### 1. Lenis 初始化后 ScrollTrigger 失效

```tsx
// ✅ Lenis 实例可用后调用 refresh
useEffect(() => {
  if (lenis) {
    ScrollTrigger.refresh()
  }
}, [lenis])
```

### 2. Next.js 路由切换后动画残留

```tsx
// app/_components/ScrollTriggerCleanup.tsx
'use client'
import { usePathname } from 'next/navigation'
import { useEffect } from 'react'
import { ScrollTrigger } from 'gsap/ScrollTrigger'

export function ScrollTriggerCleanup() {
  const pathname = usePathname()

  useEffect(() => {
    return () => {
      ScrollTrigger.getAll().forEach(st => st.kill())
    }
  }, [pathname])

  return null
}
```

### 3. React 18 Strict Mode 双调用

```tsx
// ✅ useGSAP 自动处理 Strict Mode 双 effect 调用
// 普通 useEffect + gsap.to 需要手动清理
```

### 4. SSR/Next.js

```tsx
// ⭐ 所有使用 useGSAP 的组件必须 'use client'
'use client'
import { useGSAP } from '@gsap/react'
```

### 5. 动态内容后定位失效

```tsx
// 当 items 变化或图片加载后
useEffect(() => {
  ScrollTrigger.refresh()
}, [items])
```

---

## 十一、Mod 关闭局部滚动（特定元素）

```tsx
// data-lenis-prevent: 阻止该区域内滚动冒泡
<div data-lenis-prevent>
  <textarea>Scrollable text area</textarea>
</div>

// data-lenis-prevent-wheel: 仅阻止滚轮
<div data-lenis-prevent-wheel>
  <div className="horizontal-scroll">...</div>
</div>
```

---

## 十二、横向滚动 + Lenis

```tsx
function HorizontalSection() {
  const containerRef = useRef<HTMLDivElement>(null)
  const wrapperRef = useRef<HTMLDivElement>(null)

  useGSAP(() => {
    const sections = gsap.utils.toArray<HTMLElement>('.h-section')

    gsap.to(sections, {
      xPercent: -100 * (sections.length - 1),
      ease: 'none',
      scrollTrigger: {
        trigger: wrapperRef.current,
        pin: true,
        scrub: 1,
        snap: 1 / (sections.length - 1),
        end: () => '+=' + wrapperRef.current!.scrollWidth,
      },
    })
  }, { scope: containerRef })

  return (
    <div ref={containerRef}>
      <div ref={wrapperRef} className="flex" data-lenis-prevent-wheel>
        {[1, 2, 3, 4].map(i => (
          <div key={i} className="h-section w-screen h-screen flex-shrink-0">
            Section {i}
          </div>
        ))}
      </div>
    </div>
  )
}
```

---

## 完整项目结构示例

```
project/
├── lib/
│   └── gsap.ts                    # GSAP 注册
├── components/
│   ├── SmoothScroll.tsx           # Lenis 集成
│   ├── ScrollTriggerCleanup.tsx   # 路由清理
│   ├── ScrollReset.tsx            # 路由重置
│   └── Hero/
│       ├── MagneticCursor.tsx
│       └── ParallaxHero.tsx
└── app/
    ├── layout.tsx                 # 包裹 SmoothScroll + Cleanup + Reset
    ├── globals.css
    └── page.tsx
```

```tsx
// app/layout.tsx
import { SmoothScroll } from '@/components/SmoothScroll'
import { ScrollTriggerCleanup } from '@/components/ScrollTriggerCleanup'
import { ScrollReset } from '@/components/ScrollReset'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="zh-CN">
      <body>
        <SmoothScroll>
          <ScrollTriggerCleanup />
          <ScrollReset />
          {children}
        </SmoothScroll>
      </body>
    </html>
  )
}
```

---

## 相关知识

- [动效库选型决策矩阵](动效/动效库选型决策矩阵.md) — 选哪个库
- [文本动效全攻略](动效/文本动效全攻略.md) — 文字动画细节
- [动效性能优化指南](动效/动效性能优化指南.md) — 60fps 规则
- [GSAP 页面过渡](动效/gsap页面过渡.md) — 页面级切换
- [ScrollTrigger 滚动动画](动效/scroll-trigger.md) — 滚动触发细节

---

## 元信息

| 属性 | 值 |
|-----|---|
| 源 | awwwards-animations/gsap-react.md + lenis-react.md |
| 复杂度 | ⭐⭐⭐ (3/5) |
| 依赖 | gsap, @gsap/react, lenis |
| 标签 | gsap, useGSAP, lenis, scrolltrigger, react, 集成 |
| 创建日期 | 2026-09-15 |