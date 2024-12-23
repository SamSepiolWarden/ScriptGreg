# Configuration
$GlpiUrl = 
$AppToken =  # Add your App-Token from GLPI API settings
$UserToken = # Add your Remote access key from User Preferences
$Global:SessionToken = $null

$headers = @{
    "Session-Token" = $Global:SessionToken
    "App-Token" = $AppToken
    "Authorization"  = $UserToken
    "Content-Type" = "application/json"
}
function Initialize-GlpiSession {
    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "user_token $UserToken"
        "App-Token" = $AppToken
    }
    
    try {
        $response = Invoke-RestMethod -Uri "$GlpiUrl/initSession" -Method Get -Headers $headers
        $Global:SessionToken = $response.session_token
        Write-Host "GLPI Session initialized successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to initialize GLPI session: $_"
        return $false
    }
}

function Get-GlpiComputer {
    param(
        [Parameter(Mandatory=$true)]
        [string]$AlternateUsername
    )
    
    try {
        $headers = @{
            "Session-Token" = $Global:SessionToken
            "App-Token" = $AppToken
            "Content-Type" = "application/json"
        }
        
        # Search for computer by alternate username (field 7)
        $searchUrl = "$GlpiUrl/search/Computer?" + 
                    "forcedisplay[0]=2" +  # ID
                    "&forcedisplay[1]=7" +  # Alternate username (updated field ID)
                    "&criteria[0][field]=7" + # Alternate username field (updated field ID)
                    "&criteria[0][searchtype]=equals" +
                    "&criteria[0][value]=$AlternateUsername"
        
        $searchResponse = Invoke-WebRequest -Uri $searchUrl -Headers $headers -Method Get
        $searchData = $searchResponse.Content | ConvertFrom-Json
        
        if ($searchData.data -and $searchData.data.Count -gt 0) {
            $firstResult = $searchData.data[0]
            
            if ($firstResult.PSObject.Properties['2']) {
                $computerId = [int]$firstResult.2
                $currentAltUsername = $firstResult.7
                Write-Host "Found computer ID: $computerId with alternate username: $currentAltUsername" -ForegroundColor Green
                
                return @{
                    ID = $computerId
                    AlternateUsername = $currentAltUsername
                }
            }
        }
        return $null
    }
    catch {
        Write-Error "Failed to get computer details: $_"
        return $null
    }
}

# Function to get device extension attribute 14 from Intune
function Get-IntuneDeviceLocation {
    param(
        [Parameter(Mandatory=$true)]
        [string]$DeviceId
    )
    
    try {
        $device = Get-MgDevice -DeviceId $DeviceId
        if ($device.AdditionalProperties.extensionAttributes.extensionAttribute14) {
            return $device.AdditionalProperties.extensionAttributes.extensionAttribute14
        }
        return "Spare" # Default to Spare if no location is set
    }
    catch {
        Write-Error "Failed to get Intune location for device $DeviceId : $_"
        return $null
    }
}

# Modified Get-IntuneUserLocations function to include device information
function Get-IntuneUserLocations {
    try {
        # Connect to Microsoft Graph if not already connected
        try {
            $graphConnection = Get-MgContext
            if (-not $graphConnection) {
                Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All"
            }
        }
        catch {
            Write-Error "Failed to connect to Microsoft Graph: $_"
            return $null
        }

        # Initialize hashtable to store user and device locations
        $deviceLocations = @{}

        # Get all devices from Intune
        $devices = Get-MgDevice -All
        Write-Host "Found $($devices.Count) devices in Intune" -ForegroundColor Cyan

        foreach ($device in $devices) {
            $intuneLocation = Get-IntuneDeviceLocation -DeviceId $device.Id
            
            # Get registered users for the device
            $registeredUsers = Get-MgDeviceRegisteredUser -DeviceId $device.Id
            $registeredOwners = Get-MgDeviceRegisteredOwner -DeviceId $device.Id
            $allUsers = @() + $registeredUsers + $registeredOwners | Select-Object -Unique
            
            # Get the last user (if any)
            $lastUser = $allUsers | Select-Object -Last 1
            
            if ($lastUser) {
                $upn = (Get-MgUser -UserId $lastUser.Id).UserPrincipalName
            }
            else {
                $upn = "No User"
            }

            $deviceLocations[$device.DisplayName] = @{
                DeviceId = $device.Id
                UserPrincipalName = $upn
                IntuneLocation = $intuneLocation
                SerialNumber = $device.SerialNumber
                Manufacturer = $device.Manufacturer
                Model = $device.Model
            }
        }

        Write-Host "Processed $($deviceLocations.Count) devices with their locations" -ForegroundColor Cyan
        return $deviceLocations
    }
    catch {
        Write-Error "Error in Get-IntuneUserLocations: $_"
        return $null
    }
}

function Update-GlpiComputerLocation {
    param(
        [Parameter(Mandatory=$true)]
        [int]$ComputerId,
        [Parameter(Mandatory=$true)]
        [string]$Location,
        [Parameter(Mandatory=$true)]
        [string]$UserPrincipalName
    )
    
    try {
        $headers = @{
            "Session-Token" = $Global:SessionToken
            "App-Token" = $AppToken
            "Content-Type" = "application/json"
        }

        # First check if the plugin field exists
        $searchUrl = "$GlpiUrl/search/PluginFieldsComputersitelocation?" + 
                    "forcedisplay[0]=2" +  # ID
                    "&criteria[0][field]=2" + # items_id field
                    "&criteria[0][searchtype]=equals" +
                    "&criteria[0][value]=$ComputerId"

        Write-Host "Checking for existing plugin record for computer $ComputerId" -ForegroundColor Gray
        $searchResponse = Invoke-WebRequest -Uri $searchUrl -Headers $headers -Method Get
        $searchData = $searchResponse.Content | ConvertFrom-Json

        if ($searchData.data -and $searchData.data.Count -gt 0) {
            # Update existing record
            $pluginId = $searchData.data[0].2  # Get the ID from the result
            
            $updatePayload = @{
                input = @{
                    id = $pluginId
                    sitelocationfield = $Location
                }
            } | ConvertTo-Json -Compress

            Write-Host "Updating existing plugin record ID: $pluginId for computer $ComputerId with location: $Location" -ForegroundColor Yellow
            
            $updateUrl = "$GlpiUrl/PluginFieldsComputersitelocation/$pluginId"
            $response = Invoke-WebRequest -Uri $updateUrl -Method Put -Headers $headers -Body $updatePayload
            
            if ($response.StatusCode -eq 200) {
                $content = $response.Content | ConvertFrom-Json
                if ($content.$pluginId -eq $true) {
                    Write-Host "Successfully updated location for computer $ComputerId (User: $UserPrincipalName) to $Location" -ForegroundColor Green
                    return $true
                }
            }
        }
        else {
            # Create new record
            $createPayload = @{
                input = @{
                    items_id = $ComputerId
                    itemtype = "Computer"
                    sitelocationfield = $Location
                }
            } | ConvertTo-Json -Compress

            Write-Host "Creating new plugin record for computer $ComputerId with location: $Location" -ForegroundColor Yellow
            
            $createUrl = "$GlpiUrl/PluginFieldsComputersitelocation"
            $response = Invoke-WebRequest -Uri $createUrl -Method Post -Headers $headers -Body $createPayload
            
            if ($response.StatusCode -eq 201 -or $response.StatusCode -eq 200) {
                Write-Host "Successfully created location record for computer $ComputerId (User: $UserPrincipalName) to $Location" -ForegroundColor Green
                return $true
            }
        }

        Write-Warning "Failed to update location for computer $ComputerId (Status: $($response.StatusCode))"
        return $false
    }
    catch {
        Write-Error "Failed to update location for computer $ComputerId : $_"
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $errorBody = $reader.ReadToEnd()
            Write-Host "Error response: $errorBody" -ForegroundColor Red
            $reader.Close()
        }
        return $false
    }
}

# Modified main script
try {
    # Initialize arrays for reporting
    $locationMismatches = @()
    $syncedDevices = @()
    $unregisteredDevices = @()
    
    # Initialize GLPI session
    if (-not (Initialize-GlpiSession)) {
        throw "Failed to initialize GLPI session"
    }
    
    # Get device locations from Intune
    $deviceLocations = Get-IntuneUserLocations
    if (-not $deviceLocations) {
        throw "Failed to get device locations"
    }
    
    $successCount = 0
    $failureCount = 0
    $unmatchedCount = 0
    
    # Process each device
    foreach ($deviceName in $deviceLocations.Keys) {
        $deviceInfo = $deviceLocations[$deviceName]
        Write-Host "`nProcessing device: $deviceName" -ForegroundColor Cyan
        
        # Try to find computer in GLPI first by serial number, then by name
        $computerDetails = $null
        if ($deviceInfo.SerialNumber) {
            $computerDetails = Get-GlpiComputer -SerialNumber $deviceInfo.SerialNumber
        }
        if (-not $computerDetails) {
            $computerDetails = Get-GlpiComputer -AlternateUsername $deviceInfo.UserPrincipalName
        }
        
        if ($computerDetails) {
            # Update GLPI location based on Intune extension attribute 14
            if (Update-GlpiComputerLocation -ComputerId $computerDetails.ID -Location $deviceInfo.IntuneLocation -UserPrincipalName $deviceInfo.UserPrincipalName) {
                $successCount++
                $syncedDevices += [PSCustomObject]@{
                    DeviceName = $deviceName
                    SerialNumber = $deviceInfo.SerialNumber
                    UserPrincipalName = $deviceInfo.UserPrincipalName
                    IntuneLocation = $deviceInfo.IntuneLocation
                    GlpiComputerId = $computerDetails.ID
                    Status = "Synced"
                }
            }
            else {
                $failureCount++
                $locationMismatches += [PSCustomObject]@{
                    DeviceName = $deviceName
                    SerialNumber = $deviceInfo.SerialNumber
                    UserPrincipalName = $deviceInfo.UserPrincipalName
                    IntuneLocation = $deviceInfo.IntuneLocation
                    GlpiComputerId = $computerDetails.ID
                    Status = "Sync Failed"
                }
            }
        }
        else {
            $unmatchedCount++
            $unregisteredDevices += [PSCustomObject]@{
                DeviceName = $deviceName
                SerialNumber = $deviceInfo.SerialNumber
                UserPrincipalName = $deviceInfo.UserPrincipalName
                IntuneLocation = $deviceInfo.IntuneLocation
                Manufacturer = $deviceInfo.Manufacturer
                Model = $deviceInfo.Model
                Status = "Not Found in GLPI"
            }
        }
    }
    
    # Export results to CSV
    $date = Get-Date -Format "yyyyMMdd_HHmmss"
    $syncedCsvPath = "C:\Test\SyncedDevices_$date.csv"
    $mismatchCsvPath = "C:\Test\LocationMismatches_$date.csv"
    $unregisteredCsvPath = "C:\Test\UnregisteredDevices_$date.csv"
    
    if ($syncedDevices.Count -gt 0) {
        $syncedDevices | Export-Csv -Path $syncedCsvPath -NoTypeInformation
        Write-Host "`nSynced devices exported to: $syncedCsvPath" -ForegroundColor Green
    }
    
    if ($locationMismatches.Count -gt 0) {
        $locationMismatches | Export-Csv -Path $mismatchCsvPath -NoTypeInformation
        Write-Host "Location mismatches exported to: $mismatchCsvPath" -ForegroundColor Yellow
    }
    
    if ($unregisteredDevices.Count -gt 0) {
        $unregisteredDevices | Export-Csv -Path $unregisteredCsvPath -NoTypeInformation
        Write-Host "Unregistered devices exported to: $unregisteredCsvPath" -ForegroundColor Yellow
    }
    
    # Summary
    Write-Host "`nSync Summary:" -ForegroundColor Cyan
    Write-Host "Successfully synced: $successCount" -ForegroundColor Green
    Write-Host "Failed to sync: $failureCount" -ForegroundColor Red
    Write-Host "Unregistered devices: $unmatchedCount" -ForegroundColor Yellow
}
catch {
    Write-Error "An error occurred during execution: $_"
}
finally {
    # Cleanup
    if ($Global:SessionToken) {
        $headers = @{
            "Session-Token" = $Global:SessionToken
            "App-Token" = $AppToken
        }
        try {
            Invoke-RestMethod -Uri "$GlpiUrl/killSession" -Method Get -Headers $headers | Out-Null
            Write-Host "GLPI Session closed" -ForegroundColor Green
        }
        catch {
            Write-Warning "Failed to close GLPI session: $_"
        }
    }
    Disconnect-MgGraph
}