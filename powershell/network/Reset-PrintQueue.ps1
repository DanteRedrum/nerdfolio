#Requires -Version 5.0

<#
.SYNOPSIS
    Clears the print queue on a remote computer by restarting the spooler.

.DESCRIPTION
    Stops the Print Spooler service, deletes all pending print jobs from
    the spool directory, then restarts the service. Confirms service
    status before and after the operation.

.PARAMETER ComputerName
    One or more computer names to clear print queues on.

.EXAMPLE
    .\Reset-PrintQueue.ps1 -ComputerName TARGETPC
    .\Reset-PrintQueue.ps1 -ComputerName PC1,PC2,PC3

.NOTES
    Author: Daniel Avila
    Refactored for Nerdfolio — Phase 4
    Original: PrintQue.ps1 (UTF-16 encoded)
    Changes: Removed hardcoded computer name, added parameter support,
             added status reporting before and after, error handling added
#>

param(
    [Parameter(Mandatory=$true)]
    [string[]]$ComputerName
)

foreach ($pc in $ComputerName) {
    Write-Host "$pc — Resetting print queue" -ForegroundColor Cyan

    try {
        # Check initial status
        $Before = Get-Service -ComputerName $pc -Name Spooler |
            Select-Object -ExpandProperty Status
        Write-Host "$pc — Spooler before: $Before" -ForegroundColor Yellow

        # Stop spooler
        Invoke-Command -ComputerName $pc -ScriptBlock {
            & cmd.exe /c "net stop spooler"
        }
        Start-Sleep -Seconds 5

        # Clear print jobs
        Invoke-Command -ComputerName $pc -ScriptBlock {
            & cmd.exe /c "del /F /Q C:\Windows\System32\spool\PRINTERS\*"
        }
        Start-Sleep -Seconds 3

        # Start spooler
        Invoke-Command -ComputerName $pc -ScriptBlock {
            & cmd.exe /c "net start spooler"
        }
        Start-Sleep -Seconds 3

        # Confirm status
        $After = Get-Service -ComputerName $pc -Name Spooler |
            Select-Object -ExpandProperty Status
        Write-Host "$pc — Spooler after: $After" -ForegroundColor Green
    }
    catch {
        Write-Warning "$pc — Failed: $_"
    }
}
