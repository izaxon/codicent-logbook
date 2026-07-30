# install.ps1 — Install logbook-server (Codicent Logbook MCP runtime) on Windows
#
# Usage (run in PowerShell):
#   iwr https://izaxon.github.io/codicent-logbook/install.ps1 | iex
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

# ── Download ──────────────────────────────────────────────────────────────────
Write-Host "Downloading $Asset from GitHub Releases..."
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $DownloadUrl -OutFile $Dest -UseBasicParsing

# ── Add to user PATH ──────────────────────────────────────────────────────────
$UserPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
if ($UserPath -notlike "*$InstallDir*") {
    [Environment]::SetEnvironmentVariable('PATH', "$UserPath;$InstallDir", 'User')
    $env:PATH = "$env:PATH;$InstallDir"
    Write-Host "Added $InstallDir to user PATH (takes effect in new terminals)."
}

Write-Host ""
Write-Host "Installed: $Dest"
Write-Host ""
Write-Host "Run: logbook-server"
Write-Host "     logbook-server --stdio     # stdio MCP mode (for Claude Desktop)"
Write-Host "     logbook-server --tunnel    # start Cloudflare Quick Tunnel"
Write-Host ""
Write-Host "See https://izaxon.github.io/codicent-logbook/ for documentation."
