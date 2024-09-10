Connect-ExchangeOnline
Get-User -ResultSize Unlimited | Where {$_.AuthenticationPolicy -eq "Block Basic Auth"} | Select Name,AuthenticationPolicy
Disconnect-ExchangeOnline