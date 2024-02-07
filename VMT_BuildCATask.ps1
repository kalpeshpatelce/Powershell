. C:\cfn\scripts\ClientHelperfunctions.ps1
$AccountName = "StackAdmin"
$AccountPassword = "Password123"
$InstanceNETBIOSName = "DC1"
$DomainNETBIOSName = "CORP"
$DomainDNSName = "corp.cereana.org"
$UserName = "$DomainNETBIOSNAME\$Accountname"
$BuildCATaskScript = "`"powershell.exe -file c:\cfn\scripts\VMT_Buildca.ps1`"" 
$VerificationFile = "c:\cfn\log\VMT_BuildCA_Done.txt" 
$Taskname = "BuildCA" 
$TaskCallResult = BuildTask -Server $InstanceNETBIOSName -UserName $UserName -Password $AccountPassword -TaskName $Taskname -Script $BuildCATaskScript -Verify $VerificationFile 
$TaskCallResult 
