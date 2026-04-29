"""
Nuclear patch: directly overwrites problematic compressai __init__.py files
with clean minimal versions that remove all pointcloud/torch_geometric references.
"""
import os, sysconfig

site  = sysconfig.get_paths()['purelib']
ca    = os.path.join(site, 'compressai')

def overwrite(rel_path, new_content):
    path = os.path.join(ca, rel_path.replace('/', os.sep))
    if not os.path.exists(path):
        print(f"  SKIP (not found): {rel_path}")
        return
    open(path, 'w', encoding='utf-8').write(new_content)
    print(f"  Fixed: {rel_path}")

# ── datasets/__init__.py ──────────────────────────────────────
# Original imports image + rawvideo + pointcloud. Keep only image + rawvideo.
overwrite('datasets/__init__.py', '''\
# Patched: pointcloud/rawvideo removed (requires torch_geometric)
from compressai.datasets.image import ImageFolder
__all__ = ["ImageFolder"]
''')


# ── losses/__init__.py ────────────────────────────────────────
# Keep only image losses, remove pointcloud losses.
overwrite('losses/__init__.py', '''\
# Copyright 2020 InterDigital Communications, Inc.
# Patched: pointcloud losses removed (requires torch_geometric)
from compressai.losses.rate_distortion import RateDistortionLoss

__all__ = ["RateDistortionLoss"]
''')

# ── transforms/__init__.py ────────────────────────────────────
# Keep only image transforms, remove point transforms.
overwrite('transforms/__init__.py', '''\
# Copyright 2020 InterDigital Communications, Inc.
# Patched: point transforms removed (requires torch_geometric)
from compressai.transforms.functional import (
    rgb2ycbcr,
    ycbcr2rgb,
    yuv_444_to_420,
    yuv_420_to_444,
)

__all__ = [
    "rgb2ycbcr",
    "ycbcr2rgb",
    "yuv_444_to_420",
    "yuv_420_to_444",
]
''')

# ── transforms/point/__init__.py ─────────────────────────────
overwrite('transforms/point/__init__.py', '# Patched: requires torch_geometric\n')

# ── datasets/pointcloud/__init__.py ──────────────────────────
overwrite('datasets/pointcloud/__init__.py', '# Patched: requires torch_geometric\n')

# ── registry/transforms.py ───────────────────────────────────
# Comment out torch_geometric import + usage
reg = os.path.join(ca, 'registry', 'transforms.py')
if os.path.exists(reg):
    lines = open(reg, encoding='utf-8').readlines()
    fixed = []
    for line in lines:
        if 'torch_geometric' in line or ('torch_geometric' in ''.join(fixed[-3:]) and 'torch_geometric' in line):
            fixed.append('# [PATCHED] ' + line)
        elif '**{k: v for k, v in torch_geometric' in line:
            fixed.append('# [PATCHED] ' + line)
        else:
            fixed.append(line)
    open(reg, 'w', encoding='utf-8').writelines(fixed)
    print(f"  Fixed: registry/transforms.py")

# ── Clear .pyc ───────────────────────────────────────────────
removed = 0
for dp, _, files in os.walk(ca):
    for f in files:
        if f.endswith('.pyc'):
            try: os.remove(os.path.join(dp, f)); removed += 1
            except: pass
print(f"\n✓ Cleared {removed} .pyc files")
print("Now run:  py cheng2020_codec.py compress --image data/desert.jpg")
