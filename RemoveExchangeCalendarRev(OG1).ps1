function Remove-UserPermission {
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
        Remove-MailboxFolderPermission -Identity $UserMailbox -User $HRMail -ErrorAction Stop
        Write-Host "$HRMail a été supprimé du calendrier avec succès." -ForegroundColor Green
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

    if (-not (Test-Mailbox $UserMailbox) -or -not (Test-Mailbox $HRMail)) {
        Write-Host "Invalid email address format." -ForegroundColor Red
        continue
    }
    $DisplayName = Get-Mailbox -Identity $HRMail | Select-Object -ExpandProperty DisplayName

    $AuditCalendar = Get-MailboxFolderPermission -Identity $UserMailbox | Where-Object { $_.User.DisplayName -eq $DisplayName }

    if($null -ne $AuditCalendar) {
        Write-Host "$DisplayName a déjà accès au calendrier de $UserMailbox avec le rôle $($AuditCalendar.AccessRights)." -ForegroundColor Yellow

        $response = Read-Host -Prompt "Voulez-vous supprimer l'accès? (Yes/No)"
        if ($response -eq "Yes") {
            Remove-UserPermission -UserMailbox $UserMailbox -HRMail $HRMail
        }
    } else {
        Write-Host "$HRMail n'a pas accès au calendrier de $UserMailbox." -ForegroundColor Yellow
    }

    $response = Read-Host -Prompt "Voulez-vous retirer un autre utilisateur? (Yes/No)"
    if ($response -ne "Yes") {
        $continue = $false
    }
}

Disconnect-ExchangeOnline
