'use client';

import React from 'react';
import { motion } from 'framer-motion';
import { Check, X, Image as ImageIcon, FileWarning } from 'lucide-react';
import { useCompressionStore } from '@/context/CompressionContext';
import { useTheme } from '@/context/ThemeContext';
import { formatBytes } from '@/lib/api';

export default function PreviewView() {
  const { isDark } = useTheme();
  const { mode, originalFile, originalPreviewUrl, confirmProcessing, reset } = useCompressionStore();

  if (!originalFile) return null;

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.95 }}
      className="max-w-3xl mx-auto w-full flex flex-col items-center justify-center p-4 sm:p-8"
    >
      <div className={`w-full p-6 sm:p-10 rounded-3xl border backdrop-blur-xl shadow-2xl flex flex-col items-center text-center gap-8 ${
        isDark 
          ? 'bg-white/10 border-white/10 shadow-black/50' 
          : 'bg-white/90 border-gray-200 shadow-blue-500/10'
      }`}>
        
        <div className="flex flex-col gap-2 items-center">
          <h2 className={`text-2xl sm:text-3xl font-bold tracking-tight ${isDark ? 'text-white' : 'text-gray-900'}`}>
            Ready to {mode === 'compress' ? 'Compress' : 'Decompress'}?
          </h2>
          <p className={`text-sm opacity-60 ${isDark ? 'text-white' : 'text-gray-600'}`}>
            Review the selected file before applying neural processing.
          </p>
        </div>

        <div className={`w-full max-w-md aspect-video sm:aspect-square max-h-[300px] rounded-2xl overflow-hidden flex items-center justify-center shadow-inner ${
          isDark ? 'bg-black/40 border border-white/5' : 'bg-gray-100 border border-gray-200'
        }`}>
          {mode === 'compress' && originalPreviewUrl ? (
            <img 
              src={originalPreviewUrl} 
              alt="Preview" 
              className="w-full h-full object-contain"
            />
          ) : (
            <div className="flex flex-col items-center gap-4 p-6 opacity-60">
              {mode === 'compress' ? <ImageIcon className="w-16 h-16" /> : <FileWarning className="w-16 h-16" />}
              <span className="font-mono text-xs text-center break-all">
                {originalFile.name}
              </span>
            </div>
          )}
        </div>

        <div className="w-full grid grid-cols-2 gap-4 text-left bg-black/5 p-4 rounded-xl border border-white/5">
          <div>
            <p className="text-[10px] uppercase font-bold opacity-40">File Name</p>
            <p className="text-sm font-medium truncate" title={originalFile.name}>
              {originalFile.name}
            </p>
          </div>
          <div>
            <p className="text-[10px] uppercase font-bold opacity-40">Original Size</p>
            <p className="text-sm font-medium">{formatBytes(originalFile.size)}</p>
          </div>
        </div>

        <div className="flex w-full gap-4 pt-4">
          <button
            onClick={reset}
            className={`flex-1 py-3 px-4 rounded-xl font-medium flex items-center justify-center gap-2 transition-transform hover:scale-[1.02] active:scale-[0.98] ${
              isDark 
                ? 'bg-white/5 hover:bg-white/10 text-white' 
                : 'bg-gray-100 hover:bg-gray-200 text-gray-900'
            }`}
          >
            <X className="w-5 h-5" />
            Cancel
          </button>
          
          <button
            onClick={confirmProcessing}
            className="flex-1 py-3 px-4 rounded-xl font-bold flex items-center justify-center gap-2 text-white shadow-lg transition-transform hover:scale-[1.02] active:scale-[0.98] bg-blue-600 hover:bg-blue-500 shadow-blue-600/30"
          >
            <Check className="w-5 h-5" />
            Confirm
          </button>
        </div>
      </div>
    </motion.div>
  );
}
