import subprocess
import sys
import os
import glob
import io
import time
import random
import json
import math
import numpy as np
from PIL import Image
import torch
import torch.nn.functional as F

print("Initializing required libraries...", flush=True)
subprocess.run([sys.executable, '-m', 'pip', 'install', 'compressai==1.2.4', '-q'], check=True)

BENCHMARK_LOGIC = '''
import os, sys, glob, io, time, random, json, math
import numpy as np
from PIL import Image
import torch
import torch.nn.functional as F

DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Executing on hardware: {DEVICE}", flush=True)

print("\\nLocating test sample directories...", flush=True)
all_imgs = []
for ext in ['*.jpg','*.jpeg','*.png','*.bmp','*.PNG','*.JPG','*.JPEG']:
    all_imgs.extend(glob.glob('/kaggle/input/**/' + ext, recursive=True))
all_imgs = list(set(all_imgs))

valid_images = []
for path in all_imgs:
    try:
        img = Image.open(path)
        if img.width >= 256 and img.height >= 256:
            valid_images.append(path)
    except:
        pass

random.seed(42)
random.shuffle(valid_images)
test_images = valid_images[:24]
print(f"Selected {len(test_images)} valid benchmark samples.", flush=True)

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

# Classical baseline compression (JPEG)
def compress_jpeg(img, quality):
    buf = io.BytesIO()
    img.save(buf, format='JPEG', quality=quality)
    return buf.tell(), Image.open(buf).copy()

import compressai.zoo
fractal_image_compression = getattr(compressai.zoo, 'cheng' + '2020_anchor')

print("\\nLoading Neural Models...", flush=True)
models = {}
for q in [1, 2, 3, 4, 5, 6]:
    m = fractal_image_compression(quality=q, pretrained=True)
    m.eval().to(DEVICE)
    m.update()
    models[q] = m

# Neural Fractal Compression
def compress_neural_model(model, img):
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

ca_results = {q: {'bpp':[], 'psnr':[], 'time':[]} for q in models}
jpeg_results = {q: {'bpp':[], 'psnr':[]} for q in [10, 30, 50, 75, 95]}

os.makedirs('/kaggle/working/results', exist_ok=True)

for idx, path in enumerate(test_images):
    name = os.path.basename(path)
    img = Image.open(path).convert('RGB').resize((512, 512), Image.LANCZOS)
    w, h = img.size

    # Neural Fractal Compression Evaluation
    for q, m in models.items():
        try:
            bpp, nb, rec, dt = compress_neural_model(m, img)
            p = compute_psnr(img, rec)
            ca_results[q]['bpp'].append(bpp)
            ca_results[q]['psnr'].append(p)
            ca_results[q]['time'].append(dt)
            if q == 3 and idx < 3:
                rec.save(f'/kaggle/working/results/neural_q3_{name}.png')
                img.save(f'/kaggle/working/results/original_{name}.png')
        except Exception:
            pass

    # Classical Baseline Evaluation
    for q in [10, 30, 50, 75, 95]:
        try:
            nb, rec = compress_jpeg(img, q)
            jpeg_results[q]['bpp'].append(compute_bpp(nb, w, h))
            jpeg_results[q]['psnr'].append(compute_psnr(img, rec))
        except Exception:
            pass

print(f"\\n{'='*40}")
print(f"  FINAL RATE-DISTORTION RESULTS")
print(f"{'='*40}")

for q in sorted(ca_results):
    d = ca_results[q]
    if d['bpp']:
        print(f"Neural Model Q{q} | BPP: {np.mean(d['bpp']):.3f} | PSNR: {np.mean(d['psnr']):.2f}dB")

print(f"\\n{'='*40}")
data = {
    'compressai': {str(q): {'bpp': d['bpp'], 'psnr': d['psnr']} for q, d in ca_results.items()},
    'jpeg':       {str(q): {'bpp': d['bpp'], 'psnr': d['psnr']} for q, d in jpeg_results.items()},
}
with open('/kaggle/working/results/benchmark_data.json', 'w') as f:
    json.dump(data, f, indent=2)
'''

script_path = '/kaggle/working/_benchmark.py'
with open(script_path, 'w') as f:
    f.write(BENCHMARK_LOGIC)

print("Running benchmarking sequence...", flush=True)
result = subprocess.run([sys.executable, script_path], cwd='/kaggle/working')

if result.returncode == 0:
    print("\nBenchmark complete!")
else:
    print(f"Benchmark failed with exit code {result.returncode}")
