<#===================================
Requirement Script for Krita
    Original by https://www.reddit.com/user/Constant-Position601/
    Link to original: https://www.reddit.com/r/Intune/comments/1ldo4x8/comment/nfyeqjx/

===================================#>
$ErrorActionPreference = "silentlycontinue"
#-----------------------
$DisplayNameStartsWith = "Krita"
#---------------------
$InstalledVersion = $Null
$ExpectedVersion = [version]"5.2.13.0"
#---------------------
$UpgradeNeeded = 0
#---------------------


$SW = $Null
$SW = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Get-ItemProperty | Select-Object -Property DisplayName, DisplayVersion, InstallLocation, UninstallString, PSChildName

If ($Null -ne $SW) { 
    #Start of ForEach
    #---------------------------
    ForEach ($App in $SW) {

        if ($Null -eq $App.DisplayName) { Continue }

        if ($App.DisplayName.StartsWith($DisplayNameStartsWith)) { 
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
If ($InstalledVersion -ge $ExpectedVersion) {
    Write-Host "App is installed"
    Exit 1
}
ElseIf ($Null -eq $InstalledVersion) {
    Write-Host "App not installed"
    Exit 1
}
ElseIf ($InstalledVersion -lt $ExpectedVersion) {
    $UpgradeNeeded++
}
#----------------------------------

#----------------------------------
if ($UpgradeNeeded -ne 0) {
    Write-Host "Upgrade needed"
    Exit 0
}
Else {
    Write-Host "App not installed"
    Exit 1
}
