# Connect to Microsoft Graph
Connect-MgGraph

# Continue prompting the user until they choose to stop
$AskUser = "Y"
while ($AskUser -ne "N") {
    # Prompt the user to enter the UPN of the user to get information for
    $UPN = Read-Host -Prompt "Enter the UPN of the user to get the information"

    # Initialize a properties object
    $properties = @{}

    # Assign a value to the isUsableOnce property
    $properties.isUsableOnce = $false

    # Get the current date and time
    $Date = Get-Date
    $DateAdd = [System.DateTime]::Parse($Date)

    # Assign the start date and time for the temporary access pass
    $properties.startdateTime = $DateAdd

    # Set the lifetime of the temporary access pass to 21600 minutes
    $properties.LifetimeInMinutes = 21600

    # Convert the properties object to JSON format
    $propertiesJson = $properties | ConvertTo-Json

    # Initialize a hash table to store the user's temporary access pass
    $hash = @{}

    # Prompt the user to add a temporary access pass for the specified user
    $AskToAdd = Read-Host -Prompt "Do you want to add a Tap to $UPN ? (Y/N)"
    if ($AskToAdd -eq "Y") {
        # Add a temporary access pass for the user
        $AddTap = New-MgUserAuthenticationTemporaryAccessPassMethod -UserId $UPN -BodyParameter $propertiesJson

        # If the temporary access pass was added successfully
        if($null -ne $AddTap) {
            # Display the temporary access pass that was added
            $AddTap

            # Get the temporary access pass for the user
            Get-MgUserAuthenticationTemporaryAccessPassMethod -UserId $UPN

            # Add the user's temporary access pass to the hash table
            $Hash.add($UPN, $AddTap.TemporaryAccessPass)

            # Display the hash table containing the user's temporary access pass
            $hash.GetEnumerator() | Select-Object -Property @{N="$UPN";E={$_.Key}}, @{N='Temporary Access Pass';E={$_.Value}}
        } else {
            # Display an error message if there was an issue adding the temporary access pass
            Write-Host "Error while adding Tap"
        }
    } else {
        # Display a message indicating that no temporary access pass was added
        Write-Host "No Tap added"

        # Get the temporary access pass for the user
        Get-MgUserAuthenticationTemporaryAccessPassMethod -UserId $UPN
    }

    # Prompt the user to add another temporary access pass
    $AskUser = Read-Host -Prompt "Do you want to add another Tap ? (Y/N)"
}

# Display a message indicating that the addition of temporary access passes has ended
Write-Host "End of the Tap addition" -ForegroundColor Cyan

# Disconnect from Microsoft Graph
Disconnect-MgGraph