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
        Write-Host "The department doesn't need to be changed" -ForegroundColor Green | Disconnect-AzureAD
    } 
}

else {
    $NewDepartment = Read-Host -Prompt "Enter the new department of the user"
    Set-AzureADUser -ObjectId $User -Department $NewDepartment
    Write-Host "The department has been changed to $NewDepartment" -ForegroundColor Green
}
Disconnect-AzureAD