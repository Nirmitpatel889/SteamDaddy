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

function Copy-FolderRecursive {
    param(
        [string]$SourceDir,
        [string]$TargetDir
    )
    if (-not (Test-Path -LiteralPath $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }
    Get-ChildItem -Path $SourceDir | ForEach-Object {
        $destPath = Join-Path $TargetDir $_.Name
        if ($_.PSIsContainer) {
            Copy-FolderRecursive -SourceDir $_.FullName -TargetDir $destPath
        } else {
            try {
                Copy-Item -Path $_.FullName -Destination $destPath -Force
            } catch {
                $oldItem = "$destPath.old"
                Remove-Item -Path $oldItem -Force -ErrorAction SilentlyContinue
                Rename-Item -Path $destPath -NewName "$($_.Name).old" -Force -ErrorAction SilentlyContinue
                Copy-Item -Path $_.FullName -Destination $destPath -Force
            }
        }
    }
}

try {
    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Red
    Write-Host "         STEAMDADDY · HARDCORE MILLENNIUM PATCH         " -ForegroundColor Red
    Write-Host "========================================================" -ForegroundColor Red
    Write-Host ""

    Write-Host "[1/5] Stripping Steam down and killing all running processes..." -ForegroundColor Yellow
    try {
        cmd.exe /c "taskkill /F /IM steam.exe /T >nul 2>&1"
        cmd.exe /c "taskkill /F /IM steamservice.exe >nul 2>&1"
        cmd.exe /c "taskkill /F /IM steamwebhelper.exe /T >nul 2>&1"
    } catch {}
    Get-Process -Name "steam", "steamservice", "steamwebhelper" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 1500
    Write-Host "      Steam is totally naked, wet, and unlocked for you, daddy." -ForegroundColor Green

    Write-Host "[2/5] Locating your Steam installation root..." -ForegroundColor Yellow
    $steam = Get-SteamRoot
    Write-Host "      Target Steam Folder: $steam" -ForegroundColor Green

    Write-Host "[3/5] Rebuilding wet and dirty Millennium core hooks..." -ForegroundColor Yellow
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
        throw "Millennium patch core assets could not be initialized."
    }

    Write-Host "[4/5] Sliding Millennium deep into Steam core..." -ForegroundColor Yellow
    
    & icacls "$steam" /grant "*S-1-5-32-545:(OI)(CI)M" /C /Q | Out-Null

    Copy-FolderRecursive -SourceDir $fixSource.FullName -TargetDir $steam

    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "[5/5] Relaunching Steam engine..." -ForegroundColor Yellow
    $steamExe = Join-Path $steam "steam.exe"
    if (Test-Path -LiteralPath $steamExe) {
        Start-Process -FilePath $steamExe
        Write-Host "      Steam restarted and throbbing for you, daddy." -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Magenta
    Write-Host "   🔥 DADDY MODE FULLY INJECTED - SO WET AND HARD 🔥    " -ForegroundColor Magenta
    Write-Host "========================================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  💦 Now open SteamDaddy and smash 'Install Plugin' again, daddy!" -ForegroundColor Red -BackgroundColor Black
    Write-Host "  💋 Make Steam submit to you... take everything you want." -ForegroundColor Yellow
    Write-Host ""

} catch {
    Write-Host ""
    Write-Host "[SteamDaddy] ERROR: $_" -ForegroundColor Red
}
