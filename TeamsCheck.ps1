$Version = "1.6.00.26474"
$Url = "https://teams.microsoft.com/desktopclient/update/$Version/windows/x64?ring=general"

Write-Host "Sending request to $Url"
$updateCheckResponse = Invoke-WebRequest -Uri $Url -UseBasicParsing
$updateCheckJson = $updateCheckResponse | ConvertFrom-Json
$updateCheckJson
# Get Microsoft Teams Version with PowerShell

$TeamsExe = Get-Item (“${Env:LOCALAPPDATA}” + “\Microsoft\Teams\current\Teams.exe”)

$LogFile = $env:APPDATA + “\Microsoft\Teams\logs.txt”

$InstallTimeFile = $env:APPDATA + “\Microsoft\Teams\installTime.txt”

$TeamsVersion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($TeamsExe)

$InstallDate = Get-Content $InstallTimeFile

$ringInfo = Get-Content $LogFile | Where-Object { $_.Contains(“ring=”) }

$d = $($ringInfo[-1]) -split “ring”

$UpdateCheckDate = $($ringInfo[-1]) -split “<”

$TeamsVersion
Write-Host “”
If ($null -ne $d[2])
{
write-host “Ring: $($d[2].Replace(“_”,”.”))”
}
else
{
write-host “Ring is GA”
}
Write-Host “”
Write-host “Install Date: $($InstallDate)”
Write-Host “”
Write-Host “Last Update Check: $($UpdateCheckDate[0])”