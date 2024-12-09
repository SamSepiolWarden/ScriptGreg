Connect-ExchangeOnline
$GroupName = Read-Host -Prompt "Enter the group Name"
Get-UnifiedGroup -Identity $GroupName | Format-Table ExchangeGuid
$GroupId = Read-Host -Prompt "Enter the group ID"
Get-Mailbox -ResultSize Unlimited | where {$_.PrimarySmtpAddress -like '*@sociabble.com'} | Format-Table Guid
While($ObjectId = $true)
{$ObjectId = Read-Host -Prompt "Enter the Object Id or CTRL + C to break"
Add-UnifiedGroupLinks -Identity "$GroupId" -Links $ObjectId -LinkType Members} 
if($?)
{Write-Host Members succesfully Add -ForegroundColor Green}
else
{Write-Host -ErrorAction Stop -ForegroundColor Red}
Disconnect-ExchangeOnline