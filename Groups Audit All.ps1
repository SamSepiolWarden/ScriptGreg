Connect-MgGraph

# All group azure Ad and policues
$groups = Get-MgGroup -All

# Export all group to csv
$groups | Export-Csv -Path "C:\Test\groups.csv" -NoTypeInformation

if($? -eq $true){
    Write-Host "Export groups to csv OK" -ForegroundColor Green
}
else{
    Write-Host "Issue to export groups to csv" -ForegroundColor Red
}

Disconnect-MgGraph
