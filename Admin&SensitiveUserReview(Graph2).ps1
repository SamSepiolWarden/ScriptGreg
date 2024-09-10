Connect-Mggraph

$UserAdmin = Get-MgUser -All | Where-Object {
    $_.UserPrincipalName -like "*admin*" -or 
    $_.UserPrincipalName -eq "gregory.semedo@sociabble.com" -or 
    $_.UserPrincipalName -eq "Thierry.rotin@sociabble.com" -or 
    $_.UserPrincipalName -eq "Stephane.escandell@sociabble.com" -or 
    $_.UserPrincipalName -like "aiworkshop*@sociabble.com" -or 
    $_.UserPrincipalName -eq "automated-ui-tests@sociabble.com" -or 
    $_.UserPrincipalName -eq "jane.doe@sociabble.org" -or 
    $_.UserPrincipalName -eq "jean.lannes@sociabble.com"}

$userData = @()

foreach ($user in $UserAdmin) {
    $memberships = Get-MgUserMemberOfAsGroup -UserId $user.Id | Where-Object {$_.SecurityEnabled -eq "True" -or $_.ObjectType -eq "Role"}

    foreach ($membership in $memberships) {
        if($membership.ObjectType -eq "Role"){
            $membershipData = [PSCustomObject]@{
                "User" = $user.Id
                "UPN" = $user.UserPrincipalName
                "Group" = ""
                "Role" = $membership.DisplayName
                "Description" = $membership.Description
                "Legit Or Not" = ""
                "Comment" = ""
                "Action" = ""
                "Action Date" = ""
                "Last Action Date" = ""
                "Reviewer" = ""
            }
            $userData += $membershipData
        }
        else{
            $membershipData = [PSCustomObject]@{
                "User" = $user.Id
                "UPN" = $user.UserPrincipalName
                "Group" = $membership.DisplayName
                "Description" = $membership.Description
                "Role" = ""
                "Legit Or Not" = ""
                "Comment" = ""
                "Action" = ""
                "Action Date" = ""
                "Last Action Date" = ""
                "Reviewer" = ""
            }
            $userData += $membershipData
        }
        
        }
    }

# Retrieve all administrator roles
$adminRoles = Get-MgDirectoryRole

# Initialize a list to hold all admin users and group details
$adminUsers = New-Object System.Collections.Generic.List[Object]

foreach ($role in $adminRoles) {
    $roleMembers = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id
    foreach ($member in $roleMembers) {
        try {
            # Attempt to retrieve the user
            $roleMembersUser = Get-MgUser -UserId $member.Id
            if ($null -eq $roleMembersUser) {
                $groupDetails = Get-MgGroup -GroupId $member.Id
                $userDetails = [PSCustomObject]@{
                    User = $groupDetails.Id
                    UPN = "$groupDetails.MailNickname"
                    DisplayName = $groupDetails.DisplayName
                    Role = $role.DisplayName
                    "Legit Or Not" = ""
                    Comment = "This is a group"
                    Action = ""
                    "Action Date" = ""
                    "Last Action Date" = ""
                    Reviewer = ""
                }
                $adminUsers.Add($userDetails)
            }
        }
        catch {
            # Catch block to handle errors, if any.
        }
        
        # Check if $roleMembersUser is not null outside the try-catch
        if ($null -ne $roleMembersUser) {
            $userDetails1 = [PSCustomObject]@{
                "User" = $roleMembersUser.Id
                "UPN" = $roleMembersUser.UserPrincipalName
                "DisplayName" = $roleMembersUser.DisplayName
                "Role" = $role.DisplayName
                "Legit Or Not" = ""
                "Comment" = ""
                "Action" = ""
                "Action Date" = ""
                "Last Action Date" = ""
                "Reviewer" = ""
            }
            $adminUsers.Add($userDetails1)
        }
    }
}


# $adminUsers now contains details for all users and groups, you can export it as needed


$userData | Export-Csv -Path "C:\Test\AdminExport\AdminUserReview.csv" -NoTypeInformation -Encoding UTF8
$adminUsers | Export-Csv -Path "C:\Test\AdminExport\AdminUserReview1.csv" -NoTypeInformation -Encoding UTF8

Disconnect-MgGraph