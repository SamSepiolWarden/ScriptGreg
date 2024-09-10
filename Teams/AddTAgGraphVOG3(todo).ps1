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

# Iterate over all teams the user has joined
$AllTeamUser = Get-mgUserJoinedTeam -UserId $UserID
foreach ($Team in $AllTeamUser) {
    Write-Host "Team: $($Team.DisplayName) | ID: $($Team.Id)"
    
    # Fetch and display team tags
    $TeamTags = Get-MgTeamTag -TeamId $Team.Id
    if ($TeamTags.Count -eq 0) {
        Write-Host "No tags found for Team $($Team.DisplayName). Moving to next team."
        continue  # Skip to the next iteration, skipping the current team
    } else {
        Write-Host "Tags for Team $($Team.DisplayName):"
        foreach ($Tag in $TeamTags) {
            Write-Host "- Tag: $($Tag.DisplayName)"
        }
    }

    # Ask if we want to add the user to a tag after displaying the tags
    $AddToTag = Read-Host -Prompt "Do you want to add the user to a tag in Team $($Team.DisplayName)? (Y/N)"
    if ($AddToTag -ne 'Y') {
        Write-Host "Not adding the user to any tag in Team $($Team.DisplayName)."
        continue
    }

    $Department = Read-Host -Prompt "Enter the department of the user to add to the tag (Onlycrea, OnlyCSM)"

    # Initialize a variable to track if the tag was found
    $tagFound = $false

    # Check again for tags to add the user, since we now have confirmation to proceed
    foreach ($Tag in $TeamTags) {
        if ($Tag.DisplayName -eq $Department) {
            $tagFound = $true
            try {
                New-MgTeamTagMember -TeamId $Team.Id -TeamworkTagId $Tag.Id -UserId $UserID -Confirm:$false
                Write-Host "User successfully added to tag" -ForegroundColor Green
            } catch {
                Write-Host "Failed to add user to tag: $_" -ForegroundColor Red
            }
            break # Stop looping through tags once the user is added
        }
    }

    if (-not $tagFound) {
        Write-Host "No tag matching '$Department' found in Team $($Team.DisplayName)." -ForegroundColor Gray
    }
}

Disconnect-MgGraph
