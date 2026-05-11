import torch
import torch.nn as nn
import torch.nn.functional as F

class DoubleConv(nn.Module):
    def __init__(self, in_ch, out_ch):
        super().__init__()
        self.conv = nn.Sequential(
            nn.Conv2d(in_ch, out_ch, 3, padding=1),
            nn.BatchNorm2d(out_ch),
            nn.ReLU(inplace=True),
            nn.Conv2d(out_ch, out_ch, 3, padding=1),
            nn.BatchNorm2d(out_ch),
            nn.ReLU(inplace=True)
        )

    def forward(self, x):
        return self.conv(x)

class ResidualCorrector(nn.Module):
    """
    A lightweight UNet-based model to remove artifacts from fractal-compressed images.
    Matches the architecture expected by apply_residual_correction in utils.py.
    """
    def __init__(self, channels=32):
        super().__init__()
        self.enc1 = DoubleConv(3, channels)
        self.pool1 = nn.MaxPool2d(2)
        self.enc2 = DoubleConv(channels, channels * 2)
        self.pool2 = nn.MaxPool2d(2)
        self.enc3 = DoubleConv(channels * 2, channels * 4)
        
        self.up1 = nn.ConvTranspose2d(channels * 4, channels * 2, 2, stride=2)
        self.dec1 = DoubleConv(channels * 4, channels * 2)
        self.up2 = nn.ConvTranspose2d(channels * 2, channels, 2, stride=2)
        self.dec2 = DoubleConv(channels * 2, channels)
        
        self.out = nn.Conv2d(channels, 3, 1)

    def forward(self, x):
        # Encoder
        x1 = self.enc1(x)
        x2 = self.enc2(self.pool1(x1))
        x3 = self.enc3(self.pool2(x2))
        
        # Decoder with skip connections
        x = self.up1(x3)
        x = torch.cat([x, x2], dim=1)
        x = self.dec1(x)
        
        x = self.up2(x)
        x = torch.cat([x, x1], dim=1)
        x = self.dec2(x)
        
        # Residual output: model predicts the NOISE/ARTIFACTS
        return x + self.out(x)
