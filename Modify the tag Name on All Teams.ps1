# Se connecter à Microsoft Graph avec les autorisations appropriées
Connect-MgGraph -Scopes "TeamworkTag.ReadWrite"

# Importer les identifiants d'équipes à partir d'un fichier CSV
$SearchTeam = Import-Csv -Path "C:\Test\TeamsId.csv"
$TagNewName = Read-Host -Prompt "Enter the new tag name"

# Parcourir les équipes
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
                Update-MgTeamTag -TeamId $Id.Id -TeamworkTagId $tag.Id -DisplayName $TagNewName
                Write-Host "$teamTags.DisplayName successfully modifyed the tag $tag.displayneme" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to modify the tag: $_" -ForegroundColor Red
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
