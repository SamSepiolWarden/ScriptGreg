Connect-MsolService
$Deviceid = Read-Host -Prompt "enter the Id of the Device"
Get-MsolDevice -DeviceId $Deviceid

