Connect-MgGraph -Scopes "User.Read.All", "Calendars.ReadWrite.Shared", "Calendars.ReadWrite"
Connect-ExchangeOnline
# Prompt for user
$userEmail = Read-Host -Prompt "Enter the user email address"
$SharedCalendarName = Read-Host -Prompt "Enter the shared calendar name"

# Get the user
$User = Get-MgUser -Filter "userPrincipalName eq '$userEmail'"


# Get the calendar
$Calendar = Get-MgUserCalendar -UserId $User.Id -Filter "name eq '$SharedCalendarName'"

# Import CSV file
$csv = Import-Csv -Path "C:\Test\PlanningFrance.csv"

# Loop through the CSV file
foreach ($row in $csv) {
    # Create the body parameter
    $Params = @{
        Subject = $row.Subject
        Body = @{
            ContentType = "HTML"
            Content = $row.Body
        }
        Start = @{
            DateTime = $row.StartDate
            TimeZone = "Europe/Paris"
        }
        End = @{
            DateTime = $row.EndDate
            TimeZone = "Europe/Paris"
        }
        Location = @{
            DisplayName = $row.Location
        }
        Attendees = @(
            @{
                EmailAddress = @{
                    Address = $null
                    Name = $null
                }
                Type = "Required"
            }
        )
        IsAllDay = $true
        ShowAs = "Oof"  # This sets the availability to "Away" for this event
    }

    # Create the event
    New-MgUserCalendarEvent -UserId $User.Id -CalendarId $Calendar.Id -BodyParameter $Params
}

if($? -eq $false) {
    Write-Host "Error creating event for $userEmail"
}
else {
    Write-Host "Event created for $userEmail"
}
