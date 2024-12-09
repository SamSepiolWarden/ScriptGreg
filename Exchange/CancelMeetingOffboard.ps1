# Step 1: Connect to Microsoft Graph using an authenticated session
# Make sure you have the Microsoft Graph PowerShell module installed and you are logged in
Connect-MgGraph -Scopes "User.ReadWrite", "Calendars.ReadWrite", "Calendars.ReadWrite.Shared"

function Add-UserPermission {
    param (
        [Parameter(Mandatory = $true)]
        [string]$UserMailbox,

        [Parameter(Mandatory = $true)]
        [string]$ITMail,

        [Parameter(Mandatory = $true)]
        [string]$Rights
    )

    try {
        Add-MailboxFolderPermission -Identity $UserMailbox -User $ITMail -AccessRights $Rights -ErrorAction Stop
        Write-Host "$ITMail a été ajouté au calendrier avec succès." -ForegroundColor Green
    }
    catch {
        Write-Host "Erreur lors de l'ajout de $ITMail : $_" -ForegroundColor Red
    }

    Start-Sleep -Seconds 10  # Give time for the permissions to propagate

    Get-MailboxFolderPermission -Identity $UserMailbox | Format-Table -Property User, AccessRights
}

function Set-UserPermission {
    param (
        [Parameter(Mandatory = $true)]
        [string]$UserMailbox,

        [Parameter(Mandatory = $true)]
        [string]$ITMail,

        [Parameter(Mandatory = $true)]
        [string]$Rights
    )

    try {
        Set-MailboxFolderPermission -Identity $UserMailbox -User $ITMail -AccessRights $Rights -ErrorAction Stop
        Write-Host "$ITMail a été mis à jour au calendrier avec succès." -ForegroundColor Green
    }
    catch {
        Write-Host "Erreur lors de la mise à jour de $ITMail : $_" -ForegroundColor Red
    }

    Start-Sleep -Seconds 10  # Give time for the permissions to propagate

    # Retry logic to ensure the changes are reflected
    $retryCount = 0
    $maxRetries = 3
    do {
        $retryCount++
        $currentPermissions = Get-MailboxFolderPermission -Identity $UserMailbox -User $ITMail -ErrorAction SilentlyContinue
        if ($currentPermissions) {
            Write-Host "Permissions for $ITMail on $UserMailbox after change:" -ForegroundColor Green
            $currentPermissions | Format-Table -Property User, AccessRights
            break
        }
        Write-Host "Retrying permission check for $ITMail on $UserMailbox..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5
    } while ($retryCount -lt $maxRetries)

    if (-not $currentPermissions) {
        Write-Host "Failed to confirm permission changes after retries." -ForegroundColor Red
    }
}

function Test-Mailbox {
    param (
        [string]$Mailbox
    )

    return $Mailbox -match '^[^@]+@[^@]+\.[^@]+$'
}

Connect-ExchangeOnline

$User = Read-Host -Prompt "Entrez l'adresse e-mail de l'offboard : Jane.Doe@sociabble.com:\Calendar ou :\Calendrier"
$ITMail = Read-Host -Prompt "Entrez l'adresse e-mail IT ex: Jane.Doe@sociabble.com"
$Rights = Read-Host -Prompt "Entrez le rôle de l'utilisateur (Reviewer/Editor/Owner/Author/NonEditingAuthor/PublishingEditor)"

if (-not (Test-Mailbox $User) -or -not (Test-Mailbox $ITMail)) {
    Write-Host "Invalid email address format." -ForegroundColor Red
    continue
}

$DisplayName = Get-Mailbox -Identity $ITMail | Select-Object -ExpandProperty DisplayName

# Check if ITMail already has permissions
$AuditCalendar = Get-MailboxFolderPermission -Identity $User -User $DisplayName -ErrorAction SilentlyContinue

if ($null -eq $AuditCalendar) {
    Write-Host "$DisplayName n'a pas accès au calendrier de $User." -ForegroundColor Yellow

    $response = Read-Host -Prompt "Voulez-vous ajouter l'accès? (Yes/No)"
    if ($response -eq "Yes") {
        Add-UserPermission -UserMailbox $User -ITMail $ITMail -Rights $Rights
    }
} else {
    $rights = $AuditCalendar.AccessRights -join ', '
    Write-Host "$ITMail a accès au calendrier de $User avec les droits suivants: $rights" -ForegroundColor Yellow
    $ChangeRights = Read-Host -Prompt "Voulez-vous changer les droits? (Yes/No)"
    if ($ChangeRights -eq "Yes") {
        Set-UserPermission -UserMailbox $User -ITMail $ITMail -Rights $Rights
    } else {
        Write-Host "Aucun changement n'a été apporté." -ForegroundColor Yellow
    }
}

# Step 2: Prompt the user for the email address of the calendar to process
$UserEmail = Read-Host -Prompt "Enter the email address of the user to offboard"

# Step 3: Retrieve the main calendar ID
$MainCalendar = Get-MgUserCalendar -UserId $UserEmail | Where-Object { $_.Name -eq "Calendar" }
$CalendarId = $MainCalendar.Id
Write-Host "The main calendar ID is: $CalendarId"

# Step 4: Retrieve all calendar events from the user's main calendar
$CalendarEvents = Get-MgUserCalendarEvent -UserId $UserEmail -CalendarId $CalendarId

# Step 5: Display events for review, showing key details
$CalendarEvents | Format-Table -Property Subject, IsOrganizer

# Step 6: Loop through each event and check if the user is the organizer
foreach ($Event in $CalendarEvents) {
    # Only proceed if the user is the organizer of the event
    if ($Event.IsOrganizer -eq $True) {
        # Extract the Event ID needed to remove the event
        $EventId = $Event.Id

        # Step 7: Cancel the event (and notify attendees that the meeting has been canceled)
        Remove-MgUserEvent -UserId $UserEmail -EventId $EventId -Confirm:$true

        # Output confirmation of event cancellation
        Write-Host "Canceled event: $($Event.Subject)"
    } else {
        Write-Host "Skipping event: $($Event.Subject), not organized by $UserEmail"
    }
}

# Step 8: Confirm completion
Write-Host "All events organized by $UserEmail have been processed."
