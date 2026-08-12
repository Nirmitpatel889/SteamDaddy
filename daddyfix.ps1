# =====================================================================

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Get-SteamRoot {
    if ($env:Steam -and (Test-Path -LiteralPath $env:Steam)) {
        return (Resolve-Path -LiteralPath $env:Steam).Path
    }

    foreach ($path in @("HKCU:\Software\Valve\Steam", "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam", "HKLM:\SOFTWARE\Valve\Steam")) {
        try {
            $props = Get-ItemProperty -LiteralPath $path -ErrorAction Stop
            $installPath = $props.SteamPath
            if (-not $installPath) { $installPath = $props.InstallPath }
            if ($installPath -and (Test-Path -LiteralPath $installPath)) {
                return (Resolve-Path -LiteralPath $installPath).Path
            }
        } catch {}
    }

    $fallback = Join-Path ${env:ProgramFiles(x86)} "Steam"
    if ($fallback -and (Test-Path -LiteralPath $fallback)) {
        return (Resolve-Path -LiteralPath $fallback).Path
    }

    throw "Steam installation path could not be found."
}

try {
    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "         SteamDaddy - Millennium Fix Installer          " -ForegroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""

    # 1. Stop Steam processes first
    Write-Host "[1/4] Stopping Steam processes..." -ForegroundColor Yellow
    Get-Process -Name "steam", "steamservice", "steamwebhelper" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 1500
    Write-Host "      Steam processes stopped cleanly." -ForegroundColor Green

    # 2. Locate Steam directory
    Write-Host "[2/4] Finding Steam directory..." -ForegroundColor Yellow
    $steam = Get-SteamRoot
    Write-Host "      Target Steam Folder: $steam" -ForegroundColor Green

    # 3. Download & extract millennium-fix payload from GitHub
    Write-Host "[3/4] Downloading millennium-fix payload from GitHub..." -ForegroundColor Yellow
    $tempDir = Join-Path $env:TEMP ("sd_fix_" + (Get-Random))
    $zipPath = Join-Path $tempDir "repo.zip"
    $extractDir = Join-Path $tempDir "extracted"

    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    New-Item -ItemType Directory -Path $extractDir -Force | Out-Null

    $zipUrl = "https://github.com/Contrary7nit/SteamDaddy/archive/refs/heads/main.zip"
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

    Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force

    $fixSource = Get-ChildItem -Path $extractDir -Recurse -Directory -Filter "millennium-fix" | Select-Object -First 1
    if (-not $fixSource -or -not (Test-Path -LiteralPath $fixSource.FullName)) {
        throw "Could not find 'millennium-fix' directory in GitHub repository archive."
    }

    # 4. Copy & replace files into Steam directory
    Write-Host "[4/4] Deploying & replacing files in Steam directory..." -ForegroundColor Yellow
    
    # Grant permissions via icacls on target folder
    & icacls "$steam" /grant "*S-1-5-32-545:(OI)(CI)M" /C /Q | Out-Null

    Get-ChildItem -Path $fixSource.FullName | ForEach-Object {
        $destItem = Join-Path $steam $_.Name
        if ($_.PSIsContainer) {
            Write-Host "  [+] Replacing folder: $($_.Name)" -ForegroundColor Magenta
            Copy-Item -Path $_.FullName -Destination $destItem -Recurse -Force
        } else {
            Write-Host "  [+] Replacing file: $($_.Name)" -ForegroundColor Magenta
            Copy-Item -Path $_.FullName -Destination $destItem -Force
        }
    }

    # Cleanup temp dir
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Green
    Write-Host "    SUCCESS! Millennium Fix files deployed into Steam!  " -ForegroundColor Green
    Write-Host "========================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "👉 NOW GO TO STEAMDADDY AND HIT 'INSTALL PLUGIN' AGAIN!" -ForegroundColor Yellow -BackgroundColor Black
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "[SteamDaddy] ERROR: $_" -ForegroundColor Red
}
