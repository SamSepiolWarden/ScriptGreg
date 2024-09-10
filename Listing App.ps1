New-Item -Type Directory -Path "C:\Test"
Set-Location -Path "C:\Test\"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force
Get-WMIObject -Class "Win32_Product" | Select Vendor, Name, Version| Export-Csv -Path C:\Test\ListApp.csv