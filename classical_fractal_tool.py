"""
DeepFract Classical Analyzer
============================
Three distinct fractal image compression techniques:
  1. Basic Fractal  — Fixed 8x8 blocks, sampled domain search
  2. Quadtree       — Adaptive block splitting based on variance
  3. Brute Force    — Fixed 8x8 blocks, exhaustive domain search (every position)

Each technique shows PSNR, RMSE, MSE, Compression Ratio, and Time.
"""

import os, time, math, threading
import numpy as np
from PIL import Image, ImageTk, ImageDraw
import tkinter as tk
from tkinter import filedialog, ttk

# ═══════════════════════════════════════════════════════════════════
# ENGINE
# ═══════════════════════════════════════════════════════════════════

TRANSFORMS = 8  # identity + 3 rotations + 2 flips + transpose + rot+flip

def apply_transform(patch, idx):
    """Apply one of 8 isometric transforms."""
    if idx == 0: return patch
    if idx == 1: return np.rot90(patch, 1)
    if idx == 2: return np.rot90(patch, 2)
    if idx == 3: return np.rot90(patch, 3)
    if idx == 4: return np.fliplr(patch)
    if idx == 5: return np.flipud(patch)
    if idx == 6: return np.transpose(patch)
    if idx == 7: return np.rot90(np.fliplr(patch), 1)
    return patch


def build_domain_pool(img, step):
    """
    Collect domain block positions.
    Domain blocks are 16x16 and will be downsampled to 8x8 to match range blocks.
    `step` controls how densely we sample — lower = more thorough.
    """
    h, w = img.shape
    pool = []
    for y in range(0, h - 15, step):
        for x in range(0, w - 15, step):
            pool.append((y, x))
    return pool


def best_affine_match(range_block, domain_pool, img, block_size):
    """
    For a given range block, search the domain pool for the best
    contractive affine map:  R ≈ s·D + b
    Returns (dy, dx, transform_id, s, b, mse).
    """
    best_mse = float('inf')
    best = None

    for dy, dx in domain_pool:
        # Extract domain block (2× size) and downsample to match range
        d_raw = img[dy:dy + block_size * 2, dx:dx + block_size * 2]
        if d_raw.shape[0] != block_size * 2 or d_raw.shape[1] != block_size * 2:
            continue
        d_down = d_raw[::2, ::2]  # downsample by averaging every 2 pixels

        for t in range(TRANSFORMS):
            d_t = apply_transform(d_down, t).astype(np.float64)
            r = range_block.astype(np.float64)

            # Least-squares fit: R = s·D + b
            d_mean = np.mean(d_t)
            r_mean = np.mean(r)
            num = np.sum((d_t - d_mean) * (r - r_mean))
            den = np.sum((d_t - d_mean) ** 2)

            s = np.clip(num / (den + 1e-8), -1.0, 1.0)
            b = r_mean - s * d_mean

            est = s * d_t + b
            mse = np.mean((r - est) ** 2)

            if mse < best_mse:
                best_mse = mse
                best = (dy, dx, t, s, b, mse)

    return best


def compress_basic(img, progress_cb=None):
    """
    Technique 1 — Basic Fractal Compression
    Fixed 8×8 range blocks. Domain pool sampled every 8 pixels.
    """
    h, w = img.shape
    block = 8
    codes = []
    rects = []
    pool = build_domain_pool(img, step=8)
    total = (h // block) * (w // block)
    done = 0

    for y in range(0, h - block + 1, block):
        for x in range(0, w - block + 1, block):
            rb = img[y:y + block, x:x + block]
            match = best_affine_match(rb, pool, img, block)
            if match:
                codes.append((y, x, block, match[:5]))
                rects.append((x, y, x + block, y + block))
            done += 1
            if progress_cb:
                progress_cb(done / total)

    return codes, rects


def compress_quadtree(img, threshold=12.0, progress_cb=None):
    """
    Technique 2 — Quadtree Adaptive Partitioning
    Recursively splits blocks where variance exceeds `threshold`.
    Min block = 4, Max block = image size (power of 2).
    """
    h, w = img.shape
    codes = []
    rects = []
    pool = build_domain_pool(img, step=8)
    total_pixels = h * w
    done_pixels = [0]

    def recurse(y, x, size):
        if y + size > h or x + size > w:
            return
        rb = img[y:y + size, x:x + size]
        if rb.shape[0] != size or rb.shape[1] != size:
            return

        variance = np.var(rb)

        # Split if high variance and block is large enough to split
        if variance > threshold and size > 4:
            half = size // 2
            recurse(y, x, half)
            recurse(y, x + half, half)
            recurse(y + half, x, half)
            recurse(y + half, x + half, half)
        else:
            match = best_affine_match(rb, pool, img, size)
            if match:
                codes.append((y, x, size, match[:5]))
                rects.append((x, y, x + size, y + size))
            done_pixels[0] += size * size
            if progress_cb:
                progress_cb(min(1.0, done_pixels[0] / total_pixels))

    # Start from the largest power-of-2 that fits
    start_size = 1
    while start_size * 2 <= min(h, w):
        start_size *= 2
    recurse(0, 0, start_size)

    return codes, rects


def compress_bruteforce(img, progress_cb=None):
    """
    Technique 3 — Brute Force
    Fixed 8×8 range blocks. Domain pool sampled every 1 pixel (exhaustive).
    Slowest but highest quality reconstruction.
    """
    h, w = img.shape
    block = 8
    codes = []
    rects = []
    pool = build_domain_pool(img, step=1)  # EVERY position
    total = (h // block) * (w // block)
    done = 0

    for y in range(0, h - block + 1, block):
        for x in range(0, w - block + 1, block):
            rb = img[y:y + block, x:x + block]
            match = best_affine_match(rb, pool, img, block)
            if match:
                codes.append((y, x, block, match[:5]))
                rects.append((x, y, x + block, y + block))
            done += 1
            if progress_cb:
                progress_cb(done / total)

    return codes, rects


def decompress(codes, h, w, iterations=8):
    """Iteratively apply the fractal codes to reconstruct the image."""
    img = np.full((h, w), 128.0, dtype=np.float64)  # start from gray

    for i in range(iterations):
        new_img = np.zeros_like(img)
        for y, x, size, (dy, dx, t, s, b) in codes:
            d_raw = img[dy:dy + size * 2, dx:dx + size * 2]
            if d_raw.shape[0] < size * 2 or d_raw.shape[1] < size * 2:
                new_img[y:y + size, x:x + size] = b
                continue
            d_down = d_raw[::2, ::2]
            d_t = apply_transform(d_down, t)
            new_img[y:y + size, x:x + size] = s * d_t + b
        img = new_img

    return np.clip(img, 0, 255).astype(np.uint8)


# ═══════════════════════════════════════════════════════════════════
# GUI
# ═══════════════════════════════════════════════════════════════════

# Color palette
BG       = "#0f172a"
PANEL    = "#1e293b"
SURFACE  = "#334155"
ACCENT   = "#38bdf8"
GREEN    = "#4ade80"
RED      = "#f87171"
TEXT     = "#f1f5f9"
MUTED    = "#94a3b8"


class App:
    def __init__(self, root):
        self.root = root
        self.root.title("DeepFract — Classical Fractal Analyzer")
        self.root.geometry("1150x720")
        self.root.configure(bg=BG)
        self.root.minsize(900, 600)

        self.original_img = None
        self.gray_np = None
        self.img_path = None

        self._build_ui()

    # ── UI Construction ───────────────────────────────────────────
    def _build_ui(self):
        style = ttk.Style()
        style.theme_use("clam")
        style.configure("TFrame", background=BG)
        style.configure("Panel.TFrame", background=PANEL)
        style.configure("TLabel", background=PANEL, foreground=TEXT, font=("Segoe UI", 10))
        style.configure("BG.TLabel", background=BG, foreground=TEXT, font=("Segoe UI", 9))
        style.configure("Title.TLabel", background=PANEL, foreground=ACCENT, font=("Segoe UI", 15, "bold"))
        style.configure("Accent.TButton", font=("Segoe UI", 10, "bold"))
        style.configure("TLabelframe", background=PANEL, foreground=ACCENT)
        style.configure("TLabelframe.Label", background=PANEL, foreground=ACCENT, font=("Segoe UI", 10, "bold"))

        outer = ttk.Frame(self.root)
        outer.pack(fill=tk.BOTH, expand=True, padx=15, pady=15)

        # ── Sidebar ──────────────────────────────────────────────
        side = ttk.Frame(outer, style="Panel.TFrame", width=280)
        side.pack(side=tk.LEFT, fill=tk.Y, padx=(0, 15))
        side.pack_propagate(False)

        ttk.Label(side, text="FRACTAL ANALYZER", style="Title.TLabel").pack(pady=(18, 12))

        ttk.Button(side, text="📂  Load Image", command=self._load_image).pack(fill=tk.X, padx=18, pady=(0, 12))

        # ── Technique Buttons ────────────────────────────────────
        tech = ttk.LabelFrame(side, text="  TECHNIQUE  ")
        tech.pack(fill=tk.X, padx=18, pady=(0, 10))

        self.btn_basic = ttk.Button(tech, text="1 — Basic Fractal",
                                    command=lambda: self._run("basic"), state=tk.DISABLED)
        self.btn_basic.pack(fill=tk.X, padx=10, pady=(10, 4))

        self.btn_quad = ttk.Button(tech, text="2 — Quadtree",
                                   command=lambda: self._run("quadtree"), state=tk.DISABLED)
        self.btn_quad.pack(fill=tk.X, padx=10, pady=4)

        self.btn_brute = ttk.Button(tech, text="3 — Brute Force",
                                    command=lambda: self._run("bruteforce"), state=tk.DISABLED)
        self.btn_brute.pack(fill=tk.X, padx=10, pady=(4, 10))

        # ── Stats Console ────────────────────────────────────────
        ttk.Label(side, text="STATISTICS").pack(anchor=tk.W, padx=18, pady=(8, 2))
        self.console = tk.Text(side, bg="#000000", fg=GREEN, font=("Consolas", 9),
                               height=18, borderwidth=0, insertbackground=GREEN)
        self.console.pack(fill=tk.BOTH, expand=True, padx=18, pady=(0, 18))

        # ── Main Content ─────────────────────────────────────────
        main = ttk.Frame(outer)
        main.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        self.status_lbl = ttk.Label(main, text="Load an image to begin.", style="BG.TLabel",
                                    font=("Segoe UI", 11))
        self.status_lbl.pack(pady=(0, 8))

        canvas_frame = ttk.Frame(main)
        canvas_frame.pack(fill=tk.BOTH, expand=True)

        self.cv_orig = tk.Canvas(canvas_frame, bg=PANEL, highlightthickness=0)
        self.cv_orig.grid(row=0, column=0, padx=8, pady=8, sticky="nsew")
        ttk.Label(canvas_frame, text="ORIGINAL / PARTITIONS", style="BG.TLabel").grid(row=1, column=0)

        self.cv_recon = tk.Canvas(canvas_frame, bg=PANEL, highlightthickness=0)
        self.cv_recon.grid(row=0, column=1, padx=8, pady=8, sticky="nsew")
        ttk.Label(canvas_frame, text="RECONSTRUCTED", style="BG.TLabel").grid(row=1, column=1)

        canvas_frame.columnconfigure(0, weight=1)
        canvas_frame.columnconfigure(1, weight=1)
        canvas_frame.rowconfigure(0, weight=1)

        self.progress = ttk.Progressbar(main, orient=tk.HORIZONTAL, mode="determinate")
        self.progress.pack(fill=tk.X, pady=(12, 0))

        # Keep references so images aren't garbage-collected
        self._tk_orig = None
        self._tk_recon = None

    # ── Helpers ───────────────────────────────────────────────────
    def _log(self, msg):
        self.console.insert(tk.END, msg + "\n")
        self.console.see(tk.END)

    def _show_on_canvas(self, pil_img, canvas, attr_name):
        canvas.update_idletasks()
        cw = max(canvas.winfo_width(), 200)
        ch = max(canvas.winfo_height(), 200)
        sw, sh = pil_img.size
        ratio = min(cw / sw, ch / sh)
        new_w, new_h = int(sw * ratio), int(sh * ratio)
        resized = pil_img.resize((new_w, new_h), Image.LANCZOS)
        tk_img = ImageTk.PhotoImage(resized)
        setattr(self, attr_name, tk_img)
        canvas.delete("all")
        canvas.create_image(cw // 2, ch // 2, image=tk_img)

    def _set_buttons(self, state):
        self.btn_basic.config(state=state)
        self.btn_quad.config(state=state)
        self.btn_brute.config(state=state)

    # ── Load Image ────────────────────────────────────────────────
    def _load_image(self):
        path = filedialog.askopenfilename(
            filetypes=[("Images", "*.jpg *.jpeg *.png *.bmp *.webp")])
        if not path:
            return

        img = Image.open(path).convert("RGB")

        # Resize for tractable classical compression (keep it ≤256px)
        img.thumbnail((256, 256))
        self.original_img = img
        self.gray_np = np.array(img.convert("L"))
        self.img_path = path

        self._show_on_canvas(img, self.cv_orig, "_tk_orig")
        self.cv_recon.delete("all")
        self._set_buttons(tk.NORMAL)

        h, w = self.gray_np.shape
        self.status_lbl.config(text=f"Loaded: {os.path.basename(path)}  ({w}×{h})")
        self.console.delete("1.0", tk.END)
        self._log(f"Image: {os.path.basename(path)}")
        self._log(f"Size:  {w} × {h} px")
        self._log("")

    # ── Run Compression ───────────────────────────────────────────
    def _run(self, technique):
        if self.gray_np is None:
            return
        self._set_buttons(tk.DISABLED)
        self.progress["value"] = 0
        self.console.delete("1.0", tk.END)

        labels = {
            "basic": "Basic Fractal Compression",
            "quadtree": "Quadtree Partitioning",
            "bruteforce": "Brute Force Search",
        }
        self.status_lbl.config(text=f"Running: {labels[technique]}…")
        self._log(f"═══ {labels[technique]} ═══")
        self._log("")

        t = threading.Thread(target=self._worker, args=(technique,), daemon=True)
        t.start()

    def _worker(self, technique):
        img = self.gray_np
        h, w = img.shape

        def prog(p):
            self.progress["value"] = p * 100

        t0 = time.time()

        if technique == "basic":
            self._log("Method: Fixed 8×8 blocks")
            self._log("Search: Sampled domain pool (step=8)")
            self._log("Searching…")
            codes, rects = compress_basic(img, progress_cb=prog)

        elif technique == "quadtree":
            self._log("Method: Adaptive quadtree splitting")
            self._log("Search: Sampled domain pool (step=8)")
            self._log("Min block: 4×4 | Threshold: 12")
            self._log("Searching…")
            codes, rects = compress_quadtree(img, threshold=12.0, progress_cb=prog)

        elif technique == "bruteforce":
            self._log("Method: Fixed 8×8 blocks")
            self._log("Search: EXHAUSTIVE (step=1, every position)")
            self._log("⚠ This will be slow — please wait…")
            codes, rects = compress_bruteforce(img, progress_cb=prog)

        comp_time = time.time() - t0

        # ── Draw partitions on original ──────────────────────────
        qt_img = self.original_img.copy()
        draw = ImageDraw.Draw(qt_img)
        for x1, y1, x2, y2 in rects:
            draw.rectangle([x1, y1, x2, y2], outline="#ef4444", width=1)
        self.root.after(0, lambda: self._show_on_canvas(qt_img, self.cv_orig, "_tk_orig"))

        # ── Reconstruct ──────────────────────────────────────────
        self._log("Decompressing (8 iterations)…")
        recon_np = decompress(codes, h, w, iterations=8)
        recon_img = Image.fromarray(recon_np)
        self.root.after(0, lambda: self._show_on_canvas(recon_img, self.cv_recon, "_tk_recon"))

        # ── Compute Statistics ────────────────────────────────────
        mse  = float(np.mean((img.astype(np.float64) - recon_np.astype(np.float64)) ** 2))
        rmse = math.sqrt(mse)
        psnr = 20 * math.log10(255.0 / rmse) if rmse > 0 else 100.0

        # Compression ratio: original bytes vs. fractal code bytes
        # Each code ≈ 2(y) + 2(x) + 1(size) + 2(dy) + 2(dx) + 1(t) + 4(s) + 4(b) = 18 bytes
        orig_bytes = h * w
        code_bytes = len(codes) * 18
        ratio = orig_bytes / code_bytes if code_bytes > 0 else 0

        block_sizes = [c[2] for c in codes]
        min_bs = min(block_sizes) if block_sizes else 0
        max_bs = max(block_sizes) if block_sizes else 0

        self._log("")
        self._log("─── RESULTS ───────────────")
        self._log(f"  Time:        {comp_time:.2f} s")
        self._log(f"  Blocks:      {len(codes)}")
        self._log(f"  Block range: {min_bs}×{min_bs} → {max_bs}×{max_bs}")
        self._log("")
        self._log(f"  PSNR:        {psnr:.2f} dB")
        self._log(f"  RMSE:        {rmse:.2f}")
        self._log(f"  MSE:         {mse:.2f}")
        self._log("")
        self._log(f"  Original:    {orig_bytes:,} bytes")
        self._log(f"  Compressed:  {code_bytes:,} bytes")
        self._log(f"  Ratio:       {ratio:.1f}:1")
        self._log("───────────────────────────")

        self.root.after(0, lambda: self._set_buttons(tk.NORMAL))
        self.root.after(0, lambda: self.status_lbl.config(text="Done."))
        self.root.after(0, lambda: self.progress.configure(value=100))


# ═══════════════════════════════════════════════════════════════════
if __name__ == "__main__":
    root = tk.Tk()
    app = App(root)
    root.mainloop()
