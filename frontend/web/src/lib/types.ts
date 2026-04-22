/* ─── Types for the DeepFract compression engine ──────────────────────────── */

export type CompressionMode = 'compress' | 'decompress';

export interface CompressionResult {
  ficBytes: Uint8Array;
  originalSize: number;
  compressedSize: number;
  compressionRatio: number;
  bpp: number;
  elapsedSeconds: number;
  width: number;
  height: number;
}

export interface DecompressionResult {
  imageBytes: Uint8Array;
  elapsedSeconds: number;
}

export type AppView = 'home' | 'loading' | 'result';

export interface ProcessingState {
  isProcessing: boolean;
  error: string | null;
  mode: CompressionMode;
  originalFile: File | null;
  originalPreviewUrl: string | null;
  compressResult: CompressionResult | null;
  decompressResult: DecompressionResult | null;
  currentView: AppView;
  tier: number;
}
