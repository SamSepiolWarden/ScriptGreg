function Remove-UserPermission {
    param (
        [Parameter(Mandatory = $true)]
        [string]$UserMailbox,

        [Parameter(Mandatory = $true)]
        [string]$HRMail
    )

    # Suppression des autorisations
    Remove-MailboxFolderPermission -Identity $UserMailbox -User $HRMail

    if ($?) {
        Write-Host "$HRMail a été supprimé du calendrier avec succès." -ForegroundColor Green
    } else {
        Write-Host "Erreur lors de la suppression de $HRMail." -ForegroundColor Red
    }

    Get-MailboxFolderPermission -Identity $UserMailbox
}

Connect-ExchangeOnline

$continue = $true
while ($continue) {
    $UserMailbox = Read-Host -Prompt "Entrez l'adresse e-mail du nouvel arrivant ex : Jane.Doe@sociabble.com:\Calendar ou :\Calendrier"
    $HRMail = Read-Host -Prompt "Entrez l'adresse e-mail HR ex: Jane.Doe@sociabble.com"
    $HrDisplayName = Get-Mailbox -Identity $HRMail | Select-Object -ExpandProperty DisplayName
$AuditCalendar = Get-MailboxFolderPermission -Identity $UserMailbox | Where-Object { $_.User -like "*$HrDisplayName*" }

if($AuditCalendar.User -like "*$HrDisplayName*") {
    Write-Host "$HRMail a accès au calendrier de $UserMailbox avec le rôle $($AuditCalendar.AccessRights)." -ForegroundColor Yellow
     
        $response1 = Read-Host -Prompt "Voulez-vous supprimer l'accès? (Yes/No)"
        if ($response1 -eq "Yes") {
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
