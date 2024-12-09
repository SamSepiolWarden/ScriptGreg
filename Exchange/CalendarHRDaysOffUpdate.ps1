Connect-Mggraph

# Prompt for the group
$groupID = Read-Host -Prompt "Enter the id of the group calendar"
$groupCalendarID = (Get-MgGroupCalendar -GroupId $groupID).Id
$GroupGet = Get-MgGroup -groupId $groupID

# get all event in the group

$events = Get-MgGroupCalendarEvent -GroupId $GroupGet.Id
foreach ($event in $events) {
    Write-Host "$($event.Subject)"
}


$AskToExe = Read-host -Prompt "Do you want to update these events? (Y/N)"
if ($AskToExe -eq "Y") {
    
foreach ($event in $events) {
    $Asking = Read-host -Prompt "Do you want to update this event: $($event.Subject) ? (Y/N)"
    if($Asking -eq "Y"){
    Update-MgGroupCalendarEvent -GroupId $groupID -CalendarId $groupCalendarID -EventId $event.Id }
    else {
        Write-Host "Event not updated" -ForegroundColor Cyan
    }
}
}
Disconnect-MgGraph