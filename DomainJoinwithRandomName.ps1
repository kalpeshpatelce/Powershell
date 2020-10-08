#Retrieve the AWS instance ID, keep trying until the metadata is available
$instanceID = "null"
while  ($instanceID -NotLike "i-*")  {
Start-Sleep -s 3
$instanceID = invoke-restmethod -uri http://169.254.169.254/latest/meta-data/instance-id
}

$ComputerName = New-RandomComputerName -NameLength 10

Function New-RandomComputerName
{
    [CmdletBinding(SupportsShouldProcess=$True)]

    Param(
        [int]$NameLength
    )

    #Characters Sets to be for Password Creation

    $CharSimple = "A","B","C","D","E","F","G","H","J","K","L","M","N","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","0"
    $CharNumbers = "1","2","3","4","5","6","7","8","9","0"
     
    #Verify if the Password contains at least 1 digit character

    $ContainsNumber = $False
    $Name = "GTU-"
     
    #Sets which Character Array to use based on $Complex

    #Loop to actually generate the password

    for ($i=0;$i -lt $NameLength; $i++)
        {$c = Get-Random -InputObject $CharSimple
            if ([char]::IsDigit($c))
        {$ContainsNumber = $True}
         $Name += $c}
    
    #Check to see if a Digit was seen, if not, fixit

    if ($ContainsNumber)
        {
            Return $Name
        }
        else
        {
            $Position = Get-Random -Maximum $NameLength
            $Number = Get-Random -InputObject $CharNumbers
            $NameArray = $Name.ToCharArray()
            $NameArray[$Position] = $Number
            $Name = ""
            foreach ($s in $NameArray)
            {
                $Name += $s
            }
        Return $Name
       
    }
}


$CompName = Get-WmiObject Win32_ComputerSystem
$CompName.Rename($ComputerName)



#Pass Domain Creds
$username = "Electromech\kalpesh"
$password = "Password" | ConvertTo-SecureString -AsPlainText -Force
$cred = New-Object -typename System.Management.Automation.PSCredential($username, $password)

#Adding to domain
Try {
Add-Computer -DomainName electromech.xyz -Credential $cred -Force -Restart -erroraction 'stop'
}

#Get Error messages in a file
Catch{
echo $_.Exception | Out-File c:\temp\error-joindomain.txt -Append
}
