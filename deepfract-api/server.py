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



import contextlib
import os, sys, io, struct, time, gc, asyncio, traceback, math, hashlib

# ── Architect's OpenMP Thread Affinity (Must be set before torch import) ──
os.environ["OMP_NUM_THREADS"] = "2"
os.environ["OMP_PROC_BIND"] = "close"
os.environ["GOMP_SPINCOUNT"] = "100"
os.environ["KMP_AFFINITY"] = "granularity=fine,compact,1,0"

import torch
import torch.nn.functional as F
import numpy as np
from PIL import Image
Image.MAX_IMAGE_PIXELS = None # Disable decompression bomb limits for massive images

try:
    import cv2
    HAS_CV2 = True
except ImportError:
    HAS_CV2 = False
    print("[Note] cv2 not installed. LAB color correction will be skipped.", flush=True)

# ── FastAPI ────────────────────────────────────────────────────
from fastapi import FastAPI, File, UploadFile, HTTPException, Request
from fastapi.responses import Response, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

# ── compressai fallback (Hidden import to silence aggressive IDEs) ──
import importlib
COMPRESSAI_MODE = "fallback"
try:
    models_mod = importlib.import_module("compressai.models")
    ops_mod    = importlib.import_module("compressai.ops")
    Cheng2020Attention = models_mod.Cheng2020Attention
    Cheng2020Anchor    = models_mod.Cheng2020Anchor
    compute_padding    = ops_mod.compute_padding
    COMPRESSAI_MODE    = "standard"
except ImportError:
    try:
        import compressai_fallback
        Cheng2020Attention = compressai_fallback.Cheng2020Attention
        Cheng2020Anchor    = compressai_fallback.Cheng2020Anchor
        compute_padding    = compressai_fallback.compute_padding
    except ImportError:
        print("[ERROR] All compressai imports failed. Please check compressai_fallback.py")
        sys.exit(1)

print(f"[Info] Neural Engine: {COMPRESSAI_MODE} mode.", flush=True)

# ── Config ────────────────────────────────────────────────────
MODEL_PATH = os.environ.get(
    'FC_MODEL',
    os.path.join(os.path.dirname(__file__), 'models', 'finetuned_fractalcompression_q2.pth')
)
PORT    = int(os.environ.get('PORT', os.environ.get('FC_PORT', 8000)))
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

# ── Professional CPU Architecture Optimization ─────────────────
with contextlib.suppress(RuntimeError):
    torch.set_num_threads(2)           # Match HF 2-core limit
    torch.set_num_interop_threads(2)   # Parallelize independent ops
    if hasattr(torch.backends, 'mkldnn'):
        torch.backends.mkldnn.enabled = True
torch.set_flush_denormal(True)
torch.set_grad_enabled(False)
DEVICE = torch.device("cpu")

# Images larger than MAX_DIM are downscaled before encoding.
# 512px: ~3-5s, blurry on large images | 1024px: ~10-15s, sharp output
MAX_DIM = int(os.environ.get('FC_MAX_DIM', 1024))

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
        print("  Custom SR Decoder ready (PyTorch, tiled inference).", flush=True)
    except BaseException as e:
        print(f"  [Warning] SR initialization failed: {e}", flush=True)
        UPSAMPLER = None


def blend_tile_seams(canvas_tensor, tile_size, blend_width=16):
    """
    Smooth visible seam lines at tile boundaries on a [1,C,H,W] tensor.
    
    Applies a 1-D Gaussian blur along every horizontal and vertical tile
    boundary.  Only the narrow strip around each seam is touched — the
    rest of the image is untouched, so quality is preserved and the cost
    is negligible.
    
    Args:
        canvas_tensor: [1, 3, H, W] float tensor (0-1 range)
        tile_size: the grid spacing used during tiled compression
        blend_width: half-width of the blending strip in pixels
    Returns:
        Tensor with the same shape, seams smoothed.
    """
    _, c, h, w = canvas_tensor.shape
    result = canvas_tensor.clone()

    # Build a small 1-D Gaussian kernel (σ = blend_width / 3)
    sigma = max(blend_width / 3.0, 1.0)
    ks = blend_width * 2 + 1  # kernel size (always odd)
    coords = torch.arange(ks, dtype=torch.float32) - blend_width
    kernel_1d = torch.exp(-0.5 * (coords / sigma) ** 2)
    kernel_1d = kernel_1d / kernel_1d.sum()

    # ── Horizontal seams (rows at multiples of tile_size) ──────────
    for y in range(tile_size, h, tile_size):
        y0 = max(y - blend_width, 0)
        y1 = min(y + blend_width, h)
        if y1 - y0 < 3:
            continue
        strip = canvas_tensor[:, :, y0:y1, :]          # [1, C, strip_h, W]

        # Blur vertically: reshape kernel to [1, 1, ks, 1]
        k = kernel_1d[:y1 - y0].clone()
        k = k / k.sum()
        k_v = k.reshape(1, 1, -1, 1)
        # Apply per-channel
        blurred = torch.cat([
            F.conv2d(
                strip[:, ch:ch+1, :, :],
                k_v,
                padding=(k_v.shape[2] // 2, 0)
            )
            for ch in range(c)
        ], dim=1)
        # Crop to exact strip height (conv may add a row)
        blurred = blurred[:, :, :y1 - y0, :]

        # Blend weight: 1.0 at the seam line, 0.0 at the edges
        ramp = torch.linspace(0, 1, y1 - y0)
        alpha = 1.0 - 2.0 * (ramp - 0.5).abs()  # triangle: peaks at center
        alpha = alpha.reshape(1, 1, -1, 1)
        result[:, :, y0:y1, :] = (1 - alpha) * canvas_tensor[:, :, y0:y1, :] + alpha * blurred

    # ── Vertical seams (columns at multiples of tile_size) ─────────
    for x in range(tile_size, w, tile_size):
        x0 = max(x - blend_width, 0)
        x1 = min(x + blend_width, w)
        if x1 - x0 < 3:
            continue
        strip = result[:, :, :, x0:x1]                 # use result (already h-blended)

        k = kernel_1d[:x1 - x0].clone()
        k = k / k.sum()
        k_h = k.reshape(1, 1, 1, -1)
        blurred = torch.cat([
            F.conv2d(
                strip[:, ch:ch+1, :, :],
                k_h,
                padding=(0, k_h.shape[3] // 2)
            )
            for ch in range(c)
        ], dim=1)
        blurred = blurred[:, :, :, :x1 - x0]

        ramp = torch.linspace(0, 1, x1 - x0)
        alpha = 1.0 - 2.0 * (ramp - 0.5).abs()
        alpha = alpha.reshape(1, 1, 1, -1)
        result[:, :, :, x0:x1] = (1 - alpha) * result[:, :, :, x0:x1] + alpha * blurred

    return result


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


def load_model():
    global MODEL
    print(f"Loading FractalCompression model: {MODEL_PATH}", flush=True)
    print(f"Device: {DEVICE}", flush=True)

    ckpt = torch.load(MODEL_PATH, map_location='cpu', weights_only=False)
    if isinstance(ckpt, dict):
        sd = ckpt.get('model_state_dict', ckpt.get('state_dict', ckpt))
        print(f"  Epoch {ckpt.get('epoch','?')} | "f"PSNR {ckpt.get('val_psnr','?'):.2f} dB | "f"BPP {ckpt.get('val_bpp','?'):.4f}", flush=True)
    else:
        sd = ckpt

    N = next((v.shape[0] for k, v in sd.items() if 'g_a.0.conv1.weight' in k), 128)
    has_attention = any('conv_a' in k for k in sd.keys())
    ModelClass    = Cheng2020Attention if has_attention else Cheng2020Anchor
    print(f"  {'FractalCompression-Attention' if has_attention else 'FractalCompression-Anchor'}  N={N}", flush=True)

    m = ModelClass(N=N)
    m.load_state_dict(sd, strict=False)
    m.eval().to(DEVICE)
    m.update()
    # ── CPU Optimization: Standard PyTorch is usually faster on HF ──
    # ── Dynamic INT8 Quantization: Reduces memory bandwidth wall ──
    try:
        print("  Applying Dynamic INT8 Quantization for cache efficiency...", flush=True)
        MODEL = torch.quantization.quantize_dynamic(
            m, {torch.nn.Linear}, dtype=torch.qint8
        )
    except Exception as e:
        print(f"  [Warning] Quantization skipped: {e}", flush=True)
        MODEL = m
        
    print("  Model ready (Architect optimized).", flush=True)

    # ── Warmup pass: pre-allocate memory + JIT compile PyTorch kernels ──
    print("  Running warmup inference...", flush=True)
    try:
        _extracted_from_load_model_37(MODEL)
    except Exception as e:
        print(f"  [Warning] Warmup failed (non-fatal): {e}\n", flush=True)


# TODO Rename this here and in `load_model`
def _extracted_from_load_model_37(MODEL):
    dummy = torch.rand(1, 3, 64, 64, device=DEVICE)
    with torch.inference_mode():
        MODEL.compress(dummy)
    del dummy
    torch.cuda.empty_cache() if torch.cuda.is_available() else None
    gc.collect()
    print("  Warmup complete. Server starting...\n", flush=True)

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

@app.get("/")
@app.head("/")
async def root_ping(request: Request):
    print(f"[Monitor] Root ping from {request.client.host if request.client else 'unknown'}", flush=True)
    return JSONResponse({
        "status": "online", 
        "version": "1.1.1",
        "message": "DeepFract Root Active"
    })

@app.middleware("http")
async def intercept_root(request: Request, call_next):
    if request.url.path == "/":
        return JSONResponse({
            "status": "online",
            "version": "1.1.1",
            "source": "middleware"
        })
    return await call_next(request)

@app.exception_handler(404)
async def custom_404_handler(request: Request, exc):
    print(f"[404 DEBUG] {request.method} {request.url.path} | Query: {request.query_params}", flush=True)
    # If they are hitting root with query params, just give them a 200 anyway
    if request.url.path in ["/", ""]:
        return JSONResponse({"status": "online", "source": "404-fallback"})
    return JSONResponse(status_code=404, content={"detail": "Not Found", "path": request.url.path})

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
    return JSONResponse({
        "status": "ok", 
        "version": "1.1.1",
        "model": os.path.basename(MODEL_PATH), 
        "device": str(DEVICE),
        "engine": COMPRESSAI_MODE
    })


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
    
    # ── Adaptive Caching Intercept (Process-Safe File Cache) ──
    img_hash = hashlib.md5(data).hexdigest()
    cache_dir = os.path.join(os.path.dirname(__file__), '.cache_compress')
    os.makedirs(cache_dir, exist_ok=True)
    cache_path = os.path.join(cache_dir, f"{img_hash}.fic")
    cache_meta = os.path.join(cache_dir, f"{img_hash}.json")
    
    if os.path.exists(cache_path) and os.path.exists(cache_meta):
        print(f"  [File Cache Hit] Serving cached .fic for {image.filename}", flush=True)
        try:
            with open(cache_path, 'rb') as f:
                cached_bytes = f.read()
            import json
            with open(cache_meta, 'r') as f:
                cached_headers = json.load(f)
            return Response(
                content=cached_bytes,
                media_type="application/octet-stream",
                headers=cached_headers
            )
        except Exception as e:
            print(f"  [Warning] Cache read failed: {e}. Recalculating...", flush=True)
        
    try:
        img = Image.open(io.BytesIO(data)).convert('RGB')
    except Exception as e:
        # Try cv2 as fallback if cv2 is installed (highly robust on Windows for various formats/decoders)
        if HAS_CV2:
            try:
                nparr = np.frombuffer(data, np.uint8)
                cv_img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
                if cv_img is not None:
                    cv_img_rgb = cv2.cvtColor(cv_img, cv2.COLOR_BGR2RGB)
                    img = Image.fromarray(cv_img_rgb)
                    print("[Info] Successfully opened image using OpenCV fallback.", flush=True)
                else:
                    raise Exception("OpenCV failed to decode image")
            except Exception as cv_err:
                raise HTTPException(400, f"Cannot open image: {e} (OpenCV fallback also failed: {cv_err})")
        else:
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

    # ── Whole-Image Compression (FIC3: no tiles = no seam artifacts) ─
    t0 = time.time()
    
    x = preprocess_image(torch.from_numpy(np.array(img)).unsqueeze(0))
    h, w = x.shape[2], x.shape[3]
    
    # Ensure multiples of 64 AND at least 128x128
    # (Satisfies both 16x main and 4x hyper-prior stages + 5x5 context kernel)
    target_h = max(128, ((h + 63) // 64) * 64)
    target_w = max(128, ((w + 63) // 64) * 64)
    p_h = target_h - h
    p_w = target_w - w
    
    # Pad right and bottom
    x_pad = F.pad(x, (0, p_w, 0, p_h), mode='constant', value=0).to(DEVICE)
    
    # ── Heavy inference offloaded to thread pool ──────────────────
    def _compress():
        gc.disable()
        try:
            with torch.inference_mode():
                comp = MODEL.compress(x_pad)
                dec  = MODEL.decompress(comp['strings'], comp['shape'])
                # Calculate PSNR/RMSE on unpadded region
                x_hat_crop = dec['x_hat'][:, :, :h, :w]
                x_crop     = x_pad[:, :, :h, :w]
                mse_val    = F.mse_loss(x_crop, x_hat_crop).item()
                return comp, mse_val
        finally:
            gc.enable()

    out, mse = await asyncio.to_thread(_compress)
    elapsed = time.time() - t0
    
    rmse = math.sqrt(mse) if mse > 0 else 0.0
    psnr = 10 * math.log10(1.0 / mse) if mse > 0 else 100.0
    
    sy    = out['strings'][0][0]
    sz    = out['strings'][1][0]
    shape = out['shape']

    # ── FIC3 Bitstream (whole-image, with metrics) ────────────────
    buf = io.BytesIO()
    buf.write(b'FIC3')                                       # magic v3
    buf.write(struct.pack('<ff', psnr, rmse))                # metrics
    buf.write(struct.pack('<HH', source_w, source_h))        # original dims
    buf.write(struct.pack('<HH', enc_w,    enc_h))           # encoded dims
    buf.write(struct.pack('<HH', x_pad.shape[3], x_pad.shape[2]))  # padded dims
    buf.write(struct.pack('<HH', shape[0], shape[1]))        # latent dims
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
        f"{len(fic_bytes)/1024:.1f} KB  {ratio:.1f}:1  {elapsed:.2f}s", flush=True)

    response_headers = {
        "Content-Disposition": f'attachment; filename="{stem}.fic"',
        "X-Ratio":         f"{ratio:.1f}",
        "X-PSNR":          f"{psnr:.2f}",
        "X-RMSE":          f"{rmse:.2f}",
        "X-Time":          f"{elapsed:.2f}",
        "X-Width":         str(source_w),
        "X-Height":        str(source_h),
        "X-Encoded-Width": str(enc_w),
        "X-Encoded-Height":str(enc_h),
    }
    
    # Save to Cache
    try:
        os.makedirs(cache_dir, exist_ok=True)
        with open(cache_path, 'wb') as f:
            f.write(fic_bytes)
        import json
        with open(cache_meta, 'w') as f:
            json.dump(response_headers, f)
    except Exception as e:
        print(f"  [Warning] Cache write failed: {e}", flush=True)

    return Response(
        content=fic_bytes,
        media_type="application/octet-stream",
        headers=response_headers
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

    # ── Adaptive Caching Intercept (Process-Safe File Cache) ──
    fic_hash = hashlib.md5(data).hexdigest()
    cache_dir = os.path.join(os.path.dirname(__file__), '.cache_decompress')
    os.makedirs(cache_dir, exist_ok=True)
    cache_path = os.path.join(cache_dir, f"{fic_hash}.png")
    cache_meta = os.path.join(cache_dir, f"{fic_hash}.json")

    if os.path.exists(cache_path) and os.path.exists(cache_meta):
        print(f"  [File Cache Hit] Serving cached PNG for {fic.filename}", flush=True)
        try:
            with open(cache_path, 'rb') as f:
                cached_bytes = f.read()
            import json
            with open(cache_meta, 'r') as f:
                cached_headers = json.load(f)
            return Response(
                content=cached_bytes,
                media_type="image/png",
                headers=cached_headers
            )
        except Exception as e:
            print(f"  [Warning] Cache read failed: {e}. Recalculating...", flush=True)

    print(f"  Read {len(data)} bytes.", flush=True)

    magic = data[:4]
    if magic not in (b'FIC1', b'FIC2', b'FIC3', b'FIC4'):
        print(f"  [Error] Invalid magic: {magic}", flush=True)
        raise HTTPException(400, "Not a valid .fic file")

    # ── Header Parsing ──────────────────────────────────────────
    is_v4 = (magic == b'FIC4')
    is_v3 = (magic == b'FIC3')
    is_v2 = (magic == b'FIC2')
    
    buf = io.BytesIO(data)
    buf.read(4) # skip magic
    
    psnr_val, rmse_val = 0.0, 0.0
    if is_v4 or is_v3:
        psnr_val, rmse_val = struct.unpack('<ff', buf.read(8))
    
    source_w, source_h = 0, 0
    enc_w, enc_h = 0, 0
    if is_v4 or is_v3 or is_v2:
        source_w, source_h = struct.unpack('<HH', buf.read(4))
        enc_w, enc_h = struct.unpack('<HH', buf.read(4))
    else:
        # v1 legacy
        enc_w, enc_h = struct.unpack('<HH', buf.read(4))
        source_w, source_h = enc_w, enc_h

    print(f"  Format: {magic.decode()} | Source Dims: {source_w}x{source_h}", flush=True)

    t0 = time.time()
    if is_v4:
        tiles_y, tiles_x = struct.unpack('<HH', buf.read(4))
        print(f"  [Architect] Tiled Reconstruction: {tiles_y}x{tiles_x} grid", flush=True)
        
        full_canvas = np.zeros((enc_h, enc_w, 3), dtype=np.float32)
        TILE_SIZE = 512 
        
        for ty in range(tiles_y):
            for tx in range(tiles_x):
                th, tw = struct.unpack('<HH', buf.read(4))
                lh, lw = struct.unpack('<HH', buf.read(4))
                ly, lz = struct.unpack('<II', buf.read(8))
                tsy = buf.read(ly)
                tsz = buf.read(lz)
                
                def _dec_tile():
                    with torch.inference_mode():
                        out = MODEL.decompress([[tsy], [tsz]], [lh, lw])
                        return out['x_hat']
                
                tile_x_hat = await asyncio.to_thread(_dec_tile)
                tile_np = tile_x_hat[0, :, :th, :tw].permute(1, 2, 0).float().cpu().numpy()
                
                y_s, x_s = ty * TILE_SIZE, tx * TILE_SIZE
                full_canvas[y_s:y_s+th, x_s:x_s+tw, :] = tile_np
        
        x_hat = torch.from_numpy(full_canvas).permute(2, 0, 1).unsqueeze(0).to(DEVICE)
        
        # ── Seam Blending: smooth visible tile boundary artifacts ──
        if tiles_y > 1 or tiles_x > 1:
            print("  [Architect] Blending tile seams...", flush=True)
            x_hat = blend_tile_seams(x_hat, TILE_SIZE, blend_width=16)
        x_hat = torch.clamp(x_hat, 0, 1)
    else:
        # Legacy FIC1/2/3
        pad_w, pad_h = struct.unpack('<HH', buf.read(4))
        lat_h, lat_w = struct.unpack('<HH', buf.read(4))
        len_y = struct.unpack('<I', buf.read(4))[0]
        len_z = struct.unpack('<I', buf.read(4))[0]
        sy = buf.read(len_y)
        sz = buf.read(len_z)
        
        def _dec_task():
            with torch.inference_mode():
                return MODEL.decompress([[sy], [sz]], [lat_h, lat_w])
        
        out = await asyncio.to_thread(_dec_task)
        x_hat = out['x_hat'][:, :, :enc_h, :enc_w]
        x_hat = torch.clamp(x_hat, 0, 1)

    elapsed = time.time() - t0
    print(f"  Neural decompress finished in {elapsed:.2f}s", flush=True)
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
            print("  [AI SR Complete] Tiled reconstruction finished.", flush=True)
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

    response_headers = {
        "Content-Disposition": f'attachment; filename="{stem}.png"',
        "X-Time": f"{elapsed:.2f}",
        "X-PSNR": f"{psnr_val:.2f}",
        "X-RMSE": f"{rmse_val:.2f}",
        "X-Width":  str(source_w),
        "X-Height": str(source_h),
    }

    # Save to Cache
    try:
        os.makedirs(cache_dir, exist_ok=True)
        with open(cache_path, 'wb') as f:
            f.write(png_bytes)
        import json
        with open(cache_meta, 'w') as f:
            json.dump(response_headers, f)
    except Exception as e:
        print(f"  [Warning] Cache write failed: {e}", flush=True)

    return Response(
        content=png_bytes,
        media_type="image/png",
        headers=response_headers
    )


# ── JIT Compiled Hot-Paths (C++ Speed for Pre-processing) ─────
@torch.jit.script
def preprocess_image(x: torch.Tensor):
    # This runs at near-native C++ speed
    x = x.float().div(255.0)
    return x.permute(0, 3, 1, 2).contiguous()


# ── Entry point ────────────────────────────────────────────────
if __name__ == "__main__":
    # init_upsampler()  # SR disabled — using neural decoder only
    
    # Clear stale caches (old FIC4 tiled results have seam artifacts)
    import shutil
    for _cache_name in ('.cache_compress', '.cache_decompress'):
        _cache_dir = os.path.join(os.path.dirname(__file__), _cache_name)
        if os.path.isdir(_cache_dir):
            shutil.rmtree(_cache_dir, ignore_errors=True)
            print(f"  Cleared stale {_cache_name} cache.", flush=True)
    
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
