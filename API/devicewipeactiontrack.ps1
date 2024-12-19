# Connect to Microsoft Graph if not already connected
if (-not (Get-MgContext)) {
    Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"
}

function Get-DeviceWipeHistory {
    try {
        # Get all managed devices with their action results
        $devices = Get-MgDeviceManagementManagedDevice -Property "id,deviceName,serialNumber,deviceActionResults,userPrincipalName" -All
        
        $wipeResults = @()
        
        foreach ($device in $devices) {
            if ($device.deviceActionResults) {
                # Filter for wipe-related actions
                $wipeActions = $device.deviceActionResults | Where-Object { 
                    $_.actionName -in @('Wipe', 'RetireWipe', 'Delete', 'RemoveCompanyData')
                }
                
                if ($wipeActions) {
                    foreach ($action in $wipeActions) {
                        $wipeInfo = [PSCustomObject]@{
                            DeviceName = $device.deviceName
                            SerialNumber = $device.serialNumber
                            DeviceId = $device.id
                            User = $device.userPrincipalName
                            ActionType = $action.actionName
                            StartTime = $action.startDateTime
                            LastUpdated = $action.lastUpdatedDateTime
                            Status = $action.status
                            Error = $action.error
                        }
                        $wipeResults += $wipeInfo
                    }
                }
            }
        }
        
        # Display results
        if ($wipeResults.Count -gt 0) {
            Write-Host "`nFound $($wipeResults.Count) wipe-related actions" -ForegroundColor Cyan
            
            foreach ($result in $wipeResults) {
                Write-Host "`nDevice: $($result.DeviceName)" -ForegroundColor Yellow
                Write-Host "Serial Number: $($result.SerialNumber)"
                Write-Host "User: $($result.User)"
                Write-Host "Action Type: $($result.ActionType)" -ForegroundColor Green
                Write-Host "Start Time: $($result.StartTime)"
                Write-Host "Last Updated: $($result.LastUpdated)"
                Write-Host "Status: $($result.Status)"
                if ($result.Error) {
                    Write-Host "Error: $($result.Error)" -ForegroundColor Red
                }
                Write-Host "------------------------"
            }
            
            # Optionally export to CSV
            $csvPath = "WipeHistory_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
            $wipeResults | Export-Csv -Path $csvPath -NoTypeInformation
            Write-Host "`nExported results to: $csvPath" -ForegroundColor Green
        } else {
            Write-Host "No wipe actions found in the device history" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Error "Error retrieving wipe history: $_"
    }
}

# Function to get wipe history for a specific device
function Get-SpecificDeviceWipeHistory {
    param(
        [Parameter(Mandatory=$false)]
        [string]$DeviceName,
        
        [Parameter(Mandatory=$false)]
        [string]$SerialNumber,
        
        [Parameter(Mandatory=$false)]
        [datetime]$StartDate
    )
    
    try {
        # Build filter based on parameters
        $filter = ""
        if ($DeviceName) {
            $filter = "deviceName eq '$DeviceName'"
        }
        elseif ($SerialNumber) {
            $filter = "serialNumber eq '$SerialNumber'"
        }
        
        # Get device(s)
        $devices = if ($filter) {
            Get-MgDeviceManagementManagedDevice -Filter $filter -Property "id,deviceName,serialNumber,deviceActionResults,userPrincipalName"
        } else {
            Get-MgDeviceManagementManagedDevice -Property "id,deviceName,serialNumber,deviceActionResults,userPrincipalName" -All
        }
        
        foreach ($device in $devices) {
            Write-Host "`nDevice: $($device.deviceName)" -ForegroundColor Cyan
            Write-Host "Serial Number: $($device.serialNumber)"
            Write-Host "User: $($device.userPrincipalName)"
            
            if ($device.deviceActionResults) {
                $wipeActions = $device.deviceActionResults | Where-Object { 
                    $_.actionName -in @('Wipe', 'RetireWipe', 'Delete', 'RemoveCompanyData') -and
                    (!$StartDate -or $_.startDateTime -ge $StartDate)
                }
                
                if ($wipeActions) {
                    foreach ($action in $wipeActions) {
                        Write-Host "`nAction Type: $($action.actionName)" -ForegroundColor Green
                        Write-Host "Start Time: $($action.startDateTime)"
                        Write-Host "Last Updated: $($action.lastUpdatedDateTime)"
                        Write-Host "Status: $($action.status)"
                        if ($action.error) {
                            Write-Host "Error: $($action.error)" -ForegroundColor Red
                        }
                    }
                } else {
                    Write-Host "No wipe actions found for this device" -ForegroundColor Yellow
                }
            }
            Write-Host "------------------------"
        }
    }
    catch {
        Write-Error "Error retrieving device wipe history: $_"
    }
}

# Example usage:
# Get all wipe history
Write-Host "Getting all wipe history..." -ForegroundColor Cyan
Get-DeviceWipeHistory

# Get wipe history for specific device
# Get-SpecificDeviceWipeHistory -DeviceName "LAPTOP-123"

# Get wipe history for specific serial number
# Get-SpecificDeviceWipeHistory -SerialNumber "ABC123"

# Get wipe history after a specific date
# Get-SpecificDeviceWipeHistory -StartDate (Get-Date).AddDays(-30)