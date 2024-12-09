function Set-UserPermission {
    param (
        [Parameter(Mandatory = $true)]
        [string]$UserMailbox,

        [Parameter(Mandatory = $true)]
        [string]$HRMail
    )

    # Verify if the mailbox and HR email are valid
    if (-not (Test-Mailbox $UserMailbox) -or -not (Test-Mailbox $HRMail)) {
        Write-Host "Invalid email address format." -ForegroundColor Red
        return
    }

    try {
        Set-MailboxFolderPermission -Identity $UserMailbox -User $HRMail -Accessrights $Rights -ErrorAction Stop
        Write-Host "$HRMail a été Ajouté au calendrier avec succès." -ForegroundColor Green
    }
    catch {
        Write-Host "Erreur lors de la suppression de $HRMail : $_" -ForegroundColor Red
    }

    Get-MailboxFolderPermission -Identity $UserMailbox
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

    $AuditCalendar = Get-MailboxFolderPermission -Identity $UserMailbox | Where-Object { $_.User.DisplayName -eq $DisplayName }

    if($null -eq $AuditCalendar) {
        Write-Host "$DisplayName n'a pas accès au calendrier de $UserMailbox avec le rôle $($AuditCalendar.AccessRights)." -ForegroundColor Yellow

        $response = Read-Host -Prompt "Voulez-vous ajouter l'accès? (Yes/No)"
        if ($response -eq "Yes") {
            Set-UserPermission -UserMailbox $UserMailbox -HRMail $HRMail -Accessrights $Rights
        }
    } else {
        Write-Host "$HRMail a accès au calendrier de $UserMailbox, avec ses droits $AuditCalendar.AccessRights" -ForegroundColor Yellow
        $ChangeRights = Read-Host -Prompt "Voulez-vous changer les droits? (Yes/No)"
        if ($ChangeRights -eq "Yes") {
            Set-UserPermission -UserMailbox $UserMailbox -HRMail $HRMail -Accessrights $Rights
        }
        else {
            Write-Host "Aucun changement n'a été apporté." -ForegroundColor Yellow
        }
    }

    $response = Read-Host -Prompt "Voulez-vous ajouter un autre utilisateur? (Yes/No)"
    if ($response -ne "Yes") {
        $continue = $false
    }
}

Disconnect-ExchangeOnline
