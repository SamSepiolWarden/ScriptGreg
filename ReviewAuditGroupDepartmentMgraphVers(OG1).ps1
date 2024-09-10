# Connection to Microsoft Graph
Connect-MgGraph

# Prompt the user to enter the department
$Department = Read-Host -Prompt 'Enter the department'

# Define export paths
$ExportCSVPAth = "C:\Test\Export\Only-$Department.csv"
$ExportCSVExternal = "C:\Test\Export\ExternalUser.csv"
$ExportStale = "C:\Test\Export\StaleGroup.csv"
$sharedMailboxFilePath = "C:\Test\Export\SharedMailboxOnly-$Department.csv"



# Get all external users or users with no license
# Retrieve users who are guests or have disabled accounts
$ExternalUser1 = Get-MgUser -Filter "userType eq 'Guest' or accountEnabled eq false" -Property DisplayName, UserPrincipalName, Id, AssignedLicenses

# Retrieve users who have no assigned licenses
$ExternalUser2 = Get-MgUser -Property DisplayName, UserPrincipalName, Id, AssignedLicenses | Where-Object { $_.AssignedLicenses -eq $null -or $_.AssignedLicenses.Count -eq 0 }

# Combine the results and remove duplicates
$CombinedUsers = $ExternalUser1 + $ExternalUser2
$UniqueUsers = $CombinedUsers | Group-Object Id | ForEach-Object { $_.Group | Select-Object -First 1 } | Select-Object DisplayName, UserPrincipalName, Id

# Output the unique users
$UniqueUsers

# Create an array to store user data
$NoLicenseUser = @()


foreach ($user in $UniqueUsers) {
    $membership = Get-MgUserMemberOfAsGroup -UserId $user.Id
    $Apps = Get-MgUserAppRoleAssignment -UserId $user.Id

    foreach ($membershipItem in $membership) {
        # Check if the membership item is a group
            $group = Get-MgGroup -GroupId $membershipItem.Id
            $groupName = $group.DisplayName
        
        
        $NoLicenseUser += [PSCustomObject]@{
            "User"             = $user.DisplayName
            "UPN"              = $user.UserPrincipalName
            "Group"            = $groupName  # Updated to include the group's display name
            "Description"      = $membershipItem.Description
            "Apps"             = $Apps.ResourceDisplayName -join ', '
            "Legit Or Not"     = ""
            "Comment"          = ""
            "Action"           = ""
            "Action Date"      = ""
            "Last Action Date" = ""
            "Reviewer"         = ""
        }
    }
}


# Export the external user data to a CSV file
$NoLicenseUser | Export-Csv -LiteralPath $ExportCSVExternal -NoTypeInformation -Encoding UTF8
if ($NoLicenseUser) {
    Write-Host "External users Exported $ExportCSVExternal" -ForegroundColor Green
} else {
    Write-Host "No external users found" -ForegroundColor Red
}


$UserDepartment = Get-Mguser -All -property Department, DisplayName, UserPrincipalName, Id | Select-Object Department, DisplayName, UserPrincipalName, Id
$DepartmentUsers = @()
foreach ($user in $UserDepartment) {
    if ($user.Department -like "$Department*") {
        Write-Output "User: $($user.DisplayName) Department: $($user.Department) ID: $($user.Id)"
    $DepartmentUsers += $user}
}

$UserArray = @()
foreach ($user in $DepartmentUsers) {
    $membership = Get-MgUserMemberOfAsGroup -UserId $user.Id
    $Apps = Get-MgUserAppRoleAssignment -UserId $user.Id
    $roles = Get-MgUserMemberOfAsDirectoryRole -UserId $user.Id
    foreach ($membershipItem in $membership) {
        # Check if the membership item is a group
        $group = Get-MgGroup -GroupId $membershipItem.Id
        $groupName = $group.DisplayName
        $UserArray += [PSCustomObject]@{
            "User"             = $user.DisplayName
            "UPN"              = $user.UserPrincipalName
            "Group"            = $groupName  # Updated to include the group's display name
            "Description"      = $membershipItem.Description
            "Apps"             = $Apps.ResourceDisplayName -join ', '
            "Roles"            = $roles.DisplayName -join ', '
            "Legit Or Not"     = ""
            "Comment"          = ""
            "Action"           = ""
            "Action Date"      = ""
            "Last Action Date" = ""
            "Reviewer"         = ""
        }
    }
}
$UserArray | Export-Csv -LiteralPath $ExportCSVPAth -NoTypeInformation -Encoding UTF8
if ($UserArray) {
    Write-Host "Department Exported $ExportCSVPAth" -ForegroundColor Green
} else {
    
}

# get all group in the tenant

$AllGroup = Get-Mggroup -All

# Create an array to store group data
$groupsNoMemberAndDevice = @()
$groupsNoOwner = @()


foreach ($group in $AllGroup) {
    $members = Get-MgGroupMember -GroupId $group.Id
    $devices = $members | Where-Object { $_.ObjectType -eq 'device' }
    if ($members.Count -eq 0 -and $devices.Count -eq 0) {
        $groupsNoMemberAndDevice += $group}

    $owners = Get-MgGroupOwner -GroupId $group.Id
    if ($owners.Count -eq 0) {
        $groupsNoOwner += $group
    }
}

# Créer une liste vide pour stocker les informations sur les groupes
$table = @()

# Parcourir les groupes sans membre et sans device et obtenir les informations sur leur propriétaire
ForEach ($group in $groupsNoMemberAndDevice) {
    $owner = Get-MgGroupOwner -GroupId $group.Id 
    foreach ($ownerItem in $owner) {
        $ownerId = Get-MgUser -UserId $ownerItem.Id
    }

    # Ajouter le nom du groupe et le nom du propriétaire à la table
    $table += [PSCustomObject]@{
        GroupName = $group.DisplayName
        OwnerName = $ownerId.DisplayName
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
    $table | Export-Csv -Path $ExportStale -NoTypeInformation

    # Afficher le message de confirmation
    Write-Host "Les groupes sans membre et sans device ont été exportés dans le fichier GroupOwnerWithoutMember.csv." -ForegroundColor Green
}

function Export-SharedMailboxPermissions {
    param (
        [string]$Department,
        [string]$ExportPath
    )

    Connect-ExchangeOnline

    Write-Host "Connected to Exchange Online" -ForegroundColor Cyan

    $Output = @()
    $ProcessedUsers = @{}
    $UserInDepartment = @()

    Write-Host "Retrieving users from department: $Department" -ForegroundColor Cyan
    $UserDepartment = Get-MgUser -All -Property Department, DisplayName, UserPrincipalName, Id | Where-Object { $_.Department -like "$Department*" }
    foreach ($user in $UserDepartment) {
        Write-Output "User: $($user.DisplayName) Department: $($user.Department) ID: $($user.Id) UPN: $($user.UserPrincipalName)"
        $UserInDepartment += $user
    }

    if (-not $UserInDepartment) {
        Write-Host "No users found in department $Department" -ForegroundColor Yellow
        return
    }

    Write-Host "Retrieving shared mailboxes..." -ForegroundColor Cyan
    $SharedMailboxes = Get-Mailbox -RecipientTypeDetails SharedMailbox | Select-Object Identity, EmailAddresses

    if (-not $SharedMailboxes) {
        Write-Host "No shared mailboxes found" -ForegroundColor Yellow
        return
    }

    foreach ($Mailbox in $SharedMailboxes) {
        $MailboxPermissions = Get-MailboxPermission -Identity $Mailbox.Identity | Where-Object { $_.IsInherited -eq $false }

        if (-not $MailboxPermissions) {
            Write-Host "No mailbox permissions to process for $($Mailbox.Identity)" -ForegroundColor Yellow
            continue
        }

        foreach ($Permission in $MailboxPermissions) {
            $UserMatch = $UserInDepartment | Where-Object { $_.UserPrincipalName -eq $Permission.User }
            if ($UserMatch -and $Permission.AccessRights -contains "FullAccess") {
                $ProcessedUsers[$UserMatch.UserPrincipalName] = $true

                $Output += [PSCustomObject]@{
                    'User' = $UserMatch.DisplayName
                    'SharedMailbox' = $Mailbox.Identity
                    'AccessRights' = $Permission.AccessRights
                    'Legit Or Not' = ''
                    'Comment' = ''
                    'Action' = ''
                    'Action Date' = ''
                    'Last Action Date' = ''
                    'Reviewer' = ''
                }

                Write-Host "Data collected for $($UserMatch.DisplayName)" -ForegroundColor Green
            }
        }
    }

    if ($Output) {
        $Output | Export-Csv -Path $ExportPath -NoTypeInformation
        Write-Host "Export successful to $ExportPath" -ForegroundColor Green
    } else {
        Write-Host "No data to export" -ForegroundColor Yellow
    }
}

# Usage of the function
$sharedMailboxFilePath = "C:\Test\Export\SharedMailboxPermissions-$Department.csv"
$DepartmentName = $Department # Replace with the actual department name
Export-SharedMailboxPermissions -Department $DepartmentName -ExportPath $sharedMailboxFilePath
Disconnect-MgGraph
Disconnect-ExchangeOnline