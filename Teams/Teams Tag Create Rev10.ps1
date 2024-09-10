Connect-MgGraph -Scopes 
#Repetion du code
$Repetition = Read-Host -Prompt "entrer le nombre de fois que le code doit etre répéter pour la creation de plusieurs tag"
#initialisation du compteur
$compteur = 0
while ($compteur -lt $Repetition){
$Groups = Get-MgGroup -All:$true
Write-Host "Select a group:"
foreach ($group in $Groups){
    Write-host "$($group.DisplayName) (Id: $($group.Id))"
    }
$Teams = Read-Host -Prompt "Enter the team id of your choice"
$members = Get-MgTeamMember -TeamId $Teams
Write-Host "Members in the selected team ($i):"
    foreach ($member in $members) {
        Write-Host "- $($member.DisplayName)"
    }
$SearchUser = Read-Host -Prompt "Enter the first user"
$SearchUser1 = Read-Host -Prompt "Enter the second user"
$Search1 = Get-MgUser -ConsistencyLevel eventual -Search DisplayName:$SearchUser
Write-Host "Member selected:"
    foreach($member in $Search1){
        Write-Host " $($member.Id)"
        }

$Search2 = Get-MgUser -ConsistencyLevel eventual -Search DisplayName:$SearchUser1
Write-Host "Member selected:"
    foreach($member in $Search2){
        Write-Host " $($member.Id)"
        }
$User1 = Read-Host -Prompt "Enter the object id of the first user"
$User2 = Read-Host -Prompt "Enter the object id of the second user"
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
New-MgTeamTag -TeamId $Teams -BodyParameter $Params
Write-Host "Le code s'est éxécuté $($compteur + 1) fois"
$compteur++}
Disconnect-MgGraph