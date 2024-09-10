# Se connecter à votre compte Azure AD
Connect-AzureAD

# Spécifier l'UPN de l'utilisateur à auditer
$upn = Read-Host -Prompt "Entrer l'utilisateur a auditer"

# Récupérer les informations de l'utilisateur
$user = Get-AzureADUser -ObjectId $upn

# Récupérer les rôles de l'utilisateur
$roles = Get-AzureADDirectoryRole | Where-Object { (Get-AzureADDirectoryRoleMember -ObjectId $_.ObjectId).ObjectId -contains $user.ObjectId }

# Récupérer les groupes de l'utilisateur
$groups = Get-AzureADUserMembership -ObjectId $user.ObjectId | Where-Object { $_.ObjectType -eq "Group" }

# Préparer un tableau pour stocker les résultats
$result = @()

# Ajouter les groupes et les rôles dans le tableau des résultats
foreach ($group in $groups) {
    $isSecurityGroup = $group.SecurityEnabled
    $result += [PSCustomObject]@{
        UPN             = $user.UserPrincipalName
        NomDuGroupe     = $group.DisplayName
        TypeDeGroupe    = "Groupe de sécurité" 
        EstUnGroupeDeSecurite = $isSecurityGroup
    }
}

foreach ($role in $roles) {
    $result += [PSCustomObject]@{
        UPN             = $user.UserPrincipalName
        NomDuGroupe     = $role.DisplayName
        TypeDeGroupe    = "Rôle"
        EstUnGroupeDeSecurite = "N/A"
    }
}

# Exporter les résultats dans un fichier CSV
$result | Export-Csv -Path C:\Test\Audit_AzureADAdmin.csv -Delimiter ";" -Encoding UTF8 -NoTypeInformation

# Déconnecter le compte Azure AD
Disconnect-AzureAD
