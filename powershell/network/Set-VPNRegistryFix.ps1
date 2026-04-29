#Requires -Version 5.0

<#
.SYNOPSIS
    Sets the CredSSP AllowEncryptionOracle registry key for VPN compatibility.

.DESCRIPTION
    Fixes the CredSSP encryption oracle vulnerability workaround required
    for some VPN clients. Sets AllowEncryptionOracle to 1 (Mitigated) on
    remote computers. Only modifies the key if not already set correctly.

    Registry path:
    HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters

.PARAMETER ComputerName
    One or more computer names to apply the fix to.

.PARAMETER ComputerList
    Path to a text file containing computer names, one per line.

.EXAMPLE
    .\Set-VPNRegistryFix.ps1 -ComputerName PC1,PC2
    .\Set-VPNRegistryFix.ps1 -ComputerList "C:\Temp\vpnpcs.txt"

.NOTES
    Author: Daniel Avila
    Refactored for Nerdfolio — Phase 4
    Original: RegistryforVPN.ps1 and RegistryforVPNusingFile.ps1
    Changes: Merged two scripts into one with flexible input,
             removed hardcoded file path, added error handling
    Security note: AllowEncryptionOracle=1 is the Mitigated setting.
                   Value 2 = Vulnerable (not recommended).
                   Value 0 = Force Updated Clients (most secure).
#>

param(
    [string[]]$ComputerName,
    [string]$ComputerList
)

if ($ComputerList) {
    $Computers = Get-Content -Path $ComputerList
} elseif ($ComputerName) {
    $Computers = $ComputerName
} else {
    Write-Warning "Provide either -ComputerName or -ComputerList"
    return
}

$RegPath = "HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\CredSSP\Parameters"

foreach ($pc in $Computers) {
    Write-Host "$pc" -ForegroundColor Cyan
    try {
        Invoke-Command -ComputerName $pc -ScriptBlock {
            param($Path)
            $val = Get-ItemProperty -Path $Path -Name "AllowEncryptionOracle" -ErrorAction SilentlyContinue

            if ($null -eq $val -or $val.AllowEncryptionOracle -ne 1) {
                Set-ItemProperty -Path $Path -Name "AllowEncryptionOracle" -Value 1
                Write-Host "Registry key updated on $env:COMPUTERNAME" -ForegroundColor Green
            } else {
                Write-Host "Registry key already set correctly on $env:COMPUTERNAME" -ForegroundColor Green
            }
        } -ArgumentList $RegPath
    }
    catch {
        Write-Warning "Failed to update $pc - $_"
    }
}
