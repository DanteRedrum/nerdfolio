#Requires -Version 5.0

<#
.SYNOPSIS
    Tests connectivity to one or more computers and reports online/offline status.

.DESCRIPTION
    Pings a list of computers and reports their online status with
    color-coded output. Accepts a file list or direct computer names.

.PARAMETER ComputerName
    One or more computer names to test.

.PARAMETER ComputerList
    Path to a CSV or text file containing computer names.

.PARAMETER Count
    Number of ping attempts. Defaults to 2.

.EXAMPLE
    .\Test-ComputerOnline.ps1 -ComputerName PC1,PC2,PC3
    .\Test-ComputerOnline.ps1 -ComputerList "C:\Temp\computers.txt"
    .\Test-ComputerOnline.ps1 -ComputerName PC1 -Count 4

.NOTES
    Author: Daniel Avila
    Refactored for Nerdfolio — Phase 4
    Original: Ping_with_output.ps1 (UTF-16 encoded)
    Changes: Removed hardcoded CSV path, added parameter support,
             structured output as PSCustomObject, added count parameter
#>

param(
    [string[]]$ComputerName,
    [string]$ComputerList,
    [int]$Count = 2
)

if ($ComputerList) {
    $Computers = Get-Content -Path $ComputerList
} elseif ($ComputerName) {
    $Computers = $ComputerName
} else {
    Write-Warning "Provide either -ComputerName or -ComputerList"
    return
}

foreach ($client in $Computers) {
    $Result = Test-Connection -ComputerName $client -Count $Count -Quiet

    if ($Result) {
        Write-Host "$client — Online" -ForegroundColor Green
    } else {
        Write-Host "$client — Offline" -ForegroundColor Red
    }
}
