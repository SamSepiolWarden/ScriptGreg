Connect-MsolService

# Chercher les utilisateurs sans licence
$NoLicenceUsers = Get-MsolUser -All | Where-Object {$_.isLicensed -eq $false} | Select-Object UserPrincipalName, ObjectId

# Créer un tableau vide pour stocker les données de l'utilisateur
$NoLicenceData = @()

# ajouter les utilisateurs sans licence au tableau
$NoLicenceData += $NoLicenceUsers

# Exporter les données dans un fichier CSV
$NoLicenceData | Export-Csv -Path C:\Test\NoLicenceUsers.csv -NoTypeInformation -Encoding UTF8
