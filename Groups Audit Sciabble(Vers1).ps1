# Connect to Microsoft Graph
Connect-MgGraph

# Get all Azure AD groups that have names starting with "Sociabble -"
$groups = Get-MgGroup -Filter "StartsWith(DisplayName, 'Sociabble -')"

# Filter out groups with specific departments in their display name
$filteredGroups = $groups | Where-Object { $_.DisplayName -notlike '*Sales and CSM*' -and $_.DisplayName -notlike '*RnD*' -and $_.DisplayName -notlike '*Marketing*' -and $_.DisplayName -notlike '*IT and Shared Device*' -and $_.DisplayName -notlike '*Direction*' -and $_.DisplayName -notlike '*Corp Department*' }

# Select specific properties
$selectedProperties = $filteredGroups | Select-Object DisplayName, Description, SecurityEnabled

# Export the selected properties to a CSV file
$selectedProperties | Export-Csv -Path "C:\Test\groups.csv" -NoTypeInformation

# Check if the export was successful
if ($? -eq $true) {
    Write-Host "Export groups to csv OK" -ForegroundColor Green
} else {
    Write-Host "Issue to export groups to csv" -ForegroundColor Red
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph
