Connect-ExchangeOnline
$User = Read-Host -Prompt "Enter the mail adress to who's share is calendar ex: jane.doe@sociabble.com:\Calendar ou :\Calendrier"
$UserAdd = Read-Host -Prompt "Enter the mail adress to add permission ex: axel.gaudiot@sociabble.com"
Set-MailboxFolderPermission -identity $User -User Default -AccessRights LimitedDetails
if($?)
{Write-Host Calendar Rights Successfully Set -ForegroundColor Green}
else
{Write-Host -ErrorAction Stop -ForegroundColor Red}
Add-MailboxFolderPermission -identity $User -User $UserAdd -AccessRights Editor
if($?)
{Write-Host Calendar Member Add Successfully Set -ForegroundColor Green}
else
{Write-Host -ErrorAction Stop -ForegroundColor Red}
Get-MailboxFolderPermission -identity $User
Disconnect-ExchangeOnline