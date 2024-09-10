Connect-ExchangeOnline
$User = Read-Host "Enter Name of the mailbox to remove"
Try {
    Get-Mailbox -Identity $User -ErrorAction Stop | Select-Object -ExpandProperty PrimarySmtpAddress}
Catch {
    Write-Host "No mailbox can be found called" $User; break }

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
$Product = New-Object System.Management.Automation.Host.ChoiceDescription '&Product', 'Get running ProductDL'
$Sales = New-Object System.Management.Automation.Host.ChoiceDescription '&Sales', 'Get running SalesDL'
$Tech = New-Object System.Management.Automation.Host.ChoiceDescription '&Tech', 'Get running TechDL'
$Corp = New-Object System.Management.Automation.Host.ChoiceDescription '&Corp', 'Get running CorpDL'
$Support = New-Object System.Management.Automation.Host.ChoiceDescription '&Support', 'Get running SupportDL'
$Crea = New-Object System.Management.Automation.Host.ChoiceDescription '&Crea', 'Get running CreaDL'
$Quit = New-Object System.Management.Automation.Host.ChoiceDescription '&Quit', 'Quit menu'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($CSM, $HR, $Legal, $Marketing, $Product, $Sales, $Tech, $Corp, $Support, $Crea, $Quit)
$Result = $host.UI.PromptForChoice('Task menu', 'Select a Department', $options , 0 )

switch($result)
{
    0 { $Department = "CSM"}
    1 { $Department = "HR"}
    2 { $Department = "Legal"}
    3 { $Department = "Marketing"}
    4 { $Department = "Product"}
    5 { $Department = "Sales"}
    6 { $Department = "Tech" }
    7 { $Department = "Corp" }
    8 { $Department = "Support"}
    9 { $Department = "Crea"}
    10 { $Quit = Exit }

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

# Get the user's UPN (User Principal Name)
$userUPN = Read-Host -Prompt 'Enter the user UPN'

# Get the user's Teams groups
$groups = Get-Team -User $userUPN

if ($groups.Count -eq 0) {
    Write-Host "The user is not a member of any Teams group."
}
else {
    # Display the user's Teams groups
    Write-Host "The user is a member of the following Teams groups:"
    $groups | Select-Object -Property DisplayName, GroupId

    # Prompt for confirmation to remove the user from each group
    $confirmation = Read-Host -Prompt "Do you want to remove the user from these groups? (Y/N)"

    if ($confirmation -eq 'Y') {
        foreach ($group in $groups) {
            # Display the group membership before removing the user
            Write-Host "Group: $($group.DisplayName)"
            $groupMembers = Get-Team -GroupId $group.GroupId
            $groupMembers | Select-Object -Property UserPrincipalName

            # Prompt for confirmation to remove the user from the group
            $groupConfirmation = Read-Host -Prompt "Do you want to remove the user from this group? (Y/N)"

            if ($groupConfirmation -eq 'Y') {
                Remove-TeamUser -GroupId $group.GroupId -User $userUPN
                Write-Host "The user has been removed from the group $($group.DisplayName)."
            }
            else {
                Write-Host "No action taken. The user has not been removed from the group $($group.DisplayName)."
            }
        }
    }
    else {
        Write-Host "No action taken. The user has not been removed from any Teams groups."
    }
}
Disconnect-ExchangeOnline
Disconnect-MicrosoftTeams
