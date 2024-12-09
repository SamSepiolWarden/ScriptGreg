function Get-DeviceExtensionAttributes {
    param (
        [string]$DeviceId
    )
    try {
        $device = Get-MgDevice -DeviceId $DeviceId
        $extensionAttributes = $device.AdditionalProperties.extensionAttributes
        Write-Host "Current extension attributes for device $($device.DisplayName):" -ForegroundColor Cyan
        $extensionAttributes | Format-Table | Out-String | Write-Host
    }
    catch {
        Write-Host "Failed to retrieve extension attributes for device ID $DeviceId" -ForegroundColor Red
    }
}

Connect-MgGraph
while ($true) {
    # Import the CSV
    $DeviceList = Import-Csv -Path "C:\Test\DeviceList.csv"
    $AskExtensionNumber = Read-Host -Prompt 'Which number of extension do you want to add or remove?'
    $AskExtensionName = Read-Host -Prompt 'What is the extension name?'

    # Loop through each device in the CSV
    foreach ($Device in $DeviceList) {
        $DeviceName = $Device.DeviceName
        $DeviceId = (Get-MgDevice -Filter "displayName eq '$DeviceName'").id

        # Show current extension attributes
        Get-DeviceExtensionAttributes -DeviceId $DeviceId

        $Params = @{
            "extensionAttributes" = @{
                "extensionAttribute$AskExtensionNumber" = $AskExtensionName
            }
        }
        $BodyParameter = $Params | ConvertTo-Json

        Update-Mgdevice -DeviceId $DeviceId -BodyParameter $BodyParameter
        if ($?) {
            Write-Host "Device $DeviceName updated successfully" -ForegroundColor Green
        }
        else {
            Write-Host "Failed to update device $DeviceName" -ForegroundColor Red
        }
       
        Get-DeviceExtensionAttributes -DeviceId $DeviceId
        Start-Sleep -Seconds 5
    }

    # Ask the user if they want to add another device
    $continue = Read-Host -Prompt "Do you want to add other Devices? (Y/N)"
    if ($continue -ne 'Y') {
        break
    }
}
Disconnect-MgGraph
