Connect-ExchangeOnline
$SharedName = Read-Host -Prompt "Enter the name of the mailbox"
$SharedAlias = Read-Host -Prompt "Enter the Alias"
$SharedEmail = Read-Host -Prompt "Enter the mail of the shared mailbox"
New-Mailbox -Shared:$true -Name "$SharedName" -DisplayName "$SharedName" -Alias "$SharedAlias" -PrimarySmtpAddress "$SharedEmail" -Archive:$true
if ($?) {Write-Host Shared Mailbox Succesfully Created -ForegroundColor Green}
else {
    Write-Host -ErrorAction -ForegroundColor Red
} 
$Members = Read-Host -Prompt "Enter the mail of the member to add"
Add-MailboxPermission -User "$Members" -Identity "$SharedEmail" -AccessRights SendAs -Trustee "$Members" -Confirm:$true
if ($?) {Write-Host Shared Mailbox Permission Succesfully Add -ForegroundColor Green}
else {
    Write-Host -ErrorAction -ForegroundColor Red
} 
Disconnect-ExchangeOnline