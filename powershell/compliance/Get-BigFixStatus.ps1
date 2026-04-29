#Requires -Version 5.0

<#
.SYNOPSIS
    Checks BigFix client service status across multiple computers.

.DESCRIPTION
    Reads a list of computer names from a file or accepts pipeline input,
    then checks if the BESClient service is running on each. Reports
    green for running, red for stopped or unreachable.

.PARAMETER ComputerList
    Path to a text file containing computer names, one per line.

.PARAMETER ComputerName
    One or more computer names to check directly.

.EXAMPLE
    .\Get-BigFixStatus.ps1 -ComputerList "C:\Temp\computers.txt"
    .\Get-BigFixStatus.ps1 -ComputerName PC1,PC2,PC3

.NOTES
    Author: Daniel Avila
    Refactored for Nerdfolio — Phase 4
    Changes: Removed hardcoded UNC path, added parameter support,
             added error handling for unreachable computers
#>

param(
    [string]$ComputerList,
    [string[]]$ComputerName
)

if ($ComputerList) {
    $Computers = Get-Content -Path $ComputerList
} elseif ($ComputerName) {
    $Computers = $ComputerName
} else {
    Write-Warning "Provide either -ComputerList or -ComputerName"
    return
}

foreach ($pc in $Computers) {
    try {
        $Status = Get-Service -ComputerName $pc -Name BESClient -ErrorAction Stop |
            Select-Object -ExpandProperty Status

        if ($Status -eq 'Running') {
            Write-Host "$pc — BESClient Running" -ForegroundColor Green
        } else {
            Write-Host "$pc — BESClient $Status" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "$pc — Unreachable or service not found" -ForegroundColor Red
    }
}
