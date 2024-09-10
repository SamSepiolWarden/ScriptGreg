Connect-AzureAD
$Ask = "Y"
while ($Ask -ne "N") {
    

$UserID = Read-Host -prompt "Enter the user Object ID"

$UserSearch = Get-AzureADUser -ObjectId $UserId

$UserSearch | Select-Object DisplayName, UserPrincipalName

$Ask = Read-Host -prompt "Do you want to search for another user? (Y/N)"
}
Disconnect-AzureAD
