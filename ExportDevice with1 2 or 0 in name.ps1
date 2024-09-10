Connect-MSGraph

# Récupération de tous les appareils Azure Ad
$devices = Get-IntuneManagedDevice

# Filtration des appareils dont le nom contient 'laptop', 'desktop', '0', '1' ou '2'
$filteredDevices = $devices | Where-Object { $_.DeviceName -like '*1*' -or $_.DeviceName -like '*2*' -or $_.DeviceName -like '*0*'}

$filteredDevices | Export-Csv -Path C:\Test\Devices012.csv -NoTypeInformation


