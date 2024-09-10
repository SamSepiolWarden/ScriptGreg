# Ensure a connection to Exchange Online is established
Connect-ExchangeOnline

do {
    $removeUserChoice = Read-Host -Prompt "Do you want to remove a user? (Y/N)"
    if ($removeUserChoice -eq "Y") {
        $UserToRemove = Read-Host -Prompt "Enter the UPN to remove"
        $SearchUPN = Get-Mailbox -Identity $UserToRemove -ErrorAction SilentlyContinue
        if ($null -eq $SearchUPN) {
            Write-Host "User not found"
        }
        else {
            Write-Host "User found: $($SearchUPN.PrimarySmtpAddress)"

            $AskToRemove = Read-Host -Prompt "Do you really want to remove this user? (Y/N)"
            if ($AskToRemove -eq "Y") {
                Remove-Mailbox -Identity $UserToRemove -Confirm:$false
                Write-Host "User removed"
            }
            else {
                Write-Host "User not removed"
            }
        }
    }

    Start-Sleep -s 15

    # Proceed to Create a Distribution List (DL)
    $DLName = Read-Host -Prompt "Enter the DL name"
    $emailDL = Read-Host -Prompt "Enter the DL email"
    $Members = Read-Host -Prompt "Enter the members' UPN, if you have more than one, write them separated by commas"

    New-DistributionGroup -Name $DLName -PrimarySmtpAddress $emailDL -Members $Members -ErrorAction SilentlyContinue
    if ($?) {
        Write-Host "$DLName DL created"
        # Update DL with restrictions
        Set-DistributionGroup -Identity $DLName -PrimarySmtpAddress $UserToRemove -MemberDepartRestriction Closed -MemberJoinRestriction Closed -RequireSenderAuthenticationEnabled $false

        Write-Host "DL restrictions set to Closed"
    }
    else {
        Write-Host "Error in creating $DLName DL, not created"
    }

    $continue = Read-Host "Do you want to process another operation? (Y/N)"
} while ($continue -eq "Y")

Write-Host "Exiting script..."

