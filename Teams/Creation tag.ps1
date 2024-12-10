function Get-UserIdByUPN {
    param (
        [Parameter(Mandatory = $true)]
        [string]$UPN
    )
    
    try {
        $UserDetails = Get-MgUser -Filter "UserPrincipalName eq '$UPN'"
        return ($UserDetails | Select-Object -ExpandProperty Id)
    }
    catch {
        Write-Warning "Erreur lors de la récupération de l'utilisateur avec UPN: $UPN"
        Write-Warning $_.Exception.Message
        return $null
    }
}

function Add-UsersToTagInTeams {
    param (
        [Parameter(Mandatory = $true)]
        [string]$PrincipalUserUPN,
        [Parameter(Mandatory = $true)]
        [string]$TagName,
        [Parameter(Mandatory = $true)]
        [string]$SecondaryUserID,
        [Parameter(Mandatory = $false)]
        [array]$AdditionalUserIDs = @()
    )

    $PrincipalUserID = Get-UserIdByUPN -UPN $PrincipalUserUPN
    if (-not $PrincipalUserID) {
        Write-Warning "Utilisateur principal non trouvé pour l'UPN : $PrincipalUserUPN"
        return
    }

    try {
        # Get all teams the principal user has joined
        $AllTeams = Get-MgUserJoinedTeam -UserId $PrincipalUserID
        
        foreach ($Team in $AllTeams) {
            Write-Host "Processing Équipe: $($Team.DisplayName) | ID: $($Team.Id)" -ForegroundColor Cyan
            
            try {
                # Fetch and display team members
                $members = Get-MgTeamMember -TeamId $Team.Id
                Write-Host "Membres dans l'équipe:" -ForegroundColor Green
                $members | ForEach-Object { Write-Host "- $($_.DisplayName)" }

                # Create the tag
                $Tag = New-MgTeamTag -TeamId $Team.Id -DisplayName $TagName
                $TagId = $Tag.Id

                # Add users to the tag
                $UsersToAdd = @($PrincipalUserID, $SecondaryUserID) + $AdditionalUserIDs
                foreach ($UserID in $UsersToAdd) {
                    try {
                        Add-MgTeamTagMember -TeamId $Team.Id -TagId $TagId -UserId $UserID
                        Write-Host "Ajouté utilisateur $UserID au tag" -ForegroundColor Green
                    }
                    catch {
                        Write-Warning "Erreur lors de l'ajout de l'utilisateur $UserID au tag dans l'équipe $($Team.DisplayName)"
                        Write-Warning $_.Exception.Message
                    }
                }

                Write-Host "Tag '$TagName' créé et utilisateurs ajoutés dans l'équipe $($Team.DisplayName)" -ForegroundColor Green
            }
            catch {
                Write-Warning "Erreur lors du traitement de l'équipe $($Team.DisplayName)"
                Write-Warning $_.Exception.Message
                continue
            }
        }
    }
    catch {
        Write-Warning "Erreur lors de la récupération des équipes"
        Write-Warning $_.Exception.Message
    }
}

# Main script
try {
    Connect-MgGraph -Scopes 'TeamMember.Read.All', 'TeamMember.ReadWrite.All', 'Group.Read.All'

    # Get principal user
    do {
        $PrincipalUserUPN = Read-Host -Prompt "Entrer l'UPN de l'utilisateur principal"
        $PrincipalUserID = Get-UserIdByUPN -UPN $PrincipalUserUPN
    } while (-not $PrincipalUserID)

    # Get tag name with confirmation
    do {
        $TagName = Read-Host -Prompt "Entrer le nom du tag à créer"
        $ConfirmTagName = Read-Host -Prompt "Confirmez le nom du tag $TagName (O/N)"
    } while ($ConfirmTagName -ne 'O')

    # Get secondary user
    do {
        $SecondaryUPN = Read-Host -Prompt "Entrer l'UPN du deuxième utilisateur"
        $SecondaryUserID = Get-UserIdByUPN -UPN $SecondaryUPN
    } while (-not $SecondaryUserID)

    # Get additional users
    $AdditionalUserIDs = @()
    do {
        $AdditionalUPN = Read-Host -Prompt "Entrer l'UPN d'un utilisateur supplémentaire (ou appuyez sur Entrée pour terminer)"
        if ($AdditionalUPN) {
            $AdditionalUserID = Get-UserIdByUPN -UPN $AdditionalUPN
            if ($AdditionalUserID) {
                $AdditionalUserIDs += $AdditionalUserID
            }
        }
    } while ($AdditionalUPN)

    # Add users to tag in all teams
    Add-UsersToTagInTeams -PrincipalUserUPN $PrincipalUserUPN -TagName $TagName -SecondaryUserID $SecondaryUserID -AdditionalUserIDs $AdditionalUserIDs
}
catch {
    Write-Warning "Une erreur est survenue dans le script principal"
    Write-Warning $_.Exception.Message
}
finally {
    Disconnect-MgGraph
}