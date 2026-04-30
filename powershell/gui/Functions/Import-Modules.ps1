# Module imports for Tool Center V3
# Called by ToolCenter.ps1 at startup

$ModuleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# Core helpdesk functions
$HelpdeskModule = Join-Path $ModuleRoot "modules\HelpdeskTools.psm1"
if (Test-Path $HelpdeskModule) {
    Import-Module $HelpdeskModule -Force
}

# Active Directory
try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    Write-Warning "ActiveDirectory module not available"
}