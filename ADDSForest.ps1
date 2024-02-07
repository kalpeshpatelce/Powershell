Install-windowsfeature -name AD-Domain-Services -IncludeManagementTools 
Import-Module ADDSDeployment 
$safemode_pwd = convertto-securestring Password123 -asplaintext -force 
Install-ADDSForest `
-DomainName corp.cereana.org `
-DomainNetBIOSName CORP `
-DomainMode "Win2008R2" `
-ForestMode "Win2008R2" `
-DatabasePath "C:\Windows\NTDS" `
-SYSVOLPath "C:\Windows\SYSVOL" `
-LogPath "C:\Windows\NTDS" `
-InstallDNS:$true `
-CreateDNSDelegation:$false `
-Force:$true `
-SafeModeAdministratorPassword $safemode_pwd