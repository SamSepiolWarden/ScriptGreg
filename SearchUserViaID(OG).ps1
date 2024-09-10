Connect-MgGraph

$Ask = "Y"
While($Ask -eq "Y"){
    $UserID = Read-Host -Prompt "Enter the User ID"
    $User = Get-MgUser -UserId $UserID
    Write-Host "User: $($User.DisplayName)" -ForegroundColor Cyan
    $Ask = Read-Host -Prompt "Do you want to search another user? (Y/N)"
}
Write-Host "End of Search" -ForegroundColor Green
Disconnect-MgGraph