# Connecter à AzureAD
Connect-AzureAD

# Obtenir tous les utilisateurs
$Users = Get-AzureADUser -All $true | Where-Object {$_.UserPrincipalName -like '*@sociabble.com*'}

# Créer une liste vide pour stocker les résultats
$results = @()

foreach ($User in $Users)
{
    try 
    {
        # Obtenir le gestionnaire de l'utilisateur
        $Manager = Get-AzureADUserManager -ObjectId $User.ObjectId

        if($null -eq $Manager)
        {
            Write-Host "$($User.UserPrincipalName) n'a pas de manager" -ForegroundColor Red
            # Ajouter l'objet à la liste de résultats
            $results += $User
        }
        else 
        {
            # Ne fait rien si l'utilisateur a un manager
        }
    }
    catch 
    {
        Write-Host "Erreur lors de l'obtention du manager pour l'utilisateur $($User.UserPrincipalName) : $_" -ForegroundColor Yellow
    }
}

# Exporter les résultats dans un fichier CSV
$results | Export-Csv -Path C:\Test\UserWithNoManager.csv -NoTypeInformation
