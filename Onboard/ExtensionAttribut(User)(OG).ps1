# Ensure a connection to Microsoft Graph
Connect-MgGraph

function Get-UserExtensionAttributes {
    param (
        [string]$UserId
    )
    try {
        # Search for the user by ID and fetch onPremisesExtensionAttributes
        $User = Get-MgUser -UserId $UserId -Select "onPremisesExtensionAttributes"
        if ($null -ne $User) {
            Write-Host "Current extension attributes for user $($User.DisplayName):" -ForegroundColor Cyan
            # Loop through extension attributes 1 to 15
            for ($i = 1; $i -le 15; $i++) {
                $attributeName = "extensionAttribute$i"
                $attributeValue = $User.onPremisesExtensionAttributes.$attributeName
                Write-Host "${attributeName}: ${attributeValue}"
            }
        } else {
            Write-Host "No extension attributes found."
        }
    } catch {
        Write-Host "Failed to retrieve extension attributes for user ID $UserId" -ForegroundColor Red
    }
}

# Initialize the loop control variable
$continue = $true

# Start the loop
while ($continue) {
    # Prompt for the user principal name
    $AskUser = Read-Host -Prompt "Enter the user principal name"

    # Search for the user with the specified UserPrincipalName
    try {
        $SearchUser = Get-MgUser -Filter "userPrincipalName eq '$AskUser'"
    } catch {
        Write-Host "An error occurred while searching for the user." -ForegroundColor Red
        continue
    }

    # Check if the user is found
    if ($null -eq $SearchUser) {
        Write-Host "User not found."
    } else {
        # Fetch and display current extension attributes
        Get-UserExtensionAttributes -UserId $SearchUser.Id
    }

    # Ask if the user wants to add or modify an extension attribute
    $ModifyExtension = Read-Host -Prompt "Do you want to add or modify an extension attribute? (Y/N)"
    if ($ModifyExtension -eq "Y") {
        $ExtensionNum = Read-Host -Prompt "Enter the extension number (1-15) you wish to add or modify"
        while ($ExtensionNum -lt 1 -or $ExtensionNum -gt 15) {
            Write-Host "Extension number must be between 1 and 15" -ForegroundColor Yellow
            $ExtensionNum = Read-Host -Prompt "Enter the extension number (1-15) you wish to add or modify"
            
        }
        $ExtensionValue = Read-Host -Prompt "Enter the new value for the extension attribute"

        # Update or add the extension attribute
        try {
            $updateParams = @{
                OnPremisesExtensionAttributes = @{("extensionAttribute" + $ExtensionNum) = $ExtensionValue}
            }
            Update-MgUser -UserId $SearchUser.Id -BodyParameter $updateParams
            if ($?) {
                Write-Host "Extension attribute updated successfully." -ForegroundColor Green
            }
            # Fetch and display current extension attributes
            Get-UserExtensionAttributes -UserId $SearchUser.Id
        } catch {
            Write-Host "Failed to update extension attribute."
            Write-Host $_.Exception.Message
        }
    } else {
        Write-Host "No changes made."
    }

    # Ask if the user wants to repeat the process
    $repeat = Read-Host -Prompt "Do you want to modify another user? (Y/N)"
    if ($repeat -ne "Y") {
        $continue = $false
    }
}

Disconnect-MgGraph
