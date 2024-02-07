$admin_pwd = convertto-securestring Password123 -asplaintext -force 
$admincreds = New-Object System.Management.Automation.PSCredential ("CORP\StackAdmin",$admin_pwd)
Add-Computer -Credential $admincreds -DomainName corp.cereana.org
Restart-Computer