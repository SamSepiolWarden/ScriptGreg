# Connect to Exchange Online
Connect-ExchangeOnline

# Initialize $Ask
$Ask = 'Y'

while ($Ask -eq 'Y') {
    
    # Prompt for a DL to remove
    $DLToRemove = Read-Host -Prompt 'Enter the DL to remove'
    
    # Get the DL
    $DL = Get-DistributionGroup -Identity $DLToRemove
    
    # Remove the DL
    if ($DL) {
        Remove-DistributionGroup -Identity $DLToRemove -Confirm:$true
    } else {
        Write-Host "DL $DLToRemove not found" -ForegroundColor Red
        continue
    }
    
    # Verification
    if ($?) {
        Write-Host "DL $DLToRemove removed successfully" -ForegroundColor Green
    }
    else {
        Write-Host "Failed to remove DL $DLToRemove" -ForegroundColor Red
    }

    # Ask if the user wants to remove another DL
    $Ask = Read-Host -Prompt 'Do you want to remove another DL? (Y/N)'
}

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false
