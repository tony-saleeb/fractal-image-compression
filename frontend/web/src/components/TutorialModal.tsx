'use client';

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Sparkles, Image as ImageIcon, Zap, ChevronRight, ChevronLeft, X } from 'lucide-react';
import { useTheme } from '@/context/ThemeContext';

interface TutorialModalProps {
  onClose: () => void;
}

const slides = [
  {
    icon: <Sparkles className="w-12 h-12 text-blue-500" />,
    title: 'Welcome to DeepFract',
    description: 'Experience the next generation of image compression powered by advanced neural networks and fractal latent spaces.'
  },
  {
    icon: <ImageIcon className="w-12 h-12 text-purple-500" />,
    title: 'How to Compress',
    description: 'Simply drag and drop any JPG, PNG, or WebP file into the workspace. The neural engine will analyze and compress your image into a tiny .fic archive.'
  },
  {
    icon: <Zap className="w-12 h-12 text-green-500" />,
    title: 'How to Decompress',
    description: 'Switch to the "Decompress" tab, upload your .fic archive, and our AI super-resolution decoder will perfectly reconstruct the original image.'
  }
];

export default function TutorialModal({ onClose }: TutorialModalProps) {
  const { isDark } = useTheme();
  const [step, setStep] = useState(0);

  const nextStep = () => {
    if (step < slides.length - 1) {
      setStep(step + 1);
    } else {
      onClose();
    }
  };

  const prevStep = () => {
    if (step > 0) setStep(step - 1);
  };

  const glassClass = isDark ? 'bg-black/80 border-white/10' : 'bg-white/90 border-gray-200 shadow-2xl';

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        onClick={onClose}
        className="absolute inset-0 bg-black/40 backdrop-blur-sm"
      />

      {/* Modal */}
      <motion.div
        initial={{ opacity: 0, scale: 0.9, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.9, y: 20 }}
        className={`relative w-full max-w-lg p-8 rounded-3xl border overflow-hidden backdrop-blur-xl ${glassClass}`}
      >
        <button
          onClick={onClose}
          className="absolute top-4 right-4 p-2 rounded-full hover:bg-gray-500/20 transition-colors"
        >
          <X className={`w-5 h-5 ${isDark ? 'text-gray-400' : 'text-gray-600'}`} />
        </button>

        <div className="min-h-[250px] flex flex-col items-center justify-center text-center mt-4">
          <AnimatePresence mode="wait">
            <motion.div
              key={step}
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              transition={{ duration: 0.3 }}
              className="flex flex-col items-center gap-6"
            >
              <div className="p-4 rounded-2xl bg-blue-500/10 ring-1 ring-blue-500/20">
                {slides[step].icon}
              </div>
              <h2 className={`text-2xl font-bold ${isDark ? 'text-white' : 'text-gray-900'}`}>
                {slides[step].title}
              </h2>
              <p className={`text-sm leading-relaxed max-w-sm ${isDark ? 'text-gray-300' : 'text-gray-600'}`}>
                {slides[step].description}
              </p>
            </motion.div>
          </AnimatePresence>
        </div>

        {/* Navigation */}
        <div className="mt-12 flex items-center justify-between">
          <div className="flex gap-2">
            {slides.map((_, i) => (
              <div
                key={i}
                className={`w-2 h-2 rounded-full transition-all duration-300 ${
                  i === step ? 'w-6 bg-blue-500' : isDark ? 'bg-white/20' : 'bg-gray-300'
                }`}
              />
            ))}
          </div>

          <div className="flex items-center gap-3">
            <button
              onClick={prevStep}
              disabled={step === 0}
              className={`p-3 rounded-xl transition-all ${
                step === 0
                  ? 'opacity-30 cursor-not-allowed'
                  : 'hover:bg-blue-500/10 text-blue-500'
              }`}
            >
              <ChevronLeft className="w-5 h-5" />
            </button>
            
            <button
              onClick={nextStep}
              className="flex items-center gap-2 px-6 py-3 rounded-xl bg-blue-600 hover:bg-blue-500 text-white font-medium transition-all hover:scale-105 active:scale-95"
            >
              {step === slides.length - 1 ? 'Get Started' : 'Next'}
              {step < slides.length - 1 && <ChevronRight className="w-4 h-4" />}
            </button>
          </div>
        </div>
      </motion.div>
    </div>
  );
}
