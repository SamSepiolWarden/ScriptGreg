# Step 1: Connect to Microsoft Graph
Connect-MgGraph

# Step 2: Define the user email whose calendar you want to access
$UserEmail = "sociabblebot@sociabble.net"

# Step 3: Retrieve all calendars for the user
$Calendars = Get-MgUserCalendar -UserId $UserEmail

# Step 4: Display the list of calendars with their IDs
$Calendars | Format-Table Name, Id

# Step 5: (Optional) Get the ID of the default calendar
$DefaultCalendar = $Calendars | Where-Object { $_.Name -eq "Calendar" }
$DefaultCalendarId = $DefaultCalendar.Id
Write-Host "The calendar ID is: $DefaultCalendarId"
