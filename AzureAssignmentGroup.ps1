Connect-AzureAD
$UserToAdd = Read-Host -Prompt "Enter the mail adress of the user to add"
$GroupAzure = Read-Host -Prompt "Enter the group to add"
Get-AzureADUser -ObjectId "$UserToAdd"
$ObjectId = Read-Host -Prompt "Enter the GroupObjectId"
Get-AzureADGroup -SearchString "$GroupAzure"
$RefObjectId = Read-Host -Prompt "Enter the UserId"
Add-AzureADGroupMember -ObjectId "$ObjectId" -RefObjectId "$RefObjectId"
if($?)
{Write-Host Succesfully Add -ForegroundColor Green}
else
{Write-Host -ErrorAction Stop} 
Disconnect-AzureAD