#!/usr/bin/env python3
"""
DeepFract Compression Profiler
==============================
A tool to measure the execution time of fractal image compression and decompression,
isolating the network/upload/download overhead from core computations,
and showing exact ratios, PSNR, and RMSE.

Usage:
  python profile_compression.py --image <path_to_image> [--server <url>]
  python profile_compression.py --image <path_to_image> --local
"""

import os
import sys
import time
import argparse
import urllib.request
import urllib.error
import mimetypes
import uuid
import struct
import io
import contextlib

# Try to reconfigure stdout to UTF-8 to handle unicode symbols if they are output
if hasattr(sys.stdout, 'reconfigure'):
    with contextlib.suppress(Exception):
        sys.stdout.reconfigure(encoding='utf-8')

# ANSI Color Codes for Premium Console UI
CLR_HEADER = "\033[95m"
CLR_BLUE = "\033[94m"
CLR_CYAN = "\033[96m"
CLR_GREEN = "\033[92m"
CLR_YELLOW = "\033[93m"
CLR_RED = "\033[91m"
CLR_BOLD = "\033[1m"
CLR_RESET = "\033[0m"

def print_banner():
    banner = f"""
{CLR_HEADER}{CLR_BOLD}=====================================================================
         DEEPFRACT COMPRESSION & LATENCY PROFILER
====================================================================={CLR_RESET}"""
    print(banner)

def parse_args():
    parser = argparse.ArgumentParser(
        description="Profile image compression and decompression times, isolating server processing from network roundtrips.",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument(
        "-i", "--image", 
        required=True, 
        help="Path to the image to compress."
    )
    parser.add_argument(
        "-s", "--server", 
        default="http://localhost:8000", 
        help="URL of the running API server (default: http://localhost:8000)."
    )
    parser.add_argument(
        "-l", "--local", 
        action="store_true", 
        help="Run profiling locally offline using the PyTorch backend models."
    )
    return parser.parse_args()

def check_file(path):
    if not os.path.exists(path):
        print(f"{CLR_RED}Error: File not found at '{path}'{CLR_RESET}")
        sys.exit(1)
    return os.path.abspath(path)

def format_bytes(n):
    for unit in ['B', 'KB', 'MB', 'GB']:
        if n < 1024.0:
            return f"{n:.2f} {unit}"
        n /= 1024.0
    return f"{n:.2f} TB"

def compute_psnr_rmse(orig_img, recon_img):
    """Computes PSNR and RMSE between two PIL images."""
    try:
        import numpy as np
        import math
        from PIL import Image
        
        a = np.array(orig_img.convert("RGB"), dtype=np.float64)
        b = np.array(recon_img.convert("RGB"), dtype=np.float64)
        if a.shape != b.shape:
            try:
                resample_filter = Image.Resampling.LANCZOS
            except AttributeError:
                resample_filter = Image.LANCZOS
            b = np.array(recon_img.resize(orig_img.size, resample_filter).convert("RGB"), dtype=np.float64)
            
        mse = np.mean((a - b) ** 2)
        if mse == 0:
            return 99.0, 0.0
        rmse = math.sqrt(mse)
        psnr = 20 * math.log10(255.0 / rmse)
        return psnr, rmse
    except Exception as e:
        print(f"{CLR_YELLOW}Warning: Could not calculate metrics locally: {e}{CLR_RESET}")
        return None, None

def profile_api_server(image_path, server_url):
    """
    Sends the image to the FastAPI server and profiles:
    1. Network Upload & Compression Roundtrip time (client side)
    2. Core Compression time (parsed from server response header 'X-Time')
    3. Network Download & Decompression Roundtrip time
    4. Core Decompression time (parsed from server response header 'X-Time')
    5. Ratios, quality evaluation, and overhead calculations
    """
    # ─── PART 1: COMPRESSION ───
    url_comp = f"{server_url.rstrip('/')}/compress"
    print(f"{CLR_CYAN}Mode: API Server Profiling{CLR_RESET}")
    print(f"Target Server: {CLR_BOLD}{server_url}{CLR_RESET}")
    
    orig_file_size = os.path.getsize(image_path)
    print(f"Image File:    {os.path.basename(image_path)} ({format_bytes(orig_file_size)})")
    print("\n[1/3] Uploading and compressing on server...")

    boundary = uuid.uuid4().hex
    filename = os.path.basename(image_path)
    mime_type = mimetypes.guess_type(image_path)[0] or 'application/octet-stream'

    try:
        with open(image_path, 'rb') as f:
            file_content = f.read()
    except Exception as e:
        print(f"{CLR_RED}Failed to read image file: {e}{CLR_RESET}")
        sys.exit(1)

    # Construct the multipart/form-data body for compression
    body_comp = (
        f"--{boundary}\r\n"
        f'Content-Disposition: form-data; name="image"; filename="{filename}"\r\n'
        f"Content-Type: {mime_type}\r\n\r\n"
    ).encode('utf-8') + file_content + f"\r\n--{boundary}--\r\n".encode('utf-8')

    req_comp = urllib.request.Request(
        url_comp,
        data=body_comp,
        headers={
            'Content-Type': f'multipart/form-data; boundary={boundary}',
            'Content-Length': str(len(body_comp))
        },
        method='POST'
    )

    t_comp_start = time.perf_counter()
    try:
        with urllib.request.urlopen(req_comp) as res_comp:
            fic_bytes = res_comp.read()
            t_comp_end = time.perf_counter()
            headers_comp = res_comp.info()
    except urllib.error.URLError as e:
        print(f"\n{CLR_RED}Connection failed: {e}{CLR_RESET}")
        print(f"Please make sure the API server is running on {server_url}.")
        sys.exit(1)

    comp_roundtrip = t_comp_end - t_comp_start
    
    # Retrieve server-side compression metrics
    server_comp_time_str = headers_comp.get('X-Time', '0.0')
    try:
        server_comp_time = float(server_comp_time_str)
    except ValueError:
        server_comp_time = 0.0

    bpp = headers_comp.get('X-BPP', 'N/A')
    source_w = headers_comp.get('X-Width', 'Unknown')
    source_h = headers_comp.get('X-Height', 'Unknown')
    enc_w = headers_comp.get('X-Encoded-Width', 'Unknown')
    enc_h = headers_comp.get('X-Encoded-Height', 'Unknown')

    comp_overhead = max(0.0, comp_roundtrip - server_comp_time)
    comp_overhead_pct = (comp_overhead / comp_roundtrip) * 100 if comp_roundtrip > 0 else 0.0

    compressed_size = len(fic_bytes)
    disk_ratio = orig_file_size / compressed_size if compressed_size > 0 else 0.0
    
    # ─── PART 2: DECOMPRESSION ───
    print("[2/3] Uploading .fic and decompressing on server...")
    url_dec = f"{server_url.rstrip('/')}/decompress"
    boundary_dec = uuid.uuid4().hex
    
    body_dec = (
        f"--{boundary_dec}\r\n"
        f'Content-Disposition: form-data; name="fic"; filename="image.fic"\r\n'
        f"Content-Type: application/octet-stream\r\n\r\n"
    ).encode('utf-8') + fic_bytes + f"\r\n--{boundary_dec}--\r\n".encode('utf-8')
    
    req_dec = urllib.request.Request(
        url_dec,
        data=body_dec,
        headers={
            'Content-Type': f'multipart/form-data; boundary={boundary_dec}',
            'Content-Length': str(len(body_dec))
        },
        method='POST'
    )
    
    t_dec_start = time.perf_counter()
    try:
        with urllib.request.urlopen(req_dec) as res_dec:
            decompressed_png_bytes = res_dec.read()
            t_dec_end = time.perf_counter()
            headers_dec = res_dec.info()
    except urllib.error.URLError as e:
        print(f"\n{CLR_RED}Decompression request failed: {e}{CLR_RESET}")
        sys.exit(1)
        
    dec_roundtrip = t_dec_end - t_dec_start
    
    # Retrieve server-side decompression metrics
    server_dec_time_str = headers_dec.get('X-Time', '0.0')
    try:
        server_dec_time = float(server_dec_time_str)
    except ValueError:
        server_dec_time = 0.0
        
    dec_overhead = max(0.0, dec_roundtrip - server_dec_time)
    dec_overhead_pct = (dec_overhead / dec_roundtrip) * 100 if dec_roundtrip > 0 else 0.0
    
    recon_size = len(decompressed_png_bytes)
    recon_w = headers_dec.get('X-Width', 'Unknown')
    recon_h = headers_dec.get('X-Height', 'Unknown')

    # ─── PART 3: QUALITY METRICS ───
    print("[3/3] Computing image fidelity metrics...")
    raw_ratio = 0.0
    psnr, rmse = None, None
    try:
        from PIL import Image
        orig_img = Image.open(image_path)
        raw_size = orig_img.size[0] * orig_img.size[1] * 3
        raw_ratio = raw_size / compressed_size if compressed_size > 0 else 0.0
        
        recon_img = Image.open(io.BytesIO(decompressed_png_bytes))
        psnr, rmse = compute_psnr_rmse(orig_img, recon_img)
    except Exception as e:
        print(f"Note: Skipping PSNR/RMSE computation: {e}")

    print(f"\n{CLR_GREEN}✓ API Server profiling completed successfully.{CLR_RESET}")
    print_results_table(
        mode="API Server",
        comp_time=server_comp_time,
        comp_overhead=comp_overhead,
        comp_roundtrip=comp_roundtrip,
        comp_overhead_pct=comp_overhead_pct,
        dec_time=server_dec_time,
        dec_overhead=dec_overhead,
        dec_roundtrip=dec_roundtrip,
        dec_overhead_pct=dec_overhead_pct,
        compressed_size=compressed_size,
        original_size=orig_file_size,
        recon_size=recon_size,
        raw_ratio=raw_ratio,
        disk_ratio=disk_ratio,
        bpp=bpp,
        resolution=f"{source_w}x{source_h} -> {enc_w}x{enc_h} (encoded)",
        recon_resolution=f"{recon_w}x{recon_h}",
        psnr=psnr,
        rmse=rmse
    )

def profile_local_engine(image_path):
    """
    Runs compression and decompression locally using the backend codebase
    and profiles both phases offline.
    """
    print(f"{CLR_CYAN}Mode: Local Engine Profiling (Server Equivalent){CLR_RESET}")
    orig_file_size = os.path.getsize(image_path)
    print(f"Image File: {os.path.basename(image_path)} ({format_bytes(orig_file_size)})")
    
    # Set up imports from backend folder
    backend_path = os.path.abspath('backend')
    sys.path.append(backend_path)
    
    print("\nLoading models and PyTorch libraries (this might take a few seconds)...")
    try:
        import importlib
        from PIL import Image
        import torch
        import numpy as np
        
        # Import models exactly like server.py
        try:
            models_mod = importlib.import_module("compressai.models")
            ops_mod    = importlib.import_module("compressai.ops")
            Cheng2020Attention = models_mod.Cheng2020Attention
            Cheng2020Anchor = models_mod.Cheng2020Anchor
        except ImportError:
            compressai_fallback = importlib.import_module("compressai_fallback")
            Cheng2020Attention = compressai_fallback.Cheng2020Attention
            Cheng2020Anchor = compressai_fallback.Cheng2020Anchor
    except ImportError as e:
        print(f"\n{CLR_RED}Failed to import local compression packages: {e}{CLR_RESET}")
        print("Please make sure you have activated your backend virtual environment.")
        sys.exit(1)

    # Check model path
    model_candidate_1 = os.path.join(backend_path, "models", "finetuned_fractalcompression_q2.pth")
    model_candidate_2 = os.path.join(backend_path, "models", "finetuned_cheng2020_q2.pth")
    model_path = model_candidate_1 if os.path.exists(model_candidate_1) else model_candidate_2

    print(f"Model path: {os.path.basename(model_path)}")
    
    # Load model weights
    try:
        ckpt = torch.load(model_path, map_location='cpu', weights_only=False)
        sd = ckpt.get('model_state_dict', ckpt.get('state_dict', ckpt))
        N = next((v.shape[0] for k, v in sd.items() if 'g_a.0.conv1.weight' in k), 128)
        has_attention = any('conv_a' in k for k in sd.keys())
        ModelClass = Cheng2020Attention if has_attention else Cheng2020Anchor
        
        print(f"Initializing Model Class: {ModelClass.__name__} (N={N})")
        model = ModelClass(N=N)
        model.load_state_dict(sd, strict=False)
        model.eval()
        model.update()
    except Exception as e:
        print(f"{CLR_RED}Failed to load model weights: {e}{CLR_RESET}")
        sys.exit(1)

    try:
        img = Image.open(image_path).convert("RGB")
    except Exception as e:
        print(f"{CLR_RED}Cannot read image: {e}{CLR_RESET}")
        sys.exit(1)

    w, h = img.size
    
    # Resize large images exactly like server.py
    MAX_DIM = 1024
    if max(w, h) > MAX_DIM:
        scale = MAX_DIM / max(w, h)
        enc_w = max(1, int(w * scale))
        enc_h = max(1, int(h * scale))
        try:
            resample_filter = Image.Resampling.LANCZOS
        except AttributeError:
            resample_filter = Image.LANCZOS
        img_resized = img.resize((enc_w, enc_h), resample_filter)
        print(f"  Resized {w}x{h} -> {enc_w}x{enc_h} (MAX_DIM={MAX_DIM})")
    else:
        enc_w, enc_h = w, h
        img_resized = img

    # ─── PART 1: LOCAL COMPRESSION ───
    print("\nRunning local compression profiling...")
    t_comp_start = time.perf_counter()
    
    x = torch.from_numpy(np.array(img_resized)).float().div_(255.0)
    x = x.permute(2, 0, 1).unsqueeze(0).contiguous()
    
    h_pad, w_pad = x.shape[2], x.shape[3]
    target_h = max(128, ((h_pad + 63) // 64) * 64)
    target_w = max(128, ((w_pad + 63) // 64) * 64)
    p_h = target_h - h_pad
    p_w = target_w - w_pad
    x_pad = torch.nn.functional.pad(x, (0, p_w, 0, p_h), mode='constant', value=0)
    
    with torch.inference_mode():
        out = model.compress(x_pad)
        
    t_comp_end = time.perf_counter()
    compression_time = t_comp_end - t_comp_start
    
    sy = out['strings'][0][0]
    sz = out['strings'][1][0]
    shape = out['shape']
    
    # Build standard .fic bytes (FIC2)
    buf = io.BytesIO()
    buf.write(b'FIC2')
    buf.write(struct.pack('<HH', w, h))
    buf.write(struct.pack('<HH', enc_w, enc_h))
    buf.write(struct.pack('<HH', x_pad.shape[3], x_pad.shape[2]))
    buf.write(struct.pack('<HH', shape[0], shape[1]))
    buf.write(struct.pack('<I', len(sy)))
    buf.write(struct.pack('<I', len(sz)))
    buf.write(sy)
    buf.write(sz)
    fic_bytes = buf.getvalue()
    
    compressed_size = len(fic_bytes)
    
    # Compute ratios
    raw_size = w * h * 3
    raw_ratio = raw_size / compressed_size if compressed_size > 0 else 0.0
    disk_ratio = orig_file_size / compressed_size if compressed_size > 0 else 0.0
    bpp_val = (len(sy) + len(sz)) * 8 / (enc_w * enc_h)

    # ─── PART 2: LOCAL DECOMPRESSION ───
    print("Running local decompression profiling...")
    t_dec_start = time.perf_counter()
    
    psnr, rmse = None, None
    recon_size = 0
    try:
        with torch.inference_mode():
            dec_out = model.decompress([[sy], [sz]], [shape[0], shape[1]])
        x_hat = dec_out['x_hat']
        x_hat = torch.nn.functional.pad(x_hat, [0, -(x_pad.shape[3] - enc_w), 0, -(x_pad.shape[2] - enc_h)])
        x_hat = torch.clamp(x_hat[:, :, :enc_h, :enc_w], 0, 1)
        img_np = (x_hat.squeeze(0).permute(1, 2, 0).cpu().numpy() * 255).astype(np.uint8)
        recon_img = Image.fromarray(img_np)
        
        if (w, h) != (enc_w, enc_h):
            try:
                resample_filter = Image.Resampling.LANCZOS
            except AttributeError:
                resample_filter = Image.LANCZOS
            recon_img = recon_img.resize((w, h), resample_filter)
            
        t_dec_end = time.perf_counter()
        decompression_time = t_dec_end - t_dec_start
        
        # Calculate PNG equivalent size
        png_buf = io.BytesIO()
        recon_img.save(png_buf, format='PNG')
        recon_size = len(png_buf.getvalue())
        
        psnr, rmse = compute_psnr_rmse(img, recon_img)
    except Exception as e:
        print(f"Could not decompress locally: {e}")
        decompression_time = 0.0

    print(f"\n{CLR_GREEN}✓ Local compression & decompression profiling complete.{CLR_RESET}")
    
    print_results_table(
        mode="Local Engine",
        comp_time=compression_time,
        comp_overhead=0.0,
        comp_roundtrip=compression_time,
        comp_overhead_pct=0.0,
        dec_time=decompression_time,
        dec_overhead=0.0,
        dec_roundtrip=decompression_time,
        dec_overhead_pct=0.0,
        compressed_size=compressed_size,
        original_size=orig_file_size,
        recon_size=recon_size,
        raw_ratio=raw_ratio,
        disk_ratio=disk_ratio,
        bpp=f"{bpp_val:.4f}",
        resolution=f"{w}x{h}",
        recon_resolution=f"{w}x{h}",
        psnr=psnr,
        rmse=rmse
    )

def print_results_table(mode, comp_time, comp_overhead, comp_roundtrip, comp_overhead_pct,
                        dec_time, dec_overhead, dec_roundtrip, dec_overhead_pct,
                        compressed_size, original_size, recon_size, raw_ratio, disk_ratio, bpp, resolution, recon_resolution,
                        psnr=None, rmse=None):
    width = 68
    
    def format_line(label, value, color_val="", is_bold=False):
        label_len = len(label)
        value_len = len(str(value))
        spaces = 64 - label_len - value_len
        space_padding = " " * max(1, spaces)
        bold_code = CLR_BOLD if is_bold else ""
        reset_code = CLR_RESET if is_bold else ""
        return f"| {bold_code}{label}{reset_code}{space_padding}{color_val}{value}{CLR_RESET} |"

    border_dashes = "-" * (width - 2)
    print(f"{CLR_BOLD}+{border_dashes}+")
    header_title = f"{CLR_BLUE}DEEPFRACT PROFILING METRICS BREAKDOWN ({mode}){CLR_RESET}".center(width - 2 + 9)
    print(f"| {header_title} |")
    print(f"| {border_dashes}|")
    
    # ─── COMPRESSION ───
    print(format_line("  [COMPRESSION] Core Time (Computation only):", f"{comp_time:.3f} s", CLR_GREEN, is_bold=True))
    if mode == "API Server":
        print(format_line("  [COMPRESSION] Network / Upload Overhead:", f"{comp_overhead:.3f} s", CLR_YELLOW))
        print(format_line("  [COMPRESSION] Total Request Latency:", f"{comp_roundtrip:.3f} s", CLR_BOLD))
        print(format_line("  [COMPRESSION] Overhead Percentage:", f"{comp_overhead_pct:.1f} %"))
    print(format_line("  Original File Size (Disk):", format_bytes(original_size)))
    print(format_line("  Compressed File Size (.fic):", format_bytes(compressed_size)))
    print(format_line("  Actual Size Ratio (vs. File on Disk):", f"{disk_ratio:.1f}:1", CLR_CYAN, is_bold=True))
    print(format_line("  Raw Pixel Ratio (vs. Uncompressed RGB):", f"{raw_ratio:.1f}:1"))
    print(format_line("  Bits Per Pixel (BPP):", f"{bpp}"))
    print(f"| {border_dashes}|")
    
    # ─── DECOMPRESSION ───
    print(format_line("  [DECOMPRESSION] Core Time (Computation only):", f"{dec_time:.3f} s", CLR_GREEN, is_bold=True))
    if mode == "API Server":
        print(format_line("  [DECOMPRESSION] Network / Download Overhead:", f"{dec_overhead:.3f} s", CLR_YELLOW))
        print(format_line("  [DECOMPRESSION] Total Request Latency:", f"{dec_roundtrip:.3f} s", CLR_BOLD))
        print(format_line("  [DECOMPRESSION] Overhead Percentage:", f"{dec_overhead_pct:.1f} %"))
    print(format_line("  Reconstructed File Size (PNG):", format_bytes(recon_size)))
    print(format_line("  Original Resolution Target:", resolution))
    print(format_line("  Reconstructed Resolution:", recon_resolution))
    print(f"| {border_dashes}|")
    
    # ─── FIDELITY/QUALITY ───
    psnr_str = f"{psnr:.2f} dB" if psnr is not None else "N/A"
    rmse_str = f"{rmse:.4f}" if rmse is not None else "N/A"
    print(format_line("  PSNR (Peak Signal-to-Noise Ratio):", psnr_str, CLR_GREEN, is_bold=True))
    print(format_line("  RMSE (Root Mean Square Error):", rmse_str, CLR_GREEN, is_bold=True))
    print(f"+{border_dashes}+{CLR_RESET}")

    print(f"\n{CLR_CYAN}{CLR_BOLD}💡 INSIGHT: {CLR_RESET}{CLR_BOLD}", end="")
    if mode == "API Server":
        total_time = comp_roundtrip + dec_roundtrip
        total_comp_time = comp_time + dec_time
        total_overhead = comp_overhead + dec_overhead
        total_overhead_pct = (total_overhead / total_time) * 100 if total_time > 0 else 0.0
        
        if total_overhead_pct > 60.0:
            print(f"Network is the main bottleneck. {total_overhead_pct:.1f}% of your time is spent transferring files.")
            print(f"   The model computation itself takes only {total_comp_time:.3f}s total (compress+decompress).{CLR_RESET}")
        else:
            print(f"Balanced execution: Model computation took {total_comp_time:.3f}s, and network transfer took {total_overhead:.3f}s.{CLR_RESET}")
    else:
        total_comp_time = comp_time + dec_time
        print(f"Total offline pipeline completed in {total_comp_time:.3f}s (compress: {comp_time:.3f}s | decompress: {dec_time:.3f}s).{CLR_RESET}")

def main():
    print_banner()
    args = parse_args()
    image_path = check_file(args.image)

    if args.local:
        profile_local_engine(image_path)
    else:
        profile_api_server(image_path, args.server)

if __name__ == "__main__":
    main()
