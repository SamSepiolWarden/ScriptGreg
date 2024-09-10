Connect-MgGraph 

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
Set-MgUser -UserId $User -BlockCredential $true
if ($?) {
    Write-Host "$User blocked successfully" -ForegroundColor Green
} else {
    Write-Host "User not found" -ForegroundColor Red
}

#Create the forward to the manager email
$UserForward = Get-MgUser -UserId $User
$Manager = Get-MgUser -UserId $UserForward.ManagerId

Connect-ExchangeOnline

#Create the forward
$Search = Get-Mailbox -Identity $User
if ($null -eq $Search) {
    Write-Host "User not found" -ForegroundColor Red | Break 
}
Set-Mailbox -Identity $User -ForwardingSMTPAddress $Manager -DeliverToMailboxAndForward $true
if ($?) {
    Write-Host "Forward of $User created successfully to $Manager" -ForegroundColor Green
}
else {
    Write-Host "User not found" -ForegroundColor Red
}

Disconnect-ExchangeOnline
Disconnect-MgGraph

