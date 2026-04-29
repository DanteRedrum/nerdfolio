#Requires -Version 5.0

<#
.SYNOPSIS
    Silently installs an MSI or EXE on one or more remote computers.

.DESCRIPTION
    Copies an installer from a source path to the remote computer's
    C:\Temp directory, then executes it silently via Invoke-Command.
    Cleans up the installer after completion.

.PARAMETER ComputerName
    One or more target computer names.

.PARAMETER InstallerSource
    UNC path to the installer file.

.PARAMETER InstallerArgs
    Arguments to pass to the installer. Defaults to "/quiet /norestart".

.PARAMETER KeepInstaller
    Switch to skip cleanup of installer after running.

.EXAMPLE
    .\Install-SoftwareRemote.ps1 -ComputerName PC1 -InstallerSource "\\server\share\app.msi"
    .\Install-SoftwareRemote.ps1 -ComputerName PC1,PC2 -InstallerSource "\\server\share\app.exe" -InstallerArgs "/S"

.NOTES
    Author: Daniel Avila
    Refactored for Nerdfolio — Phase 4
    Original: ChromeSilent.ps1
    Changes: Removed hardcoded paths and computer names, added cleanup,
             generalized for any MSI or EXE installer
#>

param(
    [Parameter(Mandatory=$true)]
    [string[]]$ComputerName,

    [Parameter(Mandatory=$true)]
    [string]$InstallerSource,

    [string]$InstallerArgs = "/quiet /norestart",

    [switch]$KeepInstaller
)

$InstallerName = Split-Path $InstallerSource -Leaf

foreach ($pc in $ComputerName) {
    Write-Host "$pc — Starting deployment" -ForegroundColor Cyan

    try {
        # Create temp directory if needed
        $RemoteTempPath = "\\$pc\C$\Temp"
        if (-not (Test-Path $RemoteTempPath)) {
            New-Item -Path $RemoteTempPath -ItemType Directory -Force | Out-Null
        }

        # Copy installer
        Write-Host "$pc — Copying $InstallerName" -ForegroundColor Yellow
        Copy-Item -Path $InstallerSource -Destination "$RemoteTempPath\$InstallerName" -Force

        # Run installer
        Write-Host "$pc — Running installer" -ForegroundColor Yellow
        Invoke-Command -ComputerName $pc -ScriptBlock {
            param($Name, $Args)
            & cmd.exe /c "C:\Temp\$Name $Args"
        } -ArgumentList $InstallerName, $InstallerArgs

        # Cleanup
        if (-not $KeepInstaller) {
            Remove-Item "$RemoteTempPath\$InstallerName" -Force -ErrorAction SilentlyContinue
            Write-Host "$pc — Installer removed" -ForegroundColor Gray
        }

        Write-Host "$pc — Deployment complete" -ForegroundColor Green
    }
    catch {
        Write-Warning "$pc — Deployment failed: $_"
    }
}
