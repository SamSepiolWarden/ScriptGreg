
# Se connecter à Microsoft Graph avec les autorisations appropriées
Connect-MgGraph -Scopes "TeamworkTag.ReadWrite"

# Importer les identifiants d'équipes à partir d'un fichier CSV
$SearchTeam = Import-Csv -Path "C:\Test\TeamsId.csv"

# Saisir l'identifiant de l'utilisateur
$User = Read-Host -Prompt "Enter the object id of the user"

# Si aucun utilisateur n'est spécifié, arrêter l'exécution
if ([string]::IsNullOrEmpty($User)) {
    Write-Host "No user id provided, stopping script..." -ForegroundColor Red
    return
}

# Parcourir chaque identifiant d'équipe
foreach ($Id in $SearchTeam) {
    # Récupérer les tags d'équipe
    $teamTags = Get-MgTeamTag -TeamId $Id.Id -All | Select-Object -Property Id, DisplayName

    # Initialiser une variable pour vérifier si un tag a été trouvé
    $tagFound = $false

    # Parcourir chaque tag
    foreach ($tag in $teamTags) {
        if ($tag.DisplayName -eq "OnlyPresales"){
            $tagFound = $true
            try {
                New-MgTeamTagMember -TeamId $Id.Id -TeamworkTagId $tag.Id -UserId $User
                Write-Host "User successfully added to tag" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to add user to tag: $_" -ForegroundColor Red
            }
        }
    }
    
    # Si aucun tag correspondant n'a été trouvé, afficher un message
    if (-not $tagFound) {
        Write-Host "No tag OnlyPreSales found" -ForegroundColor Gray
    }
}

# Se déconnecter de Microsoft Graph
Disconnect-MgGraph

