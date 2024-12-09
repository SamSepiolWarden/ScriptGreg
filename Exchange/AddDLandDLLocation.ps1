Connect-ExchangeOnline
$User = Read-Host "Enter Name of the mailbox to add"
Try {
    $Mbx = Get-Mailbox -Identity $User -ErrorAction Stop | Select-Object -ExpandProperty PrimarySmtpAddress}
Catch {
    $Mbx | Write-Host "No mailbox can be found called" $User; break }
$Office = [System.Management.Automation.Host.ChoiceDescription]::new('&Office')
$Office.HelpMessage = 'Get running OfficeDL'
$Paris = New-Object System.Management.Automation.Host.ChoiceDescription '&Paris' , 'Get running ParisDL'
$Lyon = New-Object System.Management.Automation.Host.ChoiceDescription '&Lyon' , 'Get running LyonDL'
$Mumbai = New-Object System.Management.Automation.Host.ChoiceDescription '&Mumbai' , 'Get running MumbaiDL'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($Paris, $Lyon, $Mumbai)
$Result = $host.UI.PromptForChoice('Task Menu', 'Select a Location', $options , 0)

switch($Result)
{
    0 { $Location = "Paris"}
    1 { $Location = "Lyon"}
    2 { $Location = "Mumbai"}
}

$DLs = Import-Csv -Path "C:\Users\GregorySemedo\Desktop\Script\DL\DL-$Location.csv"
ForEach ($DL in $DLs) {
     Try {
       Add-DistributionGroupMember -Identity $DL."DL" -Member $User -ErrorAction Continue }
      Catch {
        Write-Host "Couldn't add" $User "to DL" (Get-DistributionGroup -Identity $DL."DL").DisplayName }
       If($?)
       {
        Write-Host $User Succesfully added -ForegroundColor Green
       } 
       Else
       {
        Write-Host $User Error occurred -ForegroundColor Red
       }
}

$CSM = New-Object System.Management.Automation.Host.ChoiceDescription '&CSM', 'Get running CSMDL'
$HR = New-Object System.Management.Automation.Host.ChoiceDescription '&HR', 'Get running HRDL'
$Legal = New-Object System.Management.Automation.Host.ChoiceDescription '&Legal', 'Get running LegalDL'
$Marketing = New-Object System.Management.Automation.Host.ChoiceDescription '&Marketing', 'Get running MarketingDL'
$Product = New-Object System.Management.Automation.Host.ChoiceDescription '&Product', 'Get running ProductDL'
$Sales = New-Object System.Management.Automation.Host.ChoiceDescription '&Sales', 'Get running SalesDL'
$Tech = New-Object System.Management.Automation.Host.ChoiceDescription '&Tech', 'Get running TechDL'
$Corp = New-Object System.management.Automation.Host.ChoiceDescription '&Corp', 'Get running CorpDL'
$Quit = New-Object System.Management.Automation.Host.ChoiceDescription '&Quit', 'Quit menu'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($CSM, $HR, $Legal, $Marketing, $Product, $Sales, $Tech, $Corp, $Quit)
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
    7 { $Department = "Corp" }
    8 { $Quit = Write-Host "Stop the process and quit" | Disconnect-ExchangeOnline; break }

}
#############################################

$DLs = Import-Csv -Path "C:\Users\GregorySemedo\Desktop\Script\DL\DL-$Department.csv"
ForEach ($DL in $DLs) {
     Try {
       Add-DistributionGroupMember -Identity $DL."DL" -Member $User -ErrorAction Continue }
      Catch {
        Write-Host "Couldn't add" $User "to DL" (Get-DistributionGroup -Identity $DL."DL").DisplayName }
       If($?)
       {
        Write-Host $User Succesfully added -ForegroundColor Green
       } 
       Else
       {
        Write-Host $User Error occurred -ForegroundColor Red
       }
}

Disconnect-ExchangeOnline
