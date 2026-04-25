# DeepFract Desktop Build Script (Server-Connected)
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '')]
param()

Write-Host ''
Write-Host '===================================='
Write-Host ' DeepFract Desktop - EXE Builder'
Write-Host '===================================='
Write-Host ''

Write-Host 'Installing dependencies...'
pip install pillow customtkinter pyinstaller

Write-Host 'Cleaning up old builds and ensuring app is closed...'
Stop-Process -Name "DeepFract" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
Remove-Item 'dist\DeepFract.exe' -Force -ErrorAction SilentlyContinue

Write-Host 'Building EXE...'

@'
python -m PyInstaller --clean --noconfirm --noconsole --onefile --name DeepFract --add-data "frontend\assets\images\logo.png;assets" --hidden-import customtkinter --collect-all customtkinter deepfract_desktop.py
'@ | Set-Content -Path 'build_temp.bat' -Encoding ASCII

cmd.exe /c build_temp.bat
Remove-Item 'build_temp.bat' -ErrorAction SilentlyContinue

Write-Host ''
if (Test-Path 'dist\DeepFract.exe') {
    Write-Host '===================================='
    Write-Host ' BUILD SUCCESSFUL!'
    Write-Host ' File: dist\DeepFract.exe'
    Write-Host '===================================='
} else {
    Write-Host '[ERROR] Build failed. Check output above.'
}
