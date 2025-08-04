AuditPol /get /category:"Logon/Logoff"
AuditPol /set /category:"Logon/Logoff" /success:enable /failure:enable


Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624} -MaxEvents 1000 |
ForEach-Object {
    $event = [xml]$_.ToXml()

    $logonType = ($event.Event.EventData.Data | Where-Object { $_.Name -eq "LogonType" }).'#text'
    $ipAddress = ($event.Event.EventData.Data | Where-Object { $_.Name -eq "IpAddress" }).'#text'
    $userName  = ($event.Event.EventData.Data | Where-Object { $_.Name -eq "TargetUserName" }).'#text'
    $domain    = ($event.Event.EventData.Data | Where-Object { $_.Name -eq "TargetDomainName" }).'#text'
    $time      = $_.TimeCreated

    if (
        ($logonType -in "2", "3", "10") -and
        $userName -ne "ANONYMOUS LOGON" -and
        $userName -ne "DWM-1" -and
        $userName -ne "UMFD-0"
    ) {
        [PSCustomObject]@{
            TimeStamp = $time
            UserName  = "$domain\$userName"
            LogonType = switch ($logonType) {
                "2"  { "Local (Console)" }
                "3"  { "Network" }
                "10" { "Remote Desktop (RDP)" }
                default { "Other ($logonType)" }
            }
            ClientIP  = if ($logonType -eq "2") { "Local Machine" } else { $ipAddress }
        }
    }
} | Sort-Object TimeStamp -Descending | Select-Object -First 15 | Format-Table -AutoSize
