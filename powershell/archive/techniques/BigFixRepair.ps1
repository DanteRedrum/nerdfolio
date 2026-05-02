$Computer = Get-Content -Path '\\dw10davila\C$\Support Tools\BigFix.txt'
$cred = Get-Credential
Foreach($comp in $Computer){

    Start-Process -Filepath "C:\Support Tools\PSTools\psexec.exe" -Argumentlist "\\$comp -s C:\windows\system32\winrm.cmd quickconfig -q" -Credential $cred
	Write-Host "Enabling WINRM Quickconfig" -ForegroundColor Green	
    
    Write-Host "Waiting for 10 Seconds......." -ForegroundColor Yellow
    Start-Sleep -Seconds 10 -Verbose
    
    Start-Process -Filepath "C:\Support Tools\PSTools\psexec.exe" -Argumentlist "\\$comp -h -d powershell.exe enable-psremoting -force" -Credential $cred
	Write-Host "Enabling PSRemoting" -ForegroundColor Green
       
   	Write-Host "Waiting for 10 Seconds......." -ForegroundColor Yellow
    Start-Sleep -Seconds 10 -Verbose
    
    Start-Process -Filepath "C:\Support Tools\PSTools\psexec.exe" -Argumentlist "\\$comp -h -d powershell.exe set-executionpolicy RemoteSigned -force" -Credential $cred
	Write-Host "Enabling Execution Policy" -ForegroundColor Green	
   	
    Write-Host "Waiting for 20 Seconds......." -ForegroundColor Yellow
    Start-Sleep -Seconds 20 -Verbose

Copy-item '\\dw10davila\C$\Users\davila\Desktop\ActionSite.afxm' -Destination "\\$comp\C$\Program Files (x86)\BigFix Enterprise\BES Client"
Invoke-Command -computername $comp -scriptblock {& cmd.exe /c "net start BESClient"}
}