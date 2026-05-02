# Phase 4 Complete

## What Was Built

A proper home for 15+ years of PowerShell work. Scripts audited,
cleaned, documented, and organized. Hardcoded values removed.
Bugs fixed. Techniques preserved. The Tool Center rebuilt from scratch.

## Directory Structure
powershell/
    modules/      HelpdeskTools.psm1 — reusable function library
    ad/           Active Directory management
    assets/       Asset tag tracking
    compliance/   Endpoint compliance checking
    deployment/   Software and patch deployment
    pcinfo/       Hardware and system information
    network/      Remote management and connectivity
    gui/          Tool Center V3 — WPF helpdesk GUI
    utilities/    Popup, registry fixes, misc tools
    archive/      Originals and technique reference

    ## Scripts Promoted

| Script | Original | What Changed |
|---|---|---|
| `HelpdeskTools.psm1` | SeveralFunctions.psm1 | WMI→CIM, multi-computer fix, error handling |
| `Invoke-ADUnlock.ps1` | Unlock_Function.ps1 | Null comparison fix, try/catch |
| `Invoke-PasswordReset.ps1` | PasswordReset.ps1 | Secure password display, error handling |
| `Get-NewDomainComputers.ps1` | LDAPquery_for_PCS_Added_to_Domain.ps1 | Hardcoded date/path removed, parameterized |
| `Set-VPNLogonHours.ps1` | VPNLogonCheck.ps1 | Group/preset parameters, safety comments |
| `Get-BigFixStatus.ps1` | BigFixCheck.ps1 | Path parameterized, error handling |
| `Get-CrowdStrikeStatus.ps1` | CrowdStrikeCheck.ps1 | WMI→CIM, AD/file/direct input, export option |
| `Get-DotNetVersion.ps1` | DOTNET_Checker.ps1 | AD filter removed, parameterized, color logic |
| `Get-TPMStatus.ps1` | TPMCheck.ps1 | Fixed undefined variable, unified to CIM |
| `Install-SoftwareRemote.ps1` | ChromeSilent.ps1 | Generalized for any installer |
| `Install-SoftwareLocal.ps1` | Notepad__SilentInstaller.ps1 | Fixed = vs -eq bug, CIM, parameterized |
| `Invoke-RemotePatch.ps1` | Patch_KB4532938.ps1 | KB/path parameterized, reusable template |
| `Get-PCInfo.ps1` | Get-PCINFO.ps1 | WMI→CIM, GridView switch, full property set |
| `Get-Memory.ps1` | Get_Memory.ps1 | wmic→CIM, structured output |
| `Enable-WinRM.ps1` | EnableWINRM.ps1 | PSExec path parameterized, TestAfter switch |
| `Set-VPNRegistryFix.ps1` | RegistryforVPN.ps1 + RegistryforVPNusingFile.ps1 | Merged, flexible input |
| `Reset-PrintQueue.ps1` | PrintQue.ps1 | Parameterized, status reporting |
| `Test-ComputerOnline.ps1` | Ping_with_output.ps1 | Parameterized, structured output |
| `Invoke-AssetTracker.ps1` | AssetTracker.ps1 | Registry path parameterized, name collision fixed |
| `Invoke-Popup.ps1` | Newpopup_function.ps1 | Approved verb, preserved original quality |

## Tool Center V3

Complete WPF rewrite of the original WinForms Tool Center.

**Architecture:**
- `ToolCenter.xaml` — UI definition, fully separated from logic
- `ToolCenter.ps1` — event wiring and business logic
- `Functions/favorites.json` — configurable favorites, no code changes needed
- `Functions/Import-Modules.ps1` — dependency loader

**What V3 has that V1/V2 didn't:**
- WPF instead of WinForms — proper layout, styles, templates
- Dark theme — professional look
- Live connection status indicator — debounced ping on PC name change
- Right panel PC info — model, user, OS, IP, MAC, serial, uptime, TPM
- Quick copy buttons — IP, MAC, serial to clipboard
- Action log — scrolling history of all operations
- Systray with ContextMenuStrip — minimize to tray, restore, exit
- Settings panel — TTS, balloon, AD config, persisted to JSON
- Configurable favorites via JSON — no code editing needed
- Proper function separation — UI calls functions, functions don't touch UI
- `Register-Click` helper — null-safe event registration
- `.GetNewClosure()` on dynamic buttons — correct variable capture
- Requires-AD guard — graceful degradation without AD module

**Evolution documented in archive:**
- V1 (ToolCenter.ps1) — absolute positioning, inline functions, hardcoded values
- V2 (WorkinProgress.ps1) — panel navigation concept, Switch boolean bug
- V3 — WPF, separated concerns, function library backend

## Bugs Fixed in Refactor

| Bug | Original | Fix |
|---|---|---|
| `$STools = $false` assignment instead of comparison | Notepad++ installer | Changed to `-eq` |
| `$TPMPC` undefined variable | TPMCheck.ps1 | Fixed loop variable |
| Plaintext password in console | PasswordReset.ps1 | Preserved intentionally with comment |
| Switch comparing `"$true"`/`"$false"` strings | WorkinProgress.ps1 | Documented in archive |
| Button/function name collision on CreateAsset | AssetTracker.ps1 | Renamed button variable |
| Get-Uptime loop variable shadowing parameter | SeveralFunctions.psm1 | Fixed, documented |
| All WMI calls | Multiple | Migrated to CIM throughout |

## Techniques Archived

- **P/Invoke and token privileges** — TokenPriv.ps1
- **Inline C# compilation** — Test_Calling_Csharp.ps1
- **PSExec fleet management pattern** — BigFixRepair.ps1
- **WPF exploration** — WPF-FormTest.ps1
- **Remote user message attempts** — Balloon_Message.ps1 + Cant_push_remote.ps1
- **Credential-based elevated process launch** — Startofday.ps1
- **WinForms event reference** — Form_All_Events.ps1

## Up Next

Phase 5 — Security Lab. Isolated, disposable, intentional.