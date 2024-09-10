# Connect to Exchange Online
Connect-ExchangeOnline

function Search-Emails {
    $StartTime = Read-Host -Prompt "Enter the starting date in this format 'mm/dd/yyyy hh:mm:ss'"
    $EndTime = Read-Host -Prompt "Enter the ending date in this format 'mm/dd/yyyy hh:mm:ss'"
    $SenderAdd = Read-Host -Prompt "Enter the sender"

    $MessageTrace = Get-MessageTrace -StartDate $StartTime -EndDate $EndTime -SenderAddress $SenderAdd

    $ExportData = @()

    foreach ($message in $MessageTrace) {
        $output = "Subject: $($message.Subject), Sender: $($message.SenderAddress), Recipient: $($message.RecipientAddress), Timestamp: $($message.Received)"
        Write-Host $output

        # Collecting data for export
        $ExportData += New-Object PSObject -Property @{
            Subject = $message.MessageSubject
            Sender = $message.Sender
            Recipients = $message.Recipients -join ", "
            Timestamp = $message.Timestamp
        }
    }

    # Exporting to CSV
    $ExportPath = Read-Host -Prompt "Enter the path to export CSV file (e.g., C:\exports\emails.csv)"
    $ExportData | Export-Csv -Path $ExportPath -NoTypeInformation
    Write-Host "Data exported to $ExportPath"
}

# Initial search
Search-Emails

# Loop for new searches
while ($true) {
    $continue = Read-Host "Do you want to perform another search? (yes/no)"
    if ($continue -eq "yes") {
        Search-Emails
    } else {
        Write-Host "Exiting..."
        break
    }
}

Disconnect-ExchangeOnline