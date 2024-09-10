cd "C:\Program Files\McAfee\WebAdvisor"
.\uninstaller.exe /s
if($?)
{Write-Host Succesfully removed -ForegroundColor Green}
else
{Write-Host -ErrorAction Stop -ForegroundColor Red}
cd "C:\Program Files\McAfee'\MSC"
.\mcuihost.exe
if($?)
{Write-Host Succesfully removed -ForegroundColor Green}
else
{Write-Host -ErrorAction Stop -ForegroundColor Red}
