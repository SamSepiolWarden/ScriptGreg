Connect-ExchangeOnline

$DynamicDL = Read-Host -Prompt "Enter the name of the Dynamic Distribution List to create"
$Department = Read-Host -Prompt "Enter the department of the Dynamic Distribution List to create"
$Alias = Read-Host -Prompt "Enter the alias of the Dynamic Distribution List to create"
$RecipientsType = Read-Host -Prompt "Enter the recipieznt type of the DL $DynamicDL to add to the Dynamic Distribution List"

$Adding = New-DynamicDistributionGroup -Name $DynamicDL -RecipientFilter "(RecipientType -eq '$RecipientsType') -and (Department -eq '$Department')"  -Alias $Alias
if($Adding -eq $ErrorAction)
{
    Write-Host -ErrorAction -ForegroundColor Red
    Write-Host "Dynamic Distribution List $DynamicDL not created" -ForegroundColor Red
    Disconnect-ExchangeOnline 
}
else
{
    Write-Host "Dynamic Distribution List $DynamicDL created successfully" -ForegroundColor Green 
    $AskExternal = Read-Host -Prompt "Do you want to receive external commuication ? (Y/N)"
    if($AskExternal -eq "Y")
    {
        
        Set-DynamicDistributionGroup -identity $DynamicDL -RequireSenderAuthenticationEnabled $true -ErrorAction SilentlyContinue
    }
    else
    {
        Write-Host "Dynamic Distribution List $DynamicDL created successfully with no communication external" -ForegroundColor Green
    }
}
Disconnect-ExchangeOnline