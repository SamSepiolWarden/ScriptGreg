Connect-MsolService

$PowerBi = New-Object System.Management.Automation.Host.ChoiceDescription '&PowerBi' , 'Add Licence PowerBiPro'
$OfficeE3 = New-Object System.Management.Automation.Host.ChoiceDescription '&OfficeE3' , 'Add Licence OfficeE3'
$Sharepoint = New-Object System.Management.Automation.Host.ChoiceDescription '&Sharepoint' , 'Add Licence Sharepoint'

$options = [System.Management.Automation.Host.ChoiceDescription[]]($PowerBi, $OfficeE3, $Sharepoint)
$Result = $host.UI.PromptForChoice('Task Menu', 'Select a Licence', $options , 0)

$accountSkuId = ""
switch($Result)
{
    0 { $accountSkuId = 'azureechoboostbrainsonic491:POWER_BI_PRO' } #Licence PowerBiPro
    1 { $accountSkuId = 'azureechoboostbrainsonic491:SPE_E3' } #Licence OfficeE3
    2 { $accountSkuId= 'azureechoboostbrainsonic491:SHAREPOINTSTORAGE' } #Licence Sharepoint
}

$Licence = Get-MsolAccountSku | Where-Object {$_.AccountSkuId -eq $accountSkuId}

if ($licences.ActiveUnits - $licences.ConsumedUnits -gt 0)
{
    #Get the user to add
    $User = Read-Host -Prompt "Enter the Name of the mailbox to add"
    #Add the licence
    Set-MsolUserLicense -UserPrincipalName $User -AddLicenses $accountSkuId 
    Write-Host $User Succesfully added -ForegroundColor Green
}
else
{
    Write-Host $User already has a licence -ForegroundColor Red
}


