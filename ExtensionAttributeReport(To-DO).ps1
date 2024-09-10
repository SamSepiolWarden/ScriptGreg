# Connect to Microsoft Graph
Connect-MgGraph

# Initialize an array to hold the final output
$FinalOutput = @()

# Get all groups
$ALLGroups = get-mggroup -All:$true

# Filter groups whose DisplayName contains 'Winget'
$FilteredGroups = $ALLGroups | Where-Object { $_.DisplayName -like '*Winget*' }

foreach ($Group in $FilteredGroups) {
    Write-Host "Processing group $($Group.DisplayName)"
    
    # Initialize an array to hold the member names for the current group
    $MemberNames = @()

    # Get members of the group
    $GroupMembers = Get-MgGroupMember -GroupId $Group.Id -All:$true

    # Get the display names of the members
    foreach ($Member in $GroupMembers) {
        $Device = get-mgdevice -DeviceId $Member.Id
        if ($Device) {
            $MemberNames += $Device.DisplayName
        }
    }

    # Create a custom PSObject to hold the data
    $GroupInfo = [PSCustomObject]@{
        "GroupName"      = $Group.DisplayName
        "MembershipRule" = $Group.MembershipRule
        "GroupMembers"   = $MemberNames -join ', '
        "Action On Devices" = $Null
        "Comment"        = $Null
        "Date"           = $Null
        "Status"         = $Null
    }

    # Add the PSObject to the final output array
    $FinalOutput += $GroupInfo
}

# Export the final output to a CSV file
$FinalOutput | Select-Object GroupName, MembershipRule, GroupMembers | Export-Csv -Path "c:\Test\DevicesExtensions.csv"

# Disconnect from Microsoft Graph
Disconnect-MgGraph
