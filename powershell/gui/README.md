# Tool Center V3

Complete rewrite of the original helpdesk Tool Center GUI.
Built with WPF/XAML for a modern, maintainable UI.

## Architecture

| File | Role |
|---|---|
| `ToolCenter.ps1` | Entry point — loads XAML, wires events, runs message loop |
| `ToolCenter.xaml` | UI definition — all visual elements defined here |
| `Functions/Import-Modules.ps1` | Loads HelpdeskTools module and other dependencies |
| `Functions/favorites.json` | Configurable favorites list — edit without touching code |
| `Assets/` | Icons and images |

## Features

- Dark theme — #1E1E2E background, teal/blue accent
- Sidebar navigation — AD, Tools, Favorites, Web Links, Settings
- PC selector — type name or search AD
- Connection status indicator — live ping check
- Right panel — PC info with quick copy buttons
- Action log — scrolling history of operations
- Systray icon — minimize to tray, right-click menu
- Balloon notifications — action completion alerts
- Text-to-speech — configurable voice feedback
- Clock in status bar
- Configurable favorites via JSON

## Panels

### Active Directory
- Unlock Account
- Password Reset
- VPN Logon Hours
- Find Computer

### Tools
- PC Info (populates right panel)
- Reset Print Queue
- Computer Management
- Registry Editor
- ADUC / ADAC
- CrowdStrike / BigFix / TPM / .NET status

### Favorites
- Dynamic — driven by favorites.json
- Add/remove without editing code

### Web Links
- Configurable portal shortcuts

### Settings
- TTS on/off
- Balloon notifications on/off
- AD search base and filter

## Requirements

- Windows PowerShell 5.0+
- ActiveDirectory module
- PSExec for WinRM enablement
- Appropriate AD permissions