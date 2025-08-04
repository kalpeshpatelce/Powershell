# SystemUsageLogger.ps1
# Logs CPU, Memory, Disk data and prints it in table format

$logDir = "C:\PerfLogs"
$logPath = "$logDir\SystemUsage.csv"

# Create directory if not exists
if (-Not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force
}

# Create CSV with headers if it doesn't exist
if (-Not (Test-Path $logPath)) {
    "Timestamp,CPU_Usage_Percent,Available_Memory_MB,Total_Memory_MB,Used_Memory_Percent,Disk_C_Free_Percent" | Out-File $logPath -Encoding UTF8
}

function Get-SystemUsage {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # CPU Usage
    $cpuUsage = Get-Counter '\Processor(_Total)\% Processor Time'
    $cpu = [math]::Round($cpuUsage.CounterSamples[0].CookedValue, 2)

    # Memory Usage
    $os = Get-CimInstance Win32_OperatingSystem
    $totalMemory = [math]::Round($os.TotalVisibleMemorySize / 1024, 2)
    $freeMemory = [math]::Round($os.FreePhysicalMemory / 1024, 2)
    $usedPercent = [math]::Round(((($totalMemory - $freeMemory) / $totalMemory) * 100), 2)

    # Disk C Usage
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
    $diskFreePercent = [math]::Round((($disk.FreeSpace / $disk.Size) * 100), 2)

    # Output table to screen
    $row = [PSCustomObject]@{
        Timestamp           = $timestamp
        CPU_Usage_Percent   = "$cpu %"
        Free_Memory_MB      = $freeMemory
        Used_Memory_Percent = "$usedPercent %"
        Disk_C_Free_Percent = "$diskFreePercent %"
    }

    $row | Format-Table -AutoSize

    # Append to CSV
    "$timestamp,$cpu,$freeMemory,$totalMemory,$usedPercent,$diskFreePercent" | Out-File $logPath -Append -Encoding UTF8
}

# Loop every 5 mins and display data
while ($true) {
    Get-SystemUsage
    Start-Sleep -Seconds 300
}
