# Loop to process multiple users
do {
    # Connect to Microsoft Graph
    Connect-MgGraph

    # Ask for the UPN of the user
    $UPN = Read-Host -Prompt "Enter the UPN of the user to get the information"

    # Get user details in a single call
    $UserDetails = Get-MgUser -Filter "UserPrincipalName eq '$UPN'"
    $UserID = ($UserDetails | Select-Object Id).Id
    $UserDepartment = ($UserDetails | Select-Object Department).Department

    if (-not $UserID) {
        Write-Host "User not found for UPN: $UPN"
        Disconnect-MgGraph
        return
    }

    # Switch to handle different department tags or logic
    switch ($UserDepartment) {
        "Operations-Accounting" {
            $TagToLookFor = "OnlyAccounting"
            Write-Host "Department: Accounting. Looking for tag: $TagToLookFor"
        }
        "Marketing-Acquisition" {
            $TagToLookFor = "OnlyAcquisition"
            Write-Host "Department: Acquisition. Looking for tag: $TagToLookFor"
        }
        "Marketing-Design" {
            $TagToLookFor = "OnlyCrea"
            Write-Host "Department: Crea. Looking for tag: $TagToLookFor"
        }
        "Consulting-CSM" {
            $TagToLookFor = "OnlyCS"
            Write-Host "Department: Consulting. Looking for tag: $TagToLookFor"
        }
        
        "Operations-HR" {
            $TagToLookFor = "OnlyHR"
            Write-Host "Department: HR. Looking for tag: $TagToLookFor"
        }
        "Operations-Legal" {
            $TagToLookFor = "OnlyLegal"
            Write-Host "Department: Legal. Looking for tag: $TagToLookFor"
        }
        "Marketing" {
            $TagToLookFor = "OnlyMarketing"
            Write-Host "Department: Marketing. Looking for tag: $TagToLookFor"
        }
        "Marketing-ProductMarketing" {
            $TagToLookFor = "OnlyPM"
            Write-Host "Department: PM. Looking for tag: $TagToLookFor"
        }
        "RFP" {
            $TagToLookFor = "OnlyRFP"
            Write-Host "Department: RFP. Looking for tag: $TagToLookFor"
        }
        "Sales-SalesEx-intl"{
            $TagToLookFor = "OnlySales"
            Write-Host "Department: Sales. Looking for tag: $TagToLookFor"
        }
        "Sales-SalesEx-France"{
            $TagToLookFor = "OnlySales"
            Write-Host "Department: Sales. Looking for tag: $TagToLookFor"
        }
        "Sales-SalesEx-Apac"{
            $TagToLookFor = "OnlySales"
            Write-Host "Department: Sales. Looking for tag: $TagToLookFor"
        }
        "IT" {
            $TagToLookFor = "OnlyIT"
            Write-Host "Department: IT. Looking for tag: $TagToLookFor"
        }
        "Sales-Sdr-France"{ 
            $TagToLookFor = "OnlySDRs"
            Write-Host "Department: SDR. Looking for tag: $TagToLookFor"
        }
        "Sales-Sdr-Intl"{ 
            $TagToLookFor = "OnlySDRs"
            Write-Host "Department: SDR. Looking for tag: $TagToLookFor"
        }
        "Sales-SolutionsConsulting" {
            $TagToLookFor = "OnlySolutionConsulting"
            Write-Host "Department: Solutions Consulting. Looking for tag: $TagToLookFor"
        }
        "Product-ClientSupport" {
            $TagToLookFor = "OnlySupport"
            Write-Host "Department: Support. Looking for tag: $TagToLookFor"
        }
        "Consulting-CSTA" {
            $TagToLookFor = "OnlyTechnicalArchitect"
            Write-Host "Department: Tech. Looking for tag: $TagToLookFor"
        }
        default {
            Write-Host "Department not recognized. No specific tags to look for."
            Disconnect-MgGraph
            return
        }
    }

    # Iterate over all teams the user has joined
    $AllTeamUser = Get-mgUserJoinedTeam -UserId $UserID
    foreach ($Team in $AllTeamUser) {
        Write-Host "Team: $($Team.DisplayName) | ID: $($Team.Id)"
        
        # Fetch and display team tags
        $TeamTags = Get-MgTeamTag -TeamId $Team.Id
        if ($TeamTags.Count -eq 0) {
            Write-Host "No tags found for Team $($Team.DisplayName). Moving to next team."
            continue
        } else {
            Write-Host "Tags for Team $($Team.DisplayName):"
            $tagFound = $false

            # Automatically add the user to the tag matching their department
            foreach ($Tag in $TeamTags) {
                if ($Tag.DisplayName -eq $TagToLookFor) {
                    $tagFound = $true
                    try {
                        # Add the user to the tag
                        New-MgTeamTagMember -TeamId $Team.Id -TeamworkTagId $Tag.Id -UserId $UserID -Confirm:$false
                        Write-Host "User successfully added to tag $TagToLookFor in team $($Team.DisplayName)" -ForegroundColor Green
                    } catch {
                        Write-Host "Failed to add user to tag: $_" -ForegroundColor Red
                    }
                    break # Stop looping through tags once the user is added
                }
            }

            if (-not $tagFound) {
                Write-Host "No tag matching '$TagToLookFor' found in Team $($Team.DisplayName)." -ForegroundColor Gray
            }
        }
    }
# Loop to process multiple users
if ($UserDepartment -eq "Consulting-CSM") {




    # Ask for the department to determine which tag to use
    $UserDepartment1 = Read-Host -Prompt "Enter the Sub-department of the CSM user (e.g., CS-APAC, CS-Business, CS-DPM, CS-EMEA, etc.)"

    # Switch to handle different department tags or logic
    switch ($UserDepartment1) {
        "CS-APAC" {
            $TagToLookFor = "OnlyCS-APAC"
            Write-Host "Department: Consulting APAC. Looking for tag: $TagToLookFor"
        }
        "CS-Business" {
            $TagToLookFor = "OnlyCS-Business"
            Write-Host "Department: Consulting Business. Looking for tag: $TagToLookFor"
        }
        "CS-DPM" {
            $TagToLookFor = "OnlyCS-DPM"
            Write-Host "Department: Consulting DPM. Looking for tag: $TagToLookFor"
        }
        "CS-EMEA" {
            $TagToLookFor = "OnlyCS-EMEA"
            Write-Host "Department: Consulting EMEA. Looking for tag: $TagToLookFor"
        }
        "CS-Enterprise" {
            $TagToLookFor = "OnlyCS-Enterprise"
            Write-Host "Department: Consulting Enterprise. Looking for tag: $TagToLookFor"
        }
        "CS-Growth" {
            $TagToLookFor = "OnlyCS-Growth"
            Write-Host "Department: Consulting Growth. Looking for tag: $TagToLookFor"
        }
        "CS-Essential" {
            $TagToLookFor = "OnlyCS-Essential"
            Write-Host "Department: Consulting Essential. Looking for tag: $TagToLookFor"
        }
        "CS-Growth-EMEA" {
            $TagToLookFor = "OnlyCS-Growth-EMEA"
            Write-Host "Department: Consulting Growth EMEA. Looking for tag: $TagToLookFor"
        }
        "CS-NorthAmerica" {
            $TagToLookFor = "OnlyCS-NorthAmerica"
            Write-Host "Department: Consulting North America. Looking for tag: $TagToLookFor"
        }
        default {
            Write-Host "Department not recognized. No specific tags to look for."
            Disconnect-MgGraph
            return
        }
    }

    # Iterate over all teams the user has joined
    $AllTeamUser = Get-mgUserJoinedTeam -UserId $UserID
    foreach ($Team in $AllTeamUser) {
        Write-Host "Team: $($Team.DisplayName) | ID: $($Team.Id)"
        
        # Fetch and display team tags
        $TeamTags = Get-MgTeamTag -TeamId $Team.Id
        if ($TeamTags.Count -eq 0) {
            Write-Host "No tags found for Team $($Team.DisplayName). Moving to next team."
            continue
        } else {
            Write-Host "Tags for Team $($Team.DisplayName):"
            $tagFound = $false

            # Automatically add the user to the tag matching their department
            foreach ($Tag in $TeamTags) {
                if ($Tag.DisplayName -eq $TagToLookFor) {
                    $tagFound = $true
                    try {
                        # Add the user to the tag
                        New-MgTeamTagMember -TeamId $Team.Id -TeamworkTagId $Tag.Id -UserId $UserID -Confirm:$false
                        Write-Host "User successfully added to tag $TagToLookFor in team $($Team.DisplayName)" -ForegroundColor Green
                    } catch {
                        Write-Host "Failed to add user to tag: $_" -ForegroundColor Red
                    }
                    break # Stop looping through tags once the user is added
                }
            }

            if (-not $tagFound) {
                Write-Host "No tag matching '$TagToLookFor' found in Team $($Team.DisplayName)." -ForegroundColor Gray
            }
        }
    }
}


    # Ask if the user wants to process another UPN
    $processAnotherUser = Read-Host "Do you want to process another user? (Y/N)"
    Disconnect-MgGraph

} while ($processAnotherUser -eq 'Y')
