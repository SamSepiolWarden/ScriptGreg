# Connexion au tenant Azure AD
Connect-Msalservice
Connect-AzureAD

# Spécification du nom du groupe
$groupName = Read-Host -Prompt "ObjectId du groupe à vérifier"

# Appel à l'API Microsoft Graph pour obtenir les paramètres de groupe
$groupSettings = Invoke-MsalGraphRequest -HttpMethod GET -Url "https://graph.microsoft.com/v1.0/groups/$groupId/settings"


# Vérifie si le groupe a des paramètres
if ($groupSettings -ne $null) {
    $groupName = (Get-MsalGroup -GroupId $groupId).displayName
    Write-Host "Le groupe $groupName est rattaché aux politiques ou aux règles suivantes :"
    $groupSettings.value | ForEach-Object {
        $_.displayName
    }
} else {
    $groupName = (Get-MsalGroup -GroupId $groupId).displayName
    Write-Host "Le groupe $groupName n'est rattaché à aucune politique ou règle."
}
Disconnect-AzureAD
Disconnect-MsalService