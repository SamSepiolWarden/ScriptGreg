Connect-MgGraph

# recuperer tous les devices
$Alldevices = Get-MgDeviceManagementManagedDevice -All:$true

# creer un array pour enregistrer les devices qui n'ont pas de categorie
$NoCategory = @()

# boucler a travers tous les devices
foreach ($device in $Alldevices)

{
    # verifier si le device a une categorie
    if ($device.deviceCategoryDisplayName -eq "Unknown" -or $device.deviceCategoryDisplayName -eq "OnlyUnused")
    {
        # ajouter le device a l'array
        $NoCategory += $device
    }
}

# afficher les devices qui n'ont pas de categorie
$NoCategory | Select-Object -Property DeviceName, deviceCategoryDisplayName

#Export to a CSV file
$NoCategory | Select-Object -Property DeviceName, deviceCategoryDisplayName | Export-Csv -Path "C:\Test\NoCategoryDevice.csv" -NoTypeInformation

# Disconnect from microsoft graph
Disconnect-MgGraph