Connect-MicrosoftTeams
Get-CsTeamsClientConfiguration -Identity Global
$Choice = Read-Host -Prompt "Enter the parmater that you want $True or $False"
Set-CsTeamsClientConfiguration -AllowGuestUser "$Choice" -Identity Global
if($?)
{Write-Host Global Microsoft Teams Successfully set -ForegroundColor Green}
else
{Write-Host -ErrorAction Stop -ForegroundColor Red}
Disconnect-MicrosoftTeams