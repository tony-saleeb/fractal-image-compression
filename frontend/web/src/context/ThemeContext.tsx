'use client';

import React, { createContext, useContext, useState, useEffect, useCallback, useMemo } from 'react';

type Theme = 'dark' | 'light';

interface ThemeContextType {
  theme: Theme;
  isDark: boolean;
  toggleTheme: () => void;
  setTheme: (theme: Theme) => void;
  mounted: boolean;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setThemeState] = useState<Theme>('dark');
  const [mounted, setMounted] = useState(false);

  // Initialize theme from storage
  useEffect(() => {
    const saved = localStorage.getItem('deepfract-theme') as Theme;
    if (saved) {
      setThemeState(saved);
      if (saved === 'light') {
        document.documentElement.classList.add('light-theme');
        document.documentElement.style.colorScheme = 'light';
      }
    }
    setMounted(true);
  }, []);

  const setTheme = useCallback((newTheme: Theme) => {
    setThemeState(newTheme);
    localStorage.setItem('deepfract-theme', newTheme);
    
    // Apply immediately to DOM
    if (newTheme === 'light') {
      document.documentElement.classList.add('light-theme');
      document.documentElement.style.colorScheme = 'light';
    } else {
      document.documentElement.classList.remove('light-theme');
      document.documentElement.style.colorScheme = 'dark';
    }
  }, []);

  const toggleTheme = useCallback(() => {
    const nextTheme = theme === 'dark' ? 'light' : 'dark';
    setTheme(nextTheme);
  }, [theme, setTheme]);

  // Use useMemo for the context value to prevent unnecessary re-renders of the whole app
  const value = useMemo(() => ({
    theme,
    isDark: theme === 'dark',
    toggleTheme,
    setTheme,
    mounted
  }), [theme, toggleTheme, setTheme, mounted]);

  return (
    <ThemeContext.Provider value={value}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const context = useContext(ThemeContext);
  if (context === undefined) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
}
