Connect-MgGraph 

$Device = Read-Host -Prompt "Enter the name of the device to get the informations"
$DeviceID = (Get-MgBetaDevice -Filter "DisplayName eq '$Device'" | Select-Object DeviceId).DeviceId
$DeviceCheck = (Get-MgBetaDevice -Filter "DisplayName eq '$Device'" | Select-Object DeviceCategory).DeviceCategory
# Print the device category
Write-Host "The device $Device is in the category $DeviceCheck" -ForegroundColor Green


# Function to update device category
function Update-DeviceCategory {
    param (
        [string]$DeviceID,
        [string]$NewCategory
    )
    
    $Params = @{
        DeviceCategory = "$NewCategory"
    } | ConvertTo-Json

    Update-MgBetaDevice -DeviceId $DeviceID -BodyParameter $Params

    if ($?) {
        Write-Host "The device $Device has been changed to $NewCategory" -ForegroundColor Green
    } else {
        Write-Host "The device $Device has not been changed" -ForegroundColor Red
    }
}
   # List all categories if not 'Only'
   $Categories = (Get-MgBetaDevice | Select-Object DeviceCategory).DeviceCategory | Sort-Object -Unique
   foreach ($Category in $Categories) {
       Write-Host $Category
   }
if ($DeviceCheck -contains "Only-*") {
    Write-Host "The device $Device is in the category $DeviceCheck"
    $PromptMessage = "Do you want to change the category of the device ? (Y/N)"
} else {
    $PromptMessage = "Do you want to add a category of the device ? (Y/N)"
    
 
}

$AskingForChange = Read-Host -Prompt $PromptMessage
if ($AskingForChange -eq "Y") {
    $NewCategory = Read-Host -Prompt "Enter the new category of the device"
    Update-DeviceCategory -DeviceID $DeviceID -NewCategory $NewCategory
} else {
    Write-Host "The device $Device has not been changed" -ForegroundColor Red
}

Disconnect-MgGraph
