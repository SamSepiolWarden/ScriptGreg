# Connect to Microsoft Graph
Connect-MgGraph

# Ask for the UPN of the user
$UPN = Read-Host -Prompt "Enter the UPN of the user to get the information"

# Get user details in a single call
$UserDetails = Get-MgUser -Filter "UserPrincipalName eq '$UPN'"
$UserID = ($UserDetails | Select-Object Id).Id

if (-not $UserID) {
    Write-Host "User not found for UPN: $UPN"
    Disconnect-MgGraph
    return
}

# Ask if the user should be added to tags in each team
$AddToTags = Read-Host -Prompt "Do you want to add the user to tags in each team? (Y/N)"

# Iterate over all teams the user has joined
$AllTeamUser = Get-mgUserJoinedTeam -UserId $UserID
foreach ($Team in $AllTeamUser) {
    Write-Host "Team: $($Team.DisplayName) | ID: $($Team.Id)"
    
    # Fetch and display team tags
    $TeamTags = Get-MgTeamTag -TeamId $Team.Id
    if ($TeamTags.Count -eq 0) {
        Write-Host "No tags found for Team $($Team.DisplayName). Moving to next team."
        continue
    } else {
        Write-Host "Tags for Team $($Team.DisplayName):"
        foreach ($Tag in $TeamTags) {
            Write-Host "- Tag: $($Tag.DisplayName)"
        }
    }

    # Add user to tags if the user chose 'Y'
    if ($AddToTags -eq 'Y') {
        foreach ($Tag in $TeamTags) {
            # Add user to the tag (assuming Add-MgTeamTagMember is the correct cmdlet)
            Add-MgTeamTagMember -TeamId $Team.Id -TagId $Tag.Id -UserId $UserID
            Write-Host "Added user to tag: $($Tag.DisplayName)"
        }
    }
}

# Disconnect from Microsoft Graph
Disconnect-MgGraph