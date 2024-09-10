Install-Module -Name PSWindowsUpdate -Confirm:$false
Import-Module PSWindowsUpdate
Get-WindowsUpdate
Install-WindowsUpdate -AcceptAll -AutoReboot:$false