Connect-AzureAD

$devices = Get-AzureADDevice -All $true

$Manufacturers = $devices | Select-Object -ExpandProperty Manufacturer | Sort-Object -Unique

$Manufacturers