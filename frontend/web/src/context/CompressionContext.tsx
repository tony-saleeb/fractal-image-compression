'use client';

import React, { createContext, useContext, useReducer, useCallback, useRef, useMemo } from 'react';
import type { CompressionResult, DecompressionResult, CompressionMode, AppView, ProcessingState } from '@/lib/types';
import { compressImage, decompressFile, checkHealth } from '@/lib/api';

type Action =
  | { type: 'SET_MODE'; mode: CompressionMode }
  | { type: 'SET_TIER'; tier: number }
  | { type: 'PREVIEW_FILE'; file: File; previewUrl: string | null }
  | { type: 'START_PROCESSING' }
  | { type: 'FINISH_COMPRESSION'; result: CompressionResult }
  | { type: 'FINISH_DECOMPRESSION'; result: DecompressionResult }
  | { type: 'SET_ERROR'; error: string | null }
  | { type: 'RESET' }
  | { type: 'SET_VIEW'; view: AppView };

interface CompressionContextType extends ProcessingState {
  setMode: (mode: CompressionMode) => void;
  setTier: (tier: number) => void;
  setError: (error: string | null) => void;
  handleCompress: (file: File) => Promise<void>;
  handleDecompress: (file: File) => Promise<void>;
  previewFile: (file: File) => void;
  confirmProcessing: () => Promise<void>;
  reset: () => void;
}

const initialState: ProcessingState = {
  isProcessing: false,
  error: null,
  mode: 'compress',
  tier: 0,
  originalFile: null,
  originalPreviewUrl: null,
  compressResult: null,
  decompressResult: null,
  currentView: 'home',
};

function compressionReducer(state: ProcessingState, action: Action): ProcessingState {
  switch (action.type) {
    case 'SET_MODE':
      return { ...state, mode: state.mode === action.mode ? state.mode : action.mode };
    case 'SET_TIER':
      return { ...state, tier: action.tier };
    case 'PREVIEW_FILE':
      return {
        ...state,
        error: null,
        originalFile: action.file,
        originalPreviewUrl: action.previewUrl,
        currentView: 'preview'
      };
    case 'START_PROCESSING':
      return { 
        ...state, 
        isProcessing: true, 
        error: null, 
        currentView: 'loading' 
      };
    case 'FINISH_COMPRESSION':
      return { ...state, isProcessing: false, compressResult: action.result, currentView: 'result' };
    case 'FINISH_DECOMPRESSION':
      return { ...state, isProcessing: false, decompressResult: action.result, currentView: 'result' };
    case 'SET_ERROR':
      return { ...state, isProcessing: false, error: action.error, currentView: 'home' };
    case 'SET_VIEW':
      return { ...state, currentView: action.view };
    case 'RESET':
      return { ...initialState, mode: state.mode };
    default:
      return state;
  }
}

const CompressionContext = createContext<CompressionContextType | undefined>(undefined);

export function CompressionProvider({ children }: { children: React.ReactNode }) {
  const [state, dispatch] = useReducer(compressionReducer, initialState);
  const processingRef = useRef(false);

  const setError = useCallback((error: string | null) => {
    dispatch({ type: 'SET_ERROR', error });
  }, []);

  const setMode = useCallback((mode: CompressionMode) => {
    dispatch({ type: 'SET_MODE', mode });
  }, []);

  const setTier = useCallback((tier: number) => {
    dispatch({ type: 'SET_TIER', tier });
  }, []);

  const reset = useCallback(() => {
    if (state.originalPreviewUrl) {
      URL.revokeObjectURL(state.originalPreviewUrl);
    }
    dispatch({ type: 'RESET' });
    processingRef.current = false;
  }, [state.originalPreviewUrl]);

  const handleCompress = useCallback(async (file: File) => {
    if (processingRef.current) return;
    processingRef.current = true;
    
    dispatch({ type: 'START_PROCESSING' });

    try {
      const ok = await checkHealth();
      if (!ok) throw new Error('Backend server not responding. Ensure py server.py is running.');

      const result = await compressImage(file);
      dispatch({ type: 'FINISH_COMPRESSION', result });
    } catch (err: any) {
      setError(err.message || 'Compression failed');
    } finally {
      processingRef.current = false;
    }
  }, [setError]);

  const handleDecompress = useCallback(async (file: File) => {
    if (processingRef.current) return;
    processingRef.current = true;

    dispatch({ type: 'START_PROCESSING' });

    try {
      const ok = await checkHealth();
      if (!ok) throw new Error('Backend server not responding. Ensure py server.py is running.');

      const result = await decompressFile(file);
      dispatch({ type: 'FINISH_DECOMPRESSION', result });
    } catch (err: any) {
      setError(err.message || 'Decompression failed');
    } finally {
      processingRef.current = false;
    }
  }, [setError]);

  const previewFile = useCallback((file: File) => {
    const previewUrl = state.mode === 'compress' ? URL.createObjectURL(file) : null;
    dispatch({ type: 'PREVIEW_FILE', file, previewUrl });
  }, [state.mode]);

  const confirmProcessing = useCallback(async () => {
    if (!state.originalFile) return;
    if (state.mode === 'compress') {
      await handleCompress(state.originalFile);
    } else {
      await handleDecompress(state.originalFile);
    }
  }, [state.originalFile, state.mode, handleCompress, handleDecompress]);

  const value = useMemo(() => ({
    ...state,
    setMode,
    setTier,
    setError,
    handleCompress,
    handleDecompress,
    previewFile,
    confirmProcessing,
    reset,
  }), [state, setMode, setTier, setError, handleCompress, handleDecompress, previewFile, confirmProcessing, reset]);

  return <CompressionContext.Provider value={value}>{children}</CompressionContext.Provider>;
}

export function useCompressionStore() {
  const context = useContext(CompressionContext);
  if (context === undefined) {
    throw new Error('useCompressionStore must be used within a CompressionProvider');
  }
  return context;
}
