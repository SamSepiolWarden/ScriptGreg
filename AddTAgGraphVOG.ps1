# Connect to Microsoft Graph
Connect-MgGraph

# Ask for the UPN of the user
$UPN = Read-Host -Prompt "Enter the UPN of the user to get the informations"

# Get user details in a single call
$UserDetails = Get-MgUser -Filter "UserPrincipalName eq '$UPN'"
$UserID = ($UserDetails | Select-Object Id).Id

if (-not $UserID) {
    Write-Host "User not found for UPN: $UPN"
    Disconnect-MgGraph
    return
}
# Prompt all teamtag 


# Iterate over all teams the user has joined
$AllTeamUser = Get-mgUserJoinedTeam -UserId $UserID
foreach ($Team in $AllTeamUser) {
    Write-Host "Team: $($Team.DisplayName) | ID: $($Team.Id)"
    
    $Department = Read-Host -Prompt "Enter the department of the user to add to the tag (Onlycrea, OnlyCSM)"

    # Initialize a variable to track if the tag was found
    $tagFound = $false

    # For each team the user is a member of, find the tags they're associated with in that team
    $TeamTags = Get-MgTeamTag -TeamId $Team.Id
    foreach ($Tag in $TeamTags) {
        Write-Host "Tag: $($Tag.DisplayName) | ID: $($Tag.Id)"

        if ($Tag.DisplayName -eq "$Department"){
            $tagFound = $true
            try {
                New-MgTeamTagMember -TeamId $Team.Id -TeamworkTagId $Tag.Id -UserId $UserID -Confirm:$false
                Write-Host "User successfully added to tag" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to add user to tag: $_" -ForegroundColor Red
            }
        }
    }
    
    # if not tag found
    if (-not $tagFound) {
        Write-Host "No tag $Department found" -ForegroundColor Gray
    }
}
Disconnect-MgGraph
