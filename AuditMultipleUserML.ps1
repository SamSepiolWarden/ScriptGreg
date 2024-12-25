Connect-ExchangeOnline
Connect-MgGraph

# Ask for the UPN of the user
$UPNs = Get-MgUser -All $true | Select-Object -ExpandProperty UserPrincipalName

foreach ($UPN in $UPNs) {
    Write-Host "User: $UPN"


# Get all distribution groups
$AllDG = Get-DistributionGroup -ResultSize Unlimited

# Create an array to store the distribution groups
$ExportDL = @()

foreach ($DG in $AllDG) {
    $members = Get-DistributionGroupMember -Identity $DG.Identity
    foreach ($member in $members) {
        if ($member.PrimarySmtpAddress -eq $UPNs) {
            Write-Host "Distribution Group: $($DG.DisplayName) | ID: $($DG.Id)"
            
            # Create a custom object for the distribution group
            $obj = [PSCustomObject]@{
                'DistributionGroup' = $DG.DisplayName
                'ID'                = $DG.Id
                'User'              = $UPN
            }

            # Add the object to the array
            $ExportDL += $obj
            break
        }
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