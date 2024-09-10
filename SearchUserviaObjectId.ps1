Connect-Mggraph

$AskUser = "Y"

while ($AskUser -eq "Y") {
    


$UserID = Read-Host -prompt "Enter the user Object ID"

$UserSearch = Get-MgUser -UserId $UserId | Select-Object DisplayName, UserPrincipalName, ObjectId

Write-Host "The User is $($UserSearch.DisplayName):" -ForegroundColor Cyan

$AskUser = Read-Host -prompt "Do you want to search for another user? (Y/N)"
}
if($AskUser -eq "N"){
    Write-Host "End of User Search" -ForegroundColor Green | Disconnect-MgGraph
}