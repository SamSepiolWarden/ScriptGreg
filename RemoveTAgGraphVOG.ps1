# Connect to Microsoft Graph
Connect-MgGraph

# Ask for the UPN of the user
$UPN = Read-Host -Prompt "Enter the UPN of the user to get the informations"

# Get user details in a single call
$UserDetails = Get-MgUser -Filter "UserPrincipalName eq '$UPN'"
$DisplayName = ($UserDetails | Select-Object DisplayName).DisplayName
$UserID = ($UserDetails | Select-Object Id).Id

if (-not $UserID) {
    Write-Host "User not found for UPN: $UPN"
    Disconnect-MgGraph
    return
}

# Initialize an array to hold team, tag, and tag membership ID associations
$TeamTagAssociations = @()

# Iterate over all teams the user has joined
$AllTeamUser = Get-mgUserJoinedTeam -UserId $UserID
foreach ($Team in $AllTeamUser) {
    Write-Host "Team: $($Team.DisplayName) | ID: $($Team.Id)"
        
    # For each team the user is a member of, find the tags they're associated with in that team
    $TeamTags = Get-MgTeamTag -TeamId $Team.Id

    foreach ($Tag in $TeamTags) {
        # Fetch the tag members to find the membership ID for the user
        $TagMembers = Get-MgTeamTagMember -TeamId $Team.Id -TeamworkTagId $Tag.Id -Filter "DisplayName eq '$DisplayName'"
        $TagMemberId = ($TagMembers | Where-Object { $_.DisplayName -eq $DisplayName }).Id
        
        # If the user is a member of the tag, add the association
        if ($TagMemberId) {
            $TeamTagAssociations += [PSCustomObject]@{
                Team = $Team
                Tag = $Tag
                TagMemberId = $TagMemberId
            }
        }
        else {
            Write-Host "User $DisplayName is not a member of tag $($Tag.DisplayName) with ID $($Tag.Id) in team $($Team.DisplayName)"        }
    }
}

# Display the teams and their associated tags
foreach ($Association in $TeamTagAssociations) {
    Write-Host "Team: $($Association.Team.DisplayName) -- Tag: $($Association.Tag.DisplayName) | ID: $($Association.Tag.Id)"


# Remove the user from the tags in each team

    try {
        Remove-MgTeamTagMember -TeamId $Association.Team.Id -TeamworkTagId $Association.Tag.Id -TeamworkTagMemberId $Association.TagMemberId | Out-Null
        Write-Host "Removed $UPN from $($Association.Tag.DisplayName) with ID $($Association.Tag.Id) in team $($Association.Team.DisplayName)" -ForegroundColor Green
    }
    catch {
        Write-Host "Error : $_"
    }
}

Disconnect-MgGraph
