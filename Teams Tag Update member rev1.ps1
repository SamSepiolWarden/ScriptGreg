Connect-MgGraph -Scopes TeamworkTag.ReadWrite
#Repetion du code
$Repetition = Read-Host -Prompt "entrer le nombre de fois que le code doit etre répéter"
#initialisation du compteur
$compteur = 0
while ($compteur -lt $Repetition){
$User = Read-Host -Prompt "Enter the object id of the user"
$TeamID = Read-Host -Prompt "Enter the teams Id"
# Afficher les tags de l'équipe
    Write-Host "Tags de l'équipe :"
    Get-MgTeamTag -TeamId $TeamID -All | Format-Table
$Teamworktag = Read-Host -Prompt "Enter the team tag id"
New-MgTeamTagMember -TeamId $TeamID -TeamworkTagId $Teamworktag -UserId $User
Write-Host "Le code s'est éxécuté $($compteur + 1) fois"
$compteur++}
Disconnect-MgGraph
