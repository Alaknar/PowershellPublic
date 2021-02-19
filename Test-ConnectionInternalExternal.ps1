function Test-ConnectionInternal {
    Test-Connection -Ping -Delay 3 -Repeat -TargetName 192.168.0.1 | Format-Table -Property @{Name="Time";Expression={(Get-Date -Format HH:mm:ss)}},ping,address,Latency,status
}

function Test-ConnectionExternal {
    Test-Connection -Ping -Delay 3 -Repeat -TargetName 1.1 | Format-Table -Property @{Name="Time";Expression={(Get-Date -Format HH:mm:ss)}},ping,address,Latency,status
}