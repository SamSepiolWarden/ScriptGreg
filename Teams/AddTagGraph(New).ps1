function Add-UserToTags {
    param (
        [string]$UPN,
        [string]$TagToEnter
    )

    # Get user details in a single call
    $UserDetails = Get-MgUser -Filter "UserPrincipalName eq '$UPN'"
    $UserID = ($UserDetails | Select-Object Id).Id

    if (-not $UserID) {
        Write-Host "User not found for UPN: $UPN"
        return
    }

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

        # Add user to the specified tag if it exists
        $TagToAdd = $TeamTags | Where-Object { $_.DisplayName -eq $TagToEnter }
        if ($TagToAdd) {
            # Add user to the tag (assuming Add-MgTeamTagMember is the correct cmdlet)
            Add-MgTeamTagMember -TeamId $Team.Id -TagId $TagToAdd.Id -UserId $UserID
            Write-Host "Added user to tag: $($TagToAdd.DisplayName)"
        } else {
            Write-Host "Tag '$TagToEnter' not found in Team $($Team.DisplayName)."
        }
    }
}

# Connect to Microsoft Graph
Connect-MgGraph

do {
    # Ask for the UPN of the user
    $UPN = Read-Host -Prompt "Enter the UPN of the user to get the information"
    
    do {
        # Ask for the tag to enter
        $TagToEnter = Read-Host -Prompt "Enter the tag to add the user to"

        # Add user to tags
        Add-UserToTags -UPN $UPN -TagToEnter $TagToEnter

        $RunSameUserAnotherTag = Read-Host -Prompt "Do you want to run the script for the same user with another tag? (Y/N)"
    } while ($RunSameUserAnotherTag -eq 'Y')

    $RunAnotherUser = Read-Host -Prompt "Do you want to run the script for another user? (Y/N)"
} while ($RunAnotherUser -eq 'Y')

# Disconnect from Microsoft Graph
Disconnect-MgGraph