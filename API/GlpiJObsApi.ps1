# Configuration
$GlpiUrl = "https://sociabble.with22.glpi-network.cloud/apirest.php"
$AppToken = "4qv8BFV6jR6FJ8nR7FqcNDnNypMNbcqj94u54erJ"  # Add your App-Token from GLPI API settings
$UserToken = "EdBBbrmKNWZU0ieIUQCax4iFoHbjjTNKc4MGHzdm"  # Add your Remote access key from User Preferences
$Global:SessionToken = $null

# Connect to Microsoft Graph if not already connected
if (-not (Get-MgContext)) {
    Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All"
}

# Function to initialize GLPI session
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

# Function to get devices for spare status
function Get-DevicesForSpareStatus {
    try {
        Write-Host "Fetching devices from Intune..." -ForegroundColor Cyan
        
        # Get all managed devices
        $devices = Get-MgDeviceManagementManagedDevice -Property @(
            "id",
            "deviceName",
            "serialNumber",
            "manufacturer",
            "model",
            "operatingSystem",
            "userPrincipalName"
        ) -All

        Write-Host "Found $($devices.Count) total devices" -ForegroundColor Green
        
        $spareDevices = @()
        $count = 0
        
        foreach ($device in $devices) {
            $count++
            Write-Progress -Activity "Checking devices" -Status "$count of $($devices.Count)" -PercentComplete (($count / $devices.Count) * 100)
            
            # Skip devices with "shared" in their name
            if ($device.deviceName -like "*shared*" -or $device.DeviceName -like "*Pc-Lyon*" -or $device.DeviceName -like "R2D2") {
                Write-Verbose "Skipping shared device: $($device.deviceName)"
                continue
            }
            
            # Check for users assigned to this device
            $users = Get-MgDeviceManagementManagedDeviceUser -ManagedDeviceId $device.Id
            
            # Check if device should be marked as spare:
            # 1. No user assigned, OR
            # 2. Owner is "dsi"
            if (-not $users -or $device.userPrincipalName -like "*dsi*") {
                
                # Determine the reason for marking as spare
                $reason = if (-not $users) {
                    "No User Assigned"
                } elseif ($device.userPrincipalName -like "*dsi*") {
                    "DSI Owner"
                } else {
                    "Unknown"
                }
                
                $deviceInfo = [PSCustomObject]@{
                    DeviceName = $device.deviceName
                    SerialNumber = $device.serialNumber
                    Manufacturer = $device.manufacturer
                    Model = $device.model
                    OperatingSystem = $device.operatingSystem
                    CurrentOwner = $device.userPrincipalName
                    DeviceID = $device.id
                    SpareReason = $reason
                }
                
                $spareDevices += $deviceInfo
                
                Write-Host "`nFound device to mark as spare:" -ForegroundColor Yellow
                Write-Host "Device Name: $($device.deviceName)"
                Write-Host "Serial Number: $($device.serialNumber)"
                Write-Host "Current Owner: $($device.userPrincipalName)"
                Write-Host "Reason: $reason"
                Write-Host "--------------------------------"
            }
        }
        
        Write-Progress -Activity "Checking devices" -Completed

        # Group summary by reason
        $groupSummary = $spareDevices | Group-Object -Property SpareReason | Select-Object Name, Count
        
        Write-Host "`nDevices by category:" -ForegroundColor Cyan
        foreach ($group in $groupSummary) {
            Write-Host "$($group.Name): $($group.Count) devices"
        }
        
        if ($spareDevices.Count -eq 0) {
            Write-Host "`nNo devices found to mark as spare." -ForegroundColor Yellow
            return $null
        }
        
        return $spareDevices
    }
    catch {
        Write-Error "Error retrieving devices: $_"
        return $null
    }
}

# Function to get and display GLPI states
function Get-GlpiStates {
    param (
        [Parameter(Mandatory=$true)]
        [string]$SessionToken
    )
    
    $headers = @{
        "Session-Token" = $SessionToken
        "App-Token" = $AppToken
        "Content-Type" = "application/json"
    }
    
    try {
        # Get states from GLPI API
        $response = Invoke-RestMethod -Uri "$GlpiUrl/State" -Method Get -Headers $headers
        
        Write-Host "`nAvailable GLPI States:" -ForegroundColor Cyan
        Write-Host "------------------------"
        
        # Display all states with their IDs
        foreach ($state in $response) {
            if ($state.name -eq "Spare") {
                Write-Host "ID: $($state.id) - Name: $($state.name)" -ForegroundColor Green
            } else {
                Write-Host "ID: $($state.id) - Name: $($state.name)"
            }
        }
        Write-Host "------------------------"
        
        # Find the Spare state
        $spareState = $response | Where-Object { $_.name -eq "Spare" }
        if ($spareState) {
            Write-Host "`nFound 'Spare' state with ID: $($spareState.id)" -ForegroundColor Green
        } else {
            Write-Warning "No 'Spare' state found in GLPI!"
        }
        
        return $response
    }
    catch {
        Write-Error "Failed to get GLPI states: $_"
        return $null
    }
}
    
    

function Get-GlpiComputer {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SerialNumber
    )
    
    try {
        $headers = @{
            "Session-Token" = $Global:SessionToken
            "App-Token" = $AppToken
            "Content-Type" = "application/json"
        }
        
        $searchUrl = "$GlpiUrl/search/Computer?" + 
                    "forcedisplay[0]=2" +  # ID field
                    "&forcedisplay[1]=5" +  # Serial
                    "&criteria[0][field]=5" +
                    "&criteria[0][searchtype]=equals" +
                    "&criteria[0][value]=$SerialNumber"
        
        $searchResponse = Invoke-WebRequest -Uri $searchUrl -Headers $headers -Method Get
        $searchData = $searchResponse.Content | ConvertFrom-Json
        
        if ($searchData.data -and $searchData.data.Count -gt 0) {
            $firstResult = $searchData.data[0]
            
            # Get ID from field 2
            if ($firstResult.PSObject.Properties['2']) {
                $computerId = [int]$firstResult.2
                Write-Host "Found computer ID: $computerId" -ForegroundColor Green
                
                return @{
                    ID = $computerId
                    SerialNumber = $SerialNumber
                }
            }
        }
        Write-Warning "No computer found with serial number: $SerialNumber"
        return $null
    }
    catch {
        Write-Error "Failed to get computer details: $_"
        return $null
    }
}

function Update-GlpiComputerStatus {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SerialNumber,
        [Parameter(Mandatory=$true)]
        [string]$DeviceName,
        [Parameter(Mandatory=$true)]
        [int]$SpareStateId
    )
    
    try {
        $computerDetails = Get-GlpiComputer -SerialNumber $SerialNumber
        
        if ($computerDetails -and $computerDetails.ID -gt 0) {
            $jsonPayload = @{
                input = @{
                    id = $computerDetails.ID
                    states_id = $SpareStateId
                }
            } | ConvertTo-Json -Compress
            
            Write-Host "Updating computer ID $($computerDetails.ID) to spare state ($SpareStateId)" -ForegroundColor Yellow
            Write-Host "JSON Payload: $jsonPayload" -ForegroundColor Yellow
            
            $headers = @{
                "Session-Token" = $Global:SessionToken
                "App-Token" = $AppToken
                "Content-Type" = "application/json"
            }
            
            $updateUrl = "$GlpiUrl/Computer/$($computerDetails.ID)"
            $response = Invoke-WebRequest -Uri $updateUrl -Method Put -Headers $headers -Body $jsonPayload
            
            if ($response.StatusCode -eq 200) {
                Write-Host "Successfully updated status for $DeviceName (ID: $($computerDetails.ID))" -ForegroundColor Green
                return $true
            }
        }
        return $false
    }
    catch {
        Write-Error "Failed to update GLPI status for $DeviceName : $_"
        return $false
    }
}


# Initialize counters before the loop
$successCount = 0
$failureCount = 0

# Main script update
try {
    # Initialize GLPI session
    if (-not (Initialize-GlpiSession)) {
        throw "Failed to initialize GLPI session"
    }
    
    # Get and display GLPI states
    $states = Get-GlpiStates -SessionToken $Global:SessionToken
    
    # Find Spare state
    $spareState = $states | Where-Object { $_.name -eq "Spare" }
    if ($spareState) {
        $spareStateId = $spareState.id
        Write-Host "`nWill use Spare state ID: $spareStateId for updates" -ForegroundColor Yellow
    } else {
        throw "Could not find 'Spare' state in GLPI"
    }
    
    Write-Host "Found spare state ID: $($spareState.id)" -ForegroundColor Cyan
    
    # Get devices that should be marked as spare
    $spareDevices = Get-DevicesForSpareStatus
    
    if (-not $spareDevices) {
        Write-Host "No devices found to mark as spare" -ForegroundColor Yellow
        return
    }
    
    # Update GLPI status for each device
    $successCount = 0
    $failureCount = 0
    
    foreach ($device in $spareDevices) {
        if (Update-GlpiComputerStatus -SerialNumber $device.SerialNumber -DeviceName $device.DeviceName -SpareStateId $spareState.id) {
            $successCount++
        }
        else {
            $failureCount++
        }
        Start-Sleep -Milliseconds 500
    }
    # Export results to CSV
    $date = Get-Date -Format "yyyyMMdd_HHmmss"
    $csvPath = "SpareDevicesUpdate_$date.csv"
    $spareDevices | Export-Csv -Path $csvPath -NoTypeInformation
    
    # Summary
    Write-Host "`nUpdate Summary:" -ForegroundColor Cyan
    Write-Host "Total devices processed: $($spareDevices.Count)"
    Write-Host "Successfully updated: $successCount"
    Write-Host "Failed to update: $failureCount"
    Write-Host "`nResults exported to: $csvPath" -ForegroundColor Green
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