Connect-AzureAD

$noLicenceFile = "C:\Users\GregorySemedo\Desktop\NoLicenceUsers.csv"
$InputUserNoLicence = "C:\Test\NoLicenceUser.csv"

#CSV File with list of user
$NolicenceCSV = Get-Content -Path $InputUserNoLicence

# Create an empty array to store membership data for users without a licence
$noLicenceData = @()

# Loop through users
foreach ($user in $NolicenceCSV) {
    # Get user information
    $userInfo = Get-AzureADUser -ObjectId $user
    
    # Check if user has a licence
    if (!$userInfo.AssignedLicenses) {
        # Get user memberships
        $memberships = Get-AzureADUserMembership -ObjectId $user

        # Loop through memberships
        foreach ($membership in $memberships) {
            # Add data to no licence data array
            $noLicenceData += [PSCustomObject]@{
                "User" = $user
                "Group" = $membership.DisplayName
            }
        }
    }
}

# Write no licence data to output file
$noLicenceData | Export-Csv -LiteralPath $noLicenceFile -NoTypeInformation -Encoding UTF8

Disconnect-AzureAD