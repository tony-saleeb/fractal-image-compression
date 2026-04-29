"""
LEARNED IMAGE COMPRESSION — THESIS BENCHMARK
=============================================
Kaggle single-cell notebook. Uses subprocess to avoid numpy ABI conflicts.
Add dataset: DIV2K_Flickr2K_BSD500_WED | GPU: T4
Runtime: ~20-30 minutes
"""

import subprocess, sys, os

# Step 1: Install compressai
print("Installing CompressAI...", flush=True)
subprocess.run([sys.executable, '-m', 'pip', 'install', 'compressai==1.2.4', '-q'], check=True)
print("Done.", flush=True)

# Step 2: Write benchmark script to file (runs in fresh subprocess = no numpy conflicts)
SCRIPT = '''
import os, sys, glob, io, time, random, json, math
import numpy as np
from PIL import Image
import torch
import torch.nn.functional as F

DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Device: {DEVICE}", flush=True)
if torch.cuda.is_available():
    print(f"  GPU: {torch.cuda.get_device_name(0)}", flush=True)

# ── FIND TEST IMAGES ───────────────────────────────────────────
print("\\nSearching for test images...", flush=True)
all_imgs = []
for ext in ['*.jpg','*.jpeg','*.png','*.bmp','*.PNG','*.JPG','*.JPEG']:
    all_imgs.extend(glob.glob('/kaggle/input/**/' + ext, recursive=True))
all_imgs = list(set(all_imgs))

valid = []
for p in all_imgs:
    try:
        img = Image.open(p)
        if img.width >= 256 and img.height >= 256:
            valid.append(p)
    except:
        pass

random.seed(42)
random.shuffle(valid)
test_images = valid[:24]
print(f"Found {len(valid)} valid images, using {len(test_images)} for benchmark", flush=True)

if not test_images:
    print("ERROR: No images found! Add image dataset to notebook inputs.", flush=True)
    sys.exit(1)

# ── METRICS ────────────────────────────────────────────────────
def compute_psnr(orig, recon):
    a = np.array(orig.convert('RGB'), dtype=np.float32)
    b = np.array(recon.convert('RGB'), dtype=np.float32)
    if a.shape != b.shape:
        b = np.array(recon.resize(orig.size, Image.LANCZOS).convert('RGB'), dtype=np.float32)
    mse = ((a - b)**2).mean()
    if mse < 1e-10: return 99.0
    return 20 * np.log10(255.0 / np.sqrt(mse))

def compute_bpp(nbytes, w, h):
    return (nbytes * 8) / (w * h)

# ── JPEG & JPEG2000 ───────────────────────────────────────────
def compress_jpeg(img, quality):
    buf = io.BytesIO()
    img.save(buf, format='JPEG', quality=quality)
    n = buf.tell()
    buf.seek(0)
    return n, Image.open(buf).copy()

def compress_jpeg2000(img, rate):
    buf = io.BytesIO()
    img.save(buf, format='JPEG2000', quality_mode='rates', quality_layers=[rate])
    n = buf.tell()
    buf.seek(0)
    return n, Image.open(buf).copy()

# ── COMPRESSAI ─────────────────────────────────────────────────
from compressai.zoo import cheng2020_anchor

print("\\nLoading Deep Neural models (Q1-Q6)...", flush=True)
models = {}
for q in [1, 2, 3, 4, 5, 6]:
    m = cheng2020_anchor(quality=q, pretrained=True)
    m.eval().to(DEVICE)
    m.update()
    models[q] = m
    print(f"  Q{q} loaded", flush=True)

def compress_ca(model, img):
    w, h = img.size
    pw = (64 - w % 64) % 64
    ph = (64 - h % 64) % 64
    padded = Image.new('RGB', (w + pw, h + ph))
    padded.paste(img, (0, 0))
    x = torch.from_numpy(np.array(padded, dtype=np.float32) / 255.0)
    x = x.permute(2, 0, 1).unsqueeze(0).to(DEVICE)

    t0 = time.time()
    with torch.no_grad():
        out = model.compress(x)
    total_bytes = sum(len(s) for sl in out['strings'] for s in sl if isinstance(s, (bytes, bytearray)))

    with torch.no_grad():
        dec = model.decompress(out['strings'], out['shape'])
    dt = time.time() - t0

    xh = dec['x_hat'][:, :, :h, :w]
    arr = (xh.squeeze(0).permute(1,2,0).cpu().numpy() * 255).clip(0, 255).astype(np.uint8)
    return compute_bpp(total_bytes, w, h), total_bytes, Image.fromarray(arr), dt

# ── RUN BENCHMARK ──────────────────────────────────────────────
print(f"\\n{'='*72}", flush=True)
print(f"  BENCHMARK: {len(test_images)} images x (6 CA + 5 JPEG + 5 JP2K)", flush=True)
print(f"{'='*72}", flush=True)

os.makedirs('/kaggle/working/results', exist_ok=True)

ca_r   = {q: {'bpp':[], 'psnr':[], 'time':[]} for q in models}
jpeg_r = {q: {'bpp':[], 'psnr':[]} for q in [10, 30, 50, 75, 95]}
jp2_r  = {q: {'bpp':[], 'psnr':[]} for q in [5, 10, 20, 40, 80]}

for idx, path in enumerate(test_images):
    name = os.path.basename(path)
    img = Image.open(path).convert('RGB').resize((512, 512), Image.LANCZOS)
    w, h = img.size
    print(f"\\n  [{idx+1}/{len(test_images)}] {name}", flush=True)

    # CompressAI
    line = "    CA: "
    for q, m in models.items():
        try:
            bpp, nb, rec, dt = compress_ca(m, img)
            p = compute_psnr(img, rec)
            ca_r[q]['bpp'].append(bpp)
            ca_r[q]['psnr'].append(p)
            ca_r[q]['time'].append(dt)
            line += f"Q{q}={p:.1f}dB "
            if q == 3 and idx < 3:
                rec.save(f'/kaggle/working/results/ca_q3_{name}.png')
                img.save(f'/kaggle/working/results/orig_{name}.png')
        except Exception as e:
            line += f"Q{q}=ERR "
    print(line, flush=True)

    # JPEG
    line = "    JPEG: "
    for q in [10, 30, 50, 75, 95]:
        try:
            nb, rec = compress_jpeg(img, q)
            bpp = compute_bpp(nb, w, h)
            p = compute_psnr(img, rec)
            jpeg_r[q]['bpp'].append(bpp)
            jpeg_r[q]['psnr'].append(p)
            line += f"Q{q}={p:.1f}dB "
        except:
            line += f"Q{q}=ERR "
    print(line, flush=True)

    # JPEG2000
    line = "    JP2K: "
    for q in [5, 10, 20, 40, 80]:
        try:
            nb, rec = compress_jpeg2000(img, q)
            bpp = compute_bpp(nb, w, h)
            p = compute_psnr(img, rec)
            jp2_r[q]['bpp'].append(bpp)
            jp2_r[q]['psnr'].append(p)
            line += f"R{q}={p:.1f}dB "
        except:
            line += f"R{q}=ERR "
    print(line, flush=True)

# ── RESULTS TABLE ──────────────────────────────────────────────
print(f"\\n\\n{'='*72}", flush=True)
print(f"  RATE-DISTORTION RESULTS (avg over {len(test_images)} images)", flush=True)
print(f"{'='*72}", flush=True)

print(f"\\n  Learned Compression (Deep Neural Model):", flush=True)
print(f"  {'Quality':>8} {'BPP':>8} {'PSNR':>8} {'Ratio':>8} {'Time':>8}", flush=True)
print(f"  {'-'*44}", flush=True)
for q in sorted(ca_r):
    d = ca_r[q]
    if d['bpp']:
        bpp = np.mean(d['bpp'])
        psnr = np.mean(d['psnr'])
        print(f"  {'Q'+str(q):>8} {bpp:>8.3f} {psnr:>7.2f}dB {3/bpp:>7.1f}:1 {np.mean(d['time']):>7.2f}s", flush=True)

print(f"\\n  JPEG:", flush=True)
print(f"  {'Quality':>8} {'BPP':>8} {'PSNR':>8} {'Ratio':>8}", flush=True)
print(f"  {'-'*36}", flush=True)
for q in sorted(jpeg_r):
    d = jpeg_r[q]
    if d['bpp']:
        bpp = np.mean(d['bpp'])
        psnr = np.mean(d['psnr'])
        print(f"  {'Q'+str(q):>8} {bpp:>8.3f} {psnr:>7.2f}dB {3/bpp:>7.1f}:1", flush=True)

print(f"\\n  JPEG2000:", flush=True)
print(f"  {'Rate':>8} {'BPP':>8} {'PSNR':>8} {'Ratio':>8}", flush=True)
print(f"  {'-'*36}", flush=True)
for q in sorted(jp2_r):
    d = jp2_r[q]
    if d['bpp']:
        bpp = np.mean(d['bpp'])
        psnr = np.mean(d['psnr'])
        print(f"  {'R'+str(q):>8} {bpp:>8.3f} {psnr:>7.2f}dB {3/bpp:>7.1f}:1", flush=True)

# ── THESIS SUMMARY ─────────────────────────────────────────────
print(f"\\n\\n{'='*72}", flush=True)
print(f"  THESIS SUMMARY", flush=True)
print(f"{'='*72}", flush=True)

# Compare at similar BPP
for q in [2, 3, 4]:
    if not ca_r[q]['bpp']: continue
    ca_bpp = np.mean(ca_r[q]['bpp'])
    ca_psnr = np.mean(ca_r[q]['psnr'])
    # Find closest JPEG
    best_jq = min(jpeg_r, key=lambda jq: abs(np.mean(jpeg_r[jq]['bpp']) - ca_bpp) if jpeg_r[jq]['bpp'] else 999)
    j_psnr = np.mean(jpeg_r[best_jq]['psnr']) if jpeg_r[best_jq]['psnr'] else 0
    j_bpp = np.mean(jpeg_r[best_jq]['bpp']) if jpeg_r[best_jq]['bpp'] else 0
    gain = ca_psnr - j_psnr
    print(f"\\n  At ~{ca_bpp:.2f} bpp ({3/ca_bpp:.0f}:1 ratio):", flush=True)
    print(f"    Learned Model Q{q}: {ca_psnr:.2f} dB", flush=True)
    print(f"    JPEG Q{best_jq}:      {j_psnr:.2f} dB (at {j_bpp:.2f} bpp)", flush=True)
    print(f"    Gain: +{gain:.2f} dB", flush=True)

# Save JSON
data = {
    'compressai': {str(q): {'bpp': d['bpp'], 'psnr': d['psnr']} for q, d in ca_r.items()},
    'jpeg':       {str(q): {'bpp': d['bpp'], 'psnr': d['psnr']} for q, d in jpeg_r.items()},
    'jpeg2000':   {str(q): {'bpp': d['bpp'], 'psnr': d['psnr']} for q, d in jp2_r.items()},
}
with open('/kaggle/working/results/benchmark_data.json', 'w') as f:
    json.dump(data, f, indent=2)

print(f"\\n{'='*72}", flush=True)
print(f"  Output: /kaggle/working/results/", flush=True)
print(f"  - benchmark_data.json (raw data for RD curve plots)", flush=True)
print(f"  - orig_*.png + ca_q3_*.png (visual comparisons)", flush=True)
print(f"{'='*72}", flush=True)
'''

# Step 3: Write and run in subprocess (clean Python = no numpy corruption)
script_path = '/kaggle/working/_benchmark.py'
with open(script_path, 'w') as f:
    f.write(SCRIPT)

print("Running benchmark (subprocess)...", flush=True)
result = subprocess.run(
    [sys.executable, script_path],
    cwd='/kaggle/working',
)

if result.returncode != 0:
    print(f"Benchmark failed with exit code {result.returncode}")
else:
    print("\nBenchmark complete! Download results from /kaggle/working/results/")
