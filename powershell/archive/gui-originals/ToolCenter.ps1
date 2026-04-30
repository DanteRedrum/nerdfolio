<#  This Form was Created to Support Helpdesk
.NAME
    Helpdesk Admin Tool Center
#>

#Import Modules and Types for  All Scripts

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

Import-Module ActiveDirectory

[System.Windows.Forms.Application]::EnableVisualStyles()  

#Force AD DC
#$PSDefaultParameterValues.Add("*-AD*:Server","Central1.am.aboc.com")

#Form & Icon
    $ICONS ="C:\Users\DanAv\Downloads\th.ico"
    $Picture = "C:\Users\DanAv\Downloads\th.png"
    $Tool_Center                     = New-Object System.Windows.Forms.Form
    $InitialFormWindowState          = New-Object System.Windows.Forms.FormWindowState
    $Tool_Center                     = New-Object system.Windows.Forms.Form
    $System_Drawing_Size             = New-Object System.Drawing.Size
    $System_Drawing_Size.Width       = 600
    $System_Drawing_Size.Height      = 800
    $Tool_Center.ClientSize          = $System_Drawing_Size
    $Tool_Center.text                = "Tool Center"
    $Tool_Center.BackColor           = "#758cc0"
    $Tool_Center.TopMost             = $false
    $Tool_Center.icon                = $ICONS
    $Tool_Center.name                = "Tool Center"
    $Tool_Center.FormBorderStyle = 'Fixed3D'
    $Tool_Center.DataBindings.DefaultDataSourceUpdateMode = 0
    $InitialFormWindowState = $Tool_Center.WindowState
    $Tool_Center.add_Load($OnLoadForm_StateCorrection)

# Image Box

    $PictureBox1                     = New-Object system.Windows.Forms.PictureBox
    $PictureBox1.width               = 525
    $PictureBox1.height              = 141
    $PictureBox1.location            = New-Object System.Drawing.Point(25,36)
    $PictureBox1.imageLocation       = $Picture
    $PictureBox1.SizeMode            = [System.Windows.Forms.PictureBoxSizeMode]::zoom
    $PictureBox1.Add_Click({
    Start-Process "chrome.exe" "https://abochd.saasit.com"
    })
# Function Start

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

# Remote Assistance
Function Remote-Assistance {
<# 
.Synopsis
Remote Assistance

.Description
Used to Connect to User Pc with user available

.Parameter VariableName
None

.Example
 Remote-Assistance

.Notes
@author Davila other notes

#>

Process 
{
  Invoke-Item -Path "C:\Windows\System32\msra.exe"
 }
    }

# Password Reset
Function Password-Reset {
<# 
.Synopsis
Password Reset

.Description
Reset User Password and change at next logon (yes will remove change at logon)

.Parameter VariableName
None

.Example
 Password-Reset

.Notes
@author Davila other notes

#>

Process 
{
[ARRAY]$PWRESET = Get-ADUser -LDAPFilter "(&(&(|(&(objectCategory=person)(objectSid=*)(!samAccountType:1.2.840.113556.1.4.804:=3))(&(objectCategory=person)(!objectSid=*))(&(objectCategory=group)(groupType:1.2.840.113556.1.4.804:=14)))(objectCategory=user)(userPrincipalName=*)))" | Where-Object {$_.Enabled -EQ $true} | Select-Object -ExpandProperty SamAccountName | Out-GridView -PassThru -Title "PW RESET USERS" 

 if($PWRESET -eq $null){
$USERPW = New-Object -ComObject Wscript.Shell
$USERPW.Popup("No User Selected for PW Reset",0,"PW Reset",0 + 64)
 
}
Else{
 Foreach($UserPass in $PWRESET){
 $NewPassword = (Read-Host -Prompt "Provide New Password" -AsSecureString) 
 $midpass = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($NewPassword)
 $Newpass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($midpass)
 Set-ADAccountPassword -Identity $UserPass -NewPassword $NewPassword -Reset 
 Set-ADUser -Identity $UserPass -ChangePasswordAtLogon:$false -Confirm -ErrorAction Continue

$PWUSER = New-Object -ComObject Wscript.Shell
$PWUSER.Popup("$UserPass password is $NewPass",0,"PW Reset",0 + 64)
}
}

}
}

# Asset Tracker
 Function Asset-Tracker{
 Function SearchAsset{
    $env:tag = Invoke-Command -computername $Script:Choice {Get-ItemProperty -Path "HKLM:\SOFTWARE\Bank" | Select -ExpandProperty Asset_Tag} 
    $AssetTag.AppendText("$env:tag")
    $AssetTag.Refresh() 
    }

    Function Return-MySelection{
    $Script:Choice = $Combo.SelectedItem
    }
    
    Function ClearVar{
    $Combo.SelectedItem = $Combo.Items[0]
    $env:tag = ' '
    $AssetTag.Clear()
    }

    Function CreateAsset{
    [string]$ATag = Read-Host -Prompt "Enter Asset Tag"
   sleep -s 5
   Invoke-Command -ComputerName $Script:Choice {New-Item -Path "HKLM:\SOFTWARE" -name Bank -force}
   sleep -s 5
   Invoke-Command -computername $Script:Choice {
   New-ItemProperty -Path "HKLM:\SOFTWARE\Bank" -Name Asset_Tag -Value $Using:ATag -PropertyType String -Force | Out-Null}
   Write-Host "Tag Created try Search to confirm"
    }

 $Form                = New-Object System.Windows.Forms.Form
 $Form.TopMost        = $true
 $Form.width          = 500
 $Form.height         = 300
 $Form.Text           = ”Asset Tracker”
 $Form.icon           = $ICONS
 $Font                = New-Object System.Drawing.Font("Times New Roman",12)
 $Form.Font           = $Font

# Create a new ComboBox to be used in the form

    $Combo               = new-object System.Windows.Forms.ComboBox
    $Combo.Location      = new-object System.Drawing.Size(130,20)
    $Combo.Size          = new-object System.Drawing.Size(280,40)
    [void] $Combo.Items.Add(" ")
#Populate Combo Box

    $MyDropDownList      = Get-ADComputer -Filter "Name -like 'DW*'" -properties CN -SearchBase 'DC=am,DC=aboc,DC=com' -SearchScope 2 | Sort-Object CN | Select-Object -ExpandProperty CN 
        
        ForEach ($Item in $MyDropDownList) {
        [void] $Combo.Items.Add($Item)
        }
 $Form.Controls.Add($Combo)

#Create Label Box
    $LabelBox                        = new-object System.Windows.Forms.Label
    $LabelBox.Location               = new-object System.Drawing.Size(10,20) 
    $LabelBox.size                   = new-object System.Drawing.Size(100,80) 
    $LabelBox.Text                   = "Select the Computer from the dropdown list"
#Display Label Box
    $Form.Controls.Add($LabelBox)
 
    $AssetTag                        = New-Object System.Windows.Forms.TextBox
    $AssetTag.multiline              = $false
    $AssetTag.text                   = $env:tag
    $AssetTag.width                  = 238
    $AssetTag.height                 = 20
    $AssetTag.location               = New-Object System.Drawing.Point(125,150)
    $AssetTag.Font                   = 'Microsoft Sans Serif,10'
#Display Text Box    
    $Form.Controls.Add($AssetTag)

    $SearchButton                    = New-Object system.Windows.Forms.Button
    $SearchButton.text               = "Search Asset Tag"
    $SearchButton.width              = 140
    $SearchButton.height             = 30
    $SearchButton.location           = New-Object System.Drawing.Point(130,100)
    $SearchButton.Font               = 'Microsoft Sans Serif,10'
    $SearchButton.Add_Click({SearchAsset})
#Display Search Button    
    $Form.Controls.Add($SearchButton)

    $CreateAsset                     = New-Object system.Windows.Forms.Button
    $CreateAsset.text                = "Create Asset Tag"
    $CreateAsset.width               = 119
    $CreateAsset.height              = 30
    $CreateAsset.location            = New-Object System.Drawing.Point(270,100)
    $CreateAsset.Font                = 'Microsoft Sans Serif,10'
    $CreateAsset.Add_Click({CreateAsset})
#Display Create Button    
    $Form.Controls.Add($CreateAsset)

    # Inserting a Select button
    $SelectButton                    = new-object System.Windows.Forms.Button
    $SelectButton.Location           = new-object System.Drawing.Size(130,50)
    $SelectButton.Size               = new-object System.Drawing.Size(100,30)
    $SelectButton.Text               = "Select"
    $SelectButton.Add_Click({Return-MySelection})
    $form.Controls.Add($SelectButton)
 
    # Inserting a Clear button
    $ClearButton                    = new-object System.Windows.Forms.Button
    $ClearButton.Location           = new-object System.Drawing.Size(130,200)
    $ClearButton.Size               = new-object System.Drawing.Size(100,30)
    $ClearButton.Text               = "Clear"
    $ClearButton.Add_Click({ClearVar})
    $form.Controls.Add($ClearButton)
   
    # Inserting a Cancel button
    $CancelButton                    = new-object System.Windows.Forms.Button
    $CancelButton.Location           = new-object System.Drawing.Size(250,50)
    $CancelButton.Size               = new-object System.Drawing.Size(200,30)
    $CancelButton.Text               = "Cancel"
    $CancelButton.Add_Click({$Form.Close()})
    $form.Controls.Add($CancelButton)
 
    $Form.Add_Shown({$Form.Activate()})
    
    [void] $Form.ShowDialog()
    
    }

#Remote Desktop
Function Remote-Desktop($Computername){

Process{

$RemoteWhere =  New-object System.Windows.Forms.Form
$RemoteSize = New-Object System.Drawing.Size
$Remotewhere.TopMost = $true
$RemoteSize.Width = 250
$RemoteSize.Height = 150
$Remotewhere.ClientSize = $RemoteSize
$Remotewhere.text = "Select a PC for Remote Access" 
$Remotewhere.icon = $ICONS
$Remotewhere.name = "Select A PC"

    $RDCombo               = new-object System.Windows.Forms.ComboBox
    $RDCombo.Location      = new-object System.Drawing.Size(25,20)
    $RDCombo.Size          = new-object System.Drawing.Size(200,200)
    [void] $RDCombo.Items.Add("netman2")
    [void] $RDCombo.Items.Add("10.201.42.52")
$RDPC      = Get-ADComputer -Filter "Name -like 'DW*'" -properties CN -SearchBase 'DC=am,DC=aboc,DC=com' -SearchScope 2 | Sort-Object CN | Select-Object -ExpandProperty CN 
        ForEach ($RDCOMP in $RDPC) {
        [void] $RDCombo.Items.Add($RDCOMP)
        }
 $Remotewhere.Controls.Add($RDCombo)
 $OKButton                    = new-object System.Windows.Forms.Button
    $OKButton.Location           = new-object System.Drawing.Size(100,50)
    $OKButton.Size               = new-object System.Drawing.Size(50,50)
    $OKButton.Text               = "OK"
    $OKButton.FlatStyle = "Flat"
    $OKButton.FlatAppearance.BorderColor = "#E4002B"
    $OKButton.FlatAppearance.BorderSize = 2
    $OKButton.Add_Click({
    $Computername = $RDCombo.SelectedItem
    Start-Process "C:\Windows\system32\mstsc.exe" -ArgumentList "/V:$Computername"
    $Remotewhere.Close()})
    $Remotewhere.Controls.Add($OKButton)
[void] $Remotewhere.ShowDialog()

}}

# ADUC
Function ADUC{
Process{
Invoke-Item -path "C:\Windows\system32\dsa.msc"
}}

# ADAC
Function ADAC{
Process{
Invoke-Item -Path "C:\Windows\system32\dsac.exe"
}}

# REGEDIT
Function REGEDIT{
Process{
Invoke-Item -Path "C:\Windows\regedit.exe"
}}

# Computer Management
Function COMPMGMT{
Process{
Invoke-Item -path "C:\windows\system32\compmgmt.msc"
}}

# Print Que
Function PrintQ{
Process{

$Qwindow =  New-object System.Windows.Forms.Form
$QwindowSize = New-Object System.Drawing.Size
$QWindow.TopMost = $true
$QwindowSize.Width = 250
$QwindowSize.Height = 150
$QWindow.ClientSize = $QwindowSize
$Qwindow.text = "Select a PC to Reset PrintQ" 
$Qwindow.icon = $ICONS
$Qwindow.name = "Select A PC"

 $PQCombo               = new-object System.Windows.Forms.ComboBox
    $PQCombo.Location      = new-object System.Drawing.Size(25,20)
    $PQCombo.Size          = new-object System.Drawing.Size(200,200)
    $PQPC      = Get-ADComputer -Filter "Name -like 'DW*'" -properties CN -SearchBase 'DC=am,DC=aboc,DC=com' -SearchScope 2 | Sort-Object CN | Select-Object -ExpandProperty CN 
        ForEach ($PQCOMP in $PQPC) {
        [void] $PQCombo.Items.Add($PQCOMP)
        }
 $QWindow.Controls.Add($PQCombo)
 $OKQButton                    = new-object System.Windows.Forms.Button
    $OKQButton.Location           = new-object System.Drawing.Size(100,50)
    $OKQButton.Size               = new-object System.Drawing.Size(50,50)
    $OKQButton.Text               = "OK"
    $OKQButton.Add_Click({
    $ComputerQ = $PQCombo.SelectedItem
    If($ComputerQ -ne $Null){
$spoolstatus = Get-Service Spooler -computername "$ComputerQ"
Invoke-Command -computername "$ComputerQ" -scriptblock {& cmd.exe /c "net stop spooler"}
Write-host "$spoolstatus"
Sleep -s 5
$spoolstatus = Get-Service Spooler -computername "$ComputerQ"
Invoke-Command -computername "$ComputerQ" -scriptblock {& cmd.exe /c "del /F /Q C:\Windows\System32\spool\PRINTERS\*"}
write-host "$spoolstatus"
Sleep -s 5
Invoke-Command -computername "$ComputerQ" -scriptblock {& cmd.exe /c "net start spooler"}
$spoolstatus = Get-Service Spooler -computername "$ComputerQ"
Write-host "$spoolstatus"
}
Else{
Write-host " no pc selected "
}
    $QWindow.Close()})
    $QWindow.Controls.Add($OKQButton)
[void] $QWindow.ShowDialog()


}}

# Restart Form
Function Restart{
Process{
$RestartForm                     = New-Object system.Windows.Forms.Form
$RestartForm.ClientSize          = '342,157'
$RestartForm.FormBorderStyle     = 'Fixed3D'
$RestartForm.MaximizeBox         = $false
$RestartForm.text                = "Restart PC"
$RestartForm.BackColor           = "#4a90e2"
$RestartForm.TopMost             = $false

$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.width                  = 218
$TextBox1.height                 = 20
$TextBox1.location               = New-Object System.Drawing.Point(49,26)
$TextBox1.Font                   = 'Microsoft Sans Serif,10'

$RestartButton                   = New-Object system.Windows.Forms.Button
$RestartButton.BackColor         = "#d0021b"
$RestartButton.text              = "Restart"
$RestartButton.width             = 60
$RestartButton.height            = 30
$RestartButton.location          = New-Object System.Drawing.Point(121,88)
$RestartButton.Font              = 'Microsoft Sans Serif,10'
$RestartButton.ForeColor         = "#ffffff"

$ComputerLabel                   = New-Object system.Windows.Forms.Label
$ComputerLabel.text              = "Computer Name"
$ComputerLabel.AutoSize          = $true
$ComputerLabel.width             = 25
$ComputerLabel.height            = 10
$ComputerLabel.location          = New-Object System.Drawing.Point(108,53)
$ComputerLabel.Font              = 'Microsoft Sans Serif,10'
$ComputerLabel.ForeColor         = "#ffffff"

$RestartForm.controls.AddRange(@($TextBox1,$RestartButton,$ComputerLabel))

$RestartButton.Add_click({ 
Restart-Computer -ComputerName $cname -force 
$RestartForm.Close()
})

$TextBox1.Add_textchanged({ $cname = $TextBox1.Text})

$RestartForm.ShowDialog()
}}

#Get PC Info
Function PCINFO($Computername){
<#
.Synopsis
Gathers Data on PC.

.Description
Gathers Data based on the Parameters set.

.Parameter VariableName
$ComputerName

.Example
Get-PCINFO -ComputerName XXX

.Notes
@author Davila other notes

#>

$InfoWindow =  New-object System.Windows.Forms.Form
$InfoSize = New-Object System.Drawing.Size
$Infowindow.TopMost = $false
$InfoSize.Width = 250
$InfoSize.Height = 150
$Infowindow.ClientSize = $InfoSize
$Infowindow.text = "Select a PC to Obtain Info" 
$Infowindow.icon = $ICONS
$Infowindow.name = "Select A PC"

    $INFCombo               = new-object System.Windows.Forms.ComboBox
    $INFCombo.Location      = new-object System.Drawing.Size(25,20)
    $INFCombo.Size          = new-object System.Drawing.Size(200,200)  
$InfoPC      = Get-ADComputer -Filter "Name -like 'DW*'" -properties CN -SearchBase 'DC=am,DC=aboc,DC=com' -SearchScope 2 | Sort-Object CN | Select-Object -ExpandProperty CN 
        ForEach ($InfoCOMP in $InfoPC) {
        [void] $INFCombo.Items.Add($InfoCOMP)
        }
 $Infowindow.Controls.Add($INFCombo)
 $OKButton                    = new-object System.Windows.Forms.Button
    $OKButton.Location           = new-object System.Drawing.Size(100,50)
    $OKButton.Size               = new-object System.Drawing.Size(50,50)
    $OKButton.Text               = "OK"
    $OKButton.FlatStyle = "Flat"
    $OKButton.FlatAppearance.BorderColor = "#E4002B"
    $OKButton.FlatAppearance.BorderSize = 2
    $OKButton.Add_Click({
    $Computername = $INFCombo.SelectedItem
        Write-Verbose -Message "$ComputerName"

# Computer System
    $ComputerSystem = Get-WmiObject -Class win32_ComputerSystem -ComputerName $ComputerName

# Operating System
    $OperatingSystem = Get-WmiObject -Class win32_OperatingSystem -ComputerName $ComputerName

# BIOS
    $Bios = Get-WmiObject -Class win32_BIOS -ComputerName $ComputerName

#Product Key
    $PKey = Get-WmiObject -Class softwarelicensingservice -ComputerName $ComputerName  

#TPM 
    $TPM = Get-WmiObject -class Win32_Tpm -namespace root\CIMV2\Security\MicrosoftTpm -computername $ComputerName

#Memory
    $Memory = Get-WmiObject -Class Win32_PhysicalMemory -ComputerName $ComputerName

#Slots
    $Slots = Get-WmiObject -Class win32_physicalmemoryarray -ComputerName $ComputerName

#CPU
    $CPU = Get-WmiObject -Class Win32_Processor -ComputerName $ComputerName

#Network
    $Network = Get-WmiObject -Class Win32_NetworkAdapter -Filter "netconnectionstatus = 2" -ComputerName $ComputerName

#NetConf         
    $NETCONF = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -filter "IPEnabled = True" -ComputerName $ComputerName

# Prepare Output
    Write-Verbose -Message "$ComputerName - Preparing Output"
    $Properties = @{
        ComputerName = $ComputerSystem.Name
        Manufacturer = $ComputerSystem.Manufacturer
        Model = $ComputerSystem.Model
        User = $ComputerSystem.Username
        OperatingSystem = $OperatingSystem.Caption
        OperatingSystemVersion = $OperatingSystem.Version
        OSArchitecture = $OperatingSystem.osarchitecture
        SerialNumber = $Bios.SerialNumber
        ProductKey = $PKey.OA3xOriginalProductKey
        TPMEnabled = $TPM.IsEnabled_InitialValue
        TPMVersion = $TPM.SpecVersion
        MemoryCapacity = $Memory.Capacity
        MemorySpeed = $Memory.Speed
        MemoryUsedSlots = $Memory.DeviceLocator
        RamSlots = $Slots.MemoryDevices
        CPUName = $CPU.Name
        CPUDatawidth = $CPU.Datawidth
        NicName = $Network.Name
        NicMac = $Network.MACAddress
        NetIP = $NETCONF.IPAddress
        IPGateway = $NETCONF.defaultipgateway
        DNS = $NETCONF.DNSDOMAIN
        }
    
# Output Information

    Write-Verbose -Message "$ComputerName - Output Information"
    New-Object -TypeName PSobject -Property $Properties | Out-GridView -PassThru -Title "PC Info"

    $InfoWindow.Close()})
    $Infowindow.Controls.Add($OKButton)
[void] $Infowindow.ShowDialog()
   }

#VPN Logon Hours
Function LogonHours{
Process{
<# This Script was created to automatically adjust logon hours for the Pulse Web Users Group#>
#Sets Logon Hours
[Byte[]]$hours = @(255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255)

#Sets Array for Pulse Web Users Group Members
[Array]$Group = Get-ADGroupMember -Identity "Pulse Web Users" -Recursive | Select-object -ExpandProperty DistinguishedName

<#For Each Member in the Group the action checks the logon hours and adjusts if not equal to the hours set above#>
ForEach ($member in $Group) {
[Byte[]]$hour = get-aduser $member -properties logonhours | select-object -ExpandProperty  logonhours
if (diff $hours $hour) {

<#Below will tell you what member it changed if uncommented#>
"Completed for " + $member

<#comment out the below so you dont make AD Changes#>
$user = [ADSI]"LDAP://$member"
$user.logonhours[0] = $hours
$user.setinfo()
}
}
<# Else { can be used for an action when hours are equal }

Deny all logon
[byte[]]$hours = @(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0) 

Allow logon at all hours
[byte[]]$hours = @(255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255)

 Allow 8am-6pm – 7 days a week
[byte[]]$hours = @(0,255,3,0,255,3,0,255,3,0,255,3,0,255,3,0,255,3,0,255,3)
 #>
 }}

#Applications Installed
Function AppFinder($Computername){
Process{
$AppWindow =  New-object System.Windows.Forms.Form
$AppSize = New-Object System.Drawing.Size
$Appwindow.TopMost = $false
$AppSize.Width = 250
$AppSize.Height = 150
$Appwindow.ClientSize = $AppSize
$Appwindow.text = "Select a PC to Obtain Info" 
$Appwindow.icon = $ICONS
$Appwindow.name = "Select A PC"

    $AppCombo               = new-object System.Windows.Forms.ComboBox
    $AppCombo.Location      = new-object System.Drawing.Size(25,20)
    $AppCombo.Size          = new-object System.Drawing.Size(200,200)  
$AppInfo      = Get-ADComputer -Filter "Name -like 'DW*'" -properties CN -SearchBase 'DC=am,DC=aboc,DC=com' -SearchScope 2 | Sort-Object CN | Select-Object -ExpandProperty CN 
        ForEach ($Apper in $AppInfo) {
        [void] $AppCombo.Items.Add($Apper)
        }
 $Appwindow.Controls.Add($AppCombo)
 $OKButton                    = new-object System.Windows.Forms.Button
    $OKButton.Location           = new-object System.Drawing.Size(100,50)
    $OKButton.Size               = new-object System.Drawing.Size(50,50)
    $OKButton.Text               = "OK"
    $OKButton.FlatStyle = "Flat"
    $OKButton.FlatAppearance.BorderColor = "#E4002B"
    $OKButton.FlatAppearance.BorderSize = 2
    $OKButton.Add_Click({
    $Computername = $AppCombo.SelectedItem
Get-WmiObject -Class win32_product -ComputerName $ComputerName | Select-Object Name,Version | Out-GridView -PassThru -Title "Software Installed"
   $AppWindow.Close()})
    $Appwindow.Controls.Add($OKButton)
[void] $Appwindow.ShowDialog()
   }

}

#Enable WinRM
Function WinRM($Computer){
Process{
$WinRMWindow =  New-object System.Windows.Forms.Form
$WinRMSize = New-Object System.Drawing.Size
$WinRMwindow.TopMost = $false
$WinRMSize.Width = 250
$WinRMSize.Height = 150
$WinRMwindow.ClientSize = $WinRMSize
$WinRMwindow.text = "Select a PC to Enable WinRM" 
$WinRMwindow.icon = $ICONS
$WinRMwindow.name = "Select A PC"

    $WinRMCombo               = new-object System.Windows.Forms.ComboBox
    $WinRMCombo.Location      = new-object System.Drawing.Size(25,20)
    $WinRmCombo.Size          = new-object System.Drawing.Size(200,200)  
$WinRMInfo      = Get-ADComputer -Filter "Name -like 'DW*'" -properties CN -SearchBase 'DC=am,DC=aboc,DC=com' -SearchScope 2 | Sort-Object CN | Select-Object -ExpandProperty CN 
        ForEach ($RMer in $WinRMInfo) {
        [void] $WinRMCombo.Items.Add($RMer)
        }
$WinRMwindow.Controls.Add($WinRMCombo)
 $OKButton                    = new-object System.Windows.Forms.Button
    $OKButton.Location           = new-object System.Drawing.Size(100,50)
    $OKButton.Size               = new-object System.Drawing.Size(50,50)
    $OKButton.Text               = "OK"
    $OKButton.FlatStyle = "Flat"
    $OKButton.FlatAppearance.BorderColor = "#E4002B"
    $OKButton.FlatAppearance.BorderSize = 2
    $OKButton.Add_Click({
    $Computer = $WinRMCombo.SelectedItem
$cred = Get-Credential
ForEach ($comp in $computer ) {
if($cred -eq $null){ "Write-Host Cannot Proceed without Credentials"}
Else{

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
    
    Test-Wsman -ComputerName $comp
   
    Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $comp -Property Model
   }}
   $WinRMWindow.Close()})
    $WinRMwindow.Controls.Add($OKButton)
[void] $WinRMwindow.ShowDialog()
      
}}

# Test Connection
Function Ping($Computer){
Process{
$FormWindow =  New-object System.Windows.Forms.Form
$FormSize = New-Object System.Drawing.Size
$Formwindow.TopMost = $false
$FormSize.Width = 250
$FormSize.Height = 150
$Formwindow.ClientSize = $FormSize
$Formwindow.text = "Select A PC" 
$Formwindow.icon = $ICONS
$Formwindow.name = "Test Connection"
$FormCombo               = new-object System.Windows.Forms.ComboBox
$FormCombo.Location      = new-object System.Drawing.Size(25,20)
$FormCombo.Size          = new-object System.Drawing.Size(200,200)  
$FormInfo      = Get-ADComputer -Filter "Name -like 'DW*'" -properties CN -SearchBase 'DC=am,DC=aboc,DC=com' -SearchScope 2 | Sort-Object CN | Select-Object -ExpandProperty CN 
    ForEach ($Who in $FormInfo) {
    [void] $FormCombo.Items.Add($who)
    }
$Formwindow.Controls.Add($FormCombo)
$OKButton                    = new-object System.Windows.Forms.Button
$OKButton.Location           = new-object System.Drawing.Size(100,50)
$OKButton.Size               = new-object System.Drawing.Size(50,50)
$OKButton.Text               = "OK"
$OKButton.FlatStyle = "Flat"
$OKButton.FlatAppearance.BorderColor = "#E4002B"
$OKButton.FlatAppearance.BorderSize = 2
$OKButton.Add_Click({
$Computer = $FormCombo.SelectedItem
$Output = Test-Connection $Computer
Write-Host "$Output"
$FormWindow.Close()})
$Formwindow.Controls.Add($OKButton)
[void] $Formwindow.ShowDialog()
 }}     

#Putty
Function Putty{
Process{
Invoke-Item -Path "C:\Support Tools\Putty\Putty.exe"
}}

# DSM
Function DSM{
Process{
Invoke-Item "\\hdsm\dsm$\dsmc.exe"
}}

# RightFax
Function RightFax{
Process{
Invoke-Item -path "C:\Program Files (x86)\RightFax\Client\fuw32.exe"
}}

# RightFax EFM
Function EFM{
Process{
Invoke-Item -path "C:\Program Files (x86)\RightFax\Client\efm.exe" 
}}

#Provisioning Console
# Dont forget to add the site to Java and IE Trusted Sites.
#If error still occurs make sure you made those changes on the same account used to open the powershell.
Function ProCon{
Process{
[System.Diagnostics.Process]::Start("iexplore.exe","https://provisor.postoffice.net/provisioningconsole/main.aspx")
}}

#Premier and Director
Function Premier{
Process{
[System.Diagnostics.Process]::Start("iexplore.exe","http://10.46.234.22/NAV_NAV1151/Nav1151.aspx?&Group=252")
}}

# AMI VPI Admin WebLink
Function AMIVPI{
Process{
[System.Diagnostics.Process]::Start("iexplore.exe","https://abc.infinity.com/WealthPortalAdmin/Login/frmLogin.aspx?ReturnUrl=%2fWealthPortalAdmin%2f")
}}

# Adobe Team
Function Adobe{
Process{
Start-Process "chrome.exe" "https://adminconsole.adobe.com/48C9575E5581C62E7F000101@AdobeOrg/overview"
}}

#BAE Admin
Function BAE{
Process{
Start-Process "chrome.exe" "https://cloud.postoffice.net/auth/login"
}}

# Airwatch
Function Airwatch{
Process{
Start-Process "chrome.exe" "https://cn700.awmdm.com/AirWatch/Login?ReturnUrl=%2FAirWatch%2F"
}}

# ERPM
Function ERPM{
Process{
[System.Diagnostics.Process]::Start("iexplore.exe","https://netman2.am.aboc.com/pwcweb/")
}}

# Weblink
Function Weblink{
Process{
Start-Process "chrome.exe" "https://services2.sungard.com/idp/ABCTRPWL/?ClientID=WebLinkAdminUI"
}}

# E-Policy
Function EPOLICY{
Process{
[System.Diagnostics.Process]::Start("iexplore.exe","https://netman2:8443/core/orionSplashScreen.do")
}}

# COTG
Function COTG{
Process{
Start-Process "chrome.exe" "http://myinfo.cotg.com/einfo/Gateway/Login?ReturnUrl=%2feinfo%2f"
}}
# Function End

# Action Buttons Start

# Button for AD Unlock

$AD_Unlock                       = New-Object system.Windows.Forms.Button
$AD_Unlock.BackColor             = "#a59c94"
$AD_Unlock.text                  = "AD Unlock"
$AD_Unlock.width                 = 125
$AD_Unlock.height                = 50
$AD_Unlock.location              = New-Object System.Drawing.Point(55,250)
$AD_Unlock.Font                  = 'Microsoft Sans Serif,10'
$AD_Unlock.FlatStyle = "Flat"
$AD_Unlock.FlatAppearance.BorderColor = "#E4002B"
$AD_Unlock.FlatAppearance.BorderSize = 2
$AD_Unlock.Add_Click({AD-Unlock})

# Button for Remote Assistance

$Remote_Assistance               = New-Object system.Windows.Forms.Button
$Remote_Assistance.BackColor     = "#a59c94"
$Remote_Assistance.text          = "Remote Assistance"
$Remote_Assistance.width         = 125
$Remote_Assistance.height        = 50
$Remote_Assistance.location      = New-Object System.Drawing.Point(55,350)
$Remote_Assistance.Font          = 'Microsoft Sans Serif,10'
$Remote_Assistance.FlatStyle = "Flat"
$Remote_Assistance.FlatAppearance.BorderColor = "#E4002B"
$Remote_Assistance.FlatAppearance.BorderSize = 2
$Remote_Assistance.Add_Click({Remote-Assistance})

# Button for Password Reset

$Password_Reset                       = New-Object system.Windows.Forms.Button
$Password_Reset.BackColor             = "#a59c94"
$Password_Reset.text                  = "Password Reset"
$Password_Reset.width                 = 125
$Password_Reset.height                = 50
$Password_Reset.location              = New-Object System.Drawing.Point(55,300)
$Password_Reset.Font                  = 'Microsoft Sans Serif,10'
$Password_Reset.FlatStyle = "Flat"
$Password_Reset.FlatAppearance.BorderColor = "#E4002B"
$Password_Reset.FlatAppearance.BorderSize = 2
$Password_Reset.Add_Click({Password-Reset})

# Button for Asset Tracker

$Asset_Tracker                       = New-Object system.Windows.Forms.Button
$Asset_Tracker.BackColor             = "#a59c94"
$Asset_Tracker.text                  = "Asset-Tracker"
$Asset_Tracker.width                 = 125
$Asset_Tracker.height                = 50
$Asset_Tracker.location              = New-Object System.Drawing.Point(55,400)
$Asset_Tracker.Font                  = 'Microsoft Sans Serif,10'
$Asset_Tracker.FlatStyle = "Flat"
$Asset_Tracker.FlatAppearance.BorderColor = "#E4002B"
$Asset_Tracker.FlatAppearance.BorderSize = 2
$Asset_Tracker.Add_Click({Asset-Tracker})

#Print Q Button
$PrintQ                              = New-Object System.Windows.Forms.Button
$PrintQ.BackColor                    = "#a59c94"
$PrintQ.text                         = "Reset Print Que *Needs Work*"
$PrintQ.width                        = 125
$PrintQ.Height                       = 50
$PrintQ.Location                     = New-Object System.Drawing.Point(55,450)
$PrintQ.Font                         = 'Microsoft Sans Serif,10'
$PrintQ.FlatStyle = "Flat"
$PrintQ.FlatAppearance.BorderColor = "#E4002B"
$PrintQ.FlatAppearance.BorderSize = 2
$PrintQ.Add_Click({PrintQ})

#Restart Button
$Restart                              = New-Object System.Windows.Forms.Button
$Restart.BackColor                    = "#a59c94"
$Restart.text                         = "Restart PC"
$Restart.width                        = 125
$Restart.Height                       = 50
$Restart.Location                     = New-Object System.Drawing.Point(55,500)
$Restart.Font                         = 'Microsoft Sans Serif,10'
$Restart.FlatStyle = "Flat"
$Restart.FlatAppearance.BorderColor = "#E4002B"
$Restart.FlatAppearance.BorderSize = 2
$Restart.Add_Click({Restart})

#PC Info Button
$PCINF                              = New-Object System.Windows.Forms.Button
$PCINF.BackColor                    = "#a59c94"
$PCINF.text                         = "PC Info"
$PCINF.width                        = 125
$PCINF.Height                       = 50
$PCINF.Location                     = New-Object System.Drawing.Point(55,550)
$PCINF.Font                         = 'Microsoft Sans Serif,10'
$PCINF.FlatStyle = "Flat"
$PCINF.FlatAppearance.BorderColor = "#E4002B"
$PCINF.FlatAppearance.BorderSize = 2
$PCINF.Add_Click({PCINFO})

# Logon Hours
$lhours = New-Object System.Windows.Forms.Button
$lhours.BackColor = "#a59c94"
$lhours.text = "Logon Hours"
$lhours.width = 125
$lhours.height = 50
$lhours.location = New-Object System.Drawing.Point(55,600)
$lhours.Font = 'Microsoft Sans Serif,10'
$lhours.FlatStyle = "Flat"
$lhours.FlatAppearance.BorderColor = "#E4002B"
$lhours.FlatAppearance.BorderSize = 2
$lhours.Add_Click({LogonHours})

# AppFinder
$Finder = New-Object System.Windows.Forms.Button
$Finder.BackColor = "#a59c94"
$Finder.text = "App Finder"
$Finder.width = 125
$Finder.height = 50
$Finder.location = New-Object System.Drawing.Point(55,650)
$Finder.Font = 'Microsoft Sans Serif,10'
$Finder.FlatStyle = "Flat"
$Finder.FlatAppearance.BorderColor = "#E4002B"
$Finder.FlatAppearance.BorderSize = 2
$Finder.Add_Click({AppFinder})

#WinRM Button
$WinRM = New-Object System.Windows.Forms.Button
$WinRM.BackColor = "#a59c94"
$WinRM.Text = "Enable WinRM"
$WinRM.Width = 125
$WinRM.Height = 50
$WinRM.Location = New-Object System.Drawing.Point(55,700)
$WinRM.Font = 'Microsoft Sans Serif,10'
$WinRM.FlatStyle = "Flat"
$WinRM.FlatAppearance.BorderColor = "#E4002B"
$WinRM.FlatAppearance.BorderSize = 2
$WinRM.Add_Click({WinRM})

# Action Button End

# Tool Button Start

#Button for Remote Desktop

$Remote_Desktop                      = New-Object System.Windows.Forms.Button
$Remote_Desktop.BackColor            = "#a59c94"
$Remote_Desktop.text                 = "Remote Desktop"
$Remote_Desktop.width                = 125
$Remote_Desktop.Height               = 50
$Remote_Desktop.location             = New-Object System.Drawing.Point(400,350)
$Remote_Desktop.Font                 = 'Microsoft Sans Serif,10'
$Remote_Desktop.FlatStyle = "Flat"
$Remote_Desktop.FlatAppearance.BorderColor = "#E4002B"
$Remote_Desktop.FlatAppearance.BorderSize = 2
$Remote_Desktop.Add_Click({Remote-Desktop})

# Button for ADUC

$ADUC                       = New-Object system.Windows.Forms.Button
$ADUC.BackColor             = "#a59c94"
$ADUC.text                  = "ADUC"
$ADUC.width                 = 125
$ADUC.height                = 50
$ADUC.location              = New-Object System.Drawing.Point(400,250)
$ADUC.Font                  = 'Microsoft Sans Serif,10'
$ADUC.FlatStyle = "Flat"
$ADUC.FlatAppearance.BorderColor = "#E4002B"
$ADUC.FlatAppearance.BorderSize = 2
$ADUC.Add_Click({ADUC})

# Button for ADAC

$ADAC                       = New-Object system.Windows.Forms.Button
$ADAC.BackColor             = "#a59c94"
$ADAC.text                  = "ADAC"
$ADAC.width                 = 125
$ADAC.height                = 50
$ADAc.location              = New-Object System.Drawing.Point(400,300)
$ADAC.Font                  = 'Microsoft Sans Serif,10'
$ADAC.FlatStyle = "Flat"
$ADAC.FlatAppearance.BorderColor = "#E4002B"
$ADAC.FlatAppearance.BorderSize = 2
$ADAC.Add_Click({ADAC})

# Registry Editor

$REGEDIT                       = New-object system.Windows.Forms.Button
$REGEDIT.BackColor             = "#a59c94"
$REGEDIT.text                  = "Registry Editor"
$REGEDIT.width                 = 125
$REGEDIT.height                = 50
$REGEDIT.location              = New-Object System.Drawing.Point(400,400)
$REGEDIT.Font                  = 'Microsoft Sans Serif,10'
$REGEDIT.FlatStyle = "Flat"
$REGEDIT.FlatAppearance.BorderColor = "#E4002B"
$REGEDIT.FlatAppearance.BorderSize = 2
$REGEDIT.Add_Click({REGEDIT})

# Computer Management
$COMPMGMT                      = New-object system.windows.Forms.Button
$COMPMGMT.BackColor            = "#a59c94"
$COMPMGMT.text                 = "Computer Management"
$COMPMGMT.width                = 125
$COMPMGMT.height               = 50
$COMPMGMT.location             = New-object System.Drawing.Point(400,450)
$COMPMGMT.Font                 = 'Microsoft Sans Serif,10'
$COMPMGMT.FlatStyle = "Flat"
$COMPMGMT.FlatAppearance.BorderColor = "#E4002B"
$COMPMGMT.FlatAppearance.BorderSize = 2
$COMPMGMT.Add_Click({COMPMGMT})

# Ping Button
$Ping = New-Object System.Windows.Forms.Button
$Ping.BackColor = "#a59c94"
$Ping.text = "Ping *Needs Work*"
$Ping.Width = 125
$Ping.Height = 50
$Ping.Location = New-Object System.Drawing.Point(400,500)
$Ping.Font = 'Microsoft Sans Serif,10'
$Ping.FlatStyle = "Flat"
$Ping.FlatAppearance.BorderColor = "#E4002B"
$Ping.FlatAppearance.BorderSize = 2
$Ping.Add_Click({Ping})

#Putty
$Putty = New-Object System.Windows.Forms.Button
$Putty.BackColor = "#a59c94"
$Putty.text = "Putty"
$Putty.Width = 125
$Putty.Height = 50
$Putty.Location = New-Object System.Drawing.Point(400,550)
$Putty.Font = 'Microsoft Sans Serif,10'
$Putty.FlatStyle = "Flat"
$Putty.FlatAppearance.BorderColor = "#E4002B"
$Putty.FlatAppearance.BorderSize = 2
$Putty.Add_Click({Putty})

# DSM
$DSM = New-Object System.Windows.Forms.Button
$DSM.BackColor = "#a59c94"
$DSM.text = "DSM"
$DSM.Width = 125
$DSM.Height = 50
$DSM.Location = New-Object System.Drawing.Point(400,600)
$DSM.Font = 'Microsoft Sans Serif,10'
$DSM.FlatStyle = "Flat"
$DSM.FlatAppearance.BorderColor = "#E4002B"
$DSM.FlatAppearance.BorderSize = 2
$DSM.Add_Click({DSM})

# Right Fax
$RightFax = New-Object System.Windows.Forms.Button
$RightFax.BackColor = "#a59c94"
$RightFax.text = "RightFax *Non Priv*"
$RightFax.Width = 125
$RightFax.Height = 50
$RightFax.Location = New-Object System.Drawing.Point(400,650)
$RightFax.Font = 'Microsoft Sans Serif,10'
$RightFax.FlatStyle = "Flat"
$RightFax.FlatAppearance.BorderColor = "#E4002B"
$RightFax.FlatAppearance.BorderSize = 2
$RightFax.Add_Click({RightFax})

# Right Fax EFM
$EFM = New-Object System.Windows.Forms.Button
$EFM.BackColor = "#a59c94"
$EFM.text = "RightFax EFM *Non Priv*"
$EFM.Width = 125
$EFM.Height = 50
$EFM.Location = New-Object System.Drawing.Point(400,700)
$EFM.Font = 'Microsoft Sans Serif,10'
$EFM.FlatStyle = "Flat"
$EFM.FlatAppearance.BorderColor = "#E4002B"
$EFM.FlatAppearance.BorderSize = 2
$EFM.Add_Click({EFM})
# Tool Button End

#Favorite Buttons
#Provisioning Console
$ProCon = New-Object System.Windows.Forms.Button
$ProCon.BackColor = "#a59c94"
$ProCon.text = "Provisioning Console"
$ProCon.width = 125
$ProCon.Height = 50
$ProCon.Location = New-Object System.Drawing.Point(230,250)
$ProCon.Font = 'Microsoft Sans Serif,10'
$ProCon.FlatStyle = "Flat"
$ProCon.FlatAppearance.BorderColor = "#E4002B"
$ProCon.FlatAppearance.BorderSize = 2
$ProCon.Add_Click({ProCon})

#Premier and Director
$Premier = New-Object System.Windows.Forms.Button
$Premier.BackColor = "#a59c94"
$Premier.text = "Premier and Director"
$Premier.width = 125
$Premier.Height = 50
$Premier.Location = New-Object System.Drawing.Point(230,300)
$Premier.Font = 'Microsoft Sans Serif,10'
$Premier.FlatStyle = "Flat"
$Premier.FlatAppearance.BorderColor = "#E4002B"
$Premier.FlatAppearance.BorderSize = 2
$Premier.Add_Click({Premier})

# AMI VPI Admin Link
$AMIVPI = New-Object System.Windows.Forms.Button
$AMIVPI.BackColor = "#a59c94"
$AMIVPI.text = "AMI VPI Admin"
$AMIVPI.width = 125
$AMIVPI.Height = 50
$AMIVPI.Location = New-Object System.Drawing.Point(230,350)
$AMIVPI.Font = 'Microsoft Sans Serif,10'
$AMIVPI.FlatStyle = "Flat"
$AMIVPI.FlatAppearance.BorderColor = "#E4002B"
$AMIVPI.FlatAppearance.BorderSize = 2
$AMIVPI.Add_Click({AMIVPI})

# Adobe Team Manager
$Adobe = New-Object System.Windows.Forms.Button
$Adobe.BackColor = "#a59c94"
$Adobe.text = "Adobe Team"
$Adobe.width = 125
$Adobe.Height = 50
$Adobe.Location = New-Object System.Drawing.Point(230,400)
$Adobe.Font = 'Microsoft Sans Serif,10'
$Adobe.FlatStyle = "Flat"
$Adobe.FlatAppearance.BorderColor = "#E4002B"
$Adobe.FlatAppearance.BorderSize = 2
$Adobe.Add_Click({ADOBE})

# BAE 
$BAE = New-Object System.Windows.Forms.Button
$BAE.BackColor = "#a59c94"
$BAE.text = "BAE Admin"
$BAE.width = 125
$BAE.Height = 50
$BAE.Location = New-Object System.Drawing.Point(230,450)
$BAE.Font = 'Microsoft Sans Serif,10'
$BAE.FlatStyle = "Flat"
$BAE.FlatAppearance.BorderColor = "#E4002B"
$BAE.FlatAppearance.BorderSize = 2
$BAE.Add_Click({BAE})

# Airwatch
$Airwatch = New-Object System.Windows.Forms.Button
$Airwatch.BackColor = "#a59c94"
$Airwatch.text = "Airwatch"
$Airwatch.width = 125
$Airwatch.Height = 50
$Airwatch.Location = New-Object System.Drawing.Point(230,500)
$Airwatch.Font = 'Microsoft Sans Serif,10'
$Airwatch.FlatStyle = "Flat"
$Airwatch.FlatAppearance.BorderColor = "#E4002B"
$Airwatch.FlatAppearance.BorderSize = 2
$Airwatch.Add_Click({Airwatch})

# ERPM 
$ERPM = New-Object System.Windows.Forms.Button
$ERPM.BackColor = "#a59c94"
$ERPM.text = "ERPM"
$ERPM.width = 125
$ERPM.Height = 50
$ERPM.Location = New-Object System.Drawing.Point(230,550)
$ERPM.Font = 'Microsoft Sans Serif,10'
$ERPM.FlatStyle = "Flat"
$ERPM.FlatAppearance.BorderColor = "#E4002B"
$ERPM.FlatAppearance.BorderSize = 2
$ERPM.Add_Click({ERPM})

# Weblink 
$Weblink = New-Object System.Windows.Forms.Button
$Weblink.BackColor = "#a59c94"
$Weblink.text = "Weblink"
$Weblink.width = 125
$Weblink.Height = 50
$Weblink.Location = New-Object System.Drawing.Point(230,600)
$Weblink.Font = 'Microsoft Sans Serif,10'
$Weblink.FlatStyle = "Flat"
$Weblink.FlatAppearance.BorderColor = "#E4002B"
$Weblink.FlatAppearance.BorderSize = 2
$Weblink.Add_Click({Weblink})

# Epolicy 
$EPOLICY = New-Object System.Windows.Forms.Button
$EPOLICY.BackColor = "#a59c94"
$EPOLICY.text = "E-Policy"
$EPOLICY.width = 125
$EPOLICY.Height = 50
$EPOLICY.Location = New-Object System.Drawing.Point(230,650)
$EPOLICY.Font = 'Microsoft Sans Serif,10'
$EPOLICY.FlatStyle = "Flat"
$EPOLICY.FlatAppearance.BorderColor = "#E4002B"
$EPOLICY.FlatAppearance.BorderSize = 2
$EPOLICY.Add_Click({EPOLICY})

# COTG 
$COTG = New-Object System.Windows.Forms.Button
$COTG.BackColor = "#a59c94"
$COTG.text = "COTG Tickets"
$COTG.width = 125
$COTG.Height = 50
$COTG.Location = New-Object System.Drawing.Point(230,700)
$COTG.Font = 'Microsoft Sans Serif,10'
$COTG.FlatStyle = "Flat"
$COTG.FlatAppearance.BorderColor = "#E4002B"
$COTG.FlatAppearance.BorderSize = 2
$COTG.Add_Click({COTG})
#Favorite Buttons End

#Label Start
$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Actions"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(70,200)
$Label1.Font                     = 'Microsoft Sans Serif,18,style=Bold,Underline'

$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "Tools"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(430,200)
$Label2.Font                     = 'Microsoft Sans Serif,18,style=Bold,Underline'

$Label3                          = New-Object system.Windows.Forms.Label
$Label3.text                     = "Favorites"
$Label3.AutoSize                 = $true
$Label3.width                    = 25
$Label3.height                   = 10
$Label3.location                 = New-Object System.Drawing.Point(230,200)
$Label3.Font                     = 'Microsoft Sans Serif,18,style=Bold,Underline'
#Label End

$Tool_Center.controls.AddRange(@($AD_Unlock,$Remote_Assistance,$Password_Reset,$Asset_Tracker,$PrintQ,$Restart,$PCINF,$lhours,$Finder,$WinRM))
$Tool_Center.Controls.AddRange(@($BAE,$ProCon,$Premier,$AMIVPI,$Adobe))
$Tool_Center.Controls.AddRange(@($PictureBox1,$Label1,$Label2,$Label3))
$Tool_Center.Controls.AddRange(@($Remote_Desktop,$ADAC,$ADUC,$REGEDIT,$COMPMGMT,$Ping,$Putty,$DSM,$RightFax,$EFM))
$Tool_Center.Controls.AddRange(@($Airwatch,$ERPM,$Weblink,$EPOLICY,$COTG))
[void]$Tool_Center.ShowDialog()

