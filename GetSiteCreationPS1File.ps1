import-module BitsTransfer 
Start-BitsTransfer -Source http://s3.amazonaws.com/CFN_Templates/Create-NewADSite_V2.ps1 -Destination c:\cfn\scripts\Create-NewADSite.ps1
Start-BitsTransfer -Source http://s3.amazonaws.com/CFN_Templates/FinalizeAD.ps1 -Destination c:\cfn\scripts\FinalizeAD.ps1
