Connect-AzureAD
$Name = Read-Host -Prompt "Enter the name of the user"
Get-AzureADUser -SearchString "$Name"
$Device = Read-Host -Prompt "Enter the name of the device"
Get-AzureADDevice -SearchString "$Device"
$ObjectID = Read-Host -Prompt "Enter the object Id of the device"
$RefObjectId = Read-Host -Prompt "Enter the object id of the Owner to remove"
Remove-AzureADDeviceRegisteredOwner -ObjectId "$ObjectId" -OwnerId "$RefObjectId"
if($?)
{Write-Host Owner Succesfully Remove -ForegroundColor Green}
else
{Write-Host -ErrorAction Stop -ForegroundColor Red}
$User = Read-Host -Prompt "Enter the name of the new owner"
Get-AzureADUser -SearchString "$User"
$NewObjectId = Read-Host -Prompt "Enter the object id of the Owner to Add"
Add-AzureADDeviceRegisteredOwner -ObjectId "$ObjectID" -RefObjectId "$NewObjectId"
if($?)
{Write-Host Owner Succesfully add -ForegroundColor Green}
else
{Write-Host -ErrorAction Stop -ForegroundColor Red}
Get-AzureADDeviceRegisteredOwner -ObjectId $ObjectID
Disconnect-AzureAD

