'use client';

import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Activity, Sun, Moon, User } from 'lucide-react';
import { useTheme } from '@/context/ThemeContext';
import logoImg from '../../public/images/logo.png';

interface HeaderProps {
  onShowTutorial?: () => void;
}

const Header = React.memo(function Header({ onShowTutorial }: HeaderProps) {
  const { theme, toggleTheme, isDark } = useTheme();

  return (
    <header className="sticky top-0 z-50 w-full px-4 sm:px-8 py-3 sm:py-5 flex items-center justify-between border-b theme-transition backdrop-blur-md bg-white/2 hover:bg-white/5" style={{ borderColor: 'var(--theme-border)', backgroundColor: 'var(--theme-card-bg)' }}>
      <motion.div
        initial={{ opacity: 0, x: -20 }}
        animate={{ opacity: 1, x: 0 }}
        className="flex items-center gap-4"
      >
        <div className="relative">
          <div className="absolute inset-0 bg-blue-500 blur-2xl opacity-20" />
          <img 
            src={logoImg.src} 
            alt="DeepFract Logo" 
            className="relative w-12 h-12 sm:w-16 sm:h-16 object-contain"
          />
        </div>
        <div className="flex flex-col justify-center">
          <h1 className="text-xl sm:text-2xl font-bold tracking-tight bg-linear-to-r from-blue-400 to-blue-600 bg-clip-text text-transparent leading-none sm:leading-tight">
            DeepFract
          </h1>
          <p className={`text-[10px] uppercase tracking-widest ${isDark ? 'opacity-50' : 'opacity-70 font-semibold text-blue-600'}`}>
            Neural Latent Compression
          </p>
        </div>
      </motion.div>

      <motion.div
        initial={{ opacity: 0, x: 20 }}
        animate={{ opacity: 1, x: 0 }}
        className="flex items-center gap-4"
      >
        <div className="hidden lg:flex items-center gap-2 px-4 py-2 rounded-lg border theme-transition" style={{ backgroundColor: 'var(--theme-card-bg)', borderColor: 'var(--theme-border)' }}>
          <Activity className={`w-4 h-4 ${isDark ? 'text-green-400' : 'text-green-600'}`} />
          <span className={`text-sm ${isDark ? '' : 'font-medium'}`}>System Online</span>
        </div>

        <button
          onClick={toggleTheme}
          className="p-2 sm:p-3 rounded-lg border theme-transition cursor-pointer hover:opacity-80"
          style={{ backgroundColor: 'var(--theme-card-bg)', borderColor: 'var(--theme-border)' }}
        >
          <AnimatePresence mode="wait">
            {isDark ? (
              <motion.div key="sun" initial={{ rotate: -180, opacity: 0 }} animate={{ rotate: 0, opacity: 1 }} exit={{ rotate: 180, opacity: 0 }} transition={{ duration: 0.3 }}>
                <Sun className="w-4 h-4 sm:w-5 sm:h-5" />
              </motion.div>
            ) : (
              <motion.div key="moon" initial={{ rotate: -180, opacity: 0 }} animate={{ rotate: 0, opacity: 1 }} exit={{ rotate: 180, opacity: 0 }} transition={{ duration: 0.3 }}>
                <Moon className="w-4 h-4 sm:w-5 sm:h-5" />
              </motion.div>
            )}
          </AnimatePresence>
        </button>

        {onShowTutorial && (
          <button 
            onClick={onShowTutorial}
            className="hidden sm:flex p-2 sm:px-4 sm:py-2.5 rounded-lg border theme-transition cursor-pointer hover:opacity-80 items-center gap-2" 
            style={{ backgroundColor: 'var(--theme-card-bg)', borderColor: 'var(--theme-border)' }}
          >
            <span className={`text-sm font-medium ${isDark ? 'text-gray-300' : 'text-gray-700'}`}>Tutorial</span>
          </button>
        )}

        <button className="p-2 sm:p-3 rounded-lg border theme-transition cursor-pointer hover:opacity-80" style={{ backgroundColor: 'var(--theme-card-bg)', borderColor: 'var(--theme-border)' }}>
          <User className="w-4 h-4 sm:w-5 sm:h-5" />
        </button>
      </motion.div>
    </header>
  );
});

export default Header;
