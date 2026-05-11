# DeepFract Flet Desktop Build Script
Write-Host "Installing Flet packaging dependencies..." -ForegroundColor Cyan
pip install flet pyinstaller

Write-Host "Building Single-File EXE..." -ForegroundColor Green
# We use the full path to flet.exe since it might not be in PATH
$flet_path = "$env:APPDATA\Python\Python314\Scripts\flet.exe"

if (Test-Path $flet_path) {
    & $flet_path pack deepfract_desktop.py --name DeepFract --icon frontend/assets/images/logo.png --add-data "frontend/assets/images/logo.png;assets"
} else {
    Write-Host "Flet executable not found at $flet_path. Trying global 'flet'..." -ForegroundColor Yellow
    flet pack deepfract_desktop.py --name DeepFract --icon frontend/assets/images/logo.png --add-data "frontend/assets/images/logo.png;assets"
}

Write-Host "`nDone! Your premium executable is in the 'dist' folder." -ForegroundColor Yellow
