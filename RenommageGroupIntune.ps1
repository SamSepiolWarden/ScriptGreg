# Function to get the prefix based on the selected preset
function Get-Prefix {
    param (
        [string]$preset
    )

    switch ($preset) {
        "1" { return "DSI -" }
        "2" { return "Remediation -" }
        "3" { return "Autopatch -" }
        "4" { return "AccountProtection -" }
        "5" { return "Security -" }
        "6" { return "Compliance -" }
        "7" { return "Monitoring -" }
        "8" { return "ConditionnalAccess -" }
        "9" { return "IdentityProtection -" }
        "10" { return "Onboarding -" }
        "11" { return "LAPS -" }
        "12" { return "Applications -" }
        "13" { return "Organisation -" }
        "14" { return "SharedCalendar -" }
        "15" { return "Intune -" }
        "16" { return "Script -" }
        "17" { return "Browser -" } 
        "18" { return "Offboarding -" }
        "19" { return "Device -" }
        "20" { return "Identity -" }
        "21" { return "Mobile -" }
        "22" { return "Enrollment -" }
        "23" { return "GPO -" }
        "24" { return "Testing -" }
        "25" { return "Storage -" }
        default { throw "Invalid preset value. Please choose from '1' to '25'." }
    }
}

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Group.ReadWrite.All"

# Fetch all groups starting with 'Sociabble -'
$groups = Get-MgGroup -Filter "startswith(displayName,'Sociabble -')"

# Load the CSV file
$csv = Import-Csv -Path "C:\Test\exportGroup_2024-7-30.xlsx"

# Iterate over each group and rename it
$groups | ForEach-Object {
    # Find the corresponding entry in the CSV file
    $csvEntry = $csv | Where-Object { $_.displayname -eq $_.displayName }
    if ($csvEntry -ne $null) {
        # Display the current group being processed
        Write-Host "Processing group $($_.displayName)"
        
        # Display the preset options
        Write-Host "1 for 'DSI -'"
        Write-Host "2 for 'Remediation -'"
        Write-Host "3 for 'Autopatch -'"
        Write-Host "4 for 'AccountProtection -'"
        Write-Host "5 for 'Security -'"
        Write-Host "6 for 'Compliance -'"
        Write-Host "7 for 'Monitoring -'"
        Write-Host "8 for 'ConditionnalAccess -'"
        Write-Host "9 for 'IdentityProtection -'"
        Write-Host "10 for 'Onboarding -'"
        Write-Host "11 for 'LAPS -'"
        Write-Host "12 for 'Applications -'"
        Write-Host "13 for 'Organisation -'"
        Write-Host "14 for 'SharedCalendar -'"
        Write-Host "15 for 'Intune -'"
        Write-Host "16 for 'Script -'"
        Write-Host "17 for 'Browser -'"
        Write-Host "18 for 'Offboarding -'"
        Write-Host "19 for 'Device -'"
        Write-Host "20 for 'Identity -'"
        Write-Host "21 for 'Mobile -'"
        Write-Host "22 for 'Enrollment -'"
        Write-Host "23 for 'GPO -'"
        Write-Host "24 for 'Testing -'"
        Write-Host "25 for 'Storage -'"
        Write-Host "Choose a preset for group $($_.displayName):"
        Write-Host "The description of the group is: $($_.description)"

        do {
            $Asking = Read-Host "Do you want to rename the group? (Y/N)"
            if ($Asking -ne "Y" -and $Asking -ne "N") {
                Write-Host "Invalid input. Please enter 'Y' or 'N'." -ForegroundColor Red
            }
        } while ($Asking -ne "Y" -and $Asking -ne "N")

        if ($Asking -eq "Y") {
            do {
                $preset = Read-Host "Enter the number corresponding to your choice"
                try {
                    $prefix = Get-Prefix -preset $preset
                    $validPreset = $true
                } catch {
                    Write-Host $_.Exception.Message -ForegroundColor Red
                    $validPreset = $false
                }
            } while (-not $validPreset)
            
            # Construct the new display name by replacing 'Sociabble -' with the selected prefix
            $newName = $_.displayName -replace '^Sociabble -', $prefix
            
            # Output the change for verification
            Write-Host "Renaming group $($_.displayName) to $newName" -ForegroundColor Yellow

            do {
                $confirm = Read-Host "Are you sure to rename the group? (Y/N)"
                if ($confirm -ne "Y" -and $confirm -ne "N") {
                    Write-Host "Invalid input. Please enter 'Y' or 'N'." -ForegroundColor Red
                }
            } while ($confirm -ne "Y" -and $confirm -ne "N")

            if ($confirm -eq "Y") {
                # Update the group with the new display name
                Update-MgGroup -GroupId $_.Id -DisplayName $newName
                Write-Host "Group $($_.displayName) renamed to $newName" -ForegroundColor Green
            } else {
                Write-Host "Skipping group $($_.displayName)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "No need to rename, go next group" -ForegroundColor Yellow
        }
    }
}
