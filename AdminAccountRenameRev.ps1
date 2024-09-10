$LocalAdminAccount = Get-LocalUser -Name "SociabbleAdmin"
$NewAdminName = "SociabbleAdmin"
Rename-LocalUser -Name $LocalAdminAccount.Name -NewName $NewAdminName
Enable-LocalUser -Name $NewAdminName
$Password = ConvertTo-SecureString "C1sc0!Ell10T@" -AsPlainText -Force
Set-LocalUser -Name $NewAdminName -Password $Password
Set-LocalUser -Name $NewAdminName -PasswordNeverExpires $false
