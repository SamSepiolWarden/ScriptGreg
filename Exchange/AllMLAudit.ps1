# Connect to Exchange Online
Connect-ExchangeOnline

# Get all Mailing lists
$MailGroups = Get-DistributionGroup -ResultSize unlimited

# Prepare a list to store the results
$Results = New-Object System.Collections.Generic.List[Object]

foreach ($Mail in $MailGroups) {
    try {
        # Get members of each mailing list
        $Members = Get-DistributionGroupMember -Identity $Mail.Identity -ResultSize unlimited
        $LastMessage = Get-MessageTrace -RecipientAddress $Mail.PrimarySmtpAddress -StartDate (Get-Date).AddDays(-10) -EndDate (Get-Date) |
        Sort-Object Received -Descending |
        Select-Object -First 1
        foreach ($Member in $Members) {
            # Create a PS object to store the data
            $Data = [PSCustomObject]@{
                "DLName"      = $Mail.Name
                "Email"       = $Mail.PrimarySmtpAddress
                "Description" = $Mail.Description
                "Comments"    = $Mail.Comments
                "Member" = $Member.DisplayName -join ', '
                "LastActivity" = $LastMessage.Received
                "Comment" = ""
                "Action" = ""
                "Action Date" = ""
                "Last Action Date" = ""
                "Reviewer" = ""
            }
            
            # Add the data to the results list
            $Results.Add($Data)
        }
    } catch {
        Write-Warning "An error occurred processing group $($Mail.Name): $_"
        # break
    }
}

# Export all collected data to a CSV
$Results | Export-Csv -Path "C:\Test\AllEmail.csv" -NoTypeInformation

# Check if the file was created successfully
if (Test-Path "C:\Test\AllEmail.csv") {
    Write-Host "Export successfully created!" -ForegroundColor Green
} else {
    Write-Host "Export failed. Check the script and try again." -ForegroundColor Red
}

