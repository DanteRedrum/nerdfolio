# GUI Originals — Archived

Original Tool Center GUI scripts. Archived in favor of a complete
WPF rewrite in Phase 4. See powershell/gui/ for the new version.

## Files

### ToolCenter.ps1
The most complete version of the helpdesk Tool Center. WinForms-based
GUI with three column layout — Actions, Favorites, Tools.

**What it did:**
- AD Unlock, Password Reset, Asset Tracker
- Remote Desktop, Remote Assistance
- Print Queue reset, PC restart
- PC Info gathering via Out-GridView
- VPN logon hours management
- Application finder
- WinRM enablement
- Shortcuts to web tools (Airwatch, Adobe, ERPM, etc.)
- Systray icon with balloon notification and TTS on launch

**Architecture notes:**
- All functions defined inline at top of script
- Buttons wired directly to function calls
- Three-column layout using absolute positioning
- Systray via NotifyIcon with ContextMenu
- Icon loaded from file path — path was environment specific

**Known issues:**
- Hardcoded computer names, AD paths, file paths throughout
- Absolute positioning makes layout brittle
- No separation between UI and business logic
- Icon and image paths hardcoded to original developer's machine

### WorkinProgress.ps1
Attempted V2 rewrite. Introduced sidebar navigation with panel switching —
Network, Favorites, Helpdesk panels shown/hidden via sidebar buttons.

**What it improved:**
- Panel-based navigation concept
- TableLayoutPanel for sidebar buttons
- Systray menu with submenu items
- Cleaner separation of UI sections

**What it didn't solve:**
- Still WinForms with absolute/dock positioning conflicts
- Functions still inline
- Panel switching logic was brittle
- AD paths and icons still hardcoded

**Architecture lesson:**
The panel show/hide approach works but Switch statements comparing
string representations of booleans ("$true"/"$false") instead of
actual boolean values is a subtle bug that causes inconsistent behavior.
The correct pattern is:
    if ($Panel.Visible) { $Panel.Hide() } else { $Panel.Show() }

### SysTray.ps1
Standalone systray implementation. Shows how to create a NotifyIcon
with a ContextMenu without a visible form. Good reference for the
systray component of the new build.

**Technique:**
- NotifyIcon with ContextMenu
- ApplicationContext pattern for message loop
- Menu items with click events
- Icon loaded from process executable

**Techniques demonstrated:**
- Large button layout for easy clicking
- Conditional logic per button (check before install)
- Shell popup for user confirmation steps
- Start-Transcript for logging

## Why WPF

WinForms limitations that drove the rewrite decision:
- No proper layout system — everything is absolute or dock
- Styling is limited — flat look is hard to escape
- No data binding — UI updates require manual refresh
- XAML separation — WPF separates UI definition from code
- Modern controls — WPF has proper animations, gradients, templates
- The WPF-FormTest.ps1 in this archive shows early exploration of WPF
  and a full media player implementation — clearly the direction
  was already heading there

## Reference

These files are preserved as reference. The functions they call
have been refactored and live in:
- powershell/ad/
- powershell/compliance/
- powershell/network/
- powershell/pcinfo/
- powershell/deployment/
- powershell/modules/
