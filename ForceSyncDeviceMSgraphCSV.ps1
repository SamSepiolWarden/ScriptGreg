Connect-MsGraph
# Initial prompt
$Ask = "Y"
while ($Ask.ToLower() -eq "y"){

    # Import device names from CSV
    $DeviceNames = Import-Csv -Path "C:\Test\DeviceList.csv"

    foreach ($Device in $DeviceNames) {
        # Get last sync for each device
        $Sync = Get-IntuneManagedDevice | Where-Object DeviceName -Like $Device.DeviceName | Select-Object -Property LastSyncDateTime
        
        # Output the last sync for each device
        Write-Host "Last sync time for $($Device.DeviceName): $($Sync.LastSyncDateTime)" -ForegroundColor Cyan
        
        # Ask if user wants to sync this device
        $AskSync = Read-Host -Prompt "Do you want to sync $($Device.DeviceName)? (Y/N)"
        if($AskSync.ToUpper() -eq "Y"){
            
            # Try to sync the device
            Get-IntuneManagedDevice | Where-Object DeviceName -Like $Device.DeviceName | Invoke-IntuneManagedDeviceSyncDevice
            
            # Output the result of the sync attempt
            if ($?) {
                Write-Host "$($Device) has been successfully synced." -ForegroundColor Green
            } else {
                Write-Host "Failed to sync $($Device)." -ForegroundColor Red
            }
        } else {
            Write-Host "No sync has been done for $($Device)." -ForegroundColor Yellow
        }
    }
    
    # Ask if user wants to process another list of devices
    $Ask = Read-Host -Prompt "Do you want to sync another list of devices? (Y/N)"
}

if($Ask.ToLower() -eq "n"){
    Write-Host "End of Sync" -ForegroundColor Green
}
