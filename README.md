# Powershell
## Get IP Address of Remote PC
```
(Get-CimInstance -ComputerName 172.16.2.168 -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 'True'").IPAddress
```
## Output
![image](https://user-images.githubusercontent.com/13175900/178092275-ee80a8f0-0989-4a75-af4c-7393859a7a1a.png)

## Set Service to Automatic Delay Start
```
sc.exe config CharusatApps start= delayed-auto
```
