#this is AWS USERDATA Script used for
#if You want to add server in Domain with New name basically used in Autoscalling in AWS

#Please Change Parameter
#$username.$password,Domainip,SERVERTP,
#Replace contoso.com to your Domain
<powershell>
Set-ExecutionPolicy unrestricted -Force

#set DNS IP To ADD Server in Domain
$Eth = Get-NetAdapter | where {$_.ifDesc -notlike "TAP*"} | foreach InterfaceAlias | select -First 1
Set-DNSClientServerAddress -interfaceAlias $Eth -ServerAddresses  ("DomainIP")
Start-Sleep -s 5

#Retrieve the AWS instance ID, keep trying until the metadata is available
$instanceID = "null"
while  ($instanceID -NotLike "i-*")  {
Start-Sleep -s 3
$instanceID = invoke-restmethod -uri http://169.254.169.254/latest/meta-data/instance-id
}


#Write Log File  LogMessage -Message "Function call Event/log";
$LogFile = "C:\DomainJoinLog.txt"
function LogMessage
{
    param([string]$Message)
    
    ((Get-Date).ToString() + " - " + $Message) >> $LogFile;
}


#Domain Join Credential Information
$username = "Domain\Administrator"
$password = "Password" | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object -typename System.Management.Automation.PSCredential($username, $password)


$CompName = Get-WmiObject Win32_ComputerSystem
Write-Host $CompName.Name
LogMessage -Message "AWS EC2  Computer Name is :$CompName.Name";

#Block Used to Verify server name start with SRV and contoso.com if not it will Change Computer Name & Add to domain 
if(($CompName.Name -like 'SRV*') -and ($CompName.Domain -like '*contoso*'))
{
   Write-Host "Name With SRV"
   LogMessage -Message "Name Start With SRV"
   Write-Host "PC Already in Contoso Domain..........Exit Program"
   LogMessage -Message "PC Already in gtu Domain..........Exit Program"
 #break
}    
else
{
   Write-Host "PC Name Does not Contain SRV Word so Process For Change Name"
   LogMessage -Message "PC Name Does not Contain GTU Word so Process For Change Name"

#Get Date in 131020101025 format to generate Computer Name
   $GetDateTime=Get-date -Format "ddMMyyHHMMss"
   Write-Host $GetDateTime
   LogMessage -Message "Get Current  Date & Time: $GetDateTime"

#Add datetime to Meaning full name
    $NEWPCName = "SRV" + $GetDateTime
   
    $CompName = Get-WmiObject Win32_ComputerSystem
    $CompName.Rename($NEWPCName)
    LogMessage -Message "New PCName is:$NEWPCName"
   
   Add-Computer -domainname contoso.com -NewName $NEWPCName -Credential $cred -Passthru -Verbose -Force -Restart
}

#Domain Join Credential Information
$username = "contoso\Administrator"
$password = "password" | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object -typename System.Management.Automation.PSCredential($username, $password)

#used to map network drive during Bootup
New-SmbGlobalMapping -RemotePath \\SERVERIP\share -Credential $cred -LocalPath D:

Start-Sleep -s 5
</powershell>
<persist>true</persist>
