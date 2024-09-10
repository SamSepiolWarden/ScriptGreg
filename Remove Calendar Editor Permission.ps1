Connect-ExchangeOnline
$Useradd = Read-Host -Prompt "Enter the mail address of the user to remove permission"
$User = Read-Host -Prompt "Enter the mail of the user calendar example : Gregory.semedo@sociabble:\Calendar"
Get-EXOMailboxFolderPermission -Identity $User -User $Useradd
Remove-MailboxFolderPermission -Identity $User -User $Useradd
If($?){
Get-EXOMailboxFolderPermission -Identity $User -User $Useradd}
else
{Write-Host -ErrorAction Stop -ForegroundColor Red}
Disconnect-ExchangeOnline