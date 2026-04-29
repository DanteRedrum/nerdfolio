#Requires -Version 5.0

<#
.SYNOPSIS
    Copies and installs software locally with architecture detection.

.DESCRIPTION
    Detects OS architecture, copies the appropriate installer from a
    network share, and runs it silently. Checks if destination directory
    exists before copying.

.PARAMETER SourcePath32
    UNC path to the 32-bit installer.

.PARAMETER SourcePath64
    UNC path to the 64-bit installer.

.PARAMETER LocalPath
    Local destination directory. Defaults to C:\Temp.

.PARAMETER InstallerArgs
    Arguments to pass to the installer. Defaults to "/S".

.EXAMPLE
    .\Install-SoftwareLocal.ps1 `
        -SourcePath32 "\\server\share\app_x86.exe" `
        -SourcePath64 "\\server\share\app_x64.exe"

.NOTES
    Author: Daniel Avila
    Refactored for Nerdfolio — Phase 4
    Original: Notepad__SilentInstaller.ps1
    Bug fixed: Original used assignment (=) instead of comparison (-eq)
               in If conditions causing logic to never execute correctly.
    Changes: Removed hardcoded paths and version numbers, added parameters,
             fixed comparison operators, WMI migrated to CIM
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$SourcePath32,

    [Parameter(Mandatory=$true)]
    [string]$SourcePath64,

    [string]$LocalPath = "C:\Temp",

    [string]$InstallerArgs = "/S"
)

# Detect architecture
$OSType = (Get-CimInstance Win32_OperatingSystem).OSArchitecture
Write-Host "Detected OS: $OSType" -ForegroundColor Cyan

# Ensure local directory exists
if (-not (Test-Path -Path $LocalPath)) {
    Write-Host "Creating $LocalPath" -ForegroundColor Yellow
    New-Item -Path $LocalPath -ItemType Directory -Force | Out-Null
}

# Select correct installer
if ($OSType -eq '64-bit') {
    $InstallerName = Split-Path $SourcePath64 -Leaf
    Write-Host "Copying 64-bit installer: $InstallerName" -ForegroundColor Yellow
    Copy-Item -Path $SourcePath64 -Destination "$LocalPath\$InstallerName" -Force
} else {
    $InstallerName = Split-Path $SourcePath32 -Leaf
    Write-Host "Copying 32-bit installer: $InstallerName" -ForegroundColor Yellow
    Copy-Item -Path $SourcePath32 -Destination "$LocalPath\$InstallerName" -Force
}

# Run installer
try {
    Write-Host "Running installer: $InstallerName" -ForegroundColor Yellow
    Start-Process -FilePath "$LocalPath\$InstallerName" `
        -ArgumentList $InstallerArgs `
        -Verb RunAs `
        -Wait
    Write-Host "Installation complete" -ForegroundColor Green
}
catch {
    Write-Warning "Installation failed: $_"
}
