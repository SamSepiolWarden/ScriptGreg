Connect-ExchangeOnline
$DLName = Read-Host -Prompt "Enter the name of the DL"
$Alias = Read-Host "Enter the name of the Alias"
$DLDisplayName = Read-Host -Prompt "Enter the display name"
$EmailDL = Read-Host -Prompt "Enter the group mail"
New-DistributionGroup -Name "$DLName" -Alias "$Alias" -PrimarySmtpAddress "$EmailDL" -DisplayName "$DLDisplayName"
if ($?) 
{Write-Host DL Succesfully Created -ForegroundColor Green}
else 
{Write-Host "-ErrorAction" break -ForegroundColor Red}
$AdminUser = Read-Host -Prompt "Enter the Group User Manager"
Set-DistributionGroup -Identity "$Alias" -ManagedBy "$AdminUser" -ModerationEnabled:$True -ModeratedBy "$AdminUser"
if ($?) 
{Write-Host DL Succesfully Updated -ForegroundColor Green}
else 
{Write-Host -ErrorAction break -ForegroundColor Red}
while($Members = $True)
{$Members = Read-Host -Prompt "Enter the members name for this DL or CTRL + C to break"
Update-DistributionGroupMember -Identity "$Alias" -Members $Members -Confirm:$True}
if ($?) 
{Write-Host Members Succesfully Add -ForegroundColor Green}
else 
{Write-Host -ErrorAction break -ForegroundColor Red}
Get-DistributionGroup -Identity "$Alias"
Disconnect-ExchangeOnline
