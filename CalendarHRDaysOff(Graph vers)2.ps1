Connect-MgGraph -Scopes "User.Read.All", "Calendars.ReadWrite.Shared", "Calendars.ReadWrite"
Connect-ExchangeOnline
# Prompt for Group
#$GroupEmail = Read-Host -Prompt "Enter the group email address"
#$SharedCalendarName = Read-Host -Prompt "Enter the shared calendar name"

# Get the Group
$Group = Get-Mggroup -GroupId 8c055a44-8fe9-423f-8209-6541f3db6ae9


# Get the calendar
$Calendar = Get-MgGroupCalendar -GroupId $Group.Id
Write-Host "Calendar: $Calendar"
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
    New-MgGroupCalendarEvent -GroupId $Group.Id -Calendar $Calendar.Id -BodyParameter $Params
}

if($? -eq $false) {
    Write-Host "Error creating event for $userEmail"
}
else {
    Write-Host "Event created for $userEmail"
}
