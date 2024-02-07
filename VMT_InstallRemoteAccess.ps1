. C:\cfn\scripts\ClientHelperfunctions.ps1
Import-Module ServerManager
Add-WindowsFeature RemoteAccess  -ea stop  -verbose 
$OS = Gwmi Win32_OperatingSystem
If ($OS.Version -eq "6.3.9600") {Add-WindowsFeature DirectAccess-VPN} 
Add-WindowsFeature RSAT-RemoteAccess
Add-WindowsFeature RSAT-RemoteAccess-MGMT
