#Requires -Version 5.0

<#
.SYNOPSIS
    Enables WinRM and PSRemoting on remote computers via PSExec.

.DESCRIPTION
    Uses PSExec to bootstrap WinRM quickconfig, PSRemoting, and
    execution policy on computers that cannot be reached via
    Invoke-Command directly. Useful for onboarding new machines
    or recovering remote management access.

.PARAMETER ComputerName
    One or more computer names to enable WinRM on.

.PARAMETER PSExecPath
    Path to PSExec.exe. Defaults to "C:\Tools\PSTools\psexec.exe"

.PARAMETER TestAfter
    Switch to test WinRM connectivity after enabling.

.EXAMPLE
    .\Enable-WinRM.ps1 -ComputerName TARGETPC
    .\Enable-WinRM.ps1 -ComputerName PC1,PC2,PC3 -TestAfter

.NOTES
    Author: Daniel Avila
    Refactored for Nerdfolio — Phase 4
    Original: EnableWINRM.ps1
    Changes: PSExec path parameterized, added TestAfter switch,
             added error handling, removed hardcoded paths
    Requires: PSExec — https://docs.microsoft.com/sysinternals
#>

param(
    [Parameter(Mandatory=$true)]
    [string[]]$ComputerName,

    [string]$PSExecPath = "C:\Tools\PSTools\psexec.exe",

    [switch]$TestAfter
)

$Cred = Get-Credential

foreach ($comp in $ComputerName) {
    Write-Host "$comp — Starting WinRM enablement" -ForegroundColor Cyan

    try {
        # WinRM quickconfig
        Write-Host "$comp — Running WinRM quickconfig" -ForegroundColor Yellow
        Start-Process -FilePath $PSExecPath `
            -ArgumentList "\\$comp -s C:\windows\system32\winrm.cmd quickconfig -q" `
            -Credential $Cred -Wait
        Start-Sleep -Seconds 10

        # Enable PSRemoting
        Write-Host "$comp — Enabling PSRemoting" -ForegroundColor Yellow
        Start-Process -FilePath $PSExecPath `
            -ArgumentList "\\$comp -h -d powershell.exe enable-psremoting -force" `
            -Credential $Cred -Wait
        Start-Sleep -Seconds 10

        # Set execution policy
        Write-Host "$comp — Setting execution policy" -ForegroundColor Yellow
        Start-Process -FilePath $PSExecPath `
            -ArgumentList "\\$comp -h -d powershell.exe set-executionpolicy RemoteSigned -force" `
            -Credential $Cred -Wait
        Start-Sleep -Seconds 20

        Write-Host "$comp — WinRM enabled" -ForegroundColor Green

        if ($TestAfter) {
            Write-Host "$comp — Testing WinRM connectivity" -ForegroundColor Yellow
            $TestResult = Test-WSMan -ComputerName $comp -ErrorAction SilentlyContinue
            if ($TestResult) {
                Write-Host "$comp — WinRM responding" -ForegroundColor Green
            } else {
                Write-Warning "$comp — WinRM not responding after enablement"
            }
        }
    }
    catch {
        Write-Warning "$comp — Failed: $_"
    }
}
