Connect-MgGraph -Scopes  "UserAuthenticationMethod.ReadWrite.All" 

$AskAnotherUSer = 'Y'
while ($AskAnotherUSer -eq 'Y') {

#User to block
$User = Read-Host -Prompt "Enter the UPN of the user to block"

#Revoke sessions
Revoke-MgUserSignInSession -UserId $User
if ($?) {
    Write-Host "Sessions revoked successfully for $User" -ForegroundColor Green
}
else {
    Write-Host "User not found" -ForegroundColor Red
    return
}


$AskPassword = Read-Host -Prompt "Do you want to change the password ? (Y/N)"
if ($AskPassword -eq 'Y') {
    

# Prompt for new password
$Newpassword = Read-Host -Prompt "Enter the new password"

# Change the password
$params = @{
    passwordProfile = @{
        forceChangePasswordNextSignIn = $false
        password = $Newpassword | ConvertTo-SecureString -AsPlainText -Force
    }
}
Update-MgUser -UserId $User -BodyParameter $params
if ($?) {
    Write-Host "Password changed successfully" -ForegroundColor Green
} else {
    Write-Host "User not found" -ForegroundColor Red
}
}

# Block the user
$ASkBlock = Read-Host -Prompt "Do you want to block the user ? (Y/N)"
if ($ASkBlock -eq 'Y') {
    

$paramsBlock = @{
    accountEnabled = $false
}

Update-MgUser -UserId $User -BodyParameter $paramsBlock
if ($?) {
    Write-Host "$User blocked successfully" -ForegroundColor Green
} else {
    Write-Host "User not found" -ForegroundColor Red
}
}

$AskForward = Read-Host -Prompt "Do you want to forward the user ? (Y/N)"
if ($AskForward -eq 'Y') {
    

# Create the forward to the manager email
$UserForward = Read-host -Prompt "Enter the UPN of the user to forward"
$Manager = Get-MgUser -UserId $UserForward

Connect-ExchangeOnline

# Create the forward
$Search = Get-Mailbox -Identity $User
if ($null -eq $Search) {
    Write-Host "User not found" -ForegroundColor Red
    return
}
Set-Mailbox -Identity $User -ForwardingSMTPAddress $Manager.Mail -DeliverToMailboxAndForward $true
if ($?) {
    Write-Host "Forward of $User created successfully to $Manager" -ForegroundColor Green
}
else {
    Write-Host "User not found" -ForegroundColor Red
}
}


$Office = [System.Management.Automation.Host.ChoiceDescription]::new('&Office')
$Office.HelpMessage = 'Get running OfficeDL'
$Paris = New-Object System.Management.Automation.Host.ChoiceDescription '&Paris' , 'Get running ParisDL'
$Lyon = New-Object System.Management.Automation.Host.ChoiceDescription '&Lyon' , 'Get running LyonDL'
$Mumbai = New-Object System.Management.Automation.Host.ChoiceDescription '&Mumbai' , 'Get running MumbaiDL'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($Paris, $Lyon, $Mumbai)
$Result = $host.UI.PromptForChoice('Task Menu', 'Select a Location', $options , 0)

switch($Result)
{
    0 { $Location = "Paris"}
    1 { $Location = "Lyon"}
    2 { $Location = "Mumbai"}
}

$DLs = Import-Csv -Path "C:\Users\GregorySemedo\Desktop\Script\DL\DL-$Location.csv"
ForEach ($DL in $DLs) {
     
       Remove-DistributionGroupMember -Identity $DL."DL" -Member $User -ErrorAction Continue 
       If($?)
       {
        Write-Host $User Succesfully remove to DL -ForegroundColor Green
       } 
       Else
       {
        Write-Host -ErrorAction Stop -ForegroundColor Red
       }
}

$Services = [System.Management.Automation.Host.ChoiceDescription]::new('&Services')
$Services.HelpMessage = 'Get running services'
$CSM = New-Object System.Management.Automation.Host.ChoiceDescription '&CSM', 'Get running CSMDL'
$HR = New-Object System.Management.Automation.Host.ChoiceDescription '&HR', 'Get running HRDL'
$Legal = New-Object System.Management.Automation.Host.ChoiceDescription '&Legal', 'Get running LegalDL'
$Marketing = New-Object System.Management.Automation.Host.ChoiceDescription '&Marketing', 'Get running MarketingDL'
$Partnership = New-Object System.Management.Automation.Host.ChoiceDescription '&Partnership', 'Get running PartnershipDL'
$Product = New-Object System.Management.Automation.Host.ChoiceDescription '&Product', 'Get running ProductDL'
$Sales = New-Object System.Management.Automation.Host.ChoiceDescription '&Sales', 'Get running SalesDL'
$Tech = New-Object System.Management.Automation.Host.ChoiceDescription '&Tech', 'Get running TechDL'
$Corp = New-Object System.Management.Automation.Host.ChoiceDescription '&Corp', 'Get running CorpDL'
$Support = New-Object System.Management.Automation.Host.ChoiceDescription '&Support', 'Get running SupportDL'
$Crea = New-Object System.Management.Automation.Host.ChoiceDescription '&Crea', 'Get running CreaDL'
$Quit = New-Object System.Management.Automation.Host.ChoiceDescription '&Quit', 'Quit menu'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($CSM, $HR, $Legal, $Marketing, $Partnership, $Product, $Sales, $Tech, $Corp, $Support, $Crea, $Quit)
$Result = $host.UI.PromptForChoice('Task menu', 'Select a Department', $options , 0 )

switch($result)
{
    0 { $Department = "CSM"}
    1 { $Department = "HR"}
    2 { $Department = "Legal"}
    3 { $Department = "Marketing"}
    4 { $Department = "Partnership"}
    5 { $Department = "Product"}
    6 { $Department = "Sales"}
    7 { $Department = "Tech" }
    8 { $Department = "Corp" }
    9 { $Department = "Support"}
    10 { $Department = "Crea"}
    11 { $Quit = Exit }

}
#############################################

$DLs = Import-Csv -Path "C:\Users\GregorySemedo\Desktop\Script\DL\DL-$Department.csv"
ForEach ($DL in $DLs) {
     
            Remove-DistributionGroupMember -Identity $DL."DL" -Member $User -ErrorAction Continue 
       If($?)
       {
        Write-Host $User Succesfully remove to DL -ForegroundColor Green
       } 
       Else
       {
        Write-Host -ErrorAction Stop -ForegroundColor Red
       }
}

#########
# Ici code pour Groupes Teams
# Connect to Microsoft Teams
Connect-MicrosoftTeams


# Get the user's Teams groups
$groups = Get-Team -User $User

if ($groups.Count -eq 0) {
    Write-Host "The user is not a member of any Teams group."
} else {
    # Display the user's Teams groups
    Write-Host "The user is a member of the following Teams groups:"
    foreach ($group in $groups) {
        # Output the group display name and group id
        Write-Host "Group Name: $($group.DisplayName), Group ID: $($group.GroupId)"
    }

    # Prompt for confirmation to remove the user from each group
    $confirmation = Read-Host -Prompt "Do you want to remove the user from these groups? (Y/N)"
}


    if ($confirmation -eq 'Y') {
        foreach ($group in $groups) {
            # Display the group membership before removing the user
            Write-Host "Group: $($group.DisplayName)"
            $groupMembers = Get-Team -GroupId $group.GroupId
            $groupMembers | Select-Object -Property UserPrincipalName

            # Prompt for confirmation to remove the user from the group
            $groupConfirmation = Read-Host -Prompt "Do you want to remove the user from this group? (Y/N)"

            if ($groupConfirmation -eq 'Y') {
                Remove-TeamUser -GroupId $group.GroupId -User $User
                Write-Host "The user has been removed from the group $($group.DisplayName)." -ForegroundColor Green
            }
            else {
                Write-Host "No action taken. The user has not been removed from the group $($group.DisplayName)." -ForegroundColor Red
            }
        }
    }
    else {
        Write-Host "No action taken. The user has not been removed from any Teams groups."
    }


    Connect-SPOService -Url https://sociabble-admin.sharepoint.com

    $GroupSPO = "Sociabble - Membres"
    $SearchGroup = Get-SPOSiteGroup -Site https://sociabble.sharepoint.com/sites/sociabble -Group $GroupSPO
    if ($SearchGroup){
        Write-Host "the group $GroupSPO exist" -ForegroundColor Green
    }
    #Ask to remove the user
    $AskRemoveUser = Read-Host -Prompt "Do you want to remove another user? (Y/N)"
    if ($AskRemoveUser -eq 'Y'){
        Remove-SPOUSer -Site "https://sociabble.sharepoint.com/sites/sociabble" -LoginName $User -Group $GroupSPO
        if($?)
        {
            Write-Host "User $User removed from the group $GroupSPO" -ForegroundColor Green
        }
        else
        {
            Write-Host "User not found" -ForegroundColor Red
        }
    }
        

$AskAnotherUSer = Read-Host -Prompt "Do you want to remove another user? (Y/N)"
}
if ($AskAnotherUSer -eq 'N'){
    Write-Host "End of the User removal" -ForegroundColor Green
    Write-Host "Goodbye" -ForegroundColor Cyan
Disconnect-MicrosoftTeams
Disconnect-ExchangeOnline
Disconnect-MgGraph
}
