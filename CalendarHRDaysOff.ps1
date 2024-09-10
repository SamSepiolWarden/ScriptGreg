Connect-ExchangeOnline

# Prompt to get the user and shared calendar name
$User = Read-Host -Prompt "Enter the user's email address (owner of the shared calendar)"
$SharedCalendarName = Read-Host -Prompt "Enter the name of the shared calendar"

# Import CSV with date to import inside
$csv = Import-Csv -Path "C:\Test\PlanningFrance.csv"

foreach ($line in $csv) {
    $Start = $line.Start
    $End = $line.End
    $Location = $line.Location
    $Subject = $line.Subject
    $Body = $line.Body

    # Create the event in the shared calendar
    $calendarIdentity = "${User}:\Calendar\${SharedCalendarName}"


    New-EXOCalendarEvent -Identity $calendarIdentity -Subject $Subject -Start $Start -End $End -Location $Location -Body $Body -IsAllDayEvent:$true
    if ($?) {
        Write-Host "Calendar event $Subject created successfully in $SharedCalendarName"
    }
    else {
        Write-Host "Calendar event $Subject creation failed in $SharedCalendarName"
    }
}
