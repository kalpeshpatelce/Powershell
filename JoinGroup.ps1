param 
(
[string] $UserName,
[string] $ServerName,
[string] $DomainDNSName,
[string] $GroupName
)
$DomainFQDN = $DomainDNSName.Split(".")
$PathUserObject = $("CN=$UserName,CN=Users")
$PathGroupObject = $("CN=$GroupName,CN=Users")
foreach ($DomainFQDNObject in $DomainFQDN)
{$PathUserObject = $($PathUserObject + ",")
$PathUserObject = $($PathUserObject + "DC=" + $DomainFQDNObject)
$PathGroupObject = $($PathGroupObject + ",")
$PathGroupObject = $($PathGroupObject + "DC=" + $DomainFQDNObject)
}$user = Get-ADUser $PathUserObject -Server "$ServerName.$DomainDNSName"
$group = Get-ADGroup $PathGroupObject -Server "$ServerName.$DomainDNSName"
Add-ADGroupMember `
-Identity $group `
-Member $user `
-Server "$ServerName.$DomainDNSName"