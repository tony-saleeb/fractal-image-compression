'use client';

import React from 'react';
import { Zap } from 'lucide-react';
import { useTheme } from '@/context/ThemeContext';

const Footer = React.memo(function Footer() {
  const { isDark } = useTheme();

  return (
    <footer className="relative z-20 border-t px-8 py-10 theme-transition backdrop-blur-xl" style={{ borderColor: 'var(--theme-border)' }}>
      <div className="max-w-6xl mx-auto flex flex-col md:flex-row justify-between items-center gap-6 text-sm">
        <div className="flex items-center gap-4">
          <div className="w-8 h-8 bg-blue-600/10 rounded-lg flex items-center justify-center border border-blue-500/20">
            <Zap className="w-4 h-4 text-blue-500" />
          </div>
          <p className={`${isDark ? 'opacity-40' : 'opacity-70 text-blue-900'} font-medium`}>
            © 2026 DeepFract. Neural compression technology.
          </p>
        </div>
        <div className={`flex gap-10 ${isDark ? 'opacity-60' : 'opacity-90 font-medium text-blue-800'}`}>
          <a href="#" className="hover:text-blue-500 transition-colors">Privacy</a>
          <a href="#" className="hover:text-blue-500 transition-colors">Terms</a>
          <a href="#" className="hover:text-blue-500 transition-colors">GitHub</a>
        </div>
      </div>
    </footer>
  );
});

export default Footer;
