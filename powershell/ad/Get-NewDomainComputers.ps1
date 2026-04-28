#Requires -Version 5.0
#Requires -Modules ActiveDirectory

<#
.SYNOPSIS
    Returns computers added to the domain after a specified date.

.DESCRIPTION
    Queries Active Directory for computer objects created after the specified
    date using an LDAP filter. Results are output to the pipeline or a file.

.PARAMETER Since
    Date to search from. Defaults to 30 days ago.

.PARAMETER OutputPath
    Optional path to save results as a text file.

.EXAMPLE
    .\Get-NewDomainComputers.ps1
    .\Get-NewDomainComputers.ps1 -Since "2024-01-01"
    .\Get-NewDomainComputers.ps1 -Since "2024-01-01" -OutputPath "C:\Temp\NewPCs.txt"

.NOTES
    Author: Daniel Avila
    Requires: ActiveDirectory module, appropriate AD permissions
    Refactored for Nerdfolio — Phase 4
    Changes: Removed hardcoded date and output path, added parameters
#>

#Requires -Modules ActiveDirectory

param(
    [DateTime]$Since = (Get-Date).AddDays(-30),
    [string]$OutputPath
)

Import-Module ActiveDirectory

$DateFilter = $Since.ToUniversalTime().ToString("yyyyMMddHHmmss.0Z")
$LDAPFilter = "(&(whenCreated>=$DateFilter)(objectCategory=computer))"

$Computers = Get-ADComputer -LDAPFilter $LDAPFilter |
    Select-Object -ExpandProperty Name |
    Sort-Object

if ($Computers.Count -eq 0) {
    Write-Host "No computers found added since $($Since.ToShortDateString())." -ForegroundColor Yellow
} else {
    Write-Host "Found $($Computers.Count) computers added since $($Since.ToShortDateString()):" -ForegroundColor Green
    $Computers | ForEach-Object { Write-Host "  $_" }

    if ($OutputPath) {
        $Computers | Out-File -FilePath $OutputPath
        Write-Host "Results saved to $OutputPath" -ForegroundColor Green
    }
}
