# Connect to Microsoft Graph
Connect-MgGraph

# Fetch all groups
$AllGroups = Get-MgGroup -All:$true

# Filter groups whose name starts with '_Only'
$Groups = $AllGroups | Where-Object { $_.displayName -like '_Only*' }

# Display group names
foreach ($Group in $Groups) {
    Write-Host $Group.displayName
}

# Get the group chosen by the user
$GroupChosen = Read-Host -Prompt 'Enter the group name'
$Devicegroup = Get-MgGroup -Filter "displayName eq '$GroupChosen'"

if ($null -eq $Devicegroup) {
    Write-Host "Group not found. Exiting."
    exit
}

# Get the members in the chosen group
$GroupMembers = Get-MgGroupMember -GroupId $Devicegroup.Id

Write-Host "Number of group members found: $($GroupMembers.Count)"

# Initialize Devices array
$Devices = @()

# Display device names
foreach ($Device in $GroupMembers) {
    Write-Host "Fetching device with ID: $($Device.id)"
    $currentDevice = Get-MgDevice -DeviceId $Device.id | Select-Object -Property DisplayName
    if ($null -ne $currentDevice) {
        $Devices += $currentDevice
        Write-Host $currentDevice.DisplayName
    }
}

# Ask user if they want to add an extension to the devices
$AskExtension = Read-Host -Prompt 'Do you want to add an extension to a device? (Y/N)'

if ($AskExtension -eq 'Y') {
    $ExtensionNumber = Read-Host -Prompt 'Enter the extension number'
    $ExtensionName = Read-Host -Prompt 'Enter the extension name'
   

    
    foreach ($Device in $GroupMembers) {
       # Create a PSObject for the parameters
$Params = @{
    extensionAttributes = @{
        "extensionAttribute$ExtensionNumber" = $ExtensionName
    }
}
$currentDevice1 = Get-MgDevice -DeviceId $Device.id

# Update the Device
Update-MgDevice -DeviceId $currentDevice1.Id -BodyParameter $Params

# Check if the update was successful
if ($?) {
    Write-Host "Device $($currentDevice1.DisplayName) extension updated successfully" -ForegroundColor Green
}
else {
    Write-Host "Failed to update device extension $($currentDevice1.DisplayName)" -ForegroundColor Red
}


        # Optionally, you can fetch and display the updated device information
        Get-MgDevice -DeviceId $currentDevice1.Id
    }
} elseif ($AskExtension -eq 'N') {
    Write-Host "No need for changes"
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph
