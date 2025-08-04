# Set the URL and destination path
$downloadUrl = "https://amazoncloudwatch-agent.s3.amazonaws.com/windows/amd64/latest/amazon-cloudwatch-agent.msi"
$localInstallerPath = "C:\Users\Administrator\Downloads\amazon-cloudwatch-agent.msi"

# Download the CloudWatch Agent installer
Invoke-WebRequest -Uri $downloadUrl -OutFile $localInstallerPath

$localInstallerPath = "C:\Users\Administrator\Downloads\amazon-cloudwatch-agent.msi"

# Install the MSI silently
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$localInstallerPath`" /quiet" -Wait

# Confirm installation by checking the service
$service = Get-Service -Name "AmazonCloudWatchAgent" -ErrorAction SilentlyContinue
if ($service) {
    Write-Host "✅ CloudWatch Agent installed successfully. Status: $($service.Status)"
} else {
    Write-Host "❌ CloudWatch Agent installation failed or service not found."
}
