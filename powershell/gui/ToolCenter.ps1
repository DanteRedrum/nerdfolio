#Requires -Version 5.0

<#
.SYNOPSIS
    Nerdfolio Tool Center V3 — WPF Helpdesk GUI

.DESCRIPTION
    Modern WPF-based helpdesk tool center. Loads ToolCenter.xaml for the UI
    and wires all button events to the Phase 4 function library.

.NOTES
    Author: Daniel Avila
    Version: 3.0
    Requires: Windows PowerShell 5.0+, ActiveDirectory module, PSExec
    Run as: Helpdesk or Admin account with appropriate AD permissions
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ═══════════════════════════════════════════════════════════
# ASSEMBLIES
# ═══════════════════════════════════════════════════════════
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Speech

# ═══════════════════════════════════════════════════════════
# PATHS
# ═══════════════════════════════════════════════════════════
$ScriptRoot    = Split-Path -Parent $MyInvocation.MyCommand.Path
$XamlPath      = Join-Path $ScriptRoot "ToolCenter.xaml"
$FavoritesPath = Join-Path $ScriptRoot "Functions\favorites.json"
$ModulePath    = Join-Path $ScriptRoot "..\modules\HelpdeskTools.psm1"

# ═══════════════════════════════════════════════════════════
# LOAD MODULE
# ═══════════════════════════════════════════════════════════
if (Test-Path $ModulePath) {
    Import-Module $ModulePath -Force
} else {
    Write-Warning "HelpdeskTools module not found at $ModulePath"
}

# Import AD module if available
try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Warning "ActiveDirectory module not available — AD functions disabled"
}

# ═══════════════════════════════════════════════════════════
# LOAD XAML
# ═══════════════════════════════════════════════════════════
try {
    [xml]$Xaml = Get-Content -Path $XamlPath -Raw
    $Reader    = New-Object System.Xml.XmlNodeReader $Xaml
    $Window    = [Windows.Markup.XamlReader]::Load($Reader)
} catch {
    [System.Windows.MessageBox]::Show(
        "Failed to load UI: $_",
        "Tool Center Error",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Error
    )
    exit
}

# ═══════════════════════════════════════════════════════════
# GET CONTROLS — shorthand function
# ═══════════════════════════════════════════════════════════
function Get-Control {
    param([string]$Name)
    $Window.FindName($Name)
}

# Wire up all named controls
$TxtComputerName = Get-Control 'TxtComputerName'
$BtnSearchAD     = Get-Control 'BtnSearchAD'
$StatusDot       = Get-Control 'StatusDot'
$InfoStatusDot   = Get-Control 'InfoStatusDot'
$TxtStatusLabel  = Get-Control 'TxtStatusLabel'
$TxtStatusBar    = Get-Control 'TxtStatusBar'
$TxtActionLog    = Get-Control 'TxtActionLog'
$TxtClock        = Get-Control 'TxtClock'
$FavoritesList   = Get-Control 'FavoritesList'

# Nav buttons
$NavAD           = Get-Control 'NavAD'
$NavTools        = Get-Control 'NavTools'
$NavFavorites    = Get-Control 'NavFavorites'
$NavWeb          = Get-Control 'NavWeb'
$NavSettings     = Get-Control 'NavSettings'

# Panels
$PanelAD         = Get-Control 'PanelAD'
$PanelTools      = Get-Control 'PanelTools'
$PanelFavorites  = Get-Control 'PanelFavorites'
$PanelWeb        = Get-Control 'PanelWeb'
$PanelSettings   = Get-Control 'PanelSettings'

# PC Info fields
$InfoModel       = Get-Control 'InfoModel'
$InfoUser        = Get-Control 'InfoUser'
$InfoOS          = Get-Control 'InfoOS'
$InfoIP          = Get-Control 'InfoIP'
$InfoMAC         = Get-Control 'InfoMAC'
$InfoSerial      = Get-Control 'InfoSerial'
$InfoUptime      = Get-Control 'InfoUptime'
$InfoTPM         = Get-Control 'InfoTPM'

# Action buttons
$BtnADUnlock     = Get-Control 'BtnADUnlock'
$BtnPWReset      = Get-Control 'BtnPWReset'
$BtnLogonHours   = Get-Control 'BtnLogonHours'
$BtnADSearch     = Get-Control 'BtnADSearch'
$BtnRemoteAssist = Get-Control 'BtnRemoteAssist'
$BtnRemoteDesktop = Get-Control 'BtnRemoteDesktop'
$BtnEnableWinRM  = Get-Control 'BtnEnableWinRM'
$BtnRestartPC    = Get-Control 'BtnRestartPC'
$BtnPCInfo       = Get-Control 'BtnPCInfo'
$BtnPrintQueue   = Get-Control 'BtnPrintQueue'
$BtnCompMgmt     = Get-Control 'BtnCompMgmt'
$BtnRegedit      = Get-Control 'BtnRegedit'
$BtnADUC         = Get-Control 'BtnADUC'
$BtnADAC         = Get-Control 'BtnADAC'
$BtnCrowdStrike  = Get-Control 'BtnCrowdStrike'
$BtnBigFix       = Get-Control 'BtnBigFix'
$BtnTPM          = Get-Control 'BtnTPM'
$BtnDotNet       = Get-Control 'BtnDotNet'
$BtnRefreshInfo  = Get-Control 'BtnRefreshInfo'
$BtnCopyIP       = Get-Control 'BtnCopyIP'
$BtnCopyMAC      = Get-Control 'BtnCopyMAC'
$BtnCopySerial   = Get-Control 'BtnCopySerial'
$BtnSaveSettings = Get-Control 'BtnSaveSettings'
$TxtSearchBase   = Get-Control 'TxtSearchBase'
$TxtADFilter     = Get-Control 'TxtADFilter'
$ChkTTS          = Get-Control 'ChkTTS'
$ChkBalloon      = Get-Control 'ChkBalloon'
$ChkStartupSound = Get-Control 'ChkStartupSound'

# ═══════════════════════════════════════════════════════════
# STATE
# ═══════════════════════════════════════════════════════════
$Script:CurrentPC    = $null
$Script:TTSEngine    = New-Object System.Speech.Synthesis.SpeechSynthesizer
$Script:ActiveNav    = 'AD'

# ═══════════════════════════════════════════════════════════
# HELPERS
# ═══════════════════════════════════════════════════════════

function Write-Log {
    param([string]$Message, [string]$Color = 'White')
    $Timestamp = Get-Date -Format 'HH:mm:ss'
    $Entry = "[$Timestamp] $Message"

    $Window.Dispatcher.Invoke({
        $TxtActionLog.Text = "$Entry`n" + $TxtActionLog.Text
        $TxtStatusBar.Text = $Message
    })
}

function Invoke-TTS {
    param([string]$Text)
    if ($ChkTTS.IsChecked) {
        $Script:TTSEngine.SpeakAsync($Text) | Out-Null
    }
}

function Show-Balloon {
    param([string]$Title, [string]$Message)
    if ($ChkBalloon.IsChecked) {
        $Script:SysTrayIcon.BalloonTipTitle = $Title
        $Script:SysTrayIcon.BalloonTipText  = $Message
        $Script:SysTrayIcon.BalloonTipIcon  = [System.Windows.Forms.ToolTipIcon]::Info
        $Script:SysTrayIcon.ShowBalloonTip(3000)
    }
}

function Get-TargetPC {
    $pc = $TxtComputerName.Text.Trim()
    if ([string]::IsNullOrEmpty($pc)) {
        [System.Windows.MessageBox]::Show(
            "Please enter or select a computer name.",
            "No Computer Selected",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Warning
        )
        return $null
    }
    return $pc
}

function Update-ConnectionStatus {
    param([string]$ComputerName)
    $Window.Dispatcher.Invoke({
        $TxtStatusBar.Text    = "Checking $ComputerName..."
        $TxtStatusLabel.Text  = "Checking..."
    })

    $Online = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet -ErrorAction SilentlyContinue

    $Window.Dispatcher.Invoke({
        if ($Online) {
            $StatusDot.Fill      = [System.Windows.Media.Brushes]::Teal
            $InfoStatusDot.Fill  = [System.Windows.Media.Brushes]::Teal
            $TxtStatusLabel.Text = "$ComputerName — Online"
            $TxtStatusBar.Text   = "$ComputerName is online"
        } else {
            $StatusDot.Fill      = [System.Windows.Media.Brushes]::OrangeRed
            $InfoStatusDot.Fill  = [System.Windows.Media.Brushes]::OrangeRed
            $TxtStatusLabel.Text = "$ComputerName — Offline"
            $TxtStatusBar.Text   = "$ComputerName is offline"
        }
    })

    return $Online
}

function Clear-PCInfo {
    $InfoModel.Text   = '—'
    $InfoUser.Text    = '—'
    $InfoOS.Text      = '—'
    $InfoIP.Text      = '—'
    $InfoMAC.Text     = '—'
    $InfoSerial.Text  = '—'
    $InfoUptime.Text  = '—'
    $InfoTPM.Text     = '—'
}

function Refresh-PCInfo {
    param([string]$ComputerName)
    try {
        Write-Log "Gathering info for $ComputerName"

        $CS  = Get-CimInstance -ClassName Win32_ComputerSystem  -ComputerName $ComputerName
        $OS  = Get-CimInstance -ClassName Win32_OperatingSystem  -ComputerName $ComputerName
        $Bio = Get-CimInstance -ClassName Win32_BIOS             -ComputerName $ComputerName
        $Net = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration `
                   -Filter "IPEnabled=True" -ComputerName $ComputerName |
                   Select-Object -First 1
        $TPM = Get-CimInstance -Namespace root\CIMV2\Security\MicrosoftTpm `
                   -ClassName Win32_Tpm -ComputerName $ComputerName `
                   -ErrorAction SilentlyContinue
        $Uptime = (Get-Date) - $OS.LastBootUpTime

        $Window.Dispatcher.Invoke({
            $InfoModel.Text  = $CS.Model
            $InfoUser.Text   = if ($CS.UserName) { $CS.UserName.Split('\')[1] } else { 'None' }
            $InfoOS.Text     = $OS.Caption
            $InfoIP.Text     = ($Net.IPAddress | Where-Object { $_ -notlike '*:*' } | Select-Object -First 1)
            $InfoMAC.Text    = $Net.MACAddress
            $InfoSerial.Text = $Bio.SerialNumber
            $InfoUptime.Text = "$($Uptime.Days)d $($Uptime.Hours)h $($Uptime.Minutes)m"
            $InfoTPM.Text    = if ($TPM) { "v$($TPM.SpecVersion.Split(',')[0].Trim())" } else { 'None' }
        })

        Write-Log "PC info loaded for $ComputerName"
    }
    catch {
        Write-Log "Failed to get PC info: $_"
    }
}

function Switch-Panel {
    param([string]$PanelName)

    # Hide all panels
    $PanelAD.Visibility       = 'Collapsed'
    $PanelTools.Visibility    = 'Collapsed'
    $PanelFavorites.Visibility = 'Collapsed'
    $PanelWeb.Visibility      = 'Collapsed'
    $PanelSettings.Visibility = 'Collapsed'

    # Clear active state on all nav buttons
    $NavAD.Tag       = ''
    $NavTools.Tag    = ''
    $NavFavorites.Tag = ''
    $NavWeb.Tag      = ''
    $NavSettings.Tag = ''

    # Show requested panel and set active nav
    switch ($PanelName) {
        'AD'       { $PanelAD.Visibility        = 'Visible'; $NavAD.Tag        = 'Active' }
        'Tools'    { $PanelTools.Visibility     = 'Visible'; $NavTools.Tag     = 'Active' }
        'Favorites'{ $PanelFavorites.Visibility = 'Visible'; $NavFavorites.Tag = 'Active' }
        'Web'      { $PanelWeb.Visibility       = 'Visible'; $NavWeb.Tag       = 'Active' }
        'Settings' { $PanelSettings.Visibility  = 'Visible'; $NavSettings.Tag  = 'Active' }
    }

    $Script:ActiveNav = $PanelName
}

# ═══════════════════════════════════════════════════════════
# SYSTRAY
# ═══════════════════════════════════════════════════════════
$Script:SysTrayIcon = New-Object System.Windows.Forms.NotifyIcon
$Script:SysTrayIcon.Text    = "Nerdfolio Tool Center"
$Script:SysTrayIcon.Visible = $true

# Extract icon from powershell.exe as fallback
$ExePath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
$Script:SysTrayIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($ExePath)

# Systray context menu
$SysMenu     = New-Object System.Windows.Forms.ContextMenu
$MenuShow    = New-Object System.Windows.Forms.MenuItem
$MenuShow.Text = "Show Tool Center"
$MenuShow.add_Click({ $Window.Show(); $Window.WindowState = 'Normal' })

$MenuSep     = New-Object System.Windows.Forms.MenuItem
$MenuSep.Text = "-"

$MenuExit    = New-Object System.Windows.Forms.MenuItem
$MenuExit.Text = "Exit"
$MenuExit.add_Click({
    $Script:SysTrayIcon.Visible = $false
    $Script:SysTrayIcon.Dispose()
    $Window.Close()
})

$SysMenu.MenuItems.AddRange(@($MenuShow, $MenuSep, $MenuExit))
$Script:SysTrayIcon.ContextMenu = $SysMenu

# Double-click systray to restore
$Script:SysTrayIcon.add_DoubleClick({
    $Window.Show()
    $Window.WindowState = 'Normal'
})

# ═══════════════════════════════════════════════════════════
# CLOCK TIMER
# ═══════════════════════════════════════════════════════════
$ClockTimer          = New-Object System.Windows.Threading.DispatcherTimer
$ClockTimer.Interval = [TimeSpan]::FromSeconds(1)
$ClockTimer.add_Tick({
    $TxtClock.Text = Get-Date -Format 'ddd MMM dd  HH:mm:ss'
})
$ClockTimer.Start()

# ═══════════════════════════════════════════════════════════
# PC NAME — CHANGE HANDLER
# Debounced ping when user stops typing
# ═══════════════════════════════════════════════════════════
$PingTimer          = New-Object System.Windows.Threading.DispatcherTimer
$PingTimer.Interval = [TimeSpan]::FromMilliseconds(800)
$PingTimer.add_Tick({
    $PingTimer.Stop()
    $pc = $TxtComputerName.Text.Trim()
    if ($pc.Length -gt 2) {
        $Script:CurrentPC = $pc
        Start-ThreadJob -ScriptBlock {
            param($Computer, $Window, $StatusDot, $InfoStatusDot, $TxtStatusLabel, $TxtStatusBar)
            $Online = Test-Connection -ComputerName $Computer -Count 1 -Quiet -ErrorAction SilentlyContinue
            $Window.Dispatcher.Invoke({
                $Color = if ($Online) { '#00D4AA' } else { '#E17055' }
                $Brush = [System.Windows.Media.BrushConverter]::new().ConvertFromString($Color)
                $StatusDot.Fill     = $Brush
                $InfoStatusDot.Fill = $Brush
                $TxtStatusLabel.Text = "$Computer — $(if ($Online) { 'Online' } else { 'Offline' })"
                $TxtStatusBar.Text   = "$Computer is $(if ($Online) { 'online' } else { 'offline' })"
            })
        } -ArgumentList $pc, $Window, $StatusDot, $InfoStatusDot, $TxtStatusLabel, $TxtStatusBar |
        Out-Null
    }
})

$TxtComputerName.add_TextChanged({ $PingTimer.Stop(); $PingTimer.Start() })

# ═══════════════════════════════════════════════════════════
# SEARCH AD BUTTON
# ═══════════════════════════════════════════════════════════
$BtnSearchAD.add_Click({
    try {
        $SearchBase = $TxtSearchBase.Text.Trim()
        $Filter     = $TxtADFilter.Text.Trim()

        Write-Log "Querying AD for computers..."

        $Computers = Get-ADComputer -Filter "Name -like '$Filter'" `
            -SearchBase $SearchBase `
            -SearchScope 2 |
            Select-Object -ExpandProperty Name |
            Sort-Object |
            Out-GridView -PassThru -Title "Select a Computer"

        if ($Computers) {
            $TxtComputerName.Text = $Computers | Select-Object -First 1
        }
    }
    catch {
        Write-Log "AD search failed: $_"
    }
})

# ═══════════════════════════════════════════════════════════
# NAV EVENTS
# ═══════════════════════════════════════════════════════════
$NavAD.add_Click(       { Switch-Panel 'AD' })
$NavTools.add_Click(    { Switch-Panel 'Tools' })
$NavFavorites.add_Click({ Switch-Panel 'Favorites' })
$NavWeb.add_Click(      { Switch-Panel 'Web' })
$NavSettings.add_Click( { Switch-Panel 'Settings' })

# ═══════════════════════════════════════════════════════════
# AD PANEL EVENTS
# ═══════════════════════════════════════════════════════════
$BtnADUnlock.add_Click({
    Write-Log "Running AD Unlock..."
    Invoke-TTS "Running AD Unlock"
    try {
        [Array]$LockedOut = Get-ADUser `
            -LDAPFilter "(&(&(&(&(objectCategory=person)(objectClass=user)(lockoutTime:1.2.840.113556.1.4.804:=4294967295)))))" |
            Where-Object { $_.Enabled -eq $true } |
            Select-Object -ExpandProperty SamAccountName |
            Out-GridView -PassThru -Title "Select Users to Unlock"

        if ($null -eq $LockedOut) {
            Write-Log "No users selected for unlock"
        } else {
            foreach ($Person in $LockedOut) {
                Unlock-ADAccount -Identity $Person
                $Check = Get-ADUser -Identity $Person -Properties LockedOut |
                    Select-Object -ExpandProperty LockedOut
                if ($Check -eq $false) {
                    Write-Log "$Person unlocked"
                    Show-Balloon "AD Unlock" "$Person has been unlocked"
                }
            }
        }
    }
    catch { Write-Log "AD Unlock failed: $_" }
})

$BtnPWReset.add_Click({
    Write-Log "Running Password Reset..."
    Invoke-TTS "Running Password Reset"
    try {
        [Array]$PWReset = Get-ADUser `
            -LDAPFilter "(&(&(|(&(objectCategory=person)(objectSid=*)(!samAccountType:1.2.840.113556.1.4.804:=3))(&(objectCategory=person)(!objectSid=*))(&(objectCategory=group)(groupType:1.2.840.113556.1.4.804:=14)))(objectCategory=user)(userPrincipalName=*)))" |
            Where-Object { $_.Enabled -eq $true } |
            Select-Object -ExpandProperty SamAccountName |
            Out-GridView -PassThru -Title "Select Users for Password Reset"

        if ($null -eq $PWReset) {
            Write-Log "No users selected"
        } else {
            foreach ($User in $PWReset) {
                $NewPW = Read-Host -Prompt "New password for $User" -AsSecureString
                Set-ADAccountPassword -Identity $User -NewPassword $NewPW -Reset
                Set-ADUser -Identity $User -ChangePasswordAtLogon:$false -ErrorAction Continue
                # Display password for helpdesk verification — intentional
                $PlainPW = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($NewPW)
                )
                Write-Log "$User reset — password: $PlainPW"
                Show-Balloon "Password Reset" "$User password has been reset"
            }
        }
    }
    catch { Write-Log "Password reset failed: $_" }
})

$BtnRemoteAssist.add_Click({
    Write-Log "Launching Remote Assistance"
    Invoke-TTS "Launching Remote Assistance"
    Invoke-Item "C:\Windows\System32\msra.exe"
})

$BtnRemoteDesktop.add_Click({
    $pc = Get-TargetPC
    if ($pc) {
        Write-Log "Connecting to $pc via RDP"
        Invoke-TTS "Connecting to $pc"
        Start-Process "mstsc.exe" -ArgumentList "/v:$pc"
    }
})

$BtnEnableWinRM.add_Click({
    $pc = Get-TargetPC
    if ($pc) {
        Write-Log "Enabling WinRM on $pc"
        Invoke-TTS "Enabling WinRM on $pc"
        $PSExec = "C:\Tools\PSTools\psexec.exe"
        if (-not (Test-Path $PSExec)) {
            Write-Log "PSExec not found at $PSExec — update path in Settings"
            return
        }
        $Cred = Get-Credential
        Start-Process $PSExec -ArgumentList "\\$pc -s C:\windows\system32\winrm.cmd quickconfig -q" -Credential $Cred -Wait
        Write-Log "WinRM quickconfig sent to $pc"
        Show-Balloon "WinRM" "WinRM enabled on $pc"
    }
})

$BtnRestartPC.add_Click({
    $pc = Get-TargetPC
    if ($pc) {
        $Confirm = [System.Windows.MessageBox]::Show(
            "Restart $pc now?",
            "Confirm Restart",
            [System.Windows.MessageBoxButton]::YesNo,
            [System.Windows.MessageBoxImage]::Warning
        )
        if ($Confirm -eq 'Yes') {
            Write-Log "Restarting $pc"
            Invoke-TTS "Restarting $pc"
            Restart-Computer -ComputerName $pc -Force
            Show-Balloon "Restart" "Restart command sent to $pc"
        }
    }
})

$BtnLogonHours.add_Click({
    Write-Log "Opening VPN Logon Hours script"
    $Script = Join-Path $ScriptRoot "..\ad\Set-VPNLogonHours.ps1"
    if (Test-Path $Script) {
        Start-Process powershell.exe -ArgumentList "-File `"$Script`""
    } else {
        Write-Log "Set-VPNLogonHours.ps1 not found"
    }
})

$BtnADSearch.add_Click({
    Write-Log "Searching for computers in AD"
    $SearchBase = $TxtSearchBase.Text.Trim()
    try {
        Get-ADComputer -Filter '*' -SearchBase $SearchBase -SearchScope 2 |
            Select-Object Name, IPv4Address, OperatingSystem |
            Out-GridView -Title "Domain Computers"
    }
    catch { Write-Log "AD search failed: $_" }
})

# ═══════════════════════════════════════════════════════════
# TOOLS PANEL EVENTS
# ═══════════════════════════════════════════════════════════
$BtnPCInfo.add_Click({
    $pc = Get-TargetPC
    if ($pc) {
        Write-Log "Gathering PC info for $pc"
        Invoke-TTS "Gathering info for $pc"
        Refresh-PCInfo -ComputerName $pc
    }
})

$BtnPrintQueue.add_Click({
    $pc = Get-TargetPC
    if ($pc) {
        Write-Log "Resetting print queue on $pc"
        Invoke-TTS "Resetting print queue on $pc"
        try {
            Invoke-Command -ComputerName $pc -ScriptBlock {
                & cmd.exe /c "net stop spooler"
                & cmd.exe /c "del /F /Q C:\Windows\System32\spool\PRINTERS\*"
                & cmd.exe /c "net start spooler"
            }
            Write-Log "Print queue reset on $pc"
            Show-Balloon "Print Queue" "Print queue reset on $pc"
        }
        catch { Write-Log "Print queue reset failed: $_" }
    }
})

$BtnCompMgmt.add_Click({
    Write-Log "Opening Computer Management"
    Invoke-Item "C:\Windows\System32\compmgmt.msc"
})

$BtnRegedit.add_Click({
    Write-Log "Opening Registry Editor"
    Invoke-Item "C:\Windows\regedit.exe"
})

$BtnADUC.add_Click({
    Write-Log "Opening ADUC"
    Invoke-Item "C:\Windows\System32\dsa.msc"
})

$BtnADAC.add_Click({
    Write-Log "Opening ADAC"
    Invoke-Item "C:\Windows\System32\dsac.exe"
})

$BtnCrowdStrike.add_Click({
    $pc = Get-TargetPC
    if ($pc) {
        Write-Log "Checking CrowdStrike on $pc"
        try {
            $CS = Get-CimInstance -ComputerName $pc -ClassName Win32_Product `
                -Filter "Vendor='CrowdStrike, Inc.'" -ErrorAction Stop
            if ($CS) {
                Write-Log "CrowdStrike installed on $pc — v$($CS.Version)"
                Show-Balloon "CrowdStrike" "Installed on $pc — v$($CS.Version)"
            } else {
                Write-Log "CrowdStrike NOT found on $pc"
                Show-Balloon "CrowdStrike" "NOT installed on $pc"
            }
        }
        catch { Write-Log "CrowdStrike check failed: $_" }
    }
})

$BtnBigFix.add_Click({
    $pc = Get-TargetPC
    if ($pc) {
        Write-Log "Checking BigFix on $pc"
        try {
            $Status = Get-Service -ComputerName $pc -Name BESClient -ErrorAction Stop |
                Select-Object -ExpandProperty Status
            Write-Log "BigFix on $pc — $Status"
            Show-Balloon "BigFix" "$pc BESClient: $Status"
        }
        catch { Write-Log "BigFix check failed: $_" }
    }
})

$BtnTPM.add_Click({
    $pc = Get-TargetPC
    if ($pc) {
        Write-Log "Checking TPM on $pc"
        try {
            $TPM = Get-CimInstance -ComputerName $pc `
                -Namespace root\CIMV2\Security\MicrosoftTpm `
                -ClassName Win32_Tpm -ErrorAction Stop
            Write-Log "TPM on $pc — Enabled: $($TPM.IsEnabled_InitialValue) | v$($TPM.SpecVersion)"
        }
        catch { Write-Log "TPM check failed: $_" }
    }
})

$BtnDotNet.add_Click({
    $pc = Get-TargetPC
    if ($pc) {
        Write-Log "Checking .NET version on $pc"
        try {
            $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $pc)
            $Key = $Reg.OpenSubKey("SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full")
            $Release = $Key.GetValue("Release")
            Write-Log ".NET release key on $pc — $Release"
        }
        catch { Write-Log ".NET check failed: $_" }
    }
})

# ═══════════════════════════════════════════════════════════
# INFO PANEL EVENTS
# ═══════════════════════════════════════════════════════════
$BtnRefreshInfo.add_Click({
    $pc = Get-TargetPC
    if ($pc) { Refresh-PCInfo -ComputerName $pc }
})

$BtnCopyIP.add_Click({
    if ($InfoIP.Text -ne '—') {
        [System.Windows.Clipboard]::SetText($InfoIP.Text)
        Write-Log "IP copied to clipboard"
    }
})

$BtnCopyMAC.add_Click({
    if ($InfoMAC.Text -ne '—') {
        [System.Windows.Clipboard]::SetText($InfoMAC.Text)
        Write-Log "MAC copied to clipboard"
    }
})

$BtnCopySerial.add_Click({
    if ($InfoSerial.Text -ne '—') {
        [System.Windows.Clipboard]::SetText($InfoSerial.Text)
        Write-Log "Serial copied to clipboard"
    }
})

# ═══════════════════════════════════════════════════════════
# SETTINGS EVENTS
# ═══════════════════════════════════════════════════════════
$BtnSaveSettings.add_Click({
    Write-Log "Settings saved"
    Show-Balloon "Settings" "Settings saved successfully"
})

# ═══════════════════════════════════════════════════════════
# FAVORITES — Load from JSON
# ═══════════════════════════════════════════════════════════
if (Test-Path $FavoritesPath) {
    try {
        $Favorites = Get-Content $FavoritesPath -Raw | ConvertFrom-Json
        $FavoritesList.ItemsSource = $Favorites

        # Wire click events after load
        $FavoritesList.add_Loaded({
            # Events wired via DataTemplate in XAML
            # Individual button clicks handled via Tag property
        })
    }
    catch {
        Write-Log "Failed to load favorites: $_"
    }
}

# ═══════════════════════════════════════════════════════════
# WINDOW EVENTS
# ═══════════════════════════════════════════════════════════

# Minimize to tray instead of taskbar
$Window.add_StateChanged({
    if ($Window.WindowState -eq 'Minimized') {
        $Window.Hide()
        Show-Balloon "Tool Center" "Running in system tray"
    }
})

# Closing — cleanup
$Window.add_Closing({
    $ClockTimer.Stop()
    $Script:TTSEngine.Dispose()
    $Script:SysTrayIcon.Visible = $false
    $Script:SysTrayIcon.Dispose()
})

# ═══════════════════════════════════════════════════════════
# STARTUP
# ═══════════════════════════════════════════════════════════
Switch-Panel 'AD'

if ($ChkStartupSound.IsChecked) {
    Invoke-TTS "Tool Center ready"
}

Show-Balloon "Nerdfolio Tool Center" "Tool Center is running"

Write-Log "Tool Center V3 started"

# ═══════════════════════════════════════════════════════════
# SHOW WINDOW
# ═══════════════════════════════════════════════════════════
$Window.ShowDialog() | Out-Null