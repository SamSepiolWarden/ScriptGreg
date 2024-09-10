Connect-ExchangeOnline
$Useradd = Read-Host -Prompt "Enter the mail address of the user to add permission"
$User = Read-Host -Prompt "Enter the mail of the user calendar example : Gregory.semedo@sociabble:\Calendar"
Add-MailboxFolderPermission -Identity $User -User $Useradd -AccessRights Editor
Set-MailboxFolderPermission -Identity $User -User $Useradd -AccessRights Editor -SharingPermissionFlags Delegate
Get-EXOMailboxFolderPermission -Identity $User -User $Useradd
Disconnect-ExchangeOnline