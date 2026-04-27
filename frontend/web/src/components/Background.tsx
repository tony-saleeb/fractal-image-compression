'use client';

import React, { useEffect, memo } from 'react';
import { motion } from 'framer-motion';
import { useTheme } from '@/context/ThemeContext';

/* ─── Floating Fractal Helper ───────────────────────────────────────────── */

const FloatingFractal = memo(function FloatingFractal({ id, size, x, y, delay }: { id: number, size: number, x: string, y: string, delay: number }) {
  return (
    <motion.div
      initial={{ opacity: 0, rotate: 0 }}
      animate={{ 
        opacity: [0.03, 0.08, 0.03],
        rotate: [0, 360],
        scale: [1, 1.1, 1]
      }}
      transition={{ 
        duration: 40, 
        repeat: Infinity, 
        ease: "linear",
        delay
      }}
      className="absolute flex items-center justify-center pointer-events-none"
      style={{ width: size, height: size, left: x, top: y }}
    >
      <div 
        className="absolute inset-0 border rounded-[30%_70%_70%_30%/30%_30%_70%_70%] pointer-events-none theme-transition"
        style={{ borderWidth: '1px', borderColor: 'var(--theme-grid-color)' }}
      />
      <div 
        className="absolute inset-4 border rounded-[70%_30%_30%_70%/70%_70%_30%_30%] pointer-events-none theme-transition"
        style={{ borderWidth: '1px', opacity: 0.5, borderColor: 'var(--theme-grid-color)' }}
      />
    </motion.div>
  );
});

/* ─── Main Background Component ────────────────────────────────────────── */

const Background = memo(function Background() {
  const { isDark } = useTheme();

  // Mouse tracking using native CSS Variables (Stops React re-renders on mousemove)
  useEffect(() => {
    const root = document.documentElement;
    const handler = (e: MouseEvent) => {
      root.style.setProperty('--mx', `${e.clientX}px`);
      root.style.setProperty('--my', `${e.clientY}px`);
    };
    window.addEventListener('mousemove', handler, { passive: true });
    return () => window.removeEventListener('mousemove', handler);
  }, []);

  return (
    <div className="fixed inset-0 overflow-hidden pointer-events-none">
      {/* ── Premium Mesh Background ─────────────────────────────────────────── */}
      <div className="absolute inset-0">
        <motion.div
          animate={{
            x: [0, 400, 200, 0],
            y: [0, 200, 400, 0],
            scale: [1, 1.2, 0.8, 1],
          }}
          transition={{ duration: 25, repeat: Infinity, ease: "easeInOut" }}
          className="absolute -top-1/4 -left-1/4 w-[80vw] h-[80vh] rounded-full blur-[120px] theme-transition will-change-transform"
          style={{ 
            backgroundColor: 'var(--theme-blob-1)', 
            opacity: isDark ? 0.08 : 0.05,
            backfaceVisibility: 'hidden',
          }}
        />
        <motion.div
          animate={{
            x: [0, -300, -150, 0],
            y: [0, 400, 100, 0],
            scale: [0.8, 1.1, 0.9, 0.8],
          }}
          transition={{ duration: 30, repeat: Infinity, ease: "easeInOut", delay: 2 }}
          className="absolute top-1/4 -right-1/4 w-[70vw] h-[70vh] rounded-full blur-[100px] theme-transition will-change-transform"
          style={{ 
            backgroundColor: 'var(--theme-blob-2)', 
            opacity: isDark ? 0.08 : 0.05,
            backfaceVisibility: 'hidden',
          }}
        />
        <motion.div
          animate={{
            x: [0, 200, -200, 0],
            y: [0, -200, 200, 0],
            scale: [1.1, 0.8, 1.2, 1.1],
          }}
          transition={{ duration: 35, repeat: Infinity, ease: "easeInOut", delay: 5 }}
          className="absolute -bottom-1/4 left-1/3 w-[60vw] h-[60vh] rounded-full blur-[120px] theme-transition will-change-transform"
          style={{ 
            backgroundColor: 'var(--theme-blob-3)', 
            opacity: isDark ? 0.08 : 0.05,
            backfaceVisibility: 'hidden',
          }}
        />
      </div>

      {/* Dual-Layer Neural Grid (Cross-fade) */}
      <div 
        className="absolute inset-0 neural-pattern theme-transition opacity-[0.07] dark:opacity-[0.07]"
        style={{
          backgroundImage: `radial-gradient(circle at center, var(--theme-grid-color) 0.5px, transparent 0.5px)`,
          backgroundSize: '40px 40px',
        }}
      />

      {/* Interactive Spotlight (Handled by GPU transforms) */}
      <div
        className="absolute w-150 h-150 rounded-full pointer-events-none theme-transition will-change-transform"
        style={{
          background: `radial-gradient(circle at center, var(--theme-spotlight) 0%, transparent 70%)`,
          transform: 'translate3d(calc(var(--mx, 50vw) - 50%), calc(var(--my, 50vh) - 50%), 0)',
          transition: 'background-color var(--theme-transition)',
          backfaceVisibility: 'hidden',
        }}
      />

      {/* Fractal Floating Elements (Subtle Rotating Outlines) */}
      <div className="absolute inset-0">
        <FloatingFractal id={1} size={300} x="20%" y="15%" delay={0} />
        <FloatingFractal id={2} size={450} x="75%" y="60%" delay={10} />
        <FloatingFractal id={3} size={200} x="45%" y="80%" delay={5} />
      </div>
    </div>
  );
});

export default Background;
