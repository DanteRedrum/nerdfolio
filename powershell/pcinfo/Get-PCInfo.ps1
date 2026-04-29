#Requires -Version 5.0

<#
.SYNOPSIS
    Gathers comprehensive hardware and software information from a remote computer.

.DESCRIPTION
    Collects system information including hardware specs, OS details, BIOS,
    product key, TPM status, memory, CPU, and network configuration.
    Results are output to the pipeline as a PSCustomObject and displayed
    in Out-GridView for interactive viewing.

.PARAMETER ComputerName
    One or more computer names to query.

.PARAMETER GridView
    Switch to display results in Out-GridView. Default is pipeline output.

.EXAMPLE
    Get-PCInfo -ComputerName TARGETPC
    Get-PCInfo -ComputerName PC1,PC2,PC3
    Get-PCInfo -ComputerName TARGETPC -GridView

.NOTES
    Author: Daniel Avila
    Refactored for Nerdfolio — Phase 4
    Original: Get-PCINFO.ps1, Example.ps1 (UTF-16 encoded originals)
    The full version lived inside ToolCenter.ps1 as an embedded function.
    Changes: WMI migrated to CIM, hardcoded values removed,
             added GridView switch, error handling added per query,
             PSCustomObject accelerator used
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [string[]]$ComputerName,

    [switch]$GridView
)

process {
    foreach ($Computer in $ComputerName) {
        Write-Verbose "Querying $Computer"

        try {
            # Computer System
            $ComputerSystem = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $Computer

            # Operating System
            $OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $Computer

            # BIOS
            $Bios = Get-CimInstance -ClassName Win32_BIOS -ComputerName $Computer

            # Product Key
            $PKey = Get-CimInstance -ClassName SoftwareLicensingService -ComputerName $Computer

            # TPM
            $TPM = Get-CimInstance -Namespace root\CIMV2\Security\MicrosoftTpm `
                -ClassName Win32_Tpm -ComputerName $Computer -ErrorAction SilentlyContinue

            # Memory
            $Memory = Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $Computer

            # Memory Slots
            $Slots = Get-CimInstance -ClassName Win32_PhysicalMemoryArray -ComputerName $Computer

            # CPU
            $CPU = Get-CimInstance -ClassName Win32_Processor -ComputerName $Computer

            # Network Adapter
            $Network = Get-CimInstance -ClassName Win32_NetworkAdapter `
                -Filter "NetConnectionStatus = 2" -ComputerName $Computer

            # Network Config
            $NetConf = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration `
                -Filter "IPEnabled = True" -ComputerName $Computer

            $Result = [PSCustomObject]@{
                ComputerName           = $ComputerSystem.Name
                Manufacturer           = $ComputerSystem.Manufacturer
                Model                  = $ComputerSystem.Model
                CurrentUser            = $ComputerSystem.UserName
                OperatingSystem        = $OperatingSystem.Caption
                OSVersion              = $OperatingSystem.Version
                OSArchitecture         = $OperatingSystem.OSArchitecture
                SerialNumber           = $Bios.SerialNumber
                ProductKey             = $PKey.OA3xOriginalProductKey
                TPMEnabled             = $TPM.IsEnabled_InitialValue
                TPMVersion             = $TPM.SpecVersion
                MemoryCapacityGB       = [math]::Round(($Memory.Capacity | Measure-Object -Sum).Sum / 1GB, 2)
                MemorySpeed            = ($Memory.Speed | Select-Object -First 1)
                MemoryUsedSlots        = ($Memory.DeviceLocator -join ', ')
                TotalMemorySlots       = $Slots.MemoryDevices
                CPUName                = $CPU.Name
                CPUCores               = $CPU.NumberOfCores
                NicName                = $Network.Name
                NicMac                 = $Network.MACAddress
                IPAddress              = ($NetConf.IPAddress | Select-Object -First 1)
                DefaultGateway         = ($NetConf.DefaultIPGateway | Select-Object -First 1)
                DNSDomain              = $NetConf.DNSDomain
            }

            if ($GridView) {
                $Result | Out-GridView -Title "PC Info — $Computer"
            } else {
                $Result
            }
        }
        catch {
            Write-Warning "Failed to query $Computer - $_"
        }
    }
}
