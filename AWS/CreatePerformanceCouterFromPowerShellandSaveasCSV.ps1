# Define name and log output folder
$logName = "SystemUsageDCS"
$logPath = "C:\PerfLogs\$logName"

# Create log directory
New-Item -Path $logPath -ItemType Directory -Force | Out-Null

# Stop and delete existing collector if it already exists
if (logman query | Select-String -Pattern $logName) {
    logman stop $logName | Out-Null
    logman delete $logName | Out-Null
}

# Ask user for duration type
$unit = Read-Host "Enter duration unit ('m' for minutes or 'h' for hours)"
if ($unit -ne 'm' -and $unit -ne 'h') {
    Write-Host "❌ Invalid unit. Use 'm' or 'h'. Exiting..."
    exit
}

# Ask user for duration value
if ($unit -eq 'h') {
    $duration = Read-Host "Enter how many hours to run"
    $unitText = "hour(s)"
    $runtimeSeconds = [int]$duration * 3600
} else {
    $duration = Read-Host "Enter how many minutes to run"
    $unitText = "minute(s)"
    $runtimeSeconds = [int]$duration * 60
}

# Create new data collector set with selected counters
logman create counter $logName `
 -c "\Processor(_Total)\% Processor Time" `
    "\Memory\Available MBytes" `
    "\Memory\Committed Bytes" `
    "\LogicalDisk(C:)\% Free Space" `
    "\LogicalDisk(C:)\Free Megabytes" `
    "\LogicalDisk(C:)\% Disk Time" `
 -si 300 `
 -o "$logPath\SystemUsage" `
 -f csv `
 -v mmddhhmm `
 -max 250

# Start data collector
logman start $logName
Write-Host "✅ Data Collector '$logName' started."
Write-Host "⏱ Will run for $duration $unitText and stop automatically at $(Get-Date)."

# Wait for specified time
Start-Sleep -Seconds $runtimeSeconds

# Stop the collector
logman stop $logName
Write-Host "`n🛑 Data Collector '$logName' stopped after $duration $unitText."
Write-Host "📁 Logs saved at: $logPath"
