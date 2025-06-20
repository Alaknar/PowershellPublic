# Requirement script
$appName = "Jabra Direct"
[version]$targetVersion = "6.23.16101"
$logPath = "C:\Temp\log.txt"
$outputString = "Applicable"

#region HELPER FUNCTIONS
function Find-UninstallString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)]
        [String]$Name,
        [Parameter(Mandatory = $false)]
        [Switch]$AllParams,
        [Parameter(Mandatory = $false)]
        [Switch]$Silent
    )
    BEGIN {
        $allPaths = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    }
    PROCESS {
        IF($AllParams.IsPresent){
            foreach($path in $AllPaths){
                $found = Get-ChildItem -Path $path | Get-ItemProperty | Where-Object { $_.DisplayName -like $Name } | Select-Object *
                IF($null -ne $found){
                    IF(!$Silent.IsPresent){
                        Write-Information "Path searched: $path" -InformationAction Continue
                    }
                    $found
                }
            }
        }ELSE{
            foreach($path in $AllPaths){
                $found = Get-ChildItem -Path $path | Get-ItemProperty | Where-Object { $_.DisplayName -like $Name } | Select-Object -Property DisplayName, UninstallString, DisplayVersion
                IF($null -ne $found){
                    IF(!$Silent.IsPresent){
                        Write-Information "Path searched: $path" -InformationAction Continue
                    }
                    $found
                }
            }
        }
    }
}

function Write-Log {
    <#
    .SYNOPSIS
        Writes a message with a timestamp to a log file while also being able to display it as a Verbose Message in the console.
    .DESCRIPTION
        Write-Log is an easy to use tool to writing log files. Any text received will receive a timestamp, formatting (according to the chosen options) and then will be added to a chosen log file.
        The log file will be created automatically if it doesn't exist.

        Note: no naming convention checks are being performed so make sure you remember about setting the file name correctly and with an extension.

        Non-powershell commands (e.g. 'dir' or 'tsm') can be also used with Write-Log. Test it beforehand and remember to redirect stderr to stdout (see example 2).

        FORMATTING
        Write-Log allows for three formatting options for any message.

         - Normal
        "$time"+": "+"$Message" 

         - Emphasis
        "$time"+" === "+"$Message"+" ==="

         - Header
        "`n === "+"$Message"+" === "+$time+" ==="

        You can also end the log with '-Message "EndLog"' which adds the following line:
        "`n`n ==== LOG FILE ENDED on $time ===="
    .PARAMETER LogFile
    Set the location and filename of the log.
    .PARAMETER Message
    Set the content of the log entry. Will be prefixed with a timestamp.
    .PARAMETER TextOption
    Set formatting of the message. Available options: "Normal", "Emphasis" and "Header".
    .EXAMPLE
        PS C:\> Write-Log -LogFile C:\Logs\LogFile.log -Message "Logging stuff"
        Log the message "Logging stuff" with a timestamp to the file LogFile.log.
    .EXAMPLE
        PS C:\> tsm do stuff 2>&1 | Write-Log -LogFile $logFile
        Will catch output and error output (stderr is redirected to stdout) and add it to the log.
    .EXAMPLE
        PS C:\> Write-Log -LogFile C:\Logs\LogFile.log -Message "Testing verbose" -Verbose
        This will both send the $Message content with a timestamp to the log file and display it in the console as a Verbose message.
    .INPUTS
        System.String[]
        System.IO.FileInfo
    .OUTPUTS
        System.String[]
    .NOTES
        Created on 2021-02-08 by Alaknár.
        Version 1.0
    #>
    [CmdletBinding()]
    param (
        [Alias("Path","PSPath")]
        [Parameter(Mandatory=$true, Position=0)]
        [String]
        $LogFile,
        [Alias("Value")]
        [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true)]
        [String]
        $Message,
        [Parameter(Mandatory=$false, Position=2)]
        [ValidateSet("Header","Emphasis","Normal")]
        [String]$TextOption = "Normal"
    )

    BEGIN{
        $time = Get-Date -Format "yyyy:MM:dd HH:mm:ss"
        if (Test-Path $LogFile) {

        }
        else {
            Write-Verbose "Creating the log file."
            New-Item -Type File -Path $LogFile -Force | Out-Null
            Add-Content -Path $LogFile -Value " ==== LOG FILE CREATED on $time ====`n"
        }
    }
    PROCESS{
        switch ($TextOption) {
            "Normal"    { $LogEntry = "$time"+": "+"$Message" }
            "Emphasis"  { $LogEntry = "$time"+" === "+"$Message"+" ===" }
            "Header"    { $LogEntry = "`n === "+"$Message"+" === "+$time+" ===" }
            Default     { $LogEntry = "$time"+": "+"$Message" }
        }
        if ("EndLog" -eq $Message) {
            $LogEntry = "`n`n ==== LOG FILE ENDED on $time ===="
        }
        Write-Verbose $LogEntry
        Add-Content -Path $LogFile -Value $LogEntry
    }
}
#endregion HELPER FUNCTIONS

$detectedInstallations = Find-UninstallString $appName
IF($null -ne $detectedInstallations){
    $versionCheck = foreach($dv in $detectedInstallations.DisplayVersion){
        Write-Log -LogFile $logPath -Message "Detected $dv"
        $verTest = $([version]$dv) -ge $targetVersion
        Write-Log -LogFile $logPath -Message $verTest
        [version]$dv -ge $targetVersion
    }
    IF(!($true -in $versionCheck)){
        Write-Log -LogFile $logPath -Message $outputString
        Write-Output $outputString
    }
}
