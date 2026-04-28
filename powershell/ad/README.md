# AD Scripts

Active Directory management scripts for helpdesk operations.

## Scripts

### Invoke-ADUnlock.ps1
Finds all locked enabled AD accounts, presents them in a GUI selection
window, and unlocks selected accounts with confirmation.

**Usage:**
```powershell
.\Invoke-ADUnlock.ps1
```

### Invoke-PasswordReset.ps1
Lists all enabled AD users in a GUI selection window, prompts for a new
password, and resets selected accounts.

**Security note:** Original script printed plaintext password to console.
Fixed in Phase 4 refactor — password now stays in SecureString.

**Usage:**
```powershell
.\Invoke-PasswordReset.ps1
```

### Get-NewDomainComputers.ps1
Returns computers added to the domain after a specified date.
Defaults to the last 30 days. Optional file output.

**Usage:**
```powershell
# Last 30 days
.\Get-NewDomainComputers.ps1

# Since specific date
.\Get-NewDomainComputers.ps1 -Since "2024-01-01"

# Save to file
.\Get-NewDomainComputers.ps1 -Since "2024-01-01" -OutputPath "C:\Temp\NewPCs.txt"
```

## Requirements

- ActiveDirectory PowerShell module
- Appropriate AD read/write permissions
- Run with helpdesk or admin credentials as needed
