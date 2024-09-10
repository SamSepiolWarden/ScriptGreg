## Check for Firefox (File Detection Method)
$FirefoxExe = (Get-ChildItem -Path "C:\Program Files\Mozilla Firefox\firefox.exe","C:\Program Files (x86)\Mozilla Firefox\firefox.exe" -ErrorAction SilentlyContinue)
$FirefoxExe.FullName
$FirefoxPath = $($FirefoxExe.FullName).Replace("C:\Program Files\","").Replace("C:\Program Files (x86)\","")
$FileVersion = (Get-Item -Path "$($FirefoxExe.FullName)" -ErrorAction SilentlyContinue).VersionInfo.FileVersion

## Create Text File with Firefox File Detection Method
$FilePath = "C:\Windows\Temp\Firefox_Detection_Method.txt"
New-Item -Path "$FilePath" -Force
Set-Content -Path "$FilePath" -Value "If([String](Get-Item -Path `"`$Env:ProgramFiles\$FirefoxPath`",`"`${Env:ProgramFiles(x86)}\$FirefoxPath`" -ErrorAction SilentlyContinue).VersionInfo.FileVersion -ge `"$FileVersion`"){"
Add-Content -Path "$FilePath" -Value "Write-Host `"Installed`""
Add-Content -Path "$FilePath" -Value "Exit 0"
Add-Content -Path "$FilePath" -Value "}"
Add-Content -Path "$FilePath" -Value "else {"
Add-Content -Path "$FilePath" -Value "Exit 1"
Add-Content -Path "$FilePath" -Value "}"
Invoke-Item $FilePath