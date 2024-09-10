# Connect to Azure AD
Connect-AzureAD

# Store file paths in variables
$inputFilePath = "C:\Test\AllSales.csv"
$outputFilePath = "C:\Users\GregorySemedo\Desktop\Only-Sales.csv"
$sharedMailboxFilePath = "C:\Users\GregorySemedo\Desktop\SharedMailboxOnly-Sales.csv"
$staleGroupFilePath = "C:\Users\GregorySemedo\Desktop\StaleGroup.csv"
$noLicenceFile = "C:\Users\GregorySemedo\Desktop\NoLicenceUsers.csv"
$InputUserNoLicence = "C:\Test\NoLicenceUsers.csv"

# Import CSV file with list of users
$NolicenceCSV = Import-Csv -Path $InputUserNoLicence

# Create an empty array to store membership data for users without a licence
$noLicenceData = @()

# Loop through users
foreach ($user in $NolicenceCSV) {
    # Get user information
    $userInfo = Get-AzureADUser -ObjectId $user.User
    
    # Check if user has a licence
    if (!$userInfo.AssignedLicenses) {
        # Get user memberships
        $memberships = Get-AzureADUserMembership -ObjectId $user.User

        # Loop through memberships
        foreach ($membership in $memberships) {
            # Add data to no licence data array
            $noLicenceData += [PSCustomObject]@{
                "User" = $userInfo.ObjectId
                "UPN" = $userInfo.UserPrincipalName
                "Group" = $membership.DisplayName
                "Description" = $membership.Description
                "Legit Or Not" = ""
                "Comment" = ""
                "Action" = ""
                "Action Date" = ""
                "Last Action Date" = ""
                "Reviewer" = ""
            }
        }
    }
}

# Write no licence data to output file
$noLicenceData | Export-Csv -LiteralPath $noLicenceFile -NoTypeInformation -Encoding UTF8

# Get list of users from input file
$inputUsers = Import-Csv -Path $inputFilePath

# Create an empty array to store User data membership
$UserData = @()


# Loop through users
foreach ($user in $inputUsers) {
    # Get user detail
    $userDetail = Get-AzureADUser -ObjectId $user.user
    # Get user memberships
    $memberships = Get-AzureADUserMembership -ObjectId $user.user

    # Loop through memberships
foreach ($membership in $memberships) {
    if($membership.ObjectType -eq "Role"){
        $membershipData = [PSCustomObject]@{
            "User" = $userDetail.UserPrincipalName
            "DisplayName" = ""
            "Role" = $membership.Displayname
            "Description" = $membership.Description
            "MailEnabled" = ""
            "ObjectType" = $membership.ObjectType
            "SecurityEnabled" = ""
            "Mail" = ""
            "Legit Or Not" = ""
            "Comment" = ""
            "Action" = ""
            "Action Date" = ""
            "Last Action Date" = ""
            "Reviewer" = ""
        }
        $UserData += $membershipData
    } else {
        $membershipData1 = [PSCustomObject]@{
            "User" = $userDetail.UserPrincipalName
            "DisplayName" = $membership.Displayname
            "Role" = ""
            "Description" = $membership.Description
            "MailEnabled" = $membership.MailEnabled
            "ObjectType" = $membership.ObjectType
            "SecurityEnabled" = $membership.SecurityEnabled
            "Mail" = $membership.Mail
            "Legit Or Not" = ""
            "Comment" = ""
            "Action" = ""
            "Action Date" = ""
            "Last Action Date" = ""
            "Reviewer" = ""
        }
        $UserData += $membershipData1
    }
}
}

# Export User membership data to CSV file
$UserData | Export-Csv -Path $outputFilePath -NoTypeInformation -Encoding UTF8 -Append 

# Obtenir tous les groupes Azure AD
$groups = Get-AzureADGroup -All $true

# Créer une liste vide pour stocker les groupes sans membre et sans device
$groupsNoMemberAndDevice = @()
$groupsNoOwner = @()

# Parcourir chaque groupe et vérifier s'il a des membres et des devices
ForEach ($group in $groups) {
    # Obtenir les membres du groupe
    $members = Get-AzureADGroupMember -ObjectId $group.ObjectId -All $true
    $devices = $members | Where-Object {$_.ObjectType -eq "Device"}

    # Vérifier si le groupe n'a pas de membres et pas de devices
    if ($members.Count -eq 0 -and $devices.Count -eq 0) {
        $groupsNoMemberAndDevice += $group
    }
     # Vérifier si le groupe n'a pas de propriétaire
    $owner = Get-AzureADGroupOwner -ObjectId $group.ObjectId -All $true
    if ($owner.Count -eq 0) {
        $groupsNoOwner += $group
    }
}

# Créer une liste vide pour stocker les informations sur les groupes
$table = @()

# Parcourir les groupes sans membre et sans device et obtenir les informations sur leur propriétaire
ForEach ($group in $groupsNoMemberAndDevice) {
    $owner = Get-AzureADGroupOwner -ObjectId $group.ObjectId -All $true

    # Ajouter le nom du groupe et le nom du propriétaire à la table
    $table += [PSCustomObject]@{
        GroupName = $group.DisplayName
        OwnerName = $owner.DisplayName
        GroupType = "Group without member or device"
        Description = $group.Description
        LegitOrNot = ""
        Comment = ""
        Action = ""
        ActionDate = ""
        LastActionDate = ""
        Reviewer = ""

    }
}

# Vérifier s'il y a des groupes sans membre et sans device
if ($table.Count -eq 0) {
    Write-Host "Tous les groupes ont au moins un membre ou un device." -ForegroundColor Green
} else {
    # Exporter la table au format CSV
    $table | Export-Csv -Path $staleGroupFilePath -NoTypeInformation

    # Afficher le message de confirmation
    Write-Host "Les groupes sans membre et sans device ont été exportés dans le fichier GroupOwnerWithoutMember.csv." -ForegroundColor Green
}





Connect-ExchangeOnline

# Define the path to the CSV file containing the list of users
$UserList = Import-Csv -Path "C:\Test\Only-Sales-SharedMailbox.csv"

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
            'Legit Or Not' = ""
            'Comment' = ""
            'Action' = ""
            'Action Date' = ""
            'Last Action Date' = ""
            'Reviewer' = ""
        }
        $Output | Export-Csv -Path $sharedMailboxFilePath -Append -NoTypeInformation
    }
}


Disconnect-AzureAD
Disconnect-ExchangeOnline

