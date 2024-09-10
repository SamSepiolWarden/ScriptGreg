Connect-AzureAD
     $users = Get-Content -Path C:\Test\CSTA.csv
      ForEach ($user in $users)
             {
                 $memberships = Get-AzureADUserMembership -ObjectId $user 
                 foreach ($membership in $memberships)
                     {
                     $membershipDisplayName =  $membership.Displayname
                     $membershipMailEnabled = $membership.MailEnabled
                     $membershipObjectType = $membership.ObjectType
                     $membershipSecurityEnabled = $membership.SecurityEnabled
                     $membershipMail = $membership.Mail
                     $membershipDescription = "'"+$membership.Description.Replace("\r","")+"'"
                        
                     $out = "$user,$membershipDisplayName,$membershipDescription,$membershipMailEnabled,$membershipObjectType,$membershipSecurityEnabled,$membershipMail"
                     $out | Out-File -FilePath C:\Users\GregorySemedo\Desktop\GroupsUsersCSTA.csv -Append
                     }
             }
$groups = Get-AzureADGroup 
foreach ($group in $groups)
    {
        $members = Get-AzureADGroupMember -ObjectId $group.ObjectId
        if ($members)
            {
                $groupDisplayName = $group.DisplayName
                $groupMailEnabled = $group.MailEnabled
                $groupObjectType = $group.ObjectType
                $groupSecurityEnabled = $group.SecurityEnabled
                $groupMail = $group.Mail
                $groupDescription = "'"+$group.Description.Replace("\r","")+"'"

                $out = "$groupDisplayName,$groupDescription,$groupMailEnabled,$groupObjectType,$groupSecurityEnabled,$groupMail"
                $out | Out-File -FilePath C:\Users\GregorySemedo\Desktop\StaleGroup.csv -Append
            }
    }