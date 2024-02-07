. C:\cfn\scripts\ClientHelperfunctions.ps1
$AccountName = "StackAdmin"
$AccountPassword = "Password123"
$InstanceNETBIOSName = "EDGE1"
$DomainNETBIOSName = "CORP"
$DomainDNSName = "corp.cereana.org"
$UserName = "$DomainNETBIOSNAME\$Accountname"
$BuildTaskScript = "`"powershell.exe -file c:\cfn\scripts\VMT_BuildCerts.ps1`"" 
$VerificationFile = "c:\cfn\log\VMT_BuildSSLCerts_Done.txt" 
$Taskname = "BuildCerts" 
$TaskCallResult = BuildTask -Server $InstanceNETBIOSName -UserName $UserName -Password $AccountPassword -TaskName $Taskname -Script $BuildTaskScript -Verify $VerificationFile 
$TaskCallResult 
