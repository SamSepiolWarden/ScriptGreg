Connect-ExchangeOnline
#Repetion du code
$Repetition = Read-Host -Prompt "entrer le nombre de fois que le code doit etre répéter"
#initialiser le compteur
$compteur = 0
while ($compteur -lt $Repetition){
$User = Read-Host -Prompt "Enter the email address of the new arrival ex : Jane.Doe@sociabble.com:\Calendar ou :\Calendrier"
$UserAdd = Read-Host -Prompt "Enter the HR mail adress ex: Jane.Doe@sociabble.com"
Remove-MailboxFolderPermission -identity $User -User $UserAdd
if($?)
{Write-Host $UserAdd Succesfully remove -ForegroundColor Green}
else
{Write-Host -ErrorAction Stop -ForegroundColor Red}
Get-MailboxFolderPermission -identity $User
Write-Host "Le code s'est éxécuté $($compteur + 1) fois"
$compteur++}
Disconnect-ExchangeOnline