function Get-PCSpecs {
    $MoBo = Get-CimInstance -ClassName Win32_BaseBoard
    $CPU = Get-CimInstance -ClassName Win32_Processor
    $GPU = Get-CimInstance -ClassName Win32_VideoController
    $RAM = Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
    $Disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" | Select-Object -Property DeviceID, VolumeName, @{Name = "TotalSize"; Expression = { ([math]::round(($_.Size / 1GB))).ToString() + " GB" } }, @{Name = "FreeSpaceGB"; Expression = { ([math]::round(($_.FreeSpace / 1GB))).ToString() + " GB" } }
    $Monitors = Get-CimInstance -Namespace root\wmi -ClassName wmimonitorid | ForEach-Object {
        if ($_.UserFriendlyNameLength -eq 0) {
            $monitor = Get-CimInstance -ClassName CIM_DesktopMonitor
            New-Object -TypeName psobject -Property @{
                Manufacturer = $monitor.MonitorManufacturer
                Name         = $monitor.Name
            }
        }
        else {
            New-Object -TypeName psobject -Property @{
                Manufacturer = ($_.ManufacturerName -notmatch '^0$' | ForEach-Object { [char]$_ }) -join ""
                Name         = ($_.UserFriendlyName -notmatch '^0$' | ForEach-Object { [char]$_ }) -join ""
                Serial       = ($_.SerialNumberID   -notmatch '^0$' | ForEach-Object { [char]$_ }) -join ""
            }
        }
    }

    $computerdeets = [pscustomobject]@{
        MoBo     = $MoBo.Manufacturer + " " + $MoBo.Product
        CPU      = $CPU.DeviceID + " | " + $CPU.Name
        GPU      = foreach($GPU in $AllGPU){$GPU.Name + " | " + [math]::round($GPU.AdapterRAM / 1GB) + "GB | Driver version: " + $GPU.DriverVersion + " (published date: " + $GPU.DriverDate + ")"}
        RAM      = ([math]::round(($RAM.Sum / 1GB))).ToString() + "GB in " + $RAM.Count + " sticks"
        Disks    = $Disks
        Monitors = $Monitors
    }
    "HARDWARE:"
    $computerdeets | Select-Object MoBo, CPU, GPU, RAM | Format-List
    "MONITORS:"
    $computerdeets.Monitors | Format-Table
    "STORAGE:"
    $computerdeets.Disks | Format-Table
}