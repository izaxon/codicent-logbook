# install.ps1 — Install logbook-server (Codicent Logbook MCP runtime) on Windows
#
# Usage (run in PowerShell):
#   iwr https://logbook.codicent.ai/install.ps1 | iex
#
# Installs the self-contained logbook-server.exe from the latest GitHub Release.
# No .NET SDK required.

$ErrorActionPreference = 'Stop'

$Repo     = "izaxon/codicent-logbook"
$Tool     = "logbook-server"
$Asset    = "$Tool-win-x64.exe"
$DownloadUrl = "https://github.com/$Repo/releases/latest/download/$Asset"
$InstallDir  = "$env:USERPROFILE\.$Tool"
$Dest        = "$InstallDir\$Tool.exe"
$MinBytes    = 5MB   # real binaries are ~50MB; catch HTML/404 error pages

# ── Download ──────────────────────────────────────────────────────────────────
Write-Host "Downloading $Asset from GitHub Releases..."
Write-Host "  $DownloadUrl"
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $Dest -UseBasicParsing
} catch {
    Write-Host ""
    Write-Host "ERROR: download failed." -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)"
    Write-Host ""
    Write-Host "Check that a public release exists:"
    Write-Host "  https://github.com/$Repo/releases/latest"
    Write-Host "Docs: https://logbook.codicent.ai/"
    exit 1
}

$info = Get-Item $Dest
if ($info.Length -lt $MinBytes) {
    $preview = Get-Content $Dest -Raw -ErrorAction SilentlyContinue
    Remove-Item $Dest -Force -ErrorAction SilentlyContinue
    Write-Host ""
    Write-Host "ERROR: downloaded file is only $($info.Length) bytes (expected ~50 MB binary)." -ForegroundColor Red
    Write-Host "  The release asset is missing or the URL returned an error page."
    Write-Host "  URL: $DownloadUrl"
    if ($preview) { Write-Host "  Body preview: $($preview.Substring(0, [Math]::Min(120, $preview.Length)))" }
    Write-Host "  Releases: https://github.com/$Repo/releases"
    exit 1
}

# ── Add to user PATH ──────────────────────────────────────────────────────────
$UserPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable('PATH', "$UserPath;$InstallDir", 'User')
    $env:PATH = "$env:PATH;$InstallDir"
    Write-Host "Added $InstallDir to user PATH (takes effect in new terminals)."
}

Write-Host ""
Write-Host "Installed: $Dest ($([math]::Round($info.Length/1MB,1)) MB)"
Write-Host ""
Write-Host "Run: logbook-server"
Write-Host "     logbook-server --stdio     # stdio MCP mode (for Claude Desktop)"
Write-Host "     logbook-server --tunnel    # start Cloudflare Quick Tunnel"
Write-Host ""
Write-Host "See https://logbook.codicent.ai/ for documentation."
