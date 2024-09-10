# Connect to Azure AD
Connect-AzureAD

# Store file paths in variables
$inputFilePath = "C:\Test\Test.csv"
$outputFilePath = "C:\Users\GregorySemedo\Desktop\GroupsUsersTest.csv"
$sharedMailboxFilePath = "C:\Users\GregorySemedo\Desktop\SharedMailboxUsersTest.csv"
$staleGroupFilePath = "C:\Users\GregorySemedo\Desktop\StaleGroup.csv"

# Define function to write data to CSV file
function Write-DataToCsv {
    param(
        $data,
        $filePath
    )
    try {
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
    catch {
        Write-Error "An error occurred while writing data to $filePath. Error: $_"
    }
}

# Get list of users from input file
$inputUsers = Get-Content -Path $inputFilePath

# Loop through users
foreach ($user in $inputUsers) {
    # Get user memberships
    $memberships = Get-AzureADUserMemberships -ObjectId $user

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
        Write-DataToCsv -data $membershipData -filePath $staleGroupFilePath
    }
}

# Get list of groups
$groups = Get-AzureADGroup 

foreach ($group in $groups) {
    # Get group members
    $groupMembers = Get-AzureADGroupMember -ObjectId $group.ObjectId

    # Check if group has no members
    if (!$groupMembers) {
        $groupData = [PSCustomObject]@{
            "DisplayName" = $group.DisplayName
            "Description" = $group.Description
            "MailEnabled" = $group.MailEnabled
            "ObjectType" = $group.ObjectType
            "SecurityEnabled" = $group.SecurityEnabled
            "Mail" = $group.Mail
        }
        # Write group data to output file
        Write-DataToCsv -data $groupData -filePath $outputFilePath
    }
}

# Create an empty list to store shared mailbox data
$sharedMailboxData = New-Object System.Collections.Generic.List[PSObject]

foreach ($group in $groups) {
    # Get group members
    $groupMembers = Get-AzureADGroupMember -ObjectId $group.ObjectId

    # Check if group has members
    if ($groupMembers) {
        # Check if group is mail-enabled
        if ($group.MailEnabled) {
            # Filter members who have access to shared mailbox and are imported from input file
            $sharedMailboxMembers = $groupMembers | where {$_.MailEnabled -eq $true -and $inputUsers -contains $_.UserPrincipalName}
            
            # Loop through shared mailbox members
            foreach ($sharedMailboxMember in $sharedMailboxMembers) {
                # Add data to shared mailbox data list
                $sharedMailboxData.Add([PSCustomObject]@{
                    "User" = $sharedMailboxMember.UserPrincipalName
                    "Group" = $group.DisplayName
                })
            }
        }
    }
}
# Write shared mailbox data to output file
Write-DataToCsv -data $sharedMailboxFilePath


