Connect-AzureAD
Get-AzureADUser -All:$true | Where-Object {$_.userType -ne "Guest"} | Select-Object -Property ObjectId | Export-Csv -Path C:\Test\UserId.csv
Disconnect-AzureAD