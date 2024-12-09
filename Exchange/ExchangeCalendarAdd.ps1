Connect-ExchangeOnline
$UserCalendar = Read-Host -Prompt "Enter the mail adress to who's share is calendar ex: jane.doe@sociabble.com:\Calendar ou :\Calendrier"
$UserAdd = Read-Host -Prompt "Enter the mail adress to add permission ex: axel.gaudiot@sociabble.com"

$SearchUserAdd = Get-EXOMailboxFolderPermission -identity $UserAdd
if($null -ne $SearchUserAdd){
Write-Host "User $SearchUserAdd found" -ForegroundColor Green}
else{ Write-Host "User $SearchUserAdd not found" -ForegroundColor Red | Disconnect-ExchangeOnline}

$SearchMailbox = Get-EXOMailboxFolderPermission -identity $UserCalendar
if($null -ne $SearchMailbox){
Write-Host "Mailbox found" -ForegroundColor Green
$ASkForChanging = Read-Host -Prompt "Do you want to change the calendar rights ? (Y/N)"}
if($ASkForChanging -eq "Y"){
Set-MailboxFolderPermission -identity $UserCalendar -User Default -AccessRights LimitedDetails
if($?)
{Write-Host Calendar Rights Successfully Set -ForegroundColor Green}
else
{Write-Host -ErrorAction Stop -ForegroundColor Red}
Add-MailboxFolderPermission -identity $UserCalendar -User $UserAdd -AccessRights Reviewer
if($?)
{Write-Host Calendar Member Add Successfully Set -ForegroundColor Green}
else {
Write-Host -ErrorAction Stop -ForegroundColor Red}
Get-EXOMailboxFolderPermission -identity $UserCalendar
}
if($ASkForChanging -eq "N"){
    Write-Host "No need to change permission" 
    Disconnect-ExchangeOnline}
Disconnect-ExchangeOnline



