Connect-AzureAD

# Get all devices without autopilot
$devices = Get-AzureADDevice -All $true | Where-Object { -not ($_.DevicePhysicalIds -like '*ZTDId*') -and $_.DeviceOstype -eq 'Windows'}


# Creer une variable pour enregistrer les informations de chaque appareil
$deviceInfo = @()

# Add each devices in the device info variable
foreach ($device in $devices) {
    $deviceInfo += [PSCustomObject]@{
        "DeviceName" = $device.DisplayName
        "DeviceID" = $device.ObjectId }
    }

# Export the device info variable to a CSV file
$deviceInfo | Export-Csv -Path "C:\test\deviceInfo.csv" -NoTypeInformation
Disconnect-AzureAD
        