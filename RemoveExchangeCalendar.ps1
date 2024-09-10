Connect-ExchangeOnline
$User = Read-Host -Prompt "Enter the email address of the new arrival ex : Jane.Doe@sociabble.com:\Calendar ou :\Calendrier"
$UserAdd = Read-Host -Prompt "Enter the HR mail adress ex: Jane.Doe@sociabble.com"
Remove-MailboxFolderPermission -identity $User -User $UserAdd
if($?)
{Write-Host $UserAdd Succesfully remove -ForegroundColor Green}
else
{Write-Host -ErrorAction Stop -ForegroundColor Red}
Get-MailboxFolderPermission -identity $User
Disconnect-ExchangeOnline