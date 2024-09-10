Connect-AzureAD

$User = Read-Host -Prompt "Enter the email of the user to add "

# research the manager of the user
$Manager = Get-AzureADUserManager -ObjectId $User | Select-Object -ExpandProperty UserPrincipalName

# Conditional statement to check if the user has a manager
if ($null -eq $Manager)
{
    Write-Host "The user doesn't have a manager" -ForegroundColor Green
    $AddManager = Read-Host -Prompt "Do you want to add a manager to the user? (Y/N)"
    if ($AddManager -eq "Y")
    {
        $NewManager = Read-Host -Prompt "Enter the email of the manager"
        $NewManagerObjectId = (Get-AzureADUser -ObjectId $NewManager).ObjectId
        Set-AzureADUserManager -ObjectId $User -RefObjectId $NewManagerObjectId
        Write-Host "The manager $NewManager has been added" -ForegroundColor Green
    }
    else
    {
        Write-Host "The manager doesn't need to be added" -ForegroundColor Green Disconnect-AzureAD
    }
}
else
{
    Write-Host "The manager of the user is $Manager" -ForegroundColor Green
    $ChangeManager = Read-Host -Prompt "Do you want to change the manager of the user? (Y/N)"
    if ($ChangeManager -eq "Y")
    {
        $NewManager1 = Read-Host -Prompt "Enter the email of the new manager"
        $NewManagerObjectId1 = (Get-AzureADUser -ObjectId $NewManager1).ObjectId
        Set-AzureADUserManager -ObjectId $User -RefObjectId $NewManagerObjectId1
        Write-Host "The manager has been changed to $NewManagerObjectId1" -ForegroundColor Green
    }
    else
    {
        Write-Host "The manager doesn't need to be changed" -ForegroundColor Green | Disconnect-AzureAD
    }
}
Disconnect-AzureAD