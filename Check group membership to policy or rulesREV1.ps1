# Connexion au tenant Azure AD
Connect-Mggraph

# Spécification du nom du groupe
$groupName = Read-Host -Prompt "ObjectId du groupe à vérifier"

# Appel à l'API Microsoft Graph pour obtenir les paramètres de groupe
$groupSettings = Get-MgGroupSetting -GroupId $groupId

# Vérifie si le groupe a des paramètres
if ($groupSettings -ne $null) {
    $groupName = Get-MgGroup -GroupId $groupId | Select-Object -ExpandProperty DisplayName
    Write-Host "Le groupe $groupName est rattaché aux politiques ou aux règles suivantes :"
    $groupSettings | Select-Object -Property DisplayName
} else {
    $groupName = Get-MgGroup -GroupId $groupId | Select-Object -ExpandProperty DisplayName
    Write-Host "Le groupe $groupName n'est rattaché à aucune politique ou règle."
}
Disconnect-Mggraph