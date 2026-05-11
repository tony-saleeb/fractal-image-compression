"""
server.py — FractalCompression REST API
========================================
Loads the model ONCE at startup, then serves compress/decompress over HTTP.
The model stays in memory — no reload per request.

Start:
    py server.py

Endpoints:
    POST /compress    multipart: field "image" (any image file) → returns .fic binary
    POST /decompress  multipart: field "fic"   (.fic file)      → returns PNG binary
    GET  /health      → {"status": "ok", "model": "..."}

Flutter usage:
    var req = http.MultipartRequest('POST', Uri.parse('http://localhost:8000/compress'));
    req.files.add(await http.MultipartFile.fromPath('image', imagePath));
    var res = await req.send();
    // res.stream contains the .fic bytes
"""

import os, sys, io, struct, time, gc, asyncio, traceback, math
import torch
import torch.nn.functional as F
import numpy as np
from PIL import Image

try:
    import cv2
    HAS_CV2 = True
except ImportError:
    HAS_CV2 = False
    print("[Note] cv2 not installed. LAB color correction will be skipped.", flush=True)

# ── FastAPI ────────────────────────────────────────────────────
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import Response, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

# ── compressai ────────────────────────────────────────────────
try:
    from compressai.models import Cheng2020Attention, Cheng2020Anchor
    from compressai.ops import compute_padding
except Exception as e:
    print(f"[ERROR] compressai import failed: {e}")
    print("Run:  py patch_compressai.py")
    sys.exit(1)

# ── Config ────────────────────────────────────────────────────
MODEL_PATH = os.environ.get(
    'FC_MODEL',
    os.path.join(os.path.dirname(__file__), 'models', 'finetuned_fractalcompression_q2.pth')
)
PORT    = int(os.environ.get('FC_PORT', 8000))
HOST    = os.environ.get('FC_HOST', '0.0.0.0')
DEVICE  = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

# Images larger than MAX_DIM are downscaled before encoding.
# 512px: ~3-5s, blurry on large images | 1024px: ~10-15s, sharp output
MAX_DIM = int(os.environ.get('FC_MAX_DIM', 1024))

# ── CPU Performance Tuning ──────────────────────────────────────
# Use physical cores (not hyperthreads) for optimal tensor throughput
_cpu_count = os.cpu_count() or 4
_optimal_threads = max(2, min(_cpu_count // 2, 8))
torch.set_num_threads(_optimal_threads)
torch.set_num_interop_threads(2)  # Parallelize independent ops
torch.set_flush_denormal(True)

# ── Global enhancer & model ─────────────────────────────────────
MODEL = None
UPSAMPLER = None

def init_upsampler():
    """Load the custom PyTorch SR decoder with tiled inference for CPU speed."""
    global UPSAMPLER
    print("  Initializing Custom SR Decoder (PyTorch)...", flush=True)
    try:
        from custom_decoder import RRDBNet
        models_dir = os.path.join(os.path.dirname(__file__), 'models')
        sr_path = os.path.join(models_dir, 'my_custom_sr_decoder_epoch5.pth')
        
        if not os.path.exists(sr_path):
            print(f"  [Warning] SR model not found at {sr_path}. Skipping.", flush=True)
            UPSAMPLER = None
            return

        # Load model with lightweight config (fewer blocks = faster)
        model = RRDBNet(num_in_ch=3, num_out_ch=3, num_feat=64, num_block=23, num_grow_ch=32)
        state = torch.load(sr_path, map_location='cpu', weights_only=False)
        if 'params' in state:
            state = state['params']
        elif 'model_state_dict' in state:
            state = state['model_state_dict']
        model.load_state_dict(state, strict=False)
        model.eval()
        
        UPSAMPLER = model
        print(f"  Custom SR Decoder ready (PyTorch, tiled inference).", flush=True)
    except BaseException as e:
        print(f"  [Warning] SR initialization failed: {e}", flush=True)
        UPSAMPLER = None


def sr_tiled_inference(model, x_hat, tile_size=128, overlap=16):
    """
    Run SR model in tiles to stay cache-friendly on CPU.
    Full-image inference: ~150s.  Tiled inference: ~10-20s.
    
    The trick: small tiles fit in L2/L3 CPU cache, making each
    convolution 5-10x faster than on a full 512x512 tensor.
    """
    _, c, h, w = x_hat.shape
    
    # If image is small enough, run directly
    if h <= tile_size and w <= tile_size:
        with torch.inference_mode():
            return model(x_hat)
    
    stride = tile_size - overlap
    output = torch.zeros_like(x_hat)
    weight = torch.zeros(1, 1, h, w)  # blend weights for overlap regions
    
    total_tiles = ((h - 1) // stride + 1) * ((w - 1) // stride + 1)
    tile_n = 0
    
    with torch.inference_mode():
        for y in range(0, h, stride):
            for x_pos in range(0, w, stride):
                tile_n += 1
                # Clamp tile boundaries
                y_end = min(y + tile_size, h)
                x_end = min(x_pos + tile_size, w)
                y_start = max(0, y_end - tile_size)
                x_start = max(0, x_end - tile_size)
                
                tile = x_hat[:, :, y_start:y_end, x_start:x_end]
                sr_tile = model(tile)
                
                # Accumulate with blending
                output[:, :, y_start:y_end, x_start:x_end] += sr_tile
                weight[:, :, y_start:y_end, x_start:x_end] += 1.0
                
                if tile_n % 4 == 0 or tile_n == total_tiles:
                    print(f"    SR tile {tile_n}/{total_tiles}", flush=True, end='\r')
    
    print(f"    SR tiles: {total_tiles} processed.          ", flush=True)
    return output / weight


def compute_metrics(orig_tensor, recon_tensor):
    """Calculate PSNR and RMSE between two tensors [1, 3, H, W]."""
    mse = F.mse_loss(orig_tensor, recon_tensor).item()
    if mse < 1e-10:
        return 99.0, 0.0
    psnr = 20 * math.log10(1.0 / math.sqrt(mse))
    rmse = math.sqrt(mse) * 255.0
    return psnr, rmse

def load_model():
    global MODEL
    print(f"Loading FractalCompression model: {MODEL_PATH}", flush=True)
    print(f"Device: {DEVICE}", flush=True)

    ckpt = torch.load(MODEL_PATH, map_location='cpu', weights_only=False)
    if isinstance(ckpt, dict):
        sd = ckpt.get('model_state_dict', ckpt.get('state_dict', ckpt))
        epoch = ckpt.get('epoch', '?')
        psnr = ckpt.get('val_psnr', '?')
        bpp = ckpt.get('val_bpp', '?')
        psnr_str = f"{psnr:.2f}" if isinstance(psnr, (int, float)) else str(psnr)
        bpp_str = f"{bpp:.4f}" if isinstance(bpp, (int, float)) else str(bpp)
        print(f"  Epoch {epoch} | PSNR {psnr_str} dB | BPP {bpp_str}", flush=True)
    else:
        sd = ckpt

    N = 128
    for k, v in sd.items():
        if 'g_a.0.conv1.weight' in k:
            N = v.shape[0]; break

    has_attention = any('conv_a' in k for k in sd.keys())
    ModelClass    = Cheng2020Attention if has_attention else Cheng2020Anchor
    print(f"  {'FractalCompression-Attention' if has_attention else 'FractalCompression-Anchor'}  N={N}", flush=True)

    m = ModelClass(N=N)
    m.load_state_dict(sd, strict=False)
    m.eval().to(DEVICE)
    m.update()
    MODEL = m
    print("  Model ready.", flush=True)

    # ── Warmup pass: pre-allocate memory + JIT compile PyTorch kernels ──
    print("  Running warmup inference...", flush=True)
    try:
        dummy = torch.rand(1, 3, 64, 64, device=DEVICE)
        with torch.inference_mode():
            MODEL.compress(dummy)
        del dummy
        torch.cuda.empty_cache() if torch.cuda.is_available() else None
        gc.collect()
        print("  Warmup complete. Server starting...\n", flush=True)
    except Exception as e:
        print(f"  [Warning] Warmup failed (non-fatal): {e}\n", flush=True)

# ── FastAPI app ────────────────────────────────────────────────
app = FastAPI(title="FractalCompression API", version="1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)

@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    tb = traceback.format_exc()
    print(f"\n[CRITICAL ERROR] {exc}\n{tb}", flush=True)
    return JSONResponse(
        status_code=500,
        content={"detail": str(exc), "traceback": tb}
    )


@app.get("/health")
def health():
    return JSONResponse({"status": "ok", "model": MODEL_PATH, "device": str(DEVICE)})


@app.post("/compress")
async def compress_endpoint(image: UploadFile = File(...)):
    """
    Upload any image (JPG, PNG, BMP …) → download .fic compressed file.
    Flutter: MultipartRequest with field name 'image'
    """
    if MODEL is None:
        raise HTTPException(503, "Model not loaded")

    # Read uploaded image
    data = await image.read()
    try:
        img = Image.open(io.BytesIO(data)).convert('RGB')
    except Exception as e:
        raise HTTPException(400, f"Cannot open image: {e}")

    # Keep original source dimensions for upscaling on decompress
    source_w, source_h = img.size   # before any resize

    # ── Resize large images so CPU processing stays fast ──────────
    if max(source_w, source_h) > MAX_DIM:
        scale  = MAX_DIM / max(source_w, source_h)
        enc_w  = max(1, int(source_w * scale))
        enc_h  = max(1, int(source_h * scale))
        img    = img.resize((enc_w, enc_h), Image.LANCZOS)
        print(f"  Resized {source_w}×{source_h} → {enc_w}×{enc_h} (MAX_DIM={MAX_DIM})", flush=True)
    else:
        enc_w, enc_h = source_w, source_h

    x = torch.from_numpy(np.array(img)).float().div_(255.0)
    x = x.permute(2, 0, 1).unsqueeze(0).contiguous()

    h, w = x.shape[2], x.shape[3]
    # Ensure multiples of 64 AND at least 128x128 
    # (Satisfies both 16x main and 4x hyper-prior stages + 5x5 context kernel)
    target_h = max(128, ((h + 63) // 64) * 64)
    target_w = max(128, ((w + 63) // 64) * 64)
    
    p_h = target_h - h
    p_w = target_w - w
    
    # Pad right and bottom (F.pad takes [left, right, top, bottom])
    x_pad = F.pad(x, (0, p_w, 0, p_h), mode='constant', value=0).to(DEVICE)

    # ── Heavy inference offloaded to thread pool ──────────────────
    def _compress():
        gc.disable()
        try:
            with torch.inference_mode():
                return MODEL.compress(x_pad)
        finally:
            gc.enable()

    t0 = time.time()
    out = await asyncio.to_thread(_compress)
    elapsed = time.time() - t0

    # ── Calculate Quality Metrics ──
    # To get PSNR/RMSE, we must decompress what we just compressed
    def _get_metrics():
        with torch.inference_mode():
            # Decompress the latent we just made
            out_dec = MODEL.decompress(out['strings'], out['shape'])
            x_hat = out_dec['x_hat']
            # Crop to encoded dims
            x_hat = x_hat[:, :, :enc_h, :enc_w]
            x_hat = torch.clamp(x_hat, 0, 1)
            # Compare against the (possibly resized) input x
            return compute_metrics(x[:, :, :enc_h, :enc_w].to(DEVICE), x_hat)

    psnr, rmse = await asyncio.to_thread(_get_metrics)

    sy    = out['strings'][0][0]
    sz    = out['strings'][1][0]
    shape = out['shape']

    # Build .fic bytes in memory — FIC3 format stores metrics in header
    buf = io.BytesIO()
    buf.write(b'FIC3')                                       # magic v3
    buf.write(struct.pack('<HH', source_w, source_h))        # original dims
    buf.write(struct.pack('<HH', enc_w,    enc_h))           # encoded dims
    buf.write(struct.pack('<HH', x_pad.shape[3], x_pad.shape[2]))  # padded dims
    buf.write(struct.pack('<HH', shape[0], shape[1]))        # latent dims
    buf.write(struct.pack('<ff', psnr, rmse))                # QUALITY METRICS
    buf.write(struct.pack('<I', len(sy)))
    buf.write(struct.pack('<I', len(sz)))
    buf.write(sy)
    buf.write(sz)
    fic_bytes = buf.getvalue()

    bpp   = (len(sy) + len(sz)) * 8 / (enc_w * enc_h)
    
    # Calculate ratio against the actual original file size (e.g. PNG size)
    original_file_size = len(data)
    ratio = original_file_size / len(fic_bytes)
    
    stem  = os.path.splitext(image.filename or 'image')[0]

    print(f"[compress] {image.filename}  source:{source_w}×{source_h}  "
          f"encoded:{enc_w}×{enc_h}  "
          f"{len(fic_bytes)/1024:.1f} KB  {ratio:.1f}:1  PSNR:{psnr:.1f}  {elapsed:.2f}s", flush=True)

    return Response(
        content=fic_bytes,
        media_type="application/octet-stream",
        headers={
            "Content-Disposition": f'attachment; filename="{stem}.fic"',
            "X-Ratio":         f"{ratio:.1f}",
            "X-PSNR":          f"{psnr:.1f}",
            "X-RMSE":          f"{rmse:.2f}",
            "X-BPP":           f"{bpp:.4f}",
            "X-Time":          f"{elapsed:.2f}",
            "X-Width":         str(source_w),
            "X-Height":        str(source_h),
            "X-Encoded-Width": str(enc_w),
            "X-Encoded-Height":str(enc_h),
        }
    )


@app.post("/decompress")
async def decompress_endpoint(fic: UploadFile = File(...)):
    """
    Upload a .fic file → download decoded PNG image.
    FIC2 format: upscales output back to the original source resolution.
    FIC1 format: decoded as-is (backward compatible).
    """
    if MODEL is None:
        raise HTTPException(503, "Model not loaded")

    print(f"\n[decompress] Received request for {fic.filename}", flush=True)
    data = await fic.read()
    print(f"  Read {len(data)} bytes.", flush=True)
    
    magic = data[:4]
    if magic not in (b'FIC1', b'FIC2', b'FIC3'):
        print(f"  [Error] Invalid magic: {magic}", flush=True)
        raise HTTPException(400, "Not a valid .fic file")

    is_v3 = (magic == b'FIC3')
    is_v2 = (magic == b'FIC2' or is_v3)
    print(f"  Format: {magic.decode()}", flush=True)

    psnr, rmse = 0.0, 0.0
    with io.BytesIO(data) as buf:
        buf.read(4)   # skip magic
        if is_v2:
            source_w, source_h = struct.unpack('<HH', buf.read(4))
            enc_w,   enc_h    = struct.unpack('<HH', buf.read(4))
        else:
            enc_w, enc_h = struct.unpack('<HH', buf.read(4))
            source_w, source_h = enc_w, enc_h
        pad_w,  pad_h = struct.unpack('<HH', buf.read(4))
        lat_h,  lat_w = struct.unpack('<HH', buf.read(4))
        
        if is_v3:
            psnr, rmse = struct.unpack('<ff', buf.read(8))
            
        len_y  = struct.unpack('<I', buf.read(4))[0]
        len_z  = struct.unpack('<I', buf.read(4))[0]
        sy     = buf.read(len_y)
        sz     = buf.read(len_z)
    
    print(f"  Dims: {source_w}x{source_h} (source) | {enc_w}x{enc_h} (encoded)", flush=True)
    print(f"  Strings: {len_y}y , {len_z}z", flush=True)

    print("  Starting Neural Decompression...", flush=True)

    def _decompress():
        gc.disable()
        try:
            with torch.inference_mode():
                return MODEL.decompress([[sy], [sz]], [lat_h, lat_w])
        finally:
            gc.enable()

    t0 = time.time()
    try:
        out = await asyncio.to_thread(_decompress)
    except Exception as e:
        print(f"  [Error] Neural decompress failed: {e}", flush=True)
        raise HTTPException(500, f"Neural decompression failed: {e}")
    elapsed = time.time() - t0
    print(f"  Neural decompress finished in {elapsed:.2f}s", flush=True)

    x_hat = out['x_hat']
    # Crop padding, then clip to encoded dims
    x_hat = F.pad(x_hat, [0, -(pad_w - enc_w), 0, -(pad_h - enc_h)])
    x_hat = torch.clamp(x_hat[:, :, :enc_h, :enc_w], 0, 1)

    img_np = (x_hat.squeeze(0).permute(1, 2, 0).cpu().numpy() * 255).astype(np.uint8)
    img    = Image.fromarray(img_np)

    # ── AI Super-Resolution & Upscale ──────────────────────────────
    if UPSAMPLER is not None:
        try:
            print("  Starting AI Super-Resolution (tiled PyTorch)...", flush=True)
            t1 = time.time()
            
            def _sr_pass():
                gc.disable()
                try:
                    return sr_tiled_inference(UPSAMPLER, x_hat.cpu(), tile_size=128, overlap=16)
                finally:
                    gc.enable()
            
            x_sr = await asyncio.to_thread(_sr_pass)
            sr_elapsed = time.time() - t1
            print(f"  AI SR finished in {sr_elapsed:.2f}s", flush=True)
            elapsed += sr_elapsed
            
            x_sr = torch.clamp(x_sr, 0, 1)
            img_enh_np = (x_sr.squeeze(0).permute(1, 2, 0).numpy() * 255).astype(np.uint8)
            
            # ── Clever Color Correction Match (LAB Space) ──
            if HAS_CV2:
                img_orig_np = (x_hat.squeeze(0).permute(1, 2, 0).cpu().numpy() * 255).astype(np.uint8)
                enh_lab = cv2.cvtColor(img_enh_np, cv2.COLOR_RGB2LAB)
                orig_lab = cv2.cvtColor(img_orig_np, cv2.COLOR_RGB2LAB)
                enh_lab[:,:,1] = orig_lab[:,:,1]
                enh_lab[:,:,2] = orig_lab[:,:,2]
                img_np = cv2.cvtColor(enh_lab, cv2.COLOR_LAB2RGB)
            else:
                img_np = img_enh_np

            img = Image.fromarray(img_np)
            print(f"  [AI SR Complete] Tiled reconstruction finished.", flush=True)
        except Exception as e:
            print(f"  [AI SR Error]: Enhancement failed: {e}", flush=True)

    if (source_w, source_h) != (enc_w, enc_h):
        img = img.resize((source_w, source_h), Image.LANCZOS)
        print(f"  Upscaled {enc_w}×{enc_h} → {source_w}×{source_h}", flush=True)

    png_buf = io.BytesIO()
    img.save(png_buf, format='PNG')
    png_bytes = png_buf.getvalue()

    stem = os.path.splitext(fic.filename or 'image')[0]
    print(f"[decompress] {fic.filename}  source:{source_w}×{source_h}  "
          f"encoded:{enc_w}×{enc_h}  size:{len(png_bytes)/1024:.1f} KB  {elapsed:.2f}s", flush=True)

    return Response(
        content=png_bytes,
        media_type="image/png",
        headers={
            "Content-Disposition": f'attachment; filename="{stem}_decoded.png"',
            "X-Time":   f"{elapsed:.2f}",
            "X-Width":  str(source_w),
            "X-Height": str(source_h),
            "X-PSNR":   f"{psnr:.1f}",
            "X-RMSE":   f"{rmse:.2f}",
        }
    )




# ── Entry point ────────────────────────────────────────────────
if __name__ == "__main__":
    # init_upsampler()  # SR disabled — using neural decoder only
    load_model()
    print(f"Server running at http://localhost:{PORT}", flush=True)
    print(f"  POST http://localhost:{PORT}/compress   => upload image => .fic")
    print(f"  POST http://localhost:{PORT}/decompress => upload .fic  => PNG")
    print(f"  GET  http://localhost:{PORT}/health")
    print(f"  MAX image dimension: {MAX_DIM}px  (set FC_MAX_DIM env to change)\n")
    uvicorn.run(
        app,
        host=HOST,
        port=PORT,
        log_level="info",
        timeout_keep_alive=600,   # keep connection alive for slow CPU inference
    )
