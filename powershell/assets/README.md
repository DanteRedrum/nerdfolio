# Assets

Scripts for asset tag management.

## Scripts

### Invoke-AssetTracker.ps1

GUI tool for reading and writing asset tags stored in the remote registry.
Queries AD for computers, select from dropdown, then search or create
an asset tag stored in the remote registry.

**Usage:**
```powershell
# Basic — queries all computers
.\Invoke-AssetTracker.ps1 -SearchBase "DC=domain,DC=com"

# Filter by naming convention
.\Invoke-AssetTracker.ps1 -SearchBase "DC=domain,DC=com" -ADFilter "DESKTOP-*"

# Custom registry path
.\Invoke-AssetTracker.ps1 -SearchBase "DC=domain,DC=com" -RegistryPath "HKLM:\SOFTWARE\Company" -RegistryKey "AssetID"
```

**Registry storage:**
Asset tags are stored at the configured registry path on each remote
machine. Default path: `HKLM:\SOFTWARE\AssetManagement\AssetTag`
The original script used `HKLM:\SOFTWARE\Bank\Asset_Tag` —
change via parameters to match your environment.

**Requirements:**
- ActiveDirectory module
- WinRM enabled on target computers
- Remote registry access permissions