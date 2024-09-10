Connect-MgGraph

# List all brken and unused category device
$Device = Get-MgDevice -All | Where-Object { $_.DeviceCategory -eq "OnlyBroken" -or $_.DeviceCategory -eq "OnlyUnused" }

# output them to the screen and export them
foreach ($item in $Device) {
    Write-Host "The Device: $($item.DisplayName) | Category: $($item.DeviceCategory)"
}
$Device | Select-Object DisplayName, DeviceCategory | Export-Csv -Path C:\Test\ListUnusedBrokenDevice.csv

# Check if the file was created successfully
if (Test-Path "C:\Test\ListUnusedBrokenDevice.csv") {
    Write-Host "Export successfully created!" -ForegroundColor Green
} else {
    Write-Host "Export failed. Check the script and try again." -ForegroundColor Red
}
Disconnect-MgGraph