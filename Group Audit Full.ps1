# Connect to Azure AD
Connect-AzureAD

# Store file paths in variables
$inputFile = "C:\Test\Test.csv"
$outputFile = "C:\Users\GregorySemedo\Desktop\GroupsUsersTest.csv"
$sharedMailboxFile = "C:\Users\GregorySemedo\Desktop\SharedMailboxUsersTest.csv"
$outputFile1 = "C:\Users\GregorySemedo\Desktop\StaleGroup.csv"
# Define function to write data to CSV file
function Write-DataToCsv {
    param(
        $data,
        $filePath
    )
    # Check if file exists
    if(!(Test-Path $filePath)) {
        # If it doesn't, create it with the header row
        $data | Select-Object -Property * | Export-Csv -Path $filePath -NoTypeInformation -Encoding UTF8
    }
    else {
        # If it does, append the data to it
        $data | Select-Object -Property * | Export-Csv -Path $filePath -NoTypeInformation -Encoding UTF8 -Append
    }
}

# Get list of users from input file
$users = Get-Content -Path $inputFile

# Loop through users
foreach ($user in $users) {
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
        # Write membership data to output file
        Write-DataToCsv -data $membershipData -filePath $outputFile1
    }
}

# Get list of groups
$groups = Get-AzureADGroup 

foreach ($group in $groups) {
    # Get group members
    $members = Get-AzureADGroupMember -ObjectId $group.ObjectId

    # Check if group has no members
    if (!$members) {
        $groupData = [PSCustomObject]@{
            "DisplayName" = $group.DisplayName
            "Description" = $group.Description
            "MailEnabled" = $group.MailEnabled
            "ObjectType" = $group.ObjectType
            "SecurityEnabled" = $group.SecurityEnabled
            "Mail" = $group.Mail
        }
        # Write group data to output file
        Write-DataToCsv -data $groupData -filePath $outputFile
    }
}

# Create an empty array to store shared mailbox data
$sharedMailboxData = @()

foreach ($group in $groups) {
    # Get group members
    $members = Get-AzureADGroupMember -ObjectId $group.ObjectId

    # Check if group has members
    if ($members) {
        # Check if group is mail-enabled
        if ($group.MailEnabled) {
            # Filter members who have access to shared mailbox and are imported from input file
            $sharedMailboxMembers = $members | where {$_.MailEnabled -eq $true -and $users -contains $_.UserPrincipalName}
            
            # Loop through shared mailbox members
            foreach ($sharedMailboxMember in $sharedMailboxMembers) {
                # Add data to shared mailbox data array
                $sharedMailboxData += [PSCustomObject]@{
                    "User" = $sharedMailboxMember.UserPrincipalName
                    "Group" = $group.DisplayName
                }
            }
        }
    }
}
# Write shared mailbox data to output file
Write-DataToCsv -data $sharedMailboxData -filePath $sharedMailboxFile