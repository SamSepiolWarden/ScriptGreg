Connect-AzureAD
$Name = Read-Host -Prompt "Enter the name of the user"
Get-AzureADUser -SearchString "$Name"
$Device = Read-Host -Prompt "Enter the name of the device"
Get-AzureADDevice -SearchString "$Device".ObjectId
$ObjectID = Read-Host -Prompt "Enter the object Id of the device"
$OwnerId = Read-Host -Prompt "Enter the object id of the User"
Remove-AzureADDeviceRegisteredOwner -ObjectId "$ObjectID" -OwnerId "OwnerId"
if($?)
{Write-Host Owner Succesfully add -ForegroundColor Green}
else
{Write-Host -ErrorAction Stop -ForegroundColor Red}
Get-AzureADDeviceRegisteredOwner -ObjectId $ObjectID
Disconnect-AzureAD

