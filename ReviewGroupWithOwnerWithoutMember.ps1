# Se connecter à Azure AD
Connect-AzureAD

# Obtenir tous les groupes Azure AD
$groups = Get-AzureADGroup -All $true

# Créer une liste vide pour stocker les groupes sans membre
$groupsNoMember = @()

# Parcourir chaque groupe et vérifier s'il a des membres
ForEach ($group in $groups) {
  # Obtenir les membres du groupe
  $members = Get-AzureADGroupMember -ObjectId $group.ObjectId -All $true
  
  # Si le groupe n'a pas de membres, l'ajouter à la liste
  if ($members.Count -eq 0) {
    $groupsNoMember += $group
  }
}

# Afficher les groupes sans membre et leur propriétaire
ForEach ($groupNoMember in $groupsNoMember) {
  # Obtenir le propriétaire du groupe
  $owner = Get-AzureADGroupOwner -ObjectId $groupNoMember.ObjectId -All $true}
  
#Créer une table avec les groupes sans membres et leur propriétaire

$table = @()
ForEach ($groupNoMember in $groupsNoMember) {
#Obtenir le propriétaire du groupe

$owner = Get-AzureADGroupOwner -ObjectId $groupNoMember.ObjectId -All $true
#Ajouter le nom du groupe et le nom du propriétaire à la table

$table += [PSCustomObject]@{
GroupName = $groupNoMember.DisplayName
OwnerName = $owner.DisplayName
}
}
#Exporter la table au format CSV

$table | Export-Csv -Path "C:\Test\GroupOwnerWithoutMember.csv" -NoTypeInformation
#Afficher le message de confirmation

Write-Host "Les groupes sans membre ont été exportés dans le fichier Groupes_sans_membre.csv." -ForegroundColor Green