. C:\cfn\scripts\ClientHelperfunctions.ps1
#Building CA using Powershell
import-module servermanager 
add-windowsfeature adcs-cert-authority
add-windowsfeature RSAT-adcs -IncludeallSubFeature  
Install-ADCSCertificationAuthority -catype enterpriserootca -force 
