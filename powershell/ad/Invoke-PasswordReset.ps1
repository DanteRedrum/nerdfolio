#Requires -Version 5.0
#Requires -Modules ActiveDirectory

<#
.SYNOPSIS
    Resets Active Directory user passwords via GUI selection.

.DESCRIPTION
    Queries Active Directory for enabled user accounts, presents them in
    Out-GridView for selection, prompts for new password securely, and
    resets the account password.

.EXAMPLE
    .\Invoke-PasswordReset.ps1

.NOTES
    Author: Daniel Avila
    Requires: ActiveDirectory module, appropriate AD permissions
    Refactored for Nerdfolio — Phase 4
    Security fix: Removed plaintext password output from original script.
    ChangePasswordAtLogon left as $false — adjust per policy.
#>

Import-Module ActiveDirectory

[Array]$PWReset = Get-ADUser -LDAPFilter "(&(&(|(&(objectCategory=person)(objectSid=*)(!samAccountType:1.2.840.113556.1.4.804:=3))(&(objectCategory=person)(!objectSid=*))(&(objectCategory=group)(groupType:1.2.840.113556.1.4.804:=14)))(objectCategory=user)(userPrincipalName=*)))" |
    Where-Object { $_.Enabled -eq $true } |
    Select-Object -ExpandProperty SamAccountName |
    Out-GridView -PassThru -Title "Select Users for Password Reset"

if ($null -eq $PWReset) {
    Write-Host "No users selected." -ForegroundColor Yellow
} else {
    foreach ($UserPass in $PWReset) {
        try {
            $NewPassword = Read-Host -Prompt "Enter new password for $UserPass" -AsSecureString
            Set-ADAccountPassword -Identity $UserPass -NewPassword $NewPassword -Reset
            Set-ADUser -Identity $UserPass -ChangePasswordAtLogon:$false -ErrorAction Continue
            Write-Host "$UserPass password reset successfully." -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to reset password for $UserPass - $_"
        }
    }
}
