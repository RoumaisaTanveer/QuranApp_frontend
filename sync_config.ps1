# Syncs app_config.properties -> dart_defines.*.json + web/index.html
# Run before plain "flutter run" without run_app.ps1:
#   .\sync_config.ps1
#   flutter run -d chrome --dart-define-from-file=dart_defines.web.json

$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot
$configPath = Join-Path $Root "app_config.properties"

if (-not (Test-Path $configPath)) {
    Write-Host "Missing app_config.properties" -ForegroundColor Red
    exit 1
}

$config = @{}
Get-Content $configPath -Encoding UTF8 | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith("#") -and $line -match "=") {
        $parts = $line -split "=", 2
        $config[$parts[0].Trim()] = $parts[1].Trim()
    }
}

$webClientId = $config["GOOGLE_WEB_CLIENT_ID"]
$apiAndroid = $config["API_BASE_URL"]
$apiWeb = $config["API_BASE_URL_WEB"]
if (-not $apiWeb) { $apiWeb = "http://localhost:8000" }
$webPort = $config["WEB_PORT"]
if (-not $webPort) { $webPort = "8080" }

# dart_defines for web (chrome)
$webDefines = @{
    GOOGLE_WEB_CLIENT_ID = $webClientId
    API_BASE_URL         = $apiWeb
}
$webJson = Join-Path $Root "dart_defines.web.json"
($webDefines | ConvertTo-Json) | Set-Content -Path $webJson -Encoding UTF8

# dart_defines for android emulator
$androidDefines = @{
    GOOGLE_WEB_CLIENT_ID = $webClientId
    API_BASE_URL         = $apiAndroid
}
$androidJson = Join-Path $Root "dart_defines.android.json"
($androidDefines | ConvertTo-Json) | Set-Content -Path $androidJson -Encoding UTF8

# Default dart_defines.json -> web (most common for flutter run -d chrome)
$defaultJson = Join-Path $Root "dart_defines.json"
Copy-Item -Path $webJson -Destination $defaultJson -Force

# Patch web/index.html google client meta (ASCII-safe file, no encoding corruption)
$indexPath = Join-Path $Root "web\index.html"
if (Test-Path $indexPath) {
    $html = [System.IO.File]::ReadAllText($indexPath)
    $html = $html -replace 'content="__GOOGLE_WEB_CLIENT_ID__"', "content=`"$webClientId`""
    $html = $html -replace 'content="[0-9]+-[^"]+\.apps\.googleusercontent\.com"', "content=`"$webClientId`""
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($indexPath, $html, $utf8)
}

Write-Host "Synced dart_defines.web.json (API: $apiWeb)" -ForegroundColor Green
Write-Host "Synced dart_defines.android.json (API: $apiAndroid)" -ForegroundColor Green
Write-Host "Synced dart_defines.json (web defaults)" -ForegroundColor Green
Write-Host "Patched web/index.html" -ForegroundColor Green
Write-Host ""
Write-Host "Chrome OAuth: add these to Google Cloud > Web client > Authorized JavaScript origins:" -ForegroundColor Cyan
Write-Host "  http://localhost:$webPort"
Write-Host "  http://127.0.0.1:$webPort"
