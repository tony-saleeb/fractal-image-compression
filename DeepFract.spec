# -*- mode: python ; coding: utf-8 -*-


a = Analysis(
    ['deepfract_desktop.py'],
    pathex=[],
    binaries=[],
    datas=[('frontend/assets/images/logo.png', 'assets')],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='DeepFract',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    version='C:\\Users\\TONY\\AppData\\Local\\Temp\\1cc56c7c-0b2b-44d8-bc04-0f6ae58076fa',
    icon=['frontend\\assets\\images\\logo.png'],
)
