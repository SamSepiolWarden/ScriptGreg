# Connect to Microsoft Graph
Connect-MgGraph

# Initialize an empty array to hold group data
$groupData = @()

# Get all groups where the DisplayName starts with 'Sociabble'
$Groups = Get-MgGroup -Filter "startswith(DisplayName,'Sociabble')"

# Loop through each group to collect relevant information
foreach ($Group in $Groups) {
    # Create a custom object to hold the group's membership data
    $membershipData = [PSCustomObject]@{
        "Group" = $Group.DisplayName
        "Description" = $Group.Description
        "Id" = $Group.Id
        "MailEnabled" = $Group.MailEnabled
        "ObjectType" = $Group.ObjectType
    }  
    
    # Add the membership data to the groupData array
    $groupData += $membershipData 
}

# Export the group data to a CSV file
$groupData | Export-Csv -Path "C:\Test\Groups.csv" -NoTypeInformation
