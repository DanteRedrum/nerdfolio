# Compliance Scripts

Scripts for checking endpoint compliance across the environment.
All scripts accept either a computer list file or direct computer names.

## Scripts

### Get-BigFixStatus.ps1
Checks if the BESClient (BigFix) service is running on remote computers.

```powershell
.\Get-BigFixStatus.ps1 -ComputerList "C:\Temp\computers.txt"
.\Get-BigFixStatus.ps1 -ComputerName PC1,PC2,PC3
```

### Get-CrowdStrikeStatus.ps1
Checks CrowdStrike installation on remote computers. Supports AD query,
file list, or direct computer names. Optional export of missing computers.

```powershell
.\Get-CrowdStrikeStatus.ps1 -ComputerList "C:\Temp\computers.txt"
.\Get-CrowdStrikeStatus.ps1 -ADFilter "DESKTOP-*" -SearchBase "DC=domain,DC=com"
.\Get-CrowdStrikeStatus.ps1 -ComputerList "C:\Temp\computers.txt" -ExportMissing "C:\Temp\NeedsCS.txt"
```

### Get-DotNetVersion.ps1
Checks .NET Framework version via remote registry key.
Color coded: Red = outdated, Yellow = aging, Green = current.

```powershell
.\Get-DotNetVersion.ps1 -ComputerList "C:\Temp\computers.txt"
.\Get-DotNetVersion.ps1 -ADFilter "DESKTOP-*" -SearchBase "DC=domain,DC=com"
```

### Get-TPMStatus.ps1
Checks TPM enabled status and version on remote computers.
Also returns computer model for hardware tracking.

```powershell
.\Get-TPMStatus.ps1 -ComputerList "C:\Temp\computers.txt"
.\Get-TPMStatus.ps1 -ComputerName PC1,PC2,PC3
```

## Notes

- All scripts require appropriate remote access permissions
- CrowdStrike check uses Win32_Product which can be slow on large environments
- .NET check uses remote registry — requires RemoteRegistry service running on targets
- TPM check requires WMI access to root\CIMV2\Security\MicrosoftTpm namespace
