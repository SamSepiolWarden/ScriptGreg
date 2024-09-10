# Connect to Azure AD
Connect-AzureAD

# Get all devices
$devices = Get-AzureADDevice -All:$true -Filter "startswith(DeviceOSVersion,'10.0.19044')"

# Export to csv
$devices | Export-Csv -Path 'C:\Test\Migration22H2.csv' -Append -NoTypeInformation

Disconnect-AzureAD
