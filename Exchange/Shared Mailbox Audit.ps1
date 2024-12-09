Connect-ExchangeOnline
$out = Get-EXOMailbox -RecipientTypeDetails "SharedMailbox" -ResultSize:Unlimited | Get-EXOMailboxPermission | Select identity,user,AccessRights 
$out | Out-File -FilePath C:\Test\Sharemailbox.csv -Append
Disconnect-ExchangeOnline