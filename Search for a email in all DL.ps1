# Connect to Exchange Online
Connect-ExchangeOnline

$Ask = "Y"

while ($Ask -eq "Y") {
    # Prompt for email address
    $emailToCheck = Read-Host -Prompt "Enter the email address to check"

    $groups = Get-DistributionGroup
    $foundGroup = $null

    foreach ($group in $groups) {
        $recipientDetails = Get-Recipient -Identity $group.Identity
        $allEmailAddresses = $recipientDetails.EmailAddresses | ForEach-Object { $_.SmtpAddress }

        if ($emailToCheck -in $allEmailAddresses) {
            $foundGroup = $group
            break
        }
    }

    # Output result
    if ($foundGroup) {
        Write-Host "Email address $emailToCheck is associated with Distribution Group: $($foundGroup.Name)" -ForegroundColor Green
    } else {
        Write-Host "No Distribution Group found with email address $emailToCheck" -ForegroundColor DarkGray
    }

    # Ask if user wants to continue
    $Ask = Read-Host -Prompt "Do you want to check another email address? (Y/N)"
}

# Disconnect from Exchange Online and close session
if($Ask -eq "N"){
    Write-Host "Exiting script." -ForegroundColor Yellow
    Disconnect-ExchangeOnline
}
