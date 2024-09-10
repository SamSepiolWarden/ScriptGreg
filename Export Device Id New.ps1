Connect-AzureAD
Get-AzureADDevice -All:$true | Select-Object -Property DisplayName,Deviceid | Export-Csv -Path C:\Test\DeviceId.csv
Disconnect-AzureAD