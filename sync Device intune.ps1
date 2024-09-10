#Connect to msgraph
Connect-MSGraph

#Import the CSV file with the list of user ids
$Devices = Import-Csv -Path "C:\Test\Devices.csv"

#Do a for each for invoke a sync for each user
foreach ($Device in $Devices)
{
    #Invoke the sync
    Invoke-IntuneManagedDeviceSyncDevice -managedDeviceId $Device.DeviceId
    Write-Host  "Synced Device:  ($Device.managedDeviceId)" -ForegroundColor Yellow
}