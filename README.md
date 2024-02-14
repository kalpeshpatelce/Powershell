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
## Get Users Login and Logoff on Windows PC
## Login Event
```
Get-EventLog -LogName Security -InstanceId 4624 | Where-Object {$_.TimeGenerated -ge (Get-Date '2024-02-14')} | Format-Table
```
![image](https://github.com/kalpeshpatelce/Powershell/assets/13175900/cd062e46-9bf7-41cb-9c4b-2ccc519b1e53)

## Logout Event
```
Get-EventLog -LogName Security -InstanceId 4634 | Where-Object {$_.TimeGenerated -ge (Get-Date '2024-02-14')} | Format-Table
```
![image](https://github.com/kalpeshpatelce/Powershell/assets/13175900/47e4c261-c0b4-4bb3-b73f-80ea7990a9a6)

## Get PowerOn Hours of HDD
```
Get-Disk | Get-StorageReliabilityCounter
Get-Disk | Get-StorageReliabilityCounter | Select-Object -Property "*"
```
![image](https://github.com/kalpeshpatelce/Powershell/assets/13175900/2f0e449a-ae4f-43ba-95a3-a7522874e180)
