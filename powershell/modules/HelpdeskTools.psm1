#Requires -Version 5.0

<#
.SYNOPSIS
    Helpdesk utility functions module.

.DESCRIPTION
    A collection of reusable functions for IT helpdesk and systems administration.
    Originally developed for Windows-based helpdesk operations.
    Import with: Import-Module .\HelpdeskTools.psm1

.NOTES
    Author: Daniel Avila
    Version: 2.1
    Refactored for Nerdfolio — Phase 4
    Changes in 2.1:
      - Migrated all WMI calls to CIM
      - Fixed Get-Uptime multi-computer parameter shadowing bug
      - Added try/catch error handling throughout
      - Replaced New-Object PSObject with [PSCustomObject] accelerator
#>


function p {
    <#
    .SYNOPSIS
        Quick online check for a remote computer.
    .EXAMPLE
        p -computername TARGETPC
        Returns $true if online, $false if not.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$computername
    )
    return (Test-Connection $computername -Count 1 -Quiet)
}


function Get-LoggedIn {
    <#
    .SYNOPSIS
        Returns the currently logged-in user on a remote computer.
    .PARAMETER ComputerName
        One or more computer names to query.
    .EXAMPLE
        Get-LoggedIn -ComputerName TARGETPC
        Get-LoggedIn -ComputerName PC1,PC2,PC3
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]]$ComputerName
    )

    foreach ($pc in $ComputerName) {
        try {
            $system = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $pc
            if ($system.UserName) {
                $name = $system.UserName.Split("\")[1]
                [PSCustomObject]@{
                    ComputerName = $pc
                    LoggedInUser = $name
                }
            } else {
                [PSCustomObject]@{
                    ComputerName = $pc
                    LoggedInUser = "No user logged in"
                }
            }
        }
        catch {
            Write-Warning "Failed to query $pc - $_"
        }
    }
}


function Get-Uptime {
    <#
    .SYNOPSIS
        Returns system uptime for a local or remote computer.
    .PARAMETER ComputerName
        One or more computer names to query. Defaults to localhost.
    .EXAMPLE
        Get-Uptime
        Get-Uptime -ComputerName TARGETPC
        Get-Uptime -ComputerName PC1,PC2,PC3
    .NOTES
        Multi-computer support fixed in Phase 4 refactor.
        Original bug: loop variable shadowed the parameter.
    #>
    [CmdletBinding()]
    param (
        [string[]]$ComputerName = 'localhost'
    )

    foreach ($Computer in $ComputerName) {
        try {
            $os   = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $Computer
            $diff = (Get-Date) - $os.LastBootUpTime

            [PSCustomObject]@{
                ComputerName  = $Computer
                UptimeDays    = $diff.Days
                UptimeHours   = $diff.Hours
                UptimeMinutes = $diff.Minutes
                UptimeSeconds = $diff.Seconds
            }
        }
        catch {
            Write-Warning "Failed to query $Computer - $_"
        }
    }
}


function Get-HWVersion {
    <#
    .SYNOPSIS
        Retrieves hardware driver info from a remote computer.
    .DESCRIPTION
        Queries Win32_PnPSignedDriver for device name, driver date,
        and driver version. Checks connectivity before querying.
    .PARAMETER ComputerName
        A computer name or IP address to query.
    .PARAMETER Name
        Full or partial device name to search for.
    .EXAMPLE
        Get-HWVersion -ComputerName TARGETPC -Name "Radeon"
        Get-HWVersion -ComputerName TARGETPC -Name "Intel"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$ComputerName,

        [Parameter(Mandatory=$true)]
        [string]$Name
    )

    foreach ($Computer in $ComputerName) {
        Write-Verbose "Verifying $Computer is online"
        if (-not (Test-Connection $Computer -Count 1 -Quiet)) {
            Write-Warning "$Computer is not online — skipping"
            continue
        }

        try {
            Write-Verbose "Pulling driver data from $Computer"
            Get-CimInstance -Query "SELECT * FROM Win32_PnPSignedDriver WHERE DeviceName LIKE '%$Name%'" `
                -ComputerName $Computer |
                Sort-Object DeviceName |
                Select-Object `
                    @{Name="Server";     Expression={$_.PSComputerName}},
                    DeviceName,
                    @{Name="DriverDate"; Expression={$_.DriverDate.ToString("MM/dd/yyyy")}},
                    DriverVersion
        }
        catch {
            Write-Warning "Failed to query $Computer - $_"
        }
    }
}


Export-ModuleMember -Function p, Get-LoggedIn, Get-Uptime, Get-HWVersion
