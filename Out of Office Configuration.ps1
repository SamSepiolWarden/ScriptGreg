Connect-ExchangeOnline
# prompt pour l'utilisateur a configurer le message d'absence

$UserMailbox = Read-Host -Prompt 'Enter the user mailbox'

$InternalMessage = Read-Host -Prompt 'Enter the internal message'

$ExternalMessage = Read-Host -Prompt 'Enter the external message'

# demander la date de debut et de fin de l'absence
$AskingDate = Read-Host -Prompt 'Do you want to set a start and end date for the auto reply? (Y/N)'

if ($ASkingDate -eq "Y") {
    $StartDate = Read-Host -Prompt 'Enter the start date (dd/mm/yyyy)'
    $EndDate = Read-Host -Prompt 'Enter the end date (dd/mm/yyyy)'
Set-MailboxAutoReplyConfiguration -Identity $UserMailbox -AutoReplyState Scheduled -StartTime "$StartDate" -EndTime "$EndDate" -InternalMessage $InternalMessage -ExternalMessage $ExternalMessage
if ($? -eq $true) {
    Write-Host "Auto reply has been enabled for $UserMailbox"
} else {
    Write-Host "Auto reply has not been enabled for $UserMailbox" 
}
}
    if ($ASkingDate -eq "N") {

Set-MailboxAutoReplyConfiguration -Identity $UserMailbox -AutoReplyState Enabled -InternalMessage $InternalMessage -ExternalMessage $ExternalMessage
    
if ($? -eq $true) {
    Write-Host "Auto reply has been enabled for $UserMailbox"
} else {
    Write-Host "Auto reply has not been enabled for $UserMailbox"
}
    }
Disconnect-ExchangeOnline




