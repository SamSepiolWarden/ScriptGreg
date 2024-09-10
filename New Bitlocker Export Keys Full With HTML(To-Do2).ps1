# Connect to Graph
Connect-MgGraph -Scopes "BitlockerKey.Read.All","DeviceManagementManagedDevices.Read.All"

# Get all the Bitlocker/Filevault recovery keys and their associated DeviceId
$allDevices = Get-MgDeviceManagementManagedDevice -All:$true
Write-Host "Total Devices: $($allDevices.Count)"

$allKeys = Get-MgInformationProtectionBitlockerRecoveryKey -All:$true -Property "DeviceId"
Write-Host "Total Keys: $($allKeys.Count)"

# Filter out only Windows and Mac devices
$filteredDevices = $allDevices | Where-Object { $_.OperatingSystem -eq "Windows" -or $_.OperatingSystem -eq "MacOS" }
Write-Host "Filtered Devices: $($filteredDevices.Count)"

# Check if filtered devices is empty
if ($filteredDevices.Count -eq 0) {
    Write-Host "No Windows or macOS devices found."
}

# Create an associative array to store DeviceId and their corresponding device name
$deviceNameMapping = @{}
foreach ($device in $filteredDevices) {
    $deviceNameMapping[$device.AzureAdDeviceId] = $device.DeviceName
}

# Enhance the list with device display names and their Bitlocker/Filevault keys
$DeviceDetails = @()

foreach ($device in $filteredDevices) {
    if ($device.OperatingSystem -eq "Windows") {
        $keys = $allKeys | Where-Object { $_.DeviceId -eq $device.AzureAdDeviceId }
        foreach ($key in $keys) {
            $bitlockerKey = Get-MgInformationProtectionBitlockerRecoveryKey -BitlockerRecoveryKeyId $key.Id -Property "key"
            $DeviceDetails += [PSCustomObject]@{
                'DeviceId'    = $key.DeviceId
                'KeyId'       = $key.Id
                'DisplayName' = $deviceNameMapping[$key.DeviceId]
                'Key'         = $bitlockerKey.Key
                'KeyType'     = "Bitlocker"
            }
        }
    }
    elseif ($device.OperatingSystem -eq "MacOS") {
        $fileVaultKey = Get-MgBetaDeviceManagementManagedDeviceFileVaultKey -ManagedDeviceId $device.Id
        $DeviceDetails += [PSCustomObject]@{
            'DeviceId'    = $device.Id
            'DisplayName' = $device.DeviceName
            'Key'         = $fileVaultKey.Value
            'KeyType'     = "FileVault"
        }
    }
}

Write-Host "Total Device Details: $($DeviceDetails.Count)"

# Check if device details is empty
if ($DeviceDetails.Count -eq 0) {
    Write-Host "No device details found after mapping with keys."
}
# Custom CSS for HTML table borders
$css = @"
<style>
    table {
        border-collapse: collapse;
        width: 100%;
    }
    th, td {
        border: 1px solid black;
        padding: 8px;
        text-align: left;
    }
    th {
        background-color: #f2f2f2;
    }
</style>
"@



# Export the enhanced list to CSV
$csvExportPath = "C:\Test\DeviceKeysWithDetails.csv"
$DeviceDetails | Export-Csv -Path $csvExportPath -NoTypeInformation
Write-Host "Exported data to CSV at: $csvExportPath"

# Export the enhanced list to HTML
$htmlExportPath = "C:\Test\DeviceKeysWithDetails.html"
$DeviceDetails | ConvertTo-Html -Title "Device Keys Details" -PreContent "<h1>Device Keys Details</h1>" -Head $css | Out-File -FilePath $htmlExportPath
Write-Host "Exported data to HTML at: $htmlExportPath"

# Disconnect from Graph
Disconnect-MgGraph
