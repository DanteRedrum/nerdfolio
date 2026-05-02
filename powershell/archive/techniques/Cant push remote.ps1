$comp = Read-Host "computer name"


   $wshell = New-Object -ComObject Wscript.Shell -ErrorAction stop
    $r = $wshell.Popup("Are you ready to restart your Computer?", 5000,"Helpdesk Warning",32+4)
    
     
     If ($r -eq 6) { 
     Write-Host "He wants to"
     }
     Elseif ($r -eq 7) {
     Write-Host "He dont want to"
     }
     
    
Invoke-Command -ComputerName $comp -scriptblock {param($wshell)} -ArgumentList $r