# Powershell
## Get IP Address of Remote PC
```
(Get-CimInstance -ComputerName 172.16.2.168 -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 'True'").IPAddress
```
## Set Service to Automatic Delay Start
```
sc.exe config CharusatApps start= delayed-auto
```
