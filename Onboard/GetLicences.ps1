Connect-MgGraph

$AllLicences = Get-MgSubscribedSku
$AllLicences |  ForEach-Object {
    $prepaidUnits = $_.PrepaidUnits
    $consumedUnits = $_.ConsumedUnits

    Write-Host "SKU ID: $($_.SkuId)"
    Write-Host "SKU Part Number: $($_.SkuPartNumber)"
    
    Write-Host "Prepaid Units:"
    Write-Host "    Enabled: $($prepaidUnits.Enabled)"
    Write-Host "    Suspended: $($prepaidUnits.Suspended)"
    Write-Host "    Warning: $($prepaidUnits.Warning)"
    
    Write-Host "Consumed Units: $consumedUnits"
    Write-Host "-----------------------"}