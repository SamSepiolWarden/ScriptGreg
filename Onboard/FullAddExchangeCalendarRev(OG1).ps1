function Add-UserPermission {
    param (
        [Parameter(Mandatory = $true)]
        [string]$UserMailbox,

        [Parameter(Mandatory = $true)]
        [string]$HRMail,

        [Parameter(Mandatory = $true)]
        [string]$Rights
    )

    try {
        Add-MailboxFolderPermission -Identity $UserMailbox -User $HRMail -AccessRights $Rights -ErrorAction Stop
        Write-Host "$HRMail a été ajouté au calendrier avec succès." -ForegroundColor Green
    }
    catch {
        Write-Host "Erreur lors de l'ajout de $HRMail : $_" -ForegroundColor Red
    }

    Get-MailboxFolderPermission -Identity $UserMailbox | Format-Table -Property User, AccessRights
}

function Set-UserPermission {
    param (
        [Parameter(Mandatory = $true)]
        [string]$UserMailbox,

        [Parameter(Mandatory = $true)]
        [string]$HRMail,

        [Parameter(Mandatory = $true)]
        [string]$Rights
    )

    try {
        Set-MailboxFolderPermission -Identity $UserMailbox -User $HRMail -AccessRights $Rights -ErrorAction Stop
        Write-Host "$HRMail a été mis à jour au calendrier avec succès." -ForegroundColor Green
    }
    catch {
        Write-Host "Erreur lors de la mise à jour de $HRMail : $_" -ForegroundColor Red
    }

    Get-MailboxFolderPermission -Identity $UserMailbox | Format-Table -Property User, AccessRights
}

function Test-Mailbox {
    param (
        [string]$Mailbox
    )

    return $Mailbox -match '^[^@]+@[^@]+\.[^@]+$'
}

Connect-ExchangeOnline

$continue = $true
while ($continue) {
    $UserMailbox = Read-Host -Prompt "Entrez l'adresse e-mail du nouvel arrivant ex : Jane.Doe@sociabble.com:\Calendar ou :\Calendrier"
    $HRMail = Read-Host -Prompt "Entrez l'adresse e-mail HR ex: Jane.Doe@sociabble.com"
    $Rights = Read-Host -Prompt "Entrez le rôle de l'utilisateur (Reviewer/Editor/Owner/Author/NonEditingAuthor/PublishingEditor)"

    if (-not (Test-Mailbox $UserMailbox) -or -not (Test-Mailbox $HRMail)) {
        Write-Host "Invalid email address format." -ForegroundColor Red
        continue
    }
    $DisplayName = Get-Mailbox -Identity $HRMail | Select-Object -ExpandProperty DisplayName
    $AskForSetLimitedDetail = Read-Host "Voulez-vous ajouter l'accès en LimitedDetails par Default sur la boite mail de $UserMailbox ? (Yes/No)"
    if ($AskForSetLimitedDetail -eq "Yes") {
        Set-MailboxFolderPermission -Identity $UserMailbox -User $HRMail -AccessRights "LimitedDetails"
    }
    else {
        Write-Host "Aucun changement n'a été apporté." -ForegroundColor Yellow
    }
    # Check if HRMail already has permissions
    $AuditCalendar = Get-MailboxFolderPermission -Identity $UserMailbox -User $DisplayName -ErrorAction SilentlyContinue
    
    if ($null -eq $AuditCalendar) {
        Write-Host "$DisplayName n'a pas accès au calendrier de $UserMailbox." -ForegroundColor Yellow

        $response = Read-Host -Prompt "Voulez-vous ajouter l'accès? (Yes/No)"
        if ($response -eq "Yes") {
            Set-MailboxFolderPermission -Identity $UserMailbox -User "Default" -AccessRights "LimitedDetails"
            Add-UserPermission -UserMailbox $UserMailbox -HRMail $HRMail -Rights $Rights
        }
    } else {
        $rights = $AuditCalendar.AccessRights -join ', '
        Write-Host "$HRMail a accès au calendrier de $UserMailbox avec les droits suivants: $rights" -ForegroundColor Yellow
        $ChangeRights = Read-Host -Prompt "Voulez-vous changer les droits? (Yes/No)"
        if ($ChangeRights -eq "Yes") {
            Set-MailboxFolderPermission -Identity $UserMailbox -User "Default" -AccessRights "LimitedDetails"
            Set-UserPermission -UserMailbox $UserMailbox -HRMail $HRMail -Rights $Rights
        } else {
            Write-Host "Aucun changement n'a été apporté." -ForegroundColor Yellow
        }
    }

    $response = Read-Host -Prompt "Voulez-vous ajouter un autre utilisateur? (Yes/No)"
    if ($response -ne "Yes") {
        $continue = $false
    }
}

Disconnect-ExchangeOnline -Confirm:$false
