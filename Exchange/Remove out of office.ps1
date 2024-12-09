Connect-ExchangeOnline
# prompt pour l'utilisateur a configurer le message d'absence

$UserMailbox = Read-Host -Prompt 'Enter the user mailbox'

# Ask for disable the auto reply
Set-MailboxAutoReplyConfiguration -Identity $UserMailbox -AutoReplyState Disabled 
if ($? -eq $true) {
    Write-Host "Auto reply has been disable for $UserMailbox"
} else {
    Write-Host "Auto reply has not been disable for $UserMailbox"
}

Disconnect-ExchangeOnline




