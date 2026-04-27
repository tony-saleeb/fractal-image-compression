'use client';

import React from 'react';
import Header from '@/components/Header';
import Footer from '@/components/Footer';
import Background from '@/components/Background';
import { useTheme } from '@/context/ThemeContext';

export default function DocsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { isDark } = useTheme();

  return (
    <div className="min-h-screen relative overflow-hidden flex flex-col">
      <Background />
      <Header />

      <main className="relative z-10 flex flex-col grow px-6 pt-16 pb-32">
        <div className={`w-full max-w-4xl mx-auto p-8 sm:p-12 rounded-3xl backdrop-blur-xl border ${isDark ? 'bg-black/40 border-white/10' : 'bg-white/60 border-blue-500/10 shadow-2xl'}`}>
          {children}
        </div>
      </main>

      <Footer />
    </div>
  );
}
