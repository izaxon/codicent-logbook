# install.ps1 — Install the logbook CLI on Windows (plain-file log for humans and AI agents)
#
# Usage (run in PowerShell):
#   iwr https://logbook.codicent.ai/cli/install.ps1 | iex
#   $env:LOGBOOK_VERSION = "0.8.0"; iwr https://logbook.codicent.ai/cli/install.ps1 | iex
#
# Installs the self-contained logbook.exe from the public GitHub Releases of
# izaxon/codicent-logbook. No .NET SDK required.
#
# The repo also hosts logbook-server releases, and "latest" points at the
# server — so this script looks up the newest logbook-v* tag instead.

$ErrorActionPreference = 'Stop'

$Repo        = "izaxon/codicent-logbook"
$Tool        = "logbook"
$Asset       = "$Tool-win-x64.exe"
$InstallDir  = "$env:USERPROFILE\.$Tool"
$Dest        = "$InstallDir\$Tool.exe"
$MinBytes    = 5MB   # real binaries are ~35MB; catch HTML/404 error pages

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ── Resolve release tag ───────────────────────────────────────────────────────
if ($env:LOGBOOK_VERSION) {
    $Tag = "logbook-v" + $env:LOGBOOK_VERSION.TrimStart('v')
} else {
    $releases = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/releases?per_page=100" -UseBasicParsing
    $Tag = ($releases | Where-Object { $_.tag_name -like 'logbook-v*' } | Select-Object -First 1).tag_name
    if (-not $Tag) {
        Write-Host "ERROR: no logbook-v* release found on https://github.com/$Repo/releases" -ForegroundColor Red
        Write-Host "Docs: https://logbook.codicent.ai/cli/"
        return
    }
}

$DownloadUrl = "https://github.com/$Repo/releases/download/$Tag/$Asset"

# ── Download ──────────────────────────────────────────────────────────────────
Write-Host "Downloading $Asset ($Tag) from GitHub Releases..."
Write-Host "  $DownloadUrl"
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
$Tmp = "$Dest.download"

try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $Tmp -UseBasicParsing
} catch {
    Remove-Item $Tmp -Force -ErrorAction SilentlyContinue
    Write-Host ""
    Write-Host "ERROR: download failed." -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)"
    Write-Host "  Check https://github.com/$Repo/releases/tag/$Tag"
    return
}

$info = Get-Item $Tmp
if ($info.Length -lt $MinBytes) {
    Remove-Item $Tmp -Force -ErrorAction SilentlyContinue
    Write-Host ""
    Write-Host "ERROR: downloaded file is only $($info.Length) bytes (expected ~35 MB binary)." -ForegroundColor Red
    Write-Host "  The release asset is missing or the URL returned an error page."
    Write-Host "  URL: $DownloadUrl"
    return
}
Move-Item -Force $Tmp $Dest

# ── Add to user PATH ──────────────────────────────────────────────────────────
$UserPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable('PATH', "$UserPath;$InstallDir", 'User')
    $env:PATH = "$env:PATH;$InstallDir"
    Write-Host "Added $InstallDir to user PATH (takes effect in new terminals)."
}

Write-Host ""
Write-Host "Installed: $Dest ($Tag, $([math]::Round($info.Length/1MB,1)) MB)"
Write-Host ""
Write-Host "Run: logbook init"
Write-Host "     logbook add `"my first entry #notes`""
Write-Host "     logbook list -t notes"
Write-Host ""
Write-Host "See https://logbook.codicent.ai/cli/ for documentation."
