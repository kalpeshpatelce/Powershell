##########################################################################################
# Client HelperFunctions for Virtual Machine Topology creation system
# Author: Scott Roberts
# Version: 1.01
##########################################################################################

##########################################################################################
#                             Non-Editable Constants and Pseudo-Constants
##########################################################################################
 
#### Detect OS Version - this is used to validate various settings.

$OS = Gwmi Win32_OperatingSystem
$System = gwmi Win32_computersystem
$OSVer = $OS.Version
$OSBuild = $OS.BuildNumber
$OSSKU= $OS.OperatingSystemSKU


########################################## Logging Function

$confirmpreference="none"

################################################
##### Set IE Home Pages
function ConfigureIEHomePages($PassURL)
{
    "   "
    "-----------------------------------------------------"   

  If ($PassURL)
    {
    $URLString = $PassUrl
    }
    Else
    {
    $URLString = $Machine.IEHomePages
    }
    "Setting Home Pages: $URLString  "

    $IEHomepage=$null
    $IESecondary=$Null
    $Split=$Null
    #String should look like this, each URL with a space then the next URL
    #$URlString = "http://localhost http://C-Edge1 http://N-Edge1 http://H-C-Edge1 http://H-N-Edge1"

    #Create and array of URLS
    $split = $URlString.Split(" ")
    for($i =1; $i -lt $split.Length; $i++) {$IESecondary +=  $split[$i] +"`0"}

    #Assign the first array member to a seperate value
    $IEHomePage = $split[0]
    #Assign the rest to a second value. IE requires a NULL character `0 between each URL and two at the end to terminate the string.
    $IESecondary += "`0"

    Regedit -regaction add -regkey "HKCU:Software\Microsoft\Internet Explorer\Main" -regname "Start Page" -regvalue $IEHomepage -regtype String  
    Regedit -regaction add -regkey "HKCU:Software\Microsoft\Internet Explorer\Main" -regname "Secondary Start Pages" -regvalue "$IESecondary" -regtype MultiString  

}


################################################
##### Set IE Home Pages
function DisableAutoLogon()
{
#Some topologies require the user to logon manually. This function remove the autologon setting
 Regedit -regaction Add -regkey "HKLM:Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -regname AutoAdminLogon -regvalue 0

}

####################################
function commonbootconfig1()
{

If ($OS.Version -ge 6.2 )
{
EnableTSandFP
}

BuildBaseConfig

"Renaming NIC"

RenameNic

InstallNetMon

EnableTracing

# Flush IE Warning Under New Account
KillIE-StartPage

}

####################################
function commonbootconfig2()
{
#Make sure anything in this section can run on Win7 client as well.

    BuildBaseConfig

    "Updating Background and setting IE Homepages"

    ConfigureIEHomePages

    # Flush IE Warning Under New Account
    KillIE-StartPage

}

########################################
function addaccounts($PassedCorpFlag)
{
"Paused at addaccounts"
pause
    
}

###################################
function ListLocalGroupMember($GrouptoCheck="Administrators")
{
# List local group members on the local or a remote computer  
  
    
    $localgroupName = $GrouptoCheck
    $computerName = "$env:computername"
  
    if([ADSI]::Exists("WinNT://$computerName/$localGroupName,group")) {  
  
        $group = [ADSI]("WinNT://$computerName/$localGroupName,group")  
  
        $members = @()  
        $Group.Members() |  
        % {  
            $AdsPath = $_.GetType().InvokeMember("Adspath", 'GetProperty', $null, $_, $null)  
            # Domain members will have an ADSPath like WinNT://DomainName/UserName.  
            # Local accounts will have a value like WinNT://DomainName/ComputerName/UserName.  
            $a = $AdsPath.split('/',[StringSplitOptions]::RemoveEmptyEntries)  
            $name = $a[-1]  
            $domain = $a[-2]  
            $class = $_.GetType().InvokeMember("Class", 'GetProperty', $null, $_, $null)  
  
            $member = New-Object PSObject  
            $member | Add-Member -MemberType NoteProperty -Name "Name" -Value $name  
            $member | Add-Member -MemberType NoteProperty -Name "Domain" -Value $domain  
            $member | Add-Member -MemberType NoteProperty -Name "Class" -Value $class  
  
            $members += $member  
        }  
        if ($members.count -eq 0) {  
            "Group '$computerName\$localGroupName' is empty."  
        }  
        else {  
            "Group '$computerName\$localGroupName' contains these members:"  
            $members | Format-Table Name,Domain,Class -autosize  
        }  
    }  
    else {  
        Write-Warning "Local group '$localGroupName' doesn't exist on computer '$computerName'"  
    } 


}
#############################################
Function AddLocalAdmin($PassedUserNames=@("Administrator"),[string]$PassedDomain=$Domain)
{
   # Add a domain user to the local Administrators group on the local or a remote computer  

    ListLocalGroupMember  -GroupName "Administrators"

    $computerName = gc env:computername
     ForEach($UserNametoAdd in $PassedUserNames)
     {
        ([ADSI]"WinNT://$computerName/Administrators,group").Add("WinNT://$PassedDomain/$UserNametoAdd")  
        "User $PassedDomain\$UserNametoAdd is now local administrator"
     }
    ListLocalGroupMember -GroupName "Administrators"

}

####################################
Function SetRebootFlag($UserID,$DomainName=$CorpFlag)
{
    "Setting Reboot Flag: c:\config\boot-config.ps1 using $Corpflag"    
    Regedit -regaction Add -regkey "HKLM:Software\Microsoft\Windows\CurrentVersion\Run" -regname ClientExec -regvalue "cmd.exe /c ""powershell.exe -noprofile -ExecutionPolicy Bypass -File c:\config\boot-config.ps1 "" " 
    regedit -regaction Add -regkey "HKLM:Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -regname DefaultDomainName -regvalue $Corpflag   
    regedit -regaction Add -regkey "HKLM:Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -regname ForceAutoLogon -regvalue "1"   
    
    If($UserID)
    {
    "Setting Reboot Logon Flag: $UserID  "
    regedit -regaction Add -regkey "HKLM:Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -regname DefaultUserName -regvalue $UserID   
    }
        
}

####################################
Function RemoveAutoRunFlag()
{
    "Removing AutorunFlag for c:\config\boot-config.ps1"    
    Regedit -regaction Delete -regkey "HKLM:Software\Microsoft\Windows\CurrentVersion\Run" -regname ClientExec -regvalue "cmd.exe /c ""powershell.exe -noprofile -ExecutionPolicy Bypass -File c:\config\boot-config.ps1 "" " 
        
}

####################################
Function DisableAero()
{
    "Disabling AERO"    
    #cmd.exe /c "reg add ""HKCU\Software\Microsoft\Windows\DWM"" /v Composition /t REG_SZ /d ""0"" /f "    
    regedit -regaction Add -regkey "HKCU:Software\Microsoft\Windows\DWM" -regname Composition -regvalue "0"  
}


####################################
function ResetBoot()
{
        "Something went wrong."
        "Removing $filetest and restarting"
        Remove-Item $filetest
        RestartPC
        Restart-Computer -force -ErrorAction SilentlyContinue
        exit
}

###################################
Function PingTest($PassedIP)
{
Do
{

$ping = new-object System.Net.NetworkInformation.Ping
    Try
    {
        $Reply = $ping.Send($PassedIP)
    }
    Catch
    {
      "Ping Failed"
    }
    
    $Result = $Reply.status
    "Looking for $PassedIP Test-Path Value: $Result "

}
While ($Result -ne "Success")
"Found! $PassedIP Test-Path Value: $Result "
}


####################################
Function TestReady($PassedIP,$Passedfilename="dcdone.txt")
{

    
If ($PassedIP)
        {    
        $Test = Test-Path -path "\\$PassedIP\files\$Passedfilename"
        "Looking for \\$PassedIP\files\$Passedfilename : Test-Path Value: $Test"
        }
        Else
        {
        $Test = Test-Path -path "\\$DCIP\files\$Passedfilename"
        "Looking for \\$DCIP\files\$Passedfilename : Test-Path Value: $Test"
        }

    Do 
    {
        
        timeout /t 10

        If ($PassedIP)
        {    
        $Test = Test-Path -path "\\$PassedIP\files\$Passedfilename"
        "Looking for \\$PassedIP\files\$Passedfilename : Test-Path Value: $Test"
        }
        Else
        {
        $Test = Test-Path -path "\\$DCIP\files\$Passedfilename"
        "Looking for \\$DCIP\files\$Passedfilename : Test-Path Value: $Test"
        }
    }
    While($Test -ne $true)
    
    If ($PassedIP)
        {    
        $Test = Test-Path -path "\\$PassedIP\files\$Passedfilename "
        "Found! \\$PassedIP\files\$Passedfilename : Test-Path Value: $Test"
        }
        Else
        {
        $Test = Test-Path -path "\\$DCIP\files\$Passedfilename "
        "Found! \\$DCIP\files\$Passedfilename Test-Path Value: $Test"
        }

}

####################################
Function TestDCCorpReady($PassedIP)
{
    "Passed IP: $PassedIP"

    if ($PassedIP)
    {
        TestReady $PassedIP
    }
    Else
    {
        TestReady $DCIP
    }

    If($varDomainJoin -eq $True)
    {
       "Proceed with Domain Join: $varDomainJoin, $CorpFQDN"
       $DomainTest = VerifyDomainJoin
         
        if ($DomainTest -eq "WORKGROUP")
        {
           "Validated to be a member of a workgroup, proceeding with domain join"

            "Performing Net Join using add-computer: ID: $ID  CORP: $CORPFQDN"
            $Pwd_Credential = ConvertTo-SecureString -AsPlainText $DefaultPassword -Force
            $AdminUser = $CORPFQDN+"\Administrator"
            $Cred_Credential = New-Object System.Management.Automation.PSCredential($AdminUser, $Pwd_Credential) 

            Write-output "DomainJoin Attempted  $varDomainJoin " | Out-File -filepath "C:\config\logs\DomainJoin.txt"
            try 
            {
                If ($OS.Version -ge 6.2 )
                {
                add-computer -DomainName $CorpFQDN -Credential $Cred_Credential -Force -erroraction stop
                }
                Else
                {
                add-computer -DomainName $CorpFQDN -Credential $Cred_Credential -erroraction stop
                }
           
            }
            catch
            {
             "Attempted to perform Net Join using add-computer: ID: $ID  CORP: $CORPFQDN"
             "But something went wrong, it's not happy, resetting."
            ResetBoot
            }

            RestartPC
        }
        else
        {
          "Machine is already joined to a domain, but system wanted to join the domain again"
          "Machine joined to $Domaintest "
        }
    }
  
}
###################################
Function VerifyDomainJoin ()
{
  "Reading Domain Membership"
  $DomainTest  = Get-WmiObject -Class Win32_ComputerSystem 
  "Test Result:"
  $DomainTest
 Return $DomainTest.domain           

}

####################################
Function FixTime()
{
    cmd.exe /c “net time \\$DCIP /set /Y”    
}


#####################################
Function KillIE-StartPage()
{

    Regedit -regaction Delete -regkey "HKCU:Software\Microsoft\Internet Explorer\Main" -regname "First Home Page"
    
}


###########################################
Function InstallRemoteAccess()
{
        "Adding RemoteAccess Server Role"
        Import-Module ServerManager   

        Get-Service RemoteAccess

        try 
        {
        $Result = Add-WindowsFeature RemoteAccess  -ea stop  -verbose          
        }
        catch
        {
        "Attempted to Install RemoteAccess Roles: ID: $ID  CORP: $CORPFQDN"
        "But something went wrong, it's not happy, resetting."
        $Result
        ResetBoot
        RestartPC
        }
        
        Get-Service RemoteAccess

        Add-WindowsFeature RSAT-RemoteAccess    

        "Adding RemoteAccess Server Role"
        
        Add-WindowsFeature RSAT-RemoteAccess-MGMT   

        #Install RemoteAccess Tracing
        Regedit -regaction add -regkey "HKLM:SYSTEM\CurrentControlSet\Services\RaMgmtSvc\Parameters" -regname DebugFlag -regvalue "0xffffffff" -regtype Dword  
        Regedit -regaction add -regkey "HKLM:SYSTEM\CurrentControlSet\Services\RaMgmtSvc\Parameters" -regname EnableTracing -regvalue "5" -regtype Dword      
}


#####################################
Function EnableTracing()
{

        "Adding tracing for NLA/NLMPerforming"
        cmd.exe /c "netsh trace start nid_wpp,DirectAccess,internetclient fileMode=circular persist=yes"   
        "Adding tracing for iphlpsvc "
        regedit -regaction add -regkey "HKLM:SOFTWARE\Microsoft\Tracing\iphlpsvc" -regname EnableFileTracing -regvalue "1" -regtype Dword   
        regedit -regaction add -regkey "HKLM:SOFTWARE\Microsoft\Tracing\iphlpsvc" -regname FileTracingMask -regvalue "0xffffffff" -regtype Dword   

}

#####################################
Function Get-SSLCerts ($SSLFQDN)
{
    $ExternalDNS = "."+$ExternalFQDN
    $LDAP = "ldap."+$ExternalFQDN
    $SANString = "SAN=dns="+$SSLFQDN+"&dns="+$ExternalDNS+"&dns="+$LDAP

$certSSLTemplate=@"
[Version] 

Signature=`$Windows NT$ 

[NewRequest]
Subject = "CN=$SSLFQDN" 
Exportable = FALSE  
KeyLength = 1024    
KeySpec = 1             
KeyUsage = 0xA0    
MachineKeySet = True
ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
ProviderType = 12
RequestType = CMC
    
; Omit entire section if CA is an enterprise CA
[EnhancedKeyUsageExtension]
OID=1.3.6.1.5.5.7.3.1 ; Server Authentication
    
[RequestAttributes]
CertificateTemplate = WebServer ;Omit  line if CA is a stand-alone CA
$SANString
"@
    #$DCFQDN = FindDCFQDN
    #$CANAME = FindCANAME

        UpdateGP

        If (Test-path c:\config\cert) {} Else
        {
        mkdir c:\config\cert -Force
        }

        "Deleting any prior certificate requests $FQDN - $DCFQDN"
        remove-item -path c:\config\cert\cert-ssl.inf -force -ErrorAction SilentlyContinue

        "Deleting any prior certificate requests $FQDN - $DCFQDN"
        remove-item -path c:\config\cert\cert-ssl.req -force -ErrorAction SilentlyContinue

        "Deleting any prior certificates $FQDN - $DCFQDN"
        remove-item -path c:\config\cert\cert-ssl.cer -force -ErrorAction SilentlyContinue

        $CertSSLTemplate | out-file c:\config\cert\cert-ssl.inf

        "Getting SSL Certs for $SSLFQDN - $DCFQDN"
        cmd.exe /c "certreq -f -new c:\config\cert\cert-ssl.inf c:\config\cert\cert-ssl.req "   

        "Submit Request for $SSLFQDN - DC: $DCFQDN - CA: $CANAME "
        cmd.exe /c "certreq -f -submit -config ""$DCFQDN\$CANAME""  c:\config\cert\cert-ssl.req c:\config\cert\cert-ssl.cer "   

        "Install Cert for $SSLFQDN "
        cmd.exe /c "certreq -accept c:\config\cert\cert-ssl.cer"   

}


#####################################
function DisableInternetForwarding()
{
    "Disable forwarding on external interface"
    "Performing:Set-NetIPInterface -AddressFamily IPv4 -InterfaceAlias Private Internet -forwarding disabled"
    $Result = Set-NetIPInterface -AddressFamily IPv4 -InterfaceAlias "Private Internet" -forwarding disabled
    write-host $Result     
            
    If (-not -$NoV6)
    {
    "Performing:Set-NetIPInterface -AddressFamily IPv6 -InterfaceAlias Private Internet -forwarding disabled"
    $Result = Set-NetIPInterface -AddressFamily IPv6 -InterfaceAlias "Private Internet" -forwarding disabled
    write-host $Result     

    }
}

#####################################
function DisableInternetLDAP()
{
    
    $IPobj = Get-NetIPAddress -interfacealias "Private Internet" -Addressfamily IPv4 -PolicyStore activestore
    $IPV4Add = $IPobj.IPv4Address
   
    "Disabling LDAP on the External interface $IPV4Add - to prevent domain classfication"
    New-NetFirewallRule -DisplayName “_LDAP Block UDP” -Direction Outbound –Protocol UDP –LocalPort 389 -LocalAddress $IPV4Add -Action Block 
    New-NetFirewallRule -DisplayName “_LDAP Block UDP” -Direction Outbound –Protocol TCP –LocalPort 389 -LocalAddress $IPV4Add -Action Block 
}


#####################################
Function Get-MachineCerts($FQDN)
{
        "FQDN to Request: $FQDN "

        $CertTemplate = 
@"
        [Version] 

        Signature=`$Windows NT$

        [NewRequest]
        Subject = "CN=$FQDN"
    
        [RequestAttributes]
        CertificateTemplate = Machine
"@

        #$DCFQDN = FindDCFQDN
        #$CANAME = FindCANAME

        UpdateGP

        If (Test-path c:\config\cert) {} Else
        {
        mkdir c:\config\cert -Force
        }


        "Deleting any prior certificate INF $FQDN - $DCFQDN"
        remove-item -path c:\config\cert\cert-machine.inf -force -ErrorAction SilentlyContinue

        "Deleting any prior certificate requests $FQDN - $DCFQDN"
        remove-item -path c:\config\cert\cert-machine.req -force -ErrorAction SilentlyContinue

        "Deleting any prior certificates $FQDN - $DCFQDN"
        remove-item -path c:\config\cert\cert-machine.cer -force -ErrorAction SilentlyContinue

        #Create INF
        $CertTemplate | out-file c:\config\cert\cert-machine.inf

        "Getting Machine Certs for $FQDN - $DCFQDN"
        cmd.exe /c "certreq -f -new c:\config\cert\cert-machine.inf c:\config\cert\cert-machine.req"   
        
        "Submit Request for $FQDN"
        cmd.exe /c "certreq -adminforcemachine -submit -config ""$DCFQDN\$CANAME"" c:\config\cert\cert-machine.req c:\config\cert\cert-machine.cer"   

        "Install Cert for $FQDN"
        cmd.exe /c "certreq -accept c:\config\cert\cert-machine.cer"   

        "Completing Machine Cert Creation for $FQDN"
}


#####################################
Function FindDCFQDN()
{
    foreach ($Topology in $ColAllTopologies)
     {
    
    #TODO duplication
      $TID  =  $Topology.id
      $TNAME = $Topology.id
      $TestFile = "C:\"+$Topology.FileFlag+".xml"

      If (Test-Path $TestFile)
      {
        "Found Topology $TName"
        $FoundTopology = $Topology.id
        $DCIP = $Topology.DCIP
        $DCFQDN = $Topology.DCFQDN
        "Setting DCIP: $DCIP "
        "Setting DCFQDN: $DCFQDN "

      }

     }
     Return $DCFQDN
}

#####################################
Function FindCAName()

{
    foreach ($Topology in $ColAllTopologies)
     {
    
      $TID  =  $Topology.id
      $TNAME = $Topology.id
      $TestFile = "C:\"+$Topology.FileFlag+".xml"

      If (Test-Path $TestFile)
      {
        "Found Topology $TName"
        $CATest = $Topology.CANAME
        If ($CATest)
        {
        $CAName=$CATest
        }
        Else
        {
        $CAName="Corp-DC1-CA"
        }
        "Setting CANAME: $CANAME "
      }

     }
     Return $CANAME
}

#####################################
Function InstallNetMon()
{
    if (test-path c:\tools\Nm34_x64.exe)
    {
    "Installing Netmon"
    cmd.exe /c "c:\tools\Nm34_x64.exe /Q"  
    }
    if (test-path "C:\tools\dbg_amd64.msi")
    {
    "Installing Windbg"
    cmd.exe /c "C:\tools\dbg_amd64.msi /quiet"  
    }
}


#####################################
Function ReplaceBackground ()
{

        If ($OS.Version -ge 6.2 )
        {
            #Determine if a server build
             If ($OSSKU -gt 7)
             {
                #Make a copy of setres.exe available to the client SKU (since it's not there)
                If (test-path c:\files\en-US) {} Else
                {
                    "Creating Directory for Set Res En-US"
                    mkdir c:\files\en-US
                }

                If (test-path c:\files\setres.exe) {} Else
                {
                    "Copying SetRes to C:\files"
                    copy-item c:\windows\system32\setres.exe c:\files\setres.exe
                    copy-item c:\windows\system32\en-us\setres.exe.mui c:\files\en-US\setres.exe.mui
                }
                
             }
             Else
             {

                If (test-path c:\windows\system32\setres.exe) 
                 {
                  "Already copied setres"
                 } Else
                 {
                  #If a client SKU then copy from DC1
                  "Copying setres from $DCIP"
                  TestReady $DCIP
                  xcopy \\$DCIP\files\setres*.* c:\windows\system32 /s /Y
                }               
             }

            #Now that we prepped the files, lets set the resolution
            "Running SetRes -w $DisplayWidth -h $DisplayHeight -f "
            cmd.exe /c "setres -w $DisplayWidth -h $DisplayHeight -f "
            #set correct script on startuup
            "Setting Background to $BGColor"
            cmd.exe /c "c:\config\images\bginfo.exe c:\config\images\BG-$BGColor.bgi /timer:0 /NOLICPROMPT /SILENT"
        }
        Else
        {
             #If a older OS then just set the BG
             cmd.exe /c "c:\config\images\bginfo.exe c:\config\images\BG-$BGColor.bgi /timer:0 /NOLICPROMPT /SILENT"
        }

}

########################################## NIC Rename
Function RenameNic()
{
 
    "     NIC Values ------------------------------------------------ "
    "     Loading NICs: Reading setings for ID: $ID "
    "     Loading NICs: Reading setings for Topology: $FoundTopology "

     ForEach ($Machine in $colMachines | where { $_.Name -eq $ID})
     {
        $VMName = $Machine.Name
        "   VM Nic Rename : $VMName "    
            ForEach ($Nic in $Machine.NetworkAdapters.NetworkAdapter )
            {
                $Temp=$Null
                $Switch=$Null
                $SwitchID=$Null
                $Mac=$Null
                $MacType=$Null

                $Mac = $Nic.macaddress
                $Mactype = $Nic.mactype
                
                $SwitchID = $Nic.switchID
              

                ForEach ($FindSwitch in $ColALLSwitches | where {$_.id -eq $SwitchID})
                {

                  $Switch= $FindSwitch.name
                  "   VM Nic Rename : NIC Values for $ID "    
                  If ($Mac)     {"   VM Nic Rename : MAC: $Mac - $Switch"}            
                  If ($MacType) {"   VM Nic Rename : MACType: $MacType"}
                
                  If ($OS.Version -lt 6.2 )
                        {
                         SetIP-NETSH $Nic "Local Area Connection"
                        }
                        Else
                        {
                             If ($MacType -eq "Dynamic")
                             {
                                 "Detected Dynamic MAC - Skipping Rename. Make sure this VM only has 1 NIC with NIC Settings " 
                                 SetIP-PS $Nic "Ethernet"
                             }
                             Else
                             {
                                 Get-NetAdapter | where {$_.NetworkAddresses -like "$Mac"} | Rename-NetAdapter -NewName "$Switch"
                                 "Detected Static MAC - Calling Windows 8 Networking PowerShell "
                                 SetIP-PS $Nic $Switch
                             }
                        }
                }
            }
         

    "      NIC Values ------------------------------------------------ "
    "      VM Creation: Completed VM Creation "
    }
}

########################################
Function SetIP-PS($Nic,$Switch)
{
    $IPv4Address = $Null
    $IPv4Address2 = $Null
    $IPv4Gateway = $Null
    $IPv4SubnetMask = $Null
    $IPv4SubnetMask2 = $Null
    $IPv4PrefixLength = $Null
    $IPv4DNS = $Null
    $IPv4DNS2 = $Null
    $IPv6Address =  $Null
    $IPv6Gateway = $Null
    $IPv6PrefixLength = $Null
    $IPv6DNS = $Null
    $IPv6DNS2 = $Null
    $DNSArray = @()

    $IPv4Address = $Nic.IPv4Address
    $IPv4Address2 = $Nic.IPv4Address2
    $IPv4Gateway = $Nic.IPv4Gateway
    $IPv4SubnetMask = $Nic.IPv4SubnetMask
    $IPv4SubnetMask2 = $Nic.IPv4SubnetMask2
    $IPv4PrefixLength = $Nic.IPv4PrefixLength
    $IPv4DNS = $Nic.IPv4DNS
    $IPv4DNS2 = $Nic.IPv4DNS2
    $IPv6Address =  $Nic.IPv6Address
    $IPv6Gateway = $Nic.IPv6Gateway
    $IPv6PrefixLength = $Nic.IPv6PrefixLength
    $IPv6DNS = $Nic.IPv6DNS
    $IPv6DNS2 = $Nic.IPv6DNS2

    $V4Address=$IPv4Address+"/"+$IPv4PrefixLength

    If ($IPv4DNS) { $DNSArray+=$IPv4DNS}
    If ($IPv4DNS2){ $DNSArray+=$IPv4DNS2}
    if (-not $NoV6)
    {
        If ($IPv6DNS) { $DNSArray+=$IPv6DNS}
        If ($IPv6DNS2){ $DNSArray+=$IPv6DNS2}
    }
     If ($DNSArray -ne @()){
           "Set-DNSClientServerAddress -InterfaceAlias $Switch -ServerAddresses $DNSArray"
           Set-DNSClientServerAddress -InterfaceAlias $Switch -ServerAddresses $DNSArray
    }

    If ($IPV4Address){
         "Set-NetIPInterface -InterfaceAlias $Switch -DHCP Disabled  " 
         Set-NetIPInterface -InterfaceAlias "$Switch" -DHCP Disabled  


         "New-NetIPAddress -InterfaceAlias $Switch -IPAddress $IPv4Address -AddressFamily IPv4 -PrefixLength 24"
         New-NetIPAddress -InterfaceAlias "$Switch" -IPAddress $IPv4Address -AddressFamily IPv4 -PrefixLength $IPv4PrefixLength  
    }

    If ($IPV4Address2){
    
         "New-NetIPAddress -InterfaceAlias $Switch -IPAddress $IPv4Address2 -AddressFamily IPv4 -PrefixLength 24"
         New-NetIPAddress -InterfaceAlias "$Switch" -IPAddress $IPv4Address2 -AddressFamily IPv4 -PrefixLength $IPv4PrefixLength  

    }

    If ($Ipv4Gateway) {
         
            "New-NetRoute -InterfaceAlias $Switch -DestinationPrefix ""0.0.0.0/0"" -AddressFamily IPv4 -NextHop $Ipv4Gateway  -RouteMetric 256 "
            New-NetRoute -InterfaceAlias "$Switch" -DestinationPrefix "0.0.0.0/0" -AddressFamily IPv4 -NextHop $Ipv4Gateway  -RouteMetric 256  
             
    }

    If (-not $NoV6)
    {

        If ($IPv6Address)
        {
        
          "New-NetIPAddress -InterfaceAlias $Switch -IPAddress $IPAddress/$IPv6PrefixLength  -AddressFamily IPv6 -PrefixLength 48"
          New-NetIPAddress -InterfaceAlias "$SWitch" -IPAddress $IPv6Address -AddressFamily IPv6 -PrefixLength 48  
         
        }
        If ($IPv6Gateway){

           
            "New-NetRoute -InterfaceAlias $Switch -DestinationPrefix ""::/0"" -AddressFamily IPv6 -NextHop $Ipv6Gateway -RouteMetric 256"
            New-NetRoute -InterfaceAlias "$Switch" -DestinationPrefix "::/0" -AddressFamily IPv6 -NextHop $Ipv6Gateway -RouteMetric 256  
         
        }
    }
 
}

########################################
Function SetIP-NETSH($Nic,$Switch)
{
    $IPv4Address = $Null
    $IPv4Address2 = $Null
    $IPv4Gateway = $Null
    $IPv4SubnetMask = $Null
    $IPv4SubnetMask2 = $Null
    $IPv4PrefixLength = $Null
    $IPv4DNS = $Null
    $IPv4DNS2 = $Null
    $IPv6Address =  $Null
    $IPv6Gateway = $Null
    $IPv6PrefixLength = $Null
    $IPv6DNS = $Null
    $IPv6DNS2 = $Null

    $IPv4Address = $Nic.IPv4Address
    $IPv4Address2 = $Nic.IPv4Address2
    $IPv4Gateway = $Nic.IPv4Gateway
    $IPv4SubnetMask = $Nic.IPv4SubnetMask
    $IPv4SubnetMask2 = $Nic.IPv4SubnetMask2
    $IPv4PrefixLength = $Nic.IPv4PrefixLength
    $IPv4DNS = $Nic.IPv4DNS
    $IPv4DNS2 = $Nic.IPv4DNS2
    $IPv6Address =  $Nic.IPv6Address
    $IPv6Gateway = $Nic.IPv6Gateway
    $IPv6PrefixLength = $Nic.IPv6PrefixLength
    $IPv6DNS = $Nic.IPv6DNS
    $IPv6DNS2 = $Nic.IPv6DNS2

    $V4Address=$IPv4Address+"/"+$IPv4PrefixLength

    If ($IPV4Address){
         "Netsh int ipv4 add address name=$Switch address=$IPv4Address mask=$IPv4SubnetMask"
        Netsh int ipv4 add address name=$Switch address=$IPv4Address mask=$IPv4SubnetMask
    }
    If ($IPV4Address2){
         "Netsh int ipv4 add address name=$Switch address=$IPv4Address2 mask=$IPv4SubnetMask2"
        Netsh int ipv4 add address name=$Switch address=$IPv4Address2 mask=$IPv4SubnetMask2
    }
    If ($Ipv4Gateway) {
            "Netsh int ipv4 add route prefix=0.0.0.0/0 interface=""$Switch"" nexthop=$IPv4Gateway"
            cmd.exe /c "Netsh int ipv4 add route prefix=0.0.0.0/0 interface=""$Switch"" nexthop=$IPv4Gateway "
    }
    If ($Ipv4DNS){
            "    Netsh int ipv4 add dnsservers name=$Switch address=$IPv4DNS "
            Netsh int ipv4 add dnsservers name=$Switch  address=$IPv4DNS  validate=no  
    }
    If ($Ipv4DNS2){
            "    Netsh int ipv4 add dnsservers name=$Switch address=$IPv4DNS2 "
            Netsh int ipv4 add dnsservers name=$Switch  address=$IPv4DNS2  validate=no  
    }
    If (-not $Nov6)
    {
        If ($IPv6Address)
        {
                "Netsh int ipv6 add address interface=$Switch address=$IPv6Address/$IPv6PrefixLength"
                Netsh int ipv6 add address interface=$Switch  address=$IPv6Address/$IPv6PrefixLength
        }
        If ($IPv6Gateway){
               "Netsh int ipv6 add route ::/0 $Switch $IPv6Gateway "
               cmd.exe /c "Netsh int ipv6 add route ::/0 ""$Switch"" $IPv6Gateway "
        }
    
        If ($IPv6DNS){
          "Netsh int ipv6 add dnsservers name=$Switch address=$IPv6DNS"
          Netsh int ipv6 add dnsservers name=$Switch  address=$IPv6DNS validate=No
       }
         If ($IPv6DNS2){
          "Netsh int ipv6 add dnsservers name=$Switch address=$IPv6DNS2"
          Netsh int ipv6 add dnsservers name=$Switch  address=$IPv6DNS2 validate=No
       }
    }
    
}



########################################## 
Function GetHash($FQDN)
{
    ipmo Microsoft.Powershell.Security   

    $c = Dir cert:\LocalMachine\My | Where-Object { $_.Subject –eq “CN=$FQDN” }
    write-host $c.Thumbprint

    Return $c.Thumbprint
}

################################################
#### Build Domain Controllers
Function BuildDC($DomainToCreate=$Domain,$DomainToCreateFQDN=$DomainFQDN,$DomainType="Primary",$SiteName="Default-First-Site-Name",$ParentDomainName)
{
    $AdminUser = $DomainToCreateFQDN+"\Administrator"
    $Pwd_Credential = ConvertTo-SecureString -AsPlainText $DefaultPassword -Force; 
    $Cred_Credential = New-Object System.Management.Automation.PSCredential($AdminUser, $Pwd_Credential); 
    $Pwd_SafeModeAdministratorPassword = ConvertTo-SecureString -AsPlainText $DefaultPassword -Force; 
    $Pwd_DNSDelegationCredential = ConvertTo-SecureString -AsPlainText $DefaultPassword -Force; 
    $Cred_DNSDelegationCredential = New-Object System.Management.Automation.PSCredential($AdminUser, $Pwd_DNSDelegationCredential)

    Switch ($DomainType)
    {
        "Primary"
        {
         "Starting ADDSForest for $DomainToCreateFQDN, Admin: $AdminUser "
         Install-ADDSForest  -DomainName $DomainToCreateFQDN -InstallDNS -DomainMode "Win2008R2" -ForestMode "Win2008R2"  -SafeModeAdministratorPassword $Pwd_SafeModeAdministratorPassword                         
        }

        "AdditionalDC"

        {
            "Starting ADDSDomaincontoller for $DomainToCreateFQDN, Admin: $AdminUser, DomainType:$DomainType"           
            Install-ADDSDomainController  -DomainName $DomainToCreateFQDN -InstallDNS -Credential $Cred_Credential -SafeModeAdministratorPassword $Pwd_SafeModeAdministratorPassword -SiteName $SiteName
        }


        "TreeDomain"
        {
            "Starting ADDSDomain for $DomainToCreateFQDN,  Domain: $DomaintoCreate, Admin: $AdminUser, DomainType:$DomainType "
            
            Install-ADDSDomain  -ParentDomainName $DomainToCreateFQDN -NewDomainName $DomainToCreate -InstallDNS  -DomainMode "Win2008R2"  -SafeModeAdministratorPassword $Pwd_SafeModeAdministratorPassword -Credential $Cred_Credential -DomainType TreeDomain -SiteName $SiteName
            
        }

        "ChildDomain"
        {
            "Starting ADDSDomain for $DomainToCreateFQDN, Domain: $DomaintoCreate, Admin: $AdminUser, DomainType:$DomainType "
            
            Install-ADDSDomain  -ParentDomainName $ParentDomainName -NewDomainName $DomaintoCreate -InstallDNS  -DomainMode "Win2008R2" -SafeModeAdministratorPassword $Pwd_SafeModeAdministratorPassword -Credential $Cred_Credential -DomainType ChildDomain -SiteName $SiteName
            
        }
    }

}

################################################ 
#### Build AD Sites
Function BuildADSites()
{
    "BuildADSites Called...giving system a few minutes to boot"
    timeout /t 45
    "Trying to start adws"
    start-service adws   
    
    "Creating new site"

    ipmo activedirectory

    new-adreplicationsubnet -name  "10.0.0.0/24"  -Site "Default-First-Site-Name" -Location $Domain -Description $Domain
    If (-not $nov6){
    new-adreplicationsubnet -name "2001:db8:DC::/48"  -Site "Default-First-Site-Name" -Location $Domain -Description $Domain  
    }

}


################################################ 
#### Build AD Account Information
Function BuildADAccount()
{

    Import-Module ActiveDirectory  
    #Create the User Account
    "Create the User Account"
    $UserAccount  = "User1@"+$DomainFQDN
    New-ADUser  -Name "User1" -AccountPassword (ConvertTo-SecureString -AsPlainText $DefaultPassword -Force) -Enabled $true –UserPrincipalName $UserAccount  
    #Create the Group Account
    "Create the Group Account"
    New-ADGroup DirectAccessClients Global  

    #Create a Win7 client group
    New-ADGroup DirectAccessClientsWin7 Global 

    #Set the expiry on the accounts

    #Set Administrator and User1 password to never expire
    Get-Aduser -Identity "Administrator" | Set-Aduser -PasswordNeverExpires $true -DisplayName "Administrator"
    Get-Aduser -Identity "User1"  | Set-ADUser -PasswordNeverExpires $true -DisplayName "User1"

    #Precreate the Computer Account
    "Precreate the Computer Account"
    New-ADComputer -Name "CLIENT1" -Enabled $true  
    New-ADComputer -Name "APP1" -Enabled $true  
    New-ADComputer -Name "APP2" -Enabled $true  
    New-ADComputer -Name "CLIENT-WIN7" -Enabled $true  

    #Place the Computer Account within the Group
    "Place the Computer Account within the Group"
    $MembertoAdd= "CN=CLIENT1,CN=Computers,"+$DomainX500
    Add-ADGroupMember DirectAccessClients -members $MembertoAdd
    $MembertoAdd= "CN=CLIENT-WIN7,CN=Computers,"+$DomainX500
    Add-ADGroupMember DirectAccessClientsWin7 -members  $MembertoAdd
    
    #Add machines and groups for e2e IPsec sections
    New-ADGroup DirectAccessAppServer Global 
    $MembertoAdd= "CN=APP1,CN=Computers,"+$DomainX500 
    Add-ADGroupMember DirectAccessAppServer -members $MembertoAdd
    $MembertoAdd= "CN=APP2,CN=Computers,"+$DomainX500 
    Add-ADGroupMember DirectAccessAppServer -members $MembertoAdd
}


#####################################
Function BuildWebServer($CorpSite="Washington",$Image="Washington.jpg",[switch]$Simple,[switch]$skipcopy)

{

$SimpleHomePage=@"
<%
    ip = Request.ServerVariables("REMOTE_ADDR")
    name = Request.ServerVariables("SERVER_NAME")
    lip =  Request.ServerVariables("LOCAL_ADDR")    
%>
<html>
<head><title>Welcome to $ID !</title>
<style type="text/css">
        Body
        {
            background-color: black;
            padding: 10px 10px 10px 10px;
color:white;
        }

</style>
</head>
<body>
<h1>Welcome to $ID!  <BR></h1>
<img src="$Image" width="300" />
<h3>Your IP is <u><%= ip %></u></h3>
<p>Server IP: <%= lip %></p>
</body>
</html>
"@

$ASPHomePage=@"
<%
    ip = Request.ServerVariables("REMOTE_ADDR")
    prefix = ""
    if Len(ip) >= 16 then
        prefix = Left(ip, 12)
        if prefix = "2001:db8:dc:" then
            ep = "Washington"
        else
            if prefix = "2001:db8:ba:" then
            ep = "Cloud"
        else
            ep = "France" 
            end if    
        end if    
    else
        ep = ""
    end if
    
%>
<html>
<head><title>Welcome to $ID! ($CorpSite)</title>
<style type="text/css">
        Body
        {
            background-color: black;
            padding: 10px 10px 10px 10px;
color:white;
        }

</style>
</head>
<body>
<h1>Welcome to $ID! ($Corpsite)</h1>
<img src="$Image" width="400" />
<% if ep = "" then %>
<p>You arrived through corp</p>
<% else %>
<h3>Your IP is <u><%= ip %></u></h3>
<h1>You arrived through the <u><%= ep %></u> entry point</h1>
<% end if %>
</body>
</html>

"@

    "Adding Web-Server."
    
    Import-Module ServerManager  
    Add-WindowsFeature Web-ASP  
    Add-WindowsFeature Web-Server  
    Add-WindowsFeature Web-Mgmt-Console  
    Add-WindowsFeature Web-ASP-NET45  
    Add-WindowsFeature Web-Windows-Auth  
    Add-WindowsFeature Web-Http-Tracing  

               
    If (-not $Skipcopy)
    {
        "Copying NCSI files."
        copy-item c:\config\ncsi.txt c:\inetpub\wwwroot\ncsi.txt  

   
        #If there is a web site directory for this machine name, then ignore the options, and just copy that stuff there.
        $WebCopypath = "c:\config\topologies\"+$WebSitesPath+$ID+"\wwwroot"
        "Testing Path $WebCopyPath"
        If (test-path $WebCopypath )
        {
            "Found Path $WebCopyPath, Begin Copy"
            copy-item $WebCopypath -destination c:\inetpub -recurse -force   
        }
        else
        {
             If ($simple)
                {
                $simplehomepage | out-file c:\inetpub\wwwroot\default.asp -Encoding ascii -force   
                }
                Else
                {
                $ASPHomePage | out-file c:\inetpub\wwwroot\default.asp -Encoding ascii -force   
                }
        
                "Copying Image: $Image "
                copy-item c:\config\images\$image -destination c:\inetpub\wwwroot\$image -force   
        }

    }
    Else
    {
    "Skipping the web server file copy."
    }
  
}

################################################
###### Add User1 to AD

Function AddUser1()
{
    $DefaultPassword = "Password123"
    $domain = get-addomain
    $DNSFQDN = $domain.dnsroot
    $UserAccount  = "User1@"+$DNSFQDN
    New-ADUser  -Name "User1" -AccountPassword (ConvertTo-SecureString -AsPlainText $DefaultPassword -Force) -Enabled $true –UserPrincipalName $UserAccount  

}
################################################
##### Install CA
Function InstallCA()
{
    #Steps to build CA:
    "Building CA using Powershell"
    import-module servermanager  
    add-windowsfeature adcs-cert-authority  
    add-windowsfeature RSAT-adcs -IncludeallSubFeature  
    Install-ADCSCertificationAuthority -catype enterpriserootca -force  
}

################################################
##### Build CA
Function BuildCA([switch]$SkipCRL)
{

    "Trying to start adws"
    start-service adws   
    timeout /t 60
    "ADWS Service Status"
    Get-service adws  | % {write-host $_.Status }

    "Waiting for Services to start"
    timeout /t 15
     
     #Lengthen Certificate and CRL validity periods and remove Delta CRLs.
    cmd.exe /c "Certutil -setreg ca\validityperiodunits 5 "
    cmd.exe /c "Certutil -setreg ca\CRLPeriod ""Years""  "
    cmd.exe /c "Certutil -setreg ca\CRLPeriodunits 5  "
    cmd.exe /c "Certutil -setreg ca\CRLDeltaPeriodUnits 0  "
    
    If ($SkipCRL)
    {
        cmd.exe /c "certutil -SetReg CA\CRLPublicationURLs \n"
    }
    else
    {
        "Add CDP Extension URLs"
        cmd.exe /c "certutil -setreg ca\CRLPublicationURLs ""65:%WINDIR%\System32\CertSrv\Certenroll\%%3%%8%%9.crl\n79:LDAP:///CN=%%7%%8,CN=%%2,CN=CDP,CN=Public Key Services,CN=Services,%%6%%10\n6:http://%%1/Certenroll/%%3%%8%%9.crl"" "

        "Modify AIA ExtensionURLs"
        cmd.exe /c "certutil -setreg ca\CACertPublicationURls ""1:%WINDIR%\System32\CertSrv\Certenroll\%%1_%%3%%4.crt\n2:LDAP:///CN=%%7,CN=AIA,CN=Public Key Services,CN=Services,%%6%%11\n2:http://%%1/Certenroll/%%1_%%3%%4.crt"" "
    }

    "Setting Machine Cert Template Permissions"
    SetCATemplatePerms Machine "Authenticated Users"    
    "Setting WebServer Cert Template Permissions"
    SetCATemplatePerms WebServer "Authenticated Users"    
    
    timeout /t 15
    "Restart the certsvc service"
    restart-service  certsvc
    timeout /t 15
}


################################################
#Create a schedule task in order or perform the CA Build
#For AWS Build

#This function loops until DA is configured
Function Get-DAReady()
{

        $retryCount = 0
        #Do best effort to make sure we can get the configration prior to proceeding.
        while (-not (Get-DAClientDnsConfiguration) -and ($retryCount -lt 120))
            {
                $retryCount++
                "Looping to test again: Retry $RetryCount"
                gpupdate /force
                Sleep -Seconds 120    
            }
        $NRPT = (Get-DAClientDnsConfiguration).NrptEntry 
        $dns64Address = (Get-DAClientDnsConfiguration).NrptEntry | ? {$_.DirectAccessDnsServers} | %{ $_.DirectAccessDnsServers }
        "NRPT Entry: "
        $NRPT
        "NRPT DNS Server Entry:$dns64Address "

}


Function StartTranscriptedCmd($FunctionCall,$VerificationFile)
{
    $Env:VMTPATH = "C:"

    #Set Logging Info
    $x = "BuildLog-"
    $y = Get-Date -format "%y-%M-%d_%h%m"
    
    $filename2 = "c:\cfn\log\" + $x+$y + "-transcript.txt"

    start-transcript -path $filename2 -ea 0
    "Transcripts are easier to read in Wordpad."

    #Set the name of the client

    $ID = $System.Name

    $WarningPreference = "SilentlyContinue"

    "Performing $FunctionCall writing to $VerificationFile"

    $result = invoke-expression "$FunctionCall"
    
    $result | out-file $VerificationFile

    Stop-Transcript

    Return $filename2

}


Function BuildTask($Server,$UserName, $Password,$Script, $TaskName, $Verify)
{

#Create the task - using ONLOGON to refer task execution 
$taskSetup = "`"`"schtasks.exe /Create /SC ONLOGON /V1 /F /S $Server /Z /RU `"$UserName`" /RP $Password /TN $TaskName /TR $Script  2>&1`"`""
"Executing $tasksetup "
$result = invoke-expression "cmd.exe /c $taskSetup"

$result

#Run the task on demand
$taskSetup = "`"`"schtasks.exe /run /TN $Taskname 2>&1`"`""
"Executing $tasksetup"
$result = invoke-expression "cmd.exe /c $taskSetup"
$result

#Wait until the verification file has been created, and then remove the task
    do
    {
        "Not done. Waiting for $Verify, Looping every 5 seconds"
        start-sleep -s 5
    }
    Until (test-path $Verify)

#Remove the task
$taskSetup = "`"`"schtasks.exe /delete /TN $TaskName /F 2>&1`"`""
"Executing $tasksetup"
$result = invoke-expression "cmd.exe /c $taskSetup"
$result

}


################################################
##### Build NLB Feature
Function BuildNLB()
{

    "Import Module Server Manager"
    
    import-module ServerManager  
    "Adding Network Load Balancing Feature"

    add-windowsfeature NLB -IncludeAllSubFeature  
    "Adding Network Load Balancing GUI"
    add-windowsfeature RSAT-NLB  
}


################################################
##### Prep BaselineConfig
Function BuildBaseConfig()
{
  
    "Disable NLA Prompt"
    Regedit -regaction Add -regkey "HKLM:System\CurrentControlSet\Control\Network\NewNetworkWindowOff" -regname ExecutionPolicy
    Regedit -regaction Delete -regkey "HKLM:Software\Microsoft\Windows\CurrentVersion\Run" -regname "ServerReliabilityConfig"

}
##############################################
Function RegEdit($RegAction,$Regkey,$Regname,$RegValue=$Null,$RegType="String")
{
    $RegPathExists = Get-Item $regkey  -ErrorAction SilentlyContinue
    $regexists = Get-ItemProperty $regkey $regname -ErrorAction SilentlyContinue

    "-----------------------------------------------------"   
    "   Registry Edit (Add/Delete) "
    "    Test Key   : $RegKey "
    "    Test Value : $Regname "

    Switch ($RegAction)
    {
    "Delete"        
        {
                  
            If ($Regexists)
            {
                "    Test Existing  : Present" 
                "    Performing     : Remove-ItemProperty" 
                $TempResult = Remove-ItemProperty -path $regkey -name $regname -ErrorAction SilentlyContinue
            }
            Else
            {
                "    Found Existing : Not Present" 
                "    Found Existing : This is ok since it was to be deleted" 
            }
        }
    "Add"
        {
              
            if ($RegPathExists)
            {
                    "    Test Existing  : Present" 
            }
            Else
            {
                    "    Found Existing : Not Present" 
                    "    Found Existing : This is ok since it was to be created" 
                    "    Performing     : New-item" 
                    $TempResult = New-Item -Path $regkey -ErrorAction SilentlyContinue
            }

            If ($Regexists)
            {
                    "    Test Existing  : Present" 
                    "    Found Existing : This is ok since were are going to overwrite" 
            }
            
            "    Add: New-ItemProperty " 
            "       :    -PropertyType $regtype"
            "       :    -Value $regvalue -force"
            $TempResult = New-ItemProperty -Path $regkey -Name $regname -PropertyType $regtype -Value $regvalue -force -ErrorAction SilentlyContinue
        }
    
    }
    
}
##############################################
Function BuildBasePrepDC()
{

        "Add GPMC"
        add-windowsfeature GPMC   

        "Adding AD-Tools using server mangager "
        add-windowsfeature RSAT-AD-Tools -IncludeAllSubFeature   
        
        "RSAT-ADDS-Tools-Feature"
        add-windowsfeature RSAT-ADDS -IncludeAllSubFeature  

        "DirectoryServices-DomainController-Tools"
        Try
        {
        add-windowsfeature AD-Domain-Services -IncludeAllSubFeature  -erroraction stop  
        }
        Catch
        {
         ResetBoot
        }
   
}

##############################################
Function BuildNAT($Target)
{
    "Adding NAT"
    ipmo servermanager
    add-windowsfeature routing
    cmd.exe /c "netsh routing ip nat install"
    cmd.exe /c "netsh routing ip nat add interface ""private internet"" "
    cmd.exe /c "netsh routing ip nat set int name=""private internet"" mode=full"
    cmd.exe /c "netsh routing ip nat add portmapping name=""private internet"" proto=tcp publicip=0.0.0.0 publicport=80 privateip=$Target privateport=80"
    cmd.exe /c "netsh routing ip nat add portmapping name=""private internet"" proto=tcp publicip=0.0.0.0 publicport=443 privateip=$Target privateport=443"
    cmd.exe /c "netsh routing ip nat add portmapping name=""private internet"" proto=tcp publicip=0.0.0.0 publicport=3389 privateip=$Target privateport=3389"
    "Allow DNS inbound on the NAT device"
    New-NetFirewallRule -Displayname "Allow DNS for NAT" -Protocol UDP -LocalPort 53
}


###############################################
Function EnableTSandFP()
{
     #This is so the clients can test of DC is work by looking for the done.txt
    "File and Print Sharing "  
    Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"  
    Set-NetFirewallRule -DisplayGroup "File and Printer Sharing" -Profile Public,Private,Domain -enabled true  

    #Create  Share
    "Creating C:\files"
   
    mkdir "C:\files" -ea 0

    "Creating Share \files"
    cmd.exe /c "net share Files=C:\files"  
    "Copy example.txt"

    get-date | out-file c:\files\example.txt

    #This supports the TS to the DC part of the demo. 
    "TS enable"
    regedit -regaction add -regkey "HKLM:SYSTEM\CurrentControlSet\Control\Terminal Server" -regname fDenyTSConnections -regvalue "0" -regtype Dword   
    #cmd.exe /c "reg ADD ""HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server"" /v fDenyTSConnections /t REG_DWORD /d 0 /f"  
    "Remote Desktop Firewall Enable" 
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"  

}

#############################
Function AddDNS()
{

                "Starting Build DNS Server"
                    "Building DNS Server for Server 2012 "
                    import-module ServerManager  
                    try
                    {
                    add-windowsfeature DNS -IncludeAllSubFeature -ea 0 
                    }
                    catch
                    {
                    "Resetting Boot: add-windowsfeature DNS -IncludeAllSubFeature -ea 0 "
                    resetboot
                    
                    }

                    try
                    {
                    add-windowsfeature RSAT-DNS-Server  -ea 0
                    }
                    catch
                    {
                    "Resetting Boot: add-windowsfeature RSAT-DNS-Server  -ea 0 "
                    resetboot
                    
                    }

                "Finished BuildDNS Server"
                
}
#############################
Function AddDHCP()
{
        "Starting BuildDHCP Server" 
        "Building DHCP Server using PS on Server 2012"
        import-module ServerManager  
        try
        {
        add-windowsfeature DHCP -IncludeAllSubFeature  -ErrorAction Stop
        }
        Catch
        {
        "Resetting Boot: add-windowsfeature DHCP -IncludeAllSubFeature  -ea 0 "
        ResetBoot
        RestartPC
        }

        try
        {
        add-windowsfeature RSAT-DHCP -ea 0   
        }
        catch
        {
        "Resetting Boot: add-windowsfeature RSAT-DHCP -ea 0   "
        ResetBoot
        RestartPC
        }

       "Finished BuildDHCP Server"

}
################################################
Function FixDHCPServer($Value="10.0.0.1",$ScopeID="10.0.0.0")
{
    #Adding this due to a problem with the DC1 not getting the DNS Server added correctly.

    Do
    {
         "Testing DNS"
         $Test = Get-Service DNS
    }
    While ($test.Status -ne "Running")

    Try
    {
        "Resetting DNS Server Value after DNS started: Value: $Value, ScopeID: $ScopeID "
        Set-DhcpServerv4OptionValue -ComputerName $ID -OptionId 6 -Value $Value -ScopeId $ScopeID 
    }
    Catch
    {
        "Still failed, issuing warning, but trying one more time, most clients have hardcoded settings, so this should not be a critical failure."
        Set-DhcpServerv4OptionValue -ComputerName $ID -OptionId 6 -Value $Value -ScopeId $ScopeID 
    }           

}


#############################
function Disable-Corp()
{
    "Issuing: disable-netadapter Private Corpnet"
    disable-netadapter "Private Corpnet" -ea 0

}

#############################
function RemoveV6($PassedIP)
{
    "Issuing: remove-NetIpAddress -AddressFamily Ipv6 -IPv6Address $PassedIP "
    remove-NetIpAddress -AddressFamily Ipv6 -IPv6Address $PassedIP

}

#############################
function Disable-Home()
{
    "Issuing: disable-netadapter Private HomeNet"
    disable-netadapter "Private HomeNet" -ea 0  

}

#############################
function UpdateGP()
{
    cmd.exe /c "gpupdate /target:computer /force"    
 
}

#############################
function RestartPC()
{
    "    Setting RebootNeeded Flag"
    $global:RebootNeeded = $True

    #"Issuing: restart-computer -force"
    #restart-computer -force

}

######################################### Set CATemplatePerms
Function SetCATemplatePerms( $certificateTemplate, $objectName )

{

    import-module ActiveDirectory

    $ExtendedRightsCommonName = "CN=Extended-Rights"
    $CertificateEnrollmentCommonName = "CN=Certificate-Enrollment"
    $certificateTemplateCN = "CN=Certificate Templates"
    $publickeyServicesCN= "CN=Public Key Services"
    $serviceCN = "CN=Services"

    function GetExtendedRightsGuid( [string] $name )
    {
    $dse = [adsi]"LDAP://RootDSE"
    $host.UI.WriteLine("ADSE = " + $dse.defaultNamingContext)
    $basedn = "LDAP://" + $name + "," +$ExtendedRightsCommonName + ","+$dse.configurationNamingContext
    write-host "BaseDN =  $basedn "
    $er = [adsi]$basedn
    return $er.rightsGuid
    }

    function GetCertificateEnrollmentGuid()
    {
     return . GetExtendedRightsGuid $CertificateEnrollmentCommonName 
    }

    function GetBaseDnForCertificateTemplate( [string] $certTemplateName )
    {
    $baseDn = "AD:\CN=" + $certTemplateName + "," + $certificateTemplateCN + "," + $publicKeyServicesCN + "," + $serviceCN + ","+ $dse.configurationNamingContext

    write-host "Base DN =  + $baseDn "
    
    return $baseDn
    }

    function CreateNewACE( [string] $account, [string] $guidStr )
    {
    $identity = New-Object System.Security.Principal.NTAccount( $account )
    $adRights = [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight
    $aclType = [System.Security.AccessControl.AccessControlType]::Allow
    $inheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::None
    $guid = New-Object GUID( $guidStr )
    if( $? -eq $false )
    {
        return $NULL
    }

    $ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule( $identity, $adRights, $aclType, $guid, $inheritanceType )
    if( $? -eq $false )
    {
        return $NULL
    }
    return $ace
    }

    function SetPermissions( [string]$object, [string] $certTemplate )
    {
    $guid = . GetCertificateEnrollmentGuid
    write-host "Certificate Enrollment GUID is  $guid "
    $domain = Get-ADDomain
    if( $? -eq $false )
    {
        return $false
    }
    $domainNetbiosName = $domain.NetBIOSName

    #$account = $domainNetbiosName + "\" + $object
    $account = $object

    write-host "Creating new ACE for account: $domainNetbiosName \ $object to include certificate enrollment" 

    $ace = . CreateNewACE    $account $guid
    if ( $ace -eq $null )
    {
        return $false
    }
    
    write-host "Retriveing the ACL cert template: $certTemplate" 

    $baseDn= . GetBaseDnForCertificateTemplate( $certTemplate  )
    $acl = Get-Acl $baseDn    
    if($? -eq $false )
    {
        write-host "Return value :  $? : $error[0] "
        return $false
    }

    write-host "Adding the ACE to the ACL" 

    $acl.AddAccessRule($ace)
    if( $? -eq $false )
    {
        return $false
    }
    Set-Acl $baseDn $acl
    if($? -eq $false )
    {
        write-host "$error[0] "
        return $false
    }

    return $true
    
    }

    $return = . SetPermissions $objectName $certificateTemplate
    if( $return -eq $false )
    {
     write-host "ERROR  - Not Successful"
    }
    else
    {
        write-host "Setting permissions done successfully"
    }
}



#############################
function Get-IPHTTPS()
{
   write-host  "Issuing: Get-NetIPAddress | where {$_.InterfaceAlias -like IPHTTPSInterface}  "
    Get-NetIPAddress| where {$_.InterfaceAlias -like "IPHTTPSInterface"} | fl ipv6address
}
