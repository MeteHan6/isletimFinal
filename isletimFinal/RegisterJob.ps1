$action =
    {
        $percentageThreshold = 40;
        $checkInterval = 10*60
        $logPath = "PS/"
        for (;;)
        {
            $tmp = Get-WmiObject Win32_PerfFormattedData_PerfProc_Process |
            select-object -property Name, @{Name = "CPU"; Expression = {($_.PercentProcessorTime/ (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors)}} |
            Where-Object {($_.Name -notmatch "^(idle|_total|system)$") -and ($_.CPU -GE $percentageThreshold)} |
            Sort-Object -Property CPU -Descending;
            cls;
            New-Item -ItemType Directory -Force -Path $logPath
            $name = (get-date).tostring("yyyy-MM-dd")
            If ($tmp.count -gt 0) {
                 "%" + $percentageThreshold + " Üzeri çalýþan uygulamalar listesi" + [Environment]::NewLine + (get-date).tostring("HH:mm:ss")  >> ($logPath + $name + ".log")
                $tmp | Format-Table -Autosize -Property Name, CPU >> ($logPath + $name + ".log")
            }else{
                "Þuanda  %" + $percentageThreshold + "üzeri çalýþan uygulama yok" + [Environment]::NewLine + (get-date).tostring("HH:mm:ss") >> ($logPath + $name + ".log")
            }
            Start-Sleep -Seconds $checkInterval
        }
    }
$trigger = New-JobTrigger -Once -at (Get-Date).AddSeconds(5)
$opt = New-ScheduledJobOption -RunElevated -RequireNetwork
Register-ScheduledJob "MyJob" -Trigger $trigger -ScheduledJobOption $opt -ScriptBlock $action