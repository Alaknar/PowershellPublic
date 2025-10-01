<#
.SYNOPSIS
    Get-Uptime for PowerShell 5.
.DESCRIPTION
    The Get-Uptime cmdlet is only included in PowerShell 7 and above. This cmdlet gives the same data but works in PS5.
.EXAMPLE
    PS C:\> Get-Ps5Uptime                                          

    Days              : 0
    Hours             : 3
    Minutes           : 22
    Seconds           : 13
    Milliseconds      : 399
    Ticks             : 121333992206
    TotalDays         : 0.140432861349537
    TotalHours        : 3.37038867238889
    TotalMinutes      : 202.223320343333
    TotalSeconds      : 12133.3992206
    TotalMilliseconds : 12133399.2206
#>

function Get-Ps5Uptime {
    New-TimeSpan -Start (Get-CimInstance Win32_OperatingSystem).LastBootUpTime -End (Get-Date)
}
