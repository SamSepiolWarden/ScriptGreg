Connect-ExchangeOnline
Get-DistributionGroup -ResultSize unlimited | ft name,Managedby
Disconnect-ExchangeOnline