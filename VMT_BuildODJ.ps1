. C:\cfn\scripts\ClientHelperfunctions.ps1
Get-DAReady
$InstanceNETBIOSName = "CLIENT1"
$DomainNETBIOSName = "CORP"
$SaveFile = "c:\inetpub\wwwroot\client1.txt" 
$Verify = "c:\cfn\log\VMT_BuildODJ_Done.txt" 
write-host "Creating ODJ for $InstanceNETBIOSName using $DomainNETBIOSName " 
write-host "Saving file to $SaveFile" 
cmd.exe /c "djoin /provision /domain $DomainNETBIOSName /certtemplate machine /machine $InstanceNETBIOSName /savefile $SaveFile /policynames ""DirectAccess Client Settings"" /rootcacerts /reuse" >$Verify  
