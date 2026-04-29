'use client';

import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import logoImg from '../../public/images/logo.png';

const STEPS = [
  'Initializing neural engine…',
  'Analyzing spatial frequencies…',
  'Computing latent representation…',
  'Applying channel sparsity filter…',
  'Encoding with learned entropy…',
  'Optimizing bitstream…',
  'Finalizing output…',
];

const DECOMPRESS_STEPS = [
  'Initializing neural decoder…',
  'Parsing .fic bitstream…',
  'Decoding latent channels…',
  'Running synthesis transform…',
  'Applying super-resolution…',
  'Reconstructing pixel data…',
  'Finalizing output…',
];

interface LoadingOverlayProps {
  isDecompress: boolean;
  isDark: boolean;
}

export default function LoadingOverlay({ isDecompress, isDark }: LoadingOverlayProps) {
  const [currentStep, setCurrentStep] = useState(0);
  const steps = isDecompress ? DECOMPRESS_STEPS : STEPS;

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentStep((prev) => (prev < steps.length - 1 ? prev + 1 : prev));
    }, 1200);
    return () => clearInterval(interval);
  }, [steps.length]);

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-50 flex items-center justify-center"
    >
      {/* Backdrop */}
      <div className={`absolute inset-0 ${
        isDark ? 'bg-black/80' : 'bg-white/80'
      } backdrop-blur-xl`} />

      {/* Content */}
      <div className="relative z-10 flex flex-col items-center gap-8 px-8">
        {/* Pulsing Logo */}
        <div className="relative">
          <div className="absolute inset-0 bg-blue-500 blur-2xl opacity-50 animate-pulse-glow" />
          <motion.div
            animate={{ rotate: 360 }}
            transition={{ duration: 6, repeat: Infinity, ease: 'linear' }}
            className="relative w-28 h-28 flex items-center justify-center"
          >
            <img 
              src={logoImg.src} 
              alt="DeepFract" 
              className="w-28 h-28 object-contain drop-shadow-[0_0_20px_rgba(59,130,246,0.5)]"
            />
          </motion.div>
        </div>

        {/* Title */}
        <div className="text-center">
          <h2 className={`text-2xl font-bold mb-2 ${isDark ? 'text-white' : 'text-gray-900'}`}>
            {isDecompress ? 'Neural Reconstruction' : 'Neural Compression'}
          </h2>
          <p className={`text-sm ${isDark ? 'text-gray-400' : 'text-gray-500'}`}>
            Processing with Neural Fractal image compression
          </p>
        </div>

        {/* Steps */}
        <div className="w-80 space-y-3">
          {steps.map((step, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, x: -20 }}
              animate={{
                opacity: i <= currentStep ? 1 : 0.3,
                x: i <= currentStep ? 0 : -20,
              }}
              transition={{ delay: i * 0.1, duration: 0.3 }}
              className="flex items-center gap-3"
            >
              <div className={`w-2 h-2 rounded-full shrink-0 transition-colors duration-300 ${
                i < currentStep
                  ? 'bg-green-400'
                  : i === currentStep
                  ? 'bg-blue-400 animate-pulse'
                  : isDark ? 'bg-gray-600' : 'bg-gray-300'
              }`} />
              <span className={`text-sm ${
                i <= currentStep
                  ? isDark ? 'text-gray-200' : 'text-gray-700'
                  : isDark ? 'text-gray-600' : 'text-gray-400'
              }`}>
                {step}
              </span>
            </motion.div>
          ))}
        </div>

        {/* Progress bar */}
        <div className={`w-80 h-1 rounded-full overflow-hidden ${
          isDark ? 'bg-white/10' : 'bg-gray-200'
        }`}>
          <motion.div
            className="h-full bg-linear-to-r from-blue-600 to-blue-400 rounded-full"
            initial={{ width: '0%' }}
            animate={{ 
              width: `${((currentStep + 1) / steps.length) * 100}%`,
            }}
            transition={{ 
              width: { duration: 0.5 },
            }}
          />
        </div>
      </div>
    </motion.div>
  );
}
