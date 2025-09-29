<#===================================
Requirement Script for Krita


===================================#>
$ErrorActionPreference = "silentlycontinue"
#-----------------------
$DisplayName_StartsWith = "XXXX"
#---------------------
$InstalledVersion = $Null
$Expected_Version = [version]"XXXX"
#---------------------
$Upgrade_Needed = 0
#---------------------


$SW = $Null
$SW = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Get-ItemProperty | Select-Object -Property DisplayName, DisplayVersion, InstallLocation, UninstallString, PSChildName

If ($Null -ne $SW) { 
    #Start of ForEach
    #---------------------------
    ForEach ($App in $SW) {

        if ($Null -eq $App.DisplayName) { Continue }

        if ($App.DisplayName.StartsWith($DisplayName_StartsWith)) { 
            <#
#----------------------------
Write-Host ""
Write-Host "DisplayName:  " $App.DisplayName   -ForegroundColor Cyan
Write-Host "DisplayVersion:" $App.DisplayVersion  -ForegroundColor Cyan
Write-Host "PSChildName: " $App.PSChildName  -ForegroundColor Cyan
Write-Host ""
#----------------------------
#>
            $InstalledVersion = [version]$App.DisplayVersion
            #Write-Host "App detected:  $(App.DisplayName) $($App.DisplayVersion)" -ForegroundColor Yellow
            Break
        }

    } #End of ForEach
}

#----------------------------------
If ($InstalledVersion -ge $Expected_Version) {
    Write-Host "App is installed"
    Exit 1
}
ElseIf ($Null -eq $InstalledVersion) {
    Write-Host "App not installed"
    Exit 1
}
ElseIf ($InstalledVersion -lt $Expected_Version) {
    $Upgrade_Needed++
}
#----------------------------------

#----------------------------------
if ($Upgrade_Needed -ne 0) {
    Write-Host "Upgrade needed"
    Exit 0
}
Else {
    Write-Host "App not installed"
    Exit 1
}
