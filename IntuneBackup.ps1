#Module pre installé via powershell juste a lancer la commande pour backup
Update-MSGraphEnvironment -AppId cebe4228-8641-489c-856d-0622fda72157
Connect-MsGraph 
Start-IntuneBackup -Path "C:\Test\IntuneBackup"