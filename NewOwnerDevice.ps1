Connect-AzureAD
$NewOwner = Read-Host -Prompt "Enter the object id of the new ownerof the device"
$Device = Read-Host -Prompt "Enter the object id of the target device to be owned"
Add-AzureADDeviceRegisteredOwner -ObjectId $Device -RefObjectId $NewOwner
 If($?)
       {
        Write-Host New Owner Succesfully added -ForegroundColor Green
       } 
       Else
       {
        Write-Host New Owner Error occurred -ForegroundColor Red
       }
Disconnect-AzureAD