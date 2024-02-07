. C:\cfn\scripts\ClientHelperfunctions.ps1
$DomainDNSName = "corp.cereana.org"
$InstanceNETBIOSName = "EDGE1"
$DC1NETBIOSName = "DC1"
$FQDN = $InstanceNETBIOSName+"."+$DomainDNSName 
$DCFQDN = $DC1NETBIOSName+"."+$DomainDNSName 
$ExternalFQDN = "da.cereana.org"
$CANAME = "CORP-dc1-CA"
$Verify1 = "c:\cfn\log\VMT_BuildCerts_Done.txt" 
$Verify2 = "c:\cfn\log\VMT_BuildSSLCerts_Done.txt" 
write-host "Creating Machine Certs for $FQDN using $DCFQDN and CA $CANAME " 
write-host "SSL Cert is for $ExternalFQDN" 
$Loglocation=StartTranscriptedCmd -FunctionCall "Get-MachineCerts $FQDN" -VerificationFile $Verify1 
$Loglocation 
$Loglocation=StartTranscriptedCmd -FunctionCall "Get-SSLCerts $ExternalFQDN" -VerificationFile $Verify2 
$Loglocation 
