# Connect to Exchange Online
Connect-ExchangeOnline

function Search-Emails {
    $StartTime = Read-Host -Prompt "Enter the starting date in this format 'mm/dd/yyyy hh:mm:ss'"
    $EndTime = Read-Host -Prompt "Enter the ending date in this format 'mm/dd/yyyy hh:mm:ss'"
    $Subject = "Sociabble -Updated Handbook Docu-2024 Policy Report and sign- D7958"

    $SearchQuery = "Received:>$StartTime AND Received:<$EndTime AND Subject:'$Subject'"
    $SearchName = "EmailSearch-" + (Get-Date -Format FileDateTime)

    # Start a new compliance search
    New-ComplianceSearch -Name $SearchName -ExchangeLocation All -ContentMatchQuery $SearchQuery | Start-ComplianceSearch

    # Wait a moment for the search to initiate and gather results
    Start-Sleep -Seconds 10

    # Get search results
    $SearchStatus = Get-ComplianceSearch -Identity $SearchName

    if ($SearchStatus.Status -eq "Completed") {
        # Displaying basic information
        Write-Host "Search completed. Number of items found: $($SearchStatus.Items)"
        # Optionally, for detailed results, use New-ComplianceSearchAction to export the report
        $ExportName = $SearchName + "-Export"
        New-ComplianceSearchAction -SearchName $SearchName -Export -ExportName $ExportName

        Write-Host "Export initiated for search results. Use the Security & Compliance Center to download the report."
    } else {
        Write-Host "Search may still be running or encountered an issue."
    }
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
