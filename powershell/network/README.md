# Network Scripts

Scripts for remote management, connectivity testing, and network fixes.

## Scripts

### Enable-WinRM.ps1
Bootstraps WinRM and PSRemoting on computers that don't have it enabled,
using PSExec. Required before other remote scripts can reach new machines.

```powershell
.\Enable-WinRM.ps1 -ComputerName TARGETPC
.\Enable-WinRM.ps1 -ComputerName PC1,PC2,PC3 -TestAfter
```

**Requires:** PSExec from Sysinternals

### Set-VPNRegistryFix.ps1
Sets the CredSSP AllowEncryptionOracle registry key needed for some VPN
clients. Merges original RegistryforVPN.ps1 and RegistryforVPNusingFile.ps1.

```powershell
.\Set-VPNRegistryFix.ps1 -ComputerName PC1,PC2
.\Set-VPNRegistryFix.ps1 -ComputerList "C:\Temp\vpnpcs.txt"
```

### Reset-PrintQueue.ps1
Clears stuck print jobs by stopping the spooler, deleting spool files,
and restarting the service.

```powershell
.\Reset-PrintQueue.ps1 -ComputerName TARGETPC
```

### Test-ComputerOnline.ps1
Pings one or more computers and reports online/offline status with
color-coded output.

```powershell
.\Test-ComputerOnline.ps1 -ComputerName PC1,PC2,PC3
.\Test-ComputerOnline.ps1 -ComputerList "C:\Temp\computers.txt"
```

## Notes

- Enable-WinRM requires PSExec and admin credentials
- All remote scripts require WinRM enabled on targets
- Set-VPNRegistryFix requires PSRemoting on targets
