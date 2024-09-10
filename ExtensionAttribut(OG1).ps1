# Connect to Microsoft Graph API
Connect-MgGraph
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
while ($true) {
    $DeviceName = Read-Host -Prompt 'Enter the device name'
    while ($DeviceName -eq '') {
        Write-Host "Device name cannot be empty" -ForegroundColor Yellow
        $DeviceName = Read-Host -Prompt 'Enter the device name'
        
    }
    $DeviceId = (Get-MgDevice -Filter "displayName eq '$DeviceName'").id
    Get-DeviceExtensionAttributes -DeviceId $DeviceId
    $ExtensionNumber = Read-Host -Prompt 'Enter the extension number'
    while ($ExtensionNumber -eq '') {
        Write-Host "Extension number cannot be empty" -ForegroundColor Yellow
        $ExtensionNumber = Read-Host -Prompt 'Enter the extension number'
    }
    $ExtensionName = Read-Host -Prompt 'Enter the extension name'

    $Params = @{
        "extensionAttributes" = @{
            "extensionAttribute$ExtensionNumber" = $ExtensionName
        } 
    }
    $BodyParameter = $Params | ConvertTo-Json

    # Update Device
    Update-MgDevice -DeviceId $DeviceId -BodyParameter $BodyParameter
    if ($?) {
        Write-Host "Device $DeviceName updated successfully" -ForegroundColor Green 
    }
    else {
        Write-Host "Failed to update device $DeviceName" -ForegroundColor Red
    }
    Start-sleep -Seconds 5 
    # Show current extension attributes
    Get-DeviceExtensionAttributes -DeviceId $DeviceId

    # Ask the user if they want to add another user
    $continue = Read-Host -Prompt "Do you want to add another Device? (Y/N)"
    if ($continue -ne 'Y') {
        break
    }
}

# Disconnect from Microsoft Graph API
Disconnect-Mggraph
