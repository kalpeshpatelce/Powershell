Import-Module ServerManager
Add-WindowsFeature RemoteAccess  -ea stop -verbose 
$OS = Gwmi Win32_OperatingSystem
If ($OS.Version -eq "6.3.9600") {Add-WindowsFeature DirectAccess-VPN} 
Add-WindowsFeature RSAT-RemoteAccess -verbose
Add-WindowsFeature RSAT-RemoteAccess-MGMT -verbose
