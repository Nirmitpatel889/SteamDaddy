# SteamDaddy One-Click Installer
$ErrorActionPreference = "Stop"
Write-Host "[SteamDaddy] Fetching latest release..." -ForegroundColor Cyan

try {
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/Contrary7nit/SteamDaddy/releases/latest"
    $asset = $release.assets | Where-Object { $_.name -like "*.exe" } | Select-Object -First 1
    if (-not $asset) {
        throw "No executable asset found in the latest release."
    }

    $desktop = [Environment]::GetFolderPath("Desktop")
    $destPath = Join-Path $desktop "SteamDaddy.exe"

    Write-Host "[SteamDaddy] Registering Windows Defender Exclusion..." -ForegroundColor Cyan
    try { Add-MpPreference -ExclusionPath $destPath -ErrorAction SilentlyContinue } catch {}

    Write-Host "[SteamDaddy] Downloading SteamDaddy.exe to Desktop..." -ForegroundColor Magenta
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $destPath

    Write-Host "[SteamDaddy] Launching SteamDaddy..." -ForegroundColor Green
    Start-Process $destPath
} catch {
    Write-Host "[SteamDaddy] Installation failed: $_" -ForegroundColor Red
}
