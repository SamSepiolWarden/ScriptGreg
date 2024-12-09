Connect-MgGraph -Scopes "User.Read.All", "User.ReadWrite.All", "Directory.ReadWrite.All", "Directory.AccessAsUser.All", "Group.ReadWrite.All", "GroupMember.ReadWrite.All"

#User to block
$User = Read-Host -Prompt "Enter the UPN of the user to block"
#Revoke sessions
Revoke-MgUserSignInSession -UserId $User
if ($?) {
    Write-Host "Sessions revoked successfully for $User" -ForegroundColor Green
}
else {
    Write-Host "User not found" -ForegroundColor Red | break
}
# Prompt for new pasword
$Newpassword = Read-Host -Prompt "Enter the new password" -AsSecureString
# Change the password
$params = @{
    passwordProfile = @{
        forceChangePasswordNextSignIn = $false
        password = $Newpassword
    }
}
Update-MgUser -UserId $User -BodyParameter $params
if ($?) {
    Write-Host "Password changed successfully" -ForegroundColor Green
} else {
    Write-Host "User not found" -ForegroundColor Red
}

#Block user
Update-MgUser -UserId $User -AccountEnabled:$false
if ($?) {
    Write-Host "$User blocked successfully" -ForegroundColor Green
} else {
    Write-Host "User not found" -ForegroundColor Red
}

#Create the forward to the manager email
$ManagerForward = Read-Host -Prompt "Enter the UPN of the manager to forward the user mail to"
$Manager = Get-MgUser -UserId $ManagerForward
if($null -eq $Manager){
    Write-Host "Manager not found" -ForegroundColor Red | Break
}
Connect-ExchangeOnline

#Create the forward
$Search = Get-Mailbox -Identity $User
if ($null -eq $Search) {
    Write-Host "User not found" -ForegroundColor Red | Break 
}
Set-Mailbox -Identity $User -ForwardingSMTPAddress $ManagerForward -DeliverToMailboxAndForward $true
if ($?) {
    Write-Host "Forward of $User created successfully to $Manager" -ForegroundColor Green
}
else {
    Write-Host "User not found" -ForegroundColor Red
}

Disconnect-ExchangeOnline
Disconnect-MgGraph

