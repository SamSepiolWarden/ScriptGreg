# Ensure a connection to Microsoft Graph and Azure AD
Connect-MgGraph
Connect-AzureAD

# Initialize the loop control variable
$continue = $true

# Start the loop
while ($continue) {
    # Prompt for the user principal name
    $SAskUser = Read-Host -Prompt "Enter the user principal name"

    # Search for the user with the specified UserPrincipalName
    $SearchUser = Get-MgUser -Filter "UserPrincipalName eq '$SAskUser'"

    # Check if the user is found
    if ($null -eq $SearchUser) {
        Write-Host "User not found."
    } else {
        # Display User ID
        $UserID = $SearchUser.Id
        Write-Host "User ID: $UserID"

        # Fetch and display current extension attributes using Azure AD Command
        $SearchUserExtensions = Get-AzureADUserExtension -ObjectId $UserID

        if ($SearchUserExtensions) {
            Write-Host "Current extension attributes:"
            $SearchUserExtensions | ForEach-Object { Write-Host "$($_.Key): $($_.Value)" }
        } else {
            Write-Host "No extension attributes found."
        }

        # Ask if the user wants to add or modify an extension attribute
        $ModifyExtension = Read-Host -Prompt "Do you want to add or modify an extension attribute? (Y/N)"
        if ($ModifyExtension -eq "Y") {
            $ExtensionName = Read-Host -Prompt "Enter the full extension name (e.g., extension_{appId}_{attributeName})"
            $ExtensionValue = Read-Host -Prompt "Enter the new value for the extension attribute"

            # Update or add the extension attribute
            try {
                Set-AzureADUserExtension -ObjectId $UserID -ExtensionName $ExtensionName -ExtensionValue $ExtensionValue
                Write-Host "Extension attribute updated successfully."
            } catch {
                Write-Host "Failed to update extension attribute."
            }
        } else {
            Write-Host "No changes made."
        }
    }

    # Ask if the user wants to repeat the process
    $repeat = Read-Host -Prompt "Do you want to modify another user? (Y/N)"
    if ($repeat -ne "Y") {
        $continue = $false
    }
}
