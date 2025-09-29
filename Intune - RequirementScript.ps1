<#===================================
Requirement Script for Krita
    Original by https://www.reddit.com/user/Constant-Position601/
    Link to original: https://www.reddit.com/r/Intune/comments/1ldo4x8/comment/nfyeqjx/

    Updated by Alaknár: 2025-09-29
===================================#>

#---------------------
$Name = "XXX"
[version]$ExpectedVersion = "XXXX"
#-----------------------
$ErrorActionPreference = "silentlycontinue"
#---------------------
$testMode = 0
#---------------------

$allPaths = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
$SW = Get-ChildItem -Path $allPaths | Get-ItemProperty | Where-Object { $_.DisplayName -like $Name } | Select-Object -Property DisplayName, DisplayVersion

if ($Null -ne $SW) {
    [version]$InstalledVersion = (($SW | Sort-Object DisplayVersion)[-1]).DisplayVersion
    
    if ($InstalledVersion -ge $ExpectedVersion) {
        Write-Host "App is installed"
        if ($testMode -eq 0) {
            Exit 1
        }
        else {
            Write-Host "Exit 1" -ForegroundColor Green
        }
    }
    ElseIf ($Null -eq $InstalledVersion) {
        Write-Host "Version not found"
        if ($testMode -eq 0) {
            Exit 1
        }
        else {
            Write-Host "Exit 1" -ForegroundColor Red
        }
    }
    ElseIf ($InstalledVersion -lt $ExpectedVersion) {
        Write-Host "Upgrade needed"
        if ($testMode -eq 0) {
            Exit 0
        }
        else {
            Write-Host "Exit 0" -ForegroundColor Yellow
        }
    }
}
else {
    Write-Host "App not installed"
    if ($testMode -eq 0) {
        Exit 1
    }
    else {
        Write-Host "Exit 1" -ForegroundColor Red
    }
}
