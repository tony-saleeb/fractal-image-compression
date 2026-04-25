# ── FractalCompressor Build Script ──────────
# This script installs requirements and freezes the app into an .exe

Write-Host "Installing dependencies..." -ForegroundColor Cyan
pip install numpy pillow pyinstaller

Write-Host "Building Executable..." -ForegroundColor Green
pyinstaller --noconsole --onefile --name FractalCompressor classical_fractal_tool.py

Write-Host "`nDone! Your executable is in the 'dist' folder." -ForegroundColor Yellow
Write-Host "Path: $(Get-Location)\dist\FractalCompressor.exe" -ForegroundColor Yellow
