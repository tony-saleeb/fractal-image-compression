'use client';

import React, { useMemo, useState, useEffect } from 'react';
import { motion, Variants } from 'framer-motion';
import { 
  Download, RotateCcw, ArrowRight, Clock, 
  Maximize2, HardDrive, CheckCircle2, 
  Activity, BarChart3, Image as ImageIcon
} from 'lucide-react';
import type { CompressionResult, DecompressionResult, CompressionMode } from '@/lib/types';
import { formatBytes, formatDuration } from '@/lib/api';

interface ResultViewProps {
  mode: CompressionMode;
  originalFile: File | null;
  originalPreviewUrl: string | null;
  compressResult: CompressionResult | null;
  decompressResult: DecompressionResult | null;
  isDark: boolean;
  onReset: () => void;
}

export default function ResultView({
  mode,
  originalFile,
  originalPreviewUrl,
  compressResult,
  decompressResult,
  isDark,
  onReset,
}: ResultViewProps) {

  const [decompressedPreviewUrl, setDecompressedPreviewUrl] = useState<string | null>(null);

  useEffect(() => {
    if (!decompressResult) {
      setDecompressedPreviewUrl(null);
      return;
    }
    const blob = new Blob([new Uint8Array(decompressResult.imageBytes) as BlobPart], { type: 'image/png' });
    const url = URL.createObjectURL(blob);
    setDecompressedPreviewUrl(url);
    return () => URL.revokeObjectURL(url);
  }, [decompressResult]);

  const jobId = useMemo(() => Math.random().toString(36).substring(7).toUpperCase(), []);

  const handleDownload = () => {
    if (mode === 'compress' && compressResult) {
      const blob = new Blob([new Uint8Array(compressResult.ficBytes) as BlobPart], { type: 'application/octet-stream' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = (originalFile?.name.replace(/\.[^.]+$/, '') || 'output') + '.fic';
      a.click();
      URL.revokeObjectURL(url);
    } else if (mode === 'decompress' && decompressResult) {
      const blob = new Blob([new Uint8Array(decompressResult.imageBytes) as BlobPart], { type: 'image/png' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = (originalFile?.name.replace(/\.fic$/, '') || 'output') + '.png';
      a.click();
      URL.revokeObjectURL(url);
    }
  };

  const containerVariants: Variants = {
    hidden: { opacity: 0 },
    visible: { 
      opacity: 1,
      transition: { staggerChildren: 0.08, delayChildren: 0.1 }
    }
  };

  const itemVariants: Variants = {
    hidden: { opacity: 0, y: 15 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.4, ease: "easeOut" } }
  };

  const glassClass = isDark ? 'glass border-white/5' : 'glass-light border-gray-200/50 shadow-lg';

  const mainRatio = mode === 'compress' 
    ? (compressResult?.compressionRatio?.toFixed(1) ?? '0.0') + 'x'
    : ((decompressResult?.imageBytes?.length ?? 0) / (originalFile?.size || 1)).toFixed(1) + 'x';

  return (
    <motion.div
      variants={containerVariants}
      initial="hidden"
      animate="visible"
      className="w-full max-w-6xl mx-auto space-y-6 pb-12"
    >
      {/* ── Dashboard Header & Quick Actions ── */}
      <motion.div variants={itemVariants} className="flex flex-col sm:flex-row items-center justify-between gap-4 px-2">
        <div className="flex items-center gap-4">
          <div className="p-3 rounded-2xl bg-blue-500/10 text-blue-500 ring-1 ring-blue-500/20">
            <CheckCircle2 className="w-6 h-6" />
          </div>
          <div>
            <h2 className={`text-2xl font-bold tracking-tight ${isDark ? 'text-white' : 'text-gray-900'}`}>
              {mode === 'compress' ? 'Compression Optimized' : 'Neural Reconstruction'}
            </h2>
            <div className="flex items-center gap-2 text-xs opacity-60">
              <Activity className="w-3 h-3" />
              <span>Status: Successfully Processed</span>
              <span className="mx-1">•</span>
              <span className="font-mono">ID: {jobId}</span>
            </div>
          </div>
        </div>
        
        <div className="flex gap-3 w-full sm:w-auto">
          <button
            onClick={onReset}
            className={`flex-1 sm:flex-none flex items-center justify-center gap-2 px-6 py-2.5 rounded-xl font-medium transition-all hover:scale-[1.02] active:scale-[0.98] cursor-pointer ${
              isDark ? 'bg-white/5 text-white border border-white/10 hover:bg-white/10' : 'bg-gray-100 text-gray-900 border border-gray-200 hover:bg-gray-200'
            }`}
          >
            <RotateCcw className="w-4 h-4" />
            New
          </button>
          <button
            onClick={handleDownload}
            className="flex-1 sm:flex-none flex items-center justify-center gap-2 px-8 py-2.5 bg-blue-600 hover:bg-blue-500 text-white rounded-xl font-medium shadow-lg shadow-blue-600/20 transition-all hover:scale-[1.02] active:scale-[0.98] cursor-pointer"
          >
            <Download className="w-4 h-4" />
            Download
          </button>
        </div>
      </motion.div>

      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
        <QuickStaticCard 
          icon={<BarChart3 className="w-4 h-4" />} 
          label={mode === 'compress' ? 'Compression Ratio' : 'Neural Expansion'} 
          value={mainRatio}
          color="text-blue-500"
          isDark={isDark}
        />
        <QuickStaticCard 
          icon={<HardDrive className="w-4 h-4" />} 
          label="Payload Size" 
          value={formatBytes(mode === 'compress' ? (compressResult?.compressedSize ?? 0) : (originalFile?.size ?? 0))}
          color="text-green-500"
          isDark={isDark}
        />
        <QuickStaticCard 
          icon={<Clock className="w-4 h-4" />} 
          label="Time Elapsed" 
          value={formatDuration(mode === 'compress' ? (compressResult?.elapsedSeconds ?? 0) : (decompressResult?.elapsedSeconds ?? 0))}
          color="text-purple-500"
          isDark={isDark}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
        {/* ── Left Side: Visual Comparison ── */}
        <motion.div variants={itemVariants} className="lg:col-span-8 flex flex-col gap-6">
          <div className={`relative overflow-hidden rounded-3xl p-1  ${glassClass}`}>
            <div className="relative group">
              <div className="absolute top-4 left-4 z-10 px-3 py-1.5 rounded-full bg-blue-500/40 backdrop-blur-md border border-blue-400/20 text-[10px] font-bold text-white uppercase tracking-widest shadow-xl">
                {mode === 'compress' ? 'Source' : 'Reconstructed Output'}
              </div>
              <div className="aspect-16/10 sm:aspect-video rounded-2xl overflow-hidden bg-black/40 flex items-center justify-center">
                {mode === 'compress' ? (
                  originalPreviewUrl && (
                    (originalFile?.size ?? 0) > 50 * 1024 * 1024 ? (
                      <div className="w-full h-full flex flex-col items-center justify-center p-6 bg-black/50 text-white">
                        <ImageIcon className="w-10 h-10 opacity-30 mb-4" />
                        <p className="text-sm opacity-70 text-center font-medium">Source image too large for browser preview.</p>
                        <p className="text-xs opacity-40 text-center mt-2">Compression successfully processed by neural backend.</p>
                      </div>
                    ) : (
                      <img 
                        src={originalPreviewUrl} 
                        alt="Source" 
                        className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105" 
                      />
                    )
                  )
                ) : (
                  decompressedPreviewUrl && (
                    <img 
                      src={decompressedPreviewUrl} 
                      alt="Reconstructed Output" 
                      className="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105" 
                    />
                  )
                )}
              </div>
            </div>
          </div>
        </motion.div>

        {/* ── Right Side: Technical Specs ── */}
        <motion.div variants={itemVariants} className="lg:col-span-4 flex flex-col gap-4">
          <div className={`p-6 rounded-3xl ${glassClass}`}>
            <h3 className={`text-xs font-bold uppercase tracking-[0.2em] mb-6 opacity-40 ${isDark ? 'text-white' : 'text-gray-900'}`}>
              Technical manifest
            </h3>
            
            <div className="space-y-4">
              <SpecItem 
                icon={<HardDrive className="w-4 h-4" />} 
                label="Encoded Size" 
                value={formatBytes(mode === 'compress' ? (compressResult?.compressedSize ?? 0) : (originalFile?.size ?? 0))} 
                isDark={isDark} 
              />
              <SpecItem 
               icon={<ImageIcon className="w-4 h-4" />} 
               label="Resolution" 
               value={mode === 'compress' ? `${compressResult?.width ?? 0}×${compressResult?.height ?? 0}` : `${originalFile?.name.includes('.fic') ? 'Neural FIC' : 'Unknown'}`} 
               isDark={isDark} 
              />
              <SpecItem 
                icon={<Maximize2 className="w-4 h-4" />} 
                label="Original Size" 
                value={formatBytes(mode === 'compress' ? (compressResult?.originalSize ?? 0) : (decompressResult?.imageBytes?.length ?? 0))} 
                isDark={isDark} 
              />
              <SpecItem 
               icon={<Activity className="w-4 h-4" />} 
               label="PSNR" 
               value={mode === 'compress' ? `${compressResult?.psnr?.toFixed(2) ?? '0'} dB` : decompressResult?.psnr ? `${decompressResult.psnr.toFixed(2)} dB` : 'N/A'} 
               isDark={isDark} 
              />
              <SpecItem 
               icon={<Activity className="w-4 h-4" />} 
               label="RMSE" 
               value={mode === 'compress' ? `${compressResult?.rmse?.toFixed(2) ?? '0'}` : decompressResult?.rmse ? `${decompressResult.rmse.toFixed(2)}` : 'N/A'} 
               isDark={isDark} 
              />
            </div>
          </div>
          
          <div className={`p-5 rounded-3xl bg-blue-500/5 border border-blue-500/10 ${isDark ? '' : 'bg-blue-50'}`}>
             <p className={`text-[10px] leading-relaxed opacity-60 text-center ${isDark ? 'text-blue-100' : 'text-blue-900'}`}>
               Advanced {mode === 'compress' ? 'Fractal Compression' : 'Neural Reconstruction'} successfully applied using DeepFract Engine v2.1
             </p>
          </div>
        </motion.div>
      </div>
    </motion.div>
  );
}

function QuickStaticCard({ icon, label, value, color, isDark }: { icon: React.ReactNode, label: string, value: string, color: string, isDark: boolean }) {
  return (
    <motion.div variants={{hidden: { opacity: 0, y: 10 }, visible: { opacity: 1, y: 0 }}} className={`p-4 rounded-2xl flex flex-col items-center text-center gap-1 transition-all ${isDark ? 'bg-white/5 border border-white/5' : 'bg-gray-50 border border-gray-100 shadow-sm'}`}>
      <div className={`${color} mb-1 opacity-80`}>{icon}</div>
      <div className="text-[10px] uppercase font-bold opacity-30 tracking-wider whitespace-nowrap">{label}</div>
      <div className="text-lg font-bold tabular-nums tracking-tight">{value}</div>
    </motion.div>
  );
}

function SpecItem({ icon, label, value, isDark }: { icon: React.ReactNode, label: string, value: string, isDark: boolean }) {
  return (
    <div className="flex items-center justify-between group">
      <div className="flex items-center gap-3">
        <div className={`p-2 rounded-xl transition-colors ${isDark ? 'bg-white/5 group-hover:bg-white/10' : 'bg-gray-100 group-hover:bg-gray-200 shadow-sm'}`}>
          {icon}
        </div>
        <span className="text-xs font-medium opacity-50">{label}</span>
      </div>
      <span className="font-bold text-sm tabular-nums">{value}</span>
    </div>
  );
}
