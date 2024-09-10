# Connect to Azure AD
Connect-AzureAD

# Store file paths in variables
$inputFilePath = "C:\Test\Product-OnlyRnD.csv"
$outputFilePath = "C:\Users\GregorySemedo\Desktop\Product-OnlyRnD.csv"
$sharedMailboxFilePath = "C:\Users\GregorySemedo\Desktop\SharedMailboxProduct-OnlyRnD.csv"
$staleGroupFilePath = "C:\Users\GregorySemedo\Desktop\StaleGroup.csv"
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

# Get list of users from input file
$inputUsers = Get-Content -Path $inputFilePath

# Create an empty array to store User data membership
$UserData = @()
# Loop through users
foreach ($user in $inputUsers) {
    # Get user memberships
    $memberships = Get-AzureADUserMembership -ObjectId $user

    # Loop through memberships
    foreach ($membership in $memberships) {
        $membershipData = [PSCustomObject]@{
            "User" = $user
            "DisplayName" = $membership.Displayname
            "Description" = $membership.Description
            "MailEnabled" = $membership.MailEnabled
            "ObjectType" = $membership.ObjectType
            "SecurityEnabled" = $membership.SecurityEnabled
            "Mail" = $membership.Mail
        }
        # Add membership data to stale group data array
        $UserData += $membershipData 
    }
}
# Export stale group data to CSV file
$UserData | Export-Csv -Path $outputFilePath -NoTypeInformation -Encoding UTF8


# Get list of groups
$groups = Get-AzureADGroup 

# Create an empty array to store group data
$groupData = @()
foreach ($group in $groups) {
    # Get group members
    $groupMembers = Get-AzureADGroupMember -ObjectId $group.ObjectId

    # Check if group has no members
    if (!$groupMembers) {
        $data = [PSCustomObject]@{
            "DisplayName" = $group.DisplayName
            "Description" = $group.Description
            "MailEnabled" = $group.MailEnabled
            "ObjectType" = $group.ObjectType
            "SecurityEnabled" = $group.SecurityEnabled
            "Mail" = $group.Mail
        }
        # Add group data to group data array
        $groupData += $data
    }
}
# Export group data to CSV file
$groupData | Export-Csv -Path $staleGroupFilePath -NoTypeInformation -Encoding UTF8

Connect-ExchangeOnline

# Define the path to the CSV file containing the list of users
$UserList = Import-Csv -Path "C:\Test\Product-Rnd-SharedMailbox.csv"

# Get a list of all shared mailboxes in the organization
$SharedMailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox

# Loop through each shared mailbox
foreach ($SharedMailbox in $SharedMailboxes) {

    # Get a list of users with access to the shared mailbox
    $Users = Get-MailboxPermission -Identity $SharedMailbox.Identity | Where-Object {$_.IsInherited -eq $false}

    # Loop through each user in the user list
    foreach ($User in $UserList) {

        # Check if the user has access to the shared mailbox
        $Access = $Users | Where-Object {$_.User -eq $User.User} | Select-Object -ExpandProperty AccessRights

        # Write the user, shared mailbox, and access rights to a CSV file
        $Output = [PSCustomObject]@{
            'User' = $User.User
            'SharedMailbox' = $SharedMailbox.Identity
            'AccessRights' = $Access
        }
        $Output | Export-Csv -Path $sharedMailboxFilePath -Append -NoTypeInformation
    }
}


Disconnect-AzureAD
Disconnect-ExchangeOnline