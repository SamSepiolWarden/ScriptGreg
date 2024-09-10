Connect-MgGraph

$Loop = Y
while ($Loop -eq "Y") {
    

#Prompt to enter the staff user who change of manager
$UPN = Read-Host -Prompt "Enter the UPN of the user who change of manager"
$User = Get-MgUser -Filter "UserPrincipalName eq '$UPN'"
if($null -eq $User){
    Write-Host "User not found" -ForegroundColor Red | Break

}
Write-Host "User $User.UserPrincipalName found" -ForegroundColor Green
#Prompt to get the new manager
$Manager = Read-Host -Prompt "Enter the UPN of the new manager"
$ManagerSearch = Get-MgUser -Filter "UserPrincipalName eq '$Manager'"
if($null -eq $ManagerSearch){
    Write-Host "Manager not found" -ForegroundColor Red | Break
}
Write-Host "Manager $ManagerSearch.UserPrincipalName found" -ForegroundColor Green

#Change the manager
Update-MgUser -UserId $User.Id -Manager $ManagerSearch.Id

$Loop = Read-Host -Prompt "Do you want to change another user Manager ? (Y/N)"
}
if ($Loop) {
    Write-Host "End of script" -ForegroundColor Cyan
}

