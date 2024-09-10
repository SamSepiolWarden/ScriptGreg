Connect-MgGraph -Scopes TeamworkTag.ReadWrite
#Repetion du code
$Repetition = Read-Host -Prompt "entrer le nombre de fois que le code doit etre répéter"
$User1 = Read-Host -Prompt "Enter the object id of the first user"
$User2 = Read-Host -Prompt "Enter the object id of the second user"
#initialisation du compteur
$compteur = 0
while ($compteur -lt $Repetition){
$TeamID = Read-Host -Prompt "Enter the teams Id"
$DisplayName = Read-Host -Prompt "Enter the name of tag you need to create"
$Params = @{
	displayName = $DisplayName
	members = @(
		@{
			userId = $User1
		}
		@{
			userId = $User2
		}
	)
}
New-MgTeamTag -TeamId $TeamID -BodyParameter $Params
Write-Host "Le code s'est éxécuté $($compteur + 1) fois"
$compteur++}
Disconnect-MgGraph