function Install-MicroTextEditor {
    IF($env:ctemp.length -ne 7){
        [Environment]::SetEnvironmentVariable('ctemp','C:\Temp')
    }
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    IF($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
        $iwr = Invoke-WebRequest "https://github.com/zyedidia/micro/releases/latest"
        $version        = $iwr.BaseResponse.RequestMessage.RequestUri.AbsoluteUri.split('/')[-1].Trim('v')
        $iwrhref        = $iwr.Links | Where-Object {$_ -match "$version.win64.zip"} | Select-Object -ExpandProperty href
        $filename       = $iwrhref.split('/')[-1]
        $foldername     = $($filename.Substring(0,$filename.length-4))
        $downloadLink   = "https://github.com/$iwrhref"
        Invoke-WebRequest -Uri $downloadLink -OutFile $env:ctemp\$filename
    
        IF(Test-Path $env:ctemp\$filename){
            Expand-Archive -Path $env:ctemp\$filename -DestinationPath "$env:ctemp\$foldername"
        }
    
        IF(Test-Path $env:ctemp\$foldername\micro-$version\micro.exe){
            Copy-Item -Path $env:ctemp\$foldername\micro-$version\micro.exe -Destination $env:WinDir -force
        }
    }
    ELSE{
        Write-Warning "Admin rights required!"
    }
}