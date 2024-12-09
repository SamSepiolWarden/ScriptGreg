
Connect-ExchangeOnline
#Repetion du code
$Repetition = Read-Host -Prompt "entrer le nombre de fois que le code doit etre répéter"
#initialiser le compteur
$compteur = 0
while ($compteur -lt $Repetition){
$User = Read-Host -Prompt "Enter the mail adress to who's share is calendar ex: jane.doe@sociabble.com:\Calendar ou :\Calendrier"
$UserAdd = Read-Host -Prompt "Enter the mail adress to add permission ex: axel.gaudiot@sociabble.com"
Set-MailboxFolderPermission -identity $User -User Default -AccessRights LimitedDetails
if($?)
{Write-Host Calendar Rights Successfully Set -ForegroundColor Green}
else
{Write-Host -ErrorAction Stop -ForegroundColor Red}
Add-MailboxFolderPermission -identity $User -User $UserAdd -AccessRights Reviewer
if($?)
{Write-Host Calendar Member Add Successfully Set -ForegroundColor Green}
else
{Write-Host -ErrorAction Stop -ForegroundColor Red}
Get-MailboxFolderPermission -identity $User
Write-Host "Le code s'est éxécuté $($compteur + 1) fois"
$compteur++}
Disconnect-ExchangeOnline