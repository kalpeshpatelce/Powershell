#Manually Providing Values
$DomainNETBIOSName = "CORP"
$UserName = "StackAdmin"
$ServerName = "EDGE1"
$GroupName = "Administrators" 
$de = [ADSI]"WinNT://$ServerName/$GroupName,group"
$de.psbase.Invoke("Add",([ADSI]"WinNT://$DomainNetBIOSName/$UserName").path)
