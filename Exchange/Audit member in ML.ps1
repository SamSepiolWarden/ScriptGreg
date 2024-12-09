Connect-ExchangeOnline

# Ask for the UPN of the user
$UPN = Read-Host -Prompt "Enter the UPN of the user to get the informations"

# Get all distribution groups
$AllDG = Get-DistributionGroup -ResultSize Unlimited

# Create an array to store the distribution groups
$ExportDL = @()

foreach ($DG in $AllDG) {
    $members = Get-DistributionGroupMember -Identity $DG.Identity
    foreach ($member in $members) {
        if ($member.PrimarySmtpAddress -eq $UPN) {
            Write-Host "Distribution Group: $($DG.DisplayName) | ID: $($DG.Id)"
            
            # Create a custom object for the distribution group
            $obj = [PSCustomObject]@{
                'DistributionGroup' = $DG.DisplayName
                'ID'                = $DG.Id
            }

            # Add the object to the array
            $ExportDL += $obj
            break
        }
    }
}

if ($ExportDL.Count -eq 0) {
    Write-Host "User not found for UPN: $UPN"
} else {
    # Export the array to a CSV file
    $ExportDL | Export-Csv -Path "C:\Test\DGUser.csv" -NoTypeInformation -Append
}
Disconnect-ExchangeOnline