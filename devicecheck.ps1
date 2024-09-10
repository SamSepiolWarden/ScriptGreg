Connect-MgGraph
$DeviceCheck = get-mgdevice -deviceid bb8fdbe0-569f-48dc-b458-039c0db4374d
$DeviceCheck | select-object -property * | export-csv -path "C:\Test\DeviceCheck.csv"