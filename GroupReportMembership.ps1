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