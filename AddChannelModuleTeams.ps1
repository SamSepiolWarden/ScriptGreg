Connect-MicrosoftTeams

#entrer l'utilisateur a ajouter aux channels
$UPN = Read-Host -Prompt "Entrer l'email de l'utilisateur a ajouter aux channels"

#Entrer le nom du teams
$team = Read-Host -Prompt "Entrer le nom de l'equipe"

#Chercher le teams
$TeamObj = Get-team -DisplayName $team | Where-Object {$_.DisplayName -eq "$team"}
if ($?) {
    Write-Host "L'equipe $team a ete trouver" -ForegroundColor Green
}
else {
    Write-Host "L'equipe $team n'a pas ete trouver" -ForegroundColor Red -ErrorAction Stop | Write-Host "Can't continue the process" | Disconnect-MicrosoftTeams
}


#chercher l'identifiant du teams
$TeamId = $TeamObj.GroupId

#Chercher l'utilisateur dans le teams
Get-TeamUser -GroupId $TeamObj.GroupId | Where-Object {$_.User -eq "$UPN"}
if ($?) {
    Write-Host "L'utilisateur $UPN a ete trouver" -ForegroundColor Green
}
else {
    Write-Host "L'utilisateur $UPN n'a pas ete trouver" -ForegroundColor Red -ErrorAction Stop | Read-Host "Do you want to add the user to the team ? (O/N)" | if ($_ -eq "O") {
    Add-TeamUser -GroupId $TeamId -User $UPN    }
    if ($_ -eq "N") {
        Write-Host "Can't continue the process" | Disconnect-MicrosoftTeams    } 
}

#Chercher le channel
$Channels = Get-teamchannel -GroupId $TeamId


#Lister les channels du teams
Write-Host "Les channels de l'equipe $team sont :"
foreach ($channel in $Channels) {
    Write-Host "- $($channel.DisplayName)"
}

$Channel1 = Read-Host -Prompt "Entrer le nom du channel"


#Ajouter l'utilisateur au channel
Add-TeamChannelUser -GroupId $TeamId -DisplayName $Channel1 -User $UPN
if ($?) {
    Write-Host "L'utilisateur $UPN a ete ajoute au channel avec succes" -ForegroundColor Green
}
else {
    Write-Host "L'utilisateur $UPN n'a pas pu etre ajouter au channel" -ForegroundColor Red -ErrorAction Stop | Write-Host "Can't continue the process" | Disconnect-MicrosoftTeams}
#Creer une loop pour ajouter l'utilisateur a d'autres channels
$Add = Read-Host -Prompt "Voulez-vous ajouter l'utilisateur a d'autres channels ? (O/N)"
while ($Add -eq "O") {
    $Channel2 = Read-Host -Prompt "Entrer le nom du channel"
    Add-TeamChannelUser -GroupId $TeamId -DisplayName $Channel2 -user $UPN
    $Add = Read-Host -Prompt "Voulez-vous ajouter l'utilisateur a d'autres channels ? (O/N)"
}
if ($Add -eq "N") {
    Write-Host "L'utilisateur $UPN n'a pas besoin d'autres channel" -ForegroundColor Green }
    $Add1 = Read-Host -Prompt "Voulez-vous ajouter un autre utilisateur ? (O/N)" | if ($Add1 -eq "O") {
    $UPN1 = Read-Host -Prompt "Entrer l'email de l'utilisateur a ajouter aux channels"
    $Channel3 = Read-Host -Prompt "Entrer le nom du channel"
    Add-TeamChannelUser -GroupId $TeamId -DisplayName $Channel3 -user $UPN1}

#Deconnecter de Teams
Disconnect-MicrosoftTeams
