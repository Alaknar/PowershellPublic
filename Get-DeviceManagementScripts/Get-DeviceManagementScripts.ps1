#Requires -Modules Microsoft.Graph.Authentication
Function Get-DeviceManagementScripts() {
    <#
.SYNOPSIS
Get all or individual Intune PowerShell Platform Scripts and save them in specified folder.
 
.DESCRIPTION
The Get-DeviceManagementScripts cmdlet downloads all or individual PowerShell scripts from Intune to a specified folder.
Initial Author: Oliver Kieselbach (oliverkieselbach.com)
Compatibility with MgGraph: Alaknár (https://github.com/Alaknar)
The script is provided "AS IS" with no warranties.
 
.PARAMETER FolderPath
The folder where the script(s) are saved.

.PARAMETER FileName
An optional parameter to specify an explicit PowerShell script to download.

.EXAMPLE
Download all Intune PowerShell scripts to the specified folder

Get-DeviceManagementScripts -FolderPath C:\temp 

.EXAMPLE
Download an individual PowerShell script to the specified folder

Get-DeviceManagementScripts -FolderPath C:\temp -FileName myScript.ps1

#>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [String]$FolderPath,
        [Parameter(Mandatory = $false)]
        [String]$FileName
    )

    IF(-not (Test-Path $FolderPath)){
        Write-Warning "Directory doesn't exist. Create (Y/N)? Change path (C)?" -WarningAction Continue
        $answer = Read-Host
        while ($answer -notin "y","Y","n","N","c","C") {
            $answer = Read-Host
        }
        IF($answer -in "y","Y"){
            New-Item -Path $FolderPath -ItemType Directory -Force
        }ELSEIF($answer -in "n","N"){
            break
        }ELSEIF($answer -in "c","C"){
            Write-Host "Provide the new path:" -ForegroundColor Yellow
            $FolderPath = Read-Host
            while(-not (Test-Path $FolderPath)){
                "Update path"
                $FolderPath = Read-host
            }
        }
    }

    $graphApiVersion = "Beta"
    $graphUrl = "https://graph.microsoft.com/$graphApiVersion"

    $result = Invoke-MgGraphRequest -Uri "$graphUrl/deviceManagement/deviceManagementScripts" -Method GET

    if ($FileName) {
        $scriptId = $result.value | Select-Object id, fileName | Where-Object -Property fileName -eq $FileName
        $script = Invoke-MgGraphRequest -Uri "$graphUrl/deviceManagement/deviceManagementScripts/$($scriptId.id)" -Method GET
        [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($($script.scriptContent))) | Out-File -Encoding ASCII -FilePath $(Join-Path $FolderPath $($script.fileName))
    }
    else {
        $scriptIds = $result.value | Select-Object id, fileName
        foreach ($scriptId in $scriptIds) {
            $script = Invoke-MgGraphRequest -Uri "$graphUrl/deviceManagement/deviceManagementScripts/$($scriptId.id)" -Method GET
            [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($($script.scriptContent))) | Out-File -Encoding ASCII -FilePath $(Join-Path $FolderPath $($script.fileName))
        }
    }
}
