# Utilities

Miscellaneous utility scripts and fixes that don't fit other categories.

## FixPowerShellSpacesInPath.reg

Registry fix for two issues:
1. Running PowerShell scripts with spaces in the file path
2. Keeping the console window open after script completion

### Usage
Double-click the .reg file or import via regedit.
Run as Administrator if prompted.

### What it does
Updates the registry handler for .ps1 files so PowerShell correctly
handles paths with spaces by wrapping them in quotes, and uses
-NoExit to keep the console open when the script finishes.

### When you need this
If double-clicking a .ps1 file fails when the path contains spaces,
or if the console closes immediately after the script runs.
