# Add assemblies for WPF and Mahapps
[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')    | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework')   | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')          | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('WindowsFormsIntegration') | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('System.IO')               | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')   | Out-Null
[System.Windows.Forms.Application]::EnableVisualStyles()

# Choose an icon to display in the systray
#This Icon must be on the computer to display
$icon =  "C:\Users\davila\Documents\Helpdesk KB\Info\aboc_small_logo_lxC_icon.ico"
 
# Add the systray icon 
$Main_Tool_Icon = New-Object System.Windows.Forms.NotifyIcon
$Main_Tool_Icon.Text = "Tool Center"
$Main_Tool_Icon.Icon = $icon
$Main_Tool_Icon.Visible = $true
 
# Add menu users
$Menu_Users = New-Object System.Windows.Forms.MenuItem
$Menu_Users.Text = "User analysis"
 
# Add menu computers
$Menu_Computers = New-Object System.Windows.Forms.MenuItem
$Menu_Computers.Text = "Computer analysis"
 
# Add Showing the tool
$Menu_Show = New-Object System.Windows.Forms.MenuItem
$Menu_Show.Text = "Show Main Menu"
 
# Add menu exit
$Menu_Exit = New-Object System.Windows.Forms.MenuItem
$Menu_Exit.Text = "Exit"
$Menu_Click = $Menu_Exit.ADD_CLICK({Exit})
 
# Add all menus as context menus
$Main_Tool_Icon.ContextMenu = New-Object System.Windows.Forms.ContextMenu
$Main_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Users)
$Main_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Computers)
$Main_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Show)
$Main_Tool_Icon.contextMenu.MenuItems.AddRange($Menu_Exit)

Function Exit{
Process{
$Main_Tool_Icon.Dispose()
} 
}
<# Not Working Area

# Make PowerShell Disappear - Thanks Chrissy
#$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
#$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
#$null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)
 
# Use a Garbage colection to reduce Memory RAM
# https://dmitrysotnikov.wordpress.com/2012/02/24/freeing-up-memory-in-powershell-using-garbage-collector/
# https://docs.microsoft.com/fr-fr/dotnet/api/system.gc.collect?view=netframework-4.7.2
#[System.GC]::Collect()
 
# Create an application context for it to all run within - Thanks Chrissy
# This helps with responsiveness, especially when clicking Exit - Thanks Chrissy
#$appContext = New-Object System.Windows.Forms.ApplicationContext
#[void][System.Windows.Forms.Application]::Run($appContext)

#>