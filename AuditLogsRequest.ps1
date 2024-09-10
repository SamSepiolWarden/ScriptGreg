# Connect to Exchange Online before starting the loop
Connect-ExchangeOnline

$Ask = "Y"

# Start the loop
while ($Ask -ne "N") {
    $StartDate = Read-Host "Enter a start date in this format MM/DD/YYYY"
    $EndDate = Read-Host "Enter an end date in this format MM/DD/YYYY"


    $Search = Search-UnifiedAuditLog -RecordType ExchangeAdmin -StartDate $StartDate -EndDate $EndDate -SessionCommand ReturnLargeSet

    # Check if $Search contains data before attempting to export
    if ($Search) {
        $Search | Export-Csv -Path "C:\Test\AuditLog.csv" -NoTypeInformation
        if ($? -eq $true) {
            Write-Host "Data exported to C:\Test\AuditLog.csv" -ForegroundColor Green
        } else {
            Write-Host "Issue with the Data, not exported" -ForegroundColor Red
        }
    } else {
        Write-Host "No records found for the given date range." -ForegroundColor Yellow
    }

    # Ask the user if they want to continue after attempting the export
    $Ask = Read-Host -Prompt "Do you want to continue ? Y/N"
}

# Disconnect from Exchange Online after the loop finishes
Disconnect-ExchangeOnline
