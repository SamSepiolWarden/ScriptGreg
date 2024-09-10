Connect-AzureAD

# Enter the user to add or change department
$User = Read-Host -Prompt "Enter the email of the user to add or change department "

# Get the department of the user
$Department = (Get-AzureADUser -ObjectId $User).Department

# Conditional statement to check if the user has a department
if($Department)
{
    Write-Host "The department of the user is $Department" -ForegroundColor Green 
    $ChangeDepartment = Read-Host -Prompt "Do you want to change the department of the user? (Y/N)" 
    if ($ChangeDepartment -eq "Y")
    {
        $NewDepartment = Read-Host -Prompt "Enter the new department of the user"
        Set-AzureADUser -ObjectId $User -Department $NewDepartment
        Write-Host "The department has been changed to $NewDepartment" -ForegroundColor Green 
    }
    else
    {
        Write-Host "The department doesn't need to be changed" -ForegroundColor Green 
    } 
}

else {
    $NewDepartment = Read-Host -Prompt "Enter the new department of the user"
    Set-AzureADUser -ObjectId $User -Department $NewDepartment
    Write-Host "The department has been changed to $NewDepartment" -ForegroundColor Green
}

# research the manager of the user
$Manager = Get-AzureADUserManager -ObjectId $User | Select-Object -ExpandProperty UserPrincipalName

# Conditional statement to check if the user has a manager
if ($null -eq $Manager)
{
    Write-Host "The user doesn't have a manager" -ForegroundColor Red
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
        Write-Host "The manager has been changed to $NewManager1" -ForegroundColor Green
    }
    else
    {
        Write-Host "The manager doesn't need to be changed" -ForegroundColor Green | Disconnect-AzureAD
    }
}

Disconnect-AzureAD