Connect-MgGraph
# Function to handle mailbox permission assignment
function Add-MailboxAndSendAsPermissions {
    param (
        [string]$Mailbox,
        [string]$User
    )

    Try {
        Add-MailboxPermission -Identity $Mailbox -User $User -AccessRights FullAccess -ErrorAction Stop
        Write-Host "$User has been added to shared $Mailbox mailbox" -ForegroundColor Green
    } Catch {
        Write-Host "An error occurred while adding $User to shared $Mailbox mailbox" -ForegroundColor Red
    }

    Try {
        Add-RecipientPermission -Identity $Mailbox -Trustee $User -AccessRights SendAs -ErrorAction Stop
        Write-Host "$User has been granted SendAs permission on shared $Mailbox mailbox" -ForegroundColor Green
    } Catch {
        Write-Host "An error occurred while granting SendAs permission to $User on shared $Mailbox mailbox" -ForegroundColor Red
    }
}

# Connect to Exchange Online
Connect-ExchangeOnline

$User = Read-Host "Enter the name of the mailbox to add"
Try {
    Get-Mailbox -Identity $User -ErrorAction Stop | Select-Object -ExpandProperty PrimarySmtpAddress
} Catch {
    Write-Host "No mailbox can be found called $User" -ForegroundColor Red
    Disconnect-ExchangeOnline
    return
}

# Select Location
$Locations = @("&Paris", "&Lyon", "&Mumbai")
$Result = $host.UI.PromptForChoice('Task Menu', 'Select a Location', $Locations, 0)
$Location = $Locations[$Result].Substring(1)

# Import DLs based on location
$DLs = Import-Csv -Path "C:\Users\GregorySemedo\Desktop\Script\DL\DL-$Location.csv"
ForEach ($DL in $DLs) {
    Try {
        Add-DistributionGroupMember -Identity $DL."DL" -Member $User -ErrorAction Stop
        Write-Host "$User successfully added to DL" -ForegroundColor Green
    } Catch {
        Write-Host "An error occurred while adding $User to DL" -ForegroundColor Red
    }
}

# Select Department
$Departments = @("&CSM", "&HR", "&Legal", "&Marketing", "&Partnership", "&Product", "&Sales", "&SolutionsConsulting", "&Tech", "&Corp", "&Support", "&Crea", "&Accounting", "&Quit")
$Result = $host.UI.PromptForChoice('Task Menu', 'Select a Department', $Departments, 0)
$Department = $Departments[$Result].Substring(1)

if ($Department -eq "Quit") {
    Write-Host "Process stopped." -ForegroundColor Yellow
    Disconnect-ExchangeOnline
    return
}

# Import DLs based on department
$DLs = Import-Csv -Path "C:\Users\GregorySemedo\Desktop\Script\DL\DL-$Department.csv"
ForEach ($DL in $DLs) {
    Try {
        Add-DistributionGroupMember -Identity $DL."DL" -Member $User -ErrorAction Stop
        Write-Host "$User successfully added to DL" -ForegroundColor Green
    } Catch {
        Write-Host "An error occurred while adding $User to DL" -ForegroundColor Red
    }
}

# Connect to Teams and add the user to Teams groups
Connect-MicrosoftTeams
$TeamsAdd = Import-Csv -Path "C:\Users\GregorySemedo\Desktop\Script\Ms-Teams-Script\Teams\Teams-$Department.csv"
$i = 0
$TotalRows = $TeamsAdd.Count
Foreach ($TeamUser in $TeamsAdd) {
    $TeamName = $TeamUser.TeamName
    $GroupId = $TeamUser.GroupId
    $Role = $TeamUser.Role

    $i++
    Write-Progress -Activity "Processing $TeamName - $Role" -Status "$i out of $TotalRows completed"
    Try {
        Add-TeamUser -GroupId $GroupId -User "$User" -Role "$Role" -ErrorAction Stop
        Write-Host "$User successfully added to Teams Group $TeamName" -ForegroundColor Green
    } Catch {
        Write-Host "An error occurred while adding $User to Teams Group $TeamName" -ForegroundColor Red
    }
}

# Specific team membership logic for Paris and Lyon
$TeamLocations = @{
    'Paris' = 'b2e6ef79-7d1d-4e72-b027-fb8caa25202a'
    'Lyon'  = 'b7e7d611-2ec3-479e-afec-bcedb0aadfb4'
}

foreach ($Location in $TeamLocations.Keys) {
    $GroupId = $TeamLocations[$Location]
    $UserInTeam = Get-Team -GroupId $GroupId | Get-TeamUser | Where-Object { $_.User -eq $User }
    
    if ($UserInTeam) {
        Write-Host "$User is already a member of $Location" -ForegroundColor Red
    } else {
        Write-Host "$User is not a member of $Location, adding now..." -ForegroundColor Yellow
        Try {
            Add-TeamUser -GroupId $GroupId -User $User -Role Member -ErrorAction Stop
            Write-Host "$User successfully added to $Location" -ForegroundColor Green
        } Catch {
            Write-Host "An error occurred while adding $User to $Location team" -ForegroundColor Red
        }
    }
}

# Check if the department is Corp or Accounting and add mailbox permissions
if ($Department -eq "Corp" -or $Department -eq "Accounting") {
    $Mailboxes = @("shared.accounting@sociabble.com", "shared.billing@sociabble.com", "shared.purchase@sociabble.com", "shared.rocinante@sociabble.com")
    foreach ($Mailbox in $Mailboxes) {
        Add-MailboxAndSendAsPermissions -Mailbox $Mailbox -User $User
    }
}
# Add to Global ChitChat
If($Location -eq 'Paris' -or 'Lyon' -or 'Mumbai' ){
    $AllChat = Get-MgChat -Filter "chatType eq 'group'"
    Add-MgUserChatMember -ChatId "19:7e11acf4a6624f13a9d4bf77f4b4e5c1@thread.v2" -UserId $User
    if ($?) {
        Write-Host "$User added to $AllChat.Topic" -ForegroundColor Green
    }
    else {
        Write-Host "Error with the add for $User" -ForegroundColor DarkCyan
    }
}
# Add to Lunch time
if ($Location -eq "Paris") {
    Add-MgUserChatMember -ChatId "19:cf717a7fbc9e42c58238dc2ac20428bb@thread.v2" -UserId $User
    Write-Host "$User added to Lunch Time Chat" -ForegroundColor Green
    else {
        Write-Host "Error to add $User to LunchTime" -ForegroundColor DarkCyan
    }
}
# Disconnect from both Exchange and Microsoft Teams
Disconnect-MicrosoftTeams
Disconnect-ExchangeOnline
