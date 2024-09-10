# Ensure a connection to Microsoft Graph
Connect-MgGraph

function Get-AllUsersExtensionAttributes {
    $usersData = @()
    $allUsers = Get-MgUser -All -Property Id, DisplayName, UserPrincipalName, onPremisesExtensionAttributes

    foreach ($user in $allUsers) {
        # Assuming onPremisesExtensionAttributes property exists (even if it may be null for some attributes)
        for ($i = 1; $i -le 15; $i++) {
            $attributeName = "extensionAttribute$i"
            $attributeValue = $user.onPremisesExtensionAttributes.$attributeName
            
            # No need to check if the attribute value is not null or empty, proceed to add it regardless
            # Create a custom object for each extension attribute, including empty ones
            $userData = [PSCustomObject]@{
                UserId              = $user.Id
                DisplayName         = $user.DisplayName
                UserPrincipalName   = $user.UserPrincipalName
                AttributeName       = $attributeName
                AttributeValue      = $attributeValue -as [string]
            }

            # Add the custom object to the users data array
            $usersData += $userData
        }
    }

    # Define the CSV file path
    $csvPath = "C:\Test\UsersExtensionAttributes.csv"
    # Export the users data to a CSV file
    $usersData | Export-Csv -Path $csvPath -NoTypeInformation
    Write-Host "Export completed successfully to $csvPath" -ForegroundColor Green
}

# Call the function to execute
Get-AllUsersExtensionAttributes
