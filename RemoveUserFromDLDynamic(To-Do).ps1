Connect-ExchangeOnline

# Ask for the user to remove from the DL
$userToRemove = Read-Host "Enter the user to remove from the DL"

# Get all DL from a given user
$DistribList = Get-DistributionGroupMember -Identity $userToRemove -ResultSize Unlimited

# Loop through each DL
foreach ($DL in $distribList) {
    # Get the DL
    $DL = Get-DistributionGroup -Identity $DL
    # Display the DL
    Write-Host $DL.DisplayName
    #Ask for remove the user from the DL
    $remove = Read-Host "Do you want to remove the user from the DL? Y/N"
    if ($remove -eq "Y") {
        # Remove the user from the DL
        Remove-DistributionGroupMember -Identity $d -Member $userToRemove
    }
    if ($remove -eq "N") {
        Write-Host "The user was not removed from the DL" | ForegroundColor Red continue
    }

    
}
Disconnect-ExchangeOnline