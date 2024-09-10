Connect-ExchangeOnline
$User = Read-Host "Enter Name of the mailbox to add"
Try {
    Get-Mailbox -Identity $User -ErrorAction Stop | Select-Object -ExpandProperty PrimarySmtpAddress}
Catch {
    Write-Host "No mailbox can be found called" $User; break }

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
     
       Add-DistributionGroupMember -Identity $DL."DL" -Member $User -ErrorAction Continue 
       If($?)
       {
        Write-Host $User Succesfully added to DL -ForegroundColor Green
       } 
       Else
       {
        Write-Host -ErrorAction Stop -ForegroundColor Red
       }
}

$Services = [System.Management.Automation.Host.ChoiceDescription]::new('&Services')
$Services.HelpMessage = 'Get running services'
$CSM = New-Object System.Management.Automation.Host.ChoiceDescription '&CSM', 'Get running CSMDL'
$HR = New-Object System.Management.Automation.Host.ChoiceDescription '&HR', 'Get running HRDL'
$Legal = New-Object System.Management.Automation.Host.ChoiceDescription '&Legal', 'Get running LegalDL'
$Marketing = New-Object System.Management.Automation.Host.ChoiceDescription '&Marketing', 'Get running MarketingDL'
$Partnership = New-Object System.Management.Automation.Host.ChoiceDescription '&Partnership', 'Get running PartnershipDL'
$Product = New-Object System.Management.Automation.Host.ChoiceDescription '&Product', 'Get running ProductDL'
$Sales = New-Object System.Management.Automation.Host.ChoiceDescription '&Sales', 'Get running SalesDL'
$SolutionsConsulting = New-Object System.Management.Automation.Host.ChoiceDescription '&SolutionsConsulting', 'Get running SolutionsConsultingDL'
$Tech = New-Object System.Management.Automation.Host.ChoiceDescription '&Tech', 'Get running TechDL'
$Corp = New-Object System.Management.Automation.Host.ChoiceDescription '&Corp', 'Get running CorpDL'
$Support = New-Object System.Management.Automation.Host.ChoiceDescription '&Support', 'Get running SupportDL'
$Crea = New-Object System.Management.Automation.Host.ChoiceDescription '&Crea', 'Get running CreaDL'
$Quit = New-Object System.Management.Automation.Host.ChoiceDescription '&Quit', 'Quit menu'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($CSM, $HR, $Legal, $Marketing, $Partnership, $Product, $Sales, $SolutionsConsulting, $Tech, $Corp, $Support, $Crea, $Quit)
$Result = $host.UI.PromptForChoice('Task menu', 'Select a Department', $options , 0 )

switch($result)
{
    0 { $Department = "CSM"}
    1 { $Department = "HR"}
    2 { $Department = "Legal"}
    3 { $Department = "Marketing"}
    4 { $Department = "Partnership"}
    5 { $Department = "Product"}
    6 { $Department = "Sales"}
    7 { $Department = "SolutionsConsulting"}
    8 { $Department = "Tech" }
    9 { $Department = "Corp" }
    10 { $Department = "Support"}
    11 { $Department = "Crea"}
    12 { $Quit = Exit }

}
#############################################

$DLs = Import-Csv -Path "C:\Users\GregorySemedo\Desktop\Script\DL\DL-$Department.csv"
ForEach ($DL in $DLs) {
     
            Add-DistributionGroupMember -Identity $DL."DL" -Member $User -ErrorAction Continue 
       If($?)
       {
        Write-Host $User Succesfully added to DL -ForegroundColor Green
       } 
       Else
       {
        Write-Host -ErrorAction Stop -ForegroundColor Red
       }
}

#########
# Ici code pour Groupes Teams
Connect-MicrosoftTeams

$TeamsAdd = Import-Csv -Path "C:\Users\GregorySemedo\Desktop\Script\Ms-Teams-Script\Teams\Teams-$Department.csv"
Foreach($TeamUser in $TeamsAdd)
{
$TeamName = $TeamUser.TeamName
$GroupId = $TeamUser.GroupId
$Role = $TeamUser.Role
 
$i++;
Write-Progress -activity "Processing $TeamName - $Role" -status "$i out of $TotolRows completed"
Add-TeamUser -GroupId $GroupId -User "$User" -Role "$Role"
       If($?)
{
Write-Host $User Succesfully added to $TeamUser.TeamName -ForegroundColor Green
}
else
{
Write-Host -ErrorAction Stop -ForegroundColor Red
}
}
Connect-MicrosoftTeams

$UserInParis = Get-Team -GroupId b2e6ef79-7d1d-4e72-b027-fb8caa25202a | Get-TeamUser  | Where-Object {$_.User -eq $User}
if($UserInParis)
{Write-Host $User is already a member of Paris -ForegroundColor Red}
else {
    Write-Host $User is not a member of Paris -ForegroundColor Green
}
$UserInLyon = Get-Team -GroupId b7e7d611-2ec3-479e-afec-bcedb0aadfb4 | Get-TeamUser | Where-Object {$_.User -eq $User}
if($UserInLyon)
{Write-Host $User is already a member of Lyon -ForegroundColor Red}
else {
    Write-Host $User is not a member of Lyon -ForegroundColor Green
}


If($Location -eq 'Paris')
{Add-TeamUser -GroupId b2e6ef79-7d1d-4e72-b027-fb8caa25202a -User $User -Role Member}
if($Location -eq 'Paris')
{
Write-Host $User Succesfully added to Pais -ForegroundColor Green
}
else
{
Write-Host Skip this team -ForegroundColor Gray
}
If($Location -eq 'Lyon') 
{Add-TeamUser -GroupId b7e7d611-2ec3-479e-afec-bcedb0aadfb4 -User $User -Role Member}
if($Location -eq 'Lyon')
{
Write-Host $User Succesfully added To Lyon -ForegroundColor Green
}
else
{
Write-Host Skip this team -ForegroundColor Gray
}
If($Location -eq 'Quit')
{Write-Host Stop the process | Disconnect-MicrosoftTeams}

Disconnect-MicrosoftTeams
Disconnect-ExchangeOnline

