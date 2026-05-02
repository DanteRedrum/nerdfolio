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