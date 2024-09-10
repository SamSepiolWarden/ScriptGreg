# Définition de la fonction GetUserIdByName
function GetUserIdByName($prompt) {
    $UserName = Read-Host -Prompt $prompt
    $Search = Get-MgUser -ConsistencyLevel eventual -Search DisplayName:$UserName
    Write-Host "Utilisateur selectionne :"
    foreach($member in $Search){
        Write-Host " $($member.Id)"
    }
    $UserId = $member.Id
    return $UserId
}

Connect-MgGraph -Scopes TeamworkTag.ReadWrite

# Requérir la répétition du code
$Repetition = Read-Host -Prompt "Entrer le nombre de fois que le code doit etre repete pour la creation d'un ou de plusieurs tags"

# Initialisation du compteur
$compteur = 0

while ($compteur -lt $Repetition) {

    $Teams = Read-Host -Prompt "Entrer l'ID de l'equipe de votre choix"
    $members = Get-MgTeamMember -TeamId $Teams
    Write-Host "Membres dans l'equipe selectionnee ($i) :"
    foreach ($member in $members) {
        Write-Host "- $($member.DisplayName)"
    }

    $User1 = GetUserIdByName "Entrer le nom du premier utilisateur"
    $User2 = GetUserIdByName "Entrer le nom du deuxieme utilisateur"
    
    $DisplayName = Read-Host -Prompt "Entrer le nom du tag a creer"
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
    try{
        New-MgTeamTag -TeamId $Teams -BodyParameter $Params
        Write-Host "Le tag a été creer avec succes" -ForegroundColor Green
    }
    catch{
        Write-Host "Le tag n'a pas pu etre creer" -ForegroundColor Red -ErrorAction Stop
    }

    # Search for the new tag id
    $Search = Get-MgTeamTag -TeamId $Teams
    foreach($tag in $Search){
        if($tag.DisplayName -eq $DisplayName){
            $IDCreation = $tag.Id
        }
    } 

    #While Loop to continue the add of user
    $Add = Read-Host -Prompt "Voulez-vous ajouter un autre utilisateur ? (O/N)"
    while ($Add -eq "O") {
        $User3 = GetUserIdByName "Entrer le nom d'un autre utilisateur"
        $Params1 = @{
                    userId = $User3
             
        }

        try{
            New-MgTeamTagMember -TeamId $Teams -TeamworkTagId $IDCreation -BodyParameter $Params1 -ErrorAction Continue
            Write-Host "L'utilisateur $User3 a ete ajoute avec succes" -ForegroundColor Green
        }
        catch{
            Write-Host "L'utilisateur $User3 n'a pas pu etre ajouter" -ForegroundColor Red -ErrorAction Stop
        }
        $Add = Read-Host -Prompt "Voulez-vous ajouter un autre utilisateur ? (O/N)"
    }
    Write-Host "Le code s'est execute $($compteur + 1) fois"
    $compteur++
}

Disconnect-MgGraph
