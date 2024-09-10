Connect-MgGraph -Scopes TeamworkTag.ReadWrite, Team.ReadBasic.All, TeamSettings.Read.All, TeamSettings.ReadWrite.All, Group.Read.All, Directory.Read.All, Group.ReadWrite.All
# Repetion du code
$Repetition = Read-Host -Prompt "Entrer le nombre de fois que le code doit être répété"

# Initialisation du compteur
$compteur = 0

# Créer une liste pour stocker les données des tags
$tagsData = @()

while ($compteur -lt $Repetition) {
    $TeamID = Read-Host -Prompt "Enter the teams Id"
    $team = Get-MgTeam -TeamId $TeamID
    $TeamDisplayName = $team.DisplayName
    $Team

    # Afficher les tags de l'équipe
    Write-Host "Tags de l'équipe :"
    $teamTags = Get-MgTeamTag -TeamId $TeamID -All | Select-Object -Property Id, DisplayName

    foreach ($tag in $teamTags) {
        # Ajouter les données des tags à la liste avec le nom de l'équipe
        $tagData = [PSCustomObject] @{
            TeamName = $teamDisplayName
            TeamId = $TeamID
            TagId = $tag.Id
            DisplayName = $tag.DisplayName
        }
        $tagsData += $tagData
    }

    # Ajouter les données des tags à la liste
    $tagsData += $tags

    $teamTags | Format-Table

    Write-Host "Le code s'est éxécuté $($compteur + 1) fois"
    $compteur++

  
}
  # Exporter les données des tags dans un tableur Excel
$exportPath = "C:\Test\Teamstag.csv"
$tagsData | Export-Csv -Path $exportPath -Encoding UTF8


Disconnect-MgGraph