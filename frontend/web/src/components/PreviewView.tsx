'use client';

import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Sparkles, X, Image as ImageIcon, FileArchive, ArrowRight, HardDrive, Cpu } from 'lucide-react';
import { useCompressionStore } from '@/context/CompressionContext';
import { useTheme } from '@/context/ThemeContext';
import { formatBytes } from '@/lib/api';

export default function PreviewView() {
  const { isDark } = useTheme();
  const { mode, originalFile, originalPreviewUrl, confirmProcessing, reset } = useCompressionStore();

  if (!originalFile) return null;

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20, scale: 0.98 }}
      className="max-w-4xl mx-auto w-full px-2 sm:px-0"
    >
      <div className={`relative overflow-hidden rounded-4xl border shadow-2xl transition-all duration-500 ${
        isDark 
          ? 'bg-[#0f111a]/80 border-white/10 shadow-[0_30px_60px_-15px_rgba(0,0,0,0.8)] backdrop-blur-3xl' 
          : 'bg-white/90 border-blue-100 shadow-[0_30px_60px_-15px_rgba(0,120,255,0.15)] backdrop-blur-2xl'
      }`}>
        
        {/* Decorative dynamic lighting */}
        <div className="absolute top-0 inset-x-0 h-px bg-linear-to-r from-transparent via-blue-500/50 to-transparent" />
        <div className={`absolute -top-40 -right-40 w-80 h-80 rounded-full blur-[100px] pointer-events-none ${isDark ? 'bg-blue-600/20' : 'bg-blue-400/20'}`} />
        <div className={`absolute -bottom-40 -left-40 w-80 h-80 rounded-full blur-[100px] pointer-events-none ${isDark ? 'bg-purple-600/10' : 'bg-blue-300/20'}`} />

        <div className="relative z-10 flex flex-col md:flex-row p-6 sm:p-8 gap-8 items-center md:items-stretch">
          
          {/* ── Left Side: Neural Preview Window ── */}
          <div className="w-full md:w-[45%] shrink-0">
            <div className={`relative w-full aspect-video md:aspect-square rounded-3xl overflow-hidden group border ${
              isDark ? 'bg-black/60 border-white/5 shadow-inner shadow-white/5' : 'bg-gray-50/80 border-gray-200/60 shadow-inner shadow-black/5'
            }`}>
              
              <div className="absolute top-3 left-3 z-10 px-3 py-1.5 rounded-full bg-blue-500/20 backdrop-blur-md border border-blue-500/30 text-[10px] font-bold text-blue-500 uppercase tracking-widest shadow-lg flex items-center gap-1.5">
                <span className="relative flex h-2 w-2">
                  <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-blue-400 opacity-75"></span>
                  <span className="relative inline-flex rounded-full h-2 w-2 bg-blue-500"></span>
                </span>
                Target Acquired
              </div>

              {mode === 'compress' && originalPreviewUrl ? (
                <>
                  <motion.img 
                    initial={{ opacity: 0, filter: 'blur(10px)', scale: 1.05 }}
                    animate={{ opacity: 1, filter: 'blur(0px)', scale: 1 }}
                    transition={{ duration: 0.4, ease: "easeOut" }}
                    src={originalPreviewUrl} 
                    alt="Preview" 
                    className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105"
                  />
                  <div className="absolute inset-0 bg-linear-to-t from-black/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                </>
              ) : (
                <div className="w-full h-full flex flex-col items-center justify-center p-6 text-center">
                  <div className={`p-4 rounded-2xl mb-4 ${isDark ? 'bg-white/5 text-blue-400' : 'bg-blue-50 text-blue-600'}`}>
                    {mode === 'compress' ? <ImageIcon className="w-10 h-10" /> : <FileArchive className="w-10 h-10" />}
                  </div>
                  <span className={`font-mono text-xs break-all max-w-full ${isDark ? 'text-white/60' : 'text-gray-500'}`}>
                    {originalFile.name}
                  </span>
                </div>
              )}
            </div>
          </div>

          {/* ── Right Side: Processing Controls & Info ── */}
          <div className="flex-1 min-w-0 flex flex-col justify-between py-2">
            
            <div className="space-y-2">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-blue-500/10 text-blue-500 border border-blue-500/20 text-xs font-semibold uppercase tracking-wide mb-2">
                <Cpu className="w-3.5 h-3.5" />
                {mode === 'compress' ? 'Neural Compression' : 'Fractal Decoding'}
              </div>
              <h2 className={`text-2xl sm:text-3xl font-bold tracking-tight ${isDark ? 'text-white' : 'text-gray-900'}`}>
                Engage DeepFract Engine?
              </h2>
              <p className={`text-sm leading-relaxed ${isDark ? 'text-white/50' : 'text-gray-500'}`}>
                {mode === 'compress' 
                  ? "Your payload is ready. Our neural network will analyze and compress this image using advanced fractal patterns." 
                  : "Encrypted payload detected. The AI will now reconstruct your high-fidelity image from the compressed parameters."}
              </p>
            </div>

            <div className={`mt-6 p-4 rounded-2xl border flex items-center justify-between gap-4 ${
              isDark ? 'bg-white/5 border-white/5' : 'bg-gray-50/80 border-gray-200/50'
            }`}>
              <div className="flex items-center gap-3 overflow-hidden flex-1 min-w-0">
                <div className={`p-2 rounded-xl shrink-0 ${isDark ? 'bg-white/10 text-white/60' : 'bg-white text-gray-500 shadow-sm'}`}>
                  <HardDrive className="w-5 h-5" />
                </div>
                <div className="min-w-0 flex-1">
                  <p className={`text-[10px] uppercase font-bold tracking-wider ${isDark ? 'text-white/40' : 'text-gray-400'}`}>Source Payload</p>
                  <p className={`text-sm font-semibold truncate ${isDark ? 'text-white/90' : 'text-gray-800'}`} title={originalFile.name}>
                    {originalFile.name}
                  </p>
                </div>
              </div>
              <div className={`text-right shrink-0 font-mono text-sm font-bold ${isDark ? 'text-blue-400' : 'text-blue-600'}`}>
                {formatBytes(originalFile.size)}
              </div>
            </div>

            <div className="flex flex-col sm:flex-row w-full gap-3 mt-8">
              <button
                onClick={reset}
                className={`flex-1 py-3 px-4 rounded-xl font-medium flex items-center justify-center gap-2 transition-all hover:scale-[1.02] active:scale-[0.98] border ${
                  isDark 
                    ? 'bg-transparent border-white/10 hover:bg-white/5 text-white/70 hover:text-white' 
                    : 'bg-white border-gray-200 hover:bg-gray-50 text-gray-600 hover:text-gray-900 shadow-sm'
                }`}
              >
                <X className="w-4 h-4" />
                Abort
              </button>
              
              <button
                onClick={confirmProcessing}
                className="flex-1 py-3 px-4 rounded-xl font-bold flex items-center justify-center gap-2 text-white shadow-xl transition-all hover:scale-[1.02] active:scale-[0.98] group bg-linear-to-r from-blue-600 to-blue-500 hover:from-blue-500 hover:to-blue-400 shadow-blue-500/25 border border-blue-400/20"
              >
                <Sparkles className="w-4 h-4 shrink-0" />
                <span className="truncate">Continue Compression</span>
                <ArrowRight className="w-4 h-4 opacity-70 group-hover:translate-x-1 transition-transform shrink-0" />
              </button>
            </div>

          </div>
        </div>
      </div>
    </motion.div>
  );
}
