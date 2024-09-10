# Définition de la fonction GetUserIdByName
function GetUserIdByName($prompt) {
    $UserName = Read-Host -Prompt $prompt
    $Search = Get-MgUser -ConsistencyLevel eventual -Search DisplayName:$UserName
    Write-Host "Utilisateur sélectionné :"
    foreach($member in $Search){
        Write-Host " $($member.Id)"
    }
    $UserId = Read-Host -Prompt "Entrer l'ID de l'objet de l'utilisateur"
    return $UserId
}

Connect-MgGraph


# Requérir la répétition du code
$Repetition = Read-Host -Prompt "Entrer le nombre de fois que le code doit être répété pour la création de plusieurs tags"

# Initialisation du compteur
$compteur = 0

while ($compteur -lt $Repetition) {

    $Teams = Read-Host -Prompt "Entrer l'ID de l'équipe de votre choix"
    $members = Get-MgTeamMember -TeamId $Teams
    Write-Host "Membres dans l'équipe sélectionnée ($i) :"
    foreach ($member in $members) {
        Write-Host "- $($member.DisplayName)"
    }

    $User1 = GetUserIdByName "Entrer le nom du premier utilisateur"
    $User2 = GetUserIdByName "Entrer le nom du deuxième utilisateur"
    
    $DisplayName = Read-Host -Prompt "Entrer le nom du tag à créer"
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
    Write-Host "Le code s'est exécuté $($compteur + 1) fois"
    $compteur++
}

Disconnect-MgGraph

