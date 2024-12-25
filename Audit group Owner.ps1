Connect-ExchangeOnline
Get-DistributionGroup -ResultSize unlimited | format-table name,Managedby
Disconnect-ExchangeOnline