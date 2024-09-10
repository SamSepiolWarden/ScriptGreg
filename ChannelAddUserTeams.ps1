Connect-MicrosoftTeams

#entrer le nom de l'utilisateur
$User = Read-Host -Prompt "Entrer le nom de l'utilisateur"
#Chercher l'dentifiant de l'utilisateur
$UserId = Get-TeamUser -Filter "displayName eq '$User'" | Select-Object Id
if ($?) {
    Write-Host "L'utilisateur $User a ete trouver" -ForegroundColor Green
}
else {
    Write-Host "L'utilisateur $User n'a pas ete trouver" -ForegroundColor Red -ErrorAction Stop | Write-Host "Can't continue the process" | Disconnect-MicrosoftTeams
}

#entrer le nom de l'equipe
$Team = Read-Host -Prompt "Entrer le nom de l'equipe"
#Chercher l'dentifiant de l'equipe
$TeamId = Get-Team -Filter "displayName eq '$Team'" | Select-Object Id
if ($?) {
    Write-Host "L'equipe $Team a ete trouver" -ForegroundColor Green
}
else {
    Write-Host "L'equipe $Team n'a pas ete trouver" -ForegroundColor Red -ErrorAction Stop | Write-Host "Can't continue the process" | Disconnect-MicrosoftTeams
}

#Afficher les channels de l'equipe
$Channels = Get-TeamChannel -GroupId $TeamId.id
Write-Host "Les channels de l'equipe $Team sont :"
foreach ($channel in $Channels) {
    Write-Host "- $($channel.DisplayName)"
}

#Roles
$Roles = Read-Host "Member/Owner"

#entrer le nom du channel
$Channel = Read-Host -Prompt "Entrer le nom du channel"
if ($?) {
    Write-Host "Le channel $Channel a ete trouver" -ForegroundColor Green
}
else {
    Write-Host "Le channel $Channel n'a pas ete trouver" -ForegroundColor Red -ErrorAction Stop | Write-Host "Can't continue the process" | Disconnect-MicrosoftTeams}

#Ajouter l'utilisateur au channel
Add-TeamChannelUser -GroupId $TeamId.id -DisplayName $Channel -User $UserId -Role $Roles
if ($?) {
    Write-Host "L'utilisateur $User a ete ajoute au channel avec succes" -ForegroundColor Green
}
else {
    Write-Host "L'utilisateur $User n'a pas pu etre ajouter au channel" -ForegroundColor Red -ErrorAction Stop | Write-Host "Can't continue the process" | Disconnect-MicrosoftTeams}

    #Creer une loop pour ajouter l'utilisateur a d'autres channels
    $Add = Read-Host -Prompt "Voulez-vous ajouter l'utilisateur a d'autres channels ? (O/N)"
    while ($Add -eq "O") {
        $Channel1 = Read-Host -Prompt "Entrer le nom du channel"
        Add-TeamChannelUser -GroupId $TeamId.id -DisplayName $Channel1 -User $UserId -Role $Roles
        if ($?) {
            Write-Host "L'utilisateur $User a ete ajouter au channel avec succes" -ForegroundColor Green
        }
        else {
            Write-Host "L'utilisateur $User n'a pas pu être ajoute au channel" -ForegroundColor Red -ErrorAction Stop | Write-Host "Stop the process" | Disconnect-MicrosoftTeams}

    
        $Add = Read-Host -Prompt "Voulez-vous ajouter l'utilisateur a d'autres channels ? (O/N)"
    }
    if ($Add -eq "N") {
        Write-Host "L'utilisateur $User n'a pas ete ajouter a d'autres channels" -ForegroundColor Green | Disconnect-MicrosoftTeams}

