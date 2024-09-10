Connect-MgGraph
Connect-AzureAD
# ask for user UPN
$upn = Read-Host -Prompt 'Enter user UPN'

# get user
$user = Get-MgUser -Filter "userPrincipalName eq '$upn'"

# Start array
$Groups = @()

# export joined group and Distribution list memberships
$Graphgroup = Get-MgUserJoinedTeam -UserId $user.Id 


$AzureGroup = Get-AzureaduserMembership -ObjectId $user.Id 

# Add both to a single array
$Groups = $Graphgroup + $AzureGroup

# export to CSV
$Groups | Export-Csv -Path C:\Test\Groups.csv -NoTypeInformation


Disconnect-MgGraph
Disconnect-AzureAD

