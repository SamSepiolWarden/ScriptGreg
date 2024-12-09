Connect-ExchangeOnline
$User = Read-Host "Enter Name of the mailbox to remove"
Try {
    $Mbx = Get-Mailbox -Identity $User -ErrorAction Stop | Select -ExpandProperty PrimarySmtpAddress}
Catch {
    Write-Host "No mailbox can be found called" $User; break }
$Services = [System.Management.Automation.Host.ChoiceDescription]::new('&Services')
$Services.HelpMessage = 'Get running services'
$CSM = New-Object System.Management.Automation.Host.ChoiceDescription '&CSM', 'Remove from CSMDL'
$HR = New-Object System.Management.Automation.Host.ChoiceDescription '&HR', 'Remove from HRDL'
$Legal = New-Object System.Management.Automation.Host.ChoiceDescription '&Legal', 'Remove from LegalDL'
$Marketing = New-Object System.Management.Automation.Host.ChoiceDescription '&Marketing', 'Remove from MarketingDL'
$Product = New-Object System.Management.Automation.Host.ChoiceDescription '&Product', 'Remove from ProductDL'
$Sales = New-Object System.Management.Automation.Host.ChoiceDescription '&Sales', 'Remove from SalesDL'
$Tech = New-Object System.Management.Automation.Host.ChoiceDescription '&Tech', 'Remove from TechDL'
$Quit = New-Object System.Management.Automation.Host.ChoiceDescription '&Quit', 'Quit menu'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($CSM, $HR, $Legal, $Marketing, $Product, $Sales, $Tech, $Quit)
$Result = $host.UI.PromptForChoice('Task menu', 'Select a Department', $options , 0 )

switch($result)
{
    0 { $Department = "CSM"}
    1 { $Department = "HR"}
    2 { $Department = "Legal"}
    3 { $Department = "Marketing"}
    4 { $Department = "Product"}
    5 { $Department = "Sales"}
    6 { $Department = "Tech" }
    7 { $Quit = Exit }

}
#############################################

$DLs = Import-Csv -Path "C:\Users\GregorySemedo\Desktop\Script\DL\DL-$Department.csv"
ForEach ($DL in $DLs) {
     Try {
       Remove-DistributionGroupMember -Identity $DL."DL" -Member $User -ErrorAction Continue }
      Catch {
        Write-Host "Couldn't remove" $User "to DL" (Get-DistributionGroup -Identity $DL."DL").DisplayName }
       If($?)
       {
        Write-Host $User Succesfully remove from DL -ForegroundColor Green
       } 
       Else
       {
        Write-Host $User - Error occurred -ForegroundColor Red
       }
}
Disconnect-ExchangeOnline