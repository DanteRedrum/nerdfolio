#Requires -Version 5.0

<#
.SYNOPSIS
    Enables WinRM on remote computers via PSExec and deploys a patch.

.DESCRIPTION
    Uses PSExec to bootstrap WinRM and PSRemoting on a remote computer,
    then copies and installs a patch file. Checks if patch is already
    installed before running.

    This pattern is useful for computers that don't have WinRM enabled
    and can't be reached via Invoke-Command directly.

.PARAMETER ComputerName
    One or more target computer names.

.PARAMETER PatchSource
    UNC path to the patch file (.msu or .exe).

.PARAMETER KBNumber
    KB number to check for before installing. Example: "KB4532938"

.PARAMETER PSExecPath
    Path to PSExec.exe. Defaults to "C:\Tools\PSTools\psexec.exe"

.PARAMETER CompletedLog
    Optional path to log completed computers.

.EXAMPLE
    .\Invoke-RemotePatch.ps1 `
        -ComputerName PC1,PC2 `
        -PatchSource "\\server\share\patch.msu" `
        -KBNumber "KB4532938"

.NOTES
    Author: Daniel Avila
    Refactored for Nerdfolio — Phase 4
    Original: Patch_KB4532938.ps1
    Changes: Removed hardcoded KB, computer names, and paths.
             Generalized as reusable patch deployment template.
             PSExec path parameterized.
    Requires: PSExec in path or specified via -PSExecPath
#>

param(
    [Parameter(Mandatory=$true)]
    [string[]]$ComputerName,

    [Parameter(Mandatory=$true)]
    [string]$PatchSource,

    [Parameter(Mandatory=$true)]
    [string]$KBNumber,

    [string]$PSExecPath = "C:\Tools\PSTools\psexec.exe",

    [string]$CompletedLog
)

$Cred = Get-Credential
$PatchName = Split-Path $PatchSource -Leaf

foreach ($PC in $ComputerName) {
    Write-Host "$PC — Starting" -ForegroundColor Cyan

    try {
        # Enable WinRM via PSExec
        Write-Host "$PC — Enabling WinRM" -ForegroundColor Yellow
        Start-Process -FilePath $PSExecPath `
            -ArgumentList "\\$PC -s C:\windows\system32\winrm.cmd quickconfig -q" `
            -Credential $Cred -Wait
        Start-Sleep -Seconds 10

        # Enable PSRemoting
        Write-Host "$PC — Enabling PSRemoting" -ForegroundColor Yellow
        Start-Process -FilePath $PSExecPath `
            -ArgumentList "\\$PC -h -d powershell.exe enable-psremoting -force" `
            -Credential $Cred -Wait
        Start-Sleep -Seconds 10

        # Set execution policy
        Write-Host "$PC — Setting execution policy" -ForegroundColor Yellow
        Start-Process -FilePath $PSExecPath `
            -ArgumentList "\\$PC -h -d powershell.exe set-executionpolicy RemoteSigned -force" `
            -Credential $Cred -Wait
        Start-Sleep -Seconds 20

        # Copy patch
        Write-Host "$PC — Copying $PatchName" -ForegroundColor Yellow
        Copy-Item -Path $PatchSource -Destination "\\$PC\C$\Temp\$PatchName" -Force

        # Check if already installed
        $Hotfix = Get-HotFix -Id $KBNumber -ComputerName $PC -ErrorAction SilentlyContinue

        if ($null -eq $Hotfix) {
            Write-Host "$PC — Installing $KBNumber" -ForegroundColor Yellow
            Invoke-Command -ComputerName $PC -Credential $Cred -ScriptBlock {
                param($Name)
                & cmd.exe /c "C:\Temp\$Name /quiet /forcerestart"
            } -ArgumentList $PatchName
            Write-Host "$PC — Patch deployed" -ForegroundColor Green
        } else {
            Write-Host "$PC — $KBNumber already installed" -ForegroundColor Green
            if ($CompletedLog) {
                Add-Content -Path $CompletedLog -Value "$KBNumber already installed on $PC"
            }
        }
    }
    catch {
        Write-Warning "$PC — Failed: $_"
    }
}
