Connect-MsGraph
#Loop to ask if sync is needed
$Ask = "Y"
while ($Ask.ToLower() -eq "y"){

    #Prompt to get a device name
    $DeviceName = Read-Host -Prompt "Enter the device name"

    #Get last sync
    $Sync = Get-IntuneManagedDevice | Where-Object DeviceName -Like $DeviceName | Select-Object -Property LastSyncDateTime

    #Output the last sync
    Write-Host "Last sync time: $($Sync.LastSyncDateTime)" -ForegroundColor Cyan

    $AskSync = Read-Host -Prompt "Do you want to sync $DeviceName? (Y/N)"
    if($AskSync.ToUpper() -eq "Y"){

        #Get the device and try sync
        Get-IntuneManagedDevice | Where-Object DeviceName -Like $DeviceName | Invoke-IntuneManagedDeviceSyncDevice 

        #Output the device
        if ($?) {
            Write-Host "$DeviceName has been Processing to sync." -ForegroundColor Yellow
        }
        else {
            Write-Host "Failed to sync $DeviceName" -ForegroundColor Red
        }

        # Refresh last sync time after the sync operation
        $Sync = Get-IntuneManagedDevice | Where-Object DeviceName -Like $DeviceName | Select-Object -Property LastSyncDateTime
        Write-Host "Last sync time: $($Sync.LastSyncDateTime)" -ForegroundColor Cyan
    }
    else{
        Write-Host "No sync has been done" -ForegroundColor Yellow
    }

    $Ask = Read-Host -Prompt "Do you want to sync another device? (Y/N)"
}

if($Ask.ToLower() -eq "n"){
    Write-Host "End of Sync" -ForegroundColor Green
}
