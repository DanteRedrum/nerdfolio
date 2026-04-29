#Requires -Version 5.0

<#
.SYNOPSIS
    Checks TPM chip status and version on remote computers.

.DESCRIPTION
    Queries the TPM WMI namespace on remote computers to determine
    if TPM is enabled and what version is installed. Also returns
    the computer model for hardware tracking.

.PARAMETER ComputerList
    Path to a text file containing computer names, one per line.

.PARAMETER ComputerName
    One or more computer names to check directly.

.EXAMPLE
    .\Get-TPMStatus.ps1 -ComputerList "C:\Temp\computers.txt"
    .\Get-TPMStatus.ps1 -ComputerName PC1,PC2,PC3

.NOTES
    Author: Daniel Avila
    Refactored for Nerdfolio — Phase 4
    Original script had undefined variable $TPMPC — fixed.
    Mixed WMI/CIM calls unified to CIM.
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
    Write-Host "$pc" -ForegroundColor Cyan
    try {
        $TPM = Get-CimInstance -ComputerName $pc `
            -Namespace root\CIMV2\Security\MicrosoftTpm `
            -ClassName Win32_Tpm `
            -ErrorAction Stop |
            Select-Object IsEnabled_InitialValue, SpecVersion

        $Model = Get-CimInstance -ComputerName $pc `
            -ClassName Win32_ComputerSystem `
            -ErrorAction Stop |
            Select-Object Name, Model

        [PSCustomObject]@{
            ComputerName = $pc
            Model        = $Model.Model
            TPMEnabled   = $TPM.IsEnabled_InitialValue
            TPMVersion   = $TPM.SpecVersion
        }
    }
    catch {
        Write-Warning "Failed to query $pc - $_"
    }
}
