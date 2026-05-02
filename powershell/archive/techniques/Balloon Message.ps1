<#
strText = "Can we restart your computer?"
strTitle = "Helpdesk wants to restart"
intType = vbYesNO + vbQuestion + vbDefaultButton2

set objWshShell = Wscript.CreateObject("Wscript.Shell")
intResult = objWshShell.Popup(strText, ,strTitle,intType)
#>

$wshell = New-Object -ComObject Wscript.Shell
$Output = $wshell.Popup( "I C U")

Invoke-Command -ComputerName dw10murquiza -scriptblock "$output"

<#
Add-Type -AssemblyName System.Windows.Forms 
$global:balloon = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) 
$balloon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning 
$balloon.BalloonTipText = 'Helpdesk is Restarting your Computer'
$balloon.BalloonTipTitle = "Attention $Env:USERNAME" 
$balloon.Visible = $true 
$balloon.ShowBalloonTip(5000)

$computer = Read-Host "Computer Name"
$msg = Read-Host "Enter Your Message"
Invoke-WmiMethod -Path Win32_Process -Name Create -ArgumentList "msg * $msg" -ComputerName $computer
#>