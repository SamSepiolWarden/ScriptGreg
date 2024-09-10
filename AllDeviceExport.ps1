Connect-MgGraph

$Device = Get-MgDevice -property *
$Device | Export-Csv -Path C:\Windows\Temp\Device.csv -NoTypeInformation