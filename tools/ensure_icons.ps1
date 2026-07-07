# Checks assets/icon/*.png exist, then regenerates the mobile app icon
# via flutter_launcher_icons so the APK always ships the current icon.
# Called automatically from sync_config.ps1 — can also be run standalone:
#   .\tools\ensure_icons.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot

$iconMain = Join-Path $Root "assets\icon\app_icon.png"
$iconForeground = Join-Path $Root "assets\icon\app_icon_foreground.png"

$missing = @()
if (-not (Test-Path $iconMain)) { $missing += "assets\icon\app_icon.png" }
if (-not (Test-Path $iconForeground)) { $missing += "assets\icon\app_icon_foreground.png" }

if ($missing.Count -gt 0) {
    Write-Host "Missing icon asset(s):" -ForegroundColor Red
    foreach ($m in $missing) { Write-Host "  $m" -ForegroundColor Red }
    Write-Host "Add them, then re-run sync_config.ps1" -ForegroundColor Yellow
    exit 1
}

Push-Location $Root
try {
    Write-Host "Generating app icon (flutter_launcher_icons)..." -ForegroundColor Cyan
    dart run flutter_launcher_icons
    if ($LASTEXITCODE -ne 0) {
        Write-Host "flutter_launcher_icons failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "App icon synced" -ForegroundColor Green
}
finally {
    Pop-Location
}

exit 0