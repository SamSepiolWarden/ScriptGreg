Connect-ExchangeOnline
$GroupName = Read-Host -Prompt "Enter the Name of the Group"
Set-UnifiedGroup "$GroupName" -UnifiedGroupWelcomeMessageEnabled:$false
if($?)
{Write-Host Successfully Disable -ForegroundColor Green}
else
{Write-Host -ErrorAction Stop -ForegroundColor Red}
Get-UnifiedGroup "$GroupName" | Select DisplayName, WelcomeMessageEnabled
Disconnect-ExchangeOnline