---
title: "GSAP 页面过渡动画"
description: "使用GSAP实现高性能的页面切换和路由过渡动画"
---

# GSAP 页面过渡动画

## 概述

GSAP (GreenSock Animation Platform) 是业界最强大的动画库，提供高性能、跨浏览器的动画解决方案。相比 CSS 动画和 Framer Motion，GSAP 提供了更精确的时间控制、更丰富的缓动函数，以及更专业的动画编排能力。

## 适用场景

### ✅ 适合的场景
- SPA 单页面应用的路由切换动画
- Tab 内容切换动画
- Modal/Drawer 弹出/关闭动画
- 需要复杂动画编排的场景
- 需要精确控制动画时间轴的场景
- 需要 FLIP 动画优化性能的场景

### ❌ 不适合的场景
- 简单的 fade in/out（CSS 动画即可）
- 需要完整 UI 组件库的场景
- 仅需要 hover 交互（CSS transition 即可）

## 快速使用

### 依赖安装

```bash
npm install gsap
# 或
yarn add gsap
```

### React 项目

#### 1. 创建页面过渡组件

```tsx
import { useEffect, useRef } from 'react';
import { gsap } from 'gsap';

interface PageTransitionProps {
  children: React.ReactNode;
  animation?: 'fade' | 'slide' | 'scale';
}

const PageTransition = ({ children, animation = 'fade' }: PageTransitionProps) => {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const element = ref.current;
    if (!element) return;

    let animationConfig = {};

    switch (animation) {
      case 'slide':
        animationConfig = { opacity: 0, x: 30 };
        break;
      case 'scale':
        animationConfig = { opacity: 0, scale: 0.95 };
        break;
      case 'fade':
      default:
        animationConfig = { opacity: 0 };
    }

    gsap.fromTo(
      element,
      animationConfig,
      {
        opacity: 1,
        x: 0,
        scale: 1,
        duration: 0.5,
        ease: 'power2.out',
      }
    );
  }, [animation]);

  return <div ref={ref}>{children}</div>;
};

export default PageTransition;
```

#### 2. 在路由中使用

```tsx
import { Routes, Route } from 'react-router-dom';
import PageTransition from './components/PageTransition';

const App = () => {
  return (
    <Routes>
      <Route
        path="/"
        element={
          <PageTransition animation="fade">
            <HomePage />
          </PageTransition>
        }
      />
      <Route
        path="/about"
        element={
          <PageTransition animation="slide">
            <AboutPage />
          </PageTransition>
        }
      />
      <Route
        path="/dashboard"
        element={
          <PageTransition animation="scale">
            <DashboardPage />
          </PageTransition>
        }
      />
    </Routes>
  );
};
```

### Vue 项目

#### 1. 使用 Transition 组件

```vue
<template>
  <Transition
    name="page"
    mode="out-in"
    @enter="onEnter"
    @leave="onLeave"
  >
    <slot />
  </Transition>
</template>

<script setup>
import { gsap } from 'gsap';

const onEnter = (el, done) => {
  gsap.fromTo(
    el,
    { opacity: 0, y: 30 },
    {
      opacity: 1,
      y: 0,
      duration: 0.4,
      ease: 'power2.out',
      onComplete: done,
    }
  );
};

const onLeave = (el, done) => {
  gsap.fromTo(
    el,
    { opacity: 1, y: 0 },
    {
      opacity: 0,
      y: -30,
      duration: 0.3,
      ease: 'power2.in',
      onComplete: done,
    }
  );
};
</script>

<style scoped>
.page-enter-active,
.page-leave-active {
  transition: opacity 0.3s ease;
}

.page-enter-from,
.page-leave-to {
  opacity: 0;
}
</style>
```

## 进阶用法

### 1. 复杂动画编排 (Timeline)

```tsx
import { useEffect, useRef } from 'react';
import { gsap } from 'gsap';

const ComplexTransition = () => {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const timeline = gsap.timeline();

    // 1. 先让旧内容退出
    timeline.to('.header', { y: -100, opacity: 0, duration: 0.3 });
    timeline.to('.content', { opacity: 0 }, '<0.1');
    timeline.to('.footer', { y: 50, opacity: 0 }, '<0.1');

    // 2. 显示过渡遮罩
    timeline.to('.overlay', {
      opacity: 1,
      duration: 0.2,
      ease: 'power2.in'
    });

    // 3. 新内容入场
    timeline.fromTo(
      '.new-header',
      { y: -100, opacity: 0 },
      { y: 0, opacity: 1, duration: 0.4 }
    );
    timeline.fromTo(
      '.new-content',
      { opacity: 0, scale: 0.95 },
      { opacity: 1, scale: 1, duration: 0.5 },
      '-=0.2'
    );
    timeline.fromTo(
      '.new-footer',
      { y: 50, opacity: 0 },
      { y: 0, opacity: 1, duration: 0.3 },
      '-=0.3'
    );

    // 4. 隐藏遮罩
    timeline.to('.overlay', { opacity: 0, duration: 0.2 });

  }, []);

  return (
    <div ref={containerRef} className="container">
      <div className="header new-header">Header</div>
      <div className="content new-content">Content</div>
      <div className="footer new-footer">Footer</div>
      <div className="overlay" style={{ opacity: 0 }} />
    </div>
  );
};
```

### 2. FLIP 动画 (高性能列表动画)

FLIP (First, Last, Invert, Play) 是一种优化列表项动画的技术，可以实现元素移动的流畅动画而无需重新渲染。

```tsx
import { useEffect, useRef } from 'react';
import { gsap } from 'gsap';

const FlipList = ({ items, onReorder }) => {
  const listRef = useRef<HTMLDivElement>(null);
  const prevPositions = useRef<Map<Element, DOMRect>>(new Map());

  // 记录初始位置
  const recordPositions = () => {
    const positions = new Map();
    const elements = listRef.current?.querySelectorAll('.list-item');
    elements?.forEach((el, index) => {
      positions.set(el, el.getBoundingClientRect());
    });
    prevPositions.current = positions;
  };

  // 执行动画
  const animate = () => {
    const elements = listRef.current?.querySelectorAll('.list-item');
    elements?.forEach((el) => {
      const prevPos = prevPositions.current.get(el);
      if (!prevPos) return;

      const currentPos = el.getBoundingClientRect();
      const deltaX = prevPos.left - currentPos.left;
      const deltaY = prevPos.top - currentPos.top;

      if (deltaX !== 0 || deltaY !== 0) {
        gsap.fromTo(
          el,
          { x: deltaX, y: deltaY },
          {
            x: 0,
            y: 0,
            duration: 0.5,
            ease: 'power2.out',
          }
        );
      }
    });
  };

  const handleDragEnd = () => {
    recordPositions();
    animate();
    onReorder?.();
  };

  return (
    <div ref={listRef} className="list">
      {items.map((item) => (
        <div
          key={item.id}
          className="list-item"
          draggable
          onDragEnd={handleDragEnd}
        >
          {item.name}
        </div>
      ))}
    </div>
  );
};
```

### 3. 滚动触发的页面元素

```tsx
import { useEffect, useRef } from 'react';
import { gsap } from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

const ScrollAnimation = () => {
  const sectionRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const section = sectionRef.current;
    if (!section) return;

    const elements = section.querySelectorAll('.animate-item');

    elements.forEach((el, index) => {
      gsap.fromTo(
        el,
        { opacity: 0, y: 50 },
        {
          opacity: 1,
          y: 0,
          duration: 0.6,
          delay: index * 0.1,
          ease: 'power2.out',
          scrollTrigger: {
            trigger: el,
            start: 'top 80%',
            end: 'bottom 20%',
            toggleActions: 'play none none reverse',
          },
        }
      );
    });

    return () => {
      ScrollTrigger.getAll().forEach((trigger) => trigger.kill());
    };
  }, []);

  return (
    <div ref={sectionRef}>
      <div className="animate-item">Item 1</div>
      <div className="animate-item">Item 2</div>
      <div className="animate-item">Item 3</div>
    </div>
  );
};
```

## 性能优化技巧

### 1. 使用 transform 替代 top/left

```css
/* ❌ 低性能 */
.element {
  position: absolute;
  top: 50px;
  left: 100px;
}

/* ✅ 高性能 */
.element {
  position: absolute;
  transform: translate(100px, 50px);
}
```

### 2. 启用 will-change

```css
.element {
  will-change: transform, opacity;
}
```

### 3. 批量更新

```tsx
// ❌ 多次触发布局
elements.forEach((el) => {
  gsap.to(el, { x: 100 });
});

// ✅ 批量更新
gsap.to(elements, {
  x: 100,
  stagger: 0.1, // 错开动画
});
```

## 常见问题

### Q1: 动画在移动端性能差？

**A**: 确保：
1. 使用 `transform` 而非 `top/left`
2. 添加 `will-change: transform`（但不要滥用）
3. 避免动画中触发布局重排的属性
4. 考虑使用 `will-change: transform` 或 CSS 的 `contain` 属性

### Q2: 退出动画如何实现？

**A**: 在组件卸载时执行退出动画：

```tsx
useEffect(() => {
  const element = ref.current;
  if (!element) return;

  // 入场动画
  gsap.fromTo(element, { opacity: 0 }, { opacity: 1 });

  // 返回清理函数处理退出
  return () => {
    gsap.to(element, { opacity: 0, duration: 0.3 });
  };
}, []);
```

### Q3: 与 React Router 集成时动画丢失？

**A**: 确保过渡组件包裹的是完整页面组件，而不是在路由切换时创建新组件实例。

```tsx
// ❌ 错误
<Route path="/page" component={<Page />} />

// ✅ 正确
<Route
  path="/page"
  element={
    <PageTransition>
      <Page />
    </PageTransition>
  }
/>
```

## 相关模式

- [ScrollTrigger 滚动动画]() - 滚动触发的高级动画
- [FLIP 动画]() - 高性能列表动画
- [Stagger 入场动画]() - 列表错开入场

## 参考资料

- [GSAP 官方文档](https://greensock.com/docs/)
- [GSAP ScrollTrigger 文档](https://greensock.com/docs/v3/Plugins/ScrollTrigger)
- [FLIP 动画技术](https://css-tricks.com/animating-layouts-with-the-flip-technique/)

---

## 元信息

| 属性 | 值 |
|-----|---|
| 复杂度 | ⭐⭐ (2/5星) |
| 依赖 | gsap, (react-router-dom 可选) |
| 标签 | gsap, 页面过渡, 转场, react, vue |
| 创建日期 | 2026-09-04 |
| 技术栈 | React / Vue / 通用 |
