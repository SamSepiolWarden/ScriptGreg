# Connectez-vous à Azure AD
Connect-AzureAD

#Variable user
$User = Read-Host -Prompt 'Enter your object id or UPN'

# commande pour lister les groupes
$Groups = Get-AzureADUserOwnedObject -ObjectId $User -All $true | where { $_.ObjectType -eq "Group" -and $_.SecurityEnabled} 

#Export
$Groups | Export-Csv -Path C:\Test\OwnGroup.csv -NoTypeInformation -Append
