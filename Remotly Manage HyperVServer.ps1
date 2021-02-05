<#Prerequisites
    Client
    - Windows 10 Pro or Enterprise
    - Hyper-V Manager Installed
    - Windows PowerShell 5.1
    - Hyper-V PowerShell Module
    
    Server
    - Hyper-V Server 2019
#>

#Attempt PowerShell Remoting
Enter-PSSession -ComputerName hvserver

#Add an entry to the hosts file for the host's fqdn
Get-Content -Path "C:\Windows\System32\drivers\etc\hosts"
Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value "172.16.101.26 hvserver"

#Set Adapter Connection to Private
Get-NetConnectionProfile
Set-NetConnectionProfile -InterfaceAlias "vEthernet (Wincell)" -NetworkCategory Private

#Configure PowerShell Remoting
Enable-PSRemoting

#Add the entire domain for delegation (Handy if you have more than one Host)
Get-WSManCredSSP
Enable-WSManCredSSP -Role Client -DelegateComputer "hvserver"

#Add all hosts in the entire domain to the Trusted Hosts (Handy if you have more than one Host)
Get-Item -Path WSMan:\localhost\Client\TrustedHosts
Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value "hvserver"

#Add credentials for each computer
cmdkey /list
cmdkey /add:hvserver /user:Administrator /pass:ceit@123

#Verify PowerShell Remoting is operational
Enter-PSSession -ComputerName hvserver