# Connect to Graph

$TenantID = "be604c81-3a82-4eb5-bfbd-7808103267fb"
$Connection = Invoke-RestMethod -Uri https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token


# Prepare token
$token = $Connection.access_token
$headers = @{
  'Authorization' = "Bearer $token"
}
Connect-MgGraph
# Obtain all devices  
$allDevices = Get-MgDeviceManagementManagedDevice -All:$true 

# Filter macOS devices
$macDevices = $allDevices | Where-Object { $_.OperatingSystem -eq "MacOS" }
# Get FileVault keys
$DeviceDetails = foreach ($device in $macDevices) {
  $uri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($device.id)/getFileVaultKey"
  try {
    $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post     
    [PSCustomObject]@{
      'DeviceId' = $device.id
      'DisplayName' = $device.deviceName
      'FileVaultKey' = $response.key
    }
  } catch {
    Write-Warning "Error getting key for $($device.deviceName): $_"
  }
}

# Export CSV 
$exportPath = "C:\Test\FileVaultKeys.csv"
$DeviceDetails | Export-Csv -Path $exportPath -NoTypeInformation

Write-Host "Exported to $exportPath"

# Disconnect Graph
Disconnect-MgGraph