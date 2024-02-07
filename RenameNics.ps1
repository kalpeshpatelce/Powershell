$PrivateIP = "10.0.1.20"
$PrivateDNSIP = "10.0.1.12"
$PrivateAlias = "Private Corpnet"
$PrivateNicConfig = Get-NetIPConfiguration | where {$_.ipv4address.IPaddress -eq $PrivateIP}
$PrivateNicConfig | Rename-NetAdapter -NewName $PrivateAlias 
$PrivateAdapter = Get-NetAdapter -Name $PrivateAlias 
$Result = $PrivateAdapter | Set-DnsClientServerAddress -ServerAddresses $PrivateDNSIP -verbose
$Result | out-string
Get-NetAdapter | fl
Get-NetIPConfiguration -detailed 
