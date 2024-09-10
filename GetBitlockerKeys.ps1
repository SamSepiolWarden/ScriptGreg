Import-Module Microsoft.Graph.Identity.SignIns
Import-Module Microsoft.Graph.Identity.DirectoryManagement
Import-Module Microsoft.Graph.DeviceManagement

try {
    #Get all Windows devices from Entra ID.
    $EntraIdAllDevices = Get-MgDevice -All -Property displayName, Id, DeviceId  -Filter "OperatingSystem eq 'Windows'" | Select-Object -Property DisplayName, DeviceId

    #Get devices with BitLocker recovery keys from Entra ID. 
    $EntraIdDevicesWithKeys = Get-MgInformationProtectionBitlockerRecoveryKey -All | Select-Object -Property DeviceId -Unique 

    #Find devices without BitLocker recovery keys in Entra ID by comparing the two lists.
    $EntraDevicesWithoutKeys = $EntraIdAllDevices | Where-Object { $_.DeviceId -notin $EntraIdDevicesWithKeys.DeviceId } | Select-Object -Property DisplayName, DeviceId

    #Get all Windows devices from Intune.
    $IntuneAllDevices = Get-MgDeviceManagementManagedDevice -All -Filter "OperatingSystem eq 'Windows'" -Property Id, DeviceName, AzureAdDeviceId, UserPrincipalName, IsEncrypted | Select-Object -Property Id, AzureAdDeviceId, DeviceName, UserPrincipalName, IsEncrypted

    #Find Intune devices without BitLocker recovery keys in Entra ID by comparing the two lists by AzureAdDeviceId.
    $IntuneDevicesWithoutKeys = $IntuneAllDevices | Where-Object { $_.AzureAdDeviceId -notin $EntraIdDevicesWithKeys.DeviceId } 

    #Find Intune devices with BitLocker recovery keys in Entra ID by comparing the two lists by AzureAdDeviceId.
    $IntuneDevicesWithKeys = $IntuneAllDevices | Where-Object { $_.AzureAdDeviceId -in $EntraIdDevicesWithKeys.DeviceId } 

    #Output results to console.
    Write-Output ("`n" + [string]$EntraIdAllDevices.Count + " Windows device records found in Entra ID")
    Write-Output ([string]$EntraDevicesWithoutKeys.Count + " Windows device records found in Entra ID without BitLocker recovery keys:")
    Write-Output $EntraDevicesWithoutKeys | Format-Table -AutoSize

    Write-Output([string]$IntuneAllDevices.Count + " Windows device records found in Intune")
    Write-Output([string]$IntuneDevicesWithoutKeys.Count + " of these do not have BitLocker recovery keys in Entra ID:")
    Write-Output $IntuneDevicesWithoutKeys | Format-Table -AutoSize
}
catch {
    Write-Output $_.Exception
}

# .csv export examples:
$path = "C:\Test\EncryptionReport.csv"

$EntraIdAllDevices | Export-Csv -Path $Path -NoTypeInformation
$EntraIdDevicesWithKeys | Export-Csv -Path $Path -NoTypeInformation
$EntraDevicesWithoutKeys | Export-Csv -Path $Path -NoTypeInformation
$IntuneAllDevices | Export-Csv -Path $Path -NoTypeInformation
$IntuneDevicesWithKeys | Export-Csv -Path $Path -NoTypeInformation
$IntuneDevicesWithoutKeys | Export-Csv -Path $Path -NoTypeInformation
