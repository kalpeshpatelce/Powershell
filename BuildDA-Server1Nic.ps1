
######################################################
##### Virtual Machine Topology Generator
##### DirectAccess Single Nic Scenario
#####
##### V.03   June 28 2016 andrew@meyercord.org
#####   Reduce default instance sizes to t2.micro for Free Tier compatibility
##### V.02   May 30 2014  scorob@amazon.com
#####   Initial Release 
#####


cls

 "------------------------------------------------------------------------"
 "Virtual Machine Topology Generator: DirectAccess Single Nic"
 "------------------------------------------------------------------------"
 ""
 write-host "Warning: You MUST edit this script to configure your KeyPair and Domain" -ForegroundColor Red
 write-host "         DO NOT proceed if you have not edited this file!" -ForegroundColor Red
 ""
 "Please Note:"
 " This script will create resources in EC2 using AWS CloudFormation"
 " Ensure you have the region set as desired."
 " Also make sure your account credentials hvae permissions to create "
 " resources in the active region."  
 ""
 " Break the script now to edit the configuration"
 "------------------------------------------------------------------------"

pause

##################################################
### You MUST Edit the KeyPair and Domain values.
$KeyPairName = "Editme"

#This script assumes this is Route53 hosted. STOP NOW if you don't have a route 53 hosted domain
$DomainType ="EditMe"
$RootDomain = "EditMe"
$SubDomain = "EditMe"
$EdgePrefix = "EditMe"

# Double check that the user really edited the file.
$EditedValues = @($KeyPairName,$DomainType,$RootDomain,$SubDomain,$EdgePrefix)
ForEach($EditedValue in $EditedValues)
{
    If($EditedValue -eq "EditMe")
    {
        Write-Host "You must edit the script. Please edit and try again." -ForegroundColor Red
        exit
    }
}

#####################################
$SupportFunctionsDest   = ".\CFNFunctions.ps1"

. $SupportFunctionsDest

#####################################
Start-TopologyLogging -Function DA
#####################################

### NAT Settings
$NatStackName  = "WindowsNAT"
#$NatInstanceType = "m3.medium"
$NatInstanceType = "t2.micro" #Free Tier eligible
$NatTemplate   = "https://s3-us-west-2.amazonaws.com/vmtool/BuildNatForDA.template"
$ProxyTargetIP = "10.0.1.20"

#Other Server Instance Types
#$InstanceType = "m3.medium"
$InstanceType = "t2.micro" #Free Tier eligible
$DCStackName = "DC1"
$DCTemplate = "https://s3-us-west-2.amazonaws.com/vmtool/BuildDA-DC1.template"

######################################
### DirectAccess Settings

$DAStackName = "EDGE1"
$DATemplate = "https://s3-us-west-2.amazonaws.com/vmtool/BuildDA-Server1Nic.template"

#################################
### Client Settings

$ClientStackName = "CLIENT1"
$ClientTemplate = "https://s3-us-west-2.amazonaws.com/vmtool/BuildDA-Client.template"

######################################
### Load Values Settings
[datetime]$StartTime = Get-Date
#This line finds the current AMI ID for Server 2012 R2
$Server2012R2AMIID = Get-Server2012R2AMIID

If (!($Server2012R2AMIID))
{
    Write-Host "Failed to retrieve Server 2012 R2 AMI ID!" -ForegroundColor Red
    exit
}
###########################################
### Begin NAT Creation

# First parameter
$Nat1 = new-object Amazon.CloudFormation.Model.Parameter
$Nat1.ParameterKey = "0KeyPairName"
$Nat1.ParameterValue = $KeyPairName

# First parameter
$Nat2 = new-object Amazon.CloudFormation.Model.Parameter
$Nat2.ParameterKey = "ProxyTargetIP"
$Nat2.ParameterValue = $ProxyTargetIP

# First parameter
$Nat3 = new-object Amazon.CloudFormation.Model.Parameter
$Nat3.ParameterKey = "AMIID"
$Nat3.ParameterValue = $Server2012R2AMIID

# First parameter
$Nat4 = new-object Amazon.CloudFormation.Model.Parameter
$Nat4.ParameterKey = "NatInstanceType"
$Nat4.ParameterValue = $NatInstanceType

$NatValues = @($Nat1,$Nat2,$Nat3,$Nat4)
BuildStack -StackName $NatStackName -Values $NatValues -PassedTemplate $NatTemplate

#Read the output of the NAT stack and pass those values to the rest of the stack. Items such as VPC ID are required.
$Values = BuildValues

################################
### Build DC 

BuildStack -StackName $DCStackName -Values $Values -PassedTemplate $DCTemplate -Dependson $NATStackName

################################
### DirectAccess Section

BuildStack -StackName $DAStackName -Values $Values -PassedTemplate $DATemplate -Dependson $DCStackName

################################
### Client Section

#Only a subset of the values are required for the client stack, paring things down
$ClientValues = @($Values[0],$Values[1],$values[4],$values[11],$values[12])

BuildStack -StackName $ClientStackName -Values $ClientValues -PassedTemplate $ClientTemplate -Dependson $DAStackName

################################
### End

[datetime]$Time = Get-Date
$TimeToBuildScript = New-TimeSpan -Start $StartTime -End $Time
$TimeToBuildScriptMin = $TimeToBuildScript.Minutes
$TimeToBuildScriptHours = $TimeToBuildScript.Hours

"------------------------------------------------------------------------"
"Script Complete -- Time to Complete (Hrs.Mins): $TimeToBuildScriptHours.$TimeToBuildScriptMin "
"------------------------------------------------------------------------"
 
If ($StartedLogging -eq $True)
{
    stop-transcript -ea 0
}         