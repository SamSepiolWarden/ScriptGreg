Connect-MsolService
$Fname = Read-Host -Prompt "Enter the First Name of the user to add"
$Lname = Read-Host -Prompt "Enter the Last Name of the user to add"
$Username = Read-Host -Prompt "Enter the email of the user to add "
$Department = Read-Host -Prompt "Enter the Department of the user to add"
$Alternate = $Fname + "." + $Lname + "@azureechoboostbrainsonic491.onmicrosoft.com"
$Displayname = $Fname + " " + $Lname
$Strong = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
    $Strong.RelyingParty = *
    $Strong.State = "Enabled"
$StrongMFA = $Strong
$UsageLocation = Read-Host -Prompt "Enter the location of the user (US,FR)"
# Create a new user
New-MsolUser -DisplayName $Displayname -FirstName $Fname -LastName $Lname -UserPrincipalName $Username -Department $Department -AlternateEmailAddresses $Alternate -ForceChangePassword $true -BlockCredential $true  -ErrorAction SilentlyContinue 
Set-MsolUser -UserPrincipalName $Username -UsageLocation $UsageLocation
# Check if the user was created successfully
if ($?)
{
    $Licence = Get-MsolAccountSku | Where-Object {$_.SkuPartNumber -eq "azureechoboostbrainsonic491:SPE_E3"}
    $Licence1 = Get-MsolAccountSku | Where-Object {$_.SkuPartNumber -eq "azureechoboostbrainsonic491:TVM_Premium_Standalone"}
    # Check if there are licenses available
    if ($Licence.ConsumedUnits -ge $Licence.WarningUnits -or $Licence1.ConsumedUnits -ge $Licence1.WarningUnits)
    {
        Set-MsolUserLicense -UserPrincipalName $Username -AddLicenses $Licence.AccountSkuId
        Set-MsolUserLicense -UserPrincipalName $Username -AddLicenses $Licence1.AccountSkuId
        Write-Host "Licence assigned to $Username" -ForegroundColor Green
    }
    else
    {
        Write-Host "No more licences available" -ForegroundColor Red
    }
}
else
{
    Write-Error -ErrorRecord -ForegroundColor Red
}
Set-MsolUser -UserPrincipalName $Username -StrongAuthenticationRequirements $StrongMFA
if($?)
{
    Write-Host "MFA for $Username Enabled" -ForegroundColor Green
}
else {
    Write-Host "Mfa for $Username not enable" -ForegroundColor Red -ErrorAction
}