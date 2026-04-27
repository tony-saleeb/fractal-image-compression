'use client';

import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { AlertCircle, X } from 'lucide-react';
import { useCompressionStore } from '@/context/CompressionContext';
import { useTheme } from '@/context/ThemeContext';

import LoadingOverlay from '@/components/LoadingOverlay';
import ResultView from '@/components/ResultView';
import Background from '@/components/Background';
import Header from '@/components/Header';
import ModeSelector from '@/components/ModeSelector';
import UploadBox from '@/components/UploadBox';
import Footer from '@/components/Footer';
import TutorialModal from '@/components/TutorialModal';

/* ── Ambient Particles (Memoized to prevent re-renders) ────────────────── */

const AmbientParticles = React.memo(function AmbientParticles() {
  const [particles, setParticles] = useState<Array<{ id: number, x: number, y: number, size: number, duration: number, delay: number }>>([]);
  
  useEffect(() => {
    setParticles(
      Array.from({ length: 20 }, (_, i) => ({
        id: i,
        x: Math.random() * 100,
        y: Math.random() * 100,
        size: Math.random() * 3 + 1,
        duration: Math.random() * 12 + 10,
        delay: Math.random() * 10,
      }))
    );
  }, []);

  return (
    <div className="fixed inset-0 overflow-hidden pointer-events-none">
      {particles.map((p) => (
        <motion.div
          key={p.id}
          initial={{ opacity: 0, y: 0 }}
          animate={{ opacity: [0, 0.3, 0], y: [0, -1000] }}
          transition={{ duration: p.duration, repeat: Infinity, ease: "linear", delay: p.delay }}
          className="absolute rounded-full bg-blue-500/20 pointer-events-none will-change-transform"
          style={{ width: p.size, height: p.size, left: `${p.x}%`, bottom: "-5%", backfaceVisibility: 'hidden' }}
        />
      ))}
    </div>
  );
});

export default function Home() {
  const { isDark } = useTheme();
  const {
    error,
    setError,
    mode,
    originalFile,
    originalPreviewUrl,
    compressResult,
    decompressResult,
    currentView,
    reset,
  } = useCompressionStore();

  const [showTutorial, setShowTutorial] = useState(false);

  useEffect(() => {
    const hasSeen = localStorage.getItem('deepfract_tutorial_seen');
    if (!hasSeen) {
      setShowTutorial(true);
    }
  }, []);

  const handleCloseTutorial = () => {
    localStorage.setItem('deepfract_tutorial_seen', 'true');
    setShowTutorial(false);
  };

  return (
    <div className="min-h-screen relative overflow-hidden flex flex-col">
      <Background />

      {showTutorial && <TutorialModal onClose={handleCloseTutorial} />}

      <Header onShowTutorial={() => setShowTutorial(true)} />

      <div className="relative z-10 flex flex-col grow">
        {/* ── Error Toast ────────────────────────────────────────────────────── */}
        <AnimatePresence>
          {error && (
            <motion.div
              initial={{ opacity: 0, y: -20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              className="fixed top-24 left-1/2 -translate-x-1/2 z-50 flex items-center gap-2 sm:gap-3 px-4 sm:px-6 py-3 sm:py-4 rounded-xl bg-red-500/90 text-white backdrop-blur-lg shadow-2xl w-[90%] max-w-lg"
            >
              <AlertCircle className="w-5 h-5 shrink-0" />
              <span className="text-sm">{error}</span>
              <button onClick={() => setError(null)} className="ml-2 cursor-pointer" type="button">
                <X className="w-4 h-4" />
              </button>
            </motion.div>
          )}
        </AnimatePresence>

        {/* ── Loading Overlay ────────────────────────────────────────────────── */}
        <AnimatePresence>
          {currentView === 'loading' && (
            <LoadingOverlay isDecompress={mode === 'decompress'} isDark={isDark} />
          )}
        </AnimatePresence>

        {/* ── Main Content ───────────────────────────────────────────────────── */}
        <main className="grow px-4 sm:px-6 pt-8 sm:pt-16 pb-20 sm:pb-32">
          <div className="w-full max-w-6xl mx-auto">
            <AnimatePresence mode="wait">
              {currentView === 'result' ? (
                <ResultView
                  key="result"
                  mode={mode}
                  originalFile={originalFile}
                  originalPreviewUrl={originalPreviewUrl}
                  compressResult={compressResult}
                  decompressResult={decompressResult}
                  isDark={isDark}
                  onReset={reset}
                />
              ) : (
                <motion.div
                  key="home"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{ opacity: 0 }}
                >
                  <ModeSelector />
                  <UploadBox />
                </motion.div>
              )}
            </AnimatePresence>
          </div>
        </main>

        <AmbientParticles />

        <Footer />
      </div>
    </div>
  );
}
