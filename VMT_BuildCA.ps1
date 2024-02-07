. C:\cfn\scripts\ClientHelperfunctions.ps1
#BuildCAWrapper
$Verify = "c:\cfn\log\VMT_BuildCA_Done.txt " 
$Loglocation = StartTranscriptedCmd -FunctionCall BuildCA -VerificationFile $Verify 
$Loglocation
