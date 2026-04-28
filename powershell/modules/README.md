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

### Notes

- `Get-Uptime` has a known issue with multiple computer names — documented in the TODO comment
- `Get-HWVersion` consolidates two slightly different versions from the original codebase into one multi-computer capable function
- WMI calls will eventually be migrated to CIM equivalents (`Get-CimInstance`)
