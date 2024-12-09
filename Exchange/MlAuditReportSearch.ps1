# Connect to Exchange Online
Connect-ExchangeOnline

# Function to get the last activity of a distribution group
function Get-DistributionGroupLastActivity {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GroupName
    )

    # Get the distribution group
    $group = Get-DistributionGroup -Identity $GroupName

    if ($null -eq $group) {
        Write-Host "Distribution group $GroupName not found." -ForegroundColor Red
        return
    }

    # Get the last 90 days of message trace data for the group
    $endDate = Get-Date
    $startDate = $endDate.AddDays(-90)

    $messageTrace = Get-MessageTrace -RecipientAddress $group.PrimarySmtpAddress -StartDate $startDate -EndDate $endDate

    if ($messageTrace.Count -eq 0) {
        Write-Host "No activity found for distribution group $GroupName in the past 90 days." -ForegroundColor Yellow
    } else {
        # Find the last activity date
        $lastActivityDate = $messageTrace | Sort-Object -Property Received -Descending | Select-Object -First 1 -ExpandProperty Received

        Write-Host "The last activity for distribution group $GroupName was on $lastActivityDate." -ForegroundColor Green

        # Prepare data for CSV export
        $exportData = [PSCustomObject]@{
            GroupName = $GroupName
            LastActivityDate = $lastActivityDate
        }

        # Export to CSV
        $csvPath = "C:\Test\DistributionGroupActivity.csv"
        if (-not (Test-Path $csvPath)) {
            $exportData | Export-Csv -Path $csvPath -NoTypeInformation
        } else {
            $exportData | Export-Csv -Path $csvPath -NoTypeInformation -Append
        }

        Write-Host "Data has been exported to $csvPath" -ForegroundColor Green
    }
}

$continue = $true
while ($continue) {
    # Prompt the user to enter the name of the distribution group
    $groupName = Read-Host "Enter the name of the distribution group"

    # Confirm the search
    $confirmation = Read-Host "Do you want to search for the last activity of $groupName? (Yes/No)"
    if ($confirmation -eq "Yes") {
        Get-DistributionGroupLastActivity -GroupName $groupName
    }

    # Ask if the user wants to search for another group
    $response = Read-Host "Do you want to search for another distribution group? (Yes/No)"
    if ($response -ne "Yes") {
        $continue = $false
    }
}

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false
