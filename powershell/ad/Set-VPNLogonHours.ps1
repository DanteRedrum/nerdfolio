#Requires -Version 5.0
#Requires -Modules ActiveDirectory

<#
.SYNOPSIS
    Adjusts Active Directory logon hours for VPN group members.

.DESCRIPTION
    Queries a specified AD group and compares each member's logon hours
    against the defined allowed hours. Reports members whose hours differ.
    AD changes are commented out by default — uncomment to apply.

.PARAMETER GroupName
    The AD group to process. Defaults to "Pulse Web Users".

.PARAMETER HoursPreset
    The logon hours preset to apply:
    AllDay    — Allow logon at all hours (default)
    DenyAll   — Deny all logon
    Business  — Allow 8am-6pm, 7 days a week

.EXAMPLE
    .\Set-VPNLogonHours.ps1
    .\Set-VPNLogonHours.ps1 -GroupName "VPN Users" -HoursPreset AllDay

.NOTES
    Author: Daniel Avila
    Requires: ActiveDirectory module, AD write permissions
    Refactored for Nerdfolio — Phase 4
    Changes: Removed hardcoded group name, added preset parameter,
             AD write operations remain commented out by default for safety.

    LOGON HOURS REFERENCE:
    AllDay   = @(255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255)
    DenyAll  = @(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    Business = @(0,255,3,0,255,3,0,255,3,0,255,3,0,255,3,0,255,3,0,255,3)
    (Business = 8am-6pm, 7 days a week)
#>

param(
    [string]$GroupName = "Pulse Web Users",

    [ValidateSet("AllDay","DenyAll","Business")]
    [string]$HoursPreset = "AllDay"
)

Import-Module ActiveDirectory

# Define hour presets
$HourPresets = @{
    AllDay   = [Byte[]](255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255)
    DenyAll  = [Byte[]](0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    Business = [Byte[]](0,255,3,0,255,3,0,255,3,0,255,3,0,255,3,0,255,3,0,255,3)
}

[Byte[]]$TargetHours = $HourPresets[$HoursPreset]

Write-Host "Processing group: $GroupName" -ForegroundColor Cyan
Write-Host "Target hours preset: $HoursPreset" -ForegroundColor Cyan

[Array]$Group = Get-ADGroupMember -Identity $GroupName -Recursive |
    Select-Object -ExpandProperty DistinguishedName

if ($null -eq $Group) {
    Write-Host "No members found in group $GroupName" -ForegroundColor Yellow
    return
}

Write-Host "Found $($Group.Count) members" -ForegroundColor Green

foreach ($member in $Group) {
    try {
        [Byte[]]$CurrentHours = Get-ADUser $member -Properties logonhours |
            Select-Object -ExpandProperty logonhours

        if (Compare-Object $TargetHours $CurrentHours) {
            Write-Host "Hours differ for: $member" -ForegroundColor Yellow

            # Uncomment below to apply changes
            # $user = [ADSI]"LDAP://$member"
            # $user.logonhours = $TargetHours
            # $user.SetInfo()
            # Write-Host "Updated: $member" -ForegroundColor Green
        } else {
            Write-Host "Hours match for: $member" -ForegroundColor Green
        }
    }
    catch {
        Write-Warning "Failed to process $member - $_"
    }
}
