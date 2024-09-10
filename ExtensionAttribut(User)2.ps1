# Ensure a connection to Microsoft Graph
Connect-MgGraph

function Get-AllUsersExtensionAttributes {
    # Create an array to hold user data
    $usersData = @()

    # Get all users with the specified properties
    $allUsers = Get-MgUser -All -Property "onPremisesExtensionAttributes"

    foreach ($user in $allUsers) {
        # Initialize variables for extension attributes
        $extensionAttributesData = @()

        # Check if onPremisesExtensionAttributes property exists and is not null
        if ($null -ne $user.onPremisesExtensionAttributes) {
            for ($i = 1; $i -le 15; $i++) {
                $attributeName = "extensionAttribute$i"
                $attributeValue = $user.onPremisesExtensionAttributes.$attributeName
                Write-Host "${user.DisplayName} - ${attributeName}: ${attributeValue}"
            
                # Create a string representation for each extension attribute
                $extensionAttributeString = "${attributeName}: ${attributeValue}"
                
                # Add the string to the extensionAttributesData array
                $extensionAttributesData += $extensionAttributeString
            }
        }

        # Combine all extension attributes into a single string
        $extensionAttributesString = $extensionAttributesData -join "; "

        # Create a custom object to hold the user's data, including their extension attributes
        $userData = [PSCustomObject]@{
            UserId             = $user.Id
            DisplayName        = $user.DisplayName
            UserPrincipalName  = $user.UserPrincipalName
            ExtensionAttributes = $extensionAttributesString
        }

        # Add the custom object to the users data array
        $usersData += $userData
    }

    # Export the users data to a CSV file within the function where $usersData is accessible
    $usersData | Export-Csv -Path "UsersExtensionAttributes.csv" -NoTypeInformation
    Write-Host "Export completed successfully." -ForegroundColor Green
}

# Call the function to get all users' extension attributes and export to CSV
Get-AllUsersExtensionAttributes
