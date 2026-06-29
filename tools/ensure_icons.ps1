# Regenerates launcher icons when source assets are missing or stale.
# Called automatically from run_app.ps1; safe to run manually:
#   .\tools\ensure_icons.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path $PSScriptRoot -Parent

$iconScript = Join-Path $Root "tools\generate_app_icon.py"
$sourceIcon = Join-Path $Root "assets\icon\app_icon.png"
$sourceForeground = Join-Path $Root "assets\icon\app_icon_foreground.png"
$androidForeground = Join-Path $Root "android\app\src\main\res\drawable-xxxhdpi\ic_launcher_foreground.png"
$androidMipmap = Join-Path $Root "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png"
$webIcon = Join-Path $Root "web\icons\Icon-512.png"

function Needs-Regeneration {
    if (-not (Test-Path $sourceIcon) -or -not (Test-Path $sourceForeground)) {
        return $true
    }
    if (-not (Test-Path $androidForeground) -or -not (Test-Path $androidMipmap) -or -not (Test-Path $webIcon)) {
        return $true
    }

    $scriptTime = (Get-Item $iconScript).LastWriteTimeUtc
    $sourceTime = (Get-Item $sourceIcon).LastWriteTimeUtc
    $platformTime = @(
        (Get-Item $androidForeground).LastWriteTimeUtc
        (Get-Item $androidMipmap).LastWriteTimeUtc
        (Get-Item $webIcon).LastWriteTimeUtc
    ) | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum

    return ($scriptTime -gt $sourceTime) -or ($sourceTime -gt $platformTime)
}

if (Needs-Regeneration) {
    Write-Host "Regenerating app icons..." -ForegroundColor Cyan
    python $iconScript
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Icon generation failed (is Pillow installed? pip install pillow)" -ForegroundColor Red
        exit 1
    }
    Push-Location $Root
    try {
        dart run flutter_launcher_icons
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    } finally {
        Pop-Location
    }
    Write-Host "App icons updated." -ForegroundColor Green
}