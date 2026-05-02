Set-ExecutionPolicy -Scope CurrentUser -Force Unrestricted

$Money = Get-Credential 

Start-Process "chrome.exe" "https://abochd.saasit.com/"

Invoke-Item "C:\Program Files (x86)\Microsoft Office\Office15\OUTLOOK.EXE"

Start-Process “C:\Windows\System32\cmd.exe” -workingdirectory $PSHOME -Credential ($Money) -ArgumentList “/c dsac.exe”

sleep -s 5

Get-Process cmd | Stop-Process -Force

sleep -s 5

Get-Process cmd | Stop-Process -Force