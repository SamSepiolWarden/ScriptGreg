Connect-MgGraph
$Devices = Get-MgDeviceManagementManagedDevice -Top 999
$AddToExport = @()
# get the informations of the device
$Devices | Select-Object -ExpandProperty Model, Manufacturer, OSVersion, DeviceName, DeviceCategory
foreach ($Device in $Devices)
{ 
    $AddToExport += [PSCustomObject]@{
        Model = $Device.Model
        Manufacturer = $Device.Manufacturer
        OSVersion = $Device.OSVersion
        DeviceName = $Device.DeviceName
        DeviceCategory = $Device.DeviceCategory
    }
}
$AddToExport | Export-Csv -Path "C:\Users\GregorySemedo\Desktop\DeviceIntel.csv" -NoTypeInformation