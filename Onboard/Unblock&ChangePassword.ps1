# Connect to Microsoft Graph using the MgGraph module
Connect-MgGraph

# Initialize loop control variable
$continue = "Y"

# Loop to process multiple users until the user decides to stop
while ($continue -eq "Y") {

    # Initialize SearchUser variable to ensure a new search each iteration
    $SearchUser = $null

    # Loop until a valid user is found
    while ($null -eq $SearchUser) {

        # Prompt for user email input
        $UserId = Read-Host "Enter the user email to unblock and change password"

        # Input validation to ensure the email is provided
        if ([string]::IsNullOrWhiteSpace($UserId)) {
            Write-Host "Email address cannot be empty. Please try again." -ForegroundColor Yellow
            continue # Restart the loop if the input is invalid
        }

        # Try to find the user based on the entered email (userPrincipalName)
        try {
            $SearchUser = Get-MgUser -Filter "userPrincipalName eq '$UserId'"
        }
        catch {
            Write-Host "An error occurred while searching for the user: $_" -ForegroundColor Red
            continue
        }

        # If user not found, prompt again
        if ($null -eq $SearchUser) {
            Write-Host "User not found. Please try again." -ForegroundColor Red
        }
        else {
            # Unblock the user by enabling the account
            try {
                Update-MgUser -UserId $SearchUser.Id -BodyParameter @{accountEnabled = $true}
                Write-Host "$($SearchUser.DisplayName) unblocked." -ForegroundColor Green
            }
            catch {
                Write-Host "An error occurred while unblocking the user: $_" -ForegroundColor Red
            }
            $AskChangePassword = Read-Host "Do you want to change the password for $($SearchUser.DisplayName)? (Y/N)"
            if ($AskChangePassword.ToUpper() -ne "Y") {
                continue
            }
            # Prompt for a new password
            $NewPassword = Read-Host "Enter the new password for the user"

            # Input validation to ensure a password is provided
            if ([string]::IsNullOrWhiteSpace($NewPassword)) {
                Write-Host "Password cannot be empty. Please try again." -ForegroundColor Yellow
                continue
            }

            # Set the new password for the user
            try {
                Set-MgUserPassword -UserId $SearchUser.Id -Password $NewPassword
                Write-Host "Password changed successfully." -ForegroundColor Green
            }
            catch {
                Write-Host "An error occurred while changing the password: $_" -ForegroundColor Red
            }
        }
    }

    # Ask if the user wants to process another user
    $continue = Read-Host "Do you want to unblock and change password for another user? (Y/N)"

    # Normalize input for continue decision
    if ($continue.ToUpper() -ne "Y") {
        $continue = "N"
    }
}

# Inform the user that the script is exiting
Write-Host "Exiting script." -ForegroundColor Green
