Connect-ExchangeOnline

function AddUserToDistributionGroup {
    # Prompt for a user display name
    $UserPrompt = Read-Host -Prompt 'Enter the user display name'
    # Get a user by displayname
$UserExo = Get-EXOMailbox -Identity $UserPrompt | Select-Object -ExpandProperty UserPrincipalName
    if ($null -ne $UserExo) {
        Write-Host "User $UserPrompt found" -ForegroundColor Green
    } else {
        Write-Host "User $UserPrompt not found" -ForegroundColor Red
        Disconnect-ExchangeOnline
        exit
    }

    # Prompt for a distribution list by display name
    $DLPrompt = Read-Host -Prompt 'Enter the distribution list display name'

    # Get a distribution list by display name
    $DistributionGroup = Get-distributiongroup -Identity $DLPrompt
    if ($DistributionGroup) {
        Write-Host "Distribution list $DLPrompt found" -ForegroundColor Green
    } else {
        Write-Host "Distribution list $DLPrompt not found" -ForegroundColor Red
        Disconnect-ExchangeOnline
        exit
    }

    if ($DistributionGroup) {
        # Add the user to the distribution list
        Add-DistributionGroupMember -Identity $DLPrompt -Member $UserExo
        Write-Host "Added $UserPrompt to $DLPrompt" -ForegroundColor Green
    } else {
        Write-Host "Distribution list $DLPrompt not found" -ForegroundColor Red
    }
}

AddUserToDistributionGroup

$Ask = Read-Host -Prompt "Do you want to add another user to the distribution list ? (Y/N)"

while ($Ask -eq "Y") {
    AddUserToDistributionGroup
    $Ask = Read-Host -Prompt "Do you want to add another user to the distribution list ? (Y/N)"
}

if ($Ask -eq "N") {
    Write-Host "No more user to add to the distribution list" -ForegroundColor Green
}

Disconnect-ExchangeOnline

