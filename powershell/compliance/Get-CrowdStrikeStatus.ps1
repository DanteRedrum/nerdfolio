#Requires -Version 5.0

<#
.SYNOPSIS
    Checks CrowdStrike installation status across domain computers.

.DESCRIPTION
    Queries a list of computers for CrowdStrike installation via WMI.
    Can query from AD or a computer list file.

.PARAMETER ComputerList
    Path to a text file containing computer names, one per line.

.PARAMETER ComputerName
    One or more computer names to check directly.

.PARAMETER ADFilter
    AD computer name filter. Example: "DESKTOP-*" or "LAPTOP-*"

.PARAMETER SearchBase
    AD SearchBase DN to query computers from.

.PARAMETER ExportMissing
    Optional path to export computers missing CrowdStrike.

.EXAMPLE
    .\Get-CrowdStrikeStatus.ps1 -ComputerList "C:\Temp\computers.txt"
    .\Get-CrowdStrikeStatus.ps1 -ADFilter "DESKTOP-*" -SearchBase "DC=domain,DC=com"
    .\Get-CrowdStrikeStatus.ps1 -ComputerList "C:\Temp\computers.txt" -ExportMissing "C:\Temp\NeedsCS.txt"

.NOTES
    Author: Daniel Avila
    Refactored for Nerdfolio — Phase 4
    Changes: Removed hardcoded AD filter and domain, added parameters,
             WMI migrated to CIM, added export option
#>

param(
    [string]$ComputerList,
    [string[]]$ComputerName,
    [string]$ADFilter,
    [string]$SearchBase,
    [string]$ExportMissing
)

# Build computer list from source
if ($ComputerList) {
    $Computers = Get-Content -Path $ComputerList
} elseif ($ComputerName) {
    $Computers = $ComputerName
} elseif ($ADFilter -and $SearchBase) {
    Import-Module ActiveDirectory
    $Computers = Get-ADComputer -Filter "Name -like '$ADFilter'" `
        -Properties CN `
        -SearchBase $SearchBase `
        -SearchScope 2 |
        Select-Object -ExpandProperty CN
} else {
    Write-Warning "Provide -ComputerList, -ComputerName, or -ADFilter with -SearchBase"
    return
}

$Missing = @()

foreach ($pc in $Computers) {
    try {
        $CrowdStrike = Get-CimInstance -ComputerName $pc `
            -ClassName Win32_Product `
            -Filter "Vendor='CrowdStrike, Inc.'" `
            -ErrorAction Stop

        if ($null -eq $CrowdStrike) {
            Write-Host "$pc — CrowdStrike NOT installed" -ForegroundColor Red
            $Missing += $pc
        } else {
            Write-Host "$pc — CrowdStrike installed ($($CrowdStrike.Version))" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "$pc — Unreachable" -ForegroundColor Yellow
    }
}

if ($ExportMissing -and $Missing.Count -gt 0) {
    $Missing | Out-File -FilePath $ExportMissing
    Write-Host "Exported $($Missing.Count) computers missing CrowdStrike to $ExportMissing" -ForegroundColor Cyan
}
