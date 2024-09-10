Connect-ExchangeOnline

$DLName = Read-Host -Prompt "Enter the name of the Dynamic Distribution List to search"
$DL = Get-DynamicDistributionGroup -Identity $DLName -ErrorAction SilentlyContinue

if ($null -ne $DL) {
    Write-Host "Dynamic Distribution List $DLName found" -ForegroundColor Green
    $DL | Format-List Name, RecipientFilterType, ConditionalDepartment, Alias, RequireSenderAuthenticationEnabled
    $AskForChange = Read-Host -Prompt "Do you want to change the Settings of the DL ? (Y/N)"
    if ($AskForChange -eq "Y") {
        $AskExternal = Read-Host -Prompt "Do you want to receive external commuication 1 or change the RecipientFilter 2 ? (1/2)"
        if ($AskExternal -eq "1") {
            Set-DynamicDistributionGroup -identity $DLName -RequireSenderAuthenticationEnabled $false -ErrorAction SilentlyContinue
        } else {
            
            $Department = Read-Host -Prompt "Enter the department of the DL $DLName to add to the Dynamic Distribution List"
            $RecipientType = Read-Host -Prompt "Enter the recipieznt type of the DL $DLName to add to the Dynamic Distribution List"
            Set-DynamicDistributionGroup -identity $DLName -RecipientFilter "(RecipientType -eq '$RecipientType') -and (Department -eq '$Department')"
            if($?)
            {
                Write-Host "Dynamic Distribution List $DLName updated successfully" -ForegroundColor Green 
            }
            else
            {
                Write-Error -ErrorRecord -ForegroundColor Red
            }
        }
    } else {
    }
} else {
    Write-Host "Dynamic Distribution List $DLName not found" -ForegroundColor Red | Write-Host "Please create it before" -ForegroundColor Red
}
Disconnect-ExchangeOnline
