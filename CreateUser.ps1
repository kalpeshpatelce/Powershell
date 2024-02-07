param 
(
[string] $UserName,
[string] $AccountPassword,
[string] $DomainDNSName
)
$account_pwd = convertto-securestring $AccountPassword -asplaintext -force 
$DomainFQDN = $DomainDNSName.Split(".")
$PathObject = $("CN=Users")
foreach ($DomainFQDNObject in $DomainFQDN)
{$PathObject = $($PathObject + ",")
$PathObject = $($Pathobject + "DC=" + $DomainFQDNObject)
}New-ADUser `
-Name $UserName `
-SamAccountName $UserName `
-Path $PathObject `
-AccountPassword $account_pwd `
-PasswordNeverExpires $true `
-Enabled $true