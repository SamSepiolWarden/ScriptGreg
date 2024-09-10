Connect-AzureAD
$Upn = Read-Host -Prompt "Enter the mail address"
$User = Get-AzureADUser -ObjectId $Upn
Get-AzureADUserOwnedObject -ObjectId $User.ObjectId | Where {$_.ObjectType -eq "Group"}
Disconnect-AzureAD