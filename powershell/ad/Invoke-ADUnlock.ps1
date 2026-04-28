#Requires -Version 5.0
#Requires -Modules ActiveDirectory

<#
.SYNOPSIS
    Finds and unlocks locked Active Directory user accounts.

.DESCRIPTION
    Queries Active Directory for locked enabled user accounts using LDAP filter.
    Presents results in Out-GridView for selection, then unlocks selected accounts
    and confirms unlock status.

.EXAMPLE
    .\Invoke-ADUnlock.ps1

.NOTES
    Author: Daniel Avila
    Requires: ActiveDirectory module, appropriate AD permissions
    Refactored for Nerdfolio — Phase 4
    Changes: Added null comparison best practice, improved output formatting
#>

Import-Module ActiveDirectory

[Array]$LockedOut = Get-ADUser -LDAPFilter "(&(&(&(&(objectCategory=person)(objectClass=user)(lockoutTime:1.2.840.113556.1.4.804:=4294967295)))))" |
    Where-Object { $_.Enabled -eq $true } |
    Select-Object -ExpandProperty SamAccountName |
    Out-GridView -PassThru -Title "Select Locked Out Users to Unlock"

if ($null -eq $LockedOut) {
    Write-Host "No users selected or no locked accounts found." -ForegroundColor Yellow
} else {
    foreach ($Person in $LockedOut) {
        try {
            Unlock-ADAccount -Identity $Person

            $Check = Get-ADUser -Identity $Person -Properties LockedOut |
                Select-Object -ExpandProperty LockedOut

            if ($Check -eq $false) {
                Write-Host "$Person unlocked successfully." -ForegroundColor Green
            } else {
                Write-Host "$Person may still be locked — verify manually." -ForegroundColor Yellow
            }
        }
        catch {
            Write-Warning "Failed to unlock $Person - $_"
        }
    }
}
