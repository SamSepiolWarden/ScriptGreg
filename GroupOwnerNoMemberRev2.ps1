# Se connecter à Azure AD
Connect-AzureAD

# Obtenir tous les groupes Azure AD
$groups = Get-AzureADGroup -All $true

# Créer une liste vide pour stocker les groupes sans membre et les groupes non-membres
$groupsNoMember = @()
$groupsNonMember = @()

# Parcourir chaque groupe et vérifier s'il a des membres ou s'il est membre d'un autre groupe
ForEach ($group in $groups) {
  # Obtenir les membres du groupe
  $members = Get-AzureADGroupMember -ObjectId $group.ObjectId -All $true

  # Vérifier si le groupe n'a pas de membres
  if ($members.Count -eq 0) {
    $groupsNoMember += $group
  }
  
  # Vérifier si le groupe n'est pas membre d'un autre groupe
  $memberOfGroups = Get-AzureADGroupMember -ObjectId $group.ObjectId -All $true | Where-Object {$_.ObjectType -eq "Group"}
  if ($memberOfGroups.Count -eq 0 -and $members.Count -eq 0) {
    $groupsNonMember += $group
  }
}

# Créer une liste vide pour stocker les informations sur les groupes
$table = @()

# Parcourir les groupes sans membre et les groupes non-membres et obtenir les informations sur leur propriétaire
ForEach ($group in ($groupsNoMember + $groupsNonMember)) {
  $owner = Get-AzureADGroupOwner -ObjectId $group.ObjectId -All $true
  
  # Ajouter le nom du groupe et le nom du propriétaire à la table
  $table += [PSCustomObject]@{
    GroupName = $group.DisplayName
    OwnerName = $owner.DisplayName
    GroupType = if ($groupsNoMember -contains $group) {"GroupWithoutMember"} else {"GroupNonMember"}
  }
}

# Vérifier s'il y a des groupes sans membre ou des groupes non-membres
if ($table.Count -eq 0) {
  Write-Host "Tous les groupes ont au moins un membre." -ForegroundColor Green
} else {
  # Exporter la table au format CSV
  $table | Export-Csv -Path "C:\Test\GroupOwnerWithoutMember.csv" -NoTypeInformation

  # Afficher le message de confirmation
  Write-Host "Les groupes sans membre et les groupes non-membres ont été exportés dans le fichier GroupOwnerWithoutMember.csv." -ForegroundColor Green
}
