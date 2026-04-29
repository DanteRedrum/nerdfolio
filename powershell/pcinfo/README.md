# PC Info Scripts

Scripts for gathering hardware and system information from remote computers.

## Scripts

### Get-PCInfo.ps1
Comprehensive system information gathering. Returns computer system,
OS, BIOS, product key, TPM, memory, CPU, and network config.

```powershell
# Pipeline output
Get-PCInfo -ComputerName TARGETPC

# Multiple computers
Get-PCInfo -ComputerName PC1,PC2,PC3

# GridView popup
Get-PCInfo -ComputerName TARGETPC -GridView
```

### Get-Memory.ps1
Detailed memory chip information plus CPU and OS architecture.
Useful for hardware audits and upgrade planning.

```powershell
.\Get-Memory.ps1 -ComputerName TARGETPC
.\Get-Memory.ps1 -ComputerName PC1,PC2,PC3
```

## Notes

- Both scripts require WinRM and appropriate remote access permissions
- Get-PCInfo TPM query will return null on machines without TPM — handled gracefully
- Product key (OA3xOriginalProductKey) only returns UEFI-embedded keys
- Memory capacity reported in GB rounded to 2 decimal places
