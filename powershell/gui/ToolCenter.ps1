#Requires -Version 5.0

<#
.SYNOPSIS
    Nerdfolio Tool Center V3 - WPF Helpdesk GUI

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
$ErrorActionPreference = 'Continue'

# Ensure STA for WPF
if ([Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
    Write-Host "Restarting in STA mode..."
    powershell.exe -STA -ExecutionPolicy Bypass -File $PSCommandPath
    exit
}

# ═══════════════════════════════════════════════════════════
# ASSEMBLIES
# ═══════════════════════════════════════════════════════════
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Speech
[System.Windows.Forms.Application]::EnableVisualStyles()

# ═══════════════════════════════════════════════════════════
# PATHS
# ═══════════════════════════════════════════════════════════
$ScriptRoot    = Split-Path -Parent $MyInvocation.MyCommand.Path
$XamlPath      = Join-Path $ScriptRoot "ToolCenter.xaml"
$FavoritesPath = Join-Path $ScriptRoot "Functions\favorites.json"
$ModulePath    = Join-Path $ScriptRoot "..\modules\HelpdeskTools.psm1"
$SettingsPath = Join-Path $ScriptRoot "settings.json"

# ═══════════════════════════════════════════════════════════
# SAFE MODULE LOADS
# ═══════════════════════════════════════════════════════════
if (Test-Path $ModulePath) {
    try {
        Import-Module $ModulePath -Force
    }
    catch {
        Write-Warning "Failed loading HelpdeskTools module: $_"
    }
}
else {
    Write-Warning "HelpdeskTools module not found: $ModulePath"
}

$Script:ADAvailable = $false
try {
    Import-Module ActiveDirectory -ErrorAction Stop
    $Script:ADAvailable = $true
}
catch {
    Write-Warning "ActiveDirectory module not available - AD functions disabled"
}

# ═══════════════════════════════════════════════════════════
# LOAD XAML SAFELY
# ═══════════════════════════════════════════════════════════
if (-not (Test-Path $XamlPath)) {
    [System.Windows.MessageBox]::Show(
        "ToolCenter.xaml not found:`n$XamlPath",
        "Startup Failure",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Error
    )
    exit
}

try {
    $XamlContent = Get-Content -Path $XamlPath -Raw -Encoding UTF8

    # Strip possible BOM/illegal hidden chars
    $XamlContent = $XamlContent.Trim()

    $XmlDoc = New-Object System.Xml.XmlDocument
    $XmlDoc.LoadXml($XamlContent)

    $Reader = New-Object System.Xml.XmlNodeReader $XmlDoc
    $Window = [System.Windows.Markup.XamlReader]::Load($Reader)
}
catch {
    [System.Windows.MessageBox]::Show(
        "Failed to load UI:`n$_",
        "Tool Center Error",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Error
    )
    exit
}


# ═══════════════════════════════════════════════════════════
# SAFE CONTROL FETCH
# ═══════════════════════════════════════════════════════════
function Get-Control {
    param([string]$Name)

    $ctrl = $Window.FindName($Name)

    if (-not $ctrl) {
        Write-Warning "Missing control in XAML: $Name"
    }

    return $ctrl
}


# ═══════════════════════════════════════════════════════════
# CORE CONTROLS
# ═══════════════════════════════════════════════════════════
$TxtComputerName = Get-Control 'TxtComputerName'
$BtnSearchAD     = Get-Control 'BtnSearchAD'
$StatusDot       = Get-Control 'StatusDot'
$InfoStatusDot   = Get-Control 'InfoStatusDot'
$TxtStatusLabel  = Get-Control 'TxtStatusLabel'
$TxtStatusBar    = Get-Control 'TxtStatusBar'
$TxtActionLog    = Get-Control 'TxtActionLog'
$TxtClock        = Get-Control 'TxtClock'
$FavoritesPanel  = Get-Control 'FavoritesPanel'

# Nav
$NavAD        = Get-Control 'NavAD'
$NavTools     = Get-Control 'NavTools'
$NavFavorites = Get-Control 'NavFavorites'
$NavWeb       = Get-Control 'NavWeb'
$NavSettings  = Get-Control 'NavSettings'

# Panels
$PanelAD        = Get-Control 'PanelAD'
$PanelTools     = Get-Control 'PanelTools'
$PanelFavorites = Get-Control 'PanelFavorites'
$PanelWeb       = Get-Control 'PanelWeb'
$PanelSettings  = Get-Control 'PanelSettings'

# Info
$InfoModel   = Get-Control 'InfoModel'
$InfoUser    = Get-Control 'InfoUser'
$InfoOS      = Get-Control 'InfoOS'
$InfoIP      = Get-Control 'InfoIP'
$InfoMAC     = Get-Control 'InfoMAC'
$InfoSerial  = Get-Control 'InfoSerial'
$InfoUptime  = Get-Control 'InfoUptime'
$InfoTPM     = Get-Control 'InfoTPM'

# Buttons - AD / Tools / Settings / Info
$BtnADUnlock      = Get-Control 'BtnADUnlock'
$BtnPWReset       = Get-Control 'BtnPWReset'
$BtnLogonHours    = Get-Control 'BtnLogonHours'
$BtnADSearch      = Get-Control 'BtnADSearch'
$BtnRemoteAssist  = Get-Control 'BtnRemoteAssist'
$BtnRemoteDesktop = Get-Control 'BtnRemoteDesktop'
$BtnEnableWinRM   = Get-Control 'BtnEnableWinRM'
$BtnRestartPC     = Get-Control 'BtnRestartPC'
$BtnPCInfo        = Get-Control 'BtnPCInfo'
$BtnPrintQueue    = Get-Control 'BtnPrintQueue'
$BtnCompMgmt      = Get-Control 'BtnCompMgmt'
$BtnRegedit       = Get-Control 'BtnRegedit'
$BtnADUC          = Get-Control 'BtnADUC'
$BtnADAC          = Get-Control 'BtnADAC'
$BtnCrowdStrike   = Get-Control 'BtnCrowdStrike'
$BtnBigFix        = Get-Control 'BtnBigFix'
$BtnTPM           = Get-Control 'BtnTPM'
$BtnDotNet        = Get-Control 'BtnDotNet'
$BtnRefreshInfo   = Get-Control 'BtnRefreshInfo'
$BtnCopyIP        = Get-Control 'BtnCopyIP'
$BtnCopyMAC       = Get-Control 'BtnCopyMAC'
$BtnCopySerial    = Get-Control 'BtnCopySerial'
$BtnSaveSettings  = Get-Control 'BtnSaveSettings'

# Web buttons (missing in original)
$BtnTickets       = Get-Control 'BtnTickets'
$BtnAdobeAdmin    = Get-Control 'BtnAdobeAdmin'
$BtnAirwatch      = Get-Control 'BtnAirwatch'
$BtnERPM          = Get-Control 'BtnERPM'

# Settings controls
$TxtSearchBase    = Get-Control 'TxtSearchBase'
$TxtADFilter      = Get-Control 'TxtADFilter'
$ChkTTS           = Get-Control 'ChkTTS'
$ChkBalloon       = Get-Control 'ChkBalloon'
$ChkStartupSound  = Get-Control 'ChkStartupSound'

# ═══════════════════════════════════════════════════════════
# VALIDATE CRITICAL CONTROLS
# ═══════════════════════════════════════════════════════════
$CriticalControls = @(
    'TxtComputerName','BtnSearchAD','StatusDot','InfoStatusDot','TxtStatusLabel',
    'TxtStatusBar','TxtActionLog','TxtClock','FavoritesPanel',
    'NavAD','NavTools','NavFavorites','NavWeb','NavSettings',
    'PanelAD','PanelTools','PanelFavorites','PanelWeb','PanelSettings'
)

foreach ($ctrlName in $CriticalControls) {
    if (-not (Get-Variable -Name $ctrlName -ValueOnly -ErrorAction SilentlyContinue)) {
        Write-Warning "Missing control from XAML: $ctrlName"
    }
}

# ═══════════════════════════════════════════════════════════
# STATE
# ═══════════════════════════════════════════════════════════
$Script:CurrentPC = $null
$Script:TTSEngine = New-Object System.Speech.Synthesis.SpeechSynthesizer
$Script:ActiveNav = 'AD'

# ═══════════════════════════════════════════════════════════
# LOGGING / SPEECH / NOTIFY HELPERS
# ═══════════════════════════════════════════════════════════

function Write-Log {
    param([string]$Message)

    try {
        $Timestamp = Get-Date -Format 'HH:mm:ss'
        $Entry = "[$Timestamp] $Message"

        if ($TxtActionLog) {
            $TxtActionLog.Text = "$Entry`r`n$($TxtActionLog.Text)"
        }

        if ($TxtStatusBar) {
            $TxtStatusBar.Text = $Message
        }
    }
    catch {
        Write-Warning "Write-Log failure: $_"
    }
}

function Invoke-TTS {
    param([string]$Text)

    try {
        if ($ChkTTS -and $ChkTTS.IsChecked -and $Script:TTSEngine) {
            $Script:TTSEngine.SpeakAsyncCancelAll()
            $Script:TTSEngine.SpeakAsync($Text) | Out-Null
        }
    }
    catch {
        Write-Warning "TTS failure: $_"
    }
}

function Show-Balloon {
    param([string]$Title,[string]$Message)

    try {
        if ($ChkBalloon -and $ChkBalloon.IsChecked -and $Script:SysTrayIcon) {
            $Script:SysTrayIcon.BalloonTipTitle = $Title
            $Script:SysTrayIcon.BalloonTipText  = $Message
            $Script:SysTrayIcon.BalloonTipIcon  = [System.Windows.Forms.ToolTipIcon]::Info
            $Script:SysTrayIcon.ShowBalloonTip(2500)
        }
    }
    catch {
        Write-Warning "Balloon notification failure: $_"
    }
}

function Get-TargetPC {
    if (-not $TxtComputerName) { return $null }

    $pc = $TxtComputerName.Text.Trim()

    if ([string]::IsNullOrWhiteSpace($pc)) {
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

function Clear-PCInfo {
    foreach ($field in @($InfoModel,$InfoUser,$InfoOS,$InfoIP,$InfoMAC,$InfoSerial,$InfoUptime,$InfoTPM)) {
        if ($field) { $field.Text = 'N/A' }
    }
}

function Update-ConnectionVisual {
    param(
        [string]$ComputerName,
        [bool]$Online
    )

    try {
        $Color = if ($Online) {
            [System.Windows.Media.Brushes]::Teal
        }
        else {
            [System.Windows.Media.Brushes]::OrangeRed
        }

        if ($StatusDot)      { $StatusDot.Fill = $Color }
        if ($InfoStatusDot)  { $InfoStatusDot.Fill = $Color }
        if ($TxtStatusLabel) { $TxtStatusLabel.Text = "$ComputerName - $(if($Online){'Online'}else{'Offline'})" }
        if ($TxtStatusBar)   { $TxtStatusBar.Text = "$ComputerName is $(if($Online){'online'}else{'offline'})" }
    }
    catch {
        Write-Warning "Connection visual update failed: $_"
    }
}

function Update-ConnectionStatus {
    param([string]$ComputerName)

    try {
        if ($TxtStatusBar)   { $TxtStatusBar.Text = "Checking $ComputerName..." }
        if ($TxtStatusLabel) { $TxtStatusLabel.Text = "Checking..." }

        $Online = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet -ErrorAction SilentlyContinue
        Update-ConnectionVisual -ComputerName $ComputerName -Online $Online

        return $Online
    }
    catch {
        Write-Log "Ping failed for $ComputerName"
        return $false
    }
}

function Switch-Panel {
    param([string]$PanelName)

    foreach ($p in @($PanelAD,$PanelTools,$PanelFavorites,$PanelWeb,$PanelSettings)) {
        if ($p) { $p.Visibility = 'Collapsed' }
    }

    foreach ($n in @($NavAD,$NavTools,$NavFavorites,$NavWeb,$NavSettings)) {
        if ($n) { $n.Tag = '' }
    }

    switch ($PanelName) {
        'AD'       { if($PanelAD){$PanelAD.Visibility='Visible'}; if($NavAD){$NavAD.Tag='Active'} }
        'Tools'    { if($PanelTools){$PanelTools.Visibility='Visible'}; if($NavTools){$NavTools.Tag='Active'} }
        'Favorites'{ if($PanelFavorites){$PanelFavorites.Visibility='Visible'}; if($NavFavorites){$NavFavorites.Tag='Active'} }
        'Web'      { if($PanelWeb){$PanelWeb.Visibility='Visible'}; if($NavWeb){$NavWeb.Tag='Active'} }
        'Settings' { if($PanelSettings){$PanelSettings.Visibility='Visible'}; if($NavSettings){$NavSettings.Tag='Active'} }
    }

    $Script:ActiveNav = $PanelName
}
function Register-Click {
    param(
        [Parameter(Mandatory=$true)]$Control,
        [Parameter(Mandatory=$true)][scriptblock]$Action
    )

    if ($null -ne $Control) {
        $Control.add_Click($Action)
    }
    else {
        Write-Warning "Skipped null control event registration."
    }
}

function Register-TextChanged {
    param(
        [Parameter(Mandatory=$true)]$Control,
        [Parameter(Mandatory=$true)][scriptblock]$Action
    )

    if ($null -ne $Control) {
        $Control.add_TextChanged($Action)
    }
}

function Test-ADAvailable {
    return [bool](Get-Module -Name ActiveDirectory)
}

function Require-AD {
    if (-not (Test-ADAvailable)) {
        [System.Windows.MessageBox]::Show(
            "ActiveDirectory module is not installed on this machine.",
            "AD Module Missing",
            [System.Windows.MessageBoxButton]::OK,
            [System.Windows.MessageBoxImage]::Warning
        )
        return $false
    }
    return $true
}
function Get-CrowdStrikeStatus {
    param([string]$ComputerName)

    try {
        $paths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )

        $result = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            param($paths)

            foreach ($path in $paths) {
                Get-ItemProperty $path -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName -like "*CrowdStrike*" } |
                Select-Object DisplayName, DisplayVersion
            }
        } -ArgumentList (,$paths)

        return $result
    }
    catch {
        Write-Log "CrowdStrike detection failed: $_"
        return $null
    }
}
function Show-PasswordPrompt {
    param([string]$User)

    $inputBox = New-Object System.Windows.Forms.Form
    $inputBox.Text = "Set Password - $User"
    $inputBox.Width = 300
    $inputBox.Height = 140
    $inputBox.StartPosition = "CenterScreen"

    $txt = New-Object System.Windows.Forms.TextBox
    $txt.UseSystemPasswordChar = $true
    $txt.Width = 250
    $txt.Top = 20
    $txt.Left = 20

    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = "OK"
    $btn.Top = 60
    $btn.Left = 20

    $btn.Add_Click({ $inputBox.Tag = $txt.Text; $inputBox.Close() })

    $inputBox.Controls.Add($txt)
    $inputBox.Controls.Add($btn)

    $inputBox.ShowDialog() | Out-Null

    return $inputBox.Tag
}
function Get-RemoteServiceStatus {
    param($ComputerName, $ServiceName)

    try {
        Get-CimInstance Win32_Service -ComputerName $ComputerName |
            Where-Object { $_.Name -eq $ServiceName } |
            Select-Object Name, State
    }
    catch {
        return $null
    }
}
function Load-Settings {
    if (Test-Path $SettingsPath) {
        try {
            return Get-Content $SettingsPath -Raw | ConvertFrom-Json
        }
        catch {
            Write-Log "Settings file corrupted, using defaults"
        }
    }

    return [pscustomobject]@{
        TTS = $true
        Balloon = $true
        StartupSound = $true
        SearchBase = "DC=domain,DC=com"
        ADFilter = "*"
    }
}
function Load-Favorites {
    if (-not (Test-Path $FavoritesPath)) { return }

    try {
        $FavoritesPanel.Children.Clear()

        $Favorites = Get-Content $FavoritesPath -Raw | ConvertFrom-Json

        foreach ($fav in $Favorites) {

            if (-not $fav.Name -or -not $fav.Url) {
                continue
            }

            $btn = New-Object System.Windows.Controls.Button
            $btn.Content = $fav.Name
            $btn.Tag = $fav.Url
            $btn.Style = $Window.Resources['ActionButton']
            $btn.Margin = '0,0,8,8'
            $btn.Width = 200

            $url = $fav.Url
            $name = $fav.Name

            $handler = {
    try {
        Start-Process $url
        Write-Log "Opened favorite: $name"
    }
    catch {
        Write-Log "Failed to open: $url"
    }
}.GetNewClosure()

Register-Click $btn $handler

            $FavoritesPanel.Children.Add($btn) | Out-Null
        }

        Write-Log "Favorites loaded: $($Favorites.Count)"
    }
    catch {
        Write-Log "Favorites load failed: $_"
    }
}
function Invoke-BackgroundJob {
    param(
        [scriptblock]$Script,
        [object[]]$ArgumentList,
        [scriptblock]$OnComplete
    )

    try {
        $result = & $Script @ArgumentList
        if ($OnComplete) {
            & $OnComplete $result
        }
    }
    catch {
        Write-Log "Background job failed: $_"
    }
}

Register-EngineEvent PowerShell.OnScriptException -Action {
    Write-Log "GLOBAL ERROR: $($EventArgs.Exception.Message)"
}

# ═══════════════════════════════════════════════════════════
# MODERN SYSTRAY
# ═══════════════════════════════════════════════════════════
$Script:SysTrayIcon = New-Object System.Windows.Forms.NotifyIcon
$Script:SysTrayIcon.Text    = "Nerdfolio Tool Center"
$Script:SysTrayIcon.Visible = $true

try {
    $ExePath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
    $Script:SysTrayIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($ExePath)
}
catch {}

$SysMenu = New-Object System.Windows.Forms.ContextMenuStrip

$MenuShow = New-Object System.Windows.Forms.ToolStripMenuItem
$MenuShow.Text = "Show Tool Center"
Register-Click $MenuShow {
    $Window.Show()
    $Window.WindowState = 'Normal'
    $Window.Activate()
}

$MenuExit = New-Object System.Windows.Forms.ToolStripMenuItem
$MenuExit.Text = "Exit"
Register-Click $MenuExit {
    try {
        $Script:SysTrayIcon.Visible = $false
        $Script:SysTrayIcon.Dispose()
    } catch {}
    $Window.Close()
}

$SysMenu.Items.Add($MenuShow) | Out-Null
$SysMenu.Items.Add("-") | Out-Null
$SysMenu.Items.Add($MenuExit) | Out-Null

$Script:SysTrayIcon.ContextMenuStrip = $SysMenu

$Script:SysTrayIcon.add_DoubleClick({
    $Window.Show()
    $Window.WindowState = 'Normal'
    $Window.Activate()
})

# ═══════════════════════════════════════════════════════════
# CLOCK TIMER
# ═══════════════════════════════════════════════════════════
$ClockTimer = New-Object System.Windows.Threading.DispatcherTimer
$ClockTimer.Interval = [TimeSpan]::FromSeconds(1)
$ClockTimer.add_Tick({
    if ($TxtClock) {
        $TxtClock.Text = Get-Date -Format 'ddd MMM dd  HH:mm:ss'
    }
})
$ClockTimer.Start()

# ═══════════════════════════════════════════════════════════
# PC NAME - CHANGE HANDLER
# ═══════════════════════════════════════════════════════════
function Update-PCInfo {
    param([string]$ComputerName)

    try {
        Write-Log "Gathering info for $ComputerName"

        $CS  = Get-CimInstance Win32_ComputerSystem -ComputerName $ComputerName -ErrorAction Stop
        $OS  = Get-CimInstance Win32_OperatingSystem -ComputerName $ComputerName -ErrorAction Stop
        $BIO = Get-CimInstance Win32_BIOS -ComputerName $ComputerName -ErrorAction Stop

        $NET = Get-CimInstance Win32_NetworkAdapterConfiguration `
            -ComputerName $ComputerName `
            -Filter "IPEnabled=True" `
            -ErrorAction SilentlyContinue | Select-Object -First 1

        $TPM = Get-CimInstance `
            -Namespace root\CIMV2\Security\MicrosoftTpm `
            -ClassName Win32_Tpm `
            -ComputerName $ComputerName `
            -ErrorAction SilentlyContinue

        $Uptime = (Get-Date) - $OS.LastBootUpTime

        if ($InfoModel) {
            $InfoModel.Text = $CS.Model
        }

        if ($InfoUser) {
            $InfoUser.Text = if ($CS.UserName) { ($CS.UserName -split '\\')[-1] } else { 'None' }
        }

        if ($InfoOS) {
            $InfoOS.Text = $OS.Caption
        }

        if ($InfoIP) {
            $InfoIP.Text = ($NET.IPAddress | Where-Object { $_ -notlike '*:*' } | Select-Object -First 1)
        }

        if ($InfoMAC) {
            $InfoMAC.Text = $NET.MACAddress
        }

        if ($InfoSerial) {
            $InfoSerial.Text = $BIO.SerialNumber
        }

        if ($InfoUptime) {
            $InfoUptime.Text = "$($Uptime.Days)d $($Uptime.Hours)h $($Uptime.Minutes)m"
        }

        if ($InfoTPM) {
            $InfoTPM.Text = if ($TPM) {
                "v$($TPM.SpecVersion.Split(',')[0].Trim())"
            } else {
                'None'
            }
        }

        Write-Log "PC info loaded for $ComputerName"
    }
    catch {
        Clear-PCInfo
        Write-Log "Failed to retrieve PC info for $ComputerName"
    }
}

# ═══════════════════════════════════════════════════════════
# LIVE PC NAME MONITOR (SAFE DEBOUNCE)
# ═══════════════════════════════════════════════════════════
$PingTimer = New-Object System.Windows.Threading.DispatcherTimer
$PingTimer.Interval = [TimeSpan]::FromMilliseconds(900)

$PingTimer.add_Tick({
    $PingTimer.Stop()

    try {
        if (-not $TxtComputerName) { return }

        $pc = $TxtComputerName.Text.Trim()

        if ($pc.Length -lt 3) {
            return
        }

        if ($pc -eq $Script:CurrentPC) {
            return
        }

        $Script:CurrentPC = $pc
        Update-ConnectionStatus -ComputerName $pc
    }
    catch {
        Write-Warning "PingTimer failure: $_"
    }
})

if ($TxtComputerName) {
    Register-TextChanged $TxtComputerName {
    $PingTimer.Stop()
    $PingTimer.Start()
}
}

# ═══════════════════════════════════════════════════════════
# SEARCH AD BUTTON
# ═══════════════════════════════════════════════════════════
Register-Click $BtnSearchAD {
    if (-not (Require-AD)) {return}
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
}

# ═══════════════════════════════════════════════════════════
# NAV EVENTS
# ═══════════════════════════════════════════════════════════
Register-Click $NavAD       { Switch-Panel 'AD' }
Register-Click $NavTools    { Switch-Panel 'Tools' }
Register-Click $NavFavorites{ Switch-Panel 'Favorites' }
Register-Click $NavWeb      { Switch-Panel 'Web' }
Register-Click $NavSettings { Switch-Panel 'Settings' }

# ═══════════════════════════════════════════════════════════
# WEB LINKS PANEL EVENTS
# ═══════════════════════════════════════════════════════════
Register-Click $BtnTickets {
    Write-Log "Opening Ticket System"
    Start-Process "https://helpdesk.yourdomain.com"
}

Register-Click $BtnAdobeAdmin {
    Write-Log "Opening Adobe Admin"
    Start-Process "https://adminconsole.adobe.com"
}

Register-Click $BtnAirwatch {
    Write-Log "Opening Airwatch"
    Start-Process "https://your-airwatch-url.com"
}

Register-Click $BtnERPM {
    Write-Log "Opening ERPM"
    Start-Process "https://your-erpm-url.com"
}

# ═══════════════════════════════════════════════════════════
# AD PANEL EVENTS
# ═══════════════════════════════════════════════════════════
Register-Click $BtnADUnlock {
    if (-not (Require-AD)) {return}
    Write-Log "Running AD Unlock..."
    Invoke-TTS "Running AD Unlock"
    try {
        $LDAPFilter = "(&(&(&(&(objectCategory=person)(objectClass=user)(lockoutTime:1.2.840.113556.1.4.804:=4294967295)))))"
        
        [Array]$LockedOut = Get-ADUser -LDAPFilter $LDAPFilter |
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
}

Register-Click $BtnPWReset {
    if (-not (Require-AD)) { return }

    Write-Log "Password reset started"

    try {
        $users = Get-ADUser -Filter * |
            Select-Object -ExpandProperty SamAccountName |
            Out-GridView -PassThru -Title "Select Users"

        if (-not $users) { return }

        foreach ($user in $users) {

            $newPass = Show-PasswordPrompt -User $user
            if (-not $newPass) { continue }

            Set-ADAccountPassword -Identity $user -Reset -NewPassword (ConvertTo-SecureString $newPass -AsPlainText -Force)

            Write-Log "$user password reset (NOT logged for security)"
            Show-Balloon "Password Reset" "$user updated"
        }
    }
    catch {
        Write-Log "Password reset failed: $_"
    }
}

Register-Click $BtnRemoteAssist {
    Write-Log "Launching Remote Assistance"
    Invoke-TTS "Launching Remote Assistance"
    Invoke-Item "C:\Windows\System32\msra.exe"
}

Register-Click $BtnRemoteDesktop {
    $pc = Get-TargetPC
    if ($pc) {
        Write-Log "Connecting to $pc via RDP"
        Invoke-TTS "Connecting to $pc"
        Start-Process "mstsc.exe" -ArgumentList "/v:$pc"
    }
}

Register-Click $BtnEnableWinRM {
    $pc = Get-TargetPC
    if (-not $pc) { return }

    Write-Log "Enabling WinRM on $pc"

    $psExec = "C:\Tools\PSTools\psexec.exe"
    if (-not (Test-Path $psExec)) {
        Write-Log "PsExec missing"
        return
    }

    $cred = Get-Credential

    $user = $cred.UserName
    $pass = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($cred.Password)
    )

    Start-Process $psExec -ArgumentList "\\$pc -u $user -p $pass -s winrm quickconfig -q" -Wait
}

Register-Click $BtnRestartPC {
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
}

Register-Click $BtnLogonHours {
    Write-Log "Opening VPN Logon Hours script"
    $Script = Join-Path $ScriptRoot "..\ad\Set-VPNLogonHours.ps1"
    if (Test-Path $Script) {
        Start-Process powershell.exe -ArgumentList "-File `"$Script`""
    } else {
        Write-Log "Set-VPNLogonHours.ps1 not found"
    }
}

Register-Click $BtnADSearch {
    if (-not (Require-AD)) {return}
    Write-Log "Searching for computers in AD"
    $SearchBase = $TxtSearchBase.Text.Trim()
    try {
        Get-ADComputer -Filter '*' -SearchBase $SearchBase -SearchScope 2 |
            Select-Object Name, IPv4Address, OperatingSystem |
            Out-GridView -Title "Domain Computers"
    }
    catch { Write-Log "AD search failed: $_" }
}

# ═══════════════════════════════════════════════════════════
# TOOLS PANEL EVENTS
# ═══════════════════════════════════════════════════════════
Register-Click $BtnPCInfo {

    $pc = Get-TargetPC
    if (-not $pc) { return }

    Write-Log "Loading PC info (async)..."

    Invoke-BackgroundJob -Script {
        param($pc)

        Get-CimInstance Win32_ComputerSystem -ComputerName $pc
    } -OnComplete {
        param($result)

        if ($result) {
            Write-Log "Async PC info complete"
        }
    }
}

Register-Click $BtnPrintQueue {
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
}

Register-Click $BtnCompMgmt {
    Write-Log "Opening Computer Management"
    Invoke-Item "C:\Windows\System32\compmgmt.msc"
}

Register-Click $BtnRegedit {
    Write-Log "Opening Registry Editor"
    Invoke-Item "C:\Windows\regedit.exe"
}

Register-Click $BtnADUC {
    Write-Log "Opening ADUC"
    Invoke-Item "C:\Windows\System32\dsa.msc"
}

Register-Click $BtnADAC {
    Write-Log "Opening ADAC"
    Invoke-Item "C:\Windows\System32\dsac.exe"
}

Register-Click $BtnCrowdStrike {
    $pc = Get-TargetPC
    if (-not $pc) { return }

    Write-Log "Checking CrowdStrike on $pc"

    $cs = Get-CrowdStrikeStatus -ComputerName $pc

    if ($cs) {
        Write-Log "CrowdStrike installed: $($cs.DisplayVersion)"
        Show-Balloon "CrowdStrike" "Installed - $($cs.DisplayVersion)"
    }
    else {
        Write-Log "CrowdStrike NOT found on $pc"
        Show-Balloon "CrowdStrike" "Not installed"
    }
}

Register-Click $BtnBigFix {
    $pc = Get-TargetPC
    if (-not $pc) { return }

    $svc = Get-RemoteServiceStatus -ComputerName $pc -ServiceName "BESClient"

    if ($svc) {
        Write-Log "BigFix: $($svc.State)"
        Show-Balloon "BigFix" "$($svc.State)"
    }
    else {
        Write-Log "BigFix not reachable"
    }
}

Register-Click $BtnTPM {
    $pc = Get-TargetPC
    if ($pc) {
        Write-Log "Checking TPM on $pc"
        try {
            $TPM = Get-CimInstance -ComputerName $pc `
                -Namespace root\CIMV2\Security\MicrosoftTpm `
                -ClassName Win32_Tpm -ErrorAction Stop
            Write-Log "TPM on $pc - Enabled: $($TPM.IsEnabled_InitialValue) | v$($TPM.SpecVersion)"
        }
        catch { Write-Log "TPM check failed: $_" }
    }
}

Register-Click $BtnDotNet {
    $pc = Get-TargetPC
    if ($pc) {
        Write-Log "Checking .NET version on $pc"
        try {
            $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $pc)
            $Key = $Reg.OpenSubKey("SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full")
            $Release = $Key.GetValue("Release")
            Write-Log ".NET release key on $pc - $Release"
        }
        catch { Write-Log ".NET check failed: $_" }
    }
}

# ═══════════════════════════════════════════════════════════
# INFO PANEL EVENTS
# ═══════════════════════════════════════════════════════════
Register-Click $BtnRefreshInfo {
    $pc = Get-TargetPC
    if ($pc) { Update-PCInfo -ComputerName $pc }
}

Register-Click $BtnCopyIP {
    if ($InfoIP.Text -ne '-') {
        [System.Windows.Clipboard]::SetText($InfoIP.Text)
        Write-Log "IP copied to clipboard"
    }
}

Register-Click $BtnCopyMAC {
    if ($InfoMAC.Text -ne '-') {
        [System.Windows.Clipboard]::SetText($InfoMAC.Text)
        Write-Log "MAC copied to clipboard"
    }
}

Register-Click $BtnCopySerial {
    if ($InfoSerial.Text -ne '-') {
        [System.Windows.Clipboard]::SetText($InfoSerial.Text)
        Write-Log "Serial copied to clipboard"
    }
}

# ═══════════════════════════════════════════════════════════
# SETTINGS EVENTS
# ═══════════════════════════════════════════════════════════
Register-Click $BtnSaveSettings {
    try {
        $data = [pscustomobject]@{
            TTS          = $ChkTTS.IsChecked
            Balloon      = $ChkBalloon.IsChecked
            StartupSound = $ChkStartupSound.IsChecked
            SearchBase   = $TxtSearchBase.Text
            ADFilter     = $TxtADFilter.Text
        }

        $data | ConvertTo-Json -Depth 3 | Set-Content $SettingsPath -Encoding UTF8

        Write-Log "Settings saved"
        Show-Balloon "Settings" "Saved successfully"
    }
    catch {
        Write-Log "Settings save failed: $_"
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

# Closing - cleanup
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
Load-Favorites
$Settings = Load-Settings

if ($ChkTTS)          { $ChkTTS.IsChecked = $Settings.TTS }
if ($ChkBalloon)      { $ChkBalloon.IsChecked = $Settings.Balloon }
if ($ChkStartupSound)  { $ChkStartupSound.IsChecked = $Settings.StartupSound }
if ($TxtSearchBase)    { $TxtSearchBase.Text = $Settings.SearchBase }
if ($TxtADFilter)      { $TxtADFilter.Text = $Settings.ADFilter }
Show-Balloon "Nerdfolio Tool Center" "Tool Center is running"

Write-Log "Tool Center V3 started"

# ═══════════════════════════════════════════════════════════
# SHOW WINDOW
# ═══════════════════════════════════════════════════════════
$Window.ShowDialog() | Out-Null