Connect-ExchangeOnline
$DLName = Read-Host -Prompt "Enter the name of the DL"
$NameAlias = Read-Host -Prompt "Enter the first and last name of the alias ex : Test.test"
$DLDisplayName = Read-Host -Prompt "Enter the display nameof the DL"
$EmailDL = Read-Host -Prompt "Enter the group mail"
New-DistributionGroup -Name "$DLName" -Alias "$NameAlias" -PrimarySmtpAddress "$EmailDL" -DisplayName "$DLDisplayName"
if ($?) 
{Write-Host DL Succesfully Created -ForegroundColor Green}
else 
{Write-Host -ErrorAction Stop -ForegroundColor Red | Disconnect-ExchangeOnline}

# Ask for moderation
$Ask1 = Read-Host -Prompt "Do you want to add moderation to this DL ? Y/N"
if ($Ask1 -eq "Y"){
$AdminUser = Read-Host -Prompt "Enter the Group User Manager"
Set-DistributionGroup -Identity "$NameAlias" -ManagedBy "$AdminUser" -ModerationEnabled:$True -ModeratedBy "$AdminUser"
if ($?) 
{Write-Host DL Succesfully Updated -ForegroundColor Green}
else 
{Write-Host -ErrorAction Stop -ForegroundColor Red | Disconnect-ExchangeOnline}}
if ($Ask1 -eq "N") {
    $Ask = Read-Host -Prompt "Do you want to add members to this DL ? Y/N"
while($Ask -eq "Y"){

$Members = Read-Host -Prompt "Enter the members name for this DL or CTRL + C to break"
Update-DistributionGroupMember -Identity "$NameAlias" -Members $Members -Confirm:$True
if ($?) 
{Write-Host Members Succesfully Add -ForegroundColor Green}
else 
{Write-Host -ErrorAction Stop -ForegroundColor Red}
Get-DistributionGroupMember -Identity "$NameAlias"}}
if ($Ask -eq "N"){
    Write-Host "No need more user, Disconnect" -ForegroundColor Green | Disconnect-ExchangeOnline}
Disconnect-ExchangeOnline
