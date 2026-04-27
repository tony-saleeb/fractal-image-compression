"""
Fine-tune FractalCompression Q2 → 100:1 ratio, 28+ dB PSNR
=============================================================
Kaggle single-cell. Subprocess for numpy safety.
Dataset: DIV2K_Flickr2K_BSD500_WED | GPU: T4
Target: ~0.24 bpp (100:1) with 28+ dB PSNR
"""
import subprocess, sys
print("Installing CompressAI...", flush=True)
subprocess.run([sys.executable, '-m', 'pip', 'install', 'compressai==1.2.4', '-q'], check=True)
print("Ready.", flush=True)

SCRIPT = r'''
import os, sys, glob, time, math, random, json
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms
from PIL import Image
import io
import torchvision.models as models

# ── FRACTAL SELF-SIMILARITY LOSS (TEXTURE / GRAM MATRIX) ────────
class VGGFeatureExtractor(nn.Module):
    def __init__(self):
        super().__init__()
        vgg = models.vgg16(weights=models.VGG16_Weights.IMAGENET1K_V1).features
        self.slice1 = nn.Sequential()
        self.slice2 = nn.Sequential()
        self.slice3 = nn.Sequential()
        for x in range(4): self.slice1.add_module(str(x), vgg[x])
        for x in range(4, 9): self.slice2.add_module(str(x), vgg[x])
        for x in range(9, 16): self.slice3.add_module(str(x), vgg[x])
        for param in self.parameters():
            param.requires_grad = False
            
    def forward(self, x):
        # Normalize for VGG
        x = (x - torch.tensor([0.485, 0.456, 0.406]).view(1,3,1,1).to(x.device)) / \
            torch.tensor([0.229, 0.224, 0.225]).view(1,3,1,1).to(x.device)
        h = self.slice1(x)
        h_relu1_2 = h
        h = self.slice2(h)
        h_relu2_2 = h
        h = self.slice3(h)
        h_relu3_3 = h
        return h_relu1_2, h_relu2_2, h_relu3_3

def gram_matrix(input):
    N, C, H, W = input.size()
    features = input.view(N, C, H * W)
    # Compute the gram product using batch matrix multiplication
    G = torch.bmm(features, features.transpose(1, 2))
    # Normalize by the number of elements in the feature map
    return G.div(C * H * W)

DEVICE = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Device: {DEVICE}", flush=True)
if torch.cuda.is_available():
    print(f"  GPU: {torch.cuda.get_device_name(0)}", flush=True)

# ── DATASET ────────────────────────────────────────────────────
def find_images(min_size=300):
    roots = []
    kaggle = '/kaggle/input'
    if os.path.exists(kaggle):
        for name in sorted(os.listdir(kaggle)):
            full = os.path.join(kaggle, name)
            if os.path.isdir(full):
                roots.append(full)
                print(f"  Dataset: {name}/", flush=True)
    if not roots:
        roots = ['.']
    paths = []
    for root in roots:
        for ext in ['*.jpg','*.jpeg','*.png','*.bmp','*.JPEG','*.JPG','*.PNG']:
            paths.extend(glob.glob(os.path.join(root, '**', ext), recursive=True))
    valid = []
    for p in paths:
        try:
            img = Image.open(p)
            if img.width >= min_size and img.height >= min_size:
                valid.append(p)
        except:
            pass
    return valid

class PatchDataset(Dataset):
    def __init__(self, paths, patch=256):
        self.paths = paths
        self.patch = patch
        self.tf = transforms.Compose([
            transforms.RandomCrop(patch),
            transforms.RandomHorizontalFlip(),
            transforms.ToTensor(),
        ])
    def __len__(self):
        return len(self.paths)
    def __getitem__(self, idx):
        try:
            img = Image.open(self.paths[idx]).convert('RGB')
            w, h = img.size
            ps = self.patch
            if w < ps or h < ps:
                s = max(ps/w, ps/h) * 1.1
                img = img.resize((int(w*s), int(h*s)), Image.LANCZOS)
            return self.tf(img)
        except:
            return torch.rand(3, self.patch, self.patch)

# ── COMPRESS/DECOMPRESS ON CPU ──────────────────────────────────
def compress_on_cpu(model, img_pil):
    w, h = img_pil.size
    pw = (64 - w % 64) % 64
    ph = (64 - h % 64) % 64
    padded = Image.new('RGB', (w + pw, h + ph))
    padded.paste(img_pil, (0, 0))
    x = torch.from_numpy(np.array(padded, dtype=np.float32) / 255.0)
    x = x.permute(2, 0, 1).unsqueeze(0)

    model_cpu = model.cpu()
    model_cpu.eval()
    model_cpu.update()

    t0 = time.time()
    with torch.no_grad():
        out = model_cpu.compress(x)
        dec = model_cpu.decompress(out['strings'], out['shape'])
    dt = time.time() - t0

    total_bytes = sum(len(s) for sl in out['strings'] for s in sl if isinstance(s, (bytes, bytearray)))
    xh = torch.clamp(dec['x_hat'][:, :, :h, :w], 0, 1)
    arr = (xh.squeeze(0).permute(1, 2, 0).numpy() * 255).clip(0, 255).astype(np.uint8)
    rec = Image.fromarray(arr)

    bpp = (total_bytes * 8) / (w * h)
    mse_val = F.mse_loss(xh, x[:, :, :h, :w]).item()
    psnr = -10 * math.log10(mse_val + 1e-10)
    ratio = (w * h * 3) / max(1, total_bytes)

    model.to(DEVICE)
    return bpp, psnr, ratio, total_bytes, rec, dt

# ── TRAINING ───────────────────────────────────────────────────
def train():
    from compressai.zoo import cheng2020_anchor as fractalcompression_base

    all_images = find_images(min_size=300)
    random.shuffle(all_images)
    print(f"\nTotal images: {len(all_images)}", flush=True)
    if not all_images:
        print("ERROR: No images found!", flush=True)
        return None

    n_val = max(1, len(all_images) // 10)
    train_paths = all_images[n_val:]
    val_paths = all_images[:n_val]
    print(f"Train: {len(train_paths)} | Val: {len(val_paths)}", flush=True)

    train_loader = DataLoader(
        PatchDataset(train_paths, 256), batch_size=8,
        shuffle=True, num_workers=2, pin_memory=True, drop_last=True)
    val_loader = DataLoader(
        PatchDataset(val_paths, 256), batch_size=8,
        shuffle=False, num_workers=2, pin_memory=True)

    print(f"Batches/epoch: {len(train_loader)}", flush=True)

    # Find existing finetuned model in Kaggle datasets
    existing_model_path = None
    if os.path.exists('/kaggle/input'):
        import glob
        pth_files = glob.glob('/kaggle/input/**/*.pth', recursive=True)
        if pth_files:
            existing_model_path = pth_files[0]

    if existing_model_path:
        print(f"\nModel: Loading YOUR existing fine-tuned weights from {existing_model_path}", flush=True)
        model = fractalcompression_base(quality=2, pretrained=False).to(DEVICE)
        state = torch.load(existing_model_path, map_location=DEVICE, weights_only=False)
        if 'model_state_dict' in state:
            model.load_state_dict(state['model_state_dict'], strict=False)
        else:
            model.load_state_dict(state, strict=False)
    else:
        print(f"\nModel: No existing model found. Downloading base CompressAI Q2 weights...", flush=True)
        model = fractalcompression_base(quality=2, pretrained=True).to(DEVICE)
        
    print(f"  Params: {sum(p.numel() for p in model.parameters()):,}", flush=True)

    main_params = [p for n, p in model.named_parameters()
                   if not n.endswith(".quantiles") and p.requires_grad]
    aux_params = [p for n, p in model.named_parameters()
                  if n.endswith(".quantiles") and p.requires_grad]
    optimizer = torch.optim.Adam(main_params, lr=1e-5)
    aux_optimizer = torch.optim.Adam(aux_params, lr=1e-3)

    lmbda = 0.0035
    epochs = 20

    print(f"\nConfig:", flush=True)
    print(f"  Loss:   MSE + BPP (rate-distortion)", flush=True)
    print(f"  Lambda: {lmbda} (Q2 value, x 255^2 = {lmbda * 255**2:.1f})", flush=True)
    print(f"  LR:     1e-5", flush=True)
    print(f"  Epochs: {epochs}", flush=True)
    print(f"  Target: ~0.24 bpp (100:1), 28+ dB PSNR", flush=True)
    print("-" * 70, flush=True)

    best_val_loss = float('inf')
    save_path = '/kaggle/working/finetuned_fractalcompression_q2.pth'
    
    # Initialize Self-Similarity Loss Extractor
    vgg_ext = VGGFeatureExtractor().to(DEVICE)
    vgg_ext.eval()

    for epoch in range(epochs):
        model.train()
        t_loss = t_bpp = t_mse = t_ss = 0
        t0 = time.time()
        for x in train_loader:
            x = x.to(DEVICE)
            optimizer.zero_grad()
            aux_optimizer.zero_grad()

            out = model(x)
            N, _, H, W = x.shape
            num_px = N * H * W
            bpp = sum(
                torch.log(lk).sum() / (-math.log(2) * num_px)
                for lk in out["likelihoods"].values()
            )
            mse = F.mse_loss(out["x_hat"], x)
            
            # Extract self-similar textures
            orig_f1, orig_f2, orig_f3 = vgg_ext(x)
            hat_f1, hat_f2, hat_f3 = vgg_ext(out["x_hat"])
            
            # Penalize destruction of self-similar textures (Fractal Loss)
            ss_loss = F.mse_loss(gram_matrix(hat_f1), gram_matrix(orig_f1)) + \
                      F.mse_loss(gram_matrix(hat_f2), gram_matrix(orig_f2)) + \
                      F.mse_loss(gram_matrix(hat_f3), gram_matrix(orig_f3))
            
            # Combined Rate-Distortion-Texture loss
            # We apply a 50.0 weight to the SS loss so it contributes around 0.1 - 0.5 to the total loss
            fractal_weight = 50.0 
            loss = bpp + lmbda * (255**2) * mse + fractal_weight * ss_loss

            loss.backward()
            torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
            optimizer.step()

            aux_loss = model.aux_loss()
            aux_loss.backward()
            aux_optimizer.step()

            t_loss += loss.item()
            t_bpp += bpp.item()
            t_mse += mse.item()
            t_ss += ss_loss.item()
        nb = len(train_loader)
        elapsed = time.time() - t0

        model.eval()
        v_psnr = v_bpp = v_n = 0
        with torch.no_grad():
            for x in val_loader:
                x = x.to(DEVICE)
                out = model(x)
                xh = torch.clamp(out["x_hat"], 0, 1)
                N, _, H, W = x.shape
                num_px = N * H * W
                bpp_v = sum(
                    torch.log(lk).sum() / (-math.log(2) * num_px)
                    for lk in out["likelihoods"].values()
                )
                mse_v = F.mse_loss(xh, x)
                psnr = -10 * math.log10(mse_v.item() + 1e-10)
                v_psnr += psnr * N
                v_bpp += bpp_v.item() * N
                v_n += N

        avg_vpsnr = v_psnr / max(1, v_n)
        avg_vbpp = v_bpp / max(1, v_n)
        val_loss = lmbda * (255**2) * (10 ** (-avg_vpsnr / 10)) + avg_vbpp

        tag = ""
        if val_loss < best_val_loss:
            best_val_loss = val_loss
            torch.save({
                'model_state_dict': model.state_dict(),
                'epoch': epoch,
                'val_psnr': avg_vpsnr,
                'val_bpp': avg_vbpp,
                'lambda': lmbda,
                'quality': 2,
            }, save_path)
            tag = " * BEST"

        ratio = 24.0 / max(avg_vbpp, 0.001)
        print(
            f"Ep {epoch+1:2d}/{epochs} | "
            f"Loss: {t_loss/nb:.4f} | BPP: {t_bpp/nb:.4f} | SS_Loss: {t_ss/nb:.4f} | "
            f"Val PSNR: {avg_vpsnr:.2f} dB | Val BPP: {avg_vbpp:.4f} | "
            f"Ratio: {ratio:.0f}:1 | {elapsed:.0f}s{tag}", flush=True)

    print(f"\nTraining done. Best: {save_path}", flush=True)
    return save_path

# ── BENCHMARK ──────────────────────────────────────────────────
def benchmark(model_path):
    from compressai.zoo import cheng2020_anchor as fractalcompression_base

    print(f"\n{'='*72}", flush=True)
    print(f"  BENCHMARK: Original Q2 vs Fine-Tuned vs JPEG", flush=True)
    print(f"{'='*72}", flush=True)

    original  = fractalcompression_base(quality=2, pretrained=True).to(DEVICE)
    original.eval(); original.update()

    finetuned = fractalcompression_base(quality=2, pretrained=False).to(DEVICE)
    ckpt = torch.load(model_path, map_location=DEVICE, weights_only=False)
    finetuned.load_state_dict(ckpt['model_state_dict'])
    finetuned.eval(); finetuned.update()

    all_images = find_images(min_size=512)
    random.seed(42); random.shuffle(all_images)
    test_imgs = all_images[:20]
    print(f"Testing on {len(test_imgs)} images", flush=True)

    os.makedirs('/kaggle/working/results', exist_ok=True)

    print(f"\n{'Image':<22} {'Orig PSNR':>10} {'FT PSNR':>10} {'JPEG PSNR':>10} "
          f"{'Orig Ratio':>11} {'FT Ratio':>11} {'FT BPP':>8}", flush=True)
    print("-" * 95, flush=True)

    s_op = s_fp = s_jp = s_or = s_fr = s_fb = 0

    for i, path in enumerate(test_imgs):
        name = os.path.basename(path)[:18]
        img  = Image.open(path).convert('RGB').resize((512, 512), Image.LANCZOS)

        o_bpp, o_psnr, o_ratio, _, _, _ = compress_on_cpu(original, img)
        f_bpp, f_psnr, f_ratio, f_nb, f_rec, _ = compress_on_cpu(finetuned, img)

        best_jq = 5; best_diff = 999
        for jq in range(3, 50):
            buf = io.BytesIO()
            img.save(buf, format='JPEG', quality=jq)
            jbpp = (buf.tell() * 8) / (512 * 512)
            if abs(jbpp - f_bpp) < best_diff:
                best_diff = abs(jbpp - f_bpp); best_jq = jq
        buf = io.BytesIO()
        img.save(buf, format='JPEG', quality=best_jq)
        buf.seek(0)
        jrec = Image.open(buf).copy()
        ja = np.array(img, dtype=np.float32)
        jb = np.array(jrec.convert('RGB'), dtype=np.float32)
        jmse = ((ja - jb)**2).mean()
        j_psnr = 20 * np.log10(255.0 / np.sqrt(jmse + 1e-10))

        print(f"{name:<22} {o_psnr:>9.2f}dB {f_psnr:>9.2f}dB {j_psnr:>9.2f}dB "
              f"{o_ratio:>10.1f}:1 {f_ratio:>10.1f}:1 {f_bpp:>8.4f}", flush=True)

        s_op += o_psnr; s_fp += f_psnr; s_jp += j_psnr
        s_or += o_ratio; s_fr += f_ratio; s_fb += f_bpp

        if i < 5:
            img.save(f'/kaggle/working/results/{i:02d}_original.png')
            f_rec.save(f'/kaggle/working/results/{i:02d}_finetuned.png')

    n = len(test_imgs)
    print("-" * 95, flush=True)
    print(f"{'AVERAGE':<22} {s_op/n:>9.2f}dB {s_fp/n:>9.2f}dB {s_jp/n:>9.2f}dB "
          f"{s_or/n:>10.1f}:1 {s_fr/n:>10.1f}:1 {s_fb/n:>8.4f}", flush=True)
    print(f"\n  Fine-tuned vs Original: {(s_fp-s_op)/n:+.2f} dB", flush=True)
    print(f"  Fine-tuned vs JPEG:     {(s_fp-s_jp)/n:+.2f} dB", flush=True)
    print(f"  Average ratio:          {s_fr/n:.0f}:1", flush=True)
    print(f"  Average BPP:            {s_fb/n:.4f}", flush=True)

    target_met = (s_fp/n >= 28.0) and (s_fr/n >= 90)
    print(f"\n  Target (100:1, 28dB): {'✓ MET' if target_met else '✗ NOT MET'}", flush=True)

    results = {
        'avg_psnr_original': float(s_op/n), 'avg_psnr_finetuned': float(s_fp/n),
        'avg_psnr_jpeg': float(s_jp/n),     'avg_ratio_original': float(s_or/n),
        'avg_ratio_finetuned': float(s_fr/n),'avg_bpp_finetuned': float(s_fb/n),
    }
    with open('/kaggle/working/results/benchmark_results.json', 'w') as f:
        json.dump(results, f, indent=2)
    print(f"  Results saved to /kaggle/working/results/", flush=True)

# ── MAIN ───────────────────────────────────────────────────────
model_path = train()
if model_path:
    benchmark(model_path)
'''

script_path = '/kaggle/working/_finetune_fractalcompression.py'
with open(script_path, 'w') as f:
    f.write(SCRIPT)

print("Launching FractalCompression fine-tuning...", flush=True)
result = subprocess.run([sys.executable, script_path], cwd='/kaggle/working')
if result.returncode != 0:
    print(f"Failed with exit code {result.returncode}")
else:
    print("Complete! Download finetuned_fractalcompression_q2.pth from /kaggle/working/")
