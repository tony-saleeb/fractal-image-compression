import type { CompressionResult, DecompressionResult } from './types';

const BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';
const REQUEST_TIMEOUT = 60 * 60 * 1000; // 60 minutes

/* ─── Health Check ────────────────────────────────────────────────────────── */

export async function checkHealth(): Promise<boolean> {
  try {
    const controller = new AbortController();
    const id = setTimeout(() => controller.abort(), 3000);
    const res = await fetch(`${BASE_URL}/health`, { signal: controller.signal });
    clearTimeout(id);
    return res.ok;
  } catch {
    return false;
  }
}

/* ─── Compress Image ──────────────────────────────────────────────────────── */

export async function compressImage(file: File): Promise<CompressionResult> {
  const formData = new FormData();
  formData.append('image', file);

  const controller = new AbortController();
  const id = setTimeout(() => controller.abort(), REQUEST_TIMEOUT);

  try {
    const res = await fetch(`${BASE_URL}/compress`, {
      method: 'POST',
      body: formData,
      signal: controller.signal,
    });
    clearTimeout(id);

    if (!res.ok) {
      const text = await res.text();
      throw new Error(`Server error ${res.status}: ${text}`);
    }

    const ficBytes = new Uint8Array(await res.arrayBuffer());
    const headers = res.headers;

    return {
      ficBytes,
      originalSize: file.size,
      compressedSize: ficBytes.length,
      compressionRatio: parseFloat(headers.get('x-ratio') || '0'),
      bpp: parseFloat(headers.get('x-bpp') || '0'),
      elapsedSeconds: parseFloat(headers.get('x-time') || '0'),
      width: parseInt(headers.get('x-width') || '0', 10),
      height: parseInt(headers.get('x-height') || '0', 10),
    };
  } catch (err: unknown) {
    clearTimeout(id);
    if (err instanceof DOMException && err.name === 'AbortError') {
      throw new Error('Compression timed out (>5 min). Try a smaller image.');
    }
    throw err;
  }
}

/* ─── Decompress .fic ─────────────────────────────────────────────────────── */

export async function decompressFile(file: File): Promise<DecompressionResult> {
  const formData = new FormData();
  formData.append('fic', file);

  const controller = new AbortController();
  const id = setTimeout(() => controller.abort(), REQUEST_TIMEOUT);

  try {
    const res = await fetch(`${BASE_URL}/decompress`, {
      method: 'POST',
      body: formData,
      signal: controller.signal,
    });
    clearTimeout(id);

    if (!res.ok) {
      const text = await res.text();
      throw new Error(`Server error ${res.status}: ${text}`);
    }

    const imageBytes = new Uint8Array(await res.arrayBuffer());
    const elapsed = parseFloat(res.headers.get('x-time') || '0');

    return { imageBytes, elapsedSeconds: elapsed };
  } catch (err: unknown) {
    clearTimeout(id);
    if (err instanceof DOMException && err.name === 'AbortError') {
      throw new Error('Decompression timed out (>5 min). File may be corrupted.');
    }
    throw err;
  }
}

/* ─── Helpers ─────────────────────────────────────────────────────────────── */

export function formatBytes(bytes: number): string {
  if (bytes === 0) return '0 B';
  const k = 1024;
  const sizes = ['B', 'KB', 'MB', 'GB'];
  const i = Math.floor(Math.log(bytes) / Math.log(k));
  return `${(bytes / Math.pow(k, i)).toFixed(i > 0 ? 1 : 0)} ${sizes[i]}`;
}

export function formatDuration(seconds: number): string {
  if (seconds < 1) return `${Math.round(seconds * 1000)}ms`;
  if (seconds < 60) return `${seconds.toFixed(1)}s`;
  const m = Math.floor(seconds / 60);
  const s = Math.round(seconds % 60);
  return `${m}m ${s}s`;
}
