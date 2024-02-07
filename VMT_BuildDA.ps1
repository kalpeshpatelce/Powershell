. C:\cfn\scripts\ClientHelperfunctions.ps1
$PrivateAlias = "Private Corpnet"
#BuildDA
$DomainDNSName = "corp.cereana.org"
$InstanceNETBIOSName = "EDGE1"
$FQDN = $InstanceNETBIOSName+"."+$DomainDNSName 
$ExternalFQDN = "da.cereana.org"
$DomainNETBIOSName = "CORP"
$ServerGPOName=$DomainDNSName+"\DirectAccess Server Settings" 
$ClientGPOName= $DomainDNSName+"\DirectAccess Client Settings" 
$FunctionCall= "Install-RemoteAccess -NoPrerequisite -Force -PassThru -ServerGpoName ""$ServerGPOName"" -ClientGpoName ""$ClientGPOName"" -DAInstallType ""FullInstall"" -InternetInterface ""$PrivateAlias"" -InternalInterface ""$PrivateAlias"" -ConnectToAddress $ExternalFQDN -DeployNat -Verbose -ComputerName $FQDN " 
Write "Starting DA Config: $FunctionCall " 
$Verify = "c:\cfn\log\VMT_BuildDA_Done.txt" 
$Loglocation = StartTranscriptedCmd -FunctionCall $FunctionCall -VerificationFile $Verify 
$Loglocation
$SecurityGroupName= $DomainNETBIOSName+"\DirectAccessClients" 
$FunctionCall2= "Add-DAClient -SecurityGroupNameList ""$SecurityGroupName"" -Verbose -ComputerName $FQDN " 
Write "Updating DA Config: $FunctionCall2 " 
$Verify2 = "c:\cfn\log\VMT_BuildDA2_Done.txt" 
$Loglocation = StartTranscriptedCmd -FunctionCall $FunctionCall2 -VerificationFile $Verify2 
$Loglocation
$SecurityGroupNameToRemove=$DomainDNSName+"\Domain Computers"
$FunctionCall3= "Remove-DAClient -SecurityGroupNameList ""$SecurityGroupNameToRemove"" -Verbose -ComputerName $FQDN " 
Write "Updating DA Config: $FunctionCall3 " 
$Verify3 = "c:\cfn\log\VMT_BuildDA3_Done.txt" 
$Loglocation = StartTranscriptedCmd -FunctionCall $FunctionCall3 -VerificationFile $Verify3 
$Loglocation
$FunctionCall4= "Set-DAClient -OnlyRemoteComputers Disabled -Verbose -ComputerName $FQDN " 
Write "Updating DA Config: $FunctionCall4 " 
$Verify4 = "c:\cfn\log\VMT_BuildDA4_Done.txt" 
$Loglocation = StartTranscriptedCmd -FunctionCall $FunctionCall4 -VerificationFile $Verify4 
$Loglocation
$CorporateResource= @("HTTP:http://directaccess-WebProbeHost."+$DomainDNSName)
$FunctionCall5= "Set-DAClientExperienceConfiguration  -SupportEmail ""test@test.com"" -FriendlyName ""Workplace Connection"" -PreferLocalNamesAllowed `$False -PolicyStore ""$ClientGPOName"" -CorporateResources $CorporateResource " 
Write "Updating DA Config: $FunctionCall5 " 
$Verify5 = "c:\cfn\log\VMT_BuildDA5_Done.txt" 
$Loglocation = StartTranscriptedCmd -FunctionCall $FunctionCall5 -VerificationFile $Verify5 
$Loglocation
