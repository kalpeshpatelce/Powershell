write-host "Enabling Advertising for v6 interfaces " 
$PrivateAlias = "Private Corpnet"
Get-NetAdapterBinding -Name $PrivateAlias  
Set-NetAdapterBinding -ComponentID ms_tcpip6 -enabled $true -Name $PrivateAlias  
Get-netipinterface -InterfaceAlias $PrivateAlias -AddressFamily ipv6 | fl   
write-host "Performing:Set-NetIPInterface -AddressFamily IPv6 -InterfaceAlias $PrivateAlias -advertising enabled"   
$Result = Set-NetIPInterface -AddressFamily IPv6 -InterfaceAlias $PrivateAlias -advertising enabled 
$Result
Get-netipinterface -InterfaceAlias $PrivateAlias -AddressFamily ipv6 | fl   
