import-module BitsTransfer
$ClientFileName = "client1.txt" 
$ExternalFQDN = "da.cereana.org"
$FiletoDownload = "http://"+$ExternalFQDN+"/"+$ClientFileName 
$DestinationFile = "c:\cfn\scripts\"+$ClientFileName 
Start-BitsTransfer -Source $FiletoDownload -Destination $DestinationFile
Write-host "Applying ODJ file" 
cmd.exe /c "Djoin /requestodj /loadfile $DestinationFile /windowspath %windir% /localos " 
