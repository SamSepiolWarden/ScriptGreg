Connect-MgGraph -Scopes "Directory.ReadWrite.All"

# Demander le nom du device
$SearchDevice = Read-Host -Prompt 'Enter the device name'

# Rechercher le device id
$Device = (Get-MgBetaDevice -Filter "displayName eq '$SearchDevice'"|Select-Object Id).Id

# Rechercher la category du device
$Category = (Get-MgBetaDevice -DeviceId $Device | Select-Object DeviceCategory).DeviceCategory

# Ecrire la category du device
Write-Host "Device category is $Category for the laptop $SearchDevice"

# Lister les category de device
$AllCategory = get-mgbetaDevice -All | Select-Object -ExpandProperty DeviceCategory | Sort-Object -Unique

# Ecrire les category de device
foreach ($Category in $AllCategory) {
    Write-Host $Category
}


# Demander le changement de category
$AskChange = Read-Host -Prompt 'Do you want to change the category ? (Y/N)'
if ($AskChange -eq 'Y') {
# lister les category
$Categories = Get-MgBetadevice -All | Select-Object -ExpandProperty DeviceCategory | Sort-Object -Unique
foreach ($Category in $Categories) {
    Write-Host $Category
}
# Demander la nouvelle category
$NewCategory = Read-Host -Prompt 'Enter the new category'
$BodyParams = @{
    DeviceCategory = $NewCategory
}
try {
    # Changer la category
Update-MgBetaDeviceManagementManagedDeviceCategory -ManagedDeviceId $Device -BodyParameter $BodyParams 
}
catch {
    Write-Host "Error : $_"
}
}
else {
    Write-Host "Error : $_ "}
Disconnect-MgGraph    
