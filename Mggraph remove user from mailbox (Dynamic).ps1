# Connect to Microsoft Graph
Connect-MgGraph
Connect-ExchangeOnline
# Ask for the user to remove from the DL
$userToRemove = Read-Host "Enter the user to remove from the DL (email address)"

# Get the user's ID from their email address
$user = Get-MgUser -Filter "mail eq '$userToRemove'"
$userID = $user.Id

# Get all groups that the user is a member of

$groupMemberships = Get-MgUserMemberOf -UserId $userID 

# Loop through each group
foreach ($group in $groupMemberships) {
    # Filter for groups that start with "ML"
    $MLGroup =  get-mggroup -GroupId $group.id | where-object {$_.DisplayName -like "ML*"

foreach ($group in $MLGroup) {
    # Get the group's details
    $groupDetails = Get-MgGroup -GroupId $group.Id
    
    # Check if the group's name starts with "ML"
    if ($groupDetails.DisplayName -like "ML*") {
        # Display the group
        Write-Host ("Group: " + $groupDetails.DisplayName)

        # Ask to remove the user from the group
        $remove = Read-Host "Do you want to remove the user from this group? Y/N"
        if ($remove -eq "Y") {
            # Remove the user from the group
            Remove-DistributionGroupMember -Identity $group.DisplayName -Member $userToRemove
            Write-Host "Removed user from the $group.DisplayName group." -ForegroundColor Green
        }
        elseif ($remove -eq "N") {
            Write-Host "The user was not removed from the group." -ForegroundColor Red
        }
        else {
            Write-Host "Invalid input. Skipping this group." -ForegroundColor Yellow
        }
    }
}
    }}

# Disconnect from Microsoft Graph
Disconnect-MgGraph
Disconnect-ExchangeOnline