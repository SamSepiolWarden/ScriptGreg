Connect-ExchangeOnline
Get-User -ResultSize Unlimited | Select-Object Name,AuthenticationPolicy
Disconnect-ExchangeOnline