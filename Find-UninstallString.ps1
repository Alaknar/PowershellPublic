function Find-UninstallString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True)]
        [String]$Name
    )
    BEGIN{
        $path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall","HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    }
    PROCESS{
        Get-ChildItem -Path $path | Get-ItemProperty | Where-Object {$_.DisplayName -match $Name } | Select-Object -Property DisplayName,UninstallString,DisplayVersion
    }
}
