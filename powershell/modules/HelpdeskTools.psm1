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
    Version: 2.0
    Refactored for Nerdfolio — Phase 4
#>


# ——————————————————————————
# Function Name: p
# Quick ping test — replacement for Test-Connection one-liner
# ——————————————————————————
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


# ——————————————————————————
# Function Name: Get-LoggedIn
# Return the current logged-in user of a remote machine.
# ——————————————————————————
function Get-LoggedIn {
    <#
    .SYNOPSIS
        Returns the currently logged-in user on a remote computer.
    .PARAMETER computername
        One or more computer names to query.
    .EXAMPLE
        Get-LoggedIn -computername TARGETPC
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [string[]]$computername
    )

    foreach ($pc in $computername) {
        $logged_in = (Get-WmiObject Win32_ComputerSystem -ComputerName $pc).Username
        if ($logged_in) {
            $name = $logged_in.Split("\")[1]
            "{0}: {1}" -f $pc, $name
        } else {
            "{0}: No user logged in" -f $pc
        }
    }
}


# ——————————————————————————
# Function Name: Get-Uptime
# Calculate and display system uptime on a local or remote machine.
# ——————————————————————————
function Get-Uptime {
    <#
    .SYNOPSIS
        Returns system uptime for a local or remote computer.
    .PARAMETER ComputerName
        Computer name to query. Defaults to localhost.
    .EXAMPLE
        Get-Uptime
        Get-Uptime -ComputerName TARGETPC
    .NOTES
        TODO: Fix multiple computer name handling and convertdate errors
        when providing more than one computer name.
    #>
    [CmdletBinding()]
    param (
        [string]$ComputerName = 'localhost'
    )

    foreach ($Computer in $ComputerName) {
        $os   = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer
        $diff = $os.ConvertToDateTime($os.LocalDateTime) - $os.ConvertToDateTime($os.LastBootUpTime)

        $properties = @{
            ComputerName   = $Computer
            UptimeDays     = $diff.Days
            UptimeHours    = $diff.Hours
            UptimeMinutes  = $diff.Minutes
            UptimeSeconds  = $diff.Seconds
        }

        New-Object -TypeName PSObject -Property $properties
    }
}


# ——————————————————————————
# Function Name: Get-HWVersion
# Retrieves device name, driver date, and driver version from a remote PC.
# Two versions — single computer and multi-computer capable.
# ——————————————————————————
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
    .EXAMPLE
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
            Write-Output "$Computer not online"
            continue
        }

        Write-Verbose "Pulling driver data from $Computer"
        Get-WmiObject -Query "SELECT * FROM Win32_PnPSignedDriver WHERE DeviceName LIKE '%$Name%'" `
            -ComputerName $Computer |
            Sort-Object DeviceName |
            Select-Object `
                @{Name="Server";      Expression={$_.__Server}},
                DeviceName,
                @{Name="DriverDate";  Expression={
                    [System.Management.ManagementDateTimeConverter]::ToDateTime($_.DriverDate).ToString("MM/dd/yyyy")
                }},
                DriverVersion
    }
}


# Export all functions
Export-ModuleMember -Function p, Get-LoggedIn, Get-Uptime, Get-HWVersion
