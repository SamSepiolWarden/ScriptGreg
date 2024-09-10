Connect-MSGraph
$Devices = Get-IntuneManagedDevice -Filter "contains(operatingsystem,'Windows')"
 
Foreach ($Device in $Devices)
{
 
Invoke-IntuneManagedDeviceSyncDevice -managedDeviceId $Device.managedDeviceId
Write-Host "Sending Sync request to Device with DeviceID $($Device.managedDeviceId)" -ForegroundColor Yellow
 
}
