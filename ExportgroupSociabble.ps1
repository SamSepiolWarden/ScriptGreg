# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Group.Read.All"

# Fetch all groups and filter locally
$allGroups = Get-MgGroup -All | Where-Object { $_.DisplayName -like "Sociabble -*" }

# Collect the relevant information
$groupInfo = $allGroups | ForEach-Object {
    [PSCustomObject]@{
        DisplayName = $_.DisplayName
        Description = $_.Description
    }
}

# Export the information to a CSV file
$groupInfo | Export-Csv -Path "C:\Test\SociabbleGroupsToRename.csv" -NoTypeInformation
