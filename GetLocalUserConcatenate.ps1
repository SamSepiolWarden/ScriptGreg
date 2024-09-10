# Get all local users and their status
$Users = Get-LocalUser | Select-Object -Property Name, Enabled

# Initialize an empty string to hold the output
$Output = ""

# Loop through each user, appending their details to the output string
foreach ($User in $Users) {
    $Output += "The User: $($User.Name) | Status: $($User.Enabled); "
}

# Output the complete string at once
Write-Output $Output
