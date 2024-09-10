# Connectez-vous à Microsoft Graph
Connect-MgGraph

# Demandez l'UPN de l'utilisateur
$UPN = Read-Host -Prompt "Entrez l'UPN de l'utilisateur pour obtenir les informations"

# Obtenez les détails de l'utilisateur en un seul appel
$UserDetails = Get-MgUser -Filter "UserPrincipalName eq '$UPN'"
$DisplayName = ($UserDetails | Select-Object DisplayName).DisplayName
$UserID = ($UserDetails | Select-Object Id).Id

if (-not $UserID) {
    Write-Host "Utilisateur non trouvé pour UPN : $UPN"
    Disconnect-MgGraph
    return
}

# Initialisez un tableau pour contenir les associations d'équipe, de tag et d'ID d'adhésion au tag
$TeamTagAssociations = @()

# Parcourez toutes les équipes auxquelles l'utilisateur s'est joint
$AllTeamUser = Get-mgUserJoinedTeam -UserId $UserID

foreach ($Team in $AllTeamUser) {        
    # Pour chaque équipe dont l'utilisateur est membre, trouvez les tags auxquels ils sont associés dans cette équipe
    $TeamTags = Get-MgTeamTag -TeamId $Team.Id

    foreach ($Tag in $TeamTags) {
        # Récupérez les membres du tag pour trouver l'ID d'adhésion pour l'utilisateur
        $TagMembers = Get-MgTeamTagMember -TeamId $Team.Id -TeamworkTagId $Tag.Id -Filter "DisplayName eq '$DisplayName'"
        $TagMemberId = ($TagMembers | Where-Object { $_.DisplayName -eq $DisplayName }).Id
        
        # Si l'utilisateur est membre du tag, ajoutez l'association
        if ($TagMemberId) {
            $TeamTagAssociations += [PSCustomObject]@{
                Team = $Team
                Tag = $Tag
                TagMemberId = $TagMemberId
            }

            Write-Host "Équipe : $($Team.DisplayName) -- Tag : $($Tag.DisplayName) | ID : $($Tag.Id)"
        }
    }
}

# Supprimez l'utilisateur des tags de chaque équipe
foreach ($Association in $TeamTagAssociations) {
    try {
        Remove-MgTeamTagMember -TeamId $Association.Team.Id -TeamworkTagId $Association.Tag.Id -TeamworkTagMemberId $Association.TagMemberId | Out-Null
        Write-Host "$UPN supprimé de $($Association.Tag.DisplayName) avec ID $($Association.Tag.Id) dans l'équipe $($Association.Team.DisplayName)" -ForegroundColor Green
    }
    catch {
        Write-Host "Erreur : $_"
    }
}

Disconnect-MgGraph
