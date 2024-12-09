Connect-ExchangeOnline
$DistributionGroup = import-csv "C:\Test\groupownermigs.csv"
$NewOwner = Read-host -prompt "Enter the new owner mail address"

foreach ($Name in $DistributionGroup){
Set-DistributionGroup -Identity $Name.Name -ManagedBy @{Add=$NewOwner}
if($?)
{Write-host Succesfully Add to $Name.Name -ForegroundColor Green}
else
{Write-Host $Name.Name -ErrorAction Stop -ForegroundColor Red}
}