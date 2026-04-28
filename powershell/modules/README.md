# Modules

Reusable PowerShell functions organized as importable modules.

## HelpdeskTools.psm1

Core utility functions developed during helpdesk operations.
Refactored for reuse — hardcoded values removed, comment-based
help added, parameter validation improved.

### Functions

| Function | Description |
|---|---|
| `p` | Quick ping test — returns $true/$false |
| `Get-LoggedIn` | Returns logged-in user on remote computer |
| `Get-Uptime` | Returns system uptime for local or remote machine |
| `Get-HWVersion` | Retrieves driver info from remote computer |

### Usage

```powershell
Import-Module .\HelpdeskTools.psm1

# Check if a computer is online
p -computername TARGETPC

# Get logged in user
Get-LoggedIn -computername TARGETPC

# Get uptime
Get-Uptime -ComputerName TARGETPC

# Get driver info
Get-HWVersion -ComputerName TARGETPC -Name "Intel"
```

## Changelog

### v2.1
- Migrated all WMI calls to CIM
- Fixed Get-Uptime multi-computer parameter shadowing bug
- Added try/catch error handling throughout
- Replaced New-Object PSObject with [PSCustomObject] accelerator

### v2.0
- Initial refactor for Nerdfolio Phase 4
- Removed hardcoded values
- Added comment-based help
