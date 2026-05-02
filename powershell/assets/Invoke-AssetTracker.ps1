#Requires -Version 5.0
#Requires -Modules ActiveDirectory

<#
.SYNOPSIS
    GUI tool for reading and writing asset tags stored in remote registry.

.DESCRIPTION
    Queries Active Directory for computers, allows selection via dropdown,
    then reads or writes an asset tag value stored in the remote registry.
    Registry path and key name are configurable via parameters.

.PARAMETER ADFilter
    Filter for AD computer query. Example: "DESKTOP-*" or "*"
    Defaults to "*"

.PARAMETER SearchBase
    AD SearchBase DN. Example: "DC=domain,DC=com"

.PARAMETER RegistryPath
    Remote registry path for asset tag storage.
    Defaults to "HKLM:\SOFTWARE\AssetManagement"

.PARAMETER RegistryKey
    Registry value name for the asset tag.
    Defaults to "AssetTag"

.EXAMPLE
    .\Invoke-AssetTracker.ps1 -SearchBase "DC=domain,DC=com"
    .\Invoke-AssetTracker.ps1 -SearchBase "DC=domain,DC=com" -ADFilter "DESKTOP-*"

.NOTES
    Author: Daniel Avila
    Refactored for Nerdfolio - Phase 4
    Original: AssetTracker.ps1
    Changes: Removed hardcoded AD filter, domain, and registry path.
             Added parameters, error handling, approved function names.
             Fixed button/function name collision on CreateAsset.
             Removed unnecessary Sleep calls.
#>

param(
    [string]$ADFilter    = "*",
    [string]$SearchBase,
    [string]$RegistryPath = "HKLM:\SOFTWARE\AssetManagement",
    [string]$RegistryKey  = "AssetTag"
)

Import-Module ActiveDirectory
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# ─── State ────────────────────────────────────────────────
$Script:SelectedComputer = $null

# ─── Functions ────────────────────────────────────────────
function Get-AssetTag {
    if (-not $Script:SelectedComputer) {
        [System.Windows.Forms.MessageBox]::Show(
            "Please select a computer first.",
            "No Computer Selected",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        return
    }

    try {
        $tag = Invoke-Command -ComputerName $Script:SelectedComputer -ScriptBlock {
            param($Path, $Key)
            $prop = Get-ItemProperty -Path $Path -Name $Key -ErrorAction Stop
            $prop.$Key
        } -ArgumentList $RegistryPath, $RegistryKey -ErrorAction Stop

        $TxtAssetTag.Clear()
        $TxtAssetTag.AppendText($tag)
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Asset tag not found on $($Script:SelectedComputer).`nUse 'Create Tag' to add one.",
            "Not Found",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
        $TxtAssetTag.Clear()
    }
}

function New-AssetTag {
    if (-not $Script:SelectedComputer) {
        [System.Windows.Forms.MessageBox]::Show(
            "Please select a computer first.",
            "No Computer Selected",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        return
    }

    $ATag = [Microsoft.VisualBasic.Interaction]::InputBox(
        "Enter Asset Tag for $($Script:SelectedComputer):",
        "Create Asset Tag",
        ""
    )

    if ([string]::IsNullOrWhiteSpace($ATag)) { return }

    try {
        Invoke-Command -ComputerName $Script:SelectedComputer -ScriptBlock {
            param($Path, $Key, $Value)
            if (-not (Test-Path $Path)) {
                New-Item -Path $Path -Force | Out-Null
            }
            New-ItemProperty -Path $Path -Name $Key -Value $Value `
                -PropertyType String -Force | Out-Null
        } -ArgumentList $RegistryPath, $RegistryKey, $ATag -ErrorAction Stop

        [System.Windows.Forms.MessageBox]::Show(
            "Asset tag '$ATag' created on $($Script:SelectedComputer).`nClick Search to verify.",
            "Tag Created",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Failed to create asset tag: $_",
            "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
}

function Select-Computer {
    $Script:SelectedComputer = $Combo.SelectedItem
    $LblStatus.Text = "Selected: $($Script:SelectedComputer)"
}

function Clear-Form {
    $Combo.SelectedIndex = 0
    $Script:SelectedComputer = $null
    $TxtAssetTag.Clear()
    $LblStatus.Text = "No computer selected"
}

# ─── Form ─────────────────────────────────────────────────
$Form                = New-Object System.Windows.Forms.Form
$Form.Text           = "Asset Tracker"
$Form.Width          = 520
$Form.Height         = 320
$Form.TopMost        = $true
$Form.StartPosition  = "CenterScreen"
$Form.Font           = New-Object System.Drawing.Font("Segoe UI", 10)
$Form.BackColor      = [System.Drawing.Color]::FromArgb(30, 30, 46)
$Form.ForeColor      = [System.Drawing.Color]::White

# Label
$LblComputer         = New-Object System.Windows.Forms.Label
$LblComputer.Text    = "Select Computer:"
$LblComputer.Location = New-Object System.Drawing.Point(20, 20)
$LblComputer.Size    = New-Object System.Drawing.Size(120, 24)
$Form.Controls.Add($LblComputer)

# Combo
$Combo               = New-Object System.Windows.Forms.ComboBox
$Combo.Location      = New-Object System.Drawing.Size(145, 18)
$Combo.Size          = New-Object System.Drawing.Size(260, 28)
$Combo.DropDownStyle = 'DropDownList'
[void]$Combo.Items.Add("-- Select --")

try {
    $QueryParams = @{
        Filter      = "Name -like '$ADFilter'"
        Properties  = 'CN'
        SearchScope = 2
    }
    if ($SearchBase) { $QueryParams.SearchBase = $SearchBase }

    $Computers = Get-ADComputer @QueryParams |
        Sort-Object CN |
        Select-Object -ExpandProperty CN

    foreach ($pc in $Computers) {
        [void]$Combo.Items.Add($pc)
    }
}
catch {
    [System.Windows.Forms.MessageBox]::Show(
        "Failed to query AD: $_",
        "AD Error",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
}

$Combo.SelectedIndex = 0
$Form.Controls.Add($Combo)

# Select Button
$BtnSelect           = New-Object System.Windows.Forms.Button
$BtnSelect.Text      = "Select"
$BtnSelect.Location  = New-Object System.Drawing.Size(415, 16)
$BtnSelect.Size      = New-Object System.Drawing.Size(80, 28)
$BtnSelect.Add_Click({ Select-Computer })
$Form.Controls.Add($BtnSelect)

# Status Label
$LblStatus           = New-Object System.Windows.Forms.Label
$LblStatus.Text      = "No computer selected"
$LblStatus.Location  = New-Object System.Drawing.Point(20, 58)
$LblStatus.Size      = New-Object System.Drawing.Size(460, 20)
$LblStatus.ForeColor = [System.Drawing.Color]::FromArgb(160, 160, 192)
$Form.Controls.Add($LblStatus)

# Search / Create Buttons
$BtnSearch           = New-Object System.Windows.Forms.Button
$BtnSearch.Text      = "Search Asset Tag"
$BtnSearch.Location  = New-Object System.Drawing.Point(20, 90)
$BtnSearch.Size      = New-Object System.Drawing.Size(150, 32)
$BtnSearch.Add_Click({ Get-AssetTag })
$Form.Controls.Add($BtnSearch)

$BtnCreate           = New-Object System.Windows.Forms.Button
$BtnCreate.Text      = "Create Asset Tag"
$BtnCreate.Location  = New-Object System.Drawing.Point(180, 90)
$BtnCreate.Size      = New-Object System.Drawing.Size(150, 32)
$BtnCreate.Add_Click({ New-AssetTag })
$Form.Controls.Add($BtnCreate)

# Asset Tag label and textbox
$LblTag              = New-Object System.Windows.Forms.Label
$LblTag.Text         = "Asset Tag:"
$LblTag.Location     = New-Object System.Drawing.Point(20, 145)
$LblTag.Size         = New-Object System.Drawing.Size(100, 24)
$Form.Controls.Add($LblTag)

$TxtAssetTag         = New-Object System.Windows.Forms.TextBox
$TxtAssetTag.Location = New-Object System.Drawing.Point(125, 143)
$TxtAssetTag.Size    = New-Object System.Drawing.Size(260, 28)
$TxtAssetTag.ReadOnly = $true
$TxtAssetTag.BackColor = [System.Drawing.Color]::FromArgb(42, 42, 62)
$TxtAssetTag.ForeColor = [System.Drawing.Color]::White
$Form.Controls.Add($TxtAssetTag)

# Clear / Cancel Buttons
$BtnClear            = New-Object System.Windows.Forms.Button
$BtnClear.Text       = "Clear"
$BtnClear.Location   = New-Object System.Drawing.Point(20, 200)
$BtnClear.Size       = New-Object System.Drawing.Size(100, 32)
$BtnClear.Add_Click({ Clear-Form })
$Form.Controls.Add($BtnClear)

$BtnCancel           = New-Object System.Windows.Forms.Button
$BtnCancel.Text      = "Close"
$BtnCancel.Location  = New-Object System.Drawing.Point(395, 200)
$BtnCancel.Size      = New-Object System.Drawing.Size(100, 32)
$BtnCancel.Add_Click({ $Form.Close() })
$Form.Controls.Add($BtnCancel)

# ─── Registry Path Info ───────────────────────────────────
$LblInfo             = New-Object System.Windows.Forms.Label
$LblInfo.Text        = "Registry: $RegistryPath\$RegistryKey"
$LblInfo.Location    = New-Object System.Drawing.Point(20, 248)
$LblInfo.Size        = New-Object System.Drawing.Size(460, 18)
$LblInfo.ForeColor   = [System.Drawing.Color]::FromArgb(100, 100, 120)
$LblInfo.Font        = New-Object System.Drawing.Font("Segoe UI", 8)
$Form.Controls.Add($LblInfo)

$Form.Add_Shown({ $Form.Activate() })
[void]$Form.ShowDialog()