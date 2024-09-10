Connect-ExchangeOnline
$Csv = Read-Host -Prompt "Enter the name of your files"
Get-DistributionGroup |ft name, managedby -Wrap >C:\Test\$Csv.csv
Disconnect-ExchangeOnline