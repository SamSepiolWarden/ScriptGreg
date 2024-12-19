# Connect to Microsoft Graph if not already connected
if (-not (Get-MgContext)) {
    Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"
}

function Get-DeviceActionResults {
    try {
        # Get all managed devices with their action results
        $devices = Get-MgDeviceManagementManagedDevice -Property "id,deviceName,serialNumber,deviceActionResults" -All

        foreach ($device in $devices) {
            Write-Host "`nDevice: $($device.deviceName)" -ForegroundColor Cyan
            Write-Host "Serial Number: $($device.serialNumber)" -ForegroundColor Cyan
            Write-Host "Device ID: $($device.id)" -ForegroundColor Gray

            if ($device.deviceActionResults) {
                Write-Host "Action Results:" -ForegroundColor Yellow
                foreach ($action in $device.deviceActionResults) {
                    Write-Host "  Action Type: $($action.actionName)" -ForegroundColor Green
                    Write-Host "  Start Time: $($action.startDateTime)"
                    Write-Host "  Last Updated: $($action.lastUpdatedDateTime)"
                    Write-Host "  Status: $($action.status)"
                    if ($action.error) {
                        Write-Host "  Error: $($action.error)" -ForegroundColor Red
                    }
                    Write-Host "  -----------------------"
                }
            } else {
                Write-Host "No action results found" -ForegroundColor Yellow
            }
            Write-Host "==============================="
        }
    }
    catch {
        Write-Error "Error getting device action results: $_"
    }
}

# Run the function
Get-DeviceActionResults

# Optional: Disconnect when done
# Disconnect-MgGraph