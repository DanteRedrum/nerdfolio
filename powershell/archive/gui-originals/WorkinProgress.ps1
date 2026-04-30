#////DEPENDENCIES START///////
# Add assemblies
    [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')    | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName('presentationframework')   | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')          | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName('WindowsFormsIntegration') | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName('System.IO')               | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')   | Out-Null
    [System.Reflection.Assembly]::LoadWithPartialName('System.Speech')           | Out-Null 
    [System.Windows.Forms.Application]::EnableVisualStyles()

# Import Modules
    Import-Module ActiveDirectory

#Voice Variable
    $VoiceEngine = New-Object System.Speech.Synthesis.SpeechSynthesizer
    <#
    #The below commands are to add voice.
    # ASync can continue script while speaking.
    # Sync waits for speaking to finish before continuing.
    # $VoiceEngine.Speak('enter txt or variable')
    # $VoiceEngine.SpeakASync('enter txt or variable')
    #>

# Make PowerShell Disappear - This works but also cant bring it back without relaunching
#$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
#$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
#$null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)
#
#Kinda Breaks it 
# Use a Garbage colection to reduce Memory RAM
# https://dmitrysotnikov.wordpress.com/2012/02/24/freeing-up-memory-in-powershell-using-garbage-collector/
# https://docs.microsoft.com/fr-fr/dotnet/api/system.gc.collect?view=netframework-4.7.2
#[System.GC]::Collect()
#
#Change Below not noticeable.
# Create an application context for it to all run within - Thanks Chrissy
# This helps with responsiveness, especially when clicking Exit - Thanks Chrissy
#$appContext = New-Object System.Windows.Forms.ApplicationContext
#[void][System.Windows.Forms.Application]::Run($appContext)


#////DEPENDENCIES END///////

#////Functions START///////

# AD Unlock
Function AD-Unlock {
<# 
.Synopsis
Unlocks Users

.Description
Finds locked users in AD and Unlocks

.Parameter VariableName
None

.Example
 AD-Unlock

.Notes
@author Davila other notes

#>

Process 
{
  

[ARRAY]$LockedOut = Get-ADUser -LDAPFilter "(&(&(&(&(objectCategory=person)(objectClass=user)(lockoutTime:1.2.840.113556.1.4.804:=4294967295)))))" | Where-Object {$_.Enabled -EQ $true} | Select-Object -ExpandProperty SamAccountName | Out-GridView -PassThru -Title "Locked Out Users" 

if($LockedOut -eq $null){
$nouser = New-Object -ComObject Wscript.Shell
$nouser.Popup("No users to unlock",0,"AD Unlock",0 + 64)
 
}
Else{
Foreach($Person in $LockedOut){

Unlock-ADAccount -Identity $Person

$Check = Get-ADUser -Identity $Person -Properties LockedOut | Select-Object -ExpandProperty Lockedout

If($Check -eq $false){

$unlockeduser = New-Object -ComObject Wscript.Shell
$unlockeduser.Popup("$Person is unlocked",0,"AD Unlock",0 + 64)


}
}
}

    }
    }

# Computer Management
Function COMPMGMT{
Process{
Invoke-Item -path "C:\windows\system32\compmgmt.msc"
}}


#////Functions End///////


#////Form START///////
#Form & Icon
    $ICONS ="C:\Users\DanAv\Downloads\th.ico"
    $Picture = "C:\Users\DanAv\Downloads\th.png"
    $Tool_Center                     = New-Object System.Windows.Forms.Form
    $InitialFormWindowState          = New-Object System.Windows.Forms.FormWindowState
    $System_Drawing_Size             = New-Object System.Drawing.Size
    $System_Drawing_Size.Width       = 600
    $System_Drawing_Size.Height      = 800
    $Tool_Center.ClientSize          = $System_Drawing_Size
    $Tool_Center.text                = "Tool Center"
    $Tool_Center.BackColor           = "#758cc0"
    $Tool_Center.TopMost             = $false
    $Tool_Center.icon                = $ICONS
    $Tool_Center.name                = "Tool Center"
    $Tool_Center.AutoScroll          = $true
    $Tool_Center.AutoSize            = $true
    $Tool_Center.AutoScale           = $true
    $Tool_Center.FormBorderStyle     = 'Sizable'
    $Tool_Center.DataBindings.DefaultDataSourceUpdateMode = 0
    $InitialFormWindowState          = $Tool_Center.WindowState = 0
    $Tool_Center.add_Load($OnLoadForm_StateCorrection)
    $Tool_Center.BringToFront()
    
# Add the systray icon 
    $Main_Tool_Icon = New-Object System.Windows.Forms.NotifyIcon
    $Main_Tool_Icon.Text = "Tool Center"
    $Main_Tool_Icon.Icon = $ICONS
    $Main_Tool_Icon.Visible = $true
    $Main_Tool_Icon.BalloonTipText = " You are now working with the best "
    $Main_Tool_Icon.BalloonTipTitle = " ABOC Helpdesk "
    $Main_Tool_Icon.BalloonTipIcon =  [System.Windows.Forms.ToolTipIcon]::Info
    $Main_Tool_Icon.ShowBalloonTip(1000)
   $VoiceEngine.SpeakAsync('We the best!') | Out-Null
# Systray Menu
    $SysMenu = New-Object System.Windows.Forms.ContextMenu
    $Main_Tool_Icon.ContextMenu = $SysMenu
    
   #Close Tool Center
    $MainMenuExit = New-Object System.Windows.Forms.MenuItem
    $MainMenuExit.Text = "Exit"
    $MainMenuExit.add_click({
      [void]$Tool_Center.Close()
 })
    $Main_Tool_Icon.ContextMenu.MenuItems.AddRange(@($MainMenuExit,$Menu1))
    
    #Systray  Menu 1
    $Menu1 = New-Object System.Windows.Forms.MenuItem
    $Menu1.Text = "Network"
    $Menu1SubMenu1 = $Menu1.MenuItems.Add("AD Unlock")
    $Menu1SubMenu1.add_click({AD-Unlock})

# Header Panel
    $HeaderPanel = New-Object System.Windows.Forms.Panel
    $HeaderPanel.Width = 600
    $HeaderPanel.Height = 200
    $HeaderPanel.BackColor = "DarkBlue"
    $HeaderPanel.AutoScroll = $true
    $HeaderPanel.AutoSize = $true
    $HeaderPanel.BorderStyle = 'none'
    $HeaderPanel.Dock = 'Top'

#Header Panel PictureBox and Secret Menu
   
    # Image Box
    $PictureBox1 = New-Object system.Windows.Forms.PictureBox
    $PictureBox1.Width = 200
    $PictureBox1.Height = 100
    $PictureBox1.imageLocation       = $Picture
    $PictureBox1.SizeMode            = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
    $PictureBox1.BorderStyle         = 'None'
    $PictureBox1.Location = $HeaderPanel.Location
    $PictureBox1.Dock = "Top"
    $PictureBox1.Add_Click({
        Switch($SecretMenu.Visible){ 
            "$true"{$SecretMenu.Hide()}
            "$false"{$SecretMenu.Show()}
            }
    })

# SideBar
    $SideBar = New-Object System.Windows.Forms.Panel
    $SideBar.Width = 200
    $SideBar.Height = 600
    $SideBar.BackColor= "LightBlue"
    $SideBar.AutoScroll = $true
    $SideBar.AutoSize = $true
    $SideBar.BorderStyle = 'none'
    $SideBar.Dock = 'left'
    $SideBar.Visible = $true
    
    #Table to hold buttons inside Sidebar Panel
    $Tablelayout = New-Object System.Windows.Forms.TableLayoutPanel
    $Tablelayout.AutoSize = $true
    $Tablelayout.AutoSizeMode = "GrowandShrink"
    $Tablelayout.ColumnCount = 1
    $Tablelayout.ColumnStyles
    $Tablelayout.Dock = "left"
    $Tablelayout.RowCount = 5
    $Tablelayout.TabIndex = 1
    $Tablelayout.AutoScroll = $true


    #SideBar Items
    #Button1
    $SBOption1 = New-Object System.Windows.Forms.Button
    $SBOption1.BackColor = " Blue"
    $SBOption1.Text = "Network"
    $SBOption1.Size = "100,50"
    $SBOption1.ForeColor = "White"
    
    $SBOption1.add_click({
   Switch($Panel3.Visible){ 
            "$true"{ $Panel3.Hide()}
            "$false"{$Panel3.Show()}
            }
            Switch($Panel4.Visible){
            "$true"{$Panel4.Hide()}
            }
                Switch($Panel5.Visible){
                "$true"{$Panel5.Hide()}
                }
                
    })

    #Button2
    $SBOption2 = New-Object System.Windows.Forms.Button
    $SBOption2.BackColor = "Blue"
    $SBOption2.ForeColor = "White"
    $SBOption2.Text = "Favorites"
    $SBOption2.Size = "100,50"
    
      $SBOption2.add_click({
   Switch($Panel4.Visible){ 
            "$true"{$Panel4.Hide()}
            "$false"{$Panel4.Show()}
            }
            Switch($Panel3.Visible){
            "$true"{$Panel3.hide()}
            }
            Switch($Panel5.Visible){
            "$true"{$Panel5.hide()}
            }
    })

    #Button3
    $SBOption3 = New-Object System.Windows.Forms.Button
    $SBOption3.BackColor = "Blue"
    $SBOption3.ForeColor = "White"
    $SBOption3.Text = "Helpdesk"
    $SBOption3.Size = "100,50"

      $SBOption3.add_click({
   Switch($Panel5.Visible){ 
            "$true"{$Panel5.Hide()}
            "$false"{$Panel5.Show()}
            }
            Switch($Panel3.Visible){
            "$true"{$Panel3.hide()}
            }
            Switch($Panel4.Visible){
            "$true"{$Panel4.hide()}
            }
            
    })




#Panel3 Buttons
$Button1 = New-Object System.Windows.Forms.Button
$Button1.Text = "AD Unlock"
$Button1.Visible = $true
$button1.Dock = 'Top'
$button1.Add_Click({COMPMGMT})
$Button2 = New-Object System.Windows.Forms.Button
$Button2.Text = "Next One"
$Button2.Visible = $true
$button2.Dock = 'Right'

#Panel 3 - Connected to Button 1
 $Panel3 = New-Object System.Windows.Forms.Panel
 $Panel3.BackColor = "Red"
 $Panel3.Dock = 'fill'
 $Panel3.Visible = $False
 $Panel3.Controls.AddRange(@($Button1,$Button2))
 

#Panel 4 -Connected to Button2
 $Panel4 = New-Object System.Windows.Forms.Panel
 $Panel4.BackColor = "Orange"
 $Panel4.Dock = 'fill'
 $Panel4.Visible = $False
        
#Panel 5 - Connected to Button3
 $Panel5 = New-Object System.Windows.Forms.Panel
 $Panel5.BackColor = "Green"
 $Panel5.Dock = 'fill'
 $Panel5.Visible = $False

#Secret Menu
    $SecretMenu = New-Object System.Windows.Forms.Panel
    $SecretMenu.BackColor = 'Black'
    $SecretMenu.Dock = 'fill'
    $SecretMenu.Visible = $false

#Secret Menu Items


#Load Items into Form
$Tool_Center.Controls.AddRange(@($SideBar,<#$HeaderPanel,#>$SecretMenu,$Panel3,$Panel4,$Panel5))
$HeaderPanel.Controls.AddRange(@($PictureBox1))
$SideBar.Controls.add($Tablelayout)
$Tablelayout.Controls.addrange(@($SBOption1,$SBOption2,$SBOption3))


#Load Form and Close Properly
[void]$Tool_Center.ShowDialog()
[void]$Main_Tool_Icon.dispose()

#////Form End///////


<#
              _
             | |
             | |===( )   //////
             |_|   |||  | o o|
                    ||| ( c  )                  ____
                     ||| \= /                  ||   \_
                      ||||||                   ||     |
                      ||||||                ...||__/|-"
                      ||||||             __|________|__
                        |||             |______________|
                        |||             || ||      || ||
                        |||             || ||      || ||
------------------------|||-------------||-||------||-||-------
                        |__>            || ||      || ||


     hit any key to continue

#>