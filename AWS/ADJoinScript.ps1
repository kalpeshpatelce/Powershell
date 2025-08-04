# Step 1: Set DNS Servers (Ensure domain resolution works)
$dnsServers = "10.0.2.7","10.0.1.157"

# Get the name of the active Ethernet adapter (skip loopback, virtual, etc.)
$adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up" -and $_.HardwareInterface -eq $true} | Select-Object -First 1

# Apply DNS settings
Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses $dnsServers

# Step 2: Define domain join parameters
$domainName = "zydus.emc.test"
$ouPath = "OU=zydus,DC=zydus,DC=emc,DC=testt"  # Optional, or remove if not needed
$domainUsername = "Admin"
$password = "Techn0logy@123"  # Use a secure method in production

# Convert to secure string and create credential
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($domainUsername, $securePassword)

# Step 3: Join domain
Add-Computer -DomainName $domainName -Credential $credential -Restart -Force
