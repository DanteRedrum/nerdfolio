#Requires -Version 5.0

<#
.SYNOPSIS
    Returns detailed memory and CPU information from remote computers.

.DESCRIPTION
    Queries memory chip details, CPU name and data width, OS architecture,
    and computer model from one or more remote computers.

.PARAMETER ComputerName
    One or more computer names to query.

.EXAMPLE
    .\Get-Memory.ps1 -ComputerName TARGETPC
    .\Get-Memory.ps1 -ComputerName PC1,PC2,PC3

.NOTES
    Author: Daniel Avila
    Refactored for Nerdfolio — Phase 4
    Original: Get_Memory.ps1
    Changes: WMI (wmic) calls replaced with CIM, output structured
             as PSCustomObject instead of raw wmic text
#>

param(
    [Parameter(Mandatory=$true)]
    [string[]]$ComputerName
)

foreach ($pc in $ComputerName) {
    Write-Host "$pc" -ForegroundColor Cyan
    try {
        $Memory = Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $pc |
            Select-Object BankLabel, DeviceLocator, MemoryType, TypeDetail,
                @{Name="CapacityGB"; Expression={[math]::Round($_.Capacity/1GB,2)}}, Speed

        $CPU = Get-CimInstance -ClassName Win32_Processor -ComputerName $pc |
            Select-Object Name, DataWidth

        $OS = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $pc |
            Select-Object OSArchitecture

        $Model = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $pc |
            Select-Object Model

        [PSCustomObject]@{
            ComputerName  = $pc
            Model         = $Model.Model
            OSArchitecture = $OS.OSArchitecture
            CPUName       = $CPU.Name
            CPUDataWidth  = $CPU.DataWidth
            Memory        = $Memory
        }
    }
    catch {
        Write-Warning "Failed to query $pc - $_"
    }
}
