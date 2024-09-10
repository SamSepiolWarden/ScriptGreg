Connect-MgGraph
$Devices = Get-MgDeviceManagementManagedDevice -Top 999
$AddToExport = @()
# get the informations of the device
$Devices | Select-Object DeviceName, DeviceCategoryDisplayName
foreach ($Device in $Devices)
{ 
    $AddToExport += [PSCustomObject]@{
        DeviceName = $Device.DeviceName
        DeviceCategory = $Device.DeviceCategoryDisplayName
    }
}
$AddToExport | Export-Csv -Path "C:\Users\GregorySemedo\Desktop\DeviceCategory.csv" -NoTypeInformation

Disconnect-MgGraph