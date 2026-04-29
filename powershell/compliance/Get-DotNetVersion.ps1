#Requires -Version 5.0

<#
.SYNOPSIS
    Checks .NET Framework version on remote computers via registry.

.DESCRIPTION
    Reads the .NET Framework release key from the remote registry and
    maps it to the human-readable version. Color coded output:
    Red    = 4.5.x (outdated)
    Yellow = 4.6.x - 4.8 (aging)
    Green  = 4.8+ (current)

.PARAMETER ComputerList
    Path to a text file containing computer names, one per line.

.PARAMETER ComputerName
    One or more computer names to check directly.

.PARAMETER ADFilter
    AD computer name filter. Example: "DESKTOP-*"

.PARAMETER SearchBase
    AD SearchBase DN to query computers from.

.EXAMPLE
    .\Get-DotNetVersion.ps1 -ComputerList "C:\Temp\computers.txt"
    .\Get-DotNetVersion.ps1 -ComputerName PC1,PC2
    .\Get-DotNetVersion.ps1 -ADFilter "DESKTOP-*" -SearchBase "DC=domain,DC=com"

.NOTES
    Author: Daniel Avila
    Refactored for Nerdfolio — Phase 4
    Changes: Removed hardcoded AD filter and domain, added parameter support,
             added error handling, improved color coding logic
#>

param(
    [string]$ComputerList,
    [string[]]$ComputerName,
    [string]$ADFilter,
    [string]$SearchBase
)

# .NET release key to version mapping
$DotNetVersionMap = @{
    378389 = @{ Version = ".NET Framework 4.5";   Status = "Red" }
    378675 = @{ Version = ".NET Framework 4.5.1"; Status = "Red" }
    378758 = @{ Version = ".NET Framework 4.5.1"; Status = "Red" }
    379893 = @{ Version = ".NET Framework 4.5.2"; Status = "Red" }
    393295 = @{ Version = ".NET Framework 4.6";   Status = "Yellow" }
    393297 = @{ Version = ".NET Framework 4.6";   Status = "Yellow" }
    394254 = @{ Version = ".NET Framework 4.6.1"; Status = "Yellow" }
    394271 = @{ Version = ".NET Framework 4.6.1"; Status = "Yellow" }
    394802 = @{ Version = ".NET Framework 4.6.2"; Status = "Yellow" }
    394806 = @{ Version = ".NET Framework 4.6.2"; Status = "Yellow" }
    460798 = @{ Version = ".NET Framework 4.7";   Status = "Yellow" }
    460805 = @{ Version = ".NET Framework 4.7";   Status = "Yellow" }
    461308 = @{ Version = ".NET Framework 4.7.1"; Status = "Yellow" }
    461310 = @{ Version = ".NET Framework 4.7.1"; Status = "Yellow" }
    461808 = @{ Version = ".NET Framework 4.7.2"; Status = "Yellow" }
    461814 = @{ Version = ".NET Framework 4.7.2"; Status = "Yellow" }
    528040 = @{ Version = ".NET Framework 4.8";   Status = "Green" }
    528049 = @{ Version = ".NET Framework 4.8";   Status = "Green" }
    533320 = @{ Version = ".NET Framework 4.8.1"; Status = "Green" }
}

# Build computer list
if ($ComputerList) {
    $Computers = Get-Content -Path $ComputerList
} elseif ($ComputerName) {
    $Computers = $ComputerName
} elseif ($ADFilter -and $SearchBase) {
    Import-Module ActiveDirectory
    $Computers = Get-ADComputer -Filter "Name -like '$ADFilter'" `
        -Properties CN `
        -SearchBase $SearchBase `
        -SearchScope 2 |
        Select-Object -ExpandProperty CN
} else {
    Write-Warning "Provide -ComputerList, -ComputerName, or -ADFilter with -SearchBase"
    return
}

foreach ($comp in $Computers) {
    Write-Host "$comp" -ForegroundColor Cyan
    try {
        $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $comp)
        $RegKey = $Reg.OpenSubKey("SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full")

        if ($null -eq $RegKey) {
            Write-Host "  .NET v4 registry key not found" -ForegroundColor Red
            continue
        }

        $ReleaseKey = $RegKey.GetValue("Release")

        if ($DotNetVersionMap.ContainsKey($ReleaseKey)) {
            $Entry = $DotNetVersionMap[$ReleaseKey]
            Write-Host "  $($Entry.Version) installed" -ForegroundColor $Entry.Status
        } else {
            Write-Host "  Unknown release key: $ReleaseKey" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  Failed to query $comp - $_" -ForegroundColor Red
    }
}
