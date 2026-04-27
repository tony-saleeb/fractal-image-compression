'use client';

import React from 'react';
import Link from 'next/link';
import { useTheme } from '@/context/ThemeContext';
import logoImg from '../../public/images/logo.png';

const Footer = React.memo(function Footer() {
  const { isDark } = useTheme();

  return (
    <footer className="relative z-20 border-t px-8 py-10 theme-transition backdrop-blur-xl" style={{ borderColor: 'var(--theme-border)' }}>
      <div className="max-w-6xl mx-auto flex flex-col md:flex-row justify-between items-center gap-6 text-sm">
        <div className="flex items-center gap-4">
          <div className="w-8 h-8 rounded-lg flex items-center justify-center border border-blue-500/20 overflow-hidden bg-blue-500/5">
            <img src={logoImg.src} alt="DeepFract" className="w-6 h-6 object-contain" />
          </div>
          <p className={`${isDark ? 'opacity-40' : 'opacity-70 text-blue-900'} font-medium`}>
            © 2026 DeepFract. Neural compression technology.
          </p>
        </div>
        <div className={`flex flex-wrap gap-4 md:gap-8 ${isDark ? 'opacity-60' : 'opacity-90 font-medium text-blue-800'}`}>
          <Link href="/faq" className="hover:text-blue-500 transition-colors">FAQ</Link>
          <Link href="/help" className="hover:text-blue-500 transition-colors">Help</Link>
          <Link href="/privacy" className="hover:text-blue-500 transition-colors">Privacy</Link>
          <Link href="/terms" className="hover:text-blue-500 transition-colors">Terms</Link>
        </div>
      </div>
    </footer>
  );
});

export default Footer;
