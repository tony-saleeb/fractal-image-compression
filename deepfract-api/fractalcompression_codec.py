"""
fractalcompression_codec.py
============================
Compress / decompress images using a finetuned FractalCompression model.
Achieves ~85:1 ratio with ~29 dB PSNR using learned entropy coding.

Usage:
  Compress:
    py fractalcompression_codec.py compress --image data/lena.png
  Decompress:
    py fractalcompression_codec.py decompress --input data/lena.fic
  Measure quality:
    py fractalcompression_codec.py psnr --image data/lena.png --recon data/lena_decoded.png

.fic file format (FIC1):
  4 bytes  : magic 'FIC1'
  2+2 bytes: original width, height (uint16 LE)
  2+2 bytes: padded width, height   (uint16 LE)
  2+2 bytes: latent height, width   (uint16 LE)
  4 bytes  : len(string_y)
  4 bytes  : len(string_z)
  N bytes  : string_y  (entropy-coded main latent)
  M bytes  : string_z  (entropy-coded hyperlatent)
"""

import sys, os, struct, time, argparse
import torch
import torch.nn.functional as F
from PIL import Image
import numpy as np

# Use all CPU cores
torch.set_num_threads(os.cpu_count() or 4)

# ──────────────────────────────────────────────
# compressai import (run patch_compressai.py once if this fails)
# ──────────────────────────────────────────────
try:
    from compressai.models import Cheng2020Attention, Cheng2020Anchor
    from compressai.ops import compute_padding
except Exception as e:
    import traceback
    print(f"[ERROR] compressai import failed: {e}")
    print("Run:  py patch_compressai.py")
    traceback.print_exc()
    sys.exit(1)

MAGIC         = b'FIC1'
DEFAULT_MODEL = 'models/finetuned_fractalcompression_q2.pth'


# ──────────────────────────────────────────────
# Load model
# ──────────────────────────────────────────────
def load_model(model_path, device):
    print(f"Loading FractalCompression model: {model_path}", flush=True)
    ckpt = torch.load(model_path, map_location='cpu', weights_only=False)

    if isinstance(ckpt, dict):
        print(f"  Epoch: {ckpt.get('epoch','?')} | "
              f"PSNR: {ckpt.get('val_psnr','?'):.2f} dB | "
              f"BPP: {ckpt.get('val_bpp','?'):.4f} | "
              f"Quality: {ckpt.get('quality','?')}", flush=True)
        sd = ckpt.get('model_state_dict', ckpt.get('state_dict', ckpt))
    else:
        sd = ckpt

    # Auto-detect N from analysis transform
    N = 128
    for k, v in sd.items():
        if 'g_a.0.conv1.weight' in k:
            N = v.shape[0]; break

    # Auto-detect architecture
    has_attention = any('conv_a' in k for k in sd.keys())
    ModelClass = Cheng2020Attention if has_attention else Cheng2020Anchor
    variant    = 'FractalCompression-Attention' if has_attention else 'FractalCompression-Anchor'
    print(f"  Variant: {variant}  N={N}", flush=True)

    model = ModelClass(N=N)
    missing, unexpected = model.load_state_dict(sd, strict=False)
    if missing:
        print(f"  Info: {len(missing)} keys not in checkpoint", flush=True)

    model.eval().to(device)
    model.update()
    print("  Model ready.", flush=True)
    return model


# ──────────────────────────────────────────────
# Load image → tensor
# ──────────────────────────────────────────────
def load_image(path):
    img = Image.open(path).convert('RGB')
    orig_w, orig_h = img.size
    x = torch.from_numpy(np.array(img)).float() / 255.0
    x = x.permute(2, 0, 1).unsqueeze(0)   # 1 C H W
    return x, orig_w, orig_h


# ──────────────────────────────────────────────
# COMPRESS  →  .fic
# ──────────────────────────────────────────────
def compress(args):
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"Device: {device}", flush=True)

    model = load_model(args.model, device)

    x, orig_w, orig_h = load_image(args.image)
    print(f"Image: {args.image}  ({orig_w}×{orig_h})", flush=True)

    input_kb  = os.path.getsize(args.image) / 1024
    raw_bytes = orig_w * orig_h * 3

    h, w = x.shape[2], x.shape[3]
    pad, _ = compute_padding(h, w, min_div=64)
    x_padded = F.pad(x, pad, mode='constant', value=0).to(device)

    print("Compressing...", flush=True)
    t0 = time.time()
    with torch.inference_mode():
        out = model.compress(x_padded)
    elapsed = time.time() - t0

    strings_y   = out['strings'][0][0]
    strings_z   = out['strings'][1][0]
    shape       = out['shape']
    total_bytes = len(strings_y) + len(strings_z)

    out_path = args.output or os.path.splitext(args.image)[0] + '.fic'
    with open(out_path, 'wb') as f:
        f.write(MAGIC)
        f.write(struct.pack('<HH', orig_w, orig_h))
        f.write(struct.pack('<HH', x_padded.shape[3], x_padded.shape[2]))
        f.write(struct.pack('<HH', shape[0], shape[1]))
        f.write(struct.pack('<I', len(strings_y)))
        f.write(struct.pack('<I', len(strings_z)))
        f.write(strings_y)
        f.write(strings_z)

    out_kb = os.path.getsize(out_path) / 1024
    bpp    = (total_bytes * 8) / (orig_w * orig_h)

    print(f"\n{'='*50}")
    print(f"Compressed:  {out_path}")
    print(f"Input size:  {input_kb:.1f} KB  ({orig_w}×{orig_h})")
    print(f"Output size: {out_kb:.2f} KB")
    print(f"Ratio:       {input_kb/out_kb:.1f}:1  (vs input file)")
    print(f"Ratio:       {raw_bytes/total_bytes:.1f}:1  (vs raw RGB)")
    print(f"BPP:         {bpp:.4f}")
    print(f"Time:        {elapsed:.2f}s")
    print(f"{'='*50}")


# ──────────────────────────────────────────────
# DECOMPRESS  ←  .fic
# ──────────────────────────────────────────────
def decompress(args):
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"Device: {device}", flush=True)

    model = load_model(args.model, device)

    with open(args.input, 'rb') as f:
        magic = f.read(4)
        if magic != MAGIC:
            raise ValueError(f"Not a valid .fic file (magic={magic})")
        orig_w, orig_h = struct.unpack('<HH', f.read(4))
        pad_w,  pad_h  = struct.unpack('<HH', f.read(4))
        lat_h,  lat_w  = struct.unpack('<HH', f.read(4))
        len_y          = struct.unpack('<I', f.read(4))[0]
        len_z          = struct.unpack('<I', f.read(4))[0]
        strings_y      = f.read(len_y)
        strings_z      = f.read(len_z)

    print(f"Decompressing: {args.input}  ({orig_w}×{orig_h})", flush=True)
    t0 = time.time()
    with torch.inference_mode():
        out = model.decompress([[strings_y], [strings_z]], [lat_h, lat_w])
    elapsed = time.time() - t0

    x_hat = out['x_hat']
    x_hat = F.pad(x_hat, [0, -(pad_w - orig_w), 0, -(pad_h - orig_h)])
    x_hat = torch.clamp(x_hat[:, :, :orig_h, :orig_w], 0, 1)

    out_path = args.output or os.path.splitext(args.input)[0] + '_decoded.png'
    img_np = (x_hat.squeeze(0).permute(1,2,0).cpu().numpy() * 255).astype(np.uint8)
    Image.fromarray(img_np).save(out_path)

    print(f"Decoded:  {out_path}  ({orig_w}×{orig_h})")
    print(f"Time:     {elapsed:.2f}s")


# ──────────────────────────────────────────────
# PSNR / RMSE
# ──────────────────────────────────────────────
def measure_psnr(args):
    orig  = np.array(Image.open(args.image).convert('RGB'), dtype=np.float64)
    recon = np.array(Image.open(args.recon).convert('RGB'),  dtype=np.float64)
    if orig.shape != recon.shape:
        recon = np.array(Image.fromarray(recon.astype(np.uint8)).resize(
            (orig.shape[1], orig.shape[0])), dtype=np.float64)
    mse  = np.mean((orig - recon) ** 2)
    psnr = 10 * np.log10(255**2 / mse) if mse > 0 else 100.0
    rmse = np.sqrt(mse)
    print(f"PSNR: {psnr:.2f} dB  |  RMSE: {rmse:.2f}")


# ──────────────────────────────────────────────
# CLI
# ──────────────────────────────────────────────
def main():
    p = argparse.ArgumentParser(description='FractalCompression FIC Codec')
    sub = p.add_subparsers(dest='cmd')

    c = sub.add_parser('compress',   help='Compress image → .fic')
    c.add_argument('--image',  required=True, help='Input image path')
    c.add_argument('--model',  default=DEFAULT_MODEL)
    c.add_argument('--output', default=None,  help='Output .fic path')

    d = sub.add_parser('decompress', help='Decompress .fic → image')
    d.add_argument('--input',  required=True, help='Input .fic path')
    d.add_argument('--model',  default=DEFAULT_MODEL)
    d.add_argument('--output', default=None,  help='Output image path')

    q = sub.add_parser('psnr', help='Measure PSNR between two images')
    q.add_argument('--image', required=True)
    q.add_argument('--recon', required=True)

    args = p.parse_args()
    if   args.cmd == 'compress':   compress(args)
    elif args.cmd == 'decompress': decompress(args)
    elif args.cmd == 'psnr':       measure_psnr(args)
    else: p.print_help()


if __name__ == '__main__':
    main()
