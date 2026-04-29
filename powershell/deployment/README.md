# Deployment Scripts

Scripts for software installation and patch deployment.

## Scripts

### Install-SoftwareRemote.ps1
Copies an MSI or EXE from a network share to remote computers
and installs it silently. Cleans up installer after completion.

```powershell
.\Install-SoftwareRemote.ps1 -ComputerName PC1,PC2 -InstallerSource "\\server\share\app.msi"
```

### Install-SoftwareLocal.ps1
Detects OS architecture and installs the appropriate 32 or 64-bit
installer from a network share. Runs locally on the current machine.

```powershell
.\Install-SoftwareLocal.ps1 `
    -SourcePath32 "\\server\share\app_x86.exe" `
    -SourcePath64 "\\server\share\app_x64.exe"
```

### Invoke-RemotePatch.ps1
Bootstraps WinRM via PSExec on computers that don't have it enabled,
then deploys a patch file. Checks if patch is already installed first.

```powershell
.\Invoke-RemotePatch.ps1 `
    -ComputerName PC1,PC2 `
    -PatchSource "\\server\share\patch.msu" `
    -KBNumber "KB4532938"
```

## Archived

### microfocus_install.ps1
Environment-specific installer. Archived — technique generalized
into Install-SoftwareRemote.ps1.

## Notes

- Invoke-RemotePatch requires PSExec — download from Sysinternals
- Install-SoftwareLocal must run on the target machine directly
- All remote scripts require appropriate network and WinRM access
