Import-Module Microsoft.Graph.DeviceManagement
Connect-Mggraph

$ExportPath = Read-Host -Prompt "Please specify a path to export the policy data to e.g. C:\IntuneOutput" 

# If the directory path doesn't exist prompt user to create the directory
$ExportPath = $ExportPath.replace('"', '')

if (!(Test-Path "$ExportPath")) {

    Write-Host
    Write-Host "Path '$ExportPath' doesn't exist, do you want to create this directory? Y or N?" -ForegroundColor Yellow

    $Confirm = read-host

    if ($Confirm -eq "y" -or $Confirm -eq "Y") {

        new-item -ItemType Directory -Path "$ExportPath" | Out-Null
        Write-Host

    }

    else {

        Write-Host "Creation of directory path was cancelled..." -ForegroundColor Red
        Write-Host
        break

    }

}

Write-Host "Exporting Device Configuration Policies..." -ForegroundColor Cyan

Write-Host

# Filtering out iOS and Windows Software Update Policies
$DCPs = Get-MgDeviceManagementDeviceConfiguration | Select-Object Id, DisplayName, Version, AdditionalProperties | Where-Object { ($_.AdditionalProperties.'@odata.type' -ne "#microsoft.graph.iosUpdateConfiguration") -and ($_.AdditionalProperties.'@odata.type' -ne "#microsoft.graph.windowsUpdateForBusinessConfiguration") }

foreach ($DCP in $DCPs) {
    $fName = $DCP.displayName
    write-host "Device Configuration Policy:"$fName -f Yellow
    $DCP | ConvertTo-Json -Depth 100 | Out-File -FilePath "$ExportPath\$fName.json" -Encoding UTF8
    Write-Host
}
Disconnect-MgGraph