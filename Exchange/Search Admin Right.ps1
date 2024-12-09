Connect-MsolService
Get-MsolRole
$RoleName = Read-Host -Prompt "Enter the Role Name to search"
Get-MsolRoleMember -RoleObjectId $(Get-MsolRole -RoleName "$RoleName").ObjectId | Select-Object -Property DisplayName,EmailAddress
[Microsoft.Online.Administration.Automation.ConnectMsolService]::ClearUserSessionState()