'use client';

import React from 'react';
import { motion } from 'framer-motion';
import { Upload, Download } from 'lucide-react';
import { useCompressionStore } from '@/context/CompressionContext';

const ModeSelector = React.memo(function ModeSelector() {
  const { mode, setMode } = useCompressionStore();

  return (
    <div className="flex justify-center mb-8 sm:mb-12 px-2 sm:px-0">
      <div 
        className="relative inline-flex p-1 rounded-2xl border backdrop-blur-xl theme-transition overflow-hidden" 
        style={{ backgroundColor: 'var(--theme-card-bg)', borderColor: 'var(--theme-border)' }}
      >
        <motion.div
          layoutId="tab-bg"
          className="absolute top-1 bottom-1 bg-linear-to-r from-blue-600 to-blue-400 rounded-xl will-change-transform"
          style={{ width: 'calc(50% - 4px)', left: '4px' }}
          animate={{
            x: mode === 'compress' ? '0%' : '100%',
          }}
          transition={{ type: 'spring', stiffness: 500, damping: 40 }}
        />
        <button
          onClick={() => setMode('compress')}
          type="button"
          className={`relative z-10 px-4 sm:px-12 py-3 sm:py-4 rounded-xl transition-colors cursor-pointer outline-none ${
            mode === 'compress' ? 'text-white' : 'opacity-60 hover:opacity-100'
          }`}
        >
          <div className="flex items-center gap-3">
            <Upload className="w-5 h-5" />
            <span className="font-medium whitespace-nowrap">Compress</span>
          </div>
        </button>
        <button
          onClick={() => setMode('decompress')}
          type="button"
          className={`relative z-10 px-4 sm:px-12 py-3 sm:py-4 rounded-xl transition-colors cursor-pointer outline-none ${
            mode === 'decompress' ? 'text-white' : 'opacity-60 hover:opacity-100'
          }`}
        >
          <div className="flex items-center gap-3">
            <Download className="w-5 h-5" />
            <span className="font-medium whitespace-nowrap">Decompress</span>
          </div>
        </button>
      </div>
    </div>
  );
});

export default ModeSelector;
