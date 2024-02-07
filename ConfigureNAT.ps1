$PrivateAlias = """Private Corpnet""" 
$PublicAlias  = """Public Internet""" 
$ProxyTargetIP = "10.0.1.20"
Import-Module ServerManager
Add-WindowsFeature Routing  -ea stop  -verbose 
install-remoteaccess -vpntype vpn -verbose 
cmd.exe /c "netsh routing ip nat install " 
cmd.exe /c "netsh routing ip nat add interface $PublicAlias "  
cmd.exe /c "netsh routing ip nat set int name=$PublicAlias mode=full"  
cmd.exe /c "netsh routing ip nat add interface $PrivateAlias "  
cmd.exe /c "netsh routing ip nat set int name=$PrivateAlias mode=private" 
cmd.exe /c "netsh routing ip nat add portmapping name=$PublicAlias proto=tcp publicip=0.0.0.0 publicport=80 privateip=$ProxyTargetIP privateport=80" 
cmd.exe /c "netsh routing ip nat add portmapping name=$PublicAlias proto=tcp publicip=0.0.0.0 publicport=443 privateip=$ProxyTargetIP privateport=443" 
