#Requires -Version 2.0

<#
.SYNOPSIS
    Displays a customizable popup message box via WScript.Shell.

.DESCRIPTION
    Wraps the WScript.Shell PopUp method with named parameters and
    ValidateSet validation for button and icon types. Returns an
    integer representing the button clicked.

    Return values:
      -1 = No button clicked (timeout)
       1 = OK
       2 = Cancel
       3 = Abort
       4 = Retry
       5 = Ignore
       6 = Yes
       7 = No

.PARAMETER Message
    The message to display in the popup.

.PARAMETER Title
    The title bar text of the popup window.

.PARAMETER Time
    Seconds before auto-dismiss. Use 0 to require a button click.
    Defaults to 0.

.PARAMETER Buttons
    Button group to display. Defaults to OK.
    Valid values: OK, OKCancel, AbortRetryIgnore, YesNo, YesNoCancel, RetryCancel

.PARAMETER Icon
    Icon to display. Defaults to Information.
    Valid values: Stop, Question, Exclamation, Information

.EXAMPLE
    Invoke-Popup -Message "Operation completed" -Title "Done" -Time 5

.EXAMPLE
    $result = Invoke-Popup -Message "Restart now?" -Title "Confirm" -Buttons YesNo -Icon Question
    if ($result -eq 6) { Restart-Computer }

.NOTES
    Author: Daniel Avila
    Refactored for Nerdfolio - Phase 4
    Original: Newpopup_function.ps1
    Changes: Renamed to approved verb, minor formatting cleanup.
             Core logic and documentation preserved from original.
#>

function Invoke-Popup {
    param(
        [Parameter(Position=0, Mandatory=$true, HelpMessage="Enter a message for the popup")]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Position=1, Mandatory=$true, HelpMessage="Enter a title for the popup")]
        [ValidateNotNullOrEmpty()]
        [string]$Title,

        [Parameter(Position=2, HelpMessage="Seconds to display. Use 0 to require a button click.")]
        [ValidateScript({$_ -ge 0})]
        [int]$Time = 0,

        [Parameter(Position=3, HelpMessage="Enter a button group")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("OK","OKCancel","AbortRetryIgnore","YesNo","YesNoCancel","RetryCancel")]
        [string]$Buttons = "OK",

        [Parameter(Position=4, HelpMessage="Enter an icon set")]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Stop","Question","Exclamation","Information")]
        [string]$Icon = "Information"
    )

    switch ($Buttons) {
        "OK"               { $ButtonValue = 0 }
        "OKCancel"         { $ButtonValue = 1 }
        "AbortRetryIgnore" { $ButtonValue = 2 }
        "YesNo"            { $ButtonValue = 4 }
        "YesNoCancel"      { $ButtonValue = 3 }
        "RetryCancel"      { $ButtonValue = 5 }
    }

    switch ($Icon) {
        "Stop"        { $IconValue = 16 }
        "Question"    { $IconValue = 32 }
        "Exclamation" { $IconValue = 48 }
        "Information" { $IconValue = 64 }
    }

    try {
        $wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
        $wshell.Popup($Message, $Time, $Title, $ButtonValue + $IconValue)
    }
    catch {
        Write-Warning "Failed to create Wscript.Shell COM object: $_"
    }
}