# Ensure a connection to Microsoft Graph
Connect-MgGraph

function Get-AllUsersExtensionAttributes {
    # Create an empty array to hold user data
    $usersData = @()

    # Get all users
    $allUsers = Get-MgUser -All

    foreach ($user in $allUsers) {
        # Create a custom object to hold the user's data
        $userData = [PSCustomObject]@{
            UserId = $user.Id
            DisplayName = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            extension = $attributeValue
            
        }

        # Loop through extension attributes 1 to 15 and add them to the custom object
        for ($i = 1; $i -le 15; $i++) {
            $attributeName = "extensionAttribute$i"
            # Attempt to fetch the attribute value, if it exists
            $attributeValue = $user.OnPremisesExtensionAttributes.$attributeName
            # Add the attribute to the custom object
            $userData | Add-Member -NotePropertyName $attributeName -NotePropertyValue $attributeValue
        }

        # Add the custom object to the users data array
        $usersData += $userData
    }

    # Export the users data to a CSV file
    $usersData | Export-Csv -Path C:\Test\UsersExtensionAttributes.csv -NoTypeInformation
    Write-Host "Export completed successfully." -ForegroundColor Green
}

# Call the function to get all users' extension attributes and export to CSV
Get-AllUsersExtensionAttributes
