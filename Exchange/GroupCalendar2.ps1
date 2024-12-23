Connect-MgGraph -Scopes "User.Read.All", "Calendars.ReadWrite.Shared", "Calendars.ReadWrite"

# Prompt for user
$groupID = Read-Host -Prompt "Enter the id of the group calendar"
$groupCalendarID = (Get-MgGroupCalendar -GroupId $groupID).Id

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
                    Address = "SOCIABBLE-DaysOff@sociabble.net"
                    Name = "SOCIABBLE - Public Holiday France"
                }
                Type = "Required"
            }
        )
        IsOrganizer = @(
            @{
                EmailAddress = @{
                    Address = "sociabble-daysoff@sociabble.net"}
                }
        )
        IsAllDay = $true
        ShowAs = "Oof"  # This sets the availability to "Away" for this event
        ResponseStatus = "Accepted"
        Calendar = $groupCalendarID
    }

    try {
        # Create the event
        New-MgGroupCalendarEvent -GroupId $groupID -BodyParameter $Params
        Write-Host "Event created for $($row.Subject)"
    }
    catch {
        Write-Host "Error creating event for $($row.Subject): $_"
    }
}

Disconnect-MgGraph