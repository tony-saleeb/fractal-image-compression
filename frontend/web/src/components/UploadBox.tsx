'use client';

import React, { useState, useRef, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Upload, Download } from 'lucide-react';
import { useCompressionStore } from '@/context/CompressionContext';
import { useTheme } from '@/context/ThemeContext';

const UploadBox = React.memo(function UploadBox() {
  const { isDark } = useTheme();
  const { mode, tier, setTier, previewFile } = useCompressionStore();
  const [isDragging, setIsDragging] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const onFileSelected = useCallback((file: File) => {
    previewFile(file);
  }, [previewFile]);

  const onDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
    const file = e.dataTransfer.files?.[0];
    if (file) onFileSelected(file);
  };

  const onInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) onFileSelected(file);
    e.target.value = '';
  };

  return (
    <div className="max-w-4xl mx-auto">
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ delay: 0.1 }}
        className="h-full"
      >
        <div
          onDragEnter={() => setIsDragging(true)}
          onDragOver={(e) => { e.preventDefault(); setIsDragging(true); }}
          onDragLeave={() => setIsDragging(false)}
          onDrop={onDrop}
          onClick={() => fileInputRef.current?.click()}
          className={`relative group h-full min-h-72 sm:min-h-112.5 rounded-3xl border-2 border-dashed transition-all cursor-pointer backdrop-blur-xl flex flex-col items-center justify-center p-6 sm:p-12 will-change-gpu ${
            isDragging
              ? 'border-blue-500 bg-blue-500/10'
              : 'border-current opacity-60 hover:opacity-100 hover:border-blue-500/40 bg-white/5'
          }`}
          style={{ borderColor: isDragging ? undefined : 'var(--theme-border)' }}
        >
          <div className="absolute inset-0 bg-linear-to-br from-blue-500/10 via-blue-400/5 to-blue-300/10 rounded-3xl opacity-0 group-hover:opacity-100 transition-opacity" />

          <div className="relative z-10 flex flex-col items-center">
            <motion.div
              animate={isDragging ? { scale: 1.05 } : { scale: 1 }}
              whileHover={{ scale: 1.02, filter: 'brightness(1.1)' }}
              className="mb-10 relative group/icon"
            >
              <div className="relative w-32 h-32 flex items-center justify-center transition-all duration-300">
                {/* ── Dynamic Theme Aura ── */}
                <div className={`absolute inset-0 blur-3xl rounded-full scale-110 animate-pulse-glow transition-all duration-300 ${
                  isDark ? 'bg-blue-500/20 opacity-100' : 'bg-blue-400/10 opacity-60'
                }`} />
                
                {/* ── Professional Glass Container ── */}
                <div 
                  className={`absolute inset-0 rounded-4xl border backdrop-blur-2xl transition-all duration-300 overflow-hidden ${
                    isDark 
                      ? 'bg-linear-to-br from-white/10 to-transparent border-white/20 shadow-[0_20px_50px_rgba(0,0,0,0.5),inset_0_2px_10px_rgba(255,255,255,0.1)]' 
                      : 'bg-white/80 border-blue-500/20 shadow-[0_15px_40px_rgba(0,122,255,0.12),inset_0_2px_10px_rgba(255,255,255,0.5)]'
                  }`}
                >
                  <div className={`absolute inset-0 transition-opacity duration-300 ${
                    isDark ? 'bg-[radial-gradient(circle_at_50%_0%,rgba(255,255,255,0.15),transparent_70%)]' : 'bg-[radial-gradient(circle_at_50%_0%,rgba(0,122,255,0.05),transparent_70%)]'
                  }`} />
                </div>

                {/* ── Inner Glowing Ring ── */}
                <div className={`absolute inset-4 rounded-3xl border transition-all duration-300 animate-pulse ${
                  isDark ? 'border-blue-500/30 shadow-[0_0_15px_rgba(59,130,246,0.2)]' : 'border-blue-400/40 shadow-[0_0_15px_rgba(59,130,246,0.1)]'
                }`} style={{ animationDuration: '4s' }} />

                {/* ── The Icon ── */}
                <div className="relative z-10 w-full h-full flex items-center justify-center">
                  <AnimatePresence mode="wait">
                    {mode === 'compress' ? (
                      <motion.div 
                        key="c" 
                        initial={{ opacity: 0, rotate: -180, scale: 0.5 }} 
                        animate={{ opacity: 1, rotate: 0, scale: 1 }} 
                        exit={{ opacity: 0, rotate: 180, scale: 0.5 }}
                        transition={{ type: 'spring', damping: 25, stiffness: 500 }}
                      >
                        <div className="relative group-hover/icon:scale-110 transition-transform duration-300">
                          <Upload 
                            className={`w-14 h-14 transition-all duration-300 ${
                              isDark ? 'text-blue-400 drop-shadow-[0_0_10px_rgba(96,165,250,0.6)]' : 'text-blue-600 drop-shadow-[0_0_8px_rgba(0,122,255,0.3)]'
                            }`} 
                            strokeWidth={1.5} 
                          />
                          <div className={`absolute -inset-2 blur-xl opacity-0 group-hover/icon:opacity-100 transition-opacity ${
                            isDark ? 'bg-blue-400/20' : 'bg-blue-500/10'
                          }`} />
                        </div>
                      </motion.div>
                    ) : (
                      <motion.div 
                        key="d" 
                        initial={{ opacity: 0, rotate: -180, scale: 0.5 }} 
                        animate={{ opacity: 1, rotate: 0, scale: 1 }} 
                        exit={{ opacity: 0, rotate: 180, scale: 0.5 }}
                        transition={{ type: 'spring', damping: 25, stiffness: 500 }}
                      >
                        <div className="relative group-hover/icon:scale-110 transition-transform duration-300">
                          <Download 
                            className={`w-14 h-14 transition-all duration-300 ${
                              isDark ? 'text-blue-300 drop-shadow-[0_0_10px_rgba(147,197,253,0.6)]' : 'text-blue-500 drop-shadow-[0_0_8px_rgba(0,122,255,0.3)]'
                            }`} 
                            strokeWidth={1.5} 
                          />
                          <div className={`absolute -inset-2 blur-xl opacity-0 group-hover/icon:opacity-100 transition-opacity ${
                            isDark ? 'bg-blue-300/20' : 'bg-blue-400/10'
                          }`} />
                        </div>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </div>
              </div>
            </motion.div>

            <h2 className="text-3xl font-bold mb-4">
              {mode === 'compress' ? 'Drop Image Here' : 'Drop .fic File'}
            </h2>

            <p className="mb-8 text-center max-w-md opacity-60">
              Drag and drop your file or click to browse
            </p>

            <button
              type="button"
              className="group/btn relative px-6 py-4 sm:px-10 sm:py-5 bg-linear-to-r from-blue-600 to-blue-400 rounded-xl font-bold text-white hover:shadow-2xl hover:shadow-blue-500/50 transition-all cursor-pointer"
            >
              <span className="relative z-10">Select File</span>
              <div className="absolute inset-0 bg-white/20 rounded-xl opacity-0 group-hover/btn:opacity-100 transition-opacity" />
            </button>

            <p className={`text-xs mt-2 transition-colors ${isDark ? 'text-gray-400 group-hover/btn:text-blue-300' : 'text-blue-600/70 group-hover/btn:text-blue-800'}`}>
              {mode === 'compress' 
              ? 'JPG, PNG, WebP (No Size Limit)' 
              : 'DeepFract Archives (.fic)'}
            </p>
          </div>
        </div>
      </motion.div>

      <input
        ref={fileInputRef}
        type="file"
        className="hidden"
        accept={mode === 'compress' ? 'image/*' : '.fic'}
        onChange={onInputChange}
      />
    </div>
  );
});

export default UploadBox;
