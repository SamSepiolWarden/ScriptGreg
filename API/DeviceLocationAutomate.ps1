# Connect to Microsoft Graph API
Connect-MgGraph -Scopes "Directory.AccessAsUser.All", "User.Read.All"

# Initialize arrays for reporting
$devicesWithoutUsers = @()
$processedDevices = @()

# Get all devices
$devices = Get-MgDevice -All | Where-Object { $_.OperatingSystem -eq "Windows" -or $_.OperatingSystem -eq "MacOs"}

foreach ($device in $devices) {
    $deviceLocation = $null
    
    # Get registered users and owners
    $registeredUsers = Get-MgDeviceRegisteredUser -DeviceId $device.Id
    $registeredOwners = Get-MgDeviceRegisteredOwner -DeviceId $device.Id
    
    # Combine users and owners
    $allUsers = @() + $registeredUsers + $registeredOwners | Select-Object -Unique
    
    if ($allUsers.Count -gt 0) {
        # Get the last user in the list
        $lastUser = $allUsers | Select-Object -Last 1
        
        # Get user details including office location
        $userDetails = Get-MgUser -UserId $lastUser.Id
            
        if ($userDetails.OfficeLocation) {
            # Map office location to one of the three valid locations
            switch -Wildcard ($userDetails.OfficeLocation) {
                "*Paris*" { $deviceLocation = "Paris" }
                "*Lyon*" { $deviceLocation = "Lyon" }
                "*Mumbai*" { $deviceLocation = "Mumbai" }
            }
        }
    }
    
    if ($deviceLocation) {
        # Update the device's extension attribute 14
        $params = @{
            "extensionAttributes" = @{
                "extensionAttribute14" = $deviceLocation
            }
        }
        
        try {
            Update-MgDevice -DeviceId $device.Id -BodyParameter ($params | ConvertTo-Json)
            $processedDevices += [PSCustomObject]@{
                DeviceName = $device.DisplayName
                Location = $deviceLocation
                Status = "Updated"
            }
            Write-Host "Updated device $($device.DisplayName) with location: $deviceLocation" -ForegroundColor Green
        }
        catch {
            $processedDevices += [PSCustomObject]@{
                DeviceName = $device.DisplayName
                Location = $deviceLocation
                Status = "Failed"
            }
            Write-Host "Failed to update device $($device.DisplayName)" -ForegroundColor Red
        }
    }
    else {
        # Add to devices without users list
        $devicesWithoutUsers += [PSCustomObject]@{
            DeviceName = $device.DisplayName
            DeviceId = $device.Id
            RegisteredUsers = ($allUsers.Count)
        }
        Write-Host "No valid location found for device $($device.DisplayName)" -ForegroundColor Yellow
    }
}

# Export devices without valid locations to CSV
if ($devicesWithoutUsers.Count -gt 0) {
    $devicesWithoutUsers | Export-Csv -Path "DevicesWithoutLocation.csv" -NoTypeInformation
    Write-Host "`nExported $($devicesWithoutUsers.Count) devices without location to DevicesWithoutLocation.csv" -ForegroundColor Yellow
}

# Export processed devices to CSV
if ($processedDevices.Count -gt 0) {
    $processedDevices | Export-Csv -Path "ProcessedDevices.csv" -NoTypeInformation
    Write-Host "`nExported $($processedDevices.Count) processed devices to ProcessedDevices.csv" -ForegroundColor Green
}

# Disconnect from Microsoft Graph API
Disconnect-MgGraph