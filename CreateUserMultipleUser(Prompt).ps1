# Connect to services
Connect-MgGraph
Connect-MsolService

# Function to create a new user
function New-User {
    param (
        [string]$fname,
        [string]$lname,
        [string]$username,
        [string]$displayName,
        [SecureString]$password
    )

    $email = "$username@sociabble.com"

    # Check if the user already exists
    $existingUser = Get-MsolUser -UserPrincipalName $email -ErrorAction SilentlyContinue
    if ($existingUser) {
        Write-Host "User $email already exists. Skipping creation."
        return
    }

    # Create new user
    New-MsolUser -DisplayName "$displayName" -FirstName "$fname" -LastName "$lname" -UserPrincipalName $email -UsageLocation FR -Password $password -BlockCredential $true
if ($?) {
    Write-Host "User $email created successfully" -ForegroundColor Green
}
$UserCreated = Get-MsolUser -UserPrincipalName $email

update-mguser -UserId $UserCreated.ObjectId -OtherMails $email
    # Additional operations like assigning license and adding to group can be included here
}

# Loop to create multiple users
do {
    $fname = Read-Host -Prompt 'Write the First Name'
    $lname = Read-Host -Prompt 'Write the Last Name'
    $username = Read-Host -Prompt 'Write the Username (First part of email address - ie: Jane.Doe)'
    $displayName = Read-Host -Prompt 'Write the Display Name'

    # Convert the password to SecureString
    $securePassword = Read-Host -Prompt "Enter the password of the user to add" -AsSecureString

    New-User -fname $fname -lname $lname -username $username -displayName $displayName -password $securePassword 

    $continue = Read-Host -Prompt 'Do you want to add another user? (yes/no)'
} while ($continue -eq 'yes')

Disconnect-MgGraph
