set-executionpolicy -ExecutionPolicy unrestricted -confirm:$false
import-module BitsTransfer 
Start-BitsTransfer -Source http://s3-us-west-2.amazonaws.com/vmtool/ClientHelperfunctions.ps1 -Destination C:\cfn\scripts\ClientHelperfunctions.ps1
#Install NetMon
Start-BitsTransfer -Source http://s3-us-west-2.amazonaws.com/vmtool/NM34_x64.exe -Destination c:\cfn\scripts\NM34_x64.exe 
cmd.exe /c "c:\cfn\scripts\NM34_x64.exe  /Q " 
