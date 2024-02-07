Import-Module ServerManager
Add-WindowsFeature Web-ASP 
Add-WindowsFeature Web-Server  
Add-WindowsFeature Web-Mgmt-Console 
Add-WindowsFeature Web-ASP-NET45 
Add-WindowsFeature Web-Windows-Auth 
Add-WindowsFeature Web-Http-Tracing 
write-host "Allowing everyone write to web server directory" 
cmd.exe /c "icacls ""c:\inetpub"" /grant ""everyone"":(OI)(CI)F /inheritance:r " 
$ID = hostname 
$SimpleHomePage=" <% `n " 
$SimpleHomePage+=" ip = Request.ServerVariables(""REMOTE_ADDR"") `n " 
$SimpleHomePage+=" name = Request.ServerVariables(""SERVER_NAME"") `n " 
$SimpleHomePage+=" lip =  Request.ServerVariables(""LOCAL_ADDR"") `n " 
$SimpleHomePage+=" %> `n " 
$SimpleHomePage+=" <html><head><title>Welcome to $ID !</title></head><body><h1>Welcome to $ID!  <BR></h1><h3>Your IP is <u><%= ip %></u></h3><p>Server IP: <%= lip %></p></body></html> `n " 
$SimpleHomepage | out-file c:\inetpub\wwwroot\default.asp -Encoding ascii -force  
