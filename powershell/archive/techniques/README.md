# Techniques Archive

Scripts preserved for their technique value rather than direct reuse.
Each demonstrates a concept that informed later, cleaner implementations.

## TokenPriv.ps1
**Technique: P/Invoke and Windows token privilege manipulation**

Demonstrates how to call Windows API functions directly from PowerShell
using Add-Type with C# P/Invoke declarations. Adjusts token privileges
(SeDebugPrivilege, SeBackupPrivilege, etc.) on a running process.

This is low-level Windows security work — understanding token privileges
is foundational to understanding how privilege escalation works.

The C# struct definition, DllImport attributes, and AdjustTokenPrivileges
call pattern are reference material for any future work involving
Windows security APIs from PowerShell.

## Test_Calling_Csharp.ps1
**Technique: Inline C# compilation in PowerShell**

Shows how to define and compile C# code at runtime using Add-Type
with -Language CSharpVersion3. The compiled type is immediately
available in the PowerShell session.

This technique powers the WPF GUI approach — Add-Type is how
PresentationFramework and other .NET assemblies get loaded.
Understanding it at this level explains why WPF works the way it does
in PowerShell.

## BigFixRepair.ps1
**Technique: PSExec fleet management pattern**

Demonstrates the PSExec bootstrap pattern for reaching machines that
don't have WinRM enabled. The sequence — quickconfig, PSRemoting,
execution policy, then the actual operation — became the template
for Enable-WinRM.ps1 and Invoke-RemotePatch.ps1 in Phase 4.

Preserved to show the evolution from hardcoded fleet operations
to the parameterized, reusable versions in the deployment category.

## WPF-FormTest.ps1
**Technique: Full WPF application in PowerShell**

A complete WPF message box implementation with dynamic parameters,
XAML loading, custom button styles, animations, and a media player.
This was the exploration that directly led to Tool Center V3.

The New-WPFMessageBox function demonstrates:
- Dynamic parameters via DynamicParam
- Runtime XAML construction via XamlReader
- DropShadowEffect animations
- MediaElement integration
- DispatcherTimer for timeouts

## Remote User Message (Balloon_Message.ps1 + Cant_push_remote.ps1)
**Technique: Pushing messages to remote user desktops**

Two scripts that document the problem-solving process around sending
a popup message to a user's desktop and getting a button response.

The dead end: WScript.Shell Popup runs on the local machine only.
Passing the result via Invoke-Command doesn't push the popup to
the remote user's session.

The working technique buried in the comments:
    Invoke-WmiMethod -Path Win32_Process -Name Create
        -ArgumentList "msg * $message" -ComputerName $computer

`msg *` sends a message to all sessions on the remote machine.
This requires the Messenger service or msg.exe to be available.

The NotifyIcon balloon approach (also in Balloon_Message.ps1) only
works locally — you can't push a NotifyIcon to a remote session.

These scripts document the exploration honestly. The limitation
they ran into is real and worth understanding.

## Start of Day Automation (Startofday.ps1)
**Technique: Credential-based elevated process launch**

Personal start-of-day script that opens Chrome, Outlook, and
launches dsac.exe (AD Administrative Center) with elevated credentials
without maintaining a persistent elevated session.

Key technique:
    Start-Process "cmd.exe" -Credential $AdminCred -ArgumentList "/c dsac.exe"

This pattern — Get-Credential once, pass to Start-Process — is how
you launch specific tools with alternate credentials without running
your entire session elevated. The cmd.exe wrapper is needed because
dsac.exe can't be launched directly with -Credential.

The Get-Process | Stop-Process cleanup removes the cmd.exe window
after dsac.exe launches as its own process.

## Form All Events (Form_All_Events.ps1)
**Reference: Complete WinForms event listing**

Not a runnable script — a reference document listing every available
event for every WinForms control type used in the original Tool Center.

Control events documented:
- Button, Form, PictureBox, TextBox, Label
- CheckBox, ComboBox, ListView, RadioButton
- Panel, GroupBox, MaskedTextBox, ProgressBar, DataGridView

Use this when building WinForms GUIs and you need to know what events
are available on a given control. The pattern is:
    $Control.Add_EventName({ ... })

This predates the WPF rewrite. WPF uses a different event model
but the exploration documented here is part of the learning path
that led to Tool Center V3.