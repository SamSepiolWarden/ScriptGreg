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

    # Start a historical search for message trace data
    $searchRequest = Start-HistoricalSearch -ReportTitle "MessageTrace_$($GroupName)_$(Get-Date -Format 'yyyyMMddHHmmss')" -StartDate $startDate -EndDate $endDate -ReportType MessageTrace -NotifyAddress "gregory.semedo@sociabble.com" -RecipientAddress $group.PrimarySmtpAddress

    # Wait for the search to complete
    $searchComplete = $false
    while (-not $searchComplete) {
        $status = Get-HistoricalSearch -JobId $searchRequest.JobId | Select-Object -ExpandProperty Status
            Write-Host "Search status: $status"
        switch ($status) {
            "InProgress" {
                Write-Host "Search in progress, waiting for completion..."
                Start-Sleep -Seconds 30
                continue
            }
            "Done" {
                Write-Host "Search results finished for distribution group $GroupName." -ForegroundColor Green
                break
                $searchComplete = $true
            }
            "NotStarted" {
                Write-Host "Search not started yet, waiting for it to begin..."
                Start-Sleep -Seconds 30
                continue
            }
            default {
                Write-Host "Unexpected status: $status, waiting..."
                Start-Sleep -Seconds 30
                continue
            }
        }
    }

    $reportStatusDescription = (Get-HistoricalSearch -JobId $searchRequest.RequestId).ReportStatusDescription
    if ($reportStatusDescription -eq "Terminé - Téléchargement prêt") {
        # Retrieve the report URL
        $reportUrl = (Get-HistoricalSearch -JobId $searchRequest.RequestId).ReportRequestorDetails.ReportDownloadUrl
        if ($reportUrl) {
            # Download the report
            $localPath = "C:\Temp\MessageTraceReport.csv"
            Invoke-WebRequest -Uri $reportUrl -OutFile $localPath

            # Parse the report to check for activity
            $reportContent = Import-Csv -Path $localPath
            if ($reportContent.Count -eq 0) {
                Write-Host "No activity found for distribution group $GroupName in the past 90 days." -ForegroundColor Yellow
            } else {
                Write-Host "Activity in the $GroupName, check the notification in Outlook." -ForegroundColor Green
            }
        } else {
            Write-Host "Failed to retrieve the report URL." -ForegroundColor Red
        }
    } else {
        Write-Host "The search completed but did not find any results." -ForegroundColor Yellow
    }
}

$continue = $true
while ($continue) {
    # Prompt the user to enter the name of the distribution group
    $GroupName = Read-Host "Enter the name of the distribution group"

    # Confirm the search
    $confirmation = Read-Host "Do you want to search for the last activity of $GroupName ? (Yes/No)"
    if ($confirmation -eq "Yes") {
        Get-DistributionGroupLastActivity -GroupName $GroupName
    }

    # Ask if the user wants to search for another group
    $response = Read-Host "Do you want to search for another distribution group? (Yes/No)"
    if ($response -ne "Yes") {
        $continue = $false
    }
}

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false
