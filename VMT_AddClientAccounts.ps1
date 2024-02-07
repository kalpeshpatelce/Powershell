#Create the Group Account
write-host "Create the Group Account" 
$InstanceNETBIOSName = "CLIENT1"
New-ADGroup DirectAccessClients Global 
New-ADComputer -Name $InstanceNETBIOSName -Enabled $true 
$DomainX500 = "DC=corp,DC=cereana,DC=org"
$MembertoAdd = "CN="+$InstanceNETBIOSName+",CN=Computers,"+$DomainX500
write-host "Adding Member $MembertoAdd " 
Add-ADGroupMember DirectAccessClients -members $MembertoAdd 
