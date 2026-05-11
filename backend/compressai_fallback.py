import torch
import torch.nn as nn
import torch.nn.functional as F
import math
import io
import pickle

# ── GDN Implementation ──────────────────────────────────────────
class GDN(nn.Module):
    def __init__(self, in_channels, inverse=False, beta_min=1e-6, gamma_init=0.1):
        super().__init__()
        self.inverse = inverse
        self.beta_min = beta_min
        self.gamma_init = gamma_init
        
        self.beta = nn.Parameter(torch.ones(in_channels))
        self.gamma = nn.Parameter(torch.eye(in_channels) * gamma_init)
        
    def forward(self, x):
        _, c, _, _ = x.shape
        # Simple implementation of GDN (normalization)
        # Note: In real CompressAI this uses a more complex positivity constraint
        norm = F.conv2d(x**2, self.gamma.view(c, c, 1, 1), self.beta)
        return x * torch.sqrt(norm) if self.inverse else x / torch.sqrt(norm)

# ── Attention Block ──────────────────────────────────────────────
class AttentionBlock(nn.Module):
    def __init__(self, N):
        super().__init__()
        self.conv_a = nn.Sequential(
            nn.Conv2d(N, N, 3, padding=1),
            nn.ReLU(inplace=True),
            nn.Conv2d(N, N, 3, padding=1),
            nn.Sigmoid()
        )
        self.conv_b = nn.Sequential(
            nn.Conv2d(N, N, 3, padding=1),
            nn.ReLU(inplace=True),
            nn.Conv2d(N, N, 3, padding=1),
        )
        
    def forward(self, x):
        identity = x
        a = self.conv_a(x)
        b = self.conv_b(x)
        return a * b + identity

# ── Sub-pixel Convolution helpers ──────────────────────────────
def conv3x3(in_ch, out_ch, stride=1):
    return nn.Conv2d(in_ch, out_ch, kernel_size=3, stride=stride, padding=1)

def subpel_conv3x3(in_ch, out_ch, r=2):
    return nn.Sequential(
        nn.Conv2d(in_ch, out_ch * r**2, kernel_size=3, padding=1),
        nn.PixelShuffle(r)
    )

# ── Entropy Models (Fallbacks) ──────────────────────────────────
class EntropyModel(nn.Module):
    def __init__(self):
        super().__init__()
        self.registration_name = "entropy_model"
        
    def update(self, *args, **kwargs):
        return True
        
    def compress(self, x):
        x_q = torch.round(x)
        buf = io.BytesIO()
        torch.save(x_q.half(), buf)
        return [buf.getvalue()]

    def decompress(self, strings, shape):
        buf = io.BytesIO(strings[0])
        return torch.load(buf).float()

    def _load_from_state_dict(self, state_dict, prefix, *args, **kwargs):
        for k, v in state_dict.items():
            if k.startswith(prefix):
                name = k[len(prefix):]
                if '.' not in name and name not in self._buffers and name not in self._parameters and isinstance(v, torch.Tensor):
                    if name.startswith(('_matrix', '_bias', '_factor')):
                        self.register_parameter(name, nn.Parameter(torch.zeros_like(v)))
                    else:
                        self.register_buffer(name, torch.zeros_like(v))
        super()._load_from_state_dict(state_dict, prefix, *args, **kwargs)

class EntropyBottleneck(EntropyModel):
    def __init__(self, channels):
        super().__init__()
        self.channels = channels

class GaussianConditional(EntropyModel):
    def __init__(self):
        super().__init__()

# ── Cheng2020 Models ───────────────────────────────────────────
class Cheng2020Base(nn.Module):
    def __init__(self, N=128, **kwargs):
        super().__init__()
        self.entropy_bottleneck = EntropyBottleneck(N)
        self.gaussian_conditional = GaussianConditional()
        
    def update(self):
        return True

    def compress(self, x):
        y = self.g_a(x)
        z = self.h_a(y)
        z_strings = self.entropy_bottleneck.compress(z)
        z_hat = self.entropy_bottleneck.decompress(z_strings, z.shape[2:])
        params = self.h_s(z_hat)
        y_strings = self.gaussian_conditional.compress(y)
        return {"strings": [y_strings, z_strings], "shape": z.shape[2:]}

    def decompress(self, strings, shape):
        z_hat = self.entropy_bottleneck.decompress(strings[1], shape)
        params = self.h_s(z_hat)
        if hasattr(self, 'entropy_parameters'):
            params = self.entropy_parameters(params)
        y_hat = self.gaussian_conditional.decompress(strings[0], params)
        x_hat = self.g_s(y_hat)
        return {"x_hat": x_hat}

class Cheng2020Anchor(Cheng2020Base):
    def __init__(self, N=128, **kwargs):
        super().__init__(N=N, **kwargs)
        # Custom entropy_parameters MLP matching the checkpoint
        self.entropy_parameters = nn.Sequential(
            nn.Conv2d(512, 426, 1), nn.ReLU(inplace=True),
            nn.Conv2d(426, 341, 1), nn.ReLU(inplace=True),
            nn.Conv2d(341, 256, 1)
        )
        self.g_a = nn.Sequential(
            conv3x3(3, N, stride=2), GDN(N),
            conv3x3(N, N, stride=2), GDN(N),
            conv3x3(N, N, stride=2), GDN(N),
            conv3x3(N, N, stride=2)
        )
        self.g_s = nn.Sequential(
            subpel_conv3x3(N, N), GDN(N, inverse=True),
            subpel_conv3x3(N, N), GDN(N, inverse=True),
            subpel_conv3x3(N, N), GDN(N, inverse=True),
            subpel_conv3x3(N, 3)
        )
        self.h_a = nn.Sequential(
            conv3x3(N, N), nn.ReLU(inplace=True),
            conv3x3(N, N, stride=2), nn.ReLU(inplace=True),
            conv3x3(N, N, stride=2)
        )
        # Custom h_s matching the user's checkpoint (9 layers)
        self.h_s = nn.Sequential(
            conv3x3(N, N), nn.ReLU(inplace=True),
            subpel_conv3x3(N, N), nn.ReLU(inplace=True),
            conv3x3(N, 192), nn.ReLU(inplace=True),
            subpel_conv3x3(192, 192), nn.ReLU(inplace=True),
            conv3x3(192, 256)
        )

class Cheng2020Attention(Cheng2020Anchor):
    def __init__(self, N=128, **kwargs):
        super().__init__(N=N, **kwargs)
        self.g_a = nn.Sequential(
            conv3x3(3, N, stride=2), GDN(N),
            conv3x3(N, N, stride=2), GDN(N),
            AttentionBlock(N),
            conv3x3(N, N, stride=2), GDN(N),
            conv3x3(N, N, stride=2),
            AttentionBlock(N)
        )
        self.g_s = nn.Sequential(
            AttentionBlock(N),
            subpel_conv3x3(N, N), GDN(N, inverse=True),
            subpel_conv3x3(N, N), GDN(N, inverse=True),
            AttentionBlock(N),
            subpel_conv3x3(N, N), GDN(N, inverse=True),
            subpel_conv3x3(N, 3)
        )

def compute_padding(h, w, min_div=64):
    out_h = (h + min_div - 1) // min_div * min_div
    out_w = (w + min_div - 1) // min_div * min_div
    return 0, out_w - w, 0, out_h - h
